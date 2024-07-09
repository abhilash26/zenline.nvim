-- zenline.nvim

-- default options
local plugin_loaded = false
local active_sections = {}
local compute_indicies = {}
local default_options = require("zenline.default_options")
local o = {}
local status_active = "%{%v:lua.Zenline.active()%}"
local status_inactive = "%{%v:lua.Zenline.inactive()%}"
local diagnostic_cache = {}
local git_diff_cache = {}

-- Cache vim.api global
local api = vim.api

local get_hl = function(hl)
  return string.format("%%#%s#", hl)
end

local flip_hl = function(hl)
  local hl_data = api.nvim_get_hl(0, { name = hl })
  return {
    fg = hl_data.bg,
    bg = hl_data.fg,
  }
end

-- components
C = {}

-- mode component
C.mode = function()
  local m = api.nvim_get_mode().mode
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

C.git_branch = function()
  local git_branch = vim.b.gitsigns_head
  if not git_branch then
    return ""
  end
  return string.format("%s%s%s", o.components.git_branch.icon, get_hl("ZenLineAccent"), git_branch)
end

C.git_diff = function()
  local diff = vim.b.gitsigns_status_dict
  if not diff then
    return ""
  end
  local diff_text = {}
  for key, _ in pairs(o.components.git_diff) do
    local count = diff[key]
    if count and count > 0 then
      table.insert(diff_text, string.format("%s%s", git_diff_cache[key], count))
    end
  end
  return table.concat(diff_text, " ")
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
  local status = api.nvim_get_hl(0, { name = "StatusLine" })

  local hls = {
    ["ZenlineError"] = "DiagnosticError",
    ["ZenlineWarn"] = "DiagnosticWarn",
    ["ZenlineInfo"] = "DiagnosticInfo",
    ["ZenlineHint"] = "DiagnosticHint",
    ["ZenlineAdd"] = "SignAdd",
    ["ZenlineChange"] = "SignChange",
    ["ZenlineDelete"] = "SignDelete",
  }

  local flip_hls = {
    ["ZenLineNormal"] = "Function",
    ["ZenLineInsert"] = "String",
    ["ZenLineVisual"] = "Special",
    ["ZenLineCmdLine"] = "Constant",
    ["ZenLineReplace"] = "Identifier",
    ["ZenLineTerminal"] = "Comment",
  }

  for hl, link in pairs(hls) do
    local hl_data = api.nvim_get_hl(0, { name = link })
    api.nvim_set_hl(0, hl, { fg = hl_data.fg, bg = status.bg })
  end

  for hl, link in pairs(flip_hls) do
    local hl_data = flip_hl(link)
    api.nvim_set_hl(0, hl, { fg = status.bg, bg = hl_data.bg })
  end

  api.nvim_set_hl(0, "ZenLineAccent", { link = "StatusLine" })
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
  local cur_win = api.nvim_get_current_win()
  vim.wo[cur_win].statusline = status_active
end)

M.set_statusline = vim.schedule_wrap(function()
  local cur_win = api.nvim_get_current_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    if cur_win == w then
      vim.wo[w].statusline = status_active
    elseif api.nvim_buf_get_name(0) ~= "" then
      vim.wo[w].statusline = status_inactive
    end
  end
end)

M.cache_diagnostics = function()
  for severity, t in pairs(o.components.diagnostics) do
    diagnostic_cache[severity] = string.format("%s%s", get_hl(t[1]), t[2])
  end
end

M.cache_git_diff = function()
  for key, value in pairs(o.components.git_diff) do
    git_diff_cache[key] = string.format("%s%s", get_hl(value[1]), value[2])
  end
end

M.cache_active_sections = function()
  local no_hl = {
    "mode",
    "diagnostics",
    "git_diff",
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
  local augroup = api.nvim_create_augroup("Zenline", { clear = true })
  local is_global = (vim.o.laststatus == 3)

  -- create statusline
  api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = augroup,
    callback = is_global and M.set_global_statusline or M.set_statusline,
    desc = "set statusline"
  })

  -- redefine highlights on colorscheme change
  api.nvim_create_autocmd({ "ColorScheme" }, {
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
  if plugin_loaded then return else plugin_loaded = true end
  table.insert(active_sections, get_hl("ZenLineAccent"))
  -- exporting the module
  _G.Zenline = M
  M.merge_config(opts)
  M.define_highlights()
  M.cache_diagnostics()
  M.cache_git_diff()
  M.cache_active_sections()
  M.create_autocommands()
end

return M
