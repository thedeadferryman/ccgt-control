local class = require('lua-objects')
local Generic = require('mechina/component/generic_component')
local Schema = require('mechina/config/config_schema')


local ConfigurableComponent = class(Generic, { name = 'Mechina.ConfigurableComponent' })

function ConfigurableComponent:__new__(ctype, schema)
  assert(schema.is_instance, 'Schema must be an object')
  assert(schema:isa(Schema), 'Schema must be an instance of <ConfigSchema>')

  self:superCall('__new__', ctype)

  self._schema = schema
  self._config = {}
end

function ConfigurableComponent.__getters:schema()
  return self._schema
end

function ConfigurableComponent.__getters:config()
  return self._config
end

function ConfigurableComponent.__getters:imprint()
  return ConfigurableComponent:new(self._type, self._schema)
end

function ConfigurableComponent:configure(config)
  local valid, msg = self._schema:validate(config)

  assert(valid, msg)

  self._config = config
end

function ConfigurableComponent:isOperable()
  local genericOperable = self:superCall('isOperable')

  local valid = self._schema:validate(self._config)

  return genericOperable and valid
end

function ConfigurableComponent:serialize()
  local ser = self:superCall('serialize')

  ser.config = self._config

  return ser
end

return ConfigurableComponent