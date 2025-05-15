" GITCONFIG
" Allow folding by category
setlocal foldexpr=getline(v:lnum)=~'^[;#]\\s*\\(ex\\\|vi\\\|vim\\):'?\">1\":((getline(v:lnum)=~\"^#\\\\=[\")?\">1\":\"1\") 
setlocal foldmethod=expr 
