import sys


def main() -> None:
    # The published CLI prints banners to stdout before starting stdio MCP.
    # Import and run the FastMCP app directly so stdout remains JSON-RPC only.
    from zilliz_mcp_server.app import zilliz_mcp
    from zilliz_mcp_server.tools.milvus import milvus_tools  # noqa: F401
    from zilliz_mcp_server.tools.zilliz import zilliz_tools  # noqa: F401

    zilliz_mcp.run(transport="stdio")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"zilliz-mcp-server failed: {exc}", file=sys.stderr)
        raise
