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
      ["n"] = { "ZenlineNormal", "NORMAL" },
      ["i"] = { "ZenlineInsert", "INSERT" },
      ["ic"] = { "ZenlineInsert", "INSERT" },
      ["v"] = { "ZenlineVisual", "VISUAL" },
      ["V"] = { "ZenlineVisual", "VISUAL LINE" },
      ["^V"] = { "ZenlineVisual", "VISUAL BLOCK" },
      ["c"] = { "ZenlineCmdLine", "COMMAND" },
      ["R"] = { "ZenlineReplace", "REPLACE" },
      ["t"] = { "ZenlineTerminal", "TERMINAL" },
      default = { "Normal", "UNKNOWN" }
    },
    file_type   = { hl = "ZenlineAccent", },
    file_name   = {
      hl = "ZenlineAccent",
      mod = ":~:.",
      modified = " [+] ",
      readonly = "  ",
    },
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
      hl = "ZenlineAccent",
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
    ["qt"] = { "Quickfix", " " },
    ["toggleterm"] = { "ToggleTerm", " " },
  }
}
