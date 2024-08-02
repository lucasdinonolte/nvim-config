require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- LSP
map("n", "K", vim.lsp.buf.hover)

-- This is vim, we don't need arrow keys
map({ "i", "n", "v" }, "<Up>", "<Nop>")
map({ "i", "n", "v" }, "<Right>", "<Nop>")
map({ "i", "n", "v" }, "<Down>", "<Nop>")
map({ "i", "n", "v" }, "<Left>", "<Nop>")

-- Search and Replace
map({ "i", "n" }, "<leader>s", ":%s/", { desc = "Enter search and replace mode" })
map({ "i", "n" }, "<leader>ss", ":vimgrep /", { desc = "Enter search and replace mode" })

-- I don't need terminals in vim,
-- so disabling mappings to open them.
map("n", "<leader>h", "<Nop>")
map("n", "<leader>v", "<Nop>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>
