# Zenline.nvim - Project Analysis & Improvement Plan

## Project Overview

**zenline.nvim** is a lightweight, performance-focused statusline plugin for Neovim written in Lua. It provides a minimal, customizable statusline with support for:
- Mode indicators (Normal, Insert, Visual, etc.)
- Git integration (branch, diff stats via gitsigns.nvim)
- LSP diagnostics
- File information (name, type, modified status)
- Line/column position
- Special filetype handling (lazy, mason, oil, etc.)

**Current Architecture:**
- Single-file main module (`lua/zenline/init.lua`)
- Separate config file (`lua/zenline/config.lua`)
- Heavy use of caching for performance optimization
- Event-driven updates via autocommands
- **Zero dependencies** (gitsigns.nvim optional for git features)

**Target Neovim Version:** 0.11+

**Core Philosophy:**
- **NO new components** - Optimize and perfect existing ones
- **Stay dependency-free** - No external plugin requirements
- **Minimal by design** - Quality over quantity
- **Performance first** - Every optimization matters

---

## Current Strengths

### Performance ✅
1. **Aggressive caching strategy** - Pre-builds component strings and highlights
2. **Cached API references** - Stores `vim.api`, `vim.bo`, etc. locally
3. **Efficient component updates** - Only updates changed sections
4. **Global statusline support** - Reduces redundant updates across windows
5. **Minimal function calls** - Direct table lookups for cached data

### Usability ✅
1. **Simple setup** - One-line `require("zenline").setup()`
2. **Sensible defaults** - Works out-of-box with good appearance
3. **Deep merge config** - User options extend defaults nicely
4. **Flexible component system** - Easy to reorder or disable components
5. **Special filetype handling** - Clean display for plugin windows

### Appearance ✅
1. **Highlight linking** - Respects colorscheme automatically
2. **Nerd font icons** - Modern, attractive appearance
3. **Smart color flipping** - Mode highlights use inverted colors
4. **Clean layout** - Left/center/right section organization

---

## Improvement Opportunities

## Priority 1: Performance Optimizations 🚀

### 1.1 Reduce Memory Allocations
**Issue:** Multiple `string.format()` calls create temporary strings on every render
```lua
-- Current (line 168-169)
cache_mode[mkey] = string.format("%s %s", hl_txt(m[1]), m[2])
```

**Solutions:**
- Pre-concatenate strings during cache setup where possible
- Use table pre-allocation with known sizes: `local t = table.new(10, 0)`
- Consider string interning for frequently used patterns

**Impact:** 5-10% reduction in memory churn during statusline updates

---

### 1.2 Optimize Diagnostic Counting
**Issue:** Creates new table every time diagnostics update (line 50-59)
```lua
C.diagnostics = function()
  local diag = {}  -- New allocation each call
  local count_diag = diagnostic.count(0)
  ...
end
```

