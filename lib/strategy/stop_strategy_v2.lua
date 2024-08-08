local class = require('lua-objects')
local Strategy = require('strategy/strategy')
local Mechinas = require('model/ccgt/mechinas')

local StopStrategyV2 = class(Strategy, { name = 'CCGT.StopStrategyV2' })

function StopStrategyV2:init()
    local gas1, gas2, hxcg1, hxcg2, steam, fuel = self:unpackModels()

    gas1:toggleStarter(false)
    gas1:toggleBurnup(false)
    gas1:toggleEnabled(false)

    gas2:toggleStarter(false)
    gas2:toggleBurnup(false)
    gas2:toggleEnabled(false)

    hxcg1:toggleEnabled(false)
    hxcg2:toggleEnabled(false)

    steam:toggleEnabled(false)

    fuel:toggleEjector(false)

    self:finish()
end

function StopStrategyV2:tick()
    -- noop
end

function StopStrategyV2:unpackModels()
    local models = self._hypermodel.models

    local gas1 = models['GAS-1']
    local gas2 = models['GAS-2']

    local hxcg1 = models['HXCG-1']
    local hxcg2 = models['HXCG-2']

    local steam = models['STEAM']
    local fuel = models['FUEL']

    return gas1, gas2, hxcg1, hxcg2, steam, fuel
end

return StopStrategyV2
