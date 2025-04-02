local M = {}

M.options = {
  auto_render = true,
  comment_syntax = {
    lua = "--",
    python = "#",
    javascript = "//",
    typescript = "//",
    c = "//",
    cpp = "//",
    sh = "#",
  },
}

function M.setup(user_config)
  M.options = vim.tbl_deep_extend("force", M.options, user_config or {})
end

return M

