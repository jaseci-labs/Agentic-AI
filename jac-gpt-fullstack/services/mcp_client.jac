"""MCP client singleton using Streamable HTTP transport.

Spawns a local MCP server via:
    jac mcp --transport streamable-http --port 3001
then connects to it at http://localhost:3001/mcp.
"""

import json;
import requests;
import subprocess;
import time;

obj McpClient {
    has _base_url: str = "http://localhost:3001";
    has _tools: list = [];
    has _initialized: bool = False;
    has _rpc_id: int = 0;
    has _session_id: str = "";
    has _server_process: any = None;

    def postinit() {
        try {
            self._start_server();
            self._initialize();
            self._list_tools();
            print(f"[MCP] Client ready — {len(self._tools)} tool(s) discovered.");
        } except Exception as e {
            print(f"[MCP] Startup warning: {e}. MCP tools will be unavailable.");
        }
    }

    # ── Private helpers ────────────────────────────────────────────────────────

    """Launch `jac mcp --transport streamable-http --port 3001` as a background
    subprocess and wait until the server is accepting connections."""
    def _start_server() {
        self._server_process = subprocess.Popen(
            ["jac", "mcp", "--transport", "streamable-http", "--port", "3001"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        );

        # Poll until the server is ready (up to 10 seconds)
        max_retries = 20;
        retry_delay = 0.5;
        for _ in range(max_retries) {
            # Check if process exited early (e.g. command not found)
            exit_code = self._server_process.poll();
            if exit_code is not None {
                stderr_out = self._server_process.stderr.read().decode("utf-8", errors="ignore");
                print(f"[MCP] Server process exited with code {exit_code}: {stderr_out.strip()}");
                return;
            }
            try {
                resp = requests.get(f"{self._base_url}/", timeout=1);
                print("[MCP] Server is up.");
                return;
            } except Exception {
                time.sleep(retry_delay);
            }
        }
        print("[MCP] Warning: server may not be ready yet, proceeding anyway.");
    }

    def _make_id() -> str {
        self._rpc_id += 1;
        return str(self._rpc_id);
    }

    def _build_headers(accept_sse: bool = True) -> dict {
        headers = {"Content-Type": "application/json"};
        if accept_sse {
            headers["Accept"] = "application/json, text/event-stream";
        } else {
            headers["Accept"] = "application/json";
        }
        if self._session_id {
            headers["Mcp-Session-Id"] = self._session_id;
        }
        return headers;
    }

    def _capture_session(resp: any) -> None {
        sid = resp.headers.get("Mcp-Session-Id");
        if sid {
            self._session_id = sid;
        }
    }

    """Extract the last JSON-RPC response from an SSE text stream."""
    def _parse_sse_response(text: str) -> dict {
        last_data = {};
        for line in text.strip().split("\n") {
            if line.startswith("data: ") {
                try {
                    last_data = json.loads(line[6:]);
                } except Exception {
                    print(f"[MCP] Warning: Failed to parse SSE line as JSON: {line[6:]}");
                }
            }
        }
        return last_data;
    }

    def _send_rpc(method: str, params: dict = None) -> dict {
        req = {"jsonrpc": "2.0", "id": self._make_id(), "method": method};
        if params {
            req["params"] = params;
        }
        resp = requests.post(
            f"{self._base_url}/mcp",
            data=json.dumps(req),
            headers=self._build_headers(),
            timeout=60
        );
        resp.raise_for_status();
        self._capture_session(resp);

        content_type = resp.headers.get("Content-Type", "");
        if "text/event-stream" in content_type {
            return self._parse_sse_response(resp.text);
        }
        return resp.json();
    }

    def _send_notification(method: str, params: dict = None) -> None {
        body = {"jsonrpc": "2.0", "method": method};
        if params {
            body["params"] = params;
        }
        resp = requests.post(
            f"{self._base_url}/mcp",
            data=json.dumps(body),
            headers=self._build_headers(accept_sse=False),
            timeout=10
        );
        self._capture_session(resp);
    }

    def _initialize() {
        self._send_rpc("initialize", {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "jac-mcp-server-bridge", "version": "1.0.0"}
        });
        self._send_notification("notifications/initialized");
        self._initialized = True;
    }

    def _list_tools() {
        resp = self._send_rpc("tools/list");
        self._tools = resp.get("result", {}).get("tools", []);
    }

    # ── Public API ─────────────────────────────────────────────────────────────

    """Return a human-readable list of all available MCP tools with their
    descriptions and parameter names so the LLM can decide which to call."""
    def get_tool_descriptions() -> str {
        if not self._tools {
            return "No MCP tools are currently available.";
        }
        lines = [];
        for tool in self._tools {
            name = tool.get("name", "unknown");
            desc = tool.get("description", "");
            props = list(tool.get("inputSchema", {}).get("properties", {}).keys());
            lines.append(f"- {name}: {desc} (params: {props})");
        }
        return "\n".join(lines);
    }

    """Call an MCP tool by name with the given arguments dict.
    Returns the tool's text output as a string, or an error description."""
    def call_tool(name: str, args: dict) -> str {
        if not self._initialized {
            try {
                self._initialize();
                self._list_tools();
            } except Exception as e {
                return f"MCP client unavailable: {e}. Try again or use search_docs instead.";
            }
        }

        try {
            resp = self._send_rpc("tools/call", {"name": name, "arguments": args});
            content = resp.get("result", {}).get("content", []);
            if content {
                parts = [];
                for item in content {
                    if item.get("type") == "text" {
                        parts.append(item.get("text", ""));
                    } else {
                        parts.append(str(item));
                    }
                }
                return "\n".join(parts);
            }
            error = resp.get("error");
            if error {
                return f"MCP tool error: {error}";
            }
            return "MCP tool returned no content.";
        } except Exception as e {
            return f"MCP call failed: {e}";
        }
    }

    """Terminate the background MCP server subprocess if it is running."""
    def stop_server() -> None {
        if self._server_process {
            self._server_process.terminate();
            self._server_process.wait();
            print("[MCP] Server process terminated.");
            self._server_process = None;
        }
    }

    def get_tools_length() -> int {
        return len(self._tools);
    }
}
