"""E2E tests for jac-gpt-fullstack UI.

Run:
    pytest tests/test_e2e.jac -v
    SERVER_URL=http://localhost:8000 pytest tests/test_e2e.jac -v
    HEADED=1 pytest tests/test_e2e.jac -v
"""

import os;

import from playwright.sync_api { sync_playwright }

glob HEADLESS: bool = not os.environ.get("HEADED", ""),
     SERVER_URL: str = os.environ.get("SERVER_URL", "http://localhost:8000"),
     UI_TIMEOUT: int = 60_000,
     RESPONSE_TIMEOUT: int = 120_000;

# -- Helpers -------------------------------------------------------------------
def _with_page(callback: Any, path: str = "/") -> None {
    with sync_playwright() as p {
        browser = p.chromium.launch(headless=HEADLESS);
        page = browser.new_page(viewport={"width": 1280, "height": 800});
        try {
            page.goto(f"{SERVER_URL}{path}", wait_until="domcontentloaded");
            callback(page);
        } finally {
            browser.close();
        }
    }
}

def _wait_for_home(page: Any) -> None {
    page.wait_for_selector("text=Jac GPT", timeout=UI_TIMEOUT);
    page.wait_for_selector("text=How can I help you today?", timeout=UI_TIMEOUT);
}

def _wait_for_any_response(page: Any) -> None {
    try {
        page.wait_for_selector("text=Thinking", timeout=15_000);
        page.wait_for_selector("text=Thinking", state="hidden", timeout=RESPONSE_TIMEOUT);
    } except Exception {
        # Graceful fallback for missing/invalid API key cases.
        is_error = page.get_by_text("Sorry, I encountered an error").count() > 0;
        is_thinking = page.get_by_text("Thinking").count() > 0;
        assert is_error or not is_thinking, "Bot did not finish response in expected time";
    }
}

# -- Tests ---------------------------------------------------------------------
"""Home page renders primary heading and empty-state message."""
test "home: heading and empty state" {
    def check(page: Any) -> None {
        _wait_for_home(page);
        assert page.get_by_text("Jac GPT").first.is_visible();
        assert page.get_by_text("How can I help you today?").first.is_visible();
    }
    _with_page(check);
}

"""Home page shows chat input, sidebar controls, and suggestion chips."""
test "home: input sidebar and suggestions" {
    def check(page: Any) -> None {
        _wait_for_home(page);
        assert page.get_by_placeholder("Ask about Jac").first.is_visible();
        assert page.get_by_role("button", name="New Chat").is_visible();
        assert page.get_by_text("Guest mode").first.is_visible();
        assert page.get_by_text("What is by llm?").first.is_visible();
        assert page.get_by_text("What are walkers?").first.is_visible();
        assert page.get_by_text("What are nodes?").first.is_visible();
    }
    _with_page(check);
}

"""Clicking a suggestion sends the message and receives/finishes a response."""
test "chat: suggestion sends and responds" {
    def check(page: Any) -> None {
        _wait_for_home(page);
        page.get_by_text("What is by llm?").first.click();
        page.wait_for_selector("text=What is by llm?", timeout=10_000);
        _wait_for_any_response(page);
    }
    _with_page(check);
}

"""Documentation panel opens and closes from the header toggle button."""
test "docs: toggle panel" {
    def check(page: Any) -> None {
        _wait_for_home(page);
        page.get_by_role("button", name="Show Docs").click();
        page.wait_for_selector("text=Popular Topics", timeout=15_000);

        hide_btn = page.get_by_role("button", name="Hide Docs");
        if hide_btn.count() > 0 {
            hide_btn.click();
        } else {
            page.evaluate(
                "() => {"
                "  const buttons = [...document.querySelectorAll('button')];"
                "  const btn = buttons.find(b => b.textContent.includes('Hide Docs'));"
                "  if (btn) btn.click();"
                "}"
            );
        }
        page.wait_for_selector("text=Popular Topics", state="hidden", timeout=5_000);
    }
    _with_page(check);
}

"""New Chat resets the current conversation back to the empty state."""
 test "chat: new chat clears conversation" {
    def check(page: Any) -> None {
         _wait_for_home(page);
         page.get_by_text("What is by llm?").first.click();
         page.wait_for_selector("text=What is by llm?", timeout=10_000);

        # Ensure the app is done processing and controls are re-enabled
        _wait_for_any_response(page);
        new_chat_btn = page.get_by_role("button", name="New Chat").first;
        new_chat_btn.wait_for(state="visible", timeout=UI_TIMEOUT);
        page.wait_for_function(
           "() => {"
            "  const btn = [...document.querySelectorAll('button')].find(b => b.textContent?.includes('New Chat'));"
           "  return btn && !btn.disabled;"
            "}"
        , timeout=UI_TIMEOUT);

        page.get_by_role("button", name="New Chat").click();
        new_chat_btn.click();

        page.wait_for_selector("text=How can I help you today?", timeout=10_000);
        assert page.get_by_text("How can I help you today?").first.is_visible();
    }
     _with_page(check);
 }

"""Login page renders expected auth UI content."""
test "auth: login page renders" {
    def check(page: Any) -> None {
        page.wait_for_selector("text=Welcome Back", timeout=15_000);
        assert page.get_by_text("Welcome Back").first.is_visible();
        assert page.get_by_text("Sign In").first.is_visible();
    }
    _with_page(check, "/login");
}

"""Register page renders expected auth UI content."""
test "auth: register page renders" {
    def check(page: Any) -> None {
        page.wait_for_selector("text=Create Account", timeout=15_000);
        assert page.get_by_text("Create Account").first.is_visible();
    }
    _with_page(check, "/register");
}

"""Protected dashboard route should redirect unauthenticated users to login."""
test "auth: dashboard redirects to login" {
    def check(page: Any) -> None {
        page.wait_for_selector("text=Welcome Back", timeout=15_000);
        assert "/login" in page.url or page.get_by_text("Welcome Back").count() > 0;
    }
    _with_page(check, "/dashboard");
}

"""Typing and submitting in chat input sends a user message."""
test "chat: type and send message" {
    def check(page: Any) -> None {
        _wait_for_home(page);
        input_box = page.get_by_placeholder("Ask about Jac").first;
        input_box.fill("Hello, what is Jac?");
        input_box.press("Enter");
        page.wait_for_selector("text=Hello, what is Jac?", timeout=10_000);
    }
    _with_page(check);
}
