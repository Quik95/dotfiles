lua require'nvim-treesitter.configs'.setup { highlight = { enable = true } }

nnoremap <leader>u :UndotreeShow<CR>

let g:rg_derive_root='true'

let linters = [
            \"deadcode",
            \"errcheck",
            \"gosimple",
            \"govet",
            \"ineffassign",
            \"staticcheck",
            \"structcheck",
            \"typecheck",
            \"unused",
            \"varcheck",
            \"bodyclose",
            \"cyclop",
            \"dogsled",
            \"dupl",
            \"durationcheck",
            \"errorlint",
            \"exhaustive",
            \"exhaustivestruct",
            \"exportloopref",
            \"forcetypeassert",
            \"funlen",
            \"gci",
            \"gocognit",
            \"goconst",
            \"gocritic",
            \"godot",
            \"goerr113",
            \"gofumpt",
            \"gomnd",
            \"gomoddirectives",
            \"goprintffuncname",
            \"gosec",
            \"ifshort",
            \"importas",
            \"makezero",
            \"misspell",
            \"nakedret",
            \"nestif",
            \"nilerr",
            \"nlreturn",
            \"noctx",
            \"nolintlint",
            \"paralleltest",
            \"prealloc",
            \"predeclared",
            \"promlinter",
            \"rowserrcheck",
            \"sqlclosecheck",
            \"tagliatelle",
            \"testpackage",
            \"thelper",
            \"tparallel",
            \"unconvert",
            \"unparam",
            \"wastedassign",
            \"whitespace",
            \"wrapcheck",
            \"wsl"
\]

let g:go_fmt_command = "goimports"
let g:go_gopls_gofumpt = v:true
let g:go_metalinter_command='golangci-lint'
let g:go_metalinter_enabled=linters
let g:go_metalinter_autosave = 1

" hop.nvim
nnoremap <leader>w :HopWord<CR>

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

"Auto close parentheses
let g:lexima_enable_basic_rules = 1
