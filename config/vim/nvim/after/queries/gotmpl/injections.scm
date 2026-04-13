;; extends
;;
;; This file enables HTML syntax highlighting within Go Template files.
;; It tells Treesitter to parse text content (outside of {{ }} template tags)
;; as HTML, so both Go template syntax and HTML are properly highlighted.

((text) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined))
