-- <leader>ff
-- <leader>fg
-- <leader>fb
-- <leader>fh
-- fuzzy funding above
-- filebar on side
-- <leader>e
-- <leader>r
--
-- alt t, gives terminal and removes it


vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.mouse = "a"           -- Enable mouse support
vim.opt.clipboard = "unnamed,unnamedplus" -- y/p always use system clipboard (PRIMARY + CLIPBOARD)

-- Custom clipboard provider: use a wrapper that rediscovers WAYLAND_DISPLAY
-- from a running Wayland process, so wl-copy/wl-paste work inside tmux panes
-- whose shell lacks the Wayland env (e.g. started before the session env was set).
local clip = vim.env.HOME .. "/.config/hypr/scripts/nvim-clip.sh"
vim.g.clipboard = {
  name = "wl-clipboard",
  copy = {
    ["+"] = { clip, "copy" },
    ["*"] = { clip, "copy", "--primary" },
  },
  paste = {
    ["+"] = { clip, "paste" },
    ["*"] = { clip, "paste", "--primary" },
  },
  cache_enabled = 0,
}
vim.opt.breakindent = true    -- Maintain indent when wrapping
vim.opt.undofile = true       -- Save undo history
vim.opt.ignorecase = true     -- Case insensitive searching vim.opt.smartcase = true      -- Case sensitive if uppercase present
vim.opt.signcolumn = "yes"    -- Always show sign column
vim.opt.updatetime = 250      -- Faster completion
vim.opt.timeoutlen = 300      -- Faster key sequence completion
vim.opt.splitright = true     -- Vertical splits go right
vim.opt.splitbelow = true     -- Horizontal splits go below
vim.opt.scrolloff = 8         -- Keep 8 lines visible around cursor
vim.opt.hlsearch = true       -- Highlight search results
vim.opt.incsearch = true      -- Incremental search
vim.opt.termguicolors = true  -- True color support
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.shiftwidth = 4        -- Indentation width
vim.opt.tabstop = 4           -- Tab width

-- Treat underscore as word boundary for w motion
vim.opt.iskeyword:remove("_")

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Disable macro recording (q accidentally triggers it)
vim.keymap.set("n", "q", "<Nop>")


-- Direct directional split navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to upper window" })

-- File operations
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit Neovim" })

-- ZZ saves and closes everything (tree + all buffers) in one shot
vim.keymap.set("n", "ZZ", "<cmd>xa<CR>", { desc = "Save all and quit" })

-- Auto-close file tree when the last real buffer is closed
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local non_tree_wins = vim.tbl_filter(function(w)
      local buf = vim.api.nvim_win_get_buf(w)
      return vim.bo[buf].filetype ~= "NvimTree"
    end, vim.api.nvim_list_wins())
    if #non_tree_wins == 1 then
      require("nvim-tree.api").tree.close()
    end
  end,
})

-- Buffer management
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- Better text manipulation
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Center cursor when jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Quick file explorer (using netrw built-in)
vim.keymap.set("n", "<leader>e", "<cmd>Ex<CR>", { desc = "Open file explorer" })

-- Split management
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close split" })

-- Terminal keybinds
vim.keymap.set("n", "<leader>t", "<cmd>terminal<CR>", { desc = "Open terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal mode with jk" })

