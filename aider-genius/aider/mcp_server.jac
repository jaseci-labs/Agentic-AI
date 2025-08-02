import sys;
import os;
import from web_search { WebSearcher }
import from mcp.server.fastmcp.tools { Tool }
import from mcp.server.fastmcp { FastMCP }
import typing;

glob web_search: WebSearcher = WebSearcher();


with entry {
    mcp = FastMCP(name="RAG-MCP", port=8899);
}

def resolve_hints(fn: typing.Callable) -> typing.Callable {
    fn.__annotations__ = typing.get_type_hints(fn, include_extras=True);
    return fn;
}

@mcp.tool(name="search_web")
@resolve_hints
async def tool_search_web(query: str) -> str{
    web_search_results = web_search.search(query);
    if not web_search_results {
        return "Mention No results found for the web search";
    }
    return web_search_results;
}


with entry {
    mcp.run("streamable-http");
}