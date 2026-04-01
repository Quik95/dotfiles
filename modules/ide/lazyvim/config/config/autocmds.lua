local highlight_yank_group = vim.api.nvim_create_augroup("highlight-yank", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_yank_group,
  desc = "Highlight when yanking text",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})
