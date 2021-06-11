local class = require('lua-objects')
local Strategy = require('strategy/strategy')
local Mechinas = require('model/ccgt/mechinas')

local StopStrategy = class(Strategy, {name = 'CCGT.StopStrategy'})

function StopStrategy:init()
    local gas1, gas2, boil1, boil2, steam, fuel = self:unpackModels()

    gas1:toggleStarter(false)
    gas1:toggleBurnup(false)
    gas1:toggleEnabled(false)

    gas2:toggleStarter(false)
    gas2:toggleBurnup(false)
    gas2:toggleEnabled(false)

    boil1:toggleEnabled(false)
    boil2:toggleEnabled(false)

    steam:toggleEnabled(false)

    fuel:toggleEjector(false)

    self:finish()
end

function StopStrategy:tick()
    -- noop
end
