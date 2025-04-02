local M = {}
local parser = require("xdoc.parser")
local util = require("xdoc.util")

local ns = vim.api.nvim_create_namespace("xdoc")
local enabled = true
local original_lines = {}

local function is_empty_comment(text)
  return vim.trim(text) == ""
end

local function make_box(lines)
  if #lines == 0 then return {} end

  local content = vim.tbl_map(function(item) return item.text end, lines)
  local max_width = 0
  for _, line in ipairs(content) do
    max_width = math.max(max_width, #line)
  end

  local virt_lines = {}
  table.insert(virt_lines, { { "┌" .. string.rep("─", max_width + 2) .. "┐", "Comment" } })
  for _, line in ipairs(content) do
    local padding = max_width - #line
    table.insert(virt_lines, {
      { "│ " .. line .. string.rep(" ", padding) .. " │", "Comment" },
    })
  end
  table.insert(virt_lines, { { "└" .. string.rep("─", max_width + 2) .. "┘", "Comment" } })

  return virt_lines
end

local function get_blocks()
  local parsed = parser.parse_buffer()
  if #parsed == 0 then return {} end

  local blocks = {}
  local block = {}
  local last_lnum = nil

  for _, item in ipairs(parsed) do
    if last_lnum and item.lnum ~= last_lnum + 1 then
      table.insert(blocks, block)
      block = {}
    end
    table.insert(block, item)
    last_lnum = item.lnum
  end

  table.insert(blocks, block)
  return blocks
end

function M.render()
  if not enabled then return end

  local bufnr = vim.api.nvim_get_current_buf()
  original_lines[bufnr] = {}

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for _, block in ipairs(get_blocks()) do
    if #block >= 3 and is_empty_comment(block[1].text) and is_empty_comment(block[#block].text) then
      local top_lnum = block[1].lnum
      local virt = make_box(vim.list_slice(block, 2, #block - 1))

      vim.api.nvim_buf_set_extmark(bufnr, ns, top_lnum, 0, {
        virt_lines = virt,
        virt_lines_above = true,
      })

      for _, line in ipairs(block) do
        local orig = vim.api.nvim_buf_get_lines(bufnr, line.lnum, line.lnum + 1, false)[1]
        original_lines[bufnr][line.lnum] = orig
        vim.api.nvim_buf_set_lines(bufnr, line.lnum, line.lnum + 1, false, { "" })
      end
    end
  end
end

function M.clear()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local backup = original_lines[bufnr]
  if not backup then return end

  for lnum, line in pairs(backup) do
    vim.api.nvim_buf_set_lines(bufnr, lnum, lnum + 1, false, { line })
  end
  original_lines[bufnr] = nil
end

function M.toggle()
  enabled = not enabled
  if not enabled then
    M.clear()
  else
    M.render()
  end
end

return M

