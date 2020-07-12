scriptencoding utf-8

" Put plugins and dictionaries in this dir (also on Windows)
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
"Plug 'Valloric/YouCompleteMe'

"Plug 'simnalamburt/vim-mundo'
Plug 'mbbill/undotree'

Plug 'aperezdc/vim-template'
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-fugitive'
Plug 'thaerkh/vim-workspace'
Plug 'will133/vim-dirdiff'
Plug 'mhinz/vim-startify'
call plug#end()

let g:ycm_autoclose_preview_window_after_completion=1
let g:airline_exclude_preview = 1

"let g:tmpl_auto_initialize = 0
"let g:jedi#completions_enabled = 0
"let g:pymode_rope = 0

"set statusline=%<%f\ %h%m%r%{kite#statusline()}%=%-14.(%l,%c%V%)\ %P
set laststatus=2
set nu
set rnu

set pastetoggle=<F2>

set expandtab
set tabstop=4
set sw=4

let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2 
let g:indent_guides_enable_on_vim_startup = 1

autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=239 "237
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=246
autocmd VimLeave * :ccl

" hi IndentGuidesOdd  ctermbg=black
" hi IndentGuidesEven ctermbg=darkgrey
" hi Folded ctermbg=0242

let g:email = "waqas@tassat.com"
let g:username = "waqask"

autocmd BufWritePre *.{py,sh,tf} :%s/Last Modified: \?.*/\='Last Modified: '. strftime('%F %T %Z')/ | ''
" autocmd BufReadPost,FileReadPost *.tf :set syntax=javascript

nmap a :bprev<Return>
nmap s :bnext<Return>
nmap <b-d> :bd<Return>
nmap b :exec ":buf! ".input("")<CR>

" syntax on
" colorscheme solarized8_dark
" colorscheme zenburn

nnoremap <leader>s :ToggleWorkspace<CR>
let g:workspace_session_directory = $HOME . '/.vim/sessions/'
let g:workspace_undodir = $HOME . '/.vim/undodir/'
let g:workspace_session_disable_on_args = 1
let g:workspace_autosave_ignore = ['gitcommit', 'qf', 'nerdtree', 'Tagbar', 'mundo']

" hide buffer so it only shows in airline
let g:bufferline_echo = 0

" do this so you can exit a buffer/vim without saving it
set hidden
set hls

filetype on

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undodir')
    " Create dirs
    call system('mkdir -p ' . vimDir)
    call system('mkdir -p ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile

    nmap <F3> :UndotreeToggle<CR>
    nmap <F4> :TagbarToggle<CR>
    let g:undotree_SetFocusWhenToggle = 1
endif

if &diff
"    hi DiffAdd      gui=none    guifg=NONE          guibg=#bada9f
"    hi DiffChange   gui=none    guifg=NONE          guibg=#e5d5ac
"    hi DiffDelete   gui=bold    guifg=#ff8080       guibg=#ffb0b0
"    hi DiffText     gui=none    guifg=NONE          guibg=#8cbee2
"    colorscheme molokai
    colorscheme jellybeans
else
"    colorscheme solarized8_dark
"    colorscheme zenburn
"    colorscheme apprentice
    colorscheme jellybeans
"    autocmd BufWinEnter * :only | wincmd _
endif

" On the initial save, make the file executable if it has a shebang line,
" e.g. #!/usr/bin/env ...
" This uses the user's umask for determining the executable bits to be set.
function! s:GetShebang()
    return matchstr(getline(1), '^#!\S\+')
endfunction
function! s:MakeExecutable()
    if exists('b:executable') | return | endif
    let l:shebang = s:GetShebang()
    if empty(l:shebang) ||
    \   executable(expand('%:p')) ||
    \   ! executable('chmod')
        return
    endif

    call system('chmod +x ' . shellescape(expand('%')))
    if v:shell_error
        echohl ErrorMsg
        echomsg 'Cannot make file executable: ' . v:shell_error
        echohl None
        let b:executable = 0
    else
        echomsg 'Detected shebang' l:shebang . '; made file executable as' getfperm(expand('%'))
        let b:executable = 1
    endif
endfunction
"augroup ExecutableFileDetect
"    autocmd!
    autocmd BufWritePost * call <SID>MakeExecutable()
"augroup END
