-- Name:         Oroshi
-- Maintainer:   Tim Carry <tim@pixelastic.com>
-- "C'est parce qu'il y a 6 matières, c'est ca ?"
-- "J'ai un coude chaud."

vim.cmd('highlight clear')
if vim.g.syntax_on then
    vim.cmd('syntax reset')
end

vim.g.colors_name = "irisho"

-- Palette {{{
local function getPalette()
  local palette = {}

  local COLORS_INDEX = os.getenv('COLORS_INDEX')
  local items = vim.split(COLORS_INDEX, " ", { trimempty = true })
  for _, item in ipairs(items) do
    local key = string.gsub(item, 'ALIAS_', '')
    local value = os.getenv('COLOR_' .. item .. '_HEXA')
    palette[key] = value
  end
  return palette
end
vim.g.palette = getPalette()
-- }}}

-- Standard Groups {{{
local function hl(groupName, colorName, options)
  local defaults = { 
    fg = vim.g.palette[colorName],
    bg = "none",
    bold = false,
    italic = false,
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})

  vim.api.nvim_set_hl(0, groupName, config)
end
-- TODO: Find what works and what does not in a macro
hl('Comment', 'COMMENT')
hl('Boolean', 'BOOLEAN', { bold = true })
hl('Constant', 'CONSTANT', { bold = true }) 
hl('Delimiter', 'PUNCTUATION') 
hl('Error', 'ERROR', { bold = true }) 
hl('Function', 'FUNCTION') 
hl('Identifier', 'VARIABLE') 
hl('Keyword', 'KEYWORD') 
hl('Noise', 'NOISE') 
hl('Normal', 'TEXT') 
hl('Number', 'NUMBER', { bold = true }) 
hl('Special', 'SPECIAL_CHAR') 
hl('Statement', 'STATEMENT') 
hl('String', 'STRING') 
hl('TODO', 'TODO', { bold = true }) 
hl('Title', 'HEADER') 
hl('Type', 'VARIABLE_TYPE') 

-- }}}


-- hl('Added', 'XXX') --		added line in a diff
-- hl('Boolean', 'XXX') --		a boolean constant: TRUE, false
-- hl('Changed', 'XXX') --		changed line in a diff
-- hl('Character', 'XXX') --	a character constant: 'c', '\n'
-- hl('Conditional', 'XXX') --	if, then, else, endif, switch, etc.
-- hl('Constant', 'XXX') --	any constant
-- hl('Debug', 'XXX') --		debugging statements
-- hl('Define', 'XXX') --		preprocessor #define
-- hl('Delimiter', 'XXX') --	character that needs attention
-- hl('Error', 'XXX') --		any erroneous construct
-- hl('Exception', 'XXX') --	try, catch, throw
-- hl('Float', 'XXX') --		a floating point constant: 2.3e10
-- hl('Function', 'XXX') --	function name (also: methods for classes)
-- hl('Identifier', 'XXX') --	any variable name
-- hl('Ignore', 'XXX') --		left blank, hidden  |hl-Ignore|
-- hl('Include', 'XXX') --		preprocessor #include
-- hl('Keyword', 'XXX') --		any other keyword
-- hl('Label', 'XXX') --		case, default, etc.
-- hl('Macro', 'XXX') --		same as Define
-- hl('Number', 'XXX') --		a number constant: 234, 0xff
-- hl('Operator', 'XXX') --	"sizeof", "+", "*", etc.
-- hl('PreCondit', 'XXX') --	preprocessor #if, #else, #endif, etc.
-- hl('PreProc', 'XXX') --		generic Preprocessor
-- hl('Removed', 'XXX') --		removed line in a diff
-- hl('Repeat', 'XXX') --		for, do, while, etc.
-- hl('SpecialChar', 'XXX') --	special character in a constant
-- hl('SpecialComment', 'XXX') --	special things inside a comment
-- hl('Special', 'XXX') --		any special symbol
-- hl('Statement', 'XXX') --	any statement
-- hl('StorageClass', 'XXX') --	static, register, volatile, etc.
-- hl('String', 'XXX') --		a string constant: "this is a string"
-- hl('Structure', 'XXX') --	struct, union, enum, etc.
-- hl('Tag', 'XXX') --		you can use CTRL-] on this
-- hl('Todo', 'XXX') --		anything that needs extra attention; mostly the
-- hl('Typedef', 'XXX') --		a typedef
-- hl('Type', 'XXX') --		int, long, char, etc.
-- hl('Underlined', 'XXX') --	text that stands out, HTML links
