return function(type_name,t)
    t.type_name = type_name
    t.make = t.make or function(self,component,...) end
    t.create = function(self,...)
        local c = {__comp_name__ = type_name}
        t:make(c,...)
        return c
    end

    return setmetatable(t,{__call = t.create})
end