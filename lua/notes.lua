local M = {}
local notes_dir = os.getenv("OBS_PATH") or ""

-- ─────────────────────────────────────────
-- Floating window
-- ─────────────────────────────────────────

local function open_floating(file_path)
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.fn.bufnr(file_path, true)
  vim.bo[buf].buflisted = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " " .. vim.fn.fnamemodify(file_path, ":t") .. " ",
    title_pos = "center",
  })

  -- load the file into the buffer
  vim.api.nvim_win_call(win, function()
    if vim.fn.bufloaded(buf) == 0 then
      vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    end
  end)

  -- close with q or escape when in normal mode
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true, desc = "Close float" })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true, desc = "Close float" })

  return buf, win
end

-- ─────────────────────────────────────────
-- Note utilities
-- ─────────────────────────────────────────

local function create_from_template(template_name, dest_path, replacements)
  if vim.fn.filereadable(dest_path) == 1 then return end
  local template_path = notes_dir .. "99-Templates/" .. template_name .. ".md"
  local template = io.open(template_path, "r")
  if not template then
    vim.notify("Template not found: " .. template_path, vim.log.levels.ERROR)
    return
  end
  local content = template:read("*a")
  template:close()
  for key, value in pairs(replacements) do
    content = content:gsub("{{" .. key .. "}}", value)
  end
  local file = io.open(dest_path, "w")
  if not file then
    vim.notify("Could not create file: " .. dest_path, vim.log.levels.ERROR)
    return
  end
  file:write(content)
  file:close()
end

local function open_note(path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

local function slugify(title)
  return title:lower():gsub("%s+", "-"):gsub("[^%a%d%-]", "")
end

local function today()
  return os.date("%Y-%m-%d")
end

-- ─────────────────────────────────────────
-- Note actions
-- ─────────────────────────────────────────

function M.open_daily_note()
  local date = today()
  local path = notes_dir .. "04-Journal/" .. date .. ".md"
  create_from_template("template-daily-note", path, { date = date })
  open_floating(path)
end

function M.open_inbox_note()
  local path = notes_dir .. "inbox.md"
  if vim.fn.filereadable(path) == 0 then
    local file = io.open(path, "w")
    file:write("# Inbox\n\n")
    file:close()
  end
  open_floating(path)
end

-- ─────────────────────────────────────────
-- Keybindings
-- ─────────────────────────────────────────
local map = vim.keymap.set

local function setup_keymaps()
  map("n", "<leader>nf", function() 
    vim.cmd("Files " .. notes_dir)
  end, { desc = "Search files in notes" })

  map("n", "<leader>ng", function() 
    vim.cmd("NotesRg")
  end, { desc = "Search in notes" })

  map("n", "<leader>dn", M.open_daily_note,        { desc = "Open daily note" })
  map("n", "<leader>nn", M.open_inbox_note,        { desc = "Open inbox note" })
end

-- ─────────────────────────────────────────
-- Autocommands
-- ─────────────────────────────────────────
local function setup_autocommands()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.fn.argc() == 0 then
        local today_str = today()
        local today_path = notes_dir .. "04-Journal/" .. today_str .. ".md"

        -- create today's note from template if it doesn't exist
        create_from_template("template-daily-note", today_path, { date = today_str })

        -- find the most recent previous daily note
        local files = vim.fn.globpath(notes_dir .. "04-Journal", "*.md", false, true)
        table.sort(files, function(a, b) return a > b end)

        local prev_path = nil
        for _, file in ipairs(files) do
          local date_str = vim.fn.fnamemodify(file, ":t:r")
          if date_str ~= today_str then
            prev_path = file
            break
          end
        end

        -- open today's note on the left
        vim.cmd("edit " .. vim.fn.fnameescape(today_path))

        -- open previous note on the right if it exists
        if prev_path then
          vim.cmd("vsplit " .. vim.fn.fnameescape(prev_path))
          -- put cursor back on today's note on the left
          vim.cmd("wincmd h")
        end
      end
    end,
    desc = "Open today and previous daily note on startup",
  })

  vim.api.nvim_create_user_command("NotesRg", function(opts)
    vim.fn["fzf#vim#grep"](
      "rg --column --line-number --no-heading --color=always --smart-case -- " .. vim.fn.shellescape(opts.args),
      vim.fn["fzf#vim#with_preview"]({ dir = notes_dir }),
      opts.bang
    )
  end, { bang = true, nargs = "*", desc = "Grep notes" })
end

function M.setup()
  setup_keymaps()
  setup_autocommands()
end

return M
