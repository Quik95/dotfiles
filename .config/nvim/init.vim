filetype plugin on
set tabstop=4               "number of spaces a <Tab> stands for
set softtabstop=4           "number of spaces to insert for a <Tab>
set shiftwidth=4            "number of spaces used for each step of indent
set expandtab               "expand <Tab> to spaces in Insert mode
set smartindent             "do clever autoindenting
set exrc                    "enabel local init.vim
set relativenumber          "relative number line
set nohlsearch              "clear highlight after searching
set hidden                  "don't unload a buffer when no longer shown in a window
set noerrorbells            "don't ring error bells
set number                  "show line number
set nowrap                  "don't wrap text
set noswapfile              "don't keep a swapfile
set nobackup                "don't keep a backup
set undodir=~/.nvim/undodir "undo directory path
set undofile                "keep an undo file
set incsearch               "search as you type
set termguicolors           "use GUI colors for the terminal
set scrolloff=8             "number of screen lines to show around the cursor
set cmdheight=2             "give more space for displaying messages
set cursorline              "highlight current line
set signcolumn=yes          "whether to show the signcolumn
set shortmess+=c            "Don't pass messages to ins-completion-menu.
set updatetime=300          " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.

call plug#begin('~/.nvim/plugged/')
" Neovim lsp plugins
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Neovim tree shitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'nvim-telescope/telescope.nvim'
" required by telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'

Plug 'gruvbox-community/gruvbox'
Plug 'arcticicestudio/nord-vim'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Plug 'rust-lang/rust.vim'

Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'

Plug 'mbbill/undotree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'phaazon/hop.nvim'
call plug#end()


lua require'nvim-treesitter.configs'.setup { highlight = { enable = true } }


" colorscheme gruvbox         "aka the best colorscheme
colorscheme nord

let g:airline_theme='solarized'
let g:airline_solarized_bg="dark"

let g:rg_derive_root='true'

let mapleader = " "
" source config
nnoremap <Leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

nnoremap <leader>u :UndotreeShow<CR>

fun! TrimWhitespace()
        let l:save = winsaveview()
        keeppatterns %s/\s\+$//e
        call winrestview(l:save)
endfun

augroup THE_PRIMEAGEN
    autocmd!
    autocmd BufWritePre * :call TrimWhitespace()
augroup END

augroup COMPLETION
    autocmd!
    autocmd BufEnter * lua require'completion'.on_attach()
augroup END



augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
augroup END

"THE GREATEST REMAP
com! W w

let g:go_fmt_command = "goimports"
let g:go_metalinter_command='golangci-lint --enable-all'
let g:go_metalinter_autosave_enabled = 1

nnoremap <leader>+ :vertical resize +5<CR>
nnoremap <leader>- :vertical resize -5<CR>
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>bd :bd<CR>

" LSP and completion stuff
lua require'lspconfig'.gopls.setup{}
lua require'lspconfig'.pyls.setup{}

set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
let g:completion_confirm_key = ""
let g:completion_trigger_keyword_length = 2
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"map <c-Space> to manually trigger completion
imap <silent> <c-Space> <Plug>(completion_trigger)
let g:completion_confirm_key = ""
inoremap <expr> <cr>    pumvisible() ? "\<Plug>(completion_confirm_completion)" : "\<cr>"

nnoremap <leader>vd :lua vim.lsp.buf.definition()<CR>
nnoremap <leader>vi :lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>vsh :lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>vrr :lua vim.lsp.buf.references()<CR>
nnoremap <leader>vrn :lua vim.lsp.buf.rename()<CR>
nnoremap <leader>vld :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
nnoremap <leader>vh :lua vim.lsp.buf.hover()<CR>
nnoremap <leader>vn :lua vim.lsp.diagnostics.goto_next()<CR>
nnoremap = :lua vim.lsp.buf.formatting()<CR>

" Telescope remaps
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <leader>pf :lua require('telescope.builtin').find_files()<CR>

" hop.nvim
nnoremap <leader>ww :HopWord<CR>
nnoremap <leader>wp :HopPattern<CR>
nnoremap <leader>wb :HopChar2<CR>
nnoremap <leader>wl :HopLine<CR>

" lua filetree
let g:nvim_tree_quit_on_open = 1
let g:nvim_tree_git_hl = 1
nnoremap <leader>t :NvimTreeToggle<CR>
let g:nvim_tree_icons = {
    \ 'default': '',
    \ 'symlink': '',
    \ 'git': {
    \   'unstaged': "✗",
    \   'staged': "✓",
    \   'unmerged': "",
    \   'renamed': "➜",
    \   'untracked': "★"
    \   },
    \ 'folder': {
    \   'default': "",
    \   'open': "",
    \   'empty': "",
    \   'empty_open': "",
    \   'symlink': "",
    \   'symlink_open': "",
    \   }
    \ }

