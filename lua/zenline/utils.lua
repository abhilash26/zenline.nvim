U = {}

U.get_hl = function(hl)
  return string.format("%%#%s#", hl)
end

U.flip_hl = function(hl)
  local hl_data = vim.api.nvim_get_hl(0, { name = hl })

  if hl_data then
    return {
      fg = hl_data.bg,
      bg = hl_data.fg,
    }
  end
end

return U
