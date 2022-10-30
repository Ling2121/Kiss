return function()
    local self = {
        __dictionary__ = true,
        count = 0,
        table = {},
    }

    function self:__len()
        return self.count
    end

    function self:__newindex(k,v)
        rawset(self.table,k,v)
    end

    function self:__index(k)
        return rawget(self.table,k)
    end

    function self:has(k)
        return self.table[k] ~= nil
    end

    function self:add(k,v)
        if self.table[k] == nil then
            self.table[k] = v
            self.count = self.count + 1
        end
    end

    function self:remove(k)
        if self.table[k] ~= nil then
            self.table[k] = nil
            self.count = self.count - 1
        end
    end

    function self:items()
        return next,self.table
    end


    return setmetatable(self,self)
end