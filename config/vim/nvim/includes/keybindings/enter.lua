-- ENTER
nmap('<CR>', 'mZo<ESC>`Z', "Add line after this one")

-- SHIFT-ENTER
nmap('<S-CR>', 'mZO<ESC>`Z', "Add line before this one")
imap('<S-CR>', '<ESC>lmZO<ESC>`Zi', "Add line before this one")
