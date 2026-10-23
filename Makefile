.PHONY: local validate format lint test

SERVER := plugins/agent-memory/mcp-servers/agent-memory

# Run all validation, formatting, linting, and testing tasks.
local: validate format lint test

# Validate the plugin and the marketplace manifest.
validate:
	claude plugin validate plugins/agent-memory
	claude plugin validate .

# Format the agent-memory MCP server.
format:
	uv run --directory $(SERVER) ruff format src tests

# Lint the agent-memory MCP server.
lint:
	uv run --directory $(SERVER) ruff check src tests

# Test the agent-memory MCP server.
test:
	uv run --directory $(SERVER) python -m pytest
