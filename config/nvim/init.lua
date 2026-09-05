local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

-- Neovim detects *.h as filetype cpp, and that filetype is the LSP languageId,
-- so without this clangd parses C headers as C++.
vim.g.c_syntax_for_h = 1

require("lazy").setup({
	-- Completion is mini.completion; LSP is configured natively below.
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
	{
		"navarasu/onedark.nvim",
		config = function()
			require("onedark").setup({
				style = "dark", -- Ensure you're using the dark style
				highlights = {
					["ColorColumn"]  = {                bg = '$orange'               },
					["Folded"]       = {fg = '#FFFF00', bg = '$black', fmt = 'bold'  },
					["CursorLine"]   = {                bg = '#202020'               },
					["Normal"]       = {                bg = '#000000'               },
					["EndOfBuffer"]  = {                bg = '#000000'               },
					["LineNr"]       = { fg = '#404040' },
					["CursorLineNr"] = { fg = '#FFFF00' },
					-- Dedicated to render-markdown code only (wired up in opts.code below)
					["MdCodeBlock"]  = {                bg = '#1a1a1a' },
					["MdCodeInline"] = { fg = '#E9C46A', bg = '#1a1a1a' }
				}
			})
			require("onedark").load()
		end,
	},
	-- Treesitter parsers (main branch installs nothing by default; needs the
	-- tree-sitter CLI on PATH). Drives syntax highlighting inside markdown fences.
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter').install({
				'bash', 'c', 'cpp', 'json', 'lua', 'markdown', 'markdown_inline',
				'python', 'toml', 'vim', 'vimdoc', 'yaml',
			})
		end,
	},
	-- View Markdown files
	{
		'MeanderingProgrammer/render-markdown.nvim',
		dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			code = {
				-- MdCodeBlock / MdCodeInline are defined in the onedark highlights table above
				highlight        = 'MdCodeBlock',  -- fenced block body
				highlight_inline = 'MdCodeInline', -- `inline code`
				highlight_border = 'MdCodeBlock',  -- language label row (false = keep icon color)
				highlight_info   = 'MdCodeBlock',  -- info string after the language
			},
		},
	},
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim", },
		keys = {
			{ "<leader>c", "<cmd>ClaudeCode --continue<cr>", desc = "Resume Claude", mode = { "n", "x" } },
			{ "<C-x>",     "<cmd>ClaudeCode --continue<cr>", desc = "Resume Claude", mode = { "n", "x" } },
			{ "<leader>lr", "<cmd>ClaudeCode --resume<cr>", desc = "Continue Claude" },
			{ "<leader>lf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude", mode = { "n", "x" } },
			{ "<leader>lm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>lb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>lv", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{
				"<leader>ls",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
			},
			-- Diff management
			{ "<leader>la", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ld", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
		opts = {
			terminal = {
				---@module "snacks"
				---@type snacks.win.Config|{}
				snacks_win_opts = {
					position = "float",
					width = 0.9,
					height = 0.9,
					wo = {
						winhighlight = "Normal:ClaudeTermBg,NormalNC:ClaudeTermBg",
					},
					keys = {
						claude_hide_ctrl = { "<C-x>", function(self) self:hide() end, mode = "t", desc = "Hide (Ctrl+x)" },
						claude_hide_esc = { "<C-\\><C-n>", function(self) self:hide() end, mode = "t", desc = "Hide (Ctrl+\\)" },
						claude_nav_left  = { "<C-h>", function(self) self:hide(); vim.cmd("TmuxNavigateLeft")  end, mode = "t", desc = "Nav left" },
						claude_nav_down  = { "<C-j>", function(self) self:hide(); vim.cmd("TmuxNavigateDown")  end, mode = "t", desc = "Nav down" },
						claude_nav_up    = { "<C-k>", function(self) self:hide(); vim.cmd("TmuxNavigateUp")    end, mode = "t", desc = "Nav up" },
						claude_nav_right = { "<C-l>", function(self) self:hide(); vim.cmd("TmuxNavigateRight") end, mode = "t", desc = "Nav right" },
					},
				},
			},
		},
	},


	-- History browsing
	{ "mbbill/undotree" },

	-- GIT
	{"tpope/vim-fugitive"},

	-- Surround, statusline, animation, minimap - the suite is already pulled in as
	-- a render-markdown dependency, so declare it properly rather than relying on
	-- that transitive load.
	{ 'nvim-mini/mini.nvim' },
})

