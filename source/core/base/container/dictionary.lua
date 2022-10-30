local dict = {
    __dictionary__ = true,
    count = 0,
    table = {},
}

function dict:__len()
    return self.count
end

function dict:__newindex(k,v)
    rawset(self.table,k,v)
end

function dict:__index(k)
    return rawget(self.table,k)
end

function dict:has(k)
    return self.table[k] ~= nil
end

function dict:add(k,v)
    if self.table[k] == nil then
        self.table[k] = v
        self.count = self.count + 1
    end
end

function dict:remove(k)
    if self.table[k] ~= nil then
        self.table[k] = nil
        self.count = self.count - 1
    end
end

function dict:items()
    return next,self.table
end

return function(t)
    t = t or {}
    return setmetatable(t,{__index = dict})
end