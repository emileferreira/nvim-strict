local strict = {}
local strict_augroup = vim.api.nvim_create_augroup('strict', { clear = true })
local match_priority = -1
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

local function highlight_deep_nesting(
    highlight_group, depth_limit, ignored_characters)
    local indent_size = vim.bo.shiftwidth
    local nest_regex = string
        .format('^\\s\\{%s}\\zs\\s\\+\\(\\s*[%s]\\)\\@!',
            depth_limit * indent_size,
            ignored_characters or '')
    return vim.fn.matchadd(highlight_group, nest_regex, match_priority)
end

local function highlight_trailing_whitespace(highlight_group)
    local trailing_whitespace_regex = '\\s\\+$\\|\\t'
    return vim.fn.matchadd(highlight_group, trailing_whitespace_regex,
        match_priority)
end

local function highlight_overlong_lines(highlight_group, line_length_limit)
    local line_length_regex = string
        .format('\\%s>%sv.\\+', '%', line_length_limit)
    return vim.fn.matchadd(highlight_group, line_length_regex, match_priority)
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

local function delete_matches(matches)
    for _, match in ipairs(matches) do
        vim.fn.matchdelete(match)
    end
    return true
end

local function highlight(config)
    local matches = {}
    if config.trailing_whitespace.highlight then
        table.insert(matches, highlight_trailing_whitespace(
            config.trailing_whitespace.highlight_group))
    end
    if config.overlong_lines.highlight then
        table.insert(matches, highlight_overlong_lines(
            config.overlong_lines.highlight_group,
            config.overlong_lines.length_limit))
    end
    if config.deep_nesting.highlight then
        table.insert(matches, highlight_deep_nesting(
            config.deep_nesting.highlight_group,
            config.deep_nesting.depth_limit,
            config.deep_nesting.ignored_characters))
    end
    vim.api.nvim_create_autocmd('BufLeave', {
        group = strict_augroup,
        buffer = 0,
        callback = function() return delete_matches(matches) end
    })
end

local function autocmd_callback(config)
    if not is_included_filetype(config.included_filetypes,
        config.excluded_filetypes) then return end
    highlight(config)
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
