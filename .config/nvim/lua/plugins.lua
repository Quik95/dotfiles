return require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-compe'

    use { 'vim-airline/vim-airline', requires = {'vim-airline/vim-airline-themes'}}

    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

    use {'nvim-telescope/telescope.nvim', requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim'
    }}

    use 'gruvbox-community/gruvbox'
    use 'arcticicestudio/nord-vim'

    use {'fatih/vim-go', run = ":GoUpdateBinaries"}

    use {'kyazdani42/nvim-tree.lua', requires = {'kyazdani42/nvim-web-devicons'}}

    use 'mbbill/undotree'
    use 'tpope/vim-fugitive'
    use 'tpope/vim-commentary'
    use 'phaazon/hop.nvim'
    use 'cohama/lexima.vim'
end)
