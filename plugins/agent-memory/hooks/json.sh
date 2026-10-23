# Sourced by the hooks. Plugins installed from a marketplace cannot rely on jq
# being installed, so the hooks build their JSON output with plain bash.

# Prints $1 as a JSON string. The hook texts hold no control characters other
# than newlines.
json_string() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  printf '"%s"' "$s"
}
