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

local function match_nest(highlight_group, nest_limit, nest_ignore_chars)
    local indent_size = vim.bo.shiftwidth
    local nest_regex = string
        .format('^\\s\\{%s}\\zs\\s\\+\\(\\s*[%s]\\)\\@!',
            nest_limit * indent_size,
            nest_ignore_chars)
    vim.fn.matchadd(highlight_group, nest_regex, -1)
end

local function match_trailing_whitespace(highlight_group)
    local trailing_whitespace_regex = '\\s\\+$\\|\\t'
    vim.fn.matchadd(highlight_group, trailing_whitespace_regex, -1)
end

local function match_line_length(highlight_group, line_length_limit)
    local line_length_regex = string
        .format('\\%s>%sv.\\+', '%', line_length_limit)
    vim.fn.matchadd(highlight_group, line_length_regex, -1)
end

local strict_augroup = vim.api.nvim_create_augroup('strict', {
    clear = true
})

vim.api.nvim_create_autocmd('BufEnter', {
    group = strict_augroup,
    callback = function()
        local excluded_filetypes = { 'text', 'markdown', 'html' }
        local highlight_group = 'DiffDelete'

        local highlight_deep_nesting = true
        local nesting_limit = 4
        local nesting_ignored_chars = '\'".'

        local highlight_overlong_lines = true
        local line_length_limit = 80

        local highlight_trailing_whitespace = true

        if is_excluded_filetype(excluded_filetypes) then return end
        if highlight_trailing_whitespace then
            match_trailing_whitespace(highlight_group)
        end
        if highlight_overlong_lines then
            match_line_length(highlight_group, line_length_limit)
        end
        if highlight_deep_nesting then
            match_nest(highlight_group, nesting_limit, nesting_ignored_chars)
        end
    end
})
