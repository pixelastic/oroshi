;; extends
;;
;; This file enables ```zsh ``` markdown syntax to be highlighted as bash.

((fenced_code_block
  (info_string
    (language) @_lang)
  (code_fence_content) @injection.content)
 (#eq? @_lang "zsh")
 (#set! injection.language "bash"))
