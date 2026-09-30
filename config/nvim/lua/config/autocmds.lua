-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local fileBufferRules = vim.api.nvim_create_augroup("file_buffer_rules", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
    group = fileBufferRules,
    callback = function(event)
        if vim.bo[event.buf].buftype ~= "" then
            return
        end

        vim.wo.colorcolumn = "120"
    end,
})