-- Native LSP configuration (Neovim 0.11+)
-- Advertise mini.completion's capabilities to the server
local capabilities = require('mini.completion').get_lsp_capabilities()

vim.lsp.config.clangd = {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--enable-config",
		"--header-insertion-decorators",
		"--completion-style=bundled",
	},
	capabilities = capabilities,
	filetypes = { "c", "cpp", "objc", "objcpp" },
	root_markers = { ".git", "compile_commands.json" },
}

-- vim.lsp.enable() installs its own FileType autocmd and gates on the filetypes
-- list above, so one call is enough. Wrapping it in a FileType autocmd re-ran
-- doautoall across every loaded buffer on each C/C++ file opened.
vim.lsp.enable("clangd")

-- Source/header switching through clangd's switchSourceHeader extension,
-- replacing vim-fswitch. clangd resolves the pair from compile_commands.json, so
-- layouts like Inc/ + Src/ work without maintaining a search-path list.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or client.name ~= "clangd" then return end
		local function switch(split)
			local params = vim.lsp.util.make_text_document_params(args.buf)
			client:request("textDocument/switchSourceHeader", params, function(err, result)
				if err then return vim.notify(tostring(err), vim.log.levels.ERROR) end
				if not result or result == "" then
					return vim.notify("No corresponding source/header", vim.log.levels.WARN)
				end
				if split then vim.cmd("vsplit") end
				vim.cmd.edit(vim.uri_to_fname(result))
			end, args.buf)
		end
		vim.keymap.set("n", "<leader>h", function() switch(false) end,
			{ buffer = args.buf, silent = true, desc = "Switch source/header" })
		vim.keymap.set("n", "<leader>H", function() switch(true) end,
			{ buffer = args.buf, silent = true, desc = "Switch source/header (split)" })
	end,
})

-- The c/cpp parsers are installed but nothing started treesitter for them.
-- foldmethod=syntax yields no folds once treesitter is the highlighter, hence
-- the local foldexpr.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function(args)
		if vim.b[args.buf].large_file then return end
		vim.treesitter.start()
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end,
})

-- Cursor animation only. Scroll turns one <C-d> into up to 60 redraws ~4ms apart
-- (expensive over tmux on WSL2) and resize fires on every tmux pane resize.
require('mini.animate').setup({
	scroll = { enable = false },
	resize = { enable = false },
	open   = { enable = false },
	close  = { enable = false },
})

-- mini.surround with the documented vim-surround-compatible mappings, replacing
-- tpope/vim-surround. Gains dot-repeat, which vim-surround only has via
-- vim-repeat (never installed here).
require('mini.surround').setup({
	mappings = {
		add = 'ys', delete = 'ds', replace = 'cs',
		find = '', find_left = '', highlight = '',
		suffix_last = '', suffix_next = '',
	},
	search_method = 'cover_or_next',
})
pcall(vim.keymap.del, 'x', 'ys')
vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
vim.keymap.set('n', 'yss', 'ys_', { remap = true })
local minimap = require('mini.map')
minimap.setup({
	integrations = {
		minimap.gen_integration.builtin_search(),
		-- default is errors only; clangd runs with --clang-tidy so warnings matter
		minimap.gen_integration.diagnostic({
			error = 'DiagnosticFloatingError',
			warn  = 'DiagnosticFloatingWarn',
		}),
	},
	symbols = {
		-- Default encode symbols are the U+1FB00 "Legacy Computing" 3x2 blocks,
		-- which many terminal fonts lack (renders as tofu/blank). The 2x2 set is
		-- plain U+2580 block elements, available everywhere.
		encode = minimap.gen_encode_symbols.block('2x2'),
	},
	-- window defaults are already side='right', width=10, winblend=25
})

