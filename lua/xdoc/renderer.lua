local M = {}

local parser = require("xdoc.parser")
local util = require("xdoc.util")

local ns = vim.api.nvim_create_namespace("xdoc")
local enabled = true


local function get_style_for_line(text)
  local trimmed = vim.trim(text)

  if vim.startswith(trimmed, "# ") then return "XDocHeader" end
  if vim.startswith(trimmed, "## ") then return "XDocSubheader" end
  if vim.startswith(trimmed, "### ") then return "XDocMinor" end
  if vim.startswith(trimmed, "- ") then return "XDocBullet" end

  return "XDocText"
end


--- Build a box-style virt_lines block
---@param lines string[]
---@return table
local function build_box(lines)
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, #line.text)
  end

  local virt_lines = {}
  table.insert(virt_lines, {
    { "┌", "Comment" },
    { string.rep("─", max_width + 2), "Comment" },
    { "┐", "Comment" },
  })

  for _, line in ipairs(lines) do
    local pad = max_width - #line.text
    local hl = get_style_for_line(line.text)

    table.insert(virt_lines, {
      { "│ ", "Comment" },
      { line.text .. string.rep(" ", pad), hl },
      { " │", "Comment" },
    })
  end

  table.insert(virt_lines, {
    { "└", "Comment" },
    { string.rep("─", max_width + 2), "Comment" },
    { "┘", "Comment" },
  })

  return virt_lines
end


--- Group parsed comment lines into contiguous blocks
---@param lines table
---@return table[] blocks
local function group_blocks(lines)
  local blocks = {}
  local current = {}
  local last_lnum = nil

  for _, item in ipairs(lines) do
    if last_lnum and item.lnum ~= last_lnum + 1 then
      table.insert(blocks, current)
      current = {}
    end
    table.insert(current, item)
    last_lnum = item.lnum
  end

  if #current > 0 then
    table.insert(blocks, current)
  end

  return blocks
end

--- Main rendering function
function M.render()
  if not enabled then return end

  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local comment_lines = parser.parse_buffer()
  local blocks = group_blocks(comment_lines)

  for _, block in ipairs(blocks) do
    if #block >= 3 and util.is_empty_comment(block[1].text) and util.is_empty_comment(block[#block].text) then
      local box_lines = vim.list_slice(block, 2, #block - 1)
      local box = build_box(box_lines)

      -- Place the box above the first comment
      vim.api.nvim_buf_set_extmark(bufnr, ns, block[1].lnum, 0, {
        virt_lines = box,
        virt_lines_above = true,
        hl_mode = "combine",
      })

      -- Fold the original comment block
      local fold_start = block[2].lnum + 1
      local fold_end = block[#block - 1].lnum + 1
      if fold_end >= fold_start then
        vim.cmd(fold_start .. "," .. fold_end .. "fold")
      end
    end
  end
end

--- Clears all virtual highlights and folds created by xdoc
function M.clear()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  vim.cmd("normal! zE") -- clear all manual folds
end

--- Toggles rendering state
function M.toggle()
  enabled = not enabled
  if enabled then
    M.render()
  else
    M.clear()
  end
end


return M

