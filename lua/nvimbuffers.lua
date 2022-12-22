local M = {}

M.buf_prev = function()
  local bufs = vim.t.bufs

  for i, v in ipairs(bufs) do
    if vim.api.nvim_get_current_buf() == v then
      vim.cmd(i == 1 and "b" .. bufs[#bufs] or "b" .. bufs[i - 1])
      break
    end
  end
end

M.buf_next = function()
  local bufs = vim.t.bufs

  for i, v in ipairs(bufs) do
    if vim.api.nvim_get_current_buf() == v then
      vim.cmd(i == #bufs and "b" .. bufs[1] or "b" .. bufs[i + 1])
      break
    end
  end
end

-- Check if current buf is no name buf
M.should_hijack_buf = function(buf)
  local bufnr = buf or vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local bufmodified = vim.api.nvim_buf_get_option(bufnr, "modified")
  local ft = vim.api.nvim_buf_get_option(bufnr, "ft")

  local should_hijack_unnamed = bufname == "" and not bufmodified and ft == ""

  return should_hijack_unnamed
end

M.get_active_buffers = function()
  local listedBuffers = vim.t.bufs
  local result = {}

  for _, buf in ipairs(listedBuffers) do
    if (vim.fn.bufwinnr(buf) >= 0) then table.insert(result, buf) end
  end

  return result
end

M.get_hidden_buffers = function()
  local listedBuffers = vim.t.bufs
  local result = {}

  for _, buf in ipairs(listedBuffers) do
    if (vim.fn.bufwinnr(buf) < 0) then table.insert(result, buf) end
  end

  return result
end

M.only_buffer = function()
  local hiddenBuffers = M.get_hidden_buffers()
  for _, buf in ipairs(hiddenBuffers) do vim.cmd("confirm bd" .. buf) end
end

M.close_noname_buffer = function()
  local buffers = vim.t.bufs

  local bufcount = #buffers
  while (M.should_hijack_buf(vim.api.nvim_get_current_buf()) and bufcount > 0) do
    M.buf_prev()
    bufcount = bufcount - 1
  end

  local hiddenBuffers = M.get_hidden_buffers()
  for _, buf in ipairs(hiddenBuffers) do
    if (M.should_hijack_buf(buf)) then vim.cmd("confirm bd" .. buf) end
  end
end

function M.setup() end

return M
