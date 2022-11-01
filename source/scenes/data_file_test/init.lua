local Sandbox = require"source/entity/sandbox/sandbox"
local DataFile = require"source/core/filesystem/data_file"


local sandbox = Sandbox()

local fuck = {
    get_dict_str = 0,
    get_list_str = 0,
}


function fuck:get_dict_str(dict)
    local str = "{"
    for k,v in pairs(dict) do
        if type(v) == 'table' then
            if v.__list__ then
                str = string.format("%s %s:%s ",str,k,self:get_list_str(v))
            else
                str = string.format("%s %s:%s ",str,k,self:get_dict_str(v))
            end
        else
            str = str .. string.format(" %s : %s ",k,v)
        end
    end
    str = str .. "}"
    return str
end

function fuck:get_list_str(list)
    local str = "["
    for i,v in ipairs(list) do
        if type(v) == 'table' then
            if v.__dictionary__ or v.__list__ == nil and v.__carray__ == nil then
                str = str .. self:get_dict_str(v)
            else
                str = str .. self:get_list_str(v)
            end
        else
            if i ~= #list - 1 then
                str = str .. string.format("%s,",v)
            else
                str = str .. string.format("%s",v)
            end
        end
    end
    str = str.."]"
    return str
end

function sandbox:load()
    local file = DataFile("a.dat")

    file:open(DATAFILE_MODE_WRITE)

    local s32_1 = 233333
    file:writeInt32(s32_1)
    local s32_2 = -233333
    file:writeInt32(s32_2)
    local s64_1 = 1099511627775 --0xFFFFFFFFFF
    file:writeInt64(s64_1)
    local s64_2 = -1099511627775
    file:writeInt64(s64_2)
    local u32 = 4294967295
    file:writeUInt32(u32)
    local f32 = 3.1415
    file:writeFloat(f32)
    local f64 = 1.79E+308
    file:writeDouble(f64)
    local str = "Hello world  你好,世界"
    file:writeString(str)
    local list1 = core.Containers.List({s32_1,s32_2,s64_1,u32,f64,"啊啊啊"})
    file:writeList(list1)
    local list2 = core.Containers.List({233,list1})
    file:writeList(list2)
    local dict = core.Containers.Dictionary({x = 100,y = 200,name = "Players",backpack = list1})
    file:writeDictionary(dict)
    local dict2 = core.Containers.Dictionary({player_count = 1,player1 = dict})
    file:writeDictionary(dict2)
    local carr = core.Containers.CArray(CARRAY_TYPE_INT32,8,2333)
    file:writeCArray(carr)
    local list3 = core.Containers.List({"1",carr,"2",carr,"3",carr})
    file:writeList(list3)

    
    file:flush()

    file:open(DATAFILE_MODE_READ)

    assert(file:readInt32() == s32_1)
    assert(file:readInt32() == s32_2)
    assert(file:readInt64() == s64_1)
    assert(file:readInt64() == s64_2)
    assert(file:readUInt32() == u32)
    assert(math.ceil(file:readFloat()) == math.ceil(f32))
    assert(math.ceil(file:readDouble()) == math.ceil(f64))
    assert(file:readString() == str)
    print(fuck:get_list_str(file:readList()))
    print(fuck:get_list_str(file:readList()))
    print(fuck:get_dict_str(file:readDictionary()))
    print(fuck:get_dict_str(file:readDictionary()))
    print(fuck:get_list_str(file:readCArray()))
    print(fuck:get_list_str(file:readList()))


    file:close()
end

return sandbox