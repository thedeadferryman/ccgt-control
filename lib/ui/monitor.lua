local gui = require('GUI')
local util = require('ui/util')
local WindowedList = require('windowed_list')

-- region Stat Cells

local function gasTurbineCell(grid, col, row, name)
    local oGrid = grid:setPosition(col, row,
                                   grid:addChild(gui.layout(1, 1, 1, 1, 1, 2)))

    util.setAutoFit(oGrid, 0, 0)

    oGrid:setRowHeight(1, gui.SIZE_POLICY_ABSOLUTE, 1)
    oGrid:setRowHeight(2, gui.SIZE_POLICY_RELATIVE, 1)

    local nameLbl = oGrid:setPosition(1, 1, oGrid:addChild(
                                          gui.label(1, 1, 1, 1, 0xffffff, name)))

    nameLbl:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                         gui.ALIGNMENT_VERTICAL_CENTER)

    local gGrid = oGrid:setPosition(1, 2, oGrid:addChild(
                                        gui.layout(1, 1, 1, 1, 2, 1)))

    gGrid:setColumnWidth(1, gui.SIZE_POLICY_RELATIVE, 0.75)

    util.setAutoFit(gGrid, 2, 0)

    local gChart = gGrid:setPosition(1, 1,
                                     gGrid:addChild(
                                         gui.chart(1, 1, 1, 1, 0xffffff,
                                                   0xffffff, 0xffffff, 0xd2a58e,
                                                   0.5, 0.5, "t", "*", true, {})))

    local gInfoGrid = gGrid:setPosition(2, 1, gGrid:addChild(
                                            gui.layout(1, 1, 1, 1, 1, 4)))

    util.setAutoFit(gInfoGrid, 2, 2)

    local gIsEnabled = gInfoGrid:setPosition(1, 1, gInfoGrid:addChild(
                                                 gui.label(1, 1, 1, 1, 0x00ff00,
                                                           "DISABLED")))

    gIsEnabled:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                            gui.ALIGNMENT_VERTICAL_CENTER)

    local gState = gInfoGrid:setPosition(1, 2, gInfoGrid:addChild(
                                             gui.label(1, 1, 1, 1, 0xff0000,
                                                       "UNKNOWN")))

    gState:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                        gui.ALIGNMENT_VERTICAL_CENTER)

    local gRPM = gInfoGrid:setPosition(1, 3, gInfoGrid:addChild(
                                           gui.label(1, 1, 1, 1, 0x00ff00,
                                                     "1204 RPM")))

    gRPM:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                      gui.ALIGNMENT_VERTICAL_CENTER)

    local gBurnup = gInfoGrid:setPosition(1, 4, gInfoGrid:addChild(
                                              gui.label(1, 1, 1, 1, 0xff0000,
                                                        "NO BURNUP")))

    gBurnup:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                         gui.ALIGNMENT_VERTICAL_CENTER)

    return {
        chart = gChart,
        fields = {
            enabled = gIsEnabled,
            state = gState,
            rpm = gRPM,
            burnup = gBurnup
        }
    }
end

local function boilerCell(grid, col, row, name)
    local oGrid = grid:setPosition(col, row,
                                   grid:addChild(gui.layout(1, 1, 1, 1, 1, 2)))

    util.setAutoFit(oGrid, 0, 0)

    oGrid:setRowHeight(1, gui.SIZE_POLICY_ABSOLUTE, 1)
    oGrid:setRowHeight(2, gui.SIZE_POLICY_RELATIVE, 1)

    local nameLbl = oGrid:setPosition(1, 1, oGrid:addChild(
                                          gui.label(1, 1, 1, 1, 0xffffff, name)))

    nameLbl:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                         gui.ALIGNMENT_VERTICAL_CENTER)

    local gGrid = oGrid:setPosition(1, 2, oGrid:addChild(
                                        gui.layout(1, 1, 1, 1, 2, 1)))

    gGrid:setColumnWidth(1, gui.SIZE_POLICY_RELATIVE, 0.75)

    util.setAutoFit(gGrid, 2, 0)

    local gChart = gGrid:setPosition(1, 1,
                                     gGrid:addChild(
                                         gui.chart(1, 1, 1, 1, 0xffffff,
                                                   0xffffff, 0xffffff, 0xd2a58e,
                                                   0.5, 0.5, "t", "T", true, {})))

    local gInfoGrid = gGrid:setPosition(2, 1, gGrid:addChild(
                                            gui.layout(1, 1, 1, 1, 1, 4)))

    util.setAutoFit(gInfoGrid, 2, 2)

    local gIsEnabled = gInfoGrid:setPosition(1, 1, gInfoGrid:addChild(
                                                 gui.label(1, 1, 1, 1, 0x00ff00,
                                                           "ENABLED")))

    gIsEnabled:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                            gui.ALIGNMENT_VERTICAL_CENTER)

    local gHeat = gInfoGrid:setPosition(1, 2, gInfoGrid:addChild(
                                            gui.label(1, 1, 1, 1, 0x00ff00,
                                                      "12005 T")))

    gHeat:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                       gui.ALIGNMENT_VERTICAL_CENTER)

    local gWater = gInfoGrid:setPosition(1, 3, gInfoGrid:addChild(
                                             gui.label(1, 1, 1, 1, 0x00ff00,
                                                       "W: 17500 mB")))

    gWater:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                        gui.ALIGNMENT_VERTICAL_CENTER)

    local gFuel = gInfoGrid:setPosition(1, 4, gInfoGrid:addChild(
                                            gui.label(1, 1, 1, 1, 0xff0000,
                                                      "F: 64 mB")))

    gFuel:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                       gui.ALIGNMENT_VERTICAL_CENTER)

    return {
        chart = gChart,
        fields = {
            enabled = gIsEnabled,
            heat = gHeat,
            water = gWater,
            fuel = gFuel
        }
    }
