-- zenline.nvim - A minimal, performant statusline for Neovim
-- Target: Neovim 0.11+
-- Philosophy: Zero dependencies, maximum performance, minimal features
--
-- Performance Optimizations:
-- - Aggressive caching: Component strings pre-built at setup time
-- - Lazy loading: Only initializes components actually used
-- - Throttled updates: Prevents excessive redraws (10ms debounce)
-- - Early returns: Skips work for non-file buffers
-- - String interning: Reuses empty strings to reduce GC pressure
-- - File path caching: Paths cached per buffer, invalidated on write
-- - pcall protection: Gracefully handles missing gitsigns.nvim
--
-- Components (7 total):
-- - mode: Current Vim mode indicator
-- - file_name: File path relative to cwd
-- - file_type: Current filetype
-- - diagnostics: LSP diagnostic counts
-- - line_column: Line, column, percentage info
-- - git_branch: Current git branch (requires gitsigns)
-- - git_diff: Git diff stats (requires gitsigns)

---@diagnostic disable: undefined-global

local M = {}

-- State management
local plugin_loaded = false
local sects = {}
local hls = {}
local default_options = require("zenline.config")
local status_active = "%{%v:lua.Zenline.active()%}"
local status_inactive = "%{%v:lua.Zenline.inactive()%}"

-- Component caches
local cache_idx = {}
local cache_mode = {}
local cache_diag = {}
local cache_diff = {}
local cache_special = {}
local cache_file_path = {}  -- NEW: Cache for file paths
local cache_empty = ""      -- NEW: Reuse empty string

local comp = {}
local zenhl = ""

-- Cached vim API references (performance optimization)
local api = vim.api
local o = default_options
local bo = vim.bo
local diagnostic = vim.diagnostic
local fn = vim.fn

--- Generate highlight text for statusline
--- @param hl string Highlight group name
--- @return string Formatted highlight string
local hl_txt = function(hl)
  return hls[hl] and hls[hl].txt or string.format("%%#%s#", hl)
end

-- Component functions
-- Each component is a function that returns a string to display
-- Components should:
-- - Return early for irrelevant buffers
-- - Use cached data where possible
-- - Return cache_empty instead of "" for consistency
local C = {}

--- Mode component - Shows current Vim mode
--- @return string Mode indicator text
C.mode = function()
  local m = api.nvim_get_mode().mode
  return cache_mode[m] or cache_mode["default"]
end

--- File name component with intelligent caching
--- Caches file paths per buffer and invalidates on write
--- @return string File path with modification indicators
C.file_name = function()
  -- Early return for special buffers
  if bo.buftype ~= "" then
    return cache_empty
  end

  local fo = comp.file_name
  local bufnr = api.nvim_get_current_buf()

  -- Check cache first (updated only on write)
  if not cache_file_path[bufnr] or vim.b.zenline_path_dirty then
    local fpath = fn.fnamemodify(fn.expand("%"), fo.mod)
    cache_file_path[bufnr] = fpath
    vim.b.zenline_path_dirty = false
  end

  local modified = bo.mod and fo.modified or cache_empty
  local readonly = bo.readonly and fo.readonly or cache_empty

  return cache_file_path[bufnr] .. modified .. readonly
end

--- File type component
--- @return string Current filetype
C.file_type = function()
  -- Early return for empty filetype
  return bo.filetype ~= "" and bo.filetype or cache_empty
end

