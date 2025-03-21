local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = ","
vim.g.gundo_prefer_python3 = 1

require("lazy").setup({
	-- LSP
	{
		'neovim/nvim-lspconfig', -- LSP configurations for Neovim
		config = function()
			require('lspconfig').clangd.setup{
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--enable-config",
					"--header-insertion-decorators",
					"--completion-style=bundled",
				},
				capabilities = require('cmp_nvim_lsp').default_capabilities()
			}
		end
	},
	-- Autocompletion plugins
	'hrsh7th/nvim-cmp',      -- Completion engine
	'hrsh7th/cmp-nvim-lsp',  -- LSP source for nvim-cmp
	-- FZF and its integration plugin
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" } -- Optional: Adds file icons
	},
	-- TMUX Navigator
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},
    -- TMUX Clipboard
    {
        "roxma/vim-tmux-clipboard",
    },
    {
        "mileszs/ack.vim"
    },
	{
		"navarasu/onedark.nvim",
		config = function()
			require("onedark").setup({
				style = "dark", -- Ensure you're using the dark style
				highlights = {
					["ColorColumn"]  = {                bg = '$orange'               },
					["Folded"]       = {fg = '#FFFF00', bg = '$black', fmt = 'bold'  },
					["CursorLine"]   = {                bg = '#101010'               },
					["Normal"]       = {                bg = '#000000'               },
					["EndOfBuffer"]  = {                bg = '#000000'               }
				}
			})
			require("onedark").load()
		end,
	},

	-- Borders
	{"vim-airline/vim-airline"},  -- The main vim-airline plugin
	{"vim-airline/vim-airline-themes"},  -- Optional: for additional themes

	-- History browsing
	{ "mbbill/undotree" },

	-- GIT
	{"tpope/vim-fugitive"},

	-- fast file switching
	{ 'derekwyatt/vim-fswitch' },

	-- CTag
	{ 'yegappan/taglist' },

	-- Surround
	{ 'tpope/vim-surround' },
})

local cmp = require('cmp')

cmp.setup({
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept completion
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
	}, {
		{ name = 'buffer' },
		{ name = 'path' },
	})
})

-- Airline
vim.cmd([[
" let g:airline_theme='onedark'
" let g:airline_experimental=1
let g:airline_section_c_only_filename=1
let g:airline_stl_path_style='short'
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline#extensions#taglist#enabled=0
let g:airline#extensions#whitespace#mixed_indent_format='[%s]mi'
let g:airline#extensions#whitespace#symbol=''
let g:airline_section_z=airline#section#create(['%p%%', 'maxlinenr', 'colnr'])
]])

local fzf = require('fzf-lua')
fzf.setup({
	winopts = {
		height = 0.85,  -- Window height
		width = 0.80,   -- Window width
		preview = {
			layout = 'vertical', -- Preview layout: horizontal or vertical
			vertical = 'down:45%', -- Vertical preview height
		},
	},
	files = {
		prompt = 'Files❯ ',
		git_icons = true,   -- Show git icons
		file_icons = true,  -- Show file icons
	},
	grep = {
		prompt = 'Rg❯ ',
		input_prompt = 'Grep For❯ ',
		git_icons = true,
		file_icons = true,
	}
})

vim.keymap.set('n', '<leader>t', function()
	local cword = vim.fn.expand("<cword>") -- Get the word under the cursor
	fzf.lsp_live_workspace_symbols({ prompt = 'Fn_', query = cword, })
end, { noremap = true, silent = true, desc = 'Search workspace symbols.' })

-- Fuzzy search of ALL FILES is ',f'
vim.keymap.set('n', '<leader>f', fzf.files, { desc = 'Find Files' })
-- Fuzzy search of OPEN BUFFERS is ',b'
vim.keymap.set('n', '<leader>b', fzf.buffers, { desc = 'Switch Buffers' })

vim.keymap.set('n', '<leader>pwd', function()
    print(vim.fn.expand('%:p:h'))
end, { desc = 'Print directory of current file' })

--
-- Search for strings inside files. 3 ways
--

-- Live using fzf library and a modal window
vim.keymap.set('n', '<leader>g', function()
	local cword = vim.fn.expand('<cword>')
	fzf.live_grep({ search = cword })
end, { desc = 'Grep word under cursor' })

-- List of matches considering .gitignore in a persistent buffer
vim.keymap.set('n', '<leader>a', function()
	vim.g.ackprg = 'rg --vimgrep'
	vim.api.nvim_feedkeys(":LAck! ", "n", false)
end)

-- List of matches of all files in the directory tree in a persistent buffer
vim.keymap.set('n', '<leader>e', function()
	vim.g.ackprg = 'rg --vimgrep --no-ignore'
	vim.api.nvim_feedkeys(":LAck! ", "n", false)
end)

vim.keymap.set('n', '<C-f>', function()
	vim.lsp.buf.code_action({
		apply = true, -- Automatically apply the first code action
	})
end, { desc = "Auto Fix Code Action" })

