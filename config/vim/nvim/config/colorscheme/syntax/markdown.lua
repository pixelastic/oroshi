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


-- Gutter sign
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

-- Unused (yet)
hl('RenderMarkdownQuote', 'XXX') -- 	Default for block quote
hl('RenderMarkdownQuote1', 'XXX') -- 	Level 1 block quote marker
hl('RenderMarkdownQuote2', 'XXX') -- 	Level 2 block quote marker
hl('RenderMarkdownQuote3', 'XXX') -- 	Level 3 block quote marker
hl('RenderMarkdownQuote4', 'XXX') -- 	Level 4 block quote marker
hl('RenderMarkdownQuote5', 'XXX') -- 	Level 5 block quote marker
hl('RenderMarkdownQuote6', 'XXX') -- 	Level 6 block quote marker
hl('RenderMarkdownInlineHighlight', 'XXX') -- 	Inline highlights contents
hl('RenderMarkdownMath', 'XXX') -- 	Latex lines
hl('RenderMarkdownIndent', 'XXX') -- 	Indent icon
hl('RenderMarkdownHtmlComment', 'XXX') -- 	HTML comment inline text
hl('RenderMarkdownWikiLink', 'XXX') -- 	WikiLink icon & text
hl('RenderMarkdownUnchecked', 'XXX') -- 	Unchecked checkbox
hl('RenderMarkdownChecked', 'XXX') -- 	Checked checkbox
hl('RenderMarkdownTodo', 'XXX') -- 	Todo custom checkbox
hl('RenderMarkdownTableHead', 'XXX') -- 	Pipe table heading rows
hl('RenderMarkdownTableRow', 'XXX') -- 	Pipe table body rows
hl('RenderMarkdownTableFill', 'XXX') -- 	Pipe table inline padding
hl('RenderMarkdownSuccess', 'XXX') -- 	Success related callouts
hl('RenderMarkdownInfo', 'XXX') -- 	Info related callouts
hl('RenderMarkdownHint', 'XXX') -- 	Hint related callouts
hl('RenderMarkdownWarn', 'XXX') -- 	Warning related callouts
hl('RenderMarkdownError', 'XXX') -- 	Error related callouts
