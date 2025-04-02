local M = {}

function M.get_comment_prefix()
  local ft = vim.bo.filetype
  local map = require("xdoc.config").options.comment_syntax
  return map[ft] or "//" 
end

function M.startswith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

return M