end

local function steamTurbineCell(grid, col, row, name)
    local oGrid = grid:setPosition(col, row,
                                   grid:addChild(gui.layout(1, 1, 1, 1, 1, 2)))

    util.setAutoFit(oGrid, 0, 0)

    oGrid:setRowHeight(1, gui.SIZE_POLICY_ABSOLUTE, 1)
    oGrid:setRowHeight(2, gui.SIZE_POLICY_RELATIVE, 1)

    local nameLbl = oGrid:setPosition(1, 1, oGrid:addChild(
                                          gui.label(1, 1, 1, 1, 0xffffff, name)))

    nameLbl:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                         gui.ALIGNMENT_VERTICAL_CENTER)

    local gGrid = oGrid:setPosition(1, 2, oGrid:addChild(
                                        gui.layout(1, 1, 1, 1, 2, 1)))

    gGrid:setColumnWidth(1, gui.SIZE_POLICY_RELATIVE, 0.75)

    util.setAutoFit(gGrid, 2, 0)

    local gChart = gGrid:setPosition(1, 1,
                                     gGrid:addChild(
                                         gui.chart(1, 1, 1, 1, 0xffffff,
                                                   0xffffff, 0xffffff, 0xd2a58e,
                                                   0.5, 0.5, "t", "*", true, {})))

    local gInfoGrid = gGrid:setPosition(2, 1, gGrid:addChild(
                                            gui.layout(1, 1, 1, 1, 1, 3)))

    util.setAutoFit(gInfoGrid, 2, 2)

    local gIsEnabled = gInfoGrid:setPosition(1, 1, gInfoGrid:addChild(
                                                 gui.label(1, 1, 1, 1, 0x00ff00,
                                                           "ENABLED")))

    gIsEnabled:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                            gui.ALIGNMENT_VERTICAL_CENTER)

    local gRPM = gInfoGrid:setPosition(1, 2, gInfoGrid:addChild(
                                           gui.label(1, 1, 1, 1, 0x00ff00,
                                                     "1561 RPM")))

    gRPM:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                      gui.ALIGNMENT_VERTICAL_CENTER)

    local gSteam = gInfoGrid:setPosition(1, 3, gInfoGrid:addChild(
                                             gui.label(1, 1, 1, 1, 0xff0000,
                                                       "9750 mB")))

    gSteam:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                        gui.ALIGNMENT_VERTICAL_CENTER)

    return {
        chart = gChart,
        fields = {enabled = gIsEnabled, rpm = gRPM, steam = gSteam}
    }
end