**Solutions:**
- Cache empty diagnostic string when count is 0
- Reuse table with `table.clear()` if available
- Early return on zero diagnostics
- Consider throttling updates (diagnostics don't change that often)

**Impact:** Reduces GC pressure on every statusline render

---

### 1.3 Debounce/Throttle Autocommands
**Issue:** Statusline updates on every `WinEnter`/`BufEnter` which can be excessive
```lua
-- Line 207-211
api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = augroup,
  callback = isglobal and M.set_global_statusline or M.set_statusline,
})
```

**Solutions:**
- Use `vim.schedule()` to defer non-critical updates
- Add a dirty flag system - only update if components actually changed
- Consider using `vim.defer_fn()` with small delay for rapid window switches
- Add `vim.in_fast_event()` check to skip updates during fast events

**Impact:** Reduces unnecessary renders by 30-50% during rapid navigation

---

### 1.4 Lazy Load Components
**Issue:** All components initialized even if not used
```lua
-- Components always cached regardless of sections config
M.cache_components = function()
  -- Caches ALL components
end
```

**Solutions:**
- Only cache components that are in active sections
- Add lazy initialization for git components (only if gitsigns loaded)
- Skip special_fts caching for filetypes user will never see
- Add `enabled` flag to components

**Impact:** Faster startup, reduced memory footprint

---

### 1.5 Optimize Loop Patterns
**Issue:** Multiple loops could be optimized
```lua
-- Line 129-133: Could use ipairs with pre-calculated step
for i = 1, #cache_idx, 2 do
  local idx = cache_idx[i]
  local component = cache_idx[i + 1]
  sects[idx] = C[component]()
end
```

**Solutions:**
- Use pre-calculated pairs for cache_idx traversal
- Consider unrolling small loops (if sections are fixed)
- Use `table.move()` for bulk operations where applicable

**Impact:** Minor but measurable in tight loops

---

## Priority 2: Usability Enhancements 📖

### 2.1 Add Component Toggle API
**Feature:** Allow runtime enable/disable of components
```lua
-- Proposed API
require("zenline").toggle_component("git_branch")
require("zenline").hide_component("diagnostics")
require("zenline").show_component("diagnostics")
```

**Benefits:**
- Conditional component display based on context
- Easy debugging/profiling
- Better integration with user workflows

---

### 2.2 ~~Custom Component Support~~ ❌ REJECTED
**Decision:** Do NOT add custom component support. This violates the minimal philosophy.

**Rationale:**
- Encourages feature bloat
- Maintenance burden for edge cases
- Users who need custom components should fork or use a different plugin
- Keep the plugin focused and maintainable

---

### 2.3 Better Error Handling
**Issue:** Silent failures if gitsigns not loaded, no validation of user config
```lua
-- Add validation
M.setup = function(opts)
  if not M.validate_config(opts) then
    vim.notify("zenline: Invalid config", vim.log.levels.ERROR)
    return
  end
  ...
end
```

**Benefits:**
- Clearer error messages for misconfiguration
- Graceful degradation for missing dependencies
- Better developer experience

---

### 2.4 Component Refresh API
**Feature:** Allow manual triggering of specific component updates
```lua
-- Useful for external integrations
require("zenline").refresh_component("git_branch")
require("zenline").refresh_all()
```

**Benefits:**
- Better control for users
- Useful for testing/debugging
- Integration with external tools

---

### 2.5 Configuration Validation & Documentation
**Enhancement:**
- Add schema validation for config options
- Generate docs from code comments
- Add type annotations for Lua LSP support
- Example configs for common use cases

---

### 2.6 Component Conditions
**Feature:** Show components conditionally
```lua
components = {
  diagnostics = {
    condition = function()
      return vim.bo.buftype == "" -- Only in normal buffers
    end,
  }
}
```

**Benefits:**
- Hide irrelevant components per buffer type
- Reduce clutter in terminal/special buffers
- Better context awareness

---

## Priority 3: Appearance Improvements 🎨

### 3.1 Separator Support
**Feature:** Add customizable separators between components
```lua
sections = {
  active = {
    left = { "mode", "|", "git_branch" },
    separators = { left = "", right = "" }
  }
}
```

**Benefits:**
- More visual distinction between components
- Support for powerline-style separators
- Better visual hierarchy

---

### 3.2 Padding & Spacing Configuration
**Feature:** Configurable spacing around components
```lua
components = {
  mode = {
    padding = { left = 1, right = 1 },
  }
}
```

**Benefits:**
- Fine-tuned visual balance
- Accommodate different font sizes
- Personal preference support

---

### 3.3 Component Width Limits
**Feature:** Truncate long components intelligently
```lua
components = {
  file_name = {
    max_width = 40,
    truncate_at = "middle", -- or "start", "end"
  }
}
```

**Benefits:**
- Prevent statusline overflow
- Better behavior with long paths
- Responsive to window size

---

### 3.4 Highlight Transitions
**Feature:** Smooth color transitions between sections
```lua
sections = {
  transitions = true, -- Add gradient/separator highlights
}
```

**Benefits:**
- More polished appearance
- Powerline-style aesthetics
- Visual flow

---

### 3.5 Icon Customization
**Enhancement:**
- Allow users to override all icons
- Support for different icon sets (nerd fonts, unicode, ascii)
- Fallback mode for no nerd font

---

### 3.6 Inactive Window Styling
**Enhancement:**
- More customizable inactive statusline
- Support for components in inactive windows
- Dimmed/alternative color scheme

---

## Quick Wins (Low Effort, High Impact) ⚡

1. **Add `pcall` protection** around gitsigns calls (5 min)
   - Prevents errors if gitsigns not loaded

2. **Cache `vim.fn.fnamemodify` results** (10 min)
   - File paths don't change that often

3. **Document all config options** (30 min)
   - Generate from config.lua with comments

4. **Add `enabled = false` option per component** (15 min)
   - Easy way to disable without removing from config

5. **Early return in component functions** (10 min)
   - Skip work if buffer isn't relevant

6. **Cache empty strings** (5 min)
   - Avoid allocation for disabled components

7. **Create defaults/ folder structure** (20 min)
   - Move config.lua to defaults/normal.lua
   - Create defaults/lite.lua

---

## Architectural Improvements

### 4.1 Split Module Structure
**Current:** Single 239-line init.lua
**Proposed:**
```
lua/zenline/
  ├── init.lua          (setup, main API)
  ├── config.lua        (default options)
  ├── components/       (component definitions)
  │   ├── mode.lua
  │   ├── git.lua
  │   ├── diagnostics.lua
  │   └── file.lua
  ├── render.lua        (statusline rendering)
  ├── highlight.lua     (highlight management)
  └── utils.lua         (helper functions)
```

**Benefits:**
- Better code organization
- Easier testing
- Clearer separation of concerns
- Easier to extend

---

### 4.2 Event System
**Feature:** Internal pub/sub for component updates
```lua
-- Components subscribe to events
events.on("colorscheme_changed", M.define_highlights)
events.on("diagnostics_changed", M.update_diagnostics)
```

**Benefits:**
- Decouple components
- Better control over update frequency
- Easier to add/remove features

---

### 4.3 Testing Infrastructure
**Add:**
- Unit tests for component functions
- Integration tests for setup
- Performance benchmarks
- Visual regression tests

---

## ❌ REJECTED FEATURES

### New Components - NOT ACCEPTED
**Decision:** No new components will be added. Focus on perfecting existing ones.

**Components to keep (existing):**
- mode
- file_name
- file_type
- diagnostics
- line_column
- git_branch
- git_diff

**Why no new components:**
- Maintains minimal philosophy
- Reduces maintenance burden
- Forces us to optimize what exists
- Users wanting more can use other plugins

---

## Defaults Folder Structure

### New Directory Layout
```
lua/zenline/
  ├── init.lua          (main module)
  ├── defaults/         (configuration presets)
  │   ├── normal.lua    (standard config - current default)
  │   └── lite.lua      (ultra-minimal config)
  ├── components/       (split component code)
  │   ├── mode.lua
  │   ├── file.lua
  │   ├── git.lua
  │   └── diagnostics.lua
  ├── render.lua        (rendering engine)
  └── highlight.lua     (highlight management)
```

### Normal Default (lua/zenline/defaults/normal.lua)
```lua
-- Full-featured default configuration
return {
  sections = {
    active = {
      left = { "mode", "git_branch", "git_diff" },
      center = { "file_name" },
      right = { "diagnostics", "file_type", "line_column" },
    },
    inactive = { hl = "Normal", text = "%F%=" },
  },
  -- ... all component configs
}
```

### Lite Default (lua/zenline/defaults/lite.lua)
```lua
-- Ultra-minimal configuration (performance focused)
return {
  sections = {
    active = {
      left = { "mode", "file_name" },
      center = {},
      right = { "line_column" },
    },
    inactive = { hl = "Normal", text = "%F" },
  },
  -- Minimal component configs, no icons
  components = {
    mode = {
      ["n"] = { "ZenlineNormal", "N" },  -- Short names
      ["i"] = { "ZenlineInsert", "I" },
      ["v"] = { "ZenlineVisual", "V" },
      ["c"] = { "ZenlineCmdLine", "C" },
      default = { "Normal", "?" },
    },
    file_name = {
      hl = "ZenlineAccent",
      mod = ":t",  -- Just filename, no path
      modified = "[+]",
      readonly = "[RO]",
    },
    line_column = {
      hl = "ZenlineNormal",
      text = "%l:%c",  -- No percentage
    },
  },
  special_fts = {},  -- Disable for max performance
}
```

### Usage Examples
```lua
-- Use normal default (current behavior)
require("zenline").setup()

-- Use lite version
require("zenline").setup(require("zenline.defaults.lite"))

-- Override lite with some tweaks
local lite = require("zenline.defaults.lite")
lite.sections.active.left = { "mode", "file_name", "git_branch" }
require("zenline").setup(lite)
```

---

## Performance Benchmarks (Recommended)

### Before Optimization
- Measure with `:profile start profile.log`
- Test scenarios:
  - Cold start
  - Window switching (10x rapid)
  - Colorscheme change
  - Diagnostic updates
  - Git status changes

### Target Metrics
- Cold start: < 1ms
- Statusline render: < 0.5ms
- Component update: < 0.1ms per component
- Memory: < 100KB total

---

## Implementation Roadmap

### Phase 1: Core Optimizations (Week 1-2)
1. Create defaults folder structure (normal.lua + lite.lua)
2. Add diagnostic caching & early returns
3. Optimize string concatenation
4. Add throttling to autocommands
5. Lazy load unused components
6. Add performance benchmarks

### Phase 2: Usability (Week 3-4)
1. Add component toggle API (hide/show at runtime)
2. Add config validation
3. Improve error handling (pcall gitsigns, graceful degradation)
4. Document all options with examples
5. Add type annotations for Lua LSP

### Phase 3: Appearance (Week 5-6)
1. Add separator support (customizable between components)
2. Implement padding configuration
3. Add width limits & intelligent truncation
4. Icon customization API (for nerd fonts/unicode/ascii)
5. Enhance inactive window styling

### Phase 4: Architecture (Week 7-8)
1. Split into modular files (components/, render.lua, highlight.lua)
2. Create testing infrastructure
3. Write comprehensive documentation
4. Performance profiling and final optimizations

---

## Breaking Changes to Consider

1. **Move config.lua → defaults/normal.lua** - Better organization
2. **Change cache structure** - More efficient but different format
3. **Component function signature** - Add context parameter for optimizations
4. **Remove global `Zenline` access** - Use require() API instead (optional breaking change)

---

## Compatibility & Requirements

- **Neovim Version:** 0.11+ (leverage latest APIs)
- **Dependencies:** NONE - fully standalone
- **Optional Integration:** gitsigns.nvim (graceful degradation if missing)
- **Support global statusline** - Already implemented
- **Backwards compatible configs** - Old configs work with normal default

---

## Conclusion

**Current State:** Solid, performant, minimal statusline plugin

**Strengths to Preserve:**
- Fast rendering with aggressive caching
- Simple setup and configuration
- Clean, focused codebase
- **Zero dependencies** - completely standalone

**Key Improvements:**
1. **Performance**: Further optimize caching, reduce allocations, throttle updates
2. **Usability**: Component toggle, error handling, comprehensive documentation
3. **Appearance**: Customization through separators, padding, truncation
4. **Organization**: defaults/ folder for normal and lite configurations

**Philosophy:** Stay true to "zen" principles:
- **Minimal** - No feature bloat, perfect the existing 7 components
- **Fast** - Every micro-optimization matters
- **Elegant** - Clean code, clear purpose
- **Dependency-free** - No external requirements

---

## Contribution Guidelines

### Pull Request Policy - STRICT ⚠️

**✅ WILL BE ACCEPTED:**
- Performance optimizations for existing components
- Bug fixes with tests
- Documentation improvements
- Code refactoring that improves maintainability
- Appearance customization options (separators, padding, etc.)
- Configuration validation and error handling

**❌ WILL BE REJECTED:**
- New components (LSP status, search count, etc.)
- New features that increase complexity
- Dependencies on external plugins
- Breaking changes without strong justification
- Code that reduces performance

**Review Process:**
1. All PRs must include performance benchmarks (if applicable)
2. Code must follow existing style (stylua.toml)
3. Documentation updates required for user-facing changes
4. Tests required for bug fixes
5. Maintainer has final say on scope creep

**Why So Strict:**
- Maintain the "zen" philosophy
- Keep codebase maintainable
- Prevent feature bloat
- Ensure every line serves a purpose

---

## Questions - ANSWERED

1. ~~Should we support Neovim < 0.10 with polyfills?~~
   **NO** - Target 0.11+ for modern APIs

2. ~~How much customization is "too much" for a minimal plugin?~~
   **ANSWER:** Customization of existing components is OK. New components = too much.

3. ~~Should we add a dependency on nui.nvim or stay dependency-free?~~
   **NO DEPENDENCIES** - Stay 100% standalone

4. ~~Should there be a "lite" version with even fewer features?~~
   **YES** - Add defaults/lite.lua for ultra-minimal config

5. ~~How to handle community contributions while maintaining quality?~~
   **STRICT PR POLICY** - No new components, optimize existing ones only

---

**Generated:** 2025-10-25
**Updated:** 2025-10-25 (with minimal philosophy enforcement)
**Version:** 2.0
**Target Audience:** Plugin maintainers, contributors
**Target Neovim:** 0.11+


