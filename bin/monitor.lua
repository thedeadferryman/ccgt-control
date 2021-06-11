local MonitorGUI = require('ui/monitor')
local CCGT = require('model/ccgt')
local ser = require('serialization')
local event = require('event')
local WindowedList = require('windowed_list')
local GasTurbine = require('model/ccgt/gas_turbine')
local StartStrategy = require('strategy/start_strategy')
local StopStrategy = require('strategy/stop_strategy')

local function loadProfile(filename)
    local fd = io.open(filename, 'r')

    assert(fd, "Cannot load profile from '" .. filename ..
               "'. Specify another profile or run 'bin/configure' to create one.")

    local pfData = fd:read(1000000)

    return ser.unserialize(pfData)
end

local function initializeModel(model, conf)
    for name, comp in pairs(model.components) do
        local compConf = conf.components[name]

        comp:bind(compConf.addr)

        if compConf.config ~= nil then comp:configure(compConf.config) end
    end
end

local function initializeHypermodel(profile)
    local hmodel = CCGT:new()

    for id, conf in pairs(profile) do
        initializeModel(hmodel.models[id], conf)
    end

    return hmodel
end

local function addChartValue(chart, value)
    local wnd = WindowedList:new(50)

    local values = chart.values

    for _, val in ipairs(values) do wnd:push(val[2]) end

    wnd:push(value)

    local newValues = {{0, 0}} -- Force chart range

    for i = 1, #wnd do table.insert(newValues, {i, wnd[i]}) end

    chart.values = newValues

end

local function gasStateToDisplayed(state)
    local res = {color = 0xff0000}

    if state == GasTurbine.STATES.UNKNOWN then
        res.text = 'UNKNOWN'
    elseif state == GasTurbine.STATES.STANDBY then
        res.text = 'STANDBY'
    elseif state == GasTurbine.STATES.STARTUP then
        res.text = 'STARTUP'
        res.color = 0x00ff00
    elseif state == GasTurbine.STATES.STARTUP_STUCK then
        res.text = 'STUCK'
    elseif state == GasTurbine.STATES.STOPPING then
        res.text = 'STOPPING'
    elseif state == GasTurbine.STATES.RUNNING then
        res.text = 'RUNNING'
        res.color = 0x00ff00
    end

    return res
end

local function updateGasData(gasCell, model)
    local state = model:getState()

    addChartValue(gasCell.chart, state.rotorSpeed)

    gasCell.fields.enabled.text = state.enabled and 'ENABLED' or 'DISABLED'
    gasCell.fields.enabled.colors.text = state.enabled and 0x00ff00 or 0xff0000

    local gasState = gasStateToDisplayed(state.state)

    gasCell.fields.state.text = gasState.text
    gasCell.fields.state.colors.text = gasState.color

    gasCell.fields.rpm.text = tostring(state.rotorSpeed) .. " RPM"
    gasCell.fields.rpm.colors.text = (state.rotorSpeed > 900) and 0x00ff00 or
                                         0xff0000

    gasCell.fields.burnup.text = state.burnup and 'BURNUP' or 'NO BURNUP'
    gasCell.fields.burnup.colors.text = state.burnup and 0x00ff00 or 0xff0000
end

local function updateBoilerData(boilCell, model)
    local state = model:getState()

    addChartValue(boilCell.chart, state.heat)

    boilCell.fields.enabled.text = state.enabled and 'ENABLED' or 'DISABLED'
    boilCell.fields.enabled.colors.text = state.enabled and 0x00ff00 or 0xff0000

    boilCell.fields.heat.text = tostring(state.heat) .. ' T'
    boilCell.fields.heat.colors.text = (state.heat > 6000) and 0x00ff00 or
                                           0xff0000

    boilCell.fields.water.text = tostring(state.waterLevel.amount) .. ' mB'
    boilCell.fields.water.colors.text = (state.waterLevel.amount >
                                            state.waterLevel.capacity / 2) and
                                            0x00ff00 or 0xff0000

    boilCell.fields.fuel.text = tostring(state.fuelLevel.amount) .. ' mB'
    boilCell.fields.fuel.colors.text = (state.fuelLevel.amount >
                                           state.waterLevel.capacity / 2) and
                                           0x00ff00 or 0xff0000
end

local function updateSteamData(steamCell, model)
    local state = model:getState()

    addChartValue(steamCell.chart, state.speed)

    steamCell.fields.enabled.text = state.enabled and 'ENABLED' or 'DISABLED'
    steamCell.fields.enabled.colors.text =
        state.enabled and 0x00ff00 or 0xff0000

    steamCell.fields.rpm.text = tostring(state.speed) .. ' RPM'
    steamCell.fields.rpm.colors.text = (state.speed > 900) and 0x00ff00 or
                                           0xff0000

    steamCell.fields.steam.text = tostring(state.steamLevel.amount) .. ' mB'
    steamCell.fields.steam.colors.text =
        (state.steamLevel.amount > state.steamLevel.capacity / 2) and 0x00ff00 or
            0xff0000
end

local function updateFuelData(fuelCell, model)
    local state = model:getState()

    local level = math.round((state.level * 10000) / 15) / 100

    addChartValue(fuelCell.chart, level)

    fuelCell.fields.ejecting.text = state.isEjecting and 'EJECTING' or
                                        'NO EJECTING'
    fuelCell.fields.ejecting.colors.text =
        state.isEjecting and 0x00ff00 or 0xff0000

    fuelCell.fields.fuelLevel.text = tostring(level) .. ' %'
    fuelCell.fields.fuelLevel.colors.text =
        (level > 50) and 0x00ff00 or 0xff0000
end

local function updateUiData(statCells, hmodel)
    updateGasData(statCells['GAS-1'], hmodel.models['GAS-1'])
    updateGasData(statCells['GAS-2'], hmodel.models['GAS-2'])

    updateBoilerData(statCells['BOIL-1'], hmodel.models['BOIL-1'])
    updateBoilerData(statCells['BOIL-2'], hmodel.models['BOIL-2'])

    updateSteamData(statCells['STEAM'], hmodel.models['STEAM'])

    updateFuelData(statCells['FUEL'], hmodel.models['FUEL'])
end

local function runMonitor(args)
    local profile = loadProfile(args[1] or 'profile.cfg')

    local hmodel = initializeHypermodel(profile)

    local gui = MonitorGUI()

    local currentStrategy = nil

    updateUiData(gui.statCells, hmodel)

    local guiTimer = event.timer(1.2, function()
        updateUiData(gui.statCells, hmodel)

        gui.app:draw()
    end, math.huge)

    local strategyTimer = event.timer(0.05, function()
        if currentStrategy == nil then return nil end

        if currentStrategy.finished then currentStrategy = nil end

        currentStrategy:tick()
    end, math.huge)

    gui.buttons.start.onTouch = function()
        if currentStrategy ~= nil then return nil end

        currentStrategy = StartStrategy:new()

        currentStrategy:init()
    end

    gui.buttons.stop.onTouch = function()
        currentStrategy = StopStrategy:new()

        currentStrategy:init()
    end

    gui.buttons.quit.onTouch = function()
        gui.app:stop()

        event.cancel(guiTimer)
        event.cancel(strategyTimer)

        os.execute('clear')

        return nil
    end

    gui.app:draw(true)
    gui.app:start()
end

local args = {...}

if (args[1] == '--help' or args[1] == '-h') then
    print('Usage: bin/monitor [profile]')
    os.exit(0)
end

runMonitor(args)
