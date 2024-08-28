local U = require 'uterm.utils'

---@class TermDimensions
---@field width integer
---@field height integer
---@field x integer
---@field y integer

---@type TermDimensions
local default_dimensions = { width = 0.8, height = 0.8, x = 0.5, y = 0.5 }

---@class TermConfig
---@field cmd string | string[]
---@field auto_close boolean
---@field dimensions TermDimensions
---@field ft string
---@field border string
---@field title string?
---@field listed boolean
---@field bufopts table<string, any>?
---@field mappings {[1]: string, [2]: string, mode: string, opts: table?}[]?
---@field unmappings {[1]: string, mode: string, opts: table?}[]?

---@type TermConfig
local default_options = {
  dimensions = default_dimensions,
  border = 'single',
  ft = 'myterm',
  cmd = (os.getenv 'SHELL' or error 'no SHELL defined!'), -- NOTE: use `error` for this? It is fatal...
  auto_close = true,
  listed = false,
}

---@class Term
---@field buf integer?
---@field win integer?
---@field term integer?
---@field opts TermConfig
local Term = {}

---Get the memoized buffer or create a new one.
---@return integer
function Term:_get_buf()
  -- In case we have a valid buffer saved, return it instead of creating a new one
  if U.is_buf_valid(self.buf) then
    return self.buf
  end

  local buf = vim.api.nvim_create_buf(self.opts.listed, true)
  -- this ensures filetype is set on first run
  vim.api.nvim_buf_set_option(buf, 'filetype', self.opts.ft)

  -- set options for the buffer
  for k, v in pairs(self.opts.bufopts or {}) do
    vim.api.nvim_buf_set_option(buf, k, v)
  end

  -- set keymaps for the buffer
  for _, v in ipairs(self.opts.mappings or {}) do
    vim.keymap.set(v.mode or 'n', v[1], v[2], vim.tbl_extend('force', v.opts or {}, { buffer = buf }))
  end

  -- unset keymaps for the buffer
  for _, v in ipairs(self.opts.unmappings or {}) do
    vim.keymap.del(v.mode or 'n', v[1], vim.tbl_extend('force', v.opts or {}, { buffer = buf }))
  end

  return buf
end

---Create a new floating window
---@param buf integer
---@return integer
function Term:_new_win(buf)
  local dim = U.calc_dimensions(self.opts.dimensions)

  local win = vim.api.nvim_open_win(buf, true, {
    border = self.opts.border,
    relative = 'editor',
    style = 'minimal',
    width = dim.width,
    height = dim.height,
    col = dim.col,
    row = dim.row,
  })

  -- A.nvim_win_set_option(win, 'winhl', ('Normal:%s'):format(cfg.hl))
  -- A.nvim_win_set_option(win, 'winblend', cfg.blend)

  return win
end

function Term:_on_exit(job_id, code)
  -- non-zero exit codes don't kill the terminal
  if self.opts.auto_close and code == 0 then
    self:close(true)
  end
end

function Term:_spawn()
  local cmd = U.make_cmd(self.opts.cmd)

  -- spawn the command!
  -- We set a callback for when it closes because we need to cleanup things.
  self.term = vim.fn.termopen(cmd, {
    on_exit = function(...)
      self:_on_exit(...)
    end,
  })

  -- This prevents the filetype being changed to `term` instead of `FTerm` when
  -- closing the floating window
  vim.api.nvim_buf_set_option(self.buf, 'filetype', self.opts.ft)

  -- enter the terminal window (which should already be created and active)
  return self:_prompt()
end

---Enter insert mode. By default we enter the terminal in normal mode, which is
--not what we want.
function Term:_prompt()
  vim.cmd 'startinsert'
end

---Create a new instance of a terminal.
---@param opts table?
---@return Term
function Term:new(opts)
  opts = vim.tbl_deep_extend('force', default_options, opts or {})

  return setmetatable({ opts = opts }, { __index = self })
end

function Term:open()
  -- Before everything, check if we have a memoized window (and as such a buffer
  -- as well). If we do, just open it directly.
  if U.is_win_valid(self.win) then
    return vim.api.nvim_set_current_win(self.win)
  end

  -- TODO: save cursor?

  -- No memoized window, check the state

  -- To open the terminal, we need to get a buffer for it. This should be
  -- memoized so that the same terminal session can be opened and closed without
  -- killing it.
  local buf = self:_get_buf()

  -- Then we need a floating window for it. This window should be memoized
  -- independently from the buffer, as closing the window does not mean that we
  -- are killing the terminal. Here we always create a new one, as the check at
  -- the top means a valid window will be used directly.
  local win = self:_new_win(buf)

  -- Buffer is memoized, which means we are toggling the terminal which was
  -- started already.
  if self.buf == buf then
    -- Save the window and enter it
    self.win = win
    return self:_prompt()
  end

  -- new buffer and window, create the actual terminal (spawn process)
  self.buf = buf
  self.win = win

  return self:_spawn()
end

function Term:close(force)
  -- first check if the window is valid, if it is not there is nothing to close.
  if not U.is_win_valid(self.win) then
    return
  end

  -- close the floating window and reset our handle
  vim.api.nvim_win_close(self.win, true)
  self.win = nil

  if force then
    if U.is_buf_valid(self.buf) then
      -- delete the buffer and reset our handle
      vim.api.nvim_buf_delete(self.buf, { force = true })
      self.buf = nil

      -- kill the spawned process and reset our handle
      vim.fn.jobstop(self.term)
      self.term = nil
    end
  end

  -- TODO: restore cursor?
end

---Toggle if the terminal is open.
function Term:toggle()
  if U.is_win_valid(self.win) then
    return self:close()
  end

  self:open()
end

return Term

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
