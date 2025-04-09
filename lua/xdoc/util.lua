local M = {}

function M.get_comment_prefix()
  local ft = vim.bo.filetype
  local map = require("xdoc.config").options.comment_syntax
  return map[ft] or "//"
end

function M.startswith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

--- Utility to check if a comment line is empty
---@param text string
---@return boolean
function M.is_empty_comment(text)
  return vim.trim(text) == ""
end


return M
