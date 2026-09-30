return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    keys = {
      {
        "<leader>nt",
        "<cmd>Neotree toggle<cr>",
        desc = "Toggle Neo-tree",
      },
      {
        "<leader>nr",
        "<cmd>Neotree reveal<cr>",
        desc = "Reveal current file",
      },
      {
        "<leader>ng",
        "<cmd>Neotree git_status<cr>",
        desc = "Neo-tree git status",
      },
    },
    opts = {
      sources = { "filesystem" },
      filesystem = {
        hijack_netrw_behavior = "open_default",
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
        },
      },
      buffers = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
      },
      window = {
        position = "right",
        width = 40,
      },
    },
  },
}
