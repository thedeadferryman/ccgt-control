local class = require('lua-objects')
local Strategy = require('strategy/strategy')
local Mechinas = require('model/ccgt/mechinas')

local GasTurbine = Mechinas.GasTurbine

local StartStrategyV2 = class(Strategy, { name = 'CCGT.StartStrategyV2' })

function StartStrategyV2:__new__(hypermodel)
    self:superCall('__new__', hypermodel)

    self._stage = 'idle'

    self._stageTimer = 0
end

function StartStrategyV2:init()
    for _, model in pairs(self._hypermodel.models) do model:init() end

    local gas1, gas2, _, _, _, fuel = self:unpackModels()

    gas1:toggleStarter(false)
    gas1:toggleBurnup(false)

    gas2:toggleStarter(false)
    gas2:toggleBurnup(false)

    fuel:toggleEjector(false)
end

function StartStrategyV2:unpackModels()
    local models = self._hypermodel.models

    local gas1 = models['GAS-1']
    local gas2 = models['GAS-2']

    local hxcg1 = models['HXCG-1']
    local hxcg2 = models['HXCG-2']

    local steam = models['STEAM']
    local fuel = models['FUEL']

    return gas1, gas2, hxcg1, hxcg2, steam, fuel
end

function StartStrategyV2:tick()
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
    elseif currentStage == 'hxcg_wait_fuel' then
        self._stage = self:tickWaitFuel()
    elseif currentStage == 'hxcg_start' then
        self._stage = self:tickHXcgStart()
    elseif currentStage == 'hxcg_running' then
        self._stage = self:tickHXcgRunning()
    elseif currentStage == 'steam_wait_steam' then
        self._stage = self:tickSteamWaitSteam()
    elseif currentStage == 'steam_start' then
        self._stage = self:tickSteamStart()
    elseif currentStage == 'finished' then
        self:finish()
    end

    return nil
end

function StartStrategyV2:tickSteamStart()
    local _, _, _, _, steam = self:unpackModels()

    local steamState = steam:getState()

    if not steamState.enabled then steam:toggleEnabled(true) end

    return 'finished'
end

function StartStrategyV2:tickSteamWaitSteam()
    if self._stageTimer <= 0 then return 'steam_start' end

    self._stageTimer = self._stageTimer - 1

    return 'steam_wait_steam'
end

function StartStrategyV2:tickHXcgRunning()
    self._stageTimer = 50

    return 'steam_wait_steam'
end

function StartStrategyV2:tickHXcgStart()
    local _, _, hxcg1, hxcg2 = self:unpackModels()

    local hxcg1state, hxcg2state = hxcg1:getState(), hxcg2:getState()

    if not (hxcg1state.enabled and hxcg2state.enabled) then
        hxcg1:toggleEnabled(true)
        hxcg2:toggleEnabled(true)
    end

    return 'hxcg_running'
end

function StartStrategyV2:tickWaitFuel()
    if self._stageTimer <= 0 then return 'hxcg_start' end

    self._stageTimer = self._stageTimer - 1

    return 'hxcg_wait_fuel'
end

function StartStrategyV2:tickGasRunning()
    self._stageTimer = 100

    return 'hxcg_wait_fuel'
end

function StartStrategyV2:tickBeforeStable()
    local gas1, gas2 = self:unpackModels()

    gas1:toggleBurnup(false)
    gas2:toggleBurnup(false)

    return 'gas_running'
end

function StartStrategyV2:tickBeforeRunning()
    local gas1, gas2, _, _, _, fuel = self:unpackModels()

    local gas1state, gas2state = gas1:getState(), gas2:getState()

    fuel:toggleEjector(true)

    if (gas1state.starter or gas2state.starter) then
        gas1:toggleStarter(false)
        gas2:toggleStarter(false)
    end

    return 'gas_before_stable'
end

function StartStrategyV2:tickStartupStuck()
    local gas1, gas2 = self:unpackModels()

    local gas1state, gas2state = gas1:getState(), gas2:getState()

    if not (gas1state.burnup and gas2state.burnup) then
        gas1:toggleBurnup(true)
        gas2:toggleBurnup(true)

        return 'gas_startup_stuck'
    end

    if ((gas1:getState().fuelLevel.amount <
            gas1:getState().fuelLevel.capacity) and
            (gas2:getState().fuelLevel.amount <
                    gas2:getState().fuelLevel.capacity)) then
        return 'gas_before_running'
    end

    return 'gas_startup_stuck'
end

function StartStrategyV2:tickStartup()
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

    return 'gas_startup'
end

function StartStrategyV2:tickRefuel()
    local gas1, gas2, _, _, _, fuel = self:unpackModels()

    if ((gas1:getState().fuelLevel.amount >=
            gas1:getState().fuelLevel.capacity) and
            (gas2:getState().fuelLevel.amount >=
                    gas2:getState().fuelLevel.capacity)) then
        fuel:toggleEjector(false)
        return 'idle'
    end

    if not fuel:getState().isEjecting then fuel:toggleEjector(true) end

    return 'refuel'
end

function StartStrategyV2:tickIdle()
    local gas1, gas2 = self:unpackModels()

    local gas1state, gas2state = gas1:getState(), gas2:getState()

    if ((gas1state.fuelLevel.amount < gas1state.fuelLevel.capacity) or
            (gas2state.fuelLevel.amount < gas2state.fuelLevel.capacity)) then
        return 'refuel'
    end

    if not (gas1state.enabled and gas2state.enabled) then
        gas1:toggleEnabled(true)
        gas2:toggleEnabled(true)

        return 'idle'
    end

    return 'gas_startup'
end

return StartStrategyV2