# uterm

Microscopic floating terminal for neovim with nothing special.

## Config

To configure, just call setup:

```lua
require('uterm').setup({})
```

Options can be given to `setup`, for example:

```lua
require('uterm').setup{
    -- default terminal that will open $SHELL
    default = {},

    -- Open lazygit in a floating window
    lazygit = {
        cmd = 'lazygit',
    },
}
```
