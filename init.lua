-- Basic settings
vim.opt.number = true                              -- Line numbers
vim.opt.relativenumber = true                      -- Relative line numbers
vim.opt.cursorline = true                          -- Highlight current line
vim.opt.wrap = false                               -- Don't wrap lines
vim.opt.scrolloff = 10                             -- Keep 10 lines above/below cursor 
vim.opt.sidescrolloff = 8                          -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2                                -- Tab width
vim.opt.shiftwidth = 2                             -- Indent width
vim.opt.softtabstop = 2                            -- Soft tab stop
vim.opt.expandtab = true                           -- Use spaces instead of tabs
vim.opt.smartindent = true                         -- Smart auto-indenting
vim.opt.autoindent = true                          -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true                          -- Case insensitive search
vim.opt.smartcase = true                           -- Case sensitive if uppercase in search
vim.opt.hlsearch = true                            -- Highlight search results 
vim.opt.incsearch = true                           -- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true                       -- Enable 24-bit colors
vim.opt.signcolumn = "yes"                         -- Always show sign column
vim.opt.colorcolumn = "100"                        -- Show column at 100 characters
vim.opt.showmatch = true                           -- Highlight matching brackets
vim.opt.matchtime = 2                              -- How long to show matching bracket
vim.opt.cmdheight = 1                              -- Command line height
vim.opt.showmode = false                           -- Don't show mode in command line 
vim.opt.pumheight = 10                             -- Popup menu height 
vim.opt.conceallevel = 0                           -- Don't hide markup 
vim.opt.concealcursor = ""                         -- Don't hide cursor line markup 
vim.opt.lazyredraw = true                          -- Don't redraw during macros
vim.opt.synmaxcol = 300                            -- Syntax highlighting limit
vim.opt.winborder = 'rounded'                      -- Rounded corners for all floating windows

-- Behavior settings
vim.opt.hidden = true                              -- Allow hidden buffers
vim.opt.errorbells = false                         -- No error bells
vim.opt.backspace = "indent,eol,start"             -- Better backspace behavior
vim.opt.autochdir = false                          -- Don't auto change directory
vim.opt.iskeyword:append("-")                      -- Treat dash as part of word
vim.opt.path:append("**")                          -- include subdirectories in search
vim.opt.selection = "exclusive"                    -- Selection behavior
vim.opt.mouse = "a"                                -- Enable mouse support
vim.opt.clipboard:append("unnamedplus")            -- Use system clipboard
vim.opt.modifiable = true                          -- Allow buffer modifications
vim.opt.encoding = "UTF-8"                         -- Set encoding

-- Split behavior
vim.opt.splitbelow = true                          -- Horizontal splits go below
vim.opt.splitright = true                          -- Vertical splits go right

-- Filetree
vim.g.netrw_liststyle = 3                          -- Tree View
vim.g.netrw_banner = 0                             -- Remove netrw banner


-- ============================================================================
-- SHORTCUTS
-- ============================================================================
local map = vim.keymap.set

-- Key mappings
vim.g.mapleader = " "                              -- Set leader key to space
vim.g.maplocalleader = "\\"                        -- Set local leader key (NEW)

-- Clear highlights
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

-- Toggle to relative line number
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })

-- Search and Replace
map({ "n" }, "<leader>s", ":%s/", { desc = "Enter search and replace mode" })
map({ "n" }, "<leader>ss", ":vimgrep /", { desc = "Enter search and replace mode" })

-- Quick file navigation
map("n", "<C-n>", ":Oil --float<CR>", { desc = "Open file explorer" })

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- ============================================================================
-- STATUSLINE
-- ============================================================================

-- Git branch function
local function git_branch()
  local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
  if branch ~= "" then
    return " │ " .. branch .. ""
  end
  return ""
end

-- Git status
local function git_status()
  local file = vim.fn.expand("%:p")  -- Get the full path of the current file
  local status = vim.fn.system("git status --porcelain " .. file .. " 2>/dev/null")

  if status ~= "" then
    return " │ " .. status:sub(1, 2):lower()
  end

  return ""
end

-- LSP status
local function lsp_status()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    end
    local it = vim.iter(attached_clients)
    it:map(function (client)
        local name = client.name:gsub("language.server", "ls")
        return name
    end)
    local names = it:totable()
    return "[" .. table.concat(names, ", ") .. "]"
end
-- Mode indicator
local function mode_icon()
  local mode = vim.fn.mode()
  return mode:upper()
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.git_status = git_status
_G.lsp_status = lsp_status

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
  vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
    callback = function()
    vim.opt_local.statusline = table.concat {
      "  ",
      "%#StatusLineBold#",
      " %{v:lua.mode_icon()} ",
      "%#StatusLine#",
      "%{v:lua.git_branch()}",
      "%{v:lua.git_status()}",
      " │ %f %h%m%r",
      " │ %{strlen(&ft)?&ft[0].&ft[1:]:'None'}", -- file type
      " │ %{v:lua.lsp_status()}",
      "%=",                     -- Right-align everything after this
      " │ %l:%c  %P ",             -- Line:Column and Percentage
    }
    end
  })
  vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

  vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
    callback = function()
      vim.opt_local.statusline = "  %f %h%m%r │ %{strlen(&ft)?&ft[0].&ft[1:]:'None'} | %=  %l:%c   %P "
    end
  })
end

setup_dynamic_statusline()

-- ============================================================================
-- LSP Integration
-- ============================================================================
-- Enable the needed LSPs here, make sure they are installed on
-- your machine.
--
-- The config for each lsp lives in ~/.config/nvim/lsp/name_of_lsp.lua
vim.lsp.enable('lua_ls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('astro')
vim.lsp.enable('cssls')
vim.lsp.enable('css_variables')
vim.lsp.enable('cssmodules_ls')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local opts = { buffer = event.buf }
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- LSP Keybindings
    -- Navigation
    map("n", "gD", vim.lsp.buf.declaration, opts, "Go to declaration")
    map("n", "gd", vim.lsp.buf.definition, opts, "Go to definition")

    -- Information
    map('n', 'K', vim.lsp.buf.hover, opts)

    -- Code actions
    map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    map('n', '<leader>rn', vim.lsp.buf.rename, opts)

    -- Configure autocomplete
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
      vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
      vim.keymap.set('i', '<C-Space>', function()
        vim.lsp.completion.get()
      end)
    end
  end,
})

-- Diagnostics
vim.diagnostic.config({
  virtual_text = true
})

-- ===========================================================================
-- Autocommands
-- ===========================================================================
-- Prevent editing of things inside of node_modules
vim.api.nvim_create_autocmd("BufNew", {
    pattern = {
        "node_modules/**",
    },
    callback = function(event)
        vim.bo[event.buf].modifiable = false
    end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exists
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- ===========================================================================
-- Plugins
-- ===========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
{
  "navarasu/onedark.nvim",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('onedark').setup {
      style = 'deep'
    }
    require('onedark').load()
  end
},
  {
    'stevearc/oil.nvim',
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true
      }
    },
    lazy = false,
  },
  {
        "https://github.com/junegunn/fzf.vim",
        dependencies = {
            "https://github.com/junegunn/fzf",
        },
        keys = {
            { "<Leader>ff", "<Cmd>Files<CR>", desc = "Find files" },
            { "<Leader>fb", "<Cmd>Buffers<CR>", desc = "Find buffers" },
            { "<Leader>fw", "<Cmd>Rg<CR>", desc = "Search project" },
        },
    },
})

require("oil").setup()