vim.keymap.set('n', '<leader>mm', minimap.toggle,       { desc = 'Toggle minimap' })
vim.keymap.set('n', '<leader>ms', minimap.toggle_side,  { desc = 'Toggle minimap side' })
vim.keymap.set('n', '<leader>mf', minimap.toggle_focus, { desc = 'Focus minimap' })

-- mini.map deliberately provides no autoopen; wire it up for C/C++ buffers.
vim.api.nvim_create_autocmd("FileType", {
	group    = vim.api.nvim_create_augroup("MiniMapAutoOpen", { clear = true }),
	pattern  = { "c", "cpp", "objc", "objcpp" },
	callback = function(args)
		-- skip fzf-lua previews, claudecode scratch buffers, etc.
		if vim.bo[args.buf].buftype ~= "" then return end
		vim.schedule(function()
			-- FileType also fires for buffers loaded without a window
			if vim.api.nvim_get_current_buf() ~= args.buf then return end
			-- skip if this buffer landed inside a float
			if vim.api.nvim_win_get_config(0).relative ~= "" then return end
			minimap.open()
		end)
	end,
})

-- mini.completion replaces nvim-cmp + cmp-nvim-lsp. The old <C-Space> (complete)
-- and <C-f>/<C-b> (scroll docs) are mini's defaults, and <C-e> is Vim's built-in
-- complete_CTRL-E. The 'buffer' and 'path' cmp sources were never registered
-- (cmp-buffer/cmp-path are not installed); mini's fallback provides them for real,
-- and adds signature help, which cmp needed another plugin for.
require('mini.completion').setup()

-- Enter confirms only an explicitly selected item. mini sets
-- completeopt=menuone,noselect, so nothing is preselected and Enter inserts a
-- newline rather than accepting a completion you never chose.
vim.keymap.set('i', '<CR>', function()
	if vim.fn.complete_info()['selected'] ~= -1 then return '\25' end -- <C-y>
	return '\r'
end, { expr = true, desc = 'Confirm selected completion, else newline' })

-- mini.statusline replaces vim-airline + vim-airline-themes. The sections below
-- reproduce the airline settings that lived here: filename only, no
-- "utf-8[unix]" noise, and a %p%% / maxlinenr / colnr tail.

-- airline's mixed-indent-file check has no equivalent anywhere in mini, so port
-- it. Like airline's, it is cached per buffer and recomputed only on read/write/
-- idle - a statusline component runs on every redraw, which this is far too
-- expensive for.
local function compute_mixed_indent(buf)
	if vim.bo[buf].buftype ~= '' then return '' end
	local n = vim.api.nvim_buf_line_count(buf)
	if n > 20000 then return '' end   -- airline bails at the same size
	local c_like = vim.tbl_contains(
		{ 'c', 'cpp', 'objc', 'objcpp', 'java', 'javascript', 'arduino' }, vim.bo[buf].filetype)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local tab_line, spc_line
	for i, l in ipairs(lines) do
		-- tabs-then-spaces or spaces-then-tabs within one indent
		if l:match('^\t+ +') or l:match('^ +\t+') then return ('[%d]mi'):format(i) end
		if not tab_line and l:match('^\t') then tab_line = i end
		-- in C-like files a leading ' *' is a doc-comment continuation, not an indent
		if not spc_line and l:match('^ ') and not (c_like and l:match('^ +%*')) then
			spc_line = i
		end
	end
	if tab_line and spc_line then return ('[%d:%d]mi'):format(tab_line, spc_line) end
	return ''
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'CursorHold' }, {
	group = vim.api.nvim_create_augroup('MixedIndentCheck', { clear = true }),
	callback = function(args)
		vim.b[args.buf].mixed_indent = compute_mixed_indent(args.buf)
	end,
})

