return {
    {
        "nvim-telescope/telescope.nvim",
        -- change some options
        config = function()
            require("telescope").setup{
                defaults = {
                    file_ignore_patterns = {"node_modules", ".git", "dist", "build", "logs"}
                },
            }
        end
    }
}
