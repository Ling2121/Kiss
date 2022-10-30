local stack = {
    __stack__ = true,
    count = 0,
}

function stack:__len()
    return self.count
end

function stack:has(v)
    for i,item in ipairs(self) do
        if item == v then
            return true
        end
    end
    return false
end

function stack:push(v)
    self.count = self.count + 1
    table.insert(self,v)
end

function stack:pop()
    return table.remove(self)
end

function stack:top()
    return self[self.count]
end

function stack:iter(i)
    i = i + 1
    if i > self.count then return nil end
    return i,self[i]
end

function stack:items()
    return self.iter,self,0
end

return function(t)
    t = t or {}
    return setmetatable(t,{__index = stack})
end