local statusline = require('mini.statusline')
statusline.setup({
	content = {
		active = function()
			local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
			local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
			-- airline pulled the branch from fugitive; mini.statusline's own git
			-- section needs mini.git or gitsigns, so read fugitive directly.
			local git = vim.fn.exists('*FugitiveHead') == 1 and vim.fn.FugitiveHead(7) or ''
			if git ~= '' then git = ' ' .. git end
			local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
			fileinfo = fileinfo:gsub('%s*utf%-8%[unix%]', '')  -- airline's skip_expected_string
			return statusline.combine_groups({
				{ hl = mode_hl,                  strings = { mode } },
				{ hl = 'MiniStatuslineDevinfo',  strings = { git, diagnostics } },
				'%<',
				{ hl = 'MiniStatuslineFilename', strings = { '%t%m%r' } },
				'%=',
				{ hl = 'MiniStatuslineDevinfo',  strings = { vim.b.mixed_indent or '' } },
				{ hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
				{ hl = mode_hl,                  strings = { '%p%%', '%L', '%2v' } },
			})
		end,
	},
})

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
-- Document symbols, replacing the taglist window (which was never bound anyway)
vim.keymap.set('n', '<leader>o', fzf.lsp_document_symbols, { desc = 'Document Symbols' })

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

-- ack.vim was a thin wrapper that swapped 'grepprg' and ran :lgrep, so use the
-- native commands directly. grepformat already matches rg --vimgrep output.
vim.o.grepprg = 'rg --vimgrep'
vim.o.grepformat = '%f:%l:%c:%m'

-- List of matches considering .gitignore in a persistent buffer
vim.keymap.set('n', '<leader>a', function()
	vim.o.grepprg = 'rg --vimgrep'
	vim.api.nvim_feedkeys(':lgrep! ', 'n', false)
end, { desc = 'Grep (respects .gitignore)' })

-- List of matches of all files in the directory tree in a persistent buffer
vim.keymap.set('n', '<leader>e', function()
	vim.o.grepprg = 'rg --vimgrep --no-ignore'
	vim.api.nvim_feedkeys(':lgrep! ', 'n', false)
end, { desc = 'Grep (all files)' })

-- Open the result window automatically once the grep finishes.
vim.api.nvim_create_autocmd('QuickFixCmdPost', { pattern = 'l*',     command = 'botright lwindow' })
vim.api.nvim_create_autocmd('QuickFixCmdPost', { pattern = '[^l]*',  command = 'botright cwindow' })

-- ack.vim's result-window mappings, ported so the list still feels the same.
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'qf',
	callback = function(args)
		local function m(lhs, rhs, desc)
			vim.keymap.set('n', lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
		end
		m('o',  '<CR>',            'Open')
		m('go', '<CR><C-w>p',      'Open, keep focus on the list')
		m('t',  '<C-w><CR><C-w>T', 'Open in a new tab')
		m('v',  '<C-w><CR><C-w>H', 'Open in a vertical split')
		m('q',  '<Cmd>close<CR>',  'Close the list')
	end,
})

-- Code actions are on the built-in `gra`, which Nvim 0.12 maps unconditionally
-- (:h lsp-defaults), so <C-f> stays page-forward.

-- Use space bar to fold code
vim.keymap.set('n', '<Space>',   'za',              { silent = true })
-- Clear the search highlight with <CR>, but leave it alone where it already has a
-- job to do: quickfix/loclist jumps and the command-line window.
vim.keymap.set('n', '<CR>', function()
	if vim.bo.buftype == 'quickfix' or vim.fn.getcmdwintype() ~= '' then return '<CR>' end
	return '<Cmd>nohlsearch<CR>'
end, { expr = true, silent = true, desc = 'Clear search highlight' })
-- Toggle to the previous buffer
vim.keymap.set('n', '<leader><leader>', '<c-^>',    { silent = true })
-- Break the arrow-key habit. <Nop> rather than :echo, which clobbered the message
-- line and could trigger a hit-enter prompt.
for _, key in ipairs({ '<Left>', '<Right>', '<Up>', '<Down>' }) do
	vim.keymap.set({ 'n', 'v', 'i' }, key, '<Nop>')
