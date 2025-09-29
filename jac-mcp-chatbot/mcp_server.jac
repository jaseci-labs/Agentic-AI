import os;
import from tools {RagEngine, WebSearch}
import from mcp.server.fastmcp.tools {Tool}
import from mcp.server.fastmcp {FastMCP}
import typing;

glob rag_engine: RagEngine = RagEngine();
glob web_search: WebSearch = WebSearch();


with entry {
    mcp = FastMCP(name="RAG-MCP", port=8899);
}

def resolve_hints(fn: typing.Callable) -> typing.Callable {
    fn.__annotations__ = typing.get_type_hints(fn, include_extras=True);
    return fn;
}

@mcp.tool(name="search_docs")
@resolve_hints
async def tool_search_docs(query: str) -> str {
    print(f"[MCP] search_docs tool called with query: '{query}'");
    result = rag_engine.search(query);
    print(f"[MCP] search_docs tool returning {len(result)} characters");
    return result;
}

@mcp.tool(name="search_web")
@resolve_hints
async def tool_search_web(query: str) -> str{
    print(f"[MCP] search_web tool called with query: '{query}'");
    web_search_results = web_search.search(query);
    if not web_search_results {
        return "Mention No results found for the web search";
    }
    print(f"[MCP] search_web tool returning {len(web_search_results)} characters");
    return web_search_results;
}


with entry {
    mcp.run("streamable-http");
}