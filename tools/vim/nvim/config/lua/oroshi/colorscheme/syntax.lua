local hl = F.hl

-- Syntax groups {{{
hl("Boolean", "boolean", { bold = true })
hl("Comment", "comment")
hl("SpecialComment", "comment", { bold = true })
hl("Conditional", "statement") --	if, then, else, endif, switch, etc.
hl("Constant", "constant", { bold = true })
hl("Delimiter", "punctuation")
hl("Error", "error", { bold = true })
hl("Exception", "yellow", { bold = true }) --	try, catch, throw
hl("Function", "function")
hl("Float", "blue")
hl("Identifier", "variable")
hl("Typedef", "variable-type")
hl("Include", "import")
hl("Keyword", "keyword")
hl("Macro", "red-3")
hl("Number", "number", { bold = true })
hl("Operator", "punctuation") --	"sizeof", "+", "*", etc.
hl("PreProc", "header") --		generic Preprocessor
hl("Repeat", "statement") --		for, do, while, etc.
hl("SpecialChar", "special-char") --	special character in a constant
hl("SpecialKey", "special-char") -- Unprintable characters
hl("Special", "special-char")
hl("Statement", "statement")
hl("StorageClass", "variable-type") --	static, register, volatile, etc.
hl("String", "string")
hl("Structure", "variable-type") --	struct, union, enum, etc.
hl("Tag", "variable-type")
hl("Todo", "orange-2", { bg = "red-6", bold = true })
hl("Title", "header") --		Titles for output from ":set all", ":autocmd" etc.
hl("Type", "variable-type")
hl("Underlined", "none", { underline = true })
-- }}}

-- Diff / Git {{{
hl("Added", "git-added")
hl("Changed", "git-modified")
hl("DiffDelete", "git-removed")
hl("Removed", "git-removed")
hl("diffAdded", "git-added")
hl("diffFile", "header")
hl("diffLine", "terminal")
hl("diffRemoved", "git-removed")
hl("diffSubname", "comment")
hl("gitcommitBranch", "git-branch")
hl("gitcommitDiff", "comment")
hl("gitcommitHeader", "comment")
hl("gitcommitSelectedFile", "file")
hl("gitcommitSummary", "text")
hl("gitcommitOverflow", "text")
-- }}}

-- Treesitter groups {{{
-- Comments
hl("@comment.note.comment", "todo", { bold = true })
hl("@comment.note.vimdoc", "yellow", { bold = true })
-- Punctuation
hl("@operator", "punctuation")
hl("@punctuation", "punctuation")
-- Variables
hl("@variable", "variable")
hl("@variable.member", "key")
hl("@property", "key")
-- Keywords
hl("@keyword.import", "yellow-4", { bold = true })
hl("@keyword.directive", "orange")
-- Headers
hl("@markup.heading.1", "purple-3", { bold = true })
hl("@markup.heading.2", "blue-3", { bold = true })
hl("@markup.heading.3", "green-7", { bold = true })
hl("@markup.heading.4", "yellow-5", { bold = true })
hl("@markup.heading.5", "orange-6", { bold = true })
hl("@markup.heading.6", "red-6", { bold = true })
-- Links
hl("@markup.link", "link", { underline = true })
-- }}}

