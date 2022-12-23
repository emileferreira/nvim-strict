# nvim-strict

Strictly enforce configurable, best-practice code style with this Neovim plugin. Expose deep nesting, overlong lines, trailing whitespace, trailing empty lines, todos and inconsistent indentation.

![nvim-strict demo](demo.png)

Strict (or nvim-strict) is an all-Lua wrapper for a collection of regular expressions which combine to provide lightweight, IDE-like code style hints and formatting.

## Features

* Highlights deeply-nested code
* Highlights and splits overlong lines
* Highlights and removes trailing whitespace
* Highlights and removes trailing empty lines
* Highlights and converts tab / space indentation
* Highlights TODO comments
* Formatting functions preserve window, cursor, jumplist and search state
* Include and exclude filetypes
* Mappable functions
* Highly configurable
* Blazingly fast

## Installation

Strict can be installed using any package manager. Here is an example using [packer.nvim](https://github.com/wbthomason/packer.nvim) to install and setup Strict using the default configuration. Note that Strict is only enabled once the `setup` function has been called.

```lua
use({
    'emileferreira/nvim-strict',
    config = function()
        require('strict').setup()
    end
})
```

## Configuration

Strict comes with batteries included and (IMHO) sane defaults. The default configuration is shown below. It can be modified and passed to the `setup` function to override the default values. The configuration options are documented in [strict.txt](doc/strict.txt).

```lua
local default_config = {
    included_filetypes = nil,
    excluded_filetypes = nil,
    excluded_buftypes = { 'help', 'nofile', 'terminal', 'prompt' },
    match_priority = -1,
    deep_nesting = {
        highlight = true,
        highlight_group = 'DiffDelete',
        depth_limit = 3,
        ignored_trailing_characters = nil,
        ignored_leading_characters = nil
    },
    overlong_lines = {
        highlight = true,
        highlight_group = 'DiffDelete',
        length_limit = 80,
        split_on_save = true
    },
    trailing_whitespace = {
        highlight = true,
        highlight_group = 'SpellBad',
        remove_on_save = true,
    },
    trailing_empty_lines = {
        highlight = true,
        highlight_group = 'SpellBad',
        remove_on_save = true,
    },
    space_indentation = {
        highlight = false,
        highlight_group = 'SpellBad',
        convert_on_save = false
    },
    tab_indentation = {
        highlight = true,
        highlight_group = 'SpellBad',
        convert_on_save = true
    },
    todos = {
        highlight = true,
        highlight_group = 'DiffAdd'
    }
}
```

The following is an example of a more forgiving configuration.

```lua
require('strict').setup({
    excluded_filetypes = { 'text', 'markdown', 'html' },
    deep_nesting = {
        depth_limit = 5,
        ignored_trailing_characters = ',',
        ignored_leading_characters = '.'
    },
    overlong_lines = {
        length_limit = 120
    }
})
```

## Bypassing

The highlights of Strict can be temporarily disabled, per window, by the following command.

```
:call clearmatches()
```

The command below writes the current buffer without triggering autocmds which bypasses the format-on-save functionality of Strict.

```
:noa w
```

## Keymaps

The formatting functions are exported for use in keymaps, autocmds or other plugins. Below is a basic example of using the functions in keymaps.

```lua
local strict = require('strict')
local options = { noremap = true, silent = true }
vim.keymap.set('n', '<Leader>tw', strict.remove_trailing_whitespace, options)
vim.keymap.set('n', '<Leader>tl', strict.remove_trailing_empty_lines, options)
vim.keymap.set('n', '<Leader>st', strict.convert_spaces_to_tabs, options)
vim.keymap.set('n', '<Leader>ts', strict.convert_tabs_to_spaces, options)
vim.keymap.set('n', '<Leader>ol', strict.split_overlong_lines, options)
```

## Contributing

Pull requests, bug reports and feature requests are welcomed.
