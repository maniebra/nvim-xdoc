local M = {}

function M.setup()
  vim.api.nvim_create_user_command("XDocToggle", function()
    require("xdoc.renderer").toggle()
  end, {})
end

return M
