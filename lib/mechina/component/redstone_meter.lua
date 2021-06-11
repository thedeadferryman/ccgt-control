local class = require('lua-objects')

local ConfComp = require('mechina/component/configurable_component')
local ConfigSchema = require('mechina/config/config_schema')

local sides = require('sides')

local RedstoneMeter = class(ConfComp, { name = 'Mechina.ComponentLib.RedstoneMeter' })

local rsSchema = ConfigSchema:new()

rsSchema:addField('side', 'Active side', ConfigSchema.EnumField:new({ 'top', 'bottom', 'north', 'south', 'east', 'west' }))

function RedstoneMeter.__getters:imprint()
  return RedstoneMeter:new()
end

function RedstoneMeter:__new__()
  self:superCall('__new__', 'redstone', rsSchema)
end

function RedstoneMeter:getValue()
  return self.proxy.getComparatorInput(sides[self.config.side])
end

return RedstoneMeter