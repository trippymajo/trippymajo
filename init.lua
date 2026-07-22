vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- MS VS color scheme
    {
        "Mofiqul/vscode.nvim",
        priority = 1000,
        config = function()
            vim.o.background = "dark"

            require("vscode").setup({
                transparent = false,
                italic_comments = true,
                italic_inlayhints = true,
                terminal_colors = true,
            })

            vim.cmd.colorscheme("vscode")
        end,
    },
    --
    -- Autocompletion
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "1.*",

        opts = {
            keymap = {
                preset = "default",
            },

            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 300,
                },
            },

            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },
        },

        opts_extend = { "sources.default" },
    },
    --
    -- Status line 
    {
        "nvim-mini/mini.statusline",
        version = false,
        config = function()
            local statusline = require("mini.statusline")

            statusline.setup({
                use_icons = true,
            })

            statusline.section_location = function()
                return "%2l:%-2v"
            end
        end,
      },
      --
      -- Fuzzy finder over lists
      -- needed: sudo apt install ripgrep fd-find make 
      {
          "nvim-telescope/telescope.nvim",
          version = "*",
          dependencies = {
              "nvim-lua/plenary.nvim",
              {
                  "nvim-telescope/telescope-fzf-native.nvim",
                  build = "make",
              },
          },
          config = function()
              local telescope = require("telescope")
              local builtin = require("telescope.builtin")

              telescope.setup({})

              pcall(telescope.load_extension, "fzf")

              vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
              vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
              vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
              vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
              vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
              vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
          end,
    },
})

--
-- Options section
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Turn on/off with :set list OR set list!
vim.opt.list = true
vim.opt.listchars = {
  tab = ">-",           -- tab characters
  space = "·",          -- space characters
  nbsp = "␣",           -- non-breaking spaces
  extends = "▶",        -- text continues off-screen (right)
  precedes = "◀",       -- text continues off-screen (left)
}

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"

vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>h", ":noh<CR>", { desc = "Clear search highlight" })

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "if_many",
    },
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

        vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, opts)

        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)
    end,
})

vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--fallback-style=llvm",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = {
        "compile_commands.json",
        "compile_flags.txt",
        ".git",
    },
})

vim.lsp.enable("clangd")
