local class = require('lua-objects')

local ConfigSchema = class(nil, { name = 'Mechina.Config.Schema' })

local GenericField = class(nil, { name = 'Mechina.Config.Schema._.GenericField' })

function GenericField:__new__()
  self._typename = 'generic'
end

function GenericField.__getters:typename()
  return self._typename
end

function GenericField:serialize()
  return {
    typename = self._typename
  }
end

function GenericField:validate(val)
  return false, 'Generic type not allowed'
end

local StringField = class(GenericField, { name = 'Mechina.Config.Schema.StringField' })

function StringField:__new__()
  self:superCall('__new__')
  
  self._typename = 'string'
end

function StringField:validate(val)
  if type(val) == 'string' then
    return true
  else
    return false, 'Value is not string'
  end
end


local EnumField = class(GenericField, { name = 'Mechina.Config.Schema.EnumField' })

function EnumField:__new__(options)
  self._options = options or {}
  self._typename = 'enum'
end

function EnumField:serialize()
  return {
    typename = self._typename,
    options = self._options
  }
end

function EnumField:validate(val)
  local res = false

  for i = 1, #self._options do
    res = res or (self._options[i] == val)
  end

  return res
end

function ConfigSchema:__new__()
  self._fields = {}
end

function ConfigSchema:addField(key, name, ftype)
  assert(type(key) == 'string', 'Field key must be string')
  assert(type(name) == 'string', 'Field name must be string')
  assert(ftype:isa(GenericField), 'Invalid field type specified')
  assert(self._fields[key] == nil, 'Field exists')
  
  self._fields[key] = {
    name = name,
    type = ftype
  }
end

function ConfigSchema:serialize()
  local ser = {}

  for key, field in pairs(self._fields) do
    ser[key] = {
      name = field.name,
      type = field.type:serialize()
    }
  end

  return ser
end

function ConfigSchema:validate(config)
  assert(type(config) == 'table', 'Config should be a table')

  for key, value in pairs(config) do
    local fld = self._fields[key]

    if fld == nil then
      return false, 'Unknown property <' .. key .. '>'
    end

    local res, msg = fld.type:validate(value)

    if not res then
      return false, msg
    end
  end

  return true
end

ConfigSchema.StringField = StringField
ConfigSchema.EnumField = EnumField

return ConfigSchema