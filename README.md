# zenline.nvim

A minimal, performant statusline for Neovim written in Lua.

![image](https://github.com/abhilash26/zenline.nvim/assets/28080925/f698d710-17c2-494c-8a0a-d91e3fb41550)

## Philosophy

- **Zero dependencies** - Completely standalone (gitsigns optional for git features)
- **Performance first** - Aggressive caching, optimized rendering
- **Minimal by design** - 7 components, no bloat
- **Neovim 0.11+** - Leveraging modern APIs

## Requirements

* **Neovim >= 0.11** (required)
* `vim.opt.laststatus=2` in your init.lua (or `3` for global statusline)
* [Nerd font](https://www.nerdfonts.com/font-downloads) (recommended)
* [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) (optional - for git branch and diff)

## Installation

### Lazy.nvim

```lua
{
  "abhilash26/zenline.nvim",
  event = { "WinEnter", "BufEnter", "ColorScheme" },
  opts = {},  -- uses default (normal) configuration
},
```

### packer.nvim

```lua
use {
  "abhilash26/zenline.nvim",
  config = function()
    require("zenline").setup()
  end
}
```

## Configuration

### Default (Normal) Configuration

```lua
-- Uses full-featured configuration
require("zenline").setup()
```

### Lite Configuration (Maximum Performance)

For users prioritizing maximum performance over features:

```lua
-- Ultra-minimal: only mode, filename, and line/column
require("zenline").setup(require("zenline.defaults.lite"))
```

Lite configuration includes:
- Only 3 components: mode, file_name, line_column
- Short mode names (N, I, V instead of NORMAL, INSERT, VISUAL)
- Filename only (no path)
- No icons, no special filetype handling
- Minimal memory footprint

### Custom Configuration

```lua
-- Start with lite and add git branch
local config = require("zenline.defaults.lite")
config.sections.active.left = { "mode", "file_name", "git_branch" }
require("zenline").setup(config)

-- Or customize from normal default
require("zenline").setup({
  sections = {
    active = {
      left = { "mode", "git_branch" },
      center = { "file_name" },
      right = { "diagnostics", "line_column" },
    },
  },
})
```

### Default Options

Default configuration is in [`lua/zenline/defaults/normal.lua`](lua/zenline/defaults/normal.lua)

<details>
<summary>Click to expand full default configuration</summary>

```lua
{
  sections = {
    active = {
      left = { "mode", "git_branch", "git_diff" },
      center = { "file_name" },
      right = { "diagnostics", "file_type", "line_column" },
    },
    inactive = { hl = "Normal", text = "%F%=" },
  },
  components = {
    mode = {
      ["n"] = { "ZenlineNormal", "NORMAL" },
      ["i"] = { "ZenlineInsert", "INSERT" },
      ["ic"] = { "ZenlineInsert", "INSERT" },
      ["v"] = { "ZenlineVisual", "VISUAL" },
      ["V"] = { "ZenlineVisual", "VISUAL LINE" },
      ["^V"] = { "ZenlineVisual", "VISUAL BLOCK" },
      ["c"] = { "ZenlineCmdLine", "COMMAND" },
      ["R"] = { "ZenlineReplace", "REPLACE" },
      ["t"] = { "ZenlineTerminal", "TERMINAL" },
      default = { "Normal", "UNKNOWN" },
    },
    file_type = { hl = "ZenlineAccent" },
    file_name = {
      hl = "ZenlineAccent",
      mod = ":~:.",
      modified = " [+] ",
      readonly = "  ",
    },
    diagnostics = {
      ["ERROR"] = { "ZenlineError", " " },
      ["WARN"] = { "ZenlineWarn", " " },
      ["INFO"] = { "ZenlineInfo", " " },
      ["HINT"] = { "ZenlineHint", " " },
    },
    line_column = { hl = "ZenlineNormal", text = "%P %l:%c " },
    git_branch = { hl = "ZenlineAccent", icon = " " },
    git_diff = {
      ["added"] = { "ZenlineAdd", " " },
      ["changed"] = { "ZenlineChange", " " },
      ["removed"] = { "ZenlineDelete", " " },
    },
  },
  special_fts = {
    ["alpha"] = { "Alpha", "󰀫 " },
    ["lazy"] = { "Lazy", "󰏔 " },
    ["mason"] = { "Mason", "" },
    ["NvimTree"] = { "NvimTree", " " },
    ["neo-tree"] = { "Neotree", " " },
    ["oil"] = { "Oil", "󰖌 " },
    ["help"] = { "Help", "󰋗 " },
    ["lspinfo"] = { "LspInfo", " " },
    ["checkhealth"] = { "Checkhealth", "󰗶 " },
    ["spectre_panel"] = { "Spectre", "" },
    ["man"] = { "Man", " " },
    ["qt"] = { "Quickfix", " " },
    ["toggleterm"] = { "ToggleTerm", " " },
  },
}
```

</details>

## Components

| Component | Description |
|-----------|-------------|
| `mode` | Current Vim mode (NORMAL, INSERT, VISUAL, etc.) |
| `file_name` | Filename with path relative to cwd |
| `file_type` | Current filetype |
| `diagnostics` | LSP diagnostic counts (errors, warnings, info, hints) |
| `line_column` | Line number, column, and percentage |
| `git_branch` | Current git branch (requires gitsigns.nvim) |
| `git_diff` | Git diff stats: added, changed, deleted (requires gitsigns.nvim) |

## Performance Features

- **Aggressive caching** - Component strings pre-built, minimal runtime work
- **Lazy loading** - Only loads components actually used in configuration
- **Throttled updates** - Prevents excessive redraws during rapid navigation
- **Early returns** - Skips work for non-file buffers
- **String interning** - Reuses empty strings to reduce GC pressure
- **File path caching** - Paths cached per buffer, invalidated on write
- **pcall protection** - Gracefully handles missing gitsigns.nvim

## Customization Examples

### Minimal Setup (Just Essentials)

```lua
require("zenline").setup({
  sections = {
    active = {
      left = { "mode" },
      center = { "file_name" },
      right = { "line_column" },
    },
  },
})
```

### Git-Focused Setup

```lua
require("zenline").setup({
  sections = {
    active = {
      left = { "mode", "git_branch", "git_diff" },
      center = {},
      right = { "line_column" },
    },
  },
})
```

### Development Setup (All Components)

```lua
require("zenline").setup()  -- Uses normal default with all features
```

## Contributing

**Pull Request Policy:**

✅ **Accepted:**
- Performance optimizations
- Bug fixes with tests
- Documentation improvements
- Appearance customization options

❌ **Rejected:**
- New components (we have 7, that's it)
- External dependencies
- Features that reduce performance
- Unnecessary complexity

See [plan.md](plan.md) for development roadmap.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Credits

Inspired by the minimalist philosophy. Built for those who value performance and simplicity.
