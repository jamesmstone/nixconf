local g = vim.g
local o = vim.opt

o.autoread = true
o.swapfile = true
o.dir = '/tmp'
o.smartcase = true
o.laststatus = 3
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.relativenumber = true
o.wrap = false
o.clipboard = "unnamedplus"
o.encoding = "utf-8"
o.hidden = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.updatetime = 300
o.termguicolors = true
o.mouse = "a"
o.splitbelow = true
o.splitright = true
o.scrolloff = 9
o.cursorline = true
o.scroll = 6
o.signcolumn = "yes"
o.pumheight = 16
o.winborder = "single"
o.langmap =
[[ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz]]

-- Reload files changed on disk. `autoread` only refreshes on certain events,
-- so nudge it with `checktime` whenever we regain focus or stop typing. This
-- never clobbers unsaved edits — Neovim keeps modified buffers and warns instead.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("auto_reload", { clear = true }),
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

g.mapleader = " "

vim.cmd.colorscheme("gxvjbox")