-- Use space bar to fold code
vim.keymap.set('n', '<Space>',   'za',              { silent = true })
-- Clear existing string search when hitting enter
vim.keymap.set('n', '<CR>',      ':nohlsearch<cr>', { silent = true })
-- Toggle to the previous buffer
vim.keymap.set('n', '<leader><leader>', '<c-^>',    { silent = true })
-- Don't allow arrows when in normal mode
vim.keymap.set('n', '<Left>',  ':echo "no!"<cr>',   { silent = true})
vim.keymap.set('n', '<Right>', ':echo "no!"<cr>',   { silent = true})
vim.keymap.set('n', '<Up>',    ':echo "no!"<cr>',   { silent = true})
vim.keymap.set('n', '<Down>',  ':echo "no!"<cr>',   { silent = true})
-- Undotree
vim.keymap.set('n', '<F5>', vim.cmd.UndotreeToggle)
-- Kill buffer and go back to previous buffer
vim.keymap.set('n', '<leader>d', ':b#<bar>bd#<CR>', { silent = true})

-- Show clangd errors in full
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local opts = {
      focusable = false,
      border = "rounded",
      source = "always",
      prefix = "",
    }
    vim.diagnostic.open_float(nil, opts)
  end,
})

-- Enable dts syntax
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
	pattern = {"*.dts", "*.dtsi", "*.overlay"},
	callback = function()
		vim.bo.filetype = "dts"
		vim.opt_local.foldmethod = "indent"
	end,
})

-- turn syntax off for large files
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function()
		if vim.fn.line2byte(vim.fn.line("$") + 1) > 400000 then
			vim.cmd("syntax clear")
		end
	end,
})

-- Set C defaults
vim.api.nvim_create_autocmd("FileType", {
	pattern = {"c", "cpp" },
	callback = function()
		vim.opt_local.wrap = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.expandtab = true
		vim.opt_local.colorcolumn = "80"

		vim.keymap.set('n', '<leader>h', ':FSHere<CR>',       { silent = true })
		vim.keymap.set('n', '<leader>H', ':FSSplitRight<CR>', { silent = true })
	end,
})
vim.api.nvim_create_autocmd("BufRead", {
	pattern = {"c", "cpp" },
	callback = function()
		vim.b.fswitchlocs =  '.,../Inc,../include,../Include,../inc'
		vim.b.fswitchdst = 'h,hpp'
	end,
})
vim.api.nvim_create_autocmd("BufRead", {
	pattern = {"h", "hpp" },
	callback = function()
		vim.b.fswitchlocs =  '.,../Src,../source,../Source,../src'
		vim.b.fswitchdst = 'h,hpp'
	end,
})
-- Change the color of line numbers
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#404040' })  -- Regular line numbers (gray)
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#FFFF00' })  -- Current line number (yellow)

vim.o.termguicolors  = true        -- Use terminal colors
vim.o.background     = "dark"      -- Dark theme
vim.o.number         = true        -- Add absolute line number on the left side of code
vim.o.cursorline     = true        -- Show the cursor position all the time
vim.o.shell          = "bash"      -- avoids munging PATH under zsh
vim.o.autoread       = true        -- Automatically read files when changed outside of Neovim
vim.o.ignorecase     = true        -- searches are case insensitive...
vim.o.smartcase      = true        -- ... unless they contain at least one capital letter
vim.o.hlsearch       = true        -- highlight searches
vim.o.incsearch      = true        -- incremental searching
vim.o.wrap           = false       -- don't wrap lines
vim.o.tabstop        = 4           -- Tab size
vim.o.shiftwidth     = 4           -- an autoindent (with <<) size
vim.o.expandtab      = true        -- use spaces by default, not tabs
vim.o.list           = true        -- Show invisible characters
vim.o.backspace      = "indent,eol,start" -- backspace through everything in insert mode
vim.o.joinspaces     = false       -- Use only 1 space after "." when joining lines, not 2
vim.o.undofile       = true          -- Save the undo history
vim.o.autowrite      = true          -- Write the contents of the file on buffer switching
vim.o.scrolloff      = 3            -- Set context as we're scrolling
vim.o.splitright     = true        -- When splitting, move cursor to new window
vim.o.splitbelow     = true        -- When splitting, move cursor to new window
vim.o.foldmethod     = 'syntax'    -- Default code folding to syntax
vim.o.foldlevelstart = 99      -- Do not fold when file is originally open
vim.o.tags           = ".tags"
vim.o.signcolumn     = 'yes'       -- Keep clangd sign column visible even when in editing mode
vim.o.updatetime     = 2500        -- 1.0 seconds before floating window appears showing diagnostics

vim.g.autotagTagsFile=".tags"
vim.g.autotagmaxTagsFileSize="1000000000"
vim.g.vim_tmux_clipboard_loadb_option = '-w'

-- show when tabs exists
-- show when trailing spaces exist
-- Show when line goes past the right side
-- Show when line goes past the left side
vim.o.listchars = "tab:»·,trail:◘,extends:>,precedes:<"


_G.LRefreshTags = function()
	local cwd = vim.fn.getcwd()
	local cmd = "rm -f " .. vim.o.tags .. "; ctags -R -f " .. cwd .. "/.tags *"
	local resp = vim.fn.system(cmd)
end
vim.api.nvim_create_user_command('LRefreshTags', LRefreshTags, { bang = true, nargs = '*' })

