# zenline.nvim
A simple statusline for neovim written in lua.

## 🚧 WIP 🚧

### Requirements
* Requires neovim version >= 0.10
* `vim.opt.laststatus=2` in your init.lua for statusline. (or `3` for global line)
* Have a [nerd font installed](https://www.nerdfonts.com/font-downloads)

### Installation

#### Lazy
```lua
  {
    "abhilash26/zenline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {}
  },
```
#### Pckr (Spiritual successor of packer)
```lua
  { "abhilash26/zenline.nvim",
    config = function()
          require("zenline").setup()
    end
  };
```
### Minimum Configuration
```lua
require("zenline").setup()
```
### Click to see default configuration
 Default configuration is here [options](https://github.com/abhilash26/zenline.nvim/blob/main/lua/zenline/default_options.lua)


 ## Sections

 | section | use |
 |---------|-----|
 | mode         | shows the mode |
 | file_name     | shows filename with path to cwd |
 | file_type     | shows filetype |
 | diagnostics  | shows lsp diagnostics (number of errors, warnings, etc) |
 | line_column   | shows line, column, percentage, etc |
