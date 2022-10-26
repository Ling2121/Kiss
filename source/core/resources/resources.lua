local utilities = require"source/core/base/utilities"

--[[
    资源管理器

    资源类型
        Image 图片
        Audio 声音
        Font 字体
        Tileset 瓷砖集

    功能
        预加载资源
        防止重复资源加载
        资源编组
        自定义资源加载
    
    资源加载器
        配置文件 (lua格式)
            [加载器名称].resld.lua
                return {
                    load = function(res,path,...)
                        res[xxx] = xxx
                    end,

                    get = function(res,...)
                        return res[xxx]
                    end
                }
            参数
                这个函数会在加载指定资源的时候执行
                第一个参数会传入加载文件的完整路径
                后续参数则是用户在调用时传入的参数
                
            例子
                /assets/font/font1.ttf
                
                core.Resources:get("/assets/font/font1.ttf",13)
                    -> res.item = font_loader("/assets/font/font1.ttf",13)



    资源配置
        配置文件 (json格式)
            [资源同名文件].res
            可在任何文件夹内创建

        格式
            {
                //编组

                //第一种形式
                group_setting : {
                    {"Group1","XXX"},
                    {"Group2","XXX"}
                },
                //第二种形式
                group_setting : ["Group1","xxxx"]
                

                loader : "xxx",//加载器
                properties : {},//属性
            }
        生成的table
            {
                source = "xxx",//源文件完整路径

                group = "xxx",
                loader = "xxx",
                properties = {},
            }
--]]

FILE_TYPE_IMAGE = "image"
FILE_TYPE_AUDIO = "audio"
FILE_TYPE_FONT = "font"
FILE_TYPE_TILESET = "tileset"
FILE_TYPE_LUAFILE = "luafile"
FILE_TYPE_RESOURCE = "resource"
FILE_TYPE_RESOURCE_LOADER = "resource_loader"

local match_table = {
    -- 资源配置文件
    {"([0-9a-zA-z_]+)%.res$", FILE_TYPE_RESOURCE,".res"},
    
    -- 资源加载器
    {"([0-9a-zA-z_]+)%.resld%.lua$", FILE_TYPE_RESOURCE_LOADER,".resld.lua"},
    -- lua文件
    {"([0-9a-zA-z_]+)%.lua$", FILE_TYPE_LUAFILE,".lua"},

    -- 图像文件
    {"([0-9a-zA-z_]+)%.png$", FILE_TYPE_IMAGE,".png"},
    {"([0-9a-zA-z_]+)%.jpg$", FILE_TYPE_IMAGE,".jpg"},
    {"([0-9a-zA-z_]+)%.jpeg$",FILE_TYPE_IMAGE,".jpeg"},

    -- 音频
    {"([0-9a-zA-z_]+)%.ogg$", FILE_TYPE_AUDIO,".ogg"},
    {"([0-9a-zA-z_]+)%.mp3$", FILE_TYPE_AUDIO,".mp3"},
    {"([0-9a-zA-z_]+)%.wav$", FILE_TYPE_AUDIO,".wav"},

    -- 字体
    {"([0-9a-zA-z_]+)%.otf$", FILE_TYPE_FONT,".otf"},
    {"([0-9a-zA-z_]+)%.ttf$", FILE_TYPE_FONT,".ttf"},
}

return function(path)
    local items = utilities.getAllFileItem(match_table,path)

    local self = {
        resources = {},
        groups = {},
        loaders = {},
    }

    function self:getDefualtLoader(file_item)
        return self.loaders[file_item.type]
    end

    function self:groupAdd(group_name,name,obj)
        if not self.groups[group_name] then
            self.groups[group_name] = {}
        end
        self.groups[group_name][name] = obj
    end

    --加载所有资源加载器
    for i,item in ipairs(items) do
        if item.type == FILE_TYPE_RESOURCE_LOADER then
            local loader,err2 =  loadstring(love.filesystem.read(item.path))()
            self.loaders[loader.name] = loader
        end
    end

    for i,item in ipairs(items) do
        local setting_file_name = item.path .. ".res"
        
        --获取资源配置文件
        local info = love.filesystem.getInfo(setting_file_name)
        local res_setting = nil
        if info ~= nil and info.type == "file" then
            res_setting = utilities.loadJsonToTable(setting_file_name)
        end
        
        if res_setting ~= nil then
            loader = self.loaders[res_setting.loader] or loader
        end

        --有相对应加载器的资源才需要加载
        if loader ~= nil then
            local res = {
                --! 资源的源属性(只读)
                _source = {
                    is_loaded = false,

                    type = item.type,
                    source = item.path,
                    setting = res_setting,
                    loader = loader.name,
                }
            }
            self.resources[item.path] = res

            if res_setting ~= nil then
                --编组
                local group_setting = res_setting.group_setting
                if group_setting ~= nil then
                    if #group_setting > 0 then
                        if type(group_setting[1]) == "table" then
                            for i,setting in ipairs(group_setting) do
                                local group_name = setting[1]
                                local name = setting[2] or item.path
                                self:groupAdd(group_name,name,res)
                            end
                        else
                            local group_name = group_setting[1]
                            local name = group_setting[2] or item.path
                            self:groupAdd(group_name,name,res)
                        end
                    end
                end
            end
        end 
    end

    function self:_load_(res,...)
        local source = res._source
        if source.is_loaded then return end
        local loader = self.loaders[source.loader]
        if loader == nil then return end
        loader.load(res,source.source,source.setting,...)
        source.is_loaded = true
    end

    function self:getFromGroup(group_name,name,...)
        local group = self.groups[group_name]
        if group == nil then return nil end
        local item = group[name]
        if item == nil then return nil end
        if not item._source.is_loaded then
            self:_load_(item,...)
        end
        local loader = self.loaders[item._source.loader]
        return loader.get(item,...)
    end

    function self:get(path,...)
        local item = self[path]
        if not item then
            return nil
        end
        if not item._source.is_loaded then
            return self:_load_(item,...)
        end

        local loader = self.loaders[item._source.loader]
        return loader.get(item,...)
    end

    return self
end

