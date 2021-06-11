local class = require('lua-objects')
local Mechina = require('mechina')

local ModelBase = Mechina.ModelBase
local GenComp = Mechina.GenericComponent

local Boiler = class(ModelBase, {name = 'CCGT.Boiler'})

Boiler.MAX_TEMP = 12000

function Boiler:__new__(id)
    self:superCall('__new__', id)

    self:registerComponent('boiler', GenComp:new('it_boiler'))

    self._isEnabled = false
end

function Boiler:init()
    self._components.boiler.proxy.enableComputerControl(true)
    self._components.boiler.proxy.setEnabled(self._isEnabled)
end

function Boiler:getState()
    local boiler = self._components.boiler.proxy

    return {
        enabled = self._isEnabled,
        heat = boiler.getHeat(),
        fuelLevel = boiler.getFuelTankInfo(),
        waterLevel = boiler.getInputTankInfo(),
        steamLevel = boiler.getOutputTankInfo()
    }
end

function Boiler:toggleEnabled(value)
    self._isEnabled = value and true or false

    self._components.boiler.proxy.setEnabled(self._isEnabled)
end

return Boiler
