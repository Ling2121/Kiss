local ffi = require"ffi"

CARRAY_TYPE_BYTE = 1
CARRAY_TYPE_INT32 = 2
CARRAY_TYPE_UINT32 = 3


local function iter(self,i)
    i = i + 1
    if i >= self._lenght then return nil end
    return i,self.arr[i]
end

return function(type,len,init_value)
    local self = {
        type = type,
        _lenght = len;
        array = nil,
    }

    if type == CARRAY_TYPE_BYTE then
        self.array = ffi.new('unsigned char[?]',len,init_value)
    end

    if type == CARRAY_TYPE_INT32 then
        self.array = ffi.new('int32_t[?]',len,init_value)
    end

    if type == CARRAY_TYPE_UINT32 then
        self.array = ffi.new('uint32_t[?]',len,init_value)
    end

    function self:__index(key)
        if type(key) == 'number' then
            if key > 0 and key < self.lenght then
                return self.array[key]
            end
        end
        return rawget(self,key)
    end

    function self:__len()
        return self._lenght
    end

    function self:items()
        return iter,self,-1
    end

    return self
end