bats_load_library 'helper'

setup() {
  bats_tmp_dir
  XML_FILE="$BATS_TMP_DIR/test.xml"
}

# --- --input flag ---

@test "--input: scalar read returns value, exit 0" {
  echo '<root><name>Alice</name></root>' > "$XML_FILE"
  bats_run_zsh "xml-get --input $XML_FILE '.root.name'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "Alice" ]]
}

@test "--input: nested key returns value, exit 0" {
  echo '<rss><channel><title>Mon Podcast</title></channel></rss>' > "$XML_FILE"
  bats_run_zsh "xml-get --input $XML_FILE '.rss.channel.title'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "Mon Podcast" ]]
}

# --- stdin ---

@test "stdin: scalar read returns value, exit 0" {
  local xml='<root><city>Paris</city></root>'
  bats_run_zsh "xml-get '.root.city'" <<< "$xml"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "Paris" ]]
}

# --- array output ---

@test "array: returns one element per line, exit 0" {
  cat > "$XML_FILE" <<'XML'
<root><items><item>a</item><item>b</item><item>c</item></items></root>
XML
  bats_run_zsh "xml-get --input $XML_FILE '.root.items.item'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "$(printf 'a\nb\nc')" ]]
}

# --- absent / null ---

@test "absent key: empty output, exit 0" {
  echo '<root><name>Alice</name></root>' > "$XML_FILE"
  bats_run_zsh "xml-get --input $XML_FILE '.root.missing'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "null value: empty output, exit 0" {
  echo '<root><key></key></root>' > "$XML_FILE"
  bats_run_zsh "xml-get --input $XML_FILE '.root.key'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
