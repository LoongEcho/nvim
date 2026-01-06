-- =========================================================
-- Leader
-- =========================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =========================================================
-- lazy.nvim
-- =========================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================================================
-- Basic options
-- =========================================================
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.mouse = "a"
vim.opt.termguicolors = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- =========================================================
-- Keymaps
-- =========================================================
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

-- =========================================================
-- Plugins
-- =========================================================
require("lazy").setup({

  -- ---------------- LSP ----------------
  {
    "neovim/nvim-lspconfig",
    config = function()

      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
        end
        map("n", "gd", vim.lsp.buf.definition)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "K",  vim.lsp.buf.hover)
        map("n", "<leader>rn", vim.lsp.buf.rename)
        map("n", "<leader>ca", vim.lsp.buf.code_action)
      end
    vim.lsp.config("clangd", {
      on_attach = on_attach,
    })

    end,
  },

  -- ---------------- Completion ----------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = {
          { name = "nvim_lsp" },
        },
      })
    end,
  },

  -- ---------------- Treesitter ----------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "lua" },
      highlight = { enable = true },
    },
  },

  -- ---------------- Telescope ----------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("telescope").setup()
      local b = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", b.find_files)
      vim.keymap.set("n", "<leader>fg", b.live_grep)
      vim.keymap.set("n", "<leader>fb", b.buffers)
    end,
  },

  -- ---------------- Theme ----------------
  {
    "navarasu/onedark.nvim",
    config = function()
      require("onedark").load()
    end,
  },
})

