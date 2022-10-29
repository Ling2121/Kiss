local BlobWriter = require"library/moonblob/BlobWriter"
local BlobReader = require"library/moonblob/BlobReader"

DATAFILE_MODE_READ = 'r'
DATAFILE_MODE_WRITE = 'w'

return function(path)
    local self = {
        file = nil,
        mode = nil,
        _writer = nil,
        _reader = nil,
    }

    self.file = love.filesystem.newFile(path)

    function self:open(mode)
        self.mode = mode
        if mode == DATAFILE_MODE_READ then
            self._writer = BlobWriter()
            self._reader = nil
        end

        if mode == DATAFILE_MODE_WRITE then
            self._reader = BlobReader()
            self._writer = nil
        end
        return self.file:open(mode)
    end

    function self:write(value)
        
    end

    function self:writeByte(value)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'number' then return false end
        self._writer:u8(value)
    end

    function self:writeInt32(value)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'number' then return false end
        self._writer:s32(value)
    end

    function self:writeUInt32(value)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'number' then return false end
        self._writer:u32(value)
    end

    function self:writeFloat(value)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'number' then return false end
        self._writer:f32(value)
    end

    function self:writeDouble(value)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'number' then return false end
        self._writer:f64(value)
    end

    function self:writeString(value)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'string' then return false end
        self._writer:string(value)
    end

    function self:writeCIntArray(value,len)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'cdata' then return end

    end

    function self:writeCByteArray(value,len)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'cdata' then return end
        
    end

    function self:writeArray(value)
        if self.mode ~= DATAFILE_MODE_WRITE then return false end
        if type(value) ~= 'table' then return end
        local len = #value
        for i = 1,len do
            local value = 
        end
    end

    function self:writeTable()
        
    end

    return self
end