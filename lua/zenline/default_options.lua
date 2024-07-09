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
      ["ERROR"] = { "ZenlineError", " " },
      ["WARN"] = { "ZenlineWarn", " " },
      ["INFO"] = { "ZenlineInfo", " " },
      ["HINT"] = { "ZenlineHint", " " },
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
      ["added"] = { "ZenlineAdd", " " },
      ["changed"] = { "ZenlineChange", " " },
      ["removed"] = { "ZenlineDelete", " " },
    },
  },
  special_fts = {
    ["alpha"] = { "Alpha", "󰀫 " },
    ["lazy"] = { "Lazy", "󰏔 " },
    ["mason"] = { "Mason", "" },
    ["NvimTree"] = { "NvimTree", " " },
    ["neo-tree"] = { "Neotree", " " },
    ["oil"] = { "Oil", "󰖌 " },
    ["help"] = { "Help", "󰋗 " },
    ["lspinfo"] = { "LspInfo", " " },
    ["checkhealth"] = { "Checkhealth", "󰗶 " },
    ["spectre_panel"] = { "Spectre", "" },
    ["man"] = { "Man", " " },
  }
}
