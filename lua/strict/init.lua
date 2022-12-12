local strict = {}
local strict_augroup = vim.api.nvim_create_augroup('strict', {
    clear = true
})
local default_config = {
    excluded_filetypes = nil, -- { 'text', 'markdown', 'html' }
    highlight_group = 'DiffDelete',
    deep_nesting = {
        highlight = true,
        depth_limit = 3, -- 4
        ignored_characters = nil -- '\'".'
    },
    overlong_lines = {
        highlight = true,
        length_limit = 80
    },
    trailing_whitespace = {
        highlight = true
    }
}

local function is_excluded_filetype(excluded_filetypes)
    local buffer_filetype = vim.bo.filetype
    if type(excluded_filetypes) == 'string' then
        if buffer_filetype == excluded_filetypes then return true end
    elseif type(excluded_filetypes) == 'table' then
        for _, excluded_filetype in ipairs(excluded_filetypes) do
            if buffer_filetype == excluded_filetype then return true end
        end
    end
    return false
end

local function highlight_deep_nesting(highlight_group, depth_limit,
                                      ignored_characters)
    local indent_size = vim.bo.shiftwidth
    local nest_regex = string
        .format('^\\s\\{%s}\\zs\\s\\+\\(\\s*[%s]\\)\\@!',
            depth_limit * indent_size,
            ignored_characters)
    vim.fn.matchadd(highlight_group, nest_regex, -1)
end

local function highlight_trailing_whitespace(highlight_group)
    local trailing_whitespace_regex = '\\s\\+$\\|\\t'
    vim.fn.matchadd(highlight_group, trailing_whitespace_regex, -1)
end

local function highlight_overlong_lines(highlight_group, line_length_limit)
    local line_length_regex = string
        .format('\\%s>%sv.\\+', '%', line_length_limit)
    vim.fn.matchadd(highlight_group, line_length_regex, -1)
end

local function autocmd_callback(config)
    if is_excluded_filetype(config.excluded_filetypes) then return end
    if config.trailing_whitespace.highlight then
        highlight_trailing_whitespace(config.highlight_group)
    end
    if config.overlong_lines.highlight then
        highlight_overlong_lines(config.highlight_group,
            config.overlong_lines.length_limit)
    end
    if config.deep_nesting.highlight then
        highlight_deep_nesting(config.highlight_group,
            config.deep_nesting.depth_limit,
            config.deep_nesting.ignored_characters)
    end
end

function strict.setup(config)
    config = config or default_config
    vim.api.nvim_create_autocmd('BufEnter', {
        group = strict_augroup,
        callback = function()
            autocmd_callback(config)
        end
    })
end

return strict
