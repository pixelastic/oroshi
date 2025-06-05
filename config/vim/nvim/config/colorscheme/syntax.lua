-- Syntax groups {{{
hl('Boolean', 'BOOLEAN', { bold = true })
hl('Comment', 'COMMENT')
hl('Conditional', 'STATEMENT') --	if, then, else, endif, switch, etc.
hl('Constant', 'CONSTANT', { bold = true }) 
hl('Delimiter', 'PUNCTUATION') 
hl('Error', 'ERROR', { bold = true }) 
hl('Function', 'FUNCTION') 
hl('Identifier', 'VARIABLE') 
hl('Include', 'IMPORT') 
hl('Keyword', 'KEYWORD') 
hl('Number', 'NUMBER', { bold = true }) 
hl('Operator', 'PUNCTUATION') --	"sizeof", "+", "*", etc.
hl('PreProc', 'HEADER') --		generic Preprocessor
hl('Repeat', 'STATEMENT') --		for, do, while, etc.
hl('SpecialChar', 'SPECIAL_CHAR') --	special character in a constant
hl('SpecialKey', 'SPECIAL_CHAR') -- Unprintable characters
hl('Special', 'SPECIAL_CHAR') 
hl('Statement', 'STATEMENT') 
hl('StorageClass', 'VARIABLE_TYPE') --	static, register, volatile, etc.
hl('String', 'STRING') 
hl('Structure', 'VARIABLE_TYPE') --	struct, union, enum, etc.
hl('Todo', 'ORANGE_3', { bg = 'RED_7', bold = true }) 
hl('Title', 'HEADER') --		Titles for output from ":set all", ":autocmd" etc.
hl('Type', 'VARIABLE_TYPE') 
hl('Underlined', 'none', { underline = true }) --	text that stands out, HTML links
-- }}}

-- Messages 

-- Diff / Git {{{
hl('Added', 'GIT_ADDED')
hl('Changed', 'GIT_MODIFIED')
hl('Removed', 'GIT_REMOVED')
hl('DiffDelete', 'GIT_REMOVED')
-- }}}

-- Treesitter groups {{{
-- Comments
hl('@comment.note.comment', 'TODO', { bold = true })
hl('@comment.note.vimdoc', 'YELLOW', { bold = true })
-- Punctuation
hl('@operator', 'PUNCTUATION')
hl('@punctuation', 'PUNCTUATION')
-- Variables
hl('@variable', 'VARIABLE')
hl('@variable.member', 'KEY')
hl('@property', 'KEY')
-- Keywords
hl('@keyword.import', 'IMPORT')
hl('@keyword.directive', 'ORANGE')
-- Headers
hl('@markup.heading.1', 'PURPLE_4', { bold = true })
hl('@markup.heading.2', 'BLUE_4', { bold = true })
hl('@markup.heading.3', 'GREEN_7', { bold = true })
hl('@markup.heading.4', 'YELLOW_6', { bold = true })
hl('@markup.heading.5', 'ORANGE_7', { bold = true })
hl('@markup.heading.6', 'RED_7', { bold = true })
-- Links
hl('@markup.link', 'LINK', { underline = true })
-- }}}

