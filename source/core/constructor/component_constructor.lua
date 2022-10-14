return function(type_name,t)
    t.__is_constructor__ = true
    t.type_name = type_name
    t.create = function(self,...)
        local c = {__comp_name__ = type_name}
        t:make(c,...)
        return c
    end

    return setmetatable(t,{__call = t.create})
end