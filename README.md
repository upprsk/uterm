# uterm

Microscopic floating terminal for neovim with nothing special. Made this plugin
to learn how to make plugins.

## Config

To configure, just call setup:

```lua
require('uterm').setup({})
```

Options can be given to `setup` using the desired name as key and options as
value, for example:

```lua
require('uterm').setup{
    -- default terminal that will open $SHELL
    default = {},

    -- Open lazygit in a floating window
    lazygit = {
        cmd = 'lazygit',
    },
}

--- later
require('uterm').toggle() -- default terminal
require('uterm').toggle('lazygit') -- lazygit terminal
```

The default options for each terminal are:

```lua
{
    -- dimensions relative to the size of the viewport
    dimensions = { width = 0.8, height = 0.8, x = 0.5, y = 0.5 },
    -- view help: nvim_open_win
    border = "single",
    -- filetype to set the terminal buffer
    ft = "myterm",
    -- command to run when opening the terminal
    cmd = os.getenv("SHELL"),
    -- close automatically when the program exits
    auto_close = true,
    -- list the terminal buffer (visible to :buffers)
    listed = false,
    -- table of options to set for the buffer
    bufopts = nil,
    -- list of mappings to define for the buffer
    mappings = nil,
}
```

For the `bufopts`, simply use:

```lua
bufopts = {
    option_1 = 123,
    option_2 = true,
    --- etc
}
```

For the `mappings` use:

```lua
mappings = {
    -- disable double esc for entering normal mode in terminal
    { '<Esc><Esc>', '', mode = 't', opts = { desc = 'disable double esc' } },
}
```
