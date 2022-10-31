

return function(t)
    t = t or {}
    local dict = {
        __dictionary__ = true,
        _count = 0,
        table = t,
    }
    for k,v in pairs(t) do
        dict._count = dict._count + 1
    end

    function dict:has(k)
        return self.table[k] ~= nil
    end
    
    function dict:add(k,v)
        self[k] = v
    end
    
    function dict:remove(k)
        if self.table[k] ~= nil then
            self.table[k] = nil
            self._count = self._count - 1
        end
    end

    function dict:__pairs()
        return next,self.table
    end

    function dict:count()
        return self._count
    end

    function dict:__len()
        return self._count
    end
    
    function dict:__newindex(k,v)
        if self.table[k] == nil then
            self.table[k] = v
            if v == nil then
                self._count = self._count - 1
            else
                self._count = self._count + 1
            end
        end
    end
    
    function dict:__index(k)
        return self.table[k]
    end


    setmetatable(dict,dict)
    return dict
end