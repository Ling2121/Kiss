local list = {
    __list__ = true,
    _count = 0,
}

function list:has(v)
    for i,item in ipairs(self) do
        if item == v then
            return true
        end
    end
    return false
end

function list:add(v)
    self._count = self._count + 1
    table.insert(self,v)
end

function list:insert(i,v)
    self._count = self._count + 1
    table.insert(self,i,v)
end

function list:remove(i)
    if self._count <= 0 then return end
    local rm = table.remove(self,i)
    self._count = self._count - 1
    return rm
end

function list:removeBack()
    if self._count <= 0 then return end
    self[self._count] = nil
    self._count = self._count - 1
end

function list:iter(i)
    i = i + 1
    return i,self[i]
end

function list:count()
    return self._count
end

function list:__len()
    return self._count
end

function list:__ipairs()
    return self.iter,self,0
end

return function(t)
    t  = t or {}
    return setmetatable(t,{__index = list});
end