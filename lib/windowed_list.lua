local WindowedList = {}

WindowedList.FILL_LIMIT = 11

function WindowedList:new(size)
    local obj = {offset = -size, _data = {}}

    self.__index = function(obj, name)
        if type(name) == 'number' then
            if (name + obj.offset) < 1 then
                return 0
            else
                return obj._data[name + obj.offset]
            end
        else
            return self[name]
        end
    end

    self.__len = function() return size end

    return setmetatable(obj, self)
end

function WindowedList:push(value)
    table.insert(self._data, value)
    self.offset = self.offset + 1

    if (#self._data > WindowedList.FILL_LIMIT) then
        local realData = {}

        for i = 1, #self do
            table.insert(realData, self[i])
        end

        self._data = realData
        self.offset = 0
    end
end

return WindowedList