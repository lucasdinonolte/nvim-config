local M = {}

function M.grep_git_or_rg()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  local opts = { options = { "--delimiter=:", "--nth=2.." } }
  if vim.v.shell_error == 0 and git_root ~= "" then
    opts.dir = git_root
    vim.fn["fzf#vim#grep"](
      "git grep --line-number -- ''",
      vim.fn["fzf#vim#with_preview"](opts),
      0
    )
  else
    vim.fn["fzf#vim#grep"](
      "rg --column --line-number --no-heading --color=always --smart-case -- ''",
      vim.fn["fzf#vim#with_preview"](opts),
      0
    )
  end
end

function M.setup_keymaps()
  vim.keymap.set("n", "<Leader>ff", "<Cmd>Files<CR>", { desc = "Find files" })
  vim.keymap.set("n", "<Leader>gg", M.grep_git_or_rg, { desc = "Search project" })
end

function M.setup()
  M.setup_keymaps()
end

return M
