local opt = require("zenline.options")
local components = {}
local H = {}

-- Helper Functions


H.get_hl = function(hl)
  return string.format("%%#%s#", hl)
end

------------------------------------------------------------------------

-- Cache

local api = vim.api
local bo = vim.bo
local diagnostic = vim.diagnostic
local fn = vim.fn
local get_hl = H.get_hl

-- Components --
components.startblock = function()
  return string.format("%s%s", get_hl(opt.startblock[1]), opt.startblock[2])
end

components.endblock = function()
  return string.format("%s%s", get_hl(opt.endblock[1]), opt.endblock[2])
end

-- Mode
components.mode = function()
  local current_mode = api.nvim_get_mode().mode
  local mode_info = opt.modes[current_mode]
  if not mode_info then
    return ""
  end
  local mode_hl = mode_info[1]
  local mode_text = mode_info[2]
  return string.format("%s %s ", get_hl(mode_hl), mode_text)
end

-- File Path
components.filepath = function()
  local filepath_mod = opt.filepath.mod
  local filepath_hl = get_hl(opt.filepath.hl)
  local fpath = fn.fnamemodify(fn.expand("%"), filepath_mod[1])
  local fname = fn.expand(filepath_mod[2])

  if fpath == "." or fpath == "" then
    fpath = " "
  else
    fpath = string.format("%s %%<%s/", filepath_hl, fpath)
  end

  return fname == "" and fpath or string.format("%s%s ", fpath, fname)
end

-- File Type
components.filetype = function()
  local filetype_hl = get_hl(opt.filetype.hl)
  local type = bo.filetype
  local extended_type = opt.filetype.extend[type]

  if extended_type then
    type = extended_type
  end

  return string.format("%s %s", filetype_hl, type)
end

-- Line Column
components.linecolumn = function()
  return string.format("%s %s", get_hl(opt.linecolumn.hl), opt.linecolumn.text)
end

-- Diagnostics
components.diagnostics = function()
  local diag = {}
  local count = {}
  local severity = diagnostic.severity

  for level, k in pairs(opt.diagnostics) do
    count[level] = #diagnostic.get(0, { severity = severity[level] })

    if count[level] > 0 then
      diag[#diag + 1] = string.format("%s%s%d", get_hl(k[1]), k[2], count[level])
    end
  end

  return table.concat(diag, " ")
end

return components
