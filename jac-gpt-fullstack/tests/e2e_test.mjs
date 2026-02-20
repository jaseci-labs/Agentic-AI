/**
 * E2E tests for jac-gpt-fullstack using @playwright/mcp.
 *
 * Requires:
 *   npm install @playwright/mcp @modelcontextprotocol/sdk
 *   npx playwright install chromium --with-deps
 *
 * Usage:
 *   SERVER_URL=http://localhost:8000 node tests/e2e_test.mjs
 */

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { mkdirSync } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SCREENSHOTS_DIR = join(__dirname, "screenshots");
const SERVER_URL = process.env.SERVER_URL || "http://localhost:8000";

mkdirSync(SCREENSHOTS_DIR, { recursive: true });

// ── helpers ──────────────────────────────────────────────────────────────

let client;
let passed = 0;
let failed = 0;
const failures = [];

async function call(tool, args = {}) {
  const res = await client.callTool({ name: tool, arguments: args });
  const text = res.content
    ?.filter((c) => c.type === "text")
    .map((c) => c.text)
    .join("\n");
  return text || "";
}

/** Extract a ref for an element whose snapshot line matches `pattern`.
 *  Snapshot format: `- button "Show Docs" [ref=e77] [cursor=pointer]:`
 *  If the text is on a child line (no ref), walk up to parent lines to find the ref. */
function findRef(snapshot, pattern) {
  const refRe = /\[ref=([^\]]+)\]/i;
  const lines = snapshot.split("\n");
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].toLowerCase().includes(pattern.toLowerCase())) {
      const m = lines[i].match(refRe);
      if (m) return m[1];
      // Text found but no ref on this line — check parent lines (up to 3 above)
      for (let j = i - 1; j >= Math.max(0, i - 3); j--) {
        const pm = lines[j].match(refRe);
        if (pm) return pm[1];
      }
    }
  }
  return null;
}

async function screenshot(name) {
  try {
    await call("browser_take_screenshot", {
      filename: join(SCREENSHOTS_DIR, `${name}.png`),
    });
  } catch {
    // screenshot failures are non-fatal
  }
}

async function runTest(name, fn) {
  process.stdout.write(`  ${name} ... `);
  try {
    await fn();
    console.log("PASS");
    passed++;
  } catch (err) {
    console.log("FAIL");
    console.log(`    ${err.message}`);
    failures.push({ name, error: err.message });
    failed++;
    await screenshot(name.replace(/\s+/g, "_").toLowerCase());
  }
}

function assert(condition, msg) {
  if (!condition) throw new Error(msg);
}

async function verifyText(text) {
  const res = await client.callTool({
    name: "browser_verify_text_visible",
    arguments: { text },
  });
  const output = res.content?.map((c) => c.text).join("") || "";
  if (output.toLowerCase().includes("not visible") || output.toLowerCase().includes("error")) {
    throw new Error(`Text "${text}" is not visible on page`);
  }
}

async function navigate(url) {
  await call("browser_navigate", { url });
}

async function waitFor(opts, timeout = 30000) {
  await call("browser_wait_for", { ...opts, timeout });
}

async function snap() {
  return await call("browser_snapshot");
}

async function clickByRef(element, ref) {
  await call("browser_click", { element, ref });
}

async function typeByRef(element, ref, text, submit = false) {
  await call("browser_type", { element, ref, text, submit });
}

// ── test cases ───────────────────────────────────────────────────────────

