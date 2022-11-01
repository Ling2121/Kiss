local BlobWriter = require"library/moonblob/BlobWriter"
local BlobReader = require"library/moonblob/BlobReader"

local Containers = require"source/core/base/container/containers"

DATAFILE_MODE_READ = 'r'
DATAFILE_MODE_WRITE = 'w'

DataFileTypeLabel = {
    Byte = 0,
    Int32 = 1,
    Int64 = 2,
    UInt32 = 3,
    Float = 4,
    Double = 5,
    Boolean = 6,
    String = 7,
    List = 8,
    CArray = 9,
    Dictionary = 10,
}

local DataFileTypeLabelNames = {
    [DataFileTypeLabel.Byte] = "Byte",
    [DataFileTypeLabel.Int32] = "Int32",
    [DataFileTypeLabel.Int64] = "Int64",
    [DataFileTypeLabel.UInt32] = "UInt32",
    [DataFileTypeLabel.Float] = "Float",
    [DataFileTypeLabel.Double] = "Double",
    [DataFileTypeLabel.Boolean] = "Boolean",
    [DataFileTypeLabel.String] = "String",
    [DataFileTypeLabel.List] = "List",
    [DataFileTypeLabel.CArray] = "Carray",
    [DataFileTypeLabel.Dictionary] = "Dictionary",
}

local ARRAY_TYPE_LABEL_LUATABLE = 0
local ARRAY_TYPE_LABEL_LIST = 1

local CArrayWriteFuncNames = {
    [CARRAY_TYPE_BYTE] = 'u8',
    [CARRAY_TYPE_INT32] = 's32',
    [CARRAY_TYPE_UINT32] = 'u32',
}

local CArrayReadFuncNames = {
    [CARRAY_TYPE_BYTE] = 'u8',
    [CARRAY_TYPE_INT32] = 's32',
    [CARRAY_TYPE_UINT32] = 'u32',
}

