local class = require('lua-objects')

local Strategy = class(nil, {name = 'Mechina.Strategy'})

function Strategy:__new__(hypermodel)
    self._hmodel = hypermodel
    self._finished = false
end

function Strategy.__getters:finished() return self._finished end

function Strategy:init() error('Not implemented') end

function Strategy:tick() error('Not implemented') end

function Strategy:reset() self._finished = false end

function Strategy:finish() self._finished = true end
