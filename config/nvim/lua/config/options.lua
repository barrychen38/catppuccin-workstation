-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- TypeScript 7 native LSP. Default is vtsls.
vim.g.lazyvim_ts_lsp = "tsc"

local function useSystemClipboard()
    vim.opt.clipboard = "unnamedplus"
end

vim.g.autoformat = false

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

useSystemClipboard()

vim.api.nvim_create_autocmd("VimEnter", {
    callback = useSystemClipboard,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = useSystemClipboard,
})

local hasOsc52, osc52 = pcall(require, "vim.ui.clipboard.osc52")

if hasOsc52 and vim.env.SSH_TTY then
    local function paste()
        return {
            vim.fn.split(vim.fn.getreg(""), "\n"),
            vim.fn.getregtype(""),
        }
    end

    vim.g.clipboard = {
        name = "OSC 52",
        copy = {
            ["+"] = osc52.copy("+"),
            ["*"] = osc52.copy("*"),
        },
        paste = {
            ["+"] = paste,
            ["*"] = paste,
        },
    }
end
