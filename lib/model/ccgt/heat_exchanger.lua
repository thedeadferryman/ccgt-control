local class = require('lua-objects')
local Mechina = require('mechina')

local ModelBase = Mechina.ModelBase
local GenComp = Mechina.GenericComponent

local HeatExchanger = class(ModelBase, { name = 'CCGT.HeatExchanger' })

function HeatExchanger:__new__(id)
    self:superCall('__new__', id)

    self:registerComponent('heat_exchanger', GenComp:new('it_heat_exchanger'))

    self._isEnabled = false
end

function HeatExchanger:init()
    self._components.boiler.proxy.enableComputerControl(true)
    self._components.boiler.proxy.setEnabled(self._isEnabled)
end

function HeatExchanger:getState()
    local boiler = self._components.boiler.proxy

    return {
        enabled = self._isEnabled,
        fuelLevel = boiler.getSecondInputTankInfo(),
        waterLevel = boiler.getFirstInputTankInfo(),
        steamLevel = boiler.getFirstOutputTankInfo()
    }
end

function HeatExchanger:toggleEnabled(value)
    self._isEnabled = value and true or false

    self._components.boiler.proxy.setEnabled(self._isEnabled)
end

return HeatExchanger
