local list = {
    __list__ = true,
    count = 0,
}

function list:__len()
    return self.count
end

function list:has(v)
    for i,item in ipairs(self) do
        if item == v then
            return true
        end
    end
    return false
end

function list:add(v)
    self.count = self.count + 1
    table.insert(self,v)
end

function list:insert(i,v)
    self.count = self.count + 1
    table.insert(self,i,v)
end

function list:remove(i)
    if self.count <= 0 then return end
    local rm = table.remove(self,i)
    self.count = self.count - 1
    return rm
end

function list:removeBack()
    if self.count <= 0 then return end
    self[self.count] = nil
    self.count = self.count - 1
end

function list:iter(i)
    i = i + 1
    if i > self.count then return nil end
    return i,self[i]
end

function list:items()
    return self.iter,self,0
end

return function(t)
    t  = t or {}
    return setmetatable(t,{__index = list});
end