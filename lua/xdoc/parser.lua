local M = {}
local util = require("xdoc.util")

function M.parse_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local comment_prefix = util.get_comment_prefix()
  local pattern = "^%s*" .. vim.pesc(comment_prefix) .. "%s?(.*)"

  local parsed = {}

  for i, line in ipairs(lines) do
    local content = line:match(pattern)
    if content then
      table.insert(parsed, { lnum = i - 1, text = content })
    end
  end

  return parsed
end

return M
