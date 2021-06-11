local class = require('lua-objects')

local Mech = require('model/ccgt/mechinas')

local CCGT = class(nil, {name = 'CCGT.Model'})

function CCGT:__new__()
    self._models = {}

    self._models['FUEL'] = Mech.FuelStorage:new('FUEL')

    self._models['GAS-1'] = Mech.GasTurbine:new('GAS-1')
    self._models['GAS-2'] = Mech.GasTurbine:new('GAS-2')

    self._models['BOIL-1'] = Mech.Boiler:new('BOIL-1')
    self._models['BOIL-2'] = Mech.Boiler:new('BOIL-2')

    self._models['STEAM'] = Mech.SteamTurbine:new('STEAM')
end

function CCGT.__getters:models() return self._models end

function CCGT:serialize()
    local ser = {}

    for key, value in pairs(self._models) do
        ser[key] = value:serialize()
    end

    return ser
end

return CCGT
