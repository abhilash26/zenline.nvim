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
local active_sections = {}
local component_indices = {}

M.setup = function(opts)
  -- Export Module
  _G.Zenline = M
  -- Setup Config
  M.setup_config(opts)
  -- Define Highlights
  M.define_highlights()
  -- Initiate Active Sections Caching
  M.cache_active_sections()
  -- Create Autocommands
  M.create_autocmds()
  M.fix_annoyance()
end

M.setup_config = function(opts)
  config = vim.tbl_deep_extend("force", default_config, opts or {})
end

M.fix_annoyance = function()
  -- Remove QuickFix Statusline
  g.qf_disable_statusline = 1
end

M.define_highlights = function()
  -- Get the default colors from common highlight groups
  local utils = require("zenline.utils")
  local flip_hl = utils.flip_hl

  local status = vim.api.nvim_get_hl(0, { name = "StatusLine" })

  local highlights = {
    ZenLineAccent = "StatusLine",
    ZenLineNormalAccent = flip_hl("Function"),
    ZenLineVisualAccent = flip_hl("Special"),
    ZenLineInsertAccent = flip_hl("String"),
    ZenLineReplaceAccent = flip_hl("Identifier"),
    ZenLineCmdLineAccent = flip_hl("Constant"),
    ZenLineTerminalAccent = flip_hl("Comment"),
  }
  for name, hl in pairs(highlights) do
    if type(hl) == "table" then
      api.nvim_set_hl(0, name, { fg = status.bg, bg = hl.bg })
    else
      api.nvim_set_hl(0, name, { link = hl })
    end
  end
end


M.cache_active_sections = function()
  local config_sections = config.sections

  -- Add start block
  table.insert(active_sections, components.startblock())

  -- Add left sections and save indices
  for _, section in ipairs(config_sections.left) do
    table.insert(active_sections, "")
    table.insert(component_indices, #active_sections)
    table.insert(component_indices, section)
  end

  -- Add center alignment
  table.insert(active_sections, components.section_separator())

  -- Add center sections and save indices
  for _, section in ipairs(config_sections.center) do
    table.insert(active_sections, "")
    table.insert(component_indices, #active_sections)
    table.insert(component_indices, section)
  end

  -- Add right alignment
  table.insert(active_sections, components.section_separator())

  -- Add right sections and save indices
  for _, section in ipairs(config_sections.right) do
    table.insert(active_sections, "")
    table.insert(component_indices, #active_sections)
    table.insert(component_indices, section)
  end

  -- Add end block
  table.insert(active_sections, components.endblock())
end

M.set_correct_statusline = vim.schedule_wrap(function()
  local win = api.nvim_get_current_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    if w == win then
      wo[win].statusline = active_status
    else
      wo[win].statusline = (api.nvim_buf_get_name(0) ~= "") and active_status or inactive_status
    end
  end
end)

M.global_statusline = vim.schedule_wrap(function()
  local win = api.nvim_get_current_win()
  wo[win].statusline = active_status
end)

M.create_autocmds = function()
  local augroup = api.nvim_create_augroup("Zenline", { clear = true })

  local global_statusline = (o.laststatus == 3)

  if global_statusline then
    -- Set Global statusline
    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      group = augroup,
      callback = function()
        M.set_correct_statusline()
      end,
      desc = "Set global statusline"
    })
  else
    -- Ensure correct statusline on window changes
    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      group = augroup,
      callback = function()
        M.set_correct_statusline()
      end,
      desc = "Set correct statusline"
    })
  end

  -- Update Highlights
  api.nvim_create_autocmd({ "ColorScheme" }, {
    group = augroup,
    callback = M.define_highlights,
    desc = "Update highlights"
  })
end

M.active = function()
  for i = 1, #component_indices, 2 do
    local index = component_indices[i]
    local section = component_indices[i + 1]
    active_sections[index] = components[section]()
  end

  return table.concat(active_sections, " ")
end

return M