--- Diagnostics component with optimized allocation
--- Avoids creating tables when no diagnostics present
--- @return string Diagnostic counts with icons
C.diagnostics = function()
  -- Early return for non-file buffers
  if bo.buftype ~= "" then
    return cache_empty
  end

  local count_diag = diagnostic.count(0)

  -- Early return if no diagnostics
  if not count_diag or vim.tbl_isempty(count_diag) then
    return cache_empty
  end

  local diag = {}
  local has_diag = false

  for level, k in pairs(cache_diag) do
    local count = count_diag[diagnostic.severity[level]]
    if count and count > 0 then
      has_diag = true
      diag[#diag + 1] = k .. count
    end
  end

  return has_diag and table.concat(diag, " ") or cache_empty
end

--- Git branch component with graceful degradation
--- Uses pcall to handle missing gitsigns.nvim
--- @return string Current git branch name
C.git_branch = function()
  -- Early return for non-file buffers
  if bo.buftype ~= "" then
    return cache_empty
  end

  -- Safely access gitsigns data (may not be loaded)
  local ok, git_branch = pcall(function()
    return vim.b.gitsigns_head
  end)

  if not ok or not git_branch then
    return cache_empty
  end

  return comp.git_branch.icon .. zenhl .. git_branch
end

--- Git diff component with graceful degradation
--- Shows added, changed, and removed line counts
--- @return string Git diff statistics
C.git_diff = function()
  -- Early return for non-file buffers
  if bo.buftype ~= "" then
    return cache_empty
  end

  -- Safely access gitsigns data
  local ok, diff = pcall(function()
    return vim.b.gitsigns_status_dict
  end)

  if not ok or not diff then
    return cache_empty
  end

  local diff_text = {}
  local has_diff = false

  for type, k in pairs(cache_diff) do
    local count = diff[type]
    if count and count > 0 then
      has_diff = true
      diff_text[#diff_text + 1] = k .. count
    end
  end

  return has_diff and table.concat(diff_text, " ") or cache_empty
end

--- Line/column component (static text from config)
--- @return string Line/column format string
C.line_column = function()
  return comp.line_column.text
end

-- Configuration management
--- Merge user configuration with defaults
--- @param opts table|nil User configuration options
M.merge_config = function(opts)
  -- Prefer user's config over default
  o = vim.tbl_deep_extend("force", default_options, opts or {})
  comp = o.components
end

-- Highlight definitions
--- Define statusline highlight groups based on colorscheme
--- Called on setup and colorscheme change
M.define_highlights = function()
  local get_hl = api.nvim_get_hl
  local set_hl = api.nvim_set_hl
  local status = get_hl(0, { name = "StatusLine" })

  hls = {
    ["ZenlineError"] = { link = "DiagnosticError", flip = false },
    ["ZenlineWarn"] = { link = "DiagnosticWarn", flip = false },
    ["ZenlineInfo"] = { link = "DiagnosticInfo", flip = false },
    ["ZenlineHint"] = { link = "DiagnosticHint", flip = false },
    ["ZenlineAdd"] = { link = "SignAdd", flip = false },
    ["ZenlineChange"] = { link = "SignChange", flip = false },
    ["ZenlineDelete"] = { link = "SignDelete", flip = false },
    ["ZenlineNormal"] = { link = "Function", flip = true },
    ["ZenlineInsert"] = { link = "String", flip = true },
    ["ZenlineVisual"] = { link = "Special", flip = true },
    ["ZenlineCmdLine"] = { link = "Constant", flip = true },
    ["ZenlineReplace"] = { link = "Identifier", flip = true },
    ["ZenlineTerminal"] = { link = "Comment", flip = true },
    ["ZenlineAccent"] = { link = "StatusLine", flip = false },
  }

  for hl, data in pairs(hls) do
    local hl_data = get_hl(0, { name = data.link })
    if data.flip then
      -- Flip colors for mode indicators (background becomes foreground)
      set_hl(0, hl, { fg = status.bg, bg = hl_data.fg })
    else
      -- Keep foreground color, use statusline background
      set_hl(0, hl, { fg = hl_data.fg, bg = status.bg })
    end
    -- Pre-format highlight strings for performance
    hls[hl].txt = string.format("%%#%s#", hl)
  end

  zenhl = "%#ZenlineAccent#"
end

-- Active statusline renderer
--- Render the active statusline by calling all enabled components
--- @return string Complete statusline string
M.active = function()
  for i = 1, #cache_idx, 2 do
    local idx = cache_idx[i]
    local component = cache_idx[i + 1]
    sects[idx] = C[component]()
  end
  return table.concat(sects, " ")
end

-- Inactive statusline
--- Return the inactive statusline (simple string)
--- @return string Inactive statusline text
M.inactive = function()
  return o.sections.inactive.text
end

-- Global statusline setter
--- Set statusline for global statusline mode (laststatus=3)
M.set_global_statusline = function()
  local cur_win = api.nvim_get_current_win()
  local ft = vim.bo.ft
  local ft_opts = o.special_fts[ft]
  vim.wo[cur_win].statusline = ft_opts and cache_special[ft] or status_active
end

-- Per-window statusline setter
--- Set statusline for per-window mode (laststatus=2)
--- Active window gets full statusline, others get inactive
M.set_statusline = function()
  local cur_win = api.nvim_get_current_win()
  for _, w in ipairs(api.nvim_list_wins()) do
    if cur_win == w then
      local ft = vim.bo.ft
      local ft_opts = o.special_fts[ft]
      vim.wo[cur_win].statusline = ft_opts and cache_special[ft]
        or status_active
    else
      vim.wo[w].statusline = status_inactive
    end
  end
end

-- Component caching (build-time optimization)
--- Pre-build all component strings at setup time
--- This eliminates runtime string concatenation overhead
M.cache_components = function()
  local no_hl = { mode = true, diagnostics = true, git_diff = true }
  sects = { zenhl }

  -- Cache mode strings (pre-concatenate)
  for mkey, m in pairs(comp.mode) do
    local hl = hl_txt(m[1])
    cache_mode[mkey] = hl .. " " .. m[2]
  end

  -- Cache diagnostics strings (pre-concatenate)
  for severity, t in pairs(comp.diagnostics) do
    local hl = hl_txt(t[1])
    cache_diag[severity] = hl .. t[2]
  end

  -- Cache git_diff strings (pre-concatenate)
  for key, v in pairs(comp.git_diff) do
    local hl = hl_txt(v[1])
    cache_diff[key] = hl .. v[2]
  end

  -- Cache special filetypes
  for ft, d in pairs(o.special_fts) do
    cache_special[ft] = table.concat({ zenhl, "%=", d[2], d[1], "%=" }, "")
  end

  -- Cache active sections (only components actually used and enabled)
  for _, pos in ipairs({ "left", "center", "right" }) do
    for _, sec in ipairs(o.sections.active[pos]) do
      local c = comp[sec]
      -- Check if component exists and is enabled (default to enabled if not specified)
      if c and (c.enabled == nil or c.enabled == true) then
        if not no_hl[sec] then
          sects[#sects + 1] = hl_txt(c.hl)
        end
        cache_idx[#cache_idx + 1] = #sects + 1
        cache_idx[#cache_idx + 1] = sec
        sects[#sects + 1] = cache_empty
      end
    end
    if pos ~= "right" then
      sects[#sects + 1] = zenhl
      sects[#sects + 1] = "%="
    end
  end
end

-- Throttled statusline update
--- Prevents excessive statusline redraws during rapid navigation
local update_timer = nil
local pending_update = false

--- Throttle function execution to reduce overhead
--- @param callback function Function to call after throttle delay
local function throttled_update(callback)
  if pending_update then
    return
  end

  pending_update = true

  if update_timer then
    update_timer:stop()
  end

  update_timer = vim.defer_fn(function()
    pending_update = false
    callback()
  end, 10)  -- 10ms throttle delay
end

-- Autocommand setup
--- Create autocommands for statusline updates and highlight changes
M.create_autocommands = function()
  local augroup = api.nvim_create_augroup("Zenline", { clear = true })
  local isglobal = vim.o.laststatus == 3

  local update_callback = isglobal and M.set_global_statusline or M.set_statusline

  -- Throttled statusline updates on window/buffer changes
  api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = augroup,
    callback = function()
      -- Skip updates during fast events (macro playback, etc.)
      if vim.in_fast_event() then
        return
      end
      throttled_update(update_callback)
    end,
    desc = "set statusline (throttled)",
  })

  -- Immediate highlight updates on colorscheme change
  api.nvim_create_autocmd({ "ColorScheme" }, {
    group = augroup,
    callback = M.define_highlights,
    desc = "update highlights",
  })

  -- Mark file path cache as dirty on buffer saves/renames
  api.nvim_create_autocmd({ "BufWrite", "BufFilePost" }, {
    group = augroup,
    callback = function()
      vim.b.zenline_path_dirty = true
    end,
    desc = "invalidate file path cache",
  })
end

-- Setup function (main entry point)
--- Initialize zenline statusline plugin
--- @param opts table|nil Configuration options (merged with defaults)
---
--- Example usage:
---   require("zenline").setup()  -- Use normal default
---   require("zenline").setup(require("zenline.defaults.lite"))  -- Use lite
---   require("zenline").setup({ sections = { ... } })  -- Custom config
M.setup = function(opts)
  -- Return if setup has already taken place
  if plugin_loaded then
    vim.notify("zenline: Already loaded", vim.log.levels.WARN)
    return
  end

  -- Check Neovim version
  if vim.fn.has("nvim-0.11") ~= 1 then
    vim.notify(
      "zenline: Requires Neovim 0.11+, current version: " .. vim.version(),
      vim.log.levels.ERROR
    )
    return
  end

  -- Export the module globally
  _G.Zenline = M

  -- Merge configuration
  M.merge_config(opts)

  -- Define highlights
  M.define_highlights()

  -- Build component cache for performance
  M.cache_components()

  -- Create autocommands
  M.create_autocommands()

  -- Set initial statusline
  vim.g.statusline = status_active

  plugin_loaded = true
end

return M
