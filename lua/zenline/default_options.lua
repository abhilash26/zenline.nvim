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
    file_type   = { hl = "ZenLineAccent", },
    file_name   = {
      hl = "ZenLineAccent",
      mod = ":~:.",
      modified = " [+] ",
      readonly = "  ",
    },
    diagnostics = {
      ["ERROR"] = { "ZenLineError", " " },
      ["WARN"] = { "ZenLineWarn", " " },
      ["INFO"] = { "ZenLineInfo", " " },
      ["HINT"] = { "ZenLineHint", " " },
    },
    line_column = {
      hl = "ZenLineAccent",
      text = "%P %l:%c ",
    },
    git_branch  = {
      hl = "ZenLineAccent",
      icon = " "
    },
    git_diff    = {
      ["added"] = { "ZenLineAdd", " " },
      ["changed"] = { "ZenLineChange", " " },
      ["removed"] = { "ZenLineDelete", " " },
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
