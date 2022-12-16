# nvim-strict

Strictly enforce configurable, best-practice code style with this [Neovim](https://neovim.io/) plugin.

![nvim-strict demo](demo.png)

## Introduction

Strict (or nvim-strict) is an all-Lua wrapper for a collection of regular expressions which combine to provide lightweight, IDE-like code style hints and formatting. Strict is not a code formatting plugin; it formats everything around code.

## Features

* Highlight deeply-nested code
* Highlight overlong lines
* Highlight and automatically remove trailing whitespace
* Highlight and automatically convert tab / space indentation
* Include and exclude filetypes
* Actions are mappable
* Highly configurable
* Blazingly fast

## Installation

Strict can be installed using any package manager. Here is an example using [packer.nvim](https://github.com/wbthomason/packer.nvim) to install Strict using the default configuration.

```lua
use({
    'emileferreira/nvim-strict',
    config = function()
        require('strict').setup()
    end
})
```

## Configuration

Strict comes with batteries included and (IMHO) sane defaults. The default configuration is shown below which can be modified and passed to the `setup` function to override the default values.

```lua
local default_config = {
    included_filetypes = nil,
    excluded_filetypes = nil,
    deep_nesting = {
        highlight = true,
        highlight_group = 'DiffDelete',
        depth_limit = 3,
        ignored_characters = nil,
        detect_indentation = true
    },
    overlong_lines = {
        highlight = true,
        highlight_group = 'DiffDelete',
        length_limit = 80
    },
    trailing_whitespace = {
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
    }
}
```

## Contributing

Pull requests, bug reports and feature requests are welcomed.
