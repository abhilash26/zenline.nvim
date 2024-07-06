local opt = require("zenline.options")
local utils = require("zenline.utils")
local C = {}

-- Cache
local api = vim.api
local bo = vim.bo
local diagnostic = vim.diagnostic
local fn = vim.fn
local get_hl = utils.get_hl

-- Helper function to get mode highlight
local function get_mode_hl(mode, fallback)
  return opt.modes[mode] or fallback
end

-- Components
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

C.mode = function()
  local mode_info = get_mode_hl(api.nvim_get_mode().mode, opt.modes.default_mode)
  return mode_info and string.format("%s %s", get_hl(mode_info[1]), mode_info[2]) or ""
end

C.filepath = function()
  local fpath = fn.fnamemodify(fn.expand("%"), opt.filepath.mod[1])
  local fname = fn.expand(opt.filepath.mod[2])

  if fpath == "." or fpath == "" then
    fpath = " "
  else
    fpath = string.format("%s %%<%s/", get_hl(opt.filepath.hl), fpath)
  end

  return fname == "" and fpath or string.format("%s%s ", fpath, fname)
end

C.filetype = function()
  return string.format("%s %s", get_hl(opt.filetype.hl), bo.filetype)
end

C.linecolumn = function()
  return string.format("%s %s", get_hl(opt.linecolumn.hl), opt.linecolumn.text)
end

C.diagnostics = function()
  local diag = {}
  local severity = diagnostic.severity

  for level, k in pairs(opt.diagnostics) do
    local count = #diagnostic.get(0, { severity = severity[level] })

    if count > 0 then
      diag[#diag + 1] = string.format("%s%s%d", get_hl(k[1]), k[2], count)
    end
  end

  return table.concat(diag, " ")
end

return C

