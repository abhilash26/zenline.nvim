-- default options
return {
  sections = {
    active = {
      left = { "mode", "git_branch", "git_diff" },
      center = { "file_name" },
      right = {
        "diagnostics",
        "file_type",
        "line_column"
      },
    },
    inactive = {
      hl = "Normal",
      text = "%F%=",
    }
  },
  components = {
    mode        = {
      ["n"] = { "ZenLineNormal", "NORMAL" },
      ["i"] = { "ZenLineInsert", "INSERT" },
      ["ic"] = { "ZenLineInsert", "INSERT" },
      ["v"] = { "ZenLineVisual", "VISUAL" },
      ["V"] = { "ZenLineVisual", "VISUAL LINE" },
      ["^V"] = { "ZenLineVisual", "VISUAL BLOCK" },
      ["c"] = { "ZenLineCmdLine", "COMMAND" },
      ["R"] = { "ZenLineReplace", "REPLACE" },
      ["t"] = { "ZenLineTerminal", "TERMINAL" },
      default = { "Normal", "UNKNOWN" }
    },
    file_type   = { hl = "ZenlineAccent", },
    file_name   = {
      hl = "ZenlineAccent",
      mod = ":~:.",
      modified = " [+] ",
      readonly = "  ",
    },
    file_icon   = { hl = "Normal" },
    diagnostics = {
      ["ERROR"] = { "DiagnosticError", " " },
      ["WARN"] = { "DiagnosticWarn", " " },
      ["INFO"] = { "DiagnosticInfo", " " },
      ["HINT"] = { "DiagnosticHint", " " },
    },
    line_column = {
      hl = "ZenlineAccent",
      text = "%P %l:%c ",
    },
    git_branch  = {
      hl = "ZenLineAccent",
      icon = " "
    },
    git_diff    = {
      ["added"] = { "GitSignsAdd", " " },
      ["changed"] = { "GitSignsChange", " " },
      ["removed"] = { "GitSignsDelete", " " },
    },
  }
}
