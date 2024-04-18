local U = {}

---Check whether the window is valid
---@param win number Window ID
---@return boolean
function U.is_win_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

---Check whether the buffer is valid
---@param buf number Buffer ID
---@return boolean
function U.is_buf_valid(buf)
  return buf and vim.api.nvim_buf_is_loaded(buf)
end

---Convert a given command, which is either a function (that we call here), a
--string or a list of strings
---@param cmd (fun(): (string | string[])) | string | string[]
function U.make_cmd(cmd)
  -- if it is a function, call it to get the actual command
  if type(cmd) == 'function' then
    cmd = cmd()
  end

  -- If it is a table (i.e. {'ls', '-la'}), concatenate to create the actual
  -- command
  if type(cmd) == 'table' then
    cmd = table.concat(cmd, ' ')
  end

  -- and here, all that it can be is a string
  return cmd
end

---Calculate the dimensions for the floating window using the given ratios.
---@param opts TermDimensions
---@return { width: integer, height: integer, col: integer, row: integer }
function U.calc_dimensions(opts)
  -- get lines and columns
  local cl = vim.o.columns
  local ln = vim.o.lines

  -- calculate our floating window size
  local width = math.ceil(cl * opts.width)
  local height = math.ceil(ln * opts.height - 4)

  -- and its starting position
  local col = math.ceil((cl - width) * opts.x)
  local row = math.ceil((ln - height) * opts.y - 1)

  return {
    width = width,
    height = height,
    col = col,
    row = row,
  }
end

return U

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
