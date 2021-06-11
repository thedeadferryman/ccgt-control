local gui = require('GUI')
local util = require('ui/util')
local tableKeys = require('util').tableKeys
local Mechina = require('mechina')

local ser = require('serialization')

local GenericComponent = Mechina.GenericComponent
local Schema = Mechina.ConfigSchema
local ConfigurableComponent = Mechina.ConfigurableComponent

local function buildComponentSchema(comp)
    assert(type(comp) == 'table', 'Component must be a table')
    assert(comp.is_instance, 'Component must be an object')
    assert(comp:isa(GenericComponent),
           'Component must be an instance of <GenericComponent>')

    local sch = Schema:new()

    sch:addField('___addr__', 'Component address',
                 Schema.EnumField:new(comp:getCompatible()))

    local sers = sch:serialize()

    if comp:isa(ConfigurableComponent) then
        local sch = comp.schema:serialize()

        sch.___addr__ = sers.___addr__

        return sch
    else
        return sch:serialize()
    end
end

local function buildSchemaGrid(container, x, y, width, height, schema)
    assert(type(schema) == 'table', 'Schema must be a table')

    local names = tableKeys(schema)

    print(ser.serialize(schema, true))

    local fieldCount = #names

    local grid = container:addChild(gui.layout(x, y, width, height, 2,
                                               fieldCount))

    util.forEachCell(grid, function(col, row)
        grid:setFitting(col, row, true, false, 2, 2)
    end)

    local getters = {}

    for i = 1, fieldCount do
        local fn = names[i]
        local field = schema[fn]


        local fLabel = grid:setPosition(1, i, grid:addChild(
                                            gui.label(1, 1, 1, 1, 0x000000,
                                                      field.name .. ": ")))

        fLabel:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                            gui.ALIGNMENT_VERTICAL_CENTER)

        if field.type.typename == 'enum' then
            local fSel = grid:setPosition(2, i, grid:addChild(
                                              gui.comboBox(1, 1, 1, 3, 0x000000,
                                                           0xffffff, 0xdddddd,
                                                           0x666666)))

            for _, value in ipairs(field.type.options) do
                fSel:addItem(value)
            end

            getters[fn] = function()
                local item = fSel:getItem(fSel.selectedItem)
                return item and item.text or ''
            end
        else
            local fSel = grid:setPosition(2, i,
                                          grid:addChild(
                                              gui.input(1, 1, 1, 3, 0x000000,
                                                        0xffffff, 0xaaaaaa,
                                                        0x212121, 0xffffff, '',
                                                        "type something here")))

            getters[fn] = function() return fSel.text end
        end
    end

    return {grid = grid, getters = getters}
end

local function buildButtonsGrid(grid)
    local btnGrid = grid:addChild(gui.layout(1, 1, 1, 1, 2, 1))

    util.setAutoFit(btnGrid, 4, 0)

    local okBtn = btnGrid:setPosition(1, 1,
                                      btnGrid:addChild(
                                          gui.roundedButton(1, 1, 1, 1,
                                                            0xcccc66, 0x000000,
                                                            0x7a7a3d, 0x000000,
                                                            "CONFIRM")))

    local quitBtn = btnGrid:setPosition(2, 1,
                                        btnGrid:addChild(
                                            gui.roundedButton(1, 1, 1, 1,
                                                              0xcc9966,
                                                              0xffffff,
                                                              0x663333,
                                                              0xffffff, "QUIT")))

    return {grid = btnGrid, buttons = {ok = okBtn, quit = quitBtn}}
end

local function ConfigurerGUI(name, comp)
    local app = gui.application()

    app:addChild(gui.panel(1, 1, app.width, app.height, 0x000000))

    local wnd = util.addWindow(app, name)

    local schema = buildComponentSchema(comp)

    local wndGrid = wnd:addChild(gui.layout(1, 1, wnd.width, wnd.height, 1, 2))

    local sGrid = buildSchemaGrid(wndGrid, 1, 1, 1, 1, schema)
    local btnGrid = buildButtonsGrid(wndGrid)

    wndGrid:setRowHeight(1, gui.SIZE_POLICY_RELATIVE, 0.9)
    wndGrid:setRowHeight(2, gui.SIZE_POLICY_RELATIVE, 0.1)

    util.setAutoFit(wndGrid, 0, 0)

    wndGrid:setPosition(1, 1, sGrid.grid)
    wndGrid:setPosition(1, 2, btnGrid.grid)

    return {app = app, fieldData = sGrid.getters, buttons = btnGrid.buttons}
end

return ConfigurerGUI
