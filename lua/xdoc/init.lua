local M = {}

local config = require("xdoc.config")
local renderer = require("xdoc.renderer")
local commands = require("xdoc.commands")

function M.setup(user_config)
  config.setup(user_config)
  commands.setup()

  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:n",    callback = function()
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
end

function M.toggle_preview()
  renderer.toggle()
end

return M

