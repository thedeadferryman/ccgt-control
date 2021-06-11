local function tableKeys(tbl)
    assert(type(tbl) == 'table', 'Argument must be a table')

    local keys = {}

    for key, value in pairs(tbl) do table.insert(keys, key) end

    return keys
end

return {tableKeys = tableKeys}
