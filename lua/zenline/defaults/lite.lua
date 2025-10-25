-- zenline.nvim - Lite (Ultra-Minimal) Configuration
-- Maximum performance with minimal features
-- No icons, no git components, short mode names, minimal overhead

return {
  sections = {
    active = {
      left = { "mode", "file_name" },
      center = {},
      right = { "line_column" },
    },
    inactive = {
      hl = "Normal",
      text = "%F",
    },
  },
  components = {
    -- Short, ASCII-only mode indicators
    mode = {
      ["n"] = { "ZenlineNormal", "N" },
      ["i"] = { "ZenlineInsert", "I" },
      ["ic"] = { "ZenlineInsert", "I" },
      ["v"] = { "ZenlineVisual", "V" },
      ["V"] = { "ZenlineVisual", "V-L" },
      ["^V"] = { "ZenlineVisual", "V-B" },
      ["c"] = { "ZenlineCmdLine", "C" },
      ["R"] = { "ZenlineReplace", "R" },
      ["t"] = { "ZenlineTerminal", "T" },
      default = { "Normal", "?" },
    },
    -- Filename only, no path
    file_name = {
      hl = "ZenlineAccent",
      mod = ":t",
      modified = "[+]",
      readonly = "[RO]",
    },
    -- Just line and column, no percentage
    line_column = {
      hl = "ZenlineNormal",
      text = "%l:%c",
    },
    -- Minimal component definitions (required but not used in sections)
    file_type = { hl = "ZenlineAccent" },
    diagnostics = {
      ["ERROR"] = { "ZenlineError", "E" },
      ["WARN"] = { "ZenlineWarn", "W" },
      ["INFO"] = { "ZenlineInfo", "I" },
      ["HINT"] = { "ZenlineHint", "H" },
    },
    git_branch = {
      hl = "ZenlineAccent",
      icon = "",
    },
    git_diff = {
      ["added"] = { "ZenlineAdd", "+" },
      ["changed"] = { "ZenlineChange", "~" },
      ["removed"] = { "ZenlineDelete", "-" },
    },
  },
  -- No special filetype handling for maximum performance
  special_fts = {},
}

