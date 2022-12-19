local strict = {}
local strict_augroup = vim.api.nvim_create_augroup('strict', { clear = true })
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
    }
}

local function highlight_deep_nesting(
    highlight_group, depth_limit, ignored_trailing_characters,
    ignored_leading_characters, match_priority)
    local indent_size = vim.bo.shiftwidth
    local regex = string
        .format('\\([%s]\\)\\@<!\\n^\\s\\{%s}\\zs\\s\\+\\(\\s*[%s]\\)\\@!',
            ignored_trailing_characters or '',
            depth_limit * indent_size,
            ignored_leading_characters or '')
    vim.fn.matchadd(highlight_group, regex, match_priority)
end

local function highlight_trailing_whitespace(highlight_group, match_priority)
    local regex = '\\s\\+$'
    vim.fn.matchadd(highlight_group, regex, match_priority)
end

local function highlight_trailing_empty_lines(highlight_group, match_priority)
    local regex = '\\($\\n\\s*\\)\\+\\%$'
    vim.fn.matchadd(highlight_group, regex, match_priority)
end

local function highlight_overlong_lines(
    highlight_group, length_limit, match_priority)
    local regex = '\\%>' .. length_limit .. 'v.\\+'
    vim.fn.matchadd(highlight_group, regex, match_priority)
end

local function highlight_tab_indentation(highlight_group, match_priority)
    local regex = string.format('\\(^\\s*\\)\\@<=\\t')
    vim.fn.matchadd(highlight_group, regex, match_priority)
end

local function highlight_space_indentation(highlight_group, match_priority)
    local regex = string.format('\\(^\\s*\\)\\@<= ')
    vim.fn.matchadd(highlight_group, regex, match_priority)
end

local function contains(table, string)
    if type(table) == 'string' then return string == table
    elseif type(table) == 'table' then
        for _, element in ipairs(table) do
            if string == element then return true end
        end
    end
    return false
end

local function is_included_filetype(included_filetypes, excluded_filetypes)
    local filetype = vim.bo.filetype
    if contains(excluded_filetypes, filetype) then return false end
    if included_filetypes ~= nil and not
        contains(included_filetypes, filetype) then return false end
    return true
end

local function configure_highlights(config)
    if config.trailing_whitespace.highlight then
        highlight_trailing_whitespace(
            config.trailing_whitespace.highlight_group,
            config.match_priority)
    end
    if config.trailing_empty_lines.highlight then
        highlight_trailing_empty_lines(
            config.trailing_empty_lines.highlight_group,
            config.match_priority)
    end
    if config.overlong_lines.highlight then
        highlight_overlong_lines(
            config.overlong_lines.highlight_group,
            config.overlong_lines.length_limit,
            config.match_priority)
    end
    if config.deep_nesting.highlight then
        highlight_deep_nesting(
            config.deep_nesting.highlight_group,
            config.deep_nesting.depth_limit,
            config.deep_nesting.ignored_trailing_characters,
            config.deep_nesting.ignored_leading_characters,
            config.match_priority)
    end
    if config.tab_indentation.highlight then
        highlight_tab_indentation(
            config.tab_indentation.highlight_group,
            config.match_priority)
    end
    if config.space_indentation.highlight then
        highlight_space_indentation(
            config.space_indentation.highlight_group,
            config.match_priority)
    end
    vim.api.nvim_create_autocmd('BufWinLeave', {
        group = strict_augroup,
        buffer = 0,
        callback = function()
            vim.fn.clearmatches()
            return true
        end
    })
end

local function silent_cmd(command)
    local view = vim.fn.winsaveview()
    vim.cmd('silent keepjumps keeppatterns ' .. command)
    vim.fn.winrestview(view)
end

function strict.split_overlong_lines()
    silent_cmd('g/\\%>' .. vim.bo.textwidth .. 'v.\\+/normal gwl')
end

function strict.remove_trailing_whitespace()
    silent_cmd('%s/\\s\\+$//e')
end

function strict.remove_trailing_empty_lines()
    silent_cmd('%s/\\($\\n\\s*\\)\\+\\%$//e')
end

function strict.convert_tabs_to_spaces()
    local spaces = ''
    for _ = 1, vim.bo.shiftwidth, 1 do
        spaces = spaces .. ' '
    end
    silent_cmd('%s/\\(^\\s*\\)\\@<=\\t/' .. spaces .. '/ge')
end

function strict.convert_spaces_to_tabs()
    silent_cmd('%s/\\(^\\s*\\)\\@<=[ ]\\{' .. vim.bo.shiftwidth .. '}/\\t/ge')
end

local function configure_formatting(config)
    if config.trailing_whitespace.remove_on_save then
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = strict_augroup,
            buffer = 0,
            callback = strict.remove_trailing_whitespace
        })
    end
    if config.trailing_empty_lines.remove_on_save then
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = strict_augroup,
            buffer = 0,
            callback = strict.remove_trailing_empty_lines
        })
    end
    if config.tab_indentation.convert_on_save then
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = strict_augroup,
            buffer = 0,
            callback = strict.convert_tabs_to_spaces
        })
    end
    if config.space_indentation.convert_on_save then
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = strict_augroup,
            buffer = 0,
            callback = strict.convert_spaces_to_tabs
        })
    end
    if config.overlong_lines.split_on_save then
        vim.bo.textwidth = config.overlong_lines.length_limit
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = strict_augroup,
            buffer = 0,
            callback = strict.split_overlong_lines
        })
    end
end

local function autocmd_callback(config)
    if contains(config.excluded_buftypes, vim.bo.buftype) then return end
    if not is_included_filetype(config.included_filetypes,
        config.excluded_filetypes) then return end
    configure_highlights(config)
    configure_formatting(config)
end

local function override_config(default, user)
    if user == nil then return default end
    for key, value in pairs(user) do
        if type(default[key]) == 'table' then
            override_config(default[key], value)
        else default[key] = value end
    end
    return default
end

function strict.setup(user_config)
    local config = override_config(default_config, user_config)
    vim.api.nvim_create_autocmd('BufEnter', {
        group = strict_augroup,
        callback = function() autocmd_callback(config) end
    })
end

return strict