async function main() {
  console.log("\n=== jac-gpt-fullstack E2E Tests ===\n");
  console.log(`Server: ${SERVER_URL}\n`);

  // ── setup ──────────────────────────────────────────────────────────────

  const transport = new StdioClientTransport({
    command: "npx",
    args: [
      "@playwright/mcp",
      "--headless",
      "--caps=testing",
      "--viewport-size=1280x800",
    ],
  });

  client = new Client({ name: "jac-gpt-e2e", version: "1.0.0" });
  await client.connect(transport);

  // Navigate to app and wait for initial load
  await navigate(SERVER_URL);
  await waitFor({ text: "Jac GPT" }, 60000);

  // ── tests ──────────────────────────────────────────────────────────────

  await runTest("App heading renders", async () => {
    await verifyText("Jac GPT");
  });

  await runTest("Empty state heading visible", async () => {
    await verifyText("How can I help you today?");
  });

  await runTest("Chat input textarea present", async () => {
    const s = await snap();
    assert(
      s.includes("Ask about Jac") || s.includes("textbox") || s.includes("textarea"),
      "Chat textarea not found in snapshot"
    );
  });

  await runTest("Sidebar - New Chat button", async () => {
    await verifyText("New Chat");
  });

  await runTest("Sidebar - Guest mode indicator", async () => {
    await verifyText("Guest mode");
  });

  await runTest("Suggestion chip - What is by llm?", async () => {
    await verifyText("What is by llm?");
  });

  await runTest("Suggestion chip - What are walkers?", async () => {
    await verifyText("What are walkers?");
  });

  await runTest("Suggestion chip - What are nodes?", async () => {
    await verifyText("What are nodes?");
  });

  await runTest("Click suggestion chip sends message", async () => {
    const s = await snap();
    const ref = findRef(s, "What is by llm?");
    assert(ref, 'Could not find ref for "What is by llm?" button');
    await clickByRef("What is by llm?", ref);
    // User message should appear, and loading state should start
    await waitFor({ text: "What is by llm?" }, 10000);
  });

  await runTest("Loading state appears after sending", async () => {
    // "Thinking..." should appear while waiting for bot response
    await waitFor({ text: "Thinking" }, 15000);
  });

  await runTest("Bot responds to message", async () => {
    await waitFor({ textGone: "Thinking" }, 120000);
    const s = await snap();
    assert(
      !s.includes("Sorry, I encountered an error"),
      "Bot returned an error instead of a valid response"
    );
  });

  await runTest("Documentation panel toggle", async () => {
    let s = await snap();
    const showRef = findRef(s, "Show Docs");
    assert(showRef, 'Could not find ref for "Show Docs" button');
    await clickByRef("Show Docs", showRef);
    // Panel renders "Popular Topics" heading when open with default suggestions
    await waitFor({ text: "Popular Topics" }, 15000);

    // Close the panel — the button accessible name may not update to "Hide Docs"
    // in the snapshot, so use JS click as the reliable approach
    s = await snap();
    const hideRef = findRef(s, "Hide Docs");
    if (hideRef) {
      await clickByRef("Hide Docs", hideRef);
    } else {
      await call("browser_evaluate", {
        function: `() => {
          const buttons = [...document.querySelectorAll('button')];
          const btn = buttons.find(b => b.textContent.includes('Hide Docs'));
          if (btn) btn.click();
        }`
      });
    }
    await waitFor({ textGone: "Popular Topics" }, 5000);
  });

  await runTest("New Chat clears conversation", async () => {
    const s = await snap();
    const ref = findRef(s, "New Chat");
    assert(ref, 'Could not find ref for "New Chat" button');
    await clickByRef("New Chat", ref);
    await waitFor({ text: "How can I help you today?" }, 10000);
  });

  await runTest("Login page renders", async () => {
    await navigate(`${SERVER_URL}/login`);
    await waitFor({ text: "Welcome Back" }, 15000);
    await verifyText("Welcome Back");
    await verifyText("Sign In");
  });

  await runTest("Register page renders", async () => {
    await navigate(`${SERVER_URL}/register`);
    await waitFor({ text: "Create Account" }, 15000);
    await verifyText("Create Account");
  });

  await runTest("Admin route redirects to login", async () => {
    await navigate(`${SERVER_URL}/admin`);
    await waitFor({ text: "Welcome Back" }, 15000);
    await verifyText("Welcome Back");
  });

  await runTest("Type and send a chat message", async () => {
    await navigate(SERVER_URL);
    await waitFor({ text: "How can I help you today?" }, 15000);

    const s = await snap();
    const ref = findRef(s, "Ask about Jac") || findRef(s, "textbox");
    assert(ref, "Could not find ref for chat textarea");

    await typeByRef("chat input", ref, "Hello, what is Jac?", true);
    await waitFor({ text: "Hello, what is Jac?" }, 10000);
  });

  // ── teardown ───────────────────────────────────────────────────────────

  console.log(`\n=== Results: ${passed} passed, ${failed} failed ===\n`);

  if (failures.length > 0) {
    console.log("Failures:");
    for (const f of failures) {
      console.log(`  - ${f.name}: ${f.error}`);
    }
    console.log(`\nScreenshots saved to: ${SCREENSHOTS_DIR}\n`);
  }

  await client.close();
  process.exit(failed > 0 ? 1 : 0);
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