end
-- Undotree
vim.keymap.set('n', '<F5>', vim.cmd.UndotreeToggle)
-- Kill buffer and go back to previous buffer
vim.keymap.set('n', '<leader>d', ':b#<bar>bd#<CR>', { silent = true})

-- 0.12 shows no inline diagnostic text by default, so surface clangd messages in
-- a float on idle. Skip special buffers (quickfix, terminals, the Claude float).
vim.diagnostic.config({
	float = { focusable = false, border = "rounded", source = true, prefix = "" },
})
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then return end
		vim.diagnostic.open_float({ scope = "cursor" })
	end,
})

-- *.dts/*.dtsi/*.overlay already resolve to filetype "dts" natively; only the
-- fold style is ours.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dts",
	callback = function()
		vim.opt_local.foldmethod = "indent"
	end,
})

-- Keep very large files responsive. BufReadPre plus a real stat beats BufWinEnter
-- plus line2byte: it runs once per file instead of on every window entry.
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(args)
		local ok, st = pcall(vim.uv.fs_stat, args.match)
		if not (ok and st and st.size > 400000) then return end
		vim.b[args.buf].large_file = true
		vim.bo[args.buf].undofile = false
	end,
})

-- Filetype detection switches syntax back on after BufReadPre, so the
-- highlighters have to be disabled here, once the filetype is known.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if not vim.b[args.buf].large_file then return end
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(args.buf) then return end
			vim.bo[args.buf].syntax = "off"
			pcall(vim.treesitter.stop, args.buf)
		end)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	-- ".h"/".hpp" are not filetypes; headers are detected as "c"/"cpp" already
	pattern = { "c", "cpp" },
	callback = function(args)
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = "80"
		local bo = vim.bo[args.buf]
		-- Defaults first, then let .clang-format override only what it actually sets.
		bo.tabstop, bo.shiftwidth, bo.softtabstop, bo.expandtab = 4, 4, 4, true

		local found = vim.fs.find(".clang-format", { upward = true, path = vim.fn.expand("%:p:h") })[1]
		local fh = found and io.open(found, "r")
		if fh then
			-- A .clang-format may hold several "---"-separated documents, one per
			-- Language; only the C/C++ one applies here.
			local applies = true
			for line in fh:lines() do
				if line:match("^%-%-%-") then
					applies = true       -- new document: ours until a Language says otherwise
				elseif line:match("^%.%.%.") then
					applies = false
				else
					-- Top-level keys only (no leading whitespace, so nested blocks are
					-- skipped), and trailing "# comments" stripped off the value.
					local k, v = line:match("^([%w]+)%s*:%s*([^#]*)")
					if k then
						v = v:gsub("%s+$", "")
						if k == "Language" then
							applies = (v == "Cpp" or v == "ObjC")
						elseif applies then
							local n = tonumber(v)
							if     k == "IndentWidth" and n then bo.shiftwidth, bo.softtabstop = n, n
							elseif k == "TabWidth"    and n then bo.tabstop = n
							elseif k == "UseTab"            then bo.expandtab = (v == "Never")
							elseif k == "ColumnLimit" and n then bo.textwidth = n
							end
						end
					end
				end
			end
			fh:close()
		end
	end,
})


local md_group = vim.api.nvim_create_augroup("MarkdownSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = md_group,
	pattern = "markdown",
	callback = function()
		vim.opt_local.textwidth = 80
		vim.opt_local.formatoptions:append("t")
	end,
})


local function set_claude_term_bg()
	vim.api.nvim_set_hl(0, "ClaudeTermBg", { bg = "#000044" })
end
set_claude_term_bg()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_claude_term_bg })

vim.o.background     = "dark"      -- Dark theme
vim.o.number         = true        -- Add absolute line number on the left side of code
vim.o.cursorline     = true        -- Show the cursor position all the time
vim.o.shell          = "bash"      -- run :! and system() under bash regardless of $SHELL
vim.o.ignorecase     = true        -- searches are case insensitive...
vim.o.smartcase      = true        -- ... unless they contain at least one capital letter
vim.o.wrap           = false       -- don't wrap lines
vim.o.tabstop        = 4           -- Tab size
vim.o.shiftwidth     = 4           -- an autoindent (with <<) size
vim.o.expandtab      = true        -- use spaces by default, not tabs
vim.o.list           = true        -- Show invisible characters
vim.o.undofile       = true          -- Save the undo history
vim.o.autowrite      = true          -- Write the contents of the file on buffer switching
vim.o.scrolloff      = 3            -- Set context as we're scrolling
vim.o.splitright     = true        -- vertical splits open to the right, not left
vim.o.splitbelow     = true        -- horizontal splits open below, not above
vim.o.foldmethod     = 'syntax'    -- Default code folding to syntax
vim.o.foldlevelstart = 99      -- Do not fold when file is originally open
vim.o.tags           = "./.tags;,.tags"  -- ";" = keep searching upward to root
vim.o.signcolumn     = 'yes'       -- Keep clangd sign column visible even when in editing mode
vim.o.updatetime     = 2500        -- 2.5 seconds before the diagnostic float appears


-- show when tabs exists
-- show when trailing spaces exist
-- Show when line goes past the right side
-- Show when line goes past the left side
vim.o.listchars = "tab:»·,trail:◘,extends:>,precedes:<"


-- Regenerate ctags for the current directory. Kept for the trees clangd does not
-- cover (devicetree, Kconfig, Makefiles); C/C++ tag jumps go through the LSP
-- tagfunc instead.
vim.api.nvim_create_user_command('LRefreshTags', function()
	local dir = vim.fn.getcwd()
	local tagfile = dir .. '/.tags'
	vim.fn.delete(tagfile)
	-- List form runs without a shell: no glob, no quoting bugs, and dotfiles are
	-- included (the old trailing "*" silently skipped them).
	local out = vim.fn.system({ 'ctags', '-R', '--exclude=.git', '-f', tagfile, dir })
	if vim.v.shell_error ~= 0 then
		vim.notify('ctags failed: ' .. out, vim.log.levels.ERROR)
	else
		vim.notify('Wrote ' .. tagfile)
	end
end, { desc = 'Regenerate .tags for the current directory' })

-- Repo-wide search and replace using args/argdo.
-- Fixed-string grep (-F) plus \V very-nomagic keep the file list and the
-- substitution in exact agreement, so a search containing . * [ ] ~ $ ^ matches
-- itself instead of being read as a regex.
vim.keymap.set('n', '<leader>R', function()
	local search = vim.fn.input('Search: ')
	if search == '' then return end
	local replace = vim.fn.input({ prompt = 'Replace with: ', cancelreturn = vim.NIL })
	if replace == vim.NIL then return end -- empty replacement is legitimate (deletion)

	local files = vim.fn.systemlist({ 'git', 'grep', '--untracked', '-lF', '--', search })
	if vim.v.shell_error > 1 then     -- 1 just means "no matches"
		vim.notify('git grep failed (not a repository?)', vim.log.levels.ERROR)
		return
	end
	if #files == 0 then
		vim.notify('No matches for ' .. vim.inspect(search), vim.log.levels.WARN)
		return
	end

	-- Under \V only a backslash stays special; / needs escaping as the separator.
	local pat = vim.fn.escape(search, '\\/')
	local rep = vim.fn.escape(replace, '\\/&~')

	if vim.fn.argc() > 0 then vim.cmd('argdelete *') end
	vim.cmd('argadd ' .. table.concat(vim.tbl_map(vim.fn.fnameescape, files), ' '))

	-- The e flag keeps the first non-matching file from aborting the whole argdo.
	local ok, err = pcall(vim.cmd,
		('argdo %%s/\\V%s/%s/ge | if &modified | update | endif'):format(pat, rep))
	if not ok then
		vim.notify('argdo failed: ' .. tostring(err), vim.log.levels.ERROR)
		return
	end
	vim.notify(('Replaced %q with %q across %d file(s)'):format(search, replace, #files))
end, { desc = 'Repo-wide search and replace' })
