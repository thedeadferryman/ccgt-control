local gui = require('GUI')

local function forEachCell(grid, cb)
    for col = 1, #grid.columnSizes do
        for row = 1, #grid.rowSizes do cb(col, row) end
    end

end

local function setAutoFit(grid, padx, pady)
    forEachCell(grid, function(col, row)
        grid:setFitting(col, row, true, true, padx, pady)
    end)
end

local function addWindow(app, name, spacing)
    local spacing = spacing or 0.05
    spacing = spacing * app.width

    local width = app.width - (2 * spacing)
    local height = app.height - (2 * spacing)

    local wnd = app:addChild(gui.titledWindow(spacing, spacing, width, height,
                                              name))

    wnd.backgroundPanel.color = 0xffffff

    return wnd
end

return {
    setAutoFit = setAutoFit,
    forEachCell = forEachCell,
    addWindow = addWindow
}
