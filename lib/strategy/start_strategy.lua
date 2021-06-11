local class = require('lua-objects')
local Strategy = require('strategy/strategy')
local Mechinas = require('model/ccgt/mechinas')

local GasTurbine = Mechinas.GasTurbine
local Boiler = Mechinas.Boiler

local StartStrategy = class(Strategy, {name = 'CCGT.StartStrategy'})

function StartStrategy:__new__(hypermodel)
    self:superCall('__new__', hypermodel)

    self._stage = 'idle'

    self._stageTimer = 0
end

function StartStrategy:init()
    for _, model in pairs(self._hypermodel.models) do model:init() end

    local gas1, gas2, _, _, _, fuel = self:unpackModels()

    gas1:toggleStarter(false)
    gas1:toggleBurnup(false)

    gas2:toggleStarter(false)
    gas2:toggleBurnup(false)

    fuel:toggleEjector(false)
end

function StartStrategy:unpackModels()
    local models = self._hypermodel.models

    local gas1 = models['GAS-1']
    local gas2 = models['GAS-2']

    local boil1 = models['BOIL-1']
    local boil2 = models['BOIL-2']

    local steam = models['STEAM']
    local fuel = models['FUEL']

    return gas1, gas2, boil1, boil2, steam, fuel
end

function StartStrategy:tick()
    local currentStage = self._stage

    if currentStage == 'idle' then
        self._stage = self:tickIdle()
    elseif currentStage == 'refuel' then
        self._stage = self:tickRefuel()
    elseif currentStage == 'gas_startup' then
        self._stage = self:tickStartup()
    elseif currentStage == 'gas_startup_stuck' then
        self._stage = self:tickStartupStuck()
    elseif currentStage == 'gas_before_running' then
        self._stage = self:tickBeforeRunning()
    elseif currentStage == 'gas_before_stable' then
        self._stage = self:tickBeforeStable()
    elseif currentStage == 'gas_running' then
        self._stage = self:tickGasRunning()
    elseif currentStage == 'boil_wait_fuel' then
        self._stage = self:tickWaitFuel()
    elseif currentStage == 'boil_start' then
        self._stage = self:tickBoilStart()
    elseif currentStage == 'boil_warmup' then
        self._stage = self:tickBoilWarmup()
    elseif currentStage == 'boil_running' then
        self._stage = self:tickBoilRunning()
    elseif currentStage == 'steam_wait_steam' then
        self._stage = self:tickSteamWaitSteam()
    elseif currentStage == 'steam_start' then
        self._stage = self:tickSteamStart()
    elseif currentStage == 'finished' then
        self:finish()
    end

    return nil
end

function StartStrategy:tickSteamStart()
    local _, _, _, _, steam = self:unpackModels()

    local steamState = steam:getState()

    if not steamState.enabled then steam:toggleEnabled(true) end

    return 'finished'
end

function StartStrategy:tickSteamWaitSteam()
    if self._stageTimer <= 0 then return 'steam_start' end

    self._stageTimer = self._stageTimer - 1

    return 'steam_wait_steam'
end

function StartStrategy:tickBoilRunning()
    self._stageTimer = 50

    return 'steam_wait_steam'
end

function StartStrategy:tickBoilWarmup()
    local _, _, boil1, boil2 = self:unpackModels()

    local boil1state, boil2state = boil1:getState(), boil2:getState()

    if ((boil1state.heat < Boiler.MAX_TEMP) or
        (boil2state.heat < Boiler.MAX_TEMP)) then return 'boil_warmup' end

    return 'boil_running'
end

function StartStrategy:tickBoilStart()
    local _, _, boil1, boil2 = self:unpackModels()

    local boil1state, boil2state = boil1:getState(), boil2:getState()

    if not (boil1state.enabled and boil2state.enabled) then
        boil1:toggleEnabled(true)
        boil2:toggleEnabled(true)
    end

    return 'boil_warmup'
end

function StartStrategy:tickWaitFuel()
    if self._stageTimer <= 0 then return 'boil_start' end

    self._stageTimer = self._stageTimer - 1

    return 'boil_wait_fuel'
end

function StartStrategy:tickGasRunning()
    self._stageTimer = 50

    return 'boil_wait_fuel'
end

function StartStrategy:tickBeforeStable()
    local gas1, gas2 = self:unpackModels()

    gas1:toggleBurnup(false)
    gas2:toggleBurnup(false)

    return 'gas_running'
end

function StartStrategy:tickBeforeRunning()
    local gas1, gas2, _, _, _, fuel = self:unpackModels()

    local gas1state, gas2state = gas1:getState(), gas2:getState()

    fuel:toggleEjector(true)

    if (gas1state.startup or gas2state.startup) then
        gas1:toggleStarter(false)
        gas2:toggleStarter(false)
    end

    return 'gas_before_stable'
end

function StartStrategy:tickStartupStuck()
    local gas1, gas2 = self:unpackModels()

    local gas1state, gas2state = gas1:getState(), gas2:getState()

    if not (gas1state.burnup and gas2state.burnup) then
        gas1:toggleBurnup(true)
        gas2:toggleBurnup(true)

        return 'gas_startup_stuck'
    end

    if ((gas1:getState().fuelLevel.fluid.amount <
        gas1:getState().fuelLevel.capacity) and
        (gas2:getState().fuelLevel.fluid.amount <
            gas2:getState().fuelLevel.capacity)) then
        return 'gas_before_running'
    end

    return 'gas_startup_stuck'
end

function StartStrategy:tickStartup()
    local gas1, gas2 = self:unpackModels()

    local gas1state, gas2state = gas1:getState(), gas2:getState()

    if not (gas1state.starter and gas2state.starter) then
        gas1:toggleStarter(true)
        gas2:toggleStarter(true)

        return 'gas_startup'
    end

    if ((gas1state.rotorSpeed >= GasTurbine.STUCK_SPEED) and
        (gas2state.rotorSpeed >= GasTurbine.STUCK_SPEED)) then
        return 'gas_startup_stuck'
    end
end

function StartStrategy:tickRefuel()
    local gas1, gas2, _, _, _, fuel = self:unpackModels()

    if ((gas1:getState().fuelLevel.fluid.amount >=
        gas1:getState().fuelLevel.capacity) or
        (gas2:getState().fuelLevel.fluid.amount >=
            gas2:getState().fuelLevel.capacity)) then
        fuel:toggleEjector(false)
        return 'idle'
    end

    if not fuel:isEjecting() then fuel:toggleEjector(true) end

    return 'refuel'
end

function StartStrategy:tickIdle()
    local gas1, gas2 = self:unpackModels()

    local gas1state, gas2state = gas1:getState(), gas2:getState()

    if ((gas1state.fuelLevel.fluid.amount < gas1state.fuelLevel.capacity) or
        (gas2state.fuelLevel.fluid.amount < gas2state.fuelLevel.capacity)) then
        return 'refuel'
    end

    if not (gas1state.enabled and gas2state.enabled) then
        gas1state:toggleEnabled(true)
        gas2state:toggleEnabled(true)

        return 'idle'
    end

    return 'gas_startup'
end