local function fuelStorageCell(grid, col, row, name)
    local oGrid = grid:setPosition(col, row,
                                   grid:addChild(gui.layout(1, 1, 1, 1, 1, 2)))

    util.setAutoFit(oGrid, 0, 0)

    oGrid:setRowHeight(1, gui.SIZE_POLICY_ABSOLUTE, 1)
    oGrid:setRowHeight(2, gui.SIZE_POLICY_RELATIVE, 1)

    local nameLbl = oGrid:setPosition(1, 1, oGrid:addChild(
                                          gui.label(1, 1, 1, 1, 0xffffff, name)))

    nameLbl:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                         gui.ALIGNMENT_VERTICAL_CENTER)

    local gGrid = oGrid:setPosition(1, 2, oGrid:addChild(
                                        gui.layout(1, 1, 1, 1, 2, 1)))

    gGrid:setColumnWidth(1, gui.SIZE_POLICY_RELATIVE, 0.75)

    util.setAutoFit(gGrid, 2, 0)

    local gChart = gGrid:setPosition(1, 1,
                                     gGrid:addChild(
                                         gui.chart(1, 1, 1, 1, 0xffffff,
                                                   0xffffff, 0xffffff, 0xd2a58e,
                                                   0.5, 0.5, "t", "%", true, {})))

    local gInfoGrid = gGrid:setPosition(2, 1, gGrid:addChild(
                                            gui.layout(1, 1, 1, 1, 1, 4)))

    util.setAutoFit(gInfoGrid, 2, 2)

    local gIsEjecting = gInfoGrid:setPosition(1, 2, gInfoGrid:addChild(
                                                  gui.label(1, 1, 1, 1,
                                                            0x00ff00, "EJECTING")))

    gIsEjecting:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                             gui.ALIGNMENT_VERTICAL_CENTER)

    local gFuelLevel = gInfoGrid:setPosition(1, 3, gInfoGrid:addChild(
                                                 gui.label(1, 1, 1, 1, 0xff0000,
                                                           "43 %")))

    gFuelLevel:setAlignment(gui.ALIGNMENT_HORIZONTAL_CENTER,
                            gui.ALIGNMENT_VERTICAL_CENTER)

    return {
        chart = gChart,
        fields = {ejecting = gIsEjecting, fuelLevel = gFuelLevel}
    }
end

-- endregion

local function buttonsCell(grid, col, row)
    local btnGrid = grid:setPosition(col, row, grid:addChild(
                                         gui.layout(1, 1, 1, 1, 3, 1)))

    util.setAutoFit(btnGrid, 8, 2)

    local startBtn = btnGrid:setPosition(1, 1,
                                         btnGrid:addChild(
                                             gui.roundedButton(1, 1, 1, 1,
                                                               0xcccc66,
                                                               0x000000,
                                                               0x7a7a3d,
                                                               0x000000,
                                                               "START CORE")))
    local stopBtn = btnGrid:setPosition(2, 1,
                                        btnGrid:addChild(
                                            gui.roundedButton(1, 1, 1, 1,
                                                              0xcc9966,
                                                              0x000000,
                                                              0x663333,
                                                              0x000000,
                                                              "STOP CORE")))

    local quitBtn = btnGrid:setPosition(3, 1,
                                        btnGrid:addChild(
                                            gui.framedButton(1, 1, 1, 1,
                                                             0xcc9966, 0xcc9966,
                                                             0x663333, 0x663333,
                                                             "QUIT DASHBOARD")))

    return {start = startBtn, stop = stopBtn, quit = quitBtn}
end

local function MonitorGUI()
    local app = gui.application()

    app:addChild(gui.panel(1, 1, app.width, app.height, 0x000000))

    local root = app:addChild(gui.layout(1, 1, app.width, app.height, 1, 2))

    root:setRowHeight(1, gui.SIZE_POLICY_RELATIVE, 0.9)
    root:setRowHeight(2, gui.SIZE_POLICY_RELATIVE, 0.1)

    util.setAutoFit(root, 0, 0)

    local statGrid = root:setPosition(1, 1, root:addChild(
                                          gui.layout(1, 1, 1, 1, 2, 3)))

    util.setAutoFit(statGrid, 2, 2)

    local gas1 = gasTurbineCell(statGrid, 1, 1, "GAS-1")
    local gas2 = gasTurbineCell(statGrid, 2, 1, "GAS-2")

    local boil1 = boilerCell(statGrid, 1, 2, "BOIL-1")
    local boil2 = boilerCell(statGrid, 2, 2, "BOIL-2")

    local steam = steamTurbineCell(statGrid, 1, 3, "STEAM")
    local fuel = fuelStorageCell(statGrid, 2, 3, "FUEL")

    local buttons = buttonsCell(root, 1, 2)

    local stats = {
        ['GAS-1'] = gas1,
        ['GAS-2'] = gas2,
        ['BOIL-1'] = boil1,
        ['BOIL-2'] = boil2,
        ['STEAM'] = steam,
        ['FUEL'] = fuel
    }

    return {statCells = stats, buttons = buttons, app = app}
end

return MonitorGUI