-- Alt+hjkl to navigate windows from terminal mode
vim.keymap.set("t", "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
vim.keymap.set("t", "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Move to below window" })
vim.keymap.set("t", "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Move to above window" })
vim.keymap.set("t", "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })

-- Quickfix navigation
vim.keymap.set("n", "<leader>co", "<cmd>copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>cc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })

-- LSP keybinds (will work when LSP is set up)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- Diagnostic keybinds
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- CUSTOM KEYBINDS - Add your specific ones here
-- =============================================

-- Exit insert mode with 'jk'
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Enhanced clipboard operations
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Copy line to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("n", "<leader>P", '"+P', { desc = "Paste before from system clipboard" })

-- Resize splits with leader + hjkl
vim.keymap.set("n", "<leader>h", ":vertical resize -2<CR>", { silent = true, desc = "Shrink split width" })
vim.keymap.set("n", "<leader>l", ":vertical resize +2<CR>", { silent = true, desc = "Grow split width" })
vim.keymap.set("n", "<leader>j", ":resize -2<CR>", { silent = true, desc = "Shrink split height" })
vim.keymap.set("n", "<leader>k", ":resize +2<CR>", { silent = true, desc = "Grow split height" })

-- Toggle line wrapping
vim.keymap.set("n", "<leader>lw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
  print("Line wrap " .. (vim.opt.wrap:get() and "enabled" or "disabled"))
end, { desc = "Toggle line wrap" })

vim.keymap.set("n", "<leader>k", function()
  vim.diagnostic.open_float()
end, { desc = "Show line diagnostics" })

-- Folding keybinds
vim.keymap.set("n", "zc", "zc", { desc = "Close fold" })
vim.keymap.set("n", "zo", "zo", { desc = "Open fold" })
vim.keymap.set("n", "za", "za", { desc = "Toggle fold" })
vim.keymap.set("n", "zR", "zR", { desc = "Open all folds" })
vim.keymap.set("n", "zM", "zM", { desc = "Close all folds" })

-- Quick config reload
vim.keymap.set("n", "<leader>cr", "<cmd>source $MYVIMRC<CR>", { desc = "Reload config" })


vim.cmd([[
let g:term_buf = 0
let g:term_win = 0

function! TermToggle(height)
  if win_gotoid(g:term_win)
    hide
  else
    botright new
    exec "resize " . a:height
    try
      exec "buffer " . g:term_buf
    catch
      call termopen($SHELL, {"detach": 0})
      let g:term_buf = bufnr("")
      setlocal nonumber norelativenumber signcolumn=no
    endtry
    startinsert!
    let g:term_win = win_getid()
  endif
endfunction

nnoremap <A-t> :call TermToggle(12)<CR>
inoremap <A-t> <Esc>:call TermToggle(12)<CR>
tnoremap <A-t> <C-\><C-n>:call TermToggle(12)<CR>

" Terminal go back to normal mode
tnoremap <Esc> <C-\><C-n>
inoremap :q! <C-\><C-n>:q!<CR>
]])


-- PLUGIN SETUP WITH LAZY.NVIM
-- ============================
-- Skip plugins entirely when running inside VSCode
if vim.g.vscode then return end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require("lazy").setup({
  -- VSCode Dark+ colorscheme
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      require("vscode").setup({
        style = "dark",
        transparent = false,
        italic_comments = true,
        disable_nvimtree_bg = true,
        color_overrides = {
          -- keep the green comments
          vscGreen = "#00ff00",
        },
        group_overrides = {
          Comment = { fg = "#00ff00", italic = true },
        },
      })
      require("vscode").load()
    end,
  },

{
    "OXY2DEV/markview.nvim",
    lazy = false,

    -- Completion for `blink.cmp`
    -- dependencies = { "saghen/blink.cmp" },
},
  -- File explorer (VSCode-style)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 35,
          side = "left",
        },
        renderer = {
          group_empty = true,       -- collapse single-child folders like VSCode
          highlight_git = true,     -- color files by git status
          highlight_diagnostics = true,
          indent_markers = {
            enable = true,          -- VSCode-style indent lines in tree
          },
          icons = {
            git_placement = "after",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              diagnostics = true,
            },
            glyphs = {
              git = {
                unstaged  = "M",    -- modified  (yellow, like VSCode)
                staged    = "S",    -- staged    (green)
                untracked = "U",    -- new file  (green, like VSCode)
                deleted   = "D",    -- deleted   (red)
                ignored   = "◌",
                renamed   = "R",
                unmerged  = "C",    -- conflict
              },
            },
          },
        },
        git = {
          enable = true,
          show_on_dirs = true,      -- show status on parent folders too
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,      -- bubble errors up to parent folders
          icons = {
            error   = " ",
            warning = " ",
            hint    = " ",
            info    = " ",
          },
        },
        actions = {
          open_file = {
            quit_on_open = false,   -- keep tree open after opening a file
            resize_window = false,
          },
        },
        update_focused_file = {
          enable = true,            -- highlight the current file in tree
          update_root = false,
        },
        filters = {
          dotfiles = false,         -- show hidden files (toggle with H)
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          local function map(key, action, desc)
            vim.keymap.set("n", key, action, { buffer = bufnr, desc = desc, noremap = true, silent = true })
          end
          map("h",     api.node.navigate.parent_close, "Collapse folder")
          map("l",     api.node.open.edit,             "Open / expand")
          map("<CR>",  api.node.open.edit,             "Open")
          map("v",     api.node.open.vertical,         "Open in vsplit")
          map("s",     api.node.open.horizontal,       "Open in split")
          map("H",     api.tree.toggle_hidden_filter,  "Toggle dotfiles")
          map("R",     api.tree.reload,                "Refresh")
          map("a",     api.fs.create,                  "New file/folder")
          map("d",     api.fs.remove,                  "Delete")
          map("r",     api.fs.rename,                  "Rename")
          map("c",     api.fs.copy.node,               "Copy")
          map("x",     api.fs.cut,                     "Cut")
          map("p",     api.fs.paste,                   "Paste")
          map("y",     api.fs.copy.filename,           "Copy name")
          map("Y",     api.fs.copy.absolute_path,      "Copy path")
        end,
      })

      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>",   { desc = "Toggle file explorer" })
      vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal file in tree" })

      -- Open tree on startup but keep cursor in the file
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          local is_file = vim.fn.filereadable(data.file) == 1
          local is_empty = data.file == "" and vim.bo[data.buf].buftype == ""
          if is_file or is_empty then
            require("nvim-tree.api").tree.open()
            vim.cmd("wincmd p") -- move cursor back to the file
          end
        end,
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      vim.keymap.set("n", "<leader>gf", builtin.git_bcommits, { desc = "Git file commits" })
      vim.keymap.set("n", "<leader>gst", builtin.git_status, { desc = "Git status" })
      vim.keymap.set("n", "<leader>gbr", builtin.git_branches, { desc = "Git branches" })
    end,
  },