-- Language specific {{{
-- Bash {{{
hl("@keyword.directive.bash", "yellow")
hl("@function.builtin.bash", "green")
hl("@constant.bash", "variable")
-- }}}
-- C {{{
hl("@keyword.directive.define.c", "yellow")
hl("@keyword.type.c", "variable-type")
-- }}}
-- CSS {{{
hl("@tag.css", "green", { bold = true })
hl("@attribute.css", "red-3") -- pseudo-classes
hl("@property.css", "red-3")
hl("cssUnitDecorators", "white")
hl("cssAttrRegion", "keyword")
hl("@keyword.directive.css", "yellow")
hl("@keyword.modifier.css", "red-4", { bold = true })
-- }}}
-- Dockerfile {{{
hl("dockerfileKeyword", "function")
hl("dockerfileFrom", "symbol")
hl("dockerfileShell", "green")
hl("dockerfileValue", "variable")
-- }}}
-- Go {{{
hl("@comment.gotmpl", "comment", { bg = "sky-0" })
hl("@function.gotmpl", "function", { bg = "sky-0" })
hl("@variable.member.gotmpl", "variable", { bg = "sky-0" })
hl("@variable.gotmpl", "variable", { bg = "sky-0" })
hl("@boolean.gotmpl", "boolean", { bg = "sky-0", bold = true })
hl("@keyword.conditional.gotmpl", "orange", { bg = "sky-0" })
hl("@keyword.directive.gotmpl", "yellow", { bg = "sky-0" })
hl("@punctuation.bracket.gotmpl", "punctuation", { bg = "sky-0" })
hl("@punctuation.delimiter.gotmpl", "punctuation", { bg = "sky-0" })
hl("@operator.gotmpl", "punctuation", { bg = "sky-0" })
hl("@string.gotmpl", "string", { bg = "sky-0" })
-- }}}
-- help {{{
hl("@markup.heading.1.vimdoc", "blue-3")
hl("@label.vimdoc", "green-7")
-- }}}
-- html {{{
hl("htmlHead", "none", { bg = "blue-0" })
hl("@tag.delimiter.html", "punctuation")
hl("@tag.html", "keyword")
hl("htmlTag", "keyword") -- Explicitly needed because we override it for Vue
hl("@constant.html", "yellow", { bold = true })
hl("@tag.attribute.html", "variable-type")
hl("@markup.heading.html", "purple-3", { bold = true })
-- }}}
-- JavaScript {{{
hl("@keyword.exception.javascript", "yellow", { bold = true })
-- }}}
-- JSX {{{
hl("@tag.delimiter.javascript", "punctuation")
hl("@tag.builtin.javascript", "keyword")
hl("@tag.javascript", "function")
-- }}}
-- json {{{
hl("jsonQuote", "string")
-- }}}
-- Gitconfig {{{
hl("@markup.heading.git_config", "green")
hl("@string.special.git_config", "string")
hl("@string.special.path.git_config", "directory")
-- }}}
-- Gitignore {{{
hl("@string.special.path.gitignore", "text")
-- }}}
-- lua {{{
hl("@constructor.lua", "punctuation")
hl("@keyword.function.lua", "keyword")
hl("@keyword.directive.lua", "yellow")
hl("@keyword.lua", "variable-type")
hl("@keyword.repeat.lua", "keyword")
hl("@keyword.return.lua", "keyword")
hl("@label.lua", "yellow-3", { bold = true })
hl("@lsp.type.comment.lua", "none")
hl("@lsp.type.variable.lua", "none")
hl("@lsp.type.property.lua", "none")
-- }}}
-- markdown {{{
-- bold
hl("@markup.strong.markdown_inline", "text", { bold = true }) -- **bold**
-- links
hl("@markup.link.url.markdown_inline", "link", { underline = true }) -- [](url)
hl("@markup.link.label.markdown_inline", "string") -- [label]()
hl("@markup.link.markdown_inline", "punctuation") -- []()
hl("RenderMarkdownLink", "link") -- 	Image & hyperlink icons
hl("markdownUrl", "link") -- 	Image & hyperlink icons
-- inline code
hl("@markup.raw.markdown_inline", "string") -- `code`
hl("RenderMarkdownCode", "string", { bg = "gray-8" }) -- 	Code block background
-- block code
hl("@markup.raw.block.markdown", "string") -- ```multiline code```
hl("@label.markdown", "blue-4")
hl("RenderMarkdownCodeInline", "string") -- 	Inline code background
hl("RenderMarkdownCodeBorder", "none", { bg = "gray-8" }) -- 	Code border background
hl("RenderMarkdownCodeFallback", "XXX") -- 	Fallback for code language
-- quotes
hl("RenderMarkdownQuote1", "neutral") -- Indentation marker in normal mode
hl("@markup.quote.markdown", "gray-4", { italic = true, bold = true }) -- Quote text
-- lists
hl("@markup.list.markdown", "punctuation") -- bullet points
hl("RenderMarkdownBullet", "punctuation") -- 	List item bullet points
-- checkboxes
hl("RenderMarkdownUnchecked", "comment") -- 	Unchecked checkbox
hl("RenderMarkdownChecked", "green-5") -- 	Checked checkbox
-- <hr> separator
hl("@punctuation.special.markdown", "punctuation")
hl("RenderMarkdownDash", "punctuation") -- 	Thematic break line
-- tables
hl("RenderMarkdownTableHead", "neutral") -- 	Pipe table heading rows
hl("RenderMarkdownTableRow", "neutral") -- 	Pipe table body rows
hl("RenderMarkdownTableFill", "terminal") -- 	Pipe table inline padding
-- Header gutter sign
hl("RenderMarkdownSign", "none") -- 	Sign column background
-- header 1
hl("RenderMarkdownH1", "purple-3") -- Gutter icon
hl("RenderMarkdownH1Bg", "purple-3", { bg = "purple-0" }) -- Normal mode (full width)
hl("@markup.heading.1.markdown", "purple-3", { bold = true }) -- Insert mode
-- header 2
hl("RenderMarkdownH2", "blue-3")
hl("RenderMarkdownH2Bg", "blue-3", { bg = "blue-0" })
hl("@markup.heading.2.markdown", "blue-3", { bold = true })
-- header 3
hl("RenderMarkdownH3", "green-7")
hl("RenderMarkdownH3Bg", "green-7", { bg = "green-0" })
hl("@markup.heading.3.markdown", "green-7", { bold = true })
-- header 4
hl("RenderMarkdownH4", "yellow-5")
hl("RenderMarkdownH4Bg", "yellow-5", { bg = "yellow-0" })
hl("@markup.heading.4.markdown", "yellow-5", { bold = true })
-- header 5
hl("RenderMarkdownH5", "orange-6")
hl("RenderMarkdownH5Bg", "orange-6", { bg = "orange-0" })
hl("@markup.heading.5.markdown", "orange-6", { bold = true })
-- header 6
hl("RenderMarkdownH6", "red-6")
hl("RenderMarkdownH6Bg", "red-6", { bg = "red-0" })
hl("@markup.heading.6.markdown", "red-6", { bold = true })
-- highlight
hl("RenderMarkdownInlineHighlight", "black", { bg = "yellow" })
-- footnotes
hl("markdownIdDeclaration", "variable-type")
-- }}}
-- python {{{
hl("@keyword.directive.python", "yellow")
hl("@keyword.import.python", "yellow")
hl("@function.method.call.python", "green")
hl("@keyword.exception.python", "orange", { bold = true })
-- }}}
-- rust {{{
hl("@keyword.type.rust", "variable-type")
hl("@keyword.modifier.rust", "variable-type")
-- }}}
-- sh {{{
hl("shOption", "symbol")
hl("shVarAssign", "punctuation")
-- }}}
-- Toml {{{
hl("@property.toml", "none")
--- }}}
--- TypeScript {{{
hl("@tag.delimiter.tsx", "punctuation")
hl("@tag.builtin.tsx", "keyword")
hl("typescriptDocTags", "none")
hl("typescriptDocNotation", "none")
hl("@markup.link.label.tsx", "none")
--- }}}
-- vim {{{
hl("@label.vim", "string")
hl("@keyword.vim", "teal")
hl("@function.macro.vim", "teal")
-- }}}
-- vue {{{
hl("@tag.vue", "keyword")
hl("@tag.delimiter.vue", "punctuation")
hl("@punctuation.special.vue", "string")
hl("@markup.raw.vue", "red-7", { bg = "gray-8" })
hl("@function.method.vue", "orange")
hl("@variable.member.vue", "orange")
hl("@variable.vue", "orange")
hl("htmlTag", "orange", { filetype = "vue" })
-- }}}
-- yaml {{{
hl("@property.yaml", "variable")
-- }}}
-- Zsh {{{
hl("zshFunction", "yellow")
hl("zshVariable", "variable")
hl("zshVariableDef", "variable-definition")
hl("zshDeref", "variable")
hl("zshBrackets", "punctuation")
hl("zshParentheses", "punctuation")
hl("zshOperator", "punctuation")
hl("zshRedir", "orange")
hl("zshException", "yellow")
-- }}}
-- }}}
