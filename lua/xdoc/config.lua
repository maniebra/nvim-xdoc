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
    java = "//",
    kotlin = "//",
    rust = "//",
    go = "//",
    sh = "#",
  },
  style = {
    header1 = { fg = "#FFD700", bold = true, italic = true },
    header2 = { fg = "#FFD7FF", bold = true, italic = true },
    header3 = { fg = "#FFD700", bold = true, italic = true },
    bullet = { fg = "#00FFFF" },
    text = { bold = false, italic = false }
  }
}

function M.setup(user_config)
  M.options = vim.tbl_deep_extend("force", M.options, user_config or {})
end

return M

