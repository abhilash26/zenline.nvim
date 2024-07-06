local opt = require("zenline.options")
local utils = require("zenline.utils")
local C = {}

-- Cache

local api = vim.api
local bo = vim.bo
local diagnostic = vim.diagnostic
local fn = vim.fn
local get_hl = utils.get_hl

-- C --
C.startblock = function()
  local mode_hl = opt.modes[api.nvim_get_mode().mode] or opt.startblock[1]
  return string.format("%s%s", get_hl(mode_hl), "")
end

C.endblock = function()
  local mode_hl = opt.modes[api.nvim_get_mode().mode] or opt.endblock[1]
  return string.format("%s%s", get_hl(mode_hl), "")
end

C.section_separator = function()
  return string.format("%s%s", get_hl("ZenLineAccent"), "%=")
end

-- Mode
C.mode = function()
  local current_mode = api.nvim_get_mode().mode
  local mode_info = opt.modes[current_mode]
  if not mode_info then
    return ""
  end
  local mode_hl = mode_info[1]
  local mode_text = mode_info[2]
  return string.format("%s %s", get_hl(mode_hl), mode_text)
end

-- File Path
C.filepath = function()
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
C.filetype = function()
  local filetype_hl = get_hl(opt.filetype.hl)
  local type = bo.filetype
  local extended_type = opt.filetype.extend[type]

  if extended_type then
    type = extended_type
  end

  return string.format("%s %s", filetype_hl, type)
end

-- Line Column
C.linecolumn = function()
  return string.format("%s %s", get_hl(opt.linecolumn.hl), opt.linecolumn.text)
end

-- Diagnostics
C.diagnostics = function()
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

return C
