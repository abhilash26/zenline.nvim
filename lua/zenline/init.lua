local default_cfg = require("zenline.options")
local comp = require("zenline.components")
local utils = require("zenline.utils")

local api = vim.api
local g = vim.g
local o = vim.o
local wo = vim.wo

local M = {}

local active_status = "%{%v:lua.Zenline.active()%}"
local inactive_status = "%{%v:lua.Zenline.inactive()%}"

local cfg = {}
local active_sections = {}
local comp_indices = {}
local plugin_loaded = false

-- Setup function
M.setup = function(opts)
  if plugin_loaded then return end
  _G.Zenline = M
  M.init_config(opts)
  M.define_hl()
  M.cache_active()
  M.cache_inactive()
  M.create_autocmds()
  M.remove_qf_statusline()
  plugin_loaded = true
  vim.go.statusline = active_status
end

-- Initialize configuration
M.init_config = function(opts)
  cfg = vim.tbl_deep_extend("force", default_cfg, opts or {})
end

-- Remove QuickFix statusline
M.remove_qf_statusline = function()
  g.qf_disable_statusline = 1
end

-- Define highlights
M.define_hl = function()
  local set_hl = api.nvim_set_hl
  local flip_hl = utils.flip_hl

  local status = api.nvim_get_hl(0, { name = "StatusLine" })

  local hl_groups = {
    ZenLineAccent = "StatusLine",
    ZenLineNormalAccent = flip_hl("Function"),
    ZenLineVisualAccent = flip_hl("Special"),
    ZenLineInsertAccent = flip_hl("String"),
    ZenLineReplaceAccent = flip_hl("Identifier"),
    ZenLineCmdLineAccent = flip_hl("Constant"),
    ZenLineTerminalAccent = flip_hl("Comment"),
    ZenLineInactive = "StatusLine"
  }

  for name, hl in pairs(hl_groups) do
    if type(hl) == "table" then
      set_hl(0, name, { fg = status.bg, bg = hl.bg })
    else
      set_hl(0, name, { link = hl })
    end
  end
end

-- Cache active sections
M.cache_active = function()
  local sections = cfg.sections.active

  for _, pos in ipairs({ "left", "center", "right" }) do
    for _, section in ipairs(sections[pos]) do
      table.insert(active_sections, "")
      table.insert(comp_indices, #active_sections)
      table.insert(comp_indices, section)
    end
    if pos ~= "right" then
      table.insert(active_sections, comp.section_separator())
    end
  end
end

-- Cache inactive status
M.cache_inactive = function()
  inactive_status = M.inactive()
end

-- Set correct statusline
M.set_statusline = vim.schedule_wrap(function()
  local win = api.nvim_get_current_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    if w == win then
      wo[w].statusline = active_status
    elseif api.nvim_buf_get_name(0) ~= "" then
      wo[w].statusline = inactive_status
    end
  end
end)

-- Set global statusline
M.global_statusline = vim.schedule_wrap(function()
  local win = api.nvim_get_current_win()
  wo[win].statusline = active_status
end)

-- Create autocommands
M.create_autocmds = function()
  local augroup = api.nvim_create_augroup("Zenline", { clear = true })
  local is_global = (o.laststatus == 3)

  if is_global then
    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      group = augroup,
      callback = M.set_statusline,
      desc = "Set global statusline"
    })
  else
    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      group = augroup,
      callback = M.set_statusline,
      desc = "Set correct statusline"
    })
  end

  api.nvim_create_autocmd({ "ColorScheme" }, {
    group = augroup,
    callback = M.define_hl,
    desc = "Update highlights"
  })
end

-- Active statusline function
M.active = function()
  for i = 1, #comp_indices, 2 do
    local idx = comp_indices[i]
    local section = comp_indices[i + 1]
    active_sections[idx] = comp[section]()
  end
  return table.concat(active_sections, " ")
end

-- Inactive statusline function
M.inactive = function()
  local section = cfg.sections.inactive
  return string.format("%s%s", utils.get_hl(section.hl), section.text)
end

return M
