-- zenline.nvim

-- default options
local plugin_loaded = false
local sects = {}
local hls = {}
local default_options = require("zenline.config")
local status_active = "%{%v:lua.Zenline.active()%}"
local status_inactive = "%{%v:lua.Zenline.inactive()%}"
local cache_idx = {}
local cache_mode = {}
local cache_diag = {}
local cache_diff = {}
local cache_special = {}
local comp = {}
local zenhl = ""

-- Cache vim.api global
local api = vim.api
local o = default_options
local bo = vim.bo
local diagnostic = vim.diagnostic

local hl_txt = function(hl)
  return hls[hl] and hls[hl].txt or string.format("%%#%s#", hl)
end

-- components
C = {}

-- mode component
C.mode = function()
  local m = api.nvim_get_mode().mode
  return cache_mode[m] or cache_mode["default"]
end

C.file_name = function()
  local fo = comp.file_name
  local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), fo.mod)
  local modified = bo.mod and fo.modified or ""
  local readonly = bo.readonly and fo.readonly or ""
  return string.format("%s%s%s", fpath, modified, readonly)
end

C.file_type = function()
  return bo.filetype
end

C.diagnostics = function()
  local diag = {}
  local count_diag = diagnostic.count(0)

  for level, k in pairs(cache_diag) do
    local count = count_diag[diagnostic.severity[level]]
    if count then
      diag[#diag + 1] = string.format("%s%d", k, count)
    end
  end
  return table.concat(diag, " ")
end

C.git_branch = function()
  local git_branch = vim.b.gitsigns_head
  return git_branch
      and string.format("%s%s%s", comp.git_branch.icon, zenhl, git_branch)
    or ""
end

C.git_diff = function()
  local diff = vim.b.gitsigns_status_dict
  if not diff then
    return ""
  end
  local diff_text = {}
  for type, k in pairs(cache_diff) do
    local count = diff[type]
    if count and count > 0 then
      diff_text[#diff_text + 1] = string.format("%s%s", k, count)
    end
  end
  return table.concat(diff_text, " ")
end

C.line_column = function()
  return comp.line_column.text
end

M = {}

M.merge_config = function(opts)
  -- prefer users config over default
  o = vim.tbl_deep_extend("force", default_options, opts or {})
  comp = o.components
end

M.define_highlights = function()
  local get_hl = api.nvim_get_hl
  local set_hl = api.nvim_set_hl
  local status = get_hl(0, { name = "StatusLine" })
  hls = {
    ["ZenlineError"] = { link = "DiagnosticError", flip = false },
    ["ZenlineWarn"] = { link = "DiagnosticWarn", flip = false },
    ["ZenlineInfo"] = { link = "DiagnosticInfo", flip = false },
    ["ZenlineHint"] = { link = "DiagnosticHint", flip = false },
    ["ZenlineAdd"] = { link = "SignAdd", flip = false },
    ["ZenlineChange"] = { link = "SignChange", flip = false },
    ["ZenlineDelete"] = { link = "SignDelete", flip = false },
    ["ZenlineNormal"] = { link = "Function", flip = true },
    ["ZenlineInsert"] = { link = "String", flip = true },
    ["ZenlineVisual"] = { link = "Special", flip = true },
    ["ZenlineCmdLine"] = { link = "Constant", flip = true },
    ["ZenlineReplace"] = { link = "Identifier", flip = true },
    ["ZenlineTerminal"] = { link = "Comment", flip = true },
    ["ZenlineAccent"] = { link = "StatusLine", flip = false },
  }
  for hl, data in pairs(hls) do
    local hl_data = get_hl(0, { name = data.link })
    if data.flip then
      set_hl(0, hl, { fg = status.bg, bg = hl_data.fg })
    else
      set_hl(0, hl, { fg = hl_data.fg, bg = status.bg })
    end
    hls[hl].txt = string.format("%%#%s#", hl)
  end
  zenhl = "%#ZenlineAccent#"
end

M.active = function()
  for i = 1, #cache_idx, 2 do
    local idx = cache_idx[i]
    local component = cache_idx[i + 1]
    sects[idx] = C[component]()
  end
  return table.concat(sects, " ")
end

M.inactive = function()
  status_inactive = o.sections.inactive.text
end

M.set_global_statusline = function()
  local cur_win = api.nvim_get_current_win()
  local ft = vim.bo.ft
  local ft_opts = o.special_fts[ft]
  vim.wo[cur_win].statusline = ft_opts and cache_special[ft] or status_active
end

M.set_statusline = function()
  local cur_win = api.nvim_get_current_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    if cur_win == w then
      local ft = vim.bo.ft
      local ft_opts = o.special_fts[ft]
      vim.wo[cur_win].statusline = ft_opts and cache_special[ft]
        or status_active
    else
      vim.wo[w].statusline = status_inactive
    end
  end
end

M.cache_components = function()
  local no_hl = { mode = true, diagnostics = true, git_diff = true }
  sects = { zenhl }

  -- cache mode
  for mkey, m in pairs(comp.mode) do
    cache_mode[mkey] = string.format("%s %s", hl_txt(m[1]), m[2])
  end
  -- cache diagnostics
  for severity, t in pairs(comp.diagnostics) do
    cache_diag[severity] = string.format("%s%s", hl_txt(t[1]), t[2])
  end
  -- cache git_diff
  for key, v in pairs(comp.git_diff) do
    cache_diff[key] = string.format("%s%s", hl_txt(v[1]), v[2])
  end
  -- cache special_fts
  for ft, d in pairs(o.special_fts) do
    cache_special[ft] = table.concat({ zenhl, "%=", d[2], d[1], "%=" }, "")
  end
  -- cache active sections
  for _, pos in ipairs({ "left", "center", "right" }) do
    for _, sec in ipairs(o.sections.active[pos]) do
      local c = comp[sec]
      if c then
        if not no_hl[sec] then
          sects[#sects + 1] = hl_txt(c.hl)
        end
        cache_idx[#cache_idx + 1] = #sects + 1
        cache_idx[#cache_idx + 1] = sec
        sects[#sects + 1] = ""
      end
    end
    if pos ~= "right" then
      sects[#sects + 1] = zenhl
      sects[#sects + 1] = "%="
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
    desc = "set statusline",
  })
  -- redefine highlights on colorscheme change
  api.nvim_create_autocmd({ "ColorScheme" }, {
    group = augroup,
    callback = M.define_highlights,
    desc = "define highlights",
  })
end

-- setup function
M.setup = function(opts)
  -- return if setup has already taken place
  if plugin_loaded then
    return
  end
  -- exporting the module
  _G.Zenline = M
  M.merge_config(opts)
  M.define_highlights()
  -- perf: set cache to improve performance
  M.cache_components()
  M.create_autocommands()
  -- set statusline
  vim.g.statusline = status_active
  plugin_loaded = true
end

return M
