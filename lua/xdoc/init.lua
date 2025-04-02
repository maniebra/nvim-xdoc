local M = {}

local config = require("xdoc.config")
local renderer = require("xdoc.renderer")
local commands = require("xdoc.commands")

function M.setup(user_config)
    config.setup(user_config)
    commands.setup()

    vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:n",
        callback = function()
            if config.options.auto_render then
                renderer.render()
            end
        end,
    })

    vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "n:*",
        callback = function()
            renderer.clear()
        end,
    })


    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
            vim.api.nvim_set_hl(0, "XDocHeader", config.options.style.header1)
            vim.api.nvim_set_hl(0, "XDocSubheader", config.options.style.header2)
            vim.api.nvim_set_hl(0, "XDocMinor", config.options.style.header3)
            vim.api.nvim_set_hl(0, "XDocBullet", config.options.style.bullet)
            vim.api.nvim_set_hl(0, "XDocText", config.options.style.text)
        end,
    })

    -- Also set them immediately in case your colorscheme is already loaded
    vim.api.nvim_set_hl(0, "XDocHeader", config.options.style.header1)
    vim.api.nvim_set_hl(0, "XDocSubheader", config.options.style.header2)
    vim.api.nvim_set_hl(0, "XDocMinor", config.options.style.header3)
    vim.api.nvim_set_hl(0, "XDocBullet", config.options.style.bullet)
    vim.api.nvim_set_hl(0, "XDocText", config.options.style.text)
end

function M.toggle_preview()
    renderer.toggle()
end

-- THEMING
return M
