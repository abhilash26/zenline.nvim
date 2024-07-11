-- zenline.nvim

-- default options
local plugin_loaded = false
local active_sects = {}
local compute_idx = {}
local default_options = require("zenline.config")
local o = {}
local status_active = "%{%v:lua.Zenline.active()%}"
local status_inactive = "%{%v:lua.Zenline.inactive()%}"
local mode_cache = {}
local diag_cache = {}
local diff_cache = {}
local special_cache = {}
local hls = {
  ["ZenlineError"] = { link = "DiagnosticError", flip = false, txt = "%#ZenlineError#" },
  ["ZenlineWarn"] = { link = "DiagnosticWarn", flip = false, txt = "%#ZenlineWarn#" },
  ["ZenlineInfo"] = { link = "DiagnosticInfo", flip = false, txt = "%#ZenlineInfo#" },
  ["ZenlineHint"] = { link = "DiagnosticHint", flip = false, txt = "%#ZenlineHint#" },
  ["ZenlineAdd"] = { link = "SignAdd", flip = false, txt = "%#ZenlineAdd#" },
  ["ZenlineChange"] = { link = "SignChange", flip = false, txt = "%#ZenlineChange#" },
  ["ZenlineDelete"] = { link = "SignDelete", flip = false, txt = "%#ZenlineDelete#" },
  ["ZenlineNormal"] = { link = "Function", flip = true, txt = "%#ZenlineNormal#" },
  ["ZenlineInsert"] = { link = "String", flip = true, txt = "%#ZenlineInsert#" },
  ["ZenlineVisual"] = { link = "Special", flip = true, txt = "%#ZenlineVisual#" },
  ["ZenlineCmdLine"] = { link = "Constant", flip = true, txt = "%#ZenlineCmdLine#" },
  ["ZenlineReplace"] = { link = "Identifier", flip = true, txt = "%#ZenlineReplace#" },
  ["ZenlineTerminal"] = { link = "Comment", flip = true, txt = "%#ZenlineTerminal#" },
  ["ZenlineAccent"] = { link = "StatusLine", flip = false, txt = "%#ZenlineAccent#" },
}

-- Cache vim.api global
local api = vim.api

local hl_txt = function(hl)
  return hls[hl] and hls[hl].txt or string.format("%%#%s#", hl)
end

-- components
C = {}

-- mode component
C.mode = function()
  local m = api.nvim_get_mode().mode
  return mode_cache[m] or mode_cache["default"]
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
  local diag_count = vim.diagnostic.count(0)

  for level, k in pairs(diag_cache) do
    local count = diag_count[vim.diagnostic.severity[level]]
    if count then
      diag[#diag + 1] = string.format("%s%d", k, count)
    end
  end
  return table.concat(diag, " ")
end

C.git_branch = function()
  local git_branch = vim.b.gitsigns_head
  if not git_branch then return "" end
  return string.format("%s%s%s", o.components.git_branch.icon, hls["ZenlineAccent"].txt, git_branch)
end

C.git_diff = function()
  local diff = vim.b.gitsigns_status_dict
  if not diff then return "" end
  local diff_text = {}
  for type, k in pairs(diff_cache) do
    local count = diff[type]
    if count and count > 0 then
      diff_text[#diff_text + 1] = string.format("%s%s", k, count)
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
  local get_hl = api.nvim_get_hl
  local set_hl = api.nvim_set_hl
  local status = get_hl(0, { name = "StatusLine" })

  for hl, data in pairs(hls) do
    local hl_data = get_hl(0, { name = data.link })
    if data.flip then
      set_hl(0, hl, { fg = status.bg, bg = hl_data.fg })
    else
      set_hl(0, hl, { fg = hl_data.fg, bg = status.bg })
    end
  end
end

M.active = function()
  for i = 1, #compute_idx, 2 do
    local idx = compute_idx[i]
    local component = compute_idx[i + 1]
    active_sects[idx] = C[component]()
  end
  return table.concat(active_sects, " ")
end

M.inactive = function()
  status_inactive = o.sections.inactive.text
end

M.set_global_statusline = function()
  local cur_win = api.nvim_get_current_win()
  local ft = vim.bo.ft
  local ft_opts = o.special_fts[ft]
  vim.wo[cur_win].statusline = ft_opts and special_cache[ft] or status_active
end

M.set_statusline = function()
  local cur_win = api.nvim_get_current_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    if cur_win == w then
      local ft = vim.bo.ft
      local ft_opts = o.special_fts[ft]
      vim.wo[cur_win].statusline = ft_opts and special_cache[ft] or status_active
    else
      vim.wo[w].statusline = status_inactive
    end
  end
end

M.cache_mode = function()
  for key, value in pairs(o.components.mode) do
    mode_cache[key] = string.format("%s %s", hl_txt(value[1]), value[2])
  end
end

M.cache_diagnostics = function()
  for severity, t in pairs(o.components.diagnostics) do
    diag_cache[severity] = string.format("%s%s", hl_txt(t[1]), t[2])
  end
end

M.cache_git_diff = function()
  for key, value in pairs(o.components.git_diff) do
    diff_cache[key] = string.format("%s%s", hl_txt(value[1]), value[2])
  end
end

M.cache_special = function()
  local hl = hls["ZenlineAccent"].txt
  for ft, data in pairs(o.special_fts) do
    special_cache[ft] = table.concat({ hl, "%=", data[2], data[1], "%=" }, "")
  end
end

M.cache_active_sections = function()
  local no_hl = {
    mode = true,
    diagnostics = true,
    git_diff = true,
  }
  active_sects[#active_sects + 1] = hls["ZenlineAccent"].txt
  for _, pos in ipairs({ "left", "center", "right" }) do
    for _, section in ipairs(o.sections.active[pos]) do
      local component = o.components[section]
      if component then
        if not no_hl[section] then
          active_sects[#active_sects + 1] = hl_txt(component.hl)
        end
        compute_idx[#compute_idx + 1] = #active_sects + 1
        compute_idx[#compute_idx + 1] = section
        active_sects[#active_sects + 1] = ""
      end
    end
    if pos ~= "right" then
      active_sects[#active_sects + 1] = hls["ZenlineAccent"].txt
      active_sects[#active_sects + 1] = "%="
    end
  end
end

M.create_autocommands = function()
  local augroup = api.nvim_create_augroup("Zenline", { clear = true })
  local isglobal = vim.o.laststatus == 3

  -- create statusline
  api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = augroup,
    callback = isglobal and M.set_global_statusline or M.set_statusline,
    desc = "set statusline"
  })

  -- redefine highlights on colorscheme change
  api.nvim_create_autocmd({ "ColorScheme" }, {
    group = augroup,
    callback = M.define_highlights,
    desc = "define highlights"
  })
end

-- setup function
M.setup = function(opts)
  -- return if setup has already taken place
  if plugin_loaded then return else plugin_loaded = true end
  -- exporting the module
  _G.Zenline = M
  M.merge_config(opts)
  M.define_highlights()
  -- perf: set cache to improve performance
  M.cache_mode()
  M.cache_diagnostics()
  M.cache_git_diff()
  M.cache_active_sections()
  M.cache_special()
  M.create_autocommands()
  -- set statusline
  vim.g.statusline = status_active
end

return M
