return function()
    local self = {
        __stack__ = true,
        count = 0,
    }

    function self:__len()
        return self.count
    end

    function self:has(v)
        for i,item in ipairs(self) do
            if item == v then
                return true
            end
        end
        return false
    end
    
    function self:push(v)
        self.count = self.count + 1
        table.insert(self,v)
    end

    function self:pop()
        return table.remove(self)
    end

    function self:top()
        return self[self.count]
    end

    function self:iter(i)
        i = i + 1
        if i > self.count then return nil end
        return i,self[i]
    end

    function self:items()
        return self.iter,self,0
    end

    return setmetatable(self,self)
end