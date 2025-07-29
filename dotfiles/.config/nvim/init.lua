-- Basic Neovim Configuration

-- Line numbers
vim.opt.number = true           -- Show absolute line numbers
vim.opt.relativenumber = true   -- Show relative line numbers

-- Indentation
vim.opt.tabstop = 4            -- Number of spaces tabs count for
vim.opt.shiftwidth = 4         -- Size of an indent
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.autoindent = true      -- Copy indent from current line when starting new line
vim.opt.smartindent = true     -- Smart autoindenting when starting new line

-- Search
vim.opt.ignorecase = true      -- Ignore case in search patterns
vim.opt.smartcase = true       -- Override ignorecase if search contains uppercase
vim.opt.hlsearch = true        -- Highlight search results
vim.opt.incsearch = true       -- Show search matches as you type

-- Visual
vim.opt.wrap = false           -- Don't wrap lines
vim.opt.scrolloff = 8          -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8      -- Keep 8 columns left/right of cursor
vim.opt.cursorline = true      -- Highlight current line
vim.opt.termguicolors = true   -- Enable 24-bit RGB colors

-- Behavior
vim.opt.mouse = 'a'            -- Enable mouse support
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.undofile = true        -- Enable persistent undo
vim.opt.swapfile = false       -- Disable swap files
vim.opt.backup = false         -- Disable backup files

-- Split behavior
vim.opt.splitbelow = true      -- Horizontal splits go below
vim.opt.splitright = true      -- Vertical splits go right

-- Leader key
vim.g.mapleader = ' '          -- Set space as leader key

-- Basic keymaps
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>x', ':qa<CR>', { desc = 'Exit (quit all)' })
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
