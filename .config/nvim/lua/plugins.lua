return require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use 'neovim/nvim-lspconfig'

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'f3fora/cmp-spell',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
    }
    -- use { 'hrsh7th/nvim-compe', requires = { 'hrsh7th/vim-vsnip', 'rafamadriz/friendly-snippets', 'hrsh7th/vim-vsnip-integ' } }
    use 'ray-x/lsp_signature.nvim'

    use { 'vim-airline/vim-airline', requires = {'vim-airline/vim-airline-themes'}}

    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

    use {'nvim-telescope/telescope.nvim', requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim'
    }}

    use 'morhetz/gruvbox'
    use 'arcticicestudio/nord-vim'

    -- use {'fatih/vim-go', run = ":GoUpdateBinaries"}
    use {'fatih/vim-go'}

    use {'kyazdani42/nvim-tree.lua', requires = {'kyazdani42/nvim-web-devicons'}}

    use 'mbbill/undotree'
    use 'tpope/vim-fugitive'
    use 'tpope/vim-commentary'
    use 'phaazon/hop.nvim'
    use 'cohama/lexima.vim'
end)
