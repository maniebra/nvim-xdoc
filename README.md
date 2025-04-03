# NVIM-XDoc

> Markdown-style notes & docs embedded in your code – beautifully rendered inside Neovim.


## ✨ What is nvim-xdoc?

`nvim-xdoc` is a lightweight Neovim plugin that turns specially-formatted comments into rendered, boxed virtual text. Think of it like Markdown for your comments – but rendered right inside your code, folding the raw comments away and replacing them with stylized visual blocks.

Perfect for:
- Writing inline documentation
- Making TODO sections pop
- Embedding notes, instructions, or explanations right in your codebase

---

## 📸 Example

```lua
-- 
-- # Quick Start
-- ## How to use xdoc
-- - Write structured comments
-- - They get rendered as boxes
--
```

⬇️ becomes

```
┌──────────────────────────────┐
│ # Quick Start                │
│ ## How to use xdoc           │
│ - Write structured comments  │
│ - They get rendered as boxes │
└──────────────────────────────┘
```

The raw comments are folded away for a clean view!

---

## ⚙️ Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "maniebra/nvim-xdoc",
  config = function()
    require("xdoc").setup()
  end,
}
```

Or with `packer`:

```lua
use {
  "maniebra/nvim-xdoc",
  config = function()
    require("xdoc").setup()
  end,
}
```

---

## 🔧 Configuration

```lua
require("xdoc").setup({
  auto_render = true,
  comment_syntax = {
    lua = "--",
    python = "#",
    rust = "//",
    -- add your filetypes
  },
  style = {
    header1 = { fg = "#FFD700", bold = true, italic = true },
    bullet = { fg = "#00FFFF" },
  }
})
```

---

## 🧠 How It Works

- Comments are parsed based on your filetype’s syntax.
- Comments surrounded by blank comment lines are grouped and parsed.
- If formatted with Markdown-style headings (`#`, `##`, `-`), they're highlighted accordingly.
- The raw comment block is **folded**, and a rendered **virtual text box** is shown instead.

---

## 🚀 Usage

Once set up, `xdoc` just works when you enter **Normal mode** or when the **window is resized**.

You can manually toggle the preview with:

```lua
require("xdoc").toggle_preview()
```

---

## 🎨 Highlight Groups

You can customize these in your colorscheme or config:

- `XDocHeader` – for `# Heading`
- `XDocSubheader` – for `## Subheading`
- `XDocMinor` – for `### Minor heading`
- `XDocBullet` – for `- list items`
- `XDocText` – fallback text style

---

## 🧪 Supported Languages (out of the box)

- Lua
- Python
- JavaScript / TypeScript
- C / C++ / Java / Kotlin / Go / Rust
- Shell (`.sh`)

Feel free to extend `comment_syntax` in your config!

---

## 📣 Contributing

PRs, issues, and suggestions are always welcome! Let's make Neovim commenting more elegant together. 🖋️

