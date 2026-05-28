return {
    "neogit",
    cmd = { "Neogit" },
    keys = {
        { "<leader>gg", "<cmd>Neogit<cr>",         desc = "Neogit status" },
        { "<leader>gc", "<cmd>Neogit commit<cr>",  desc = "Neogit commit" },
        { "<leader>gp", "<cmd>Neogit pull<cr>",    desc = "Neogit pull" },
        { "<leader>gP", "<cmd>Neogit push<cr>",    desc = "Neogit push" },
        { "<leader>gl", "<cmd>Neogit log<cr>",     desc = "Neogit log" },
        { "<leader>gb", "<cmd>Neogit branch<cr>",  desc = "Neogit branch" },
    },
    after = function()
        require("neogit").setup({
            integrations = {
                diffview = true,
            },
            graph_style = "unicode",
        })
    end,
}
