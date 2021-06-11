local Configurer = require('ui/configurer')
local CCGT = require('model/ccgt')
local util = require('util')
local Mechina = require('mechina')
local ser = require('serialization')

local function configureModel()
    local conf = CCGT:new()

    local modelNames = util.tableKeys(conf.models)

    table.sort(modelNames)

    local quit = nil

    for _, id in ipairs(modelNames) do
        if quit then return nil end

        local model = conf.models[id]

        for key, comp in pairs(model.components) do
            local cfg = Configurer("Configuring " .. id .. " : component <" ..
                                       key .. ">", comp)

            cfg.buttons.ok.onTouch = function()
                local conf = {}

                for key, getter in pairs(cfg.fieldData) do
                    conf[key] = getter()
                end

                comp:bind(conf.___addr__)

                conf.___addr__ = nil

                if comp:isa(Mechina.ConfigurableComponent) then
                    comp:configure(conf)
                end

                cfg.app:stop()
            end

            cfg.buttons.quit.onTouch = function()
                cfg.app:stop()

                quit = true
            end

            cfg.app:draw(true)
            cfg.app:start()
        end
    end

    return conf:serialize()
end

local function writeConfig(targetFile)
    local conf = configureModel()

    if conf ~= nil then
        local hfile = io.open(targetFile or 'profile.cfg', 'w')

        hfile:write(ser.serialize(conf))

        hfile:close()
    end
end

local args = {...}

if (args[1] == '--help' or args[1] == '-h') then
    print('Usage: bin/monitor [profile]')
    os.exit(0)
end

writeConfig(args[1])