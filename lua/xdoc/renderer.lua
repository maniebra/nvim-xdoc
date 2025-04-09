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

--- Build a box-style virt_lines block
---@param lines string[]
---@return table
local function build_box(lines)
    local win_width = vim.api.nvim_win_get_width(0)
    local num_width = vim.wo.number and vim.wo.numberwidth or 0
    local fold_width = tonumber(vim.wo.foldcolumn) or 0
    local sign_width = (vim.wo.signcolumn == "no" and 0 or 2)

    local effective_width = win_width - num_width - fold_width - sign_width
    if effective_width < 10 then effective_width = 10 end -- safety guard

    local content_width = effective_width - 2             -- account for vertical borders
    local virt_lines = {}

    -- top border
    table.insert(virt_lines, {
        { "┌" .. string.rep("─", content_width) .. "┐", "Comment" }
    })

    for _, line in ipairs(lines) do
        local text = line.text
        local hl = get_highlight(text)
        local display_width = vim.fn.strdisplaywidth(text)
        if display_width > content_width then
            local truncated = ""
            local remaining_width = content_width - 3 -- reserve space for "..."
            local i = 1
            while remaining_width > 0 and i <= #text do
                local char = text:sub(i, i)
                local char_width = vim.fn.strdisplaywidth(char)
                if char_width <= remaining_width then
                    truncated = truncated .. char
                    remaining_width = remaining_width - char_width
                else
                    break
                end
                i = i + 1
            end
            text = truncated .. "..."
            display_width = vim.fn.strdisplaywidth(text)
        end

        local pad = content_width - display_width
        local padded = text .. string.rep(" ", pad)
        table.insert(virt_lines, {
            { "│", "Comment" },
            { padded, hl },
            { "│", "Comment" },
        })
    end

    -- bottom border
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

-- New helper function to detect doc comment blocks (e.g., with @param, @return, etc.)
local function is_doc_block(block)
    for _, item in ipairs(block) do
        if item.text:match("^%s*@%w+") then
            return true
        end
    end
    return false
end

--- Main rendering function
function M.render()
    if not enabled then return end

    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local comment_lines = parser.parse_buffer()
    local blocks = group_blocks(comment_lines)

    for _, block in ipairs(blocks) do
        local is_empty_box = (#block >= 3 and util.is_empty_comment(block[1].text) and util.is_empty_comment(block[#block].text))
        local is_doc = is_doc_block(block)

        if is_empty_box or is_doc then
            local content
            if is_empty_box then
                content = vim.list_slice(block, 2, #block - 1)
            else
                content = block
            end

            local box = build_box(content)

            local virt_opts = {
                virt_lines = box,
                hl_mode = "combine",
                virt_lines_above = block[1].lnum ~= 0, -- show below if first line
            }

            vim.api.nvim_buf_set_extmark(bufnr, ns, block[1].lnum, 0, virt_opts)

            if is_empty_box then
                local fold_start = block[2].lnum + 1
                local fold_end = block[#block - 1].lnum + 1
                if fold_end >= fold_start then
                    vim.cmd(fold_start .. "," .. fold_end .. "fold")
                end
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
