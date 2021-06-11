local class = require('lua-objects')
local Mechina = require('mechina')

local ModelBase = Mechina.ModelBase
local GenComp = Mechina.GenericComponent

local SteamTurbine = class(ModelBase, { name = 'CCGT.SteamTurbine' })

function SteamTurbine:__new__(id)
  self:superCall('__new__', id)

  self:registerComponent('turbine', GenComp:new('it_steam_turbine'))
  
  self._isEnabled = false
end

function SteamTurbine:init()
  self._components.turbine.proxy.enableComputerControl(true)
  self._components.turbine.proxy.setEnabled(self._isEnabled)
end

function SteamTurbine:getState()
  local turbine = self._components.turbine.proxy

  return {
    enabled = self._isEnabled,
    speed = turbine.getSpeed(),
    steamLevel = turbine.getTankInfo(),
  }
end

function SteamTurbine:toggleEnabled(value)
  self._isEnabled = value and true or false

  self._components.turbine.proxy.setEnabled(self._isEnabled)
end

return SteamTurbine