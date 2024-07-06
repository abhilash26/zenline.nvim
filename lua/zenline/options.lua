-- Default Options for Zenline
return {
  sections = {
    "mode",
    "filepath",
    "diagnostics",
    "filetype",
    "linecolumn"
  },
  modes = {
    ["n"] = { "ZenLineAccent", "NORMAL" },
    ["no"] = { "ZenLineAccent", "NORMAL" },
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
  },
  startblock = { "ZenLineAccent", "" },
  endblock = { "ZenLineAccent", "" },
  filepath = {
    mod = { ":~:.:h", "%:t" },
    hl = "Normal"
  },
  filetype = {
    hl = "Normal",
    extend = {
      ["alpha"] = "Alpha"
    }
  },
  linecolumn = {
    text = " %P %l:%c",
    hl = "Normal"
  },
  diagnostics = {
    ["ERROR"] = { "DiagnosticError", " " },
    ["WARN"] = { "DiagnosticWarn", " " },
    ["INFO"] = { "DiagnosticInfo", " " },
    ["HINT"] = { "DiagnosticHint", " " },
  },
  global = true
}
