# zenline.nvim
A simple statusline for neovim written in lua.

## 🚧 WIP 🚧

### Requirements
* Requires neovim version >= 0.10
* `vim.opt.laststatus=2` in your init.lua for statusline. (or `3` for global line)
* `vim.opt.termguicolors = true` must be set.
* Have a [nerd font installed](https://www.nerdfonts.com/font-downloads)

### Installation

## Lazy
```lua
  {
    "abhilash26/zenline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      sections = {
        "mode",
        "%=",
        "filepath",
        "%=",
        "diagnostics",
        "filetype",
        "linecolumn"
      },
    }
  },
```
## Pckr (Spiritual successor of packer)
```lua
  { "abhilash26/zenline.nvim",
    branch = "main",
    config = function()
          require("zenline").setup()
    end
  };
```
## Minimum Configuration
```lua
require("zenline").setup({
      sections = {
        "mode",
        "%=",
        "filepath",
        "%=",
        "diagnostics",
        "filetype",
        "linecolumn"
      },
    }
)
```
 ## Click to see default configuration
 Default configuration is here [options](https://github.com/abhilash26/zenline.nvim/blob/main/lua/zenline/options.lua)


 ## Sections

 | section | use |
 |---------|-----|
 | mode         | shows the mode |
 | filepath     | shows filename with path to cwd |
 | filetype     | shows filetype |
 | diagnostics  | shows lsp diagnostics (number of errors, warnings, etc) |
 | linecolumn   | shows line, column, percentage, etc |
