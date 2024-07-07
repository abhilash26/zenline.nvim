-- zenline.nvim

-- default options
local plugin_loaded = false
local active_sections = {}
local compute_indicies = {}
local default_options = require("lua.zenline.default_options")
local devicons = require('nvim-web-devicons')
local o = {}
local status_active = "%{%v:lua.Zenline.active()%}"
local status_inactive = "%{%v:lua.Zenline.inactive()%}"
local diagnostic_cache = {}

local get_hl = function(hl)
  return string.format("%%#%s#", hl)
end

local flip_hl = function(hl)
  local hl_data = vim.api.nvim_get_hl(0, { name = hl })
  return {
    fg = hl_data.bg,
    bg = hl_data.fg,
  }
end

-- components
C = {}

-- mode component
C.mode = function()
  local m = vim.api.nvim_get_mode().mode
  local mode_info = o.components.mode[m] or o.components.mode.default
  return string.format("%%#%s# %s", mode_info[1], mode_info[2])
end

C.file_name = function()
  local fo = o.components.file_name
  local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), fo.mod)
  local modified = vim.bo.mod and fo.modified or ""
  local readonly = vim.bo.readonly and fo.readonly or ""
  return string.format("%s%s%s", fpath, modified, readonly)
end

C.file_type = function()
  return vim.bo.filetype
end

C.file_icon = function()
  local icon, _ = devicons.get_icon(vim.fn.expand("%:t"), nil, { default = true })
  return icon
end

C.diagnostics = function()
  local diag = {}

  for level, k in pairs(diagnostic_cache) do
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[level] })
    if count > 0 then
      diag[#diag + 1] = string.format("%s%d", k, count)
    end
  end
  return table.concat(diag, " ")
end

C.line_column = function()
  return o.components.line_column.text
end

M = {}

M.merge_config = function(opts)
  -- prefer users config over default
  o = vim.tbl_deep_extend("force", default_options, opts or {})
end

M.define_highlights = function()
  local hls = {
    ["ZenLineNormal"] = "Function",
    ["ZenLineInsert"] = "String",
    ["ZenLineVisual"] = "Special",
    ["ZenLineCmdLine"] = "Constant",
    ["ZenLineReplace"] = "Identifier",
    ["ZenLineTerminal"] = "Comment",
  }
  local status = vim.api.nvim_get_hl(0, { name = "StatusLine" })
  for hl, link in pairs(hls) do
    local hl_data = flip_hl(link)
    vim.api.nvim_set_hl(0, hl, { fg = status.bg, bg = hl_data.bg })
  end
  vim.api.nvim_set_hl(0, "ZenLineAccent", { link = "StatusLine" })
end

M.active = function()
  for i = 1, #compute_indicies, 2 do
    local idx = compute_indicies[i]
    local component = compute_indicies[i + 1]
    active_sections[idx] = C[component]()
  end
  return table.concat(active_sections, " ")
end

M.inactive = function()
  status_inactive = o.sections.inactive.text
end

M.set_global_statusline = vim.schedule_wrap(function()
  local cur_win = vim.api.nvim_get_current_win()
  vim.wo[cur_win].statusline = status_active
end)

M.set_statusline = vim.schedule_wrap(function()
  local cur_win = vim.api.nvim_get_current_win()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if cur_win == w then
      vim.wo[w].statusline = status_active
    elseif vim.api.nvim_buf_get_name(0) ~= "" then
      vim.wo[w].statusline = status_inactive
    end
  end
end)

M.cache_diagnostics = function()
  for severity, t in pairs(o.components.diagnostics) do
    diagnostic_cache[severity] = string.format("%s%s", get_hl(t[1]), t[2])
  end
end

M.cache_active_sections = function()
  local no_hl = {
    "mode",
    "diagnostics",
    "file_icon"
  }
  for _, pos in ipairs({ "left", "center", "right" }) do
    for _, section in ipairs(o.sections.active[pos]) do
      local component = o.components[section]
      if component then
        local no_hl_lookup = {}
        for _, v in ipairs(no_hl) do
          no_hl_lookup[v] = true
        end

        if not no_hl_lookup[section] then
          table.insert(active_sections, get_hl(component.hl))
        end
        table.insert(compute_indicies, #active_sections + 1)
        table.insert(compute_indicies, section)
        table.insert(active_sections, "")
      end
    end
    if pos ~= "right" then
      table.insert(active_sections, get_hl("ZenLineAccent"))
      table.insert(active_sections, "%=")
    end
  end
end

M.create_autocommands = function()
  local augroup = vim.api.nvim_create_augroup("Zenline", { clear = true })
  local is_global = (vim.o.laststatus == 3)

  -- create statusline
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = augroup,
    callback = is_global and M.set_global_statusline or M.set_statusline,
    desc = "set statusline"
  })

  -- redefine highlights on colorscheme change
  vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    group = augroup,
    callback = vim.schedule_wrap(function()
      M.define_highlights()
    end),
    desc = "define highlights"
  })
end

-- setup function
M.setup = function(opts)
  -- return if setup has already taken place
  if plugin_loaded then return end
  table.insert(active_sections, get_hl("ZenLineAccent"))
  -- exporting the module
  _G.Zenline = M
  M.merge_config(opts)
  M.define_highlights()
  M.cache_diagnostics()
  M.cache_active_sections()
  M.create_autocommands()
end

return M