-- markdown viewer
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = "cd app && npx --yes yarn install",
      ft = { "markdown" },
       keys = {
        { "<leader>m", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview toggle" },
      },
    config = function()
      -- vim.g.mkdp_auto_start = 1     -- autostart
      vim.g.mkdp_auto_close = 1   -- closes when you leave the buffer
      vim.g.mkdp_theme = "dark"
    end,
    },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("lualine").setup({
        options = {
          theme = "vscode",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
      })
    end,
  },

  {
    "kwakzalver/duckytype.nvim",
    cmd = "DuckyType",
    config = function()
      require("duckytype").setup({
        number_of_words = 25,
        highlight = {
          good = "Comment",
          bad = "Error",
          remaining = "Normal",
        },
      })
      vim.keymap.set("n", "<leader>D", "<cmd>DuckyType<CR>", { desc = "Start DuckyType test" })
    end,
  },
    
{
    "kylechui/nvim-surround",
    version = "^3.0.0",
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({})
    end
},

{
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",        -- keep parsers up-to-date
    lazy = false,               -- always load on startup
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "python", "cpp", "bash", "javascript", "html", "css", "json", "go"},
        sync_install = false,
        auto_install = true,

        highlight = { enable = true },
        indent = { enable = true },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      })

      -- Treesitter folding
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.opt.foldenable = true
      vim.opt.foldlevel = 99  -- start mostly unfolded
    end,
  },
  
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gs = require("gitsigns")
      gs.setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = false,
        on_attach = function(bufnr)
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          -- Navigate hunks
          map("n", "]h", gs.next_hunk, "Next git hunk")
          map("n", "[h", gs.prev_hunk, "Prev git hunk")
          -- Stage / reset
          map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
          map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
          map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selected")
          map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selected")
          map("n", "<leader>gS", gs.stage_buffer, "Stage entire buffer")
          map("n", "<leader>gR", gs.reset_buffer, "Reset entire buffer")
          map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
          -- Inspect
          map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line (full)")
          map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
          map("n", "<leader>gd", gs.diffthis, "Diff this file")
        end,
      })
    end,
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright" },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
          end,
          pyright = function()
            require("lspconfig").pyright.setup({
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              settings = {
                python = {
                  analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "workspace",
                  },
                },
              },
            })
          end,
        },
      })
    end,
  },

  -- Completion engine (the VSCode IntelliSense equivalent)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Git UI (lazygit in a floating window)
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },

  -- Side-by-side diff view + full file history browser
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>",           desc = "Diff view (working tree)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",  desc = "This file's git history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",    desc = "Repo git history" },
    },
  },

  -- Rainbow brackets
  {
    'HiPhish/rainbow-delimiters.nvim',
    config = function()
      vim.g.rainbow_delimiters = { strategy = { 'global', 'local' } }
    end
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({ indent = { char = "│" }, scope = { enabled = true } })
    end,
  },

  -- Diagnostics panel (like VSCode's Problems tab)
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics panel" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols panel" },
    },
  },

},
    {
  -- Lazy.nvim configuration
  ui = {
    border = "rounded",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
