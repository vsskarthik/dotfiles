vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Options
vim.opt.relativenumber = true
vim.opt.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.inccommand = 'split'
vim.o.background = 'dark'
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus down' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus up' })
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', { desc = 'Open diagnostic float' })
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<leader>bx', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })
vim.keymap.set('n', '<leader>bX', '<cmd>bufdo bdelete<CR>', { desc = 'Delete all buffers' })

-- On `nvim .`: cd into dir, wipe blank buffer, show starter
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('dir-open', { clear = true }),
  callback = function()
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd('cd ' .. vim.fn.fnameescape(vim.fn.argv(0)))
      vim.cmd 'bwipeout'
      require('mini.starter').open()
    end
  end,
  nested = true,
})

-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Lazy bootstrap
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- Colorscheme
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = { style = 'night' },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme 'tokyonight'
    end,
  },

  -- Git signs in gutter + blame toggle
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPost',
    opts = {
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,
      current_line_blame_opts = { delay = 500, virt_text = false },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        vim.keymap.set('n', '<leader>gb', gs.toggle_current_line_blame, { buffer = bufnr, desc = 'Toggle git blame' })
      end,
    },
  },

  -- Buffer tabs at top
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VimEnter',
    opts = {
      options = {
        numbers = 'ordinal',
        diagnostics = 'nvim_lsp',
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = 'thin',
      },
    },
    config = function(_, opts)
      require('bufferline').setup(opts)
      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, '<cmd>BufferLineGoToBuffer ' .. i .. '<cr>', { desc = 'Go to buffer ' .. i })
      end
      vim.keymap.set('n', '<leader>0', '<cmd>BufferLineGoToBuffer 10<cr>', { desc = 'Go to buffer 10' })
    end,
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git/' },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files,    { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep,     { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags,     { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string,   { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics,   { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume,        { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles,      { desc = '[S]earch Recent Files' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps,       { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { previewer = false })
      end, { desc = '[/] Fuzzy search buffer' })
    end,
  },

  -- File tree (side panel)
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<leader><space>', '<cmd>Neotree toggle<cr>', desc = 'Toggle Neo-tree' },
    },
    opts = {
      filesystem = {
        hijack_netrw_behavior = 'disabled',
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = { enabled = true },
      },
      window = { width = 30 },
    },
  },

  -- Floating terminal + lazygit popup
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup()
      local Terminal = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new {
        cmd = 'lazygit',
        dir = 'git_dir',
        direction = 'float',
        float_opts = { border = 'double' },
        on_open = function(term)
          vim.cmd 'startinsert!'
          vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
        end,
      }
      vim.keymap.set('n', '<leader>g', function()
        lazygit:toggle()
      end, { noremap = true, silent = true, desc = 'Toggle Lazygit' })
    end,
  },

  -- Completion
  {
    'saghen/blink.cmp',
    version = '1.*',
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = { 'lsp', 'path' },
      },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      local lsp_cfg = require 'lsp-servers'

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local builtin = require 'telescope.builtin'
          map('gd', builtin.lsp_definitions,               'Goto Definition')
          map('gr', builtin.lsp_references,                'Goto References')
          map('gi', builtin.lsp_implementations,           'Goto Implementation')
          map('gt', builtin.lsp_type_definitions,          'Goto Type Definition')
          map('gD', vim.lsp.buf.declaration,               'Goto Declaration')
          map('gO', builtin.lsp_document_symbols,          'Document Symbols')
          map('gW', builtin.lsp_dynamic_workspace_symbols, 'Workspace Symbols')
          map('gn', vim.lsp.buf.rename,                    'Rename')
          map('ga', vim.lsp.buf.code_action,               'Code Action', { 'n', 'x' })

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            local supports_inlay = vim.fn.has 'nvim-0.11' == 1
              and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
              or client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, { bufnr = event.buf })
            if supports_inlay then
              map('<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
              end, 'Toggle Inlay Hints')
            end
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = { source = 'if_many', spacing = 2 },
      }

      -- Auto-install formatter/linter tools via mason-registry
      local mr = require 'mason-registry'
      mr.refresh(function()
        for _, tool in ipairs(lsp_cfg.tools or {}) do
          local ok, pkg = pcall(mr.get_package, tool)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(lsp_cfg.servers),
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = lsp_cfg.servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    config = function()
      local lsp_cfg = require 'lsp-servers'
      require('conform').setup {
        notify_on_error = false,
        format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
        formatters_by_ft = lsp_cfg.formatters,
      }
    end,
  },

  -- Syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufReadPost',
    config = function()
      local lsp_cfg = require 'lsp-servers'
      require('nvim-treesitter.configs').setup {
        ensure_installed = lsp_cfg.treesitter,
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

-- mini: text objects, surround, auto-pairs, statusline, starter
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.pairs').setup()

      local statusline = require 'mini.statusline'
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
            local git           = statusline.section_git { trunc_width = 40 }
            local diff          = statusline.section_diff { trunc_width = 75 }
            local diagnostics   = statusline.section_diagnostics { trunc_width = 75 }
            local lsp           = statusline.section_lsp { trunc_width = 75 }
            local filename      = statusline.section_filename { trunc_width = 140 }
            local fileinfo      = statusline.section_fileinfo { trunc_width = 120 }
            local location      = '%2l:%-2v'
            local blame         = vim.b.gitsigns_blame_line or ''

            return statusline.combine_groups {
              { hl = mode_hl,                  strings = { mode } },
              { hl = 'MiniStatuslineDevinfo',  strings = { git, diff, diagnostics, lsp } },
              '%<',
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=',
              { hl = 'MiniStatuslineFileinfo', strings = { blame } },
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl,                  strings = { location } },
            }
          end,
        },
      }

      require('mini.starter').setup {
        header = 'Hi Karthik\nWelcome To Your Workspace',
        items = {},
        footer = '',
        content_hooks = {
          require('mini.starter').gen_hook.aligning('center', 'center'),
        },
      }
    end,
  },

}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂',
      init = '⚙', keys = '🗝', plugin = '🔌', runtime = '💻',
      require = '🌙', source = '📄', start = '🚀', task = '📌',
      lazy = '💤 ',
    },
  },
})
