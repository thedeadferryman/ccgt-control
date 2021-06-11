local class = require('lua-objects')
local comp = require('component')

local GenericComponent = class(nil, { name = 'Mechina.GenericComponent' }) 

function GenericComponent:__new__(ctype)
  assert(type(ctype) == 'string', 'Type must be a string')
  
  self._type = ctype
  self._proxy = nil
end

function GenericComponent.__getters:type() 
  return self._type
end

function GenericComponent.__getters:proxy()
  return self._proxy
end

function GenericComponent.__getters:imprint()
  return GenericComponent:new(self._type)
end

function GenericComponent:getCompatible()
  local comps = {}

  for addr, type in comp.list(self._type) do
    if type == self._type then
      comps[#comps + 1] = addr
    end
  end

  return comps
end

function GenericComponent:bind(addr)
  assert(comp.type(addr) == self._type, 'Unsupported component')

  self._proxy = comp.proxy(addr)
end

function GenericComponent:unbind()
  self._proxy = nil
end

function GenericComponent:isOperable()
  return self._proxy ~= nil
end

function GenericComponent:serialize()
  return {
    addr = self._proxy.address,
    type = self._type
  }  
end

return GenericComponent