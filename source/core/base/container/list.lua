return function()
    local self = {
        __list__ = true,
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

    function self:add(v)
        self.count = self.count + 1
        table.insert(self,v)
    end

    function self:insert(i,v)
        self.count = self.count + 1
        table.insert(self,i,v)
    end

    function self:remove(i)
        if self.count <= 0 then return end
        local rm = table.remove(self,i)
        self.count = self.count - 1
        return rm
    end

    function self:removeBack()
        if self.count <= 0 then return end
        self[self.count] = nil
        self.count = self.count - 1
    end

    function self:iter(i)
        i = i + 1
        if i > self.count then return nil end
        return i,self[i]
    end

    function self:items()
        return self.iter,self,0
    end

    return setmetatable(self,self);
end