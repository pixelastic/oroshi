-- Default syntax groups {{{
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

-- Treesitter groups {{{
hl('@comment.note.comment', 'TODO', { bold = true })
hl('@comment.note.vimdoc', 'YELLOW', { bold = true })
hl('@operator', 'PUNCTUATION')
hl('@property', 'KEY')
hl('@punctuation', 'PUNCTUATION')
hl('@variable', 'VARIABLE')
hl('@variable.member', 'KEY')
hl('@markup.link', 'LINK', { underline = true })
-- Headers
hl('@markup.heading.1', 'PURPLE_4', { bold = true })
hl('@markup.heading.2', 'BLUE_4', { bold = true })
hl('@markup.heading.3', 'GREEN_7', { bold = true })
hl('@markup.heading.4', 'YELLOW_6', { bold = true })
hl('@markup.heading.5', 'ORANGE_7', { bold = true })
hl('@markup.heading.6', 'RED_7', { bold = true })

-- }}}

-- Language specific {{{
frequire('oroshi/colorscheme/syntax/lua')
frequire('oroshi/colorscheme/syntax/help')
frequire('oroshi/colorscheme/syntax/markdown')
frequire('oroshi/colorscheme/syntax/yaml')
-- }}}
