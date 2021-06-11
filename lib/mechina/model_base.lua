local class = require('lua-objects')
local Comp = require('mechina/component/generic_component')

local ModelBase = class(nil, {name = 'Mechina.ModelBase'})

function ModelBase:__new__(id)
    self._id = id or ''
    self._components = {}
end

function ModelBase.__getters:components() return self._components end

function ModelBase:registerComponent(name, component)
    assert(self._components[name] == nil,
           'Component <' .. name .. '> is already registered')
    assert(component.is_instance, 'Component must be an object')
    assert(component:isa(Comp), 'Invalid component')

    self._components[name] = component.imprint
end

function ModelBase:init() end

function ModelBase:isOperable()
    local res = true

    for key, value in pairs(self._components) do
        res = res and value:isOperable()
    end

    return res
end

function ModelBase:serialize()
    local ser = {}

    for name, comp in pairs(self._components) do ser[name] = comp:serialize() end

    return {id = self._id, components = ser}
end

return ModelBase
