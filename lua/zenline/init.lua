-- Zenline

local default_config = require("zenline.options")
local components = require("zenline.components")

local api = vim.api
local g = vim.g
local o = vim.o
local wo = vim.wo

local M = {}

local active_status = "%{%v:lua.Zenline.active()%}"
local inactive_status = "%{%v:lua.Zenline.active()%}"

local config = {}

M.setup = function(opts)
  -- Export Module
  _G.Zenline = M
  -- Setup Config
  M.setup_config(opts)
  -- Define Highlights
  M.define_highlights()
  -- Create Autocommands
  M.create_autocmds()
  M.fix_annoyance()
end

M.setup_config = function(opts)
  config = vim.tbl_deep_extend("force", default_config, opts or {})
  o.laststatus = config.global and 3 or 2
end

M.fix_annoyance = function()
  -- Remove QuickFix Statusline
  g.qf_disable_statusline = 1
end

M.define_highlights = function()
  -- Get the default colors from common highlight groups
  local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  local string_hl = vim.api.nvim_get_hl(0, { name = "String", link = false })
  local keyword_hl = vim.api.nvim_get_hl(0, { name = "Keyword", link = false })

  local normal_fg = normal_hl.fg
  local normal_bg = normal_hl.bg
  local comment_fg = comment_hl.fg
  local string_fg = string_hl.fg
  local keyword_fg = keyword_hl.fg

  -- Define new highlights using the fetched colors
  local highlights = {
    ZenLineAccent = { fg = normal_fg, bg = normal_bg },
    ZenLineVisualAccent = { fg = comment_fg, bg = normal_bg },
    ZenLineInsertAccent = { fg = string_fg, bg = normal_bg },
    ZenLineReplaceAccent = { fg = keyword_fg, bg = normal_bg },
    ZenLineCmdLineAccent = { fg = keyword_fg, bg = normal_bg },
    ZenLineTerminalAccent = { fg = string_fg, bg = normal_bg }
  }

  for name, attributes in pairs(highlights) do
    api.nvim_set_hl(0, name, attributes)
  end
end

M.set_correct_statusline = vim.schedule_wrap(function()
  local current_win = api.nvim_get_current_win()
  local is_global_stl = o.laststatus == 3
  if is_global_stl then
    wo[current_win].statusline = active_status
  else
    for _, win in ipairs(api.nvim_list_wins()) do
      wo[win].statusline = (win == current_win) and active_status or inactive_status
    end
  end
end)

M.create_autocmds = function()
  local augroup = api.nvim_create_augroup("Zenline", {})

  -- Ensure correct statusline on window changes
  api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = augroup,
    callback = M.set_correct_statusline,
    desc = "set Correct Statusline"
  })
end

M.active = function()
  -- Declare active_sections as a local variable
  local active_sections = {}
  local config_sections = config.sections

  active_sections[#active_sections + 1] = components.startblock()

  -- Ensure options.sections exists before iterating
  for _, section in ipairs(config_sections) do
    local component = components[section]
    if component then
      active_sections[#active_sections + 1] = component()
    else
      active_sections[#active_sections + 1] = section
    end
  end

  active_sections[#active_sections + 1] = components.endblock()

  -- Return the concatenated active sections or a default value if empty
  return #active_sections > 0 and table.concat(active_sections, " ") or ""
end

return M
