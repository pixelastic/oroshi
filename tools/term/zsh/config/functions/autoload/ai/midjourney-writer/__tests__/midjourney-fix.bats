bats_load_library 'helper'

@test "adds default ratio and version to a prompt without parameters" {
	bats_run_zsh "midjourney-fix" <<<'a cat on a mat'
	[[ "$status" -eq 0 ]]
	[[ "$output" == "a cat on a mat --ar 16:9 --v 8.2" ]]
}

@test "reads the prompt from the first argument" {
	bats_run_zsh "midjourney-fix 'a cat on a mat'"
	[[ "$status" -eq 0 ]]
	[[ "$output" == "a cat on a mat --ar 16:9 --v 8.2" ]]
}

@test "fails without a prompt" {
	bats_run_zsh "midjourney-fix" <<<''
	[[ "$status" -ne 0 ]]
}

@test "keeps an existing ratio" {
	bats_run_zsh "midjourney-fix" <<<'a cat --ar 9:16'
	[[ "$output" == "a cat --ar 9:16 --v 8.2" ]]

	bats_run_zsh "midjourney-fix" <<<'a cat --aspect 9:16'
	[[ "$output" == "a cat --aspect 9:16 --v 8.2" ]]
}

@test "forces version 8.2" {
	bats_run_zsh "midjourney-fix" <<<'a cat --v 7 --ar 1:1'
	[[ "$output" == "a cat --ar 1:1 --v 8.2" ]]

	bats_run_zsh "midjourney-fix" <<<'a cat --version 8.1'
	[[ "$output" == "a cat --ar 16:9 --v 8.2" ]]
}

@test "removes forbidden parameters with their value" {
	bats_run_zsh "midjourney-fix" <<<'a cat --q 2 --niji 7 --oref https://example.com/cat.png --p abc123 --draft'
	[[ "$output" == "a cat --ar 16:9 --v 8.2" ]]

	bats_run_zsh "midjourney-fix" <<<'a cat --quality 1 --ow 100 --cref https://example.com/a.png --cw 50 --turbo --profile abc'
	[[ "$output" == "a cat --ar 16:9 --v 8.2" ]]

	bats_run_zsh "midjourney-fix" <<<'a cat --sref 123 --sw 200 --sv 4 --edit --iw 2 --video --motion high --loop --end https://example.com/b.png --bs 2'
	[[ "$output" == "a cat --ar 16:9 --v 8.2" ]]
}

@test "keeps allowed parameters in place" {
	bats_run_zsh "midjourney-fix" <<<'a cat --no dog, bird --q 2 --raw --s 250'
	[[ "$output" == "a cat --no dog, bird --raw --s 250 --ar 16:9 --v 8.2" ]]
}

@test "removes multi-prompt weights" {
	bats_run_zsh "midjourney-fix" <<<'cat::2 dog::-0.5 hot:: dog'
	[[ "$output" == "cat dog hot dog --ar 16:9 --v 8.2" ]]
}

@test "joins a multi-line prompt into one line" {
	bats_run_zsh "midjourney-fix" <<<$'a cat\non a mat\n--raw'
	[[ "$output" == "a cat on a mat --raw --ar 16:9 --v 8.2" ]]
}

@test "returns an already-fixed prompt unchanged" {
	local prompt='a "Hello" sign --no dog, bird --raw --s 250 --hd --ar 3:2 --v 8.2'
	bats_run_zsh "midjourney-fix" <<<"$prompt"
	[[ "$output" == "$prompt" ]]
}
