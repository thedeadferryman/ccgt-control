local class = require('lua-objects')

local Mech = require('model/ccgt/mechinas')

local CCGTV2 = class(nil, { name = 'CCGT.HypermodelV2' })

function CCGTV2:__new__()
    self._models = {}

    self._models['FUEL'] = Mech.FuelStorage:new('FUEL')

    self._models['GAS-1'] = Mech.GasTurbine:new('GAS-1')
    self._models['GAS-2'] = Mech.GasTurbine:new('GAS-2')

    self._models['HXCG-1'] = Mech.HeatExchanger:new('HXCG-1')
    self._models['HXCG-2'] = Mech.HeatExchanger:new('HXCG-2')

    self._models['STEAM'] = Mech.SteamTurbine:new('STEAM')
end

function CCGTV2.__getters:models() return self._models end

function CCGTV2:serialize()
    local ser = {}

    for key, value in pairs(self._models) do
        ser[key] = value:serialize()
    end

    return ser
end

return CCGTV2
