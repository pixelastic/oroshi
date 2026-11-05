bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "uniform sentences: variation is 0" {
  bats_run_zsh "prose-burstiness 'One two three. Four five six. Seven eight nine.'"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq '.sentenceCount')" -eq 3 ]]
  [[ "$(printf '%s' "$output" | jq '.variation')" == "0" ]]
}

@test "varied sentences: variation is high" {
  bats_run_zsh "prose-burstiness 'Fast. I had already tried it on another project, and now I wanted to compare it with something else entirely. Still no luck.'"
  [[ "$status" -eq 0 ]]
  printf '%s' "$output" | jq --exit-status '.variation > 0.5' >/dev/null
}

@test "reports mean and standard deviation in words per sentence" {
  bats_run_zsh "prose-burstiness 'One two. One two three four.'"
  [[ "$(printf '%s' "$output" | jq '.meanLength')" == "3" ]]
  [[ "$(printf '%s' "$output" | jq '.standardDeviation')" == "1" ]]
}

@test "single sentence: variation is null" {
  bats_run_zsh "prose-burstiness 'Only one sentence here.'"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq '.variation')" == "null" ]]
}

@test "no argument: zero sentences and null variation" {
  bats_run_zsh "prose-burstiness"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq '.sentenceCount')" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq '.variation')" == "null" ]]
}

@test "--file ignores front matter, headings, lists and code blocks" {
  local file="$BATS_TMP_DIR/post.md"
  cat > "$file" <<'EOF'
---
title: A very long front matter title that should not count at all
---

# A heading that should not count either

One two three. Four five six.

- A list item that should not count

```js
const code = "should not count. at all.";
```

Seven eight nine.
EOF
  bats_run_zsh "prose-burstiness --file $file"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq '.sentenceCount')" -eq 3 ]]
  [[ "$(printf '%s' "$output" | jq '.variation')" == "0" ]]
}

@test "uniform text with enough sentences: not ok, exits 1, explains why" {
  bats_run_zsh "prose-burstiness 'One two three four. Five six seven eight. Nine ten eleven twelve. Red blue green black. Cat dog bird fish. Sun moon star sky.'"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq '.ok')" == "false" ]]
  printf '%s' "$output" | jq --exit-status '.message | test("too uniform")' >/dev/null
}

@test "varied text with enough sentences: ok, exits 0, no message" {
  bats_run_zsh "prose-burstiness 'Fast. I had already tried it on another project, and now I wanted to compare it with something else entirely. Still no luck. It broke. I fixed the build by removing the cache folder and running the whole thing again from scratch. Done.'"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq '.ok')" == "true" ]]
  [[ "$(printf '%s' "$output" | jq '.message')" == "null" ]]
}

@test "uniform text under the minimum sentence count: ok" {
  bats_run_zsh "prose-burstiness 'One two three. Four five six. Seven eight nine.'"
  [[ "$status" -eq 0 ]]
  [[ "$(printf '%s' "$output" | jq '.ok')" == "true" ]]
}
