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
vim.opt.clipboard = "unnamedplus" -- System clipboard integration
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

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to upper window" })

-- File operations
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit Neovim" })

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

-- Toggle line wrapping
vim.keymap.set("n", "<leader>lw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
  print("Line wrap " .. (vim.opt.wrap:get() and "enabled" or "disabled"))
end, { desc = "Toggle line wrap" })

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
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night", -- storm, moon, night, day
        transparent = false,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

{
    "OXY2DEV/markview.nvim",
    lazy = false,

    -- Completion for `blink.cmp`
    -- dependencies = { "saghen/blink.cmp" },
},
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
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
    end,
  },

  {
      "OXY2DEV/markview.nvim",
      lazy = false,
      config = function()
        require("markview").setup({});
        vim.keymap.set("n", "<leader>m", "<cmd>Markview toggle<CR>", { desc = "Toggle markdown preview" });
      end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
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
      vim.keymap.set("n", "<leader>d", "<cmd>DuckyType<CR>", { desc = "Start DuckyType test" })
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
      require("nvim-treesitter.configs").setup({
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

      -- optional: use treesitter for folding
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = false  -- start unfolded
    end,
  },
  
{
  "neovim/nvim-lspconfig",
  config = function()
    -- Modern LSP setup using vim.lsp.config
    vim.lsp.config("pyright", {
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
    {
      'HiPhish/rainbow-delimiters.nvim',
      config = function()
        vim.g.rainbow_delimiters = {
          strategy = {
            'global',
            'local',
          },
        }
      end
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
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })
    end,
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
