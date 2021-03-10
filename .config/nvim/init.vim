if exists('g:vscode')
    xmap gc  <Plug>VSCodeCommentary
    nmap gc  <Plug>VSCodeCommentary
    omap gc  <Plug>VSCodeCommentary
    nmap gcc <Plug>VSCodeCommentaryLine
else
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

    Plug 'nvim-telescope/telescope.nvim'
    " required by telescope
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'

    Plug 'gruvbox-community/gruvbox'
    Plug 'arcticicestudio/nord-vim'

    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    Plug 'rust-lang/rust.vim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    Plug 'mbbill/undotree'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-commentary'
    Plug 'Krasjet/auto.pairs'
    Plug 'easymotion/vim-easymotion'
    Plug 'justinmk/vim-sneak'
    call plug#end()

    " colorscheme gruvbox         "aka the best colorscheme
    colorscheme nord

    let mapleader = " "
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

    augroup highlight_yank
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
    augroup END

    "THE GREATEST REMAP
    com! W w

    let g:go_fmt_command = "goimports"
    let g:go_metalinter_autosave_enabled = 1

    nnoremap <leader>+ :vertical resize +5<CR>
    nnoremap <leader>- :vertical resize -5<CR>
    nnoremap <leader>h :wincmd h<CR>
    nnoremap <leader>j :wincmd j<CR>
    nnoremap <leader>k :wincmd k<CR>
    nnoremap <leader>l :wincmd l<CR>
    nnoremap <leader>bd :bd<CR>
    map f <Plug>Sneak_s
    map F <Plug>Sneak_S

    " LSP and completion stuff
    lua require'lspconfig'.gopls.setup{ on_attach=require'completion'.on_attach }
    lua require'lspconfig'.pyls.setup{ on_attach=require'completion'.on_attach }
    lua require'lspconfig'.rust_analyzer.setup{ on_attach=require'completion'.on_attach }
    lua require'lspconfig'.clangd.setup{ on_attach=require'completion'.on_attach }

    set completeopt=menuone,noinsert,noselect
    let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
    " Use <Tab> and <S-Tab> to navigate through popup menu
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    "map <c-Space> to manually trigger completion
    imap <silent> <c-Space> <Plug>(completion_trigger)
    let g:completion_tabnine_max_num_results=3
    let g:completion_chain_complete_list = {
        \ 'default': [
        \    {'complete_items': ['tabnine', 'lsp', 'snippet']},
        \    {'mode': '<c-p>'},
        \    {'mode': '<c-n>'}
        \]
    \}

    nnoremap <leader>vd :lua vim.lsp.buf.definition()<CR>
    nnoremap <leader>vi :lua vim.lsp.buf.implementation()<CR>
    nnoremap <leader>vsh :lua vim.lsp.buf.signature_help()<CR>
    nnoremap <leader>vrr :lua vim.lsp.buf.references()<CR>
    nnoremap <leader>vrn :lua vim.lsp.buf.rename()<CR>
    nnoremap <leader>vld :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
    nnoremap <leader>vh :lua vim.lsp.buf.hover()<CR>
    nnoremap = :lua vim.lsp.buf.formatting()<CR>
endif