return function(path)
    local self = {
        file = nil,
        mode = nil,
        _writer = nil,
        _reader = nil,
    }

    self.file = love.filesystem.newFile(path)

    function self:open(mode)
        self.file:close()
        self.mode = mode
        if mode == DATAFILE_MODE_WRITE then
            self._writer = BlobWriter()
            self._reader = nil
        end

        if mode == DATAFILE_MODE_READ  then
            self._reader = BlobReader(self.file:read())
            self._writer = nil
        end
        return self.file:open(mode)
    end

    function self:flush()
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        self.file:write(self._writer:tostring())
        self.file:flush()
    end

    function self:close()
        if self.mode == DATAFILE_MODE_WRITE then
            self:flush()
        end
        self.file:close();
    end

    function self:write(value)
        if type(value) == 'number' then
            if math.ceil(value) ~= value then--判断是否是浮点数
                if value > 3.402823E+38 then
                    self:writeDouble(value)
                else
                    self:writeFloat(value)
                end
            else
                if value > 0x7FFFFFFF then--int32极限
                    self:writeInt64(value)
                else
                    self:writeInt32(value)
                end
            end
        elseif type(value) == 'boolean' then
            self:writeBoolean(value)
        elseif type(value) == 'string' then
            self:writeString(value)
        elseif type(value) == 'table' then
            if value.__carray__ then
                self:writeCArray(value)
            elseif value.__list__ then
                self:writeList(value)
            elseif value.__dictionary__ then
                self:writeDictionary(value)
            else
                error(("不支持写入<table>类型的数据"):format(type(value)))
            end
        else
            error(("不支持写入<%s>类型的数据"):format(type(value)))
        end
    end

    function self:writeByte(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'number',"writeByte 需要number类型的数据")

        if type(value) ~= 'number' then return false end
        self._writer:u8(DataFileTypeLabel.Byte)
        self._writer:u8(value)
    end

    function self:writeBoolean(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'boolean',"writeByte 需要boolean类型的数据")
        self._writer:u8(DataFileTypeLabel.Boolean)
        self._writer:bool(value)
    end

    function self:writeInt32(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'number',"writeInt32 需要number类型的数据")

        self._writer:u8(DataFileTypeLabel.Int32)
        self._writer:s32(value)
    end

    function self:writeInt64(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'number',"writeInt32 需要number类型的数据")

        self._writer:u8(DataFileTypeLabel.Int64)
        self._writer:s64(value)
    end

    function self:writeUInt32(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'number',"writeUInt32 需要number类型的数据")

        if type(value) ~= 'number' then return false end
        self._writer:u8(DataFileTypeLabel.UInt32)
        self._writer:u32(value)
    end

    function self:writeFloat(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'number',"writeFloat 需要number类型的数据")

        self._writer:u8(DataFileTypeLabel.Float)
        self._writer:f32(value)
    end

    function self:writeDouble(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'number',"writeDouble 需要number类型的数据")
        
        self._writer:u8(DataFileTypeLabel.Double)
        self._writer:f64(value)
    end

    function self:writeString(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'string',"writeString 需要string类型的数据")

        self._writer:u8(DataFileTypeLabel.String)
        self._writer:string(value)
    end

    function self:writeList(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'table' and value.__list__,"writeArray 需要core.Containers.List类型的数据")

        self._writer:u8(DataFileTypeLabel.List)
        if value.__array__ then
            self._writer:u8(ARRAY_TYPE_LABEL_LUATABLE)
        else
            self._writer:u8(ARRAY_TYPE_LABEL_LIST)
        end
        
        local len = #value
        self._writer:u32(len)

        for i = 1,len do
            local v = value[i]
            self:write(v)
        end
    end

    function self:writeCArray(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'table' and value.__carray__,"writeArray 需要core.Containers.CArray类型的数据")
        self._writer:u8(DataFileTypeLabel.CArray)
        local len = #value
        self._writer:u8(value.type)
        self._writer:u32(len)
        local write_func = CArrayWriteFuncNames[value.type]

        for i = 0,len - 1 do
            local v = value[i]
            self._writer[write_func](self._writer,v)
        end
    end

    function self:writeDictionary(value)
        assert(self.mode == DATAFILE_MODE_WRITE,"文件模式需要为 DATAFILE_MODE_WRITE 或 'w'")
        assert(type(value) == 'table'and value.__dictionary__,"writeArray 需要core.Containers.Dictionary类型的数据")
        self._writer:u8(DataFileTypeLabel.Dictionary)
        self._writer:u32(#value)
        for k,v in pairs(value) do
            self._writer:string(tostring(k))
            self:write(v)
        end
    end

    function self:readNext()
        local type = self._reader:u8()
        if type == DataFileTypeLabel.Int32 then
            return self:_readInt32()
        elseif type == DataFileTypeLabel.Int64 then
            return self:_readInt64()
        elseif type == DataFileTypeLabel.UInt32 then
            return self:_readUInt32()
        elseif type == DataFileTypeLabel.String then
            return self:_readString()
        elseif type == DataFileTypeLabel.Boolean then
            return self:_readBoolean()
        elseif type == DataFileTypeLabel.List then
            return self:_readList()
        elseif type == DataFileTypeLabel.CArray then
            return self:_readCArray()
        elseif type == DataFileTypeLabel.Dictionary then
            return self:_readDictionary()
        else
            error(("读取到未知的类型<%d>"):format(type))
        end
    end

    function self:_readInt32()
        return self._reader:s32()
    end

    function self:_readInt64()
        return self._reader:s64()
    end

    function self:_readUInt32()
        return self._reader:u32()
    end

    function self:_readFloat()
        return self._reader:f32()
    end

    function self:_readDouble()
        return self._reader:f64()
    end

    function self:_readString()
        return self._reader:string()
    end

    function self:_readBoolean()
        return self._reader:bool()
    end

    function self:_readList()
        local arr_type = self._reader:u8()
        local len = self._reader:u32()
        local list = {}

        if arr_type == ARRAY_TYPE_LABEL_LIST then
            list = Containers.List()
            for i = 1,len do
                list:add(self:readNext())
            end
        else
            for i = 1,len do
                list[i] = self:readNext()
            end
        end
        return list
    end

    function self:_readCArray()
        local type = self._reader:u8()
        local len = self._reader:u32()
        local carray = Containers.CArray(type,len)
        local read_func = self._reader[CArrayReadFuncNames[type]]
        for i = 0,len - 1 do
            carray[i] = read_func(self._reader)
        end
        return carray
    end

    function self:_readDictionary()
        local dict = Containers.Dictionary()
        local len = self._reader:u32()
        for i = 1,len do
            local key = self._reader:string()
            dict[key] = self:readNext()
        end
        return dict
    end

    function self:readInt32()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.Int32,("需求int32类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readInt32()
    end

    function self:readInt64()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.Int64,("需求int64类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readInt64()
    end

    function self:readUInt32()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.UInt32,("需求UInt32类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readUInt32()
    end

    function self:readFloat()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.Float,("需求Float类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readFloat()
    end

    function self:readDouble()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.Double,("需求Double类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readDouble()
    end

    function self:readString()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.String,("需求String类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readString()
    end

    function self:readBoolean()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.Boolean,("需求Boolean类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readBoolean()
    end

    function self:readList()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.List,("需求List类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readList()
    end

    function self:readCArray()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.CArray,("需求CArray类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readCArray()
    end

    function self:readDictionary()
        local type = self._reader:u8()
        assert(type == DataFileTypeLabel.Dictionary,("需求Dictionary类型，但读取到的是%s"):format(DataFileTypeLabelNames[type]))
        return self:_readDictionary()
    end

    return self
end