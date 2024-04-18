local Term = require("uterm.uterm")

---@class uterm
---@field terms table<string, Term>
local M = {
	terms = {},
}

---Setup!
---@param opts table
function M.setup(opts)
	opts = opts or {
		default = {},
	}

	for n, o in pairs(opts) do
		M.new_named(n, o)
	end
end

---Open a terminal, if no name is given the default terminal is opened.
---@param name string?
function M.open(name)
	local t = M.terms[name or "default"]
	t:open()
end

---Close a terminal, if no name is given the default terminal is closed.
---@param name string?
function M.close(name)
	local t = M.terms[name or "default"]
	t:close()
end

---Toggle the open/close state of a terminal, if no name is given the default
---terminal is toggled.
---@param name string?
function M.toggle(name)
	local t = M.terms[name or "default"]
	t:toggle()
end

---Create a new named terminal instance that can later be used.
---@param name string
---@param opts TermConfig
function M.new_named(name, opts)
	M.terms[name] = Term:new(opts)
end

return M

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
