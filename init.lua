-- =========================================================
-- Leader

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
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>nh", ":nohl<CR>")
vim.keymap.set('n', '<leader>i', ':keepjumps normal! gg=G<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
-- =========================================================
-- Plugins
-- =========================================================
require("lazy").setup({

    -- ===============================
    -- Mason
    -- ===============================
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "clangd" },
            })
        end,
    },

    -- ===============================
    --  先加载补全！！！
    -- ===============================
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",

        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                completion = {
                    autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
                },

                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },

                mapping = cmp.mapping.preset.insert({
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                }),

                sources = {
                    { name = "nvim_lsp" },  -- LSP（verible）
                    { name = "buffer" },    -- 工程代码补全
                    { name = "luasnip" },
                },
            })
        end,
    },

    -- ===============================
    --  再加载 LSP（关键）
    -- ===============================
    {
        "neovim/nvim-lspconfig",
        config = function()

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(_, bufnr)
                local map = function(mode, lhs, rhs)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
                end
                map("n", "gd", vim.lsp.buf.definition)
                map("n", "K",  vim.lsp.buf.hover)
            end

            -- ===============================
            -- C / C++ (clangd)
            --
            -- 项目级配置通过各项目根目录的 .clangd 文件控制：
            --   ESP32/PlatformIO → .clangd 写死 include paths + defines
            --   STM32/CubeMX     → .clangd 指向 build/compile_commands.json
            --   通用 CMake        → clangd 自动找 compile_commands.json
            --
            -- 全局不加 --query-driver 和 --compile-commands-dir，
            -- 避免不同工具链项目之间互相污染。
            -- ===============================
            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                },
                capabilities = capabilities,
                on_attach = on_attach,
            })
            vim.lsp.enable("clangd")

            -- Python
            vim.lsp.config("pyright", {
                capabilities = capabilities,
                on_attach = on_attach,
            })
            vim.lsp.enable("pyright")

            --  Verilog
            vim.lsp.config("verible", {
                cmd = { "verible-verilog-ls", "--rules_config_search" },
                filetypes = { "verilog", "systemverilog" },
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    verible = {
                        completion = { enable = true },
                    },
                },
            })
            vim.lsp.enable("verible")

        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = { "c", "cpp", "lua", "verilog" },
            highlight = { enable = true },
        },
    },

    { "numToStr/Comment.nvim", opts = {} },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    {
        "navarasu/onedark.nvim",
        config = function()
            require("onedark").load()
        end,
    },
})
-- =========================================================
-- Diagnostics display (Neovim 0.11)
-- =========================================================
vim.diagnostic.config({
    virtual_text = {
        spacing = 2,
        prefix = "●",   -- 你也可以用 "▎" / "■"
    },
    signs = true,     -- 左侧 E/W
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
    },
})

-- 光标停留时自动显示错误
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})


if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "win32yank-wsl",
        copy = {
            ["+"] = "/mnt/d/StaticTools/win32yank/win32yank.exe -i --crlf",
            ["*"] = "/mnt/d/StaticTools/win32yank/win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "/mnt/d/StaticTools/win32yank/win32yank.exe -o --lf",
            ["*"] = "/mnt/d/StaticTools/win32yank/win32yank.exe -o --lf",
        },
        cache_enabled = 0,
    }
end

-- =========================================================
-- Custom highlight
-- =========================================================
vim.api.nvim_set_hl(0, "@comment", { fg = "#6A9955", italic = true })
vim.api.nvim_set_hl(0, "Comment", { fg = "#6A9955", italic = true })

-- ===============================
-- Verilog / SystemVerilog LSP
-- ===============================


-- 自动保存时格式化
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.v", "*.sv" },
  callback = function()
    vim.cmd("silent !verible-verilog-format -i %")
  end,
})
