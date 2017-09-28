scriptencoding utf-8
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'bling/vim-bufferline'
Plug 'kien/ctrlp.vim'

Plug 'vim-airline/vim-airline-themes'

Plug 'hashivim/vim-terraform'
Plug 'pangloss/vim-javascript'
 
Plug 'klen/python-mode'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'davidhalter/jedi-vim'
" Plug 'Valloric/YouCompleteMe'

"Plug 'sjl/gundo.vim'
Plug 'mbbill/undotree'

Plug 'aperezdc/vim-template'
:
Plug 'majutsushi/tagbar'

Plug 'tpope/vim-fugitive'
call plug#end()

let g:ycm_autoclose_preview_window_after_completion=1
let g:airline_exclude_preview = 1

nmap <F3> :TagbarToggle<CR>

set laststatus=2
set nu

" let pymode_lint_checkers = ['pep8', 'mccabe']

set pastetoggle=<F2>

set expandtab
set tabstop=4

let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2 
let g:indent_guides_enable_on_vim_startup = 1
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=239 "237
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=246
" hi IndentGuidesOdd  ctermbg=black
" hi IndentGuidesEven ctermbg=darkgrey
" hi Folded ctermbg=0242

let g:email = "waqas.khan@trueex.com"
let g:username = "waqask"

autocmd BufWritePre *.{py,sh,tf} :%s/Last Modified: .*/\='Last Modified: '. strftime('%F %T %Z')/ | ''
" autocmd BufReadPost,FileReadPost *.tf :set syntax=javascript
au BufWritePost * if getline(1) =~ "^#!" | if getline(1) =~ "/bin/" | silent !chmod 744 <afile> | endif | endif

nmap a :bprev<Return>
nmap s :bnext<Return>
nmap <b-d> :bd<Return>
nmap b :exec ":buf! ".input("")<CR>

" syntax on

" hide buffer so it only shows in airline
let g:bufferline_echo = 0

" do this so you can exit a buffer/vim without saving it
set hidden

set tabpagemax=100
set hlsearch

" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
	let myUndoDir = expand(vimDir . '/undodir')
	" Create dirs
	call system('mkdir -p ' . vimDir)
	call system('mkdir -p ' . myUndoDir)
	let &undodir = myUndoDir
	set undofile
    
    nmap <F6> :UndotreeToggle <CR>
    let g:undotree_SetFocusWhenToggle = 1
endif

if &diff
"    hi DiffAdd      gui=none    guifg=NONE          guibg=#bada9f
"    hi DiffChange   gui=none    guifg=NONE          guibg=#e5d5ac
"    hi DiffDelete   gui=bold    guifg=#ff8080       guibg=#ffb0b0
"    hi DiffText     gui=none    guifg=NONE          guibg=#8cbee2
    colorscheme molokai
else
"    colorscheme solarized8_dark
"    colorscheme zenburn
    colorscheme apprentice
endif