-- Language specific {{{
-- Bash {{{
hl('@keyword.directive.bash', 'YELLOW')
hl('@function.builtin.bash', 'GREEN')
hl('@constant.bash', 'VARIABLE')
-- }}}
-- CSS {{{
hl('@tag.css', 'GREEN', { bold = true })
-- }}}
-- lua {{{
hl('@constructor.lua', 'PUNCTUATION')
hl('@keyword.function.lua', 'KEYWORD')
hl('@keyword.lua', 'VARIABLE_TYPE')
hl('@keyword.repeat.lua', 'KEYWORD')
hl('@keyword.return.lua', 'KEYWORD')
hl('@label.lua', 'YELLOW_LIGHT', { bold = true})
-- }}}
-- help {{{
hl('@markup.heading.1.vimdoc', 'BLUE_4')
hl('@label.vimdoc', 'GREEN_7')
-- }}}
-- markdown {{{
-- bold
hl('@markup.strong.markdown_inline', 'TEXT', { bold = true }) -- **bold**
-- links
hl('@markup.link.url.markdown_inline', 'LINK', { underline = true }) -- [](url)
hl('@markup.link.label.markdown_inline', 'STRING') -- [label]() 
hl('@markup.link.markdown_inline', 'PUNCTUATION') -- []()
hl('RenderMarkdownLink', 'LINK') -- 	Image & hyperlink icons
-- inline code
hl('@markup.raw.markdown_inline', 'STRING') -- `code`
hl('RenderMarkdownCode', 'STRING', { bg = 'GRAY_8' }) -- 	Code block background
-- block code
hl('@markup.raw.block.markdown', 'STRING') -- ```multiline code```
hl('@label.markdown', 'BLUE_5')
hl('RenderMarkdownCodeInline', 'STRING') -- 	Inline code background
hl('RenderMarkdownCodeBorder', 'none', { bg = 'GRAY_8'}) -- 	Code border background
hl('RenderMarkdownCodeFallback', 'XXX') -- 	Fallback for code language
-- lists
hl('@markup.list.markdown', 'PUNCTUATION') -- bullet points
hl('RenderMarkdownBullet', 'PUNCTUATION') -- 	List item bullet points
-- <hr> separator
hl('@punctuation.special.markdown', 'GRAY_8')
hl('RenderMarkdownDash', 'GRAY_8') -- 	Thematic break line
-- Header gutter sign
hl('RenderMarkdownSign', 'none') -- 	Sign column background
-- header 1
hl('RenderMarkdownH1', 'PURPLE_4') -- Gutter icon
hl('RenderMarkdownH1Bg', 'PURPLE_5') -- Normal mode (full width)
hl('@markup.heading.1.markdown', 'PURPLE_4', { bold = true }) -- Insert mode
-- header 2
hl('RenderMarkdownH2', 'BLUE_4')
hl('RenderMarkdownH2Bg', 'BLUE_2', { bg = 'BLUE_9' })
hl('@markup.heading.2.markdown', 'BLUE_4', { bold = true })
-- header 3
hl('RenderMarkdownH3', 'GREEN_7')
hl('RenderMarkdownH3Bg', 'GREEN_1', { bg = 'GREEN_9' })
hl('@markup.heading.3.markdown', 'GREEN_7', { bold = true })
-- header 4
hl('RenderMarkdownH4', 'YELLOW_6')
hl('RenderMarkdownH4Bg', 'YELLOW_1', { bg = 'YELLOW_9' })
hl('@markup.heading.4.markdown', 'YELLOW_6', { bold = true })
-- header 5
hl('RenderMarkdownH5', 'ORANGE_7')
hl('RenderMarkdownH5Bg', 'ORANGE_2', { bg = 'ORANGE_9' })
hl('@markup.heading.5.markdown', 'ORANGE_7', { bold = true })
-- header 6
hl('RenderMarkdownH6', 'RED_7')
hl('RenderMarkdownH6Bg', 'RED_2', { bg = 'RED_9' })
hl('@markup.heading.6.markdown', 'RED_7', { bold = true })
-- }}}
-- vim {{{
hl('@label.vim', 'STRING')
-- }}}
-- yaml {{{
hl('@property.yaml', 'VARIABLE')
-- }}}
-- Zsh {{{
hl('zshFunction', 'YELLOW')
hl('zshVariableDef', 'VARIABLE_DEFINITION')
hl('zshDeref', 'VARIABLE')
hl('zshBrackets', 'PUNCTUATION')
hl('zshParentheses', 'PUNCTUATION')
hl('zshOperator', 'PUNCTUATION')
hl('zshRedir', 'ORANGE')
-- }}}
