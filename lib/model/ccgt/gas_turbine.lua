local class = require('lua-objects')
local Mechina = require('mechina')
local sides = require('sides')

local ModelBase = Mechina.ModelBase
local GenericComp = Mechina.GenericComponent
local RsToggle = Mechina.ComponentLib.RedstoneToggle

local STUCK_SPEED = 440

local GasTurbine = class(ModelBase, {name = 'CCGT.GasTurbine'})

GasTurbine.STATES = {
    UNKNOWN = 'unknown',
    STANDBY = 'standby',
    STOPPING = 'stopping',
    STARTUP = 'startup',
    STARTUP_STUCK = 'startup_stuck',
    RUNNING = 'running'
}

GasTurbine.STUCK_SPEED = STUCK_SPEED
GasTurbine.STABLE_SPEED = 500
GasTurbine.MAX_SPEED = 1800

function GasTurbine:__new__(id)
    self:superCall('__new__', id)

    self:registerComponent('starter', RsToggle:new())
    self:registerComponent('burnup', RsToggle:new())

    self:registerComponent('turbine', GenericComp:new('it_gas_turbine'))

    self._isEnabled = false
end

function GasTurbine:init()
    assert(self:isOperable(), 'Model is not set up correctly')

    self._components.turbine.proxy.enableComputerControl(true)
    self._components.turbine.proxy.setEnabled(self._isEnabled)
end

function GasTurbine:getState()
    local turbine = self._components.turbine

    local rotorSpeed = turbine.proxy.getSpeed()
    local fuelLevel = turbine.proxy.getInputTankInfo()
    local isStartup = self._components.starter:isEnabled()
    local isBurnup = self._components.burnup:isEnabled()

    local stateTp = GasTurbine.STATES.UNKNOWN

    if rotorSpeed == 0 then
        if not isStartup then
            stateTp = GasTurbine.STATES.STANDBY
        else
            stateTp = GasTurbine.STATES.STARTUP
        end
    else
        if isStartup then
            if rotorSpeed >= STUCK_SPEED then
                stateTp = GasTurbine.STATES.STARTUP_STUCK
            else
                stateTp = GasTurbine.STATES.STARTUP
            end
        else
            stateTp = GasTurbine.STATES.RUNNING
        end
    end

    return {
        enabled = self._isEnabled,
        state = stateTp,
        rotorSpeed = rotorSpeed,
        fuelLevel = fuelLevel,
        burnup = isBurnup,
        starter = isStartup
    }
end

function GasTurbine:toggleEnabled(value)
    self._isEnabled = value

    self._components.turbine.proxy.setEnabled(self._isEnabled)
end

function GasTurbine:toggleStarter(value)
    self._components.starter:setEnabled(value)
end

function GasTurbine:toggleBurnup(value) self._components.burnup:setEnabled(value) end

return GasTurbine
