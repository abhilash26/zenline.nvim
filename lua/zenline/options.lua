-- Default Options for Zenline
return {
  inactive = {
    text = "%F%=",
    hl = "ZenLineInactive",
  },
  sections = {
    left = { "mode" },
    center = { "filepath" },
    right = { "diagnostics", "filetype", "linecolumn" },
  },
  modes = {
    ["n"] = { "ZenLineNormalAccent", "NORMAL" },
    ["no"] = { "ZenLineNormalAccent", "NORMAL" },
    ["v"] = { "ZenLineVisualAccent", "VISUAL" },
    ["V"] = { "ZenLineVisualAccent", "VISUAL LINE" },
    ["^V"] = { "ZenLineVisualAccent", "VISUAL BLOCK" },
    ["s"] = { "ZenLineAccent", "SELECT" },
    ["S"] = { "ZenLineAccent", "SELECT LINE" },
    [""] = { "ZenLineAccent", "SELECT BLOCK" },
    ["i"] = { "ZenLineInsertAccent", "INSERT" },
    ["ic"] = { "ZenLineInsertAccent", "INSERT" },
    ["R"] = { "ZenLineReplaceAccent", "REPLACE" },
    ["Rv"] = { "ZenLineAccent", "VISUAL REPLACE" },
    ["c"] = { "ZenLineCmdLineAccent", "COMMAND" },
    ["cv"] = { "ZenLineAccent", "VIM EX" },
    ["ce"] = { "ZenLineAccent", "EX" },
    ["r"] = { "ZenLineAccent", "PROMPT" },
    ["rm"] = { "ZenLineAccent", "MOAR" },
    ["r?"] = { "ZenLineAccent", "CONFIRM" },
    ["!"] = { "ZenLineAccent", "SHELL" },
    ["t"] = { "ZenLineTerminalAccent", "TERMINAL" },
    default_mode = { "ZenLineAccent", "UNKNOWN" },
  },
  filepath = {
    mod = { ":~:.:h", "%:t" },
    hl = "Normal",
  },
  filetype = {
    hl = "Normal",
  },
  linecolumn = {
    text = "%P %l:%c",
    hl = "ZenLineNormalAccent",
  },
  diagnostics = {
    ["ERROR"] = { "DiagnosticError", " " },
    ["WARN"] = { "DiagnosticWarn", " " },
    ["INFO"] = { "DiagnosticInfo", " " },
    ["HINT"] = { "DiagnosticHint", " " },
  },
}
