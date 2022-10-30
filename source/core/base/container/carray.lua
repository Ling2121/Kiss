local ffi = require"ffi"

CARRAY_TYPE_BYTE = 1
CARRAY_TYPE_INT32 = 2
CARRAY_TYPE_UINT32 = 3


local function iter(self,i)
    i = i + 1
    if i >= self._lenght then return nil end
    return i,self.arr[i]
end

return function(dtype,len,init_value)
    local self = {
        __carray__ = true;
        type = dtype,
        _lenght = len;
        array = nil,
    }

    function self:__len()
        return self._lenght
    end

    function self:__newindex(k,v)
        if type(k) ~= 'number' then return end
        if k < 0 or k >= self._lenght then return end
        
        self.array[k] = v
    end

    function self:__index(k)
        if type(k) ~= 'number' then return end
        if k < 0 or k >= self._lenght then return end

        return self.array[k]
    end

    function self:has(v)
        for i,item in self:items() do
            if item == v then
                return true
            end
        end
        return false
    end

    if dtype == CARRAY_TYPE_BYTE then
        self.array = ffi.new('unsigned char[?]',len,init_value)
    end

    if dtype == CARRAY_TYPE_INT32 then
        self.array = ffi.new('int32_t[?]',len,init_value)
    end

    if dtype == CARRAY_TYPE_UINT32 then
        self.array = ffi.new('uint32_t[?]',len,init_value)
    end

    function self:items()
        return iter,self,-1
    end

    return setmetatable(self,self)
end