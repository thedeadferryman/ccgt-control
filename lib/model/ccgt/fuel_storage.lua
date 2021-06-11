local class = require('lua-objects')
local Mechina = require('mechina')

local ModelBase = Mechina.ModelBase
local RsToggle = Mechina.ComponentLib.RedstoneToggle
local RsMeter = Mechina.ComponentLib.RedstoneMeter


local FuelStorage = class(ModelBase, { name = 'CCGT.FuelStorage' })

function FuelStorage:__new__(id)
  self:superCall('__new__', id)

  self:registerComponent('ejector', RsToggle:new())
  self:registerComponent('level', RsMeter:new())
end

function FuelStorage:getState()
  local ejector = self._components.ejector:isEnabled()
  local level = self._components.level:getValue()

  return {
    isEjecting = ejector,
    level = level
  }
end

function FuelStorage:toggleEjector(value)
  self._components.ejector:setEnabled(value and true or false)
end

return FuelStorage