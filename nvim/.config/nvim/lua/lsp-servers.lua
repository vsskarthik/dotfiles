-- Sync this file across machines to replicate your full language setup.
-- Add any LSP server name from :h lspconfig-all — Mason auto-installs it.
return {
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
          diagnostics = { disable = { 'missing-fields' } },
        },
      },
    },
    pyright = {},
    ts_ls = {},
    gopls = {},
    rust_analyzer = {},
  },

  -- Non-LSP tools Mason should install (formatters, linters)
  tools = {
    'stylua',    -- Lua
    'ruff',      -- Python formatter
    'prettierd', -- JS/TS formatter
  },

  -- conform.nvim formatters per filetype
  formatters = {
    lua        = { 'stylua' },
    python     = { 'ruff_format' },
    javascript = { 'prettierd' },
    typescript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    -- Go and Rust format via LSP natively (gopls / rust_analyzer)
  },

  -- Treesitter parsers to install
  treesitter = {
    'bash',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'vim',
    'vimdoc',
    'python',
    'typescript',
    'javascript',
    'tsx',
    'go',
    'rust',
  },
}
