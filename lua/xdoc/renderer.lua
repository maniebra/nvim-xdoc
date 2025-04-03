local M = {}

local parser = require("xdoc.parser")
local util = require("xdoc.util")

local ns = vim.api.nvim_create_namespace("xdoc")
local enabled = true


local function get_highlight(text)
  local trimmed = vim.trim(text)

  if vim.startswith(trimmed, "# ") then return "XDocHeader" end
  if vim.startswith(trimmed, "## ") then return "XDocSubheader" end
  if vim.startswith(trimmed, "### ") then return "XDocMinor" end
  if vim.startswith(trimmed, "- ") then return "XDocBullet" end

  return "XDocText"
end

local function build_box(lines)
  local win_width = vim.api.nvim_win_get_width(0)
  local num_width = vim.wo.number and vim.wo.numberwidth or 0
  local fold_width = tonumber(vim.wo.foldcolumn) or 0
  local sign_width = (vim.wo.signcolumn == "no" and 0 or 2)

  local effective_width = win_width - num_width - fold_width - sign_width
  if effective_width < 10 then
    effective_width = 10
  end

  local content_width = effective_width - 2 
  local virt_lines = {}

  table.insert(virt_lines, {
    { "┌" .. string.rep("─", content_width) .. "┐", "Comment" }
  })

  local function wrap_text(text, width)
    local wrapped = {}
    local current = ""
    local current_width = 0

    for i = 1, #text do
      local char = text:sub(i, i)
      local char_width = vim.fn.strdisplaywidth(char)

      if current_width + char_width > width then
        table.insert(wrapped, current)
        current = char
        current_width = char_width
      else
        current = current .. char
        current_width = current_width + char_width
      end
    end

    if current ~= "" then
      table.insert(wrapped, current)
    end

    return wrapped
  end

  for _, line in ipairs(lines) do
    local text = line.text
    local hl = get_highlight(text)
    local wrapped_lines = wrap_text(text, content_width)

    for _, wline in ipairs(wrapped_lines) do
      local display_width = vim.fn.strdisplaywidth(wline)
      local pad = content_width - display_width
      local padded = wline .. string.rep(" ", pad)

      table.insert(virt_lines, {
        { "│", "Comment" },
        { padded, hl },
        { "│", "Comment" },
      })
    end
  end

  table.insert(virt_lines, {
    { "└" .. string.rep("─", content_width) .. "┘", "Comment" }
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

