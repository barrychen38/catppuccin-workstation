-- Keep this setup lean: it exists to view and navigate code (LSP jumps,
-- fuzzy search, highlighting), not to write it. Disable the editing layer.
return {
  { "blink.cmp", enabled = false },          -- completion
  { "friendly-snippets", enabled = false },  -- completion snippets
  { "conform.nvim", enabled = false },       -- formatting
  { "nvim-lint", enabled = false },          -- linting
  { "nvim-ts-autotag", enabled = false },    -- auto close tags
  { "mini.pairs", enabled = false },         -- auto close brackets
  { "persistence.nvim", enabled = false },   -- session restore
  { "noice.nvim", enabled = false },         -- fancy message UI
  { "trouble.nvim", enabled = false },       -- diagnostics panel
}
