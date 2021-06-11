local class = require('lua-objects')

local ConfComp = require('mechina/component/configurable_component')
local ConfigSchema = require('mechina/config/config_schema')

local sides = require('sides')

local RedstoneToggle = class(ConfComp, { name = 'Mechina.ComponentLib.RedstoneToggle' })

local rsSchema = ConfigSchema:new()

local RS_ON = 15
local RS_OFF = 0

rsSchema:addField('side', 'Active side', ConfigSchema.EnumField:new({ 'top', 'bottom', 'north', 'south', 'east', 'west' }))

function RedstoneToggle.__getters:imprint()
  return RedstoneToggle:new()
end

function RedstoneToggle:__new__()
  self:superCall('__new__', 'redstone', rsSchema)
end

function RedstoneToggle:setEnabled(value)
  self.proxy.setOutput(sides[self.config.side], (value and RS_ON or RS_OFF))
end

function RedstoneToggle:isEnabled()
  return self.proxy.getOutput(sides[self.config.side]) > RS_OFF
end

return RedstoneToggle