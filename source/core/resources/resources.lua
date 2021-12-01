local utilities = require"source/core/base/utilities"

local function newTileset(file_item)
    -- 需要在同级目录创建
    -- 一个图像文件        -> 名称.png
    -- 一个Tileset结构文件 -> 名称.tileset.json
    --                      {
    --                          name : "Tileset名称"
    --                          tile_width : 16,
    --                          tile_height : 16,
    --                          tiles : [               这里的Tile对应顺序是从左到右，上到下进行递增
    --                              {name:"项名"},       1,2,3,
    --                              {name:"项名"},       4,5,6,
    --                              {name:"项名"},       7,8,9
    --                              ...                 
    --                          ]
    --                      }
    local file_name = file_item.name
    local image_name = file_name..".png"
    local image_path = file_item.dir.."/"..image_name
    local image = love.graphics.newImage(image_path)
    local json = utilities.loadJsonToTable(file_item.path)
    local tileset = {
        name = json.name,
        tile_width = json.tile_width,
        tile_height = json.tile_height,
        image = image,
        tiles = {}
    }

    local imgw,imgh = image:getWidth(),image:getHeight()
    local tlew,tleh = json.tile_width,json.tile_height
    local tlewsize,tlehsize = math.floor(imgw / tlew), math.floor(imgh / tleh)

    local tile_draw_fn = function(tile,...)
        love.graphics.draw(tile.image,tile.quad,...)
    end

    local x,y = 0,0
    for i,item in ipairs(json.tiles) do
        item.quad = love.graphics.newQuad(x * tlew,y * tleh,tlew,tleh,imgw,imgh)
        item.image = image
        item.draw = tile_draw_fn
        tileset.tiles[item.name] = item

        function item:type()
            return "Tile"
        end
        
        x = x + 1
        if x > tlewsize then
            x = 0
            y = y + 1
        end
    end

    tileset.getTile = function(self,name)
        return self.tiles[name]
    end

    function tileset:type()
        return "TileSet"
    end

    return tileset
end

return function(path)
    local items = utilities.getAllFileItem(path)
    local resources = {}

    for i,item in ipairs(items) do
        if item.type == FILE_TYPE_IMAGE then
            resources[item.path] = {
                item = love.graphics.newImage(item.path),
                get = function(self)
                    return self.item
                end
            }
        end

        if items.type == FILE_TYPE_AUDIO then
            resources[item.path] = {
                item = love.graphics.newImage(item.path),
                get = function(self)
                    return self.item
                end
            }
        end

        if item.type == FILE_TYPE_FONT then
            resources[item.path] = {
                path = item.path,
                fonts = {},--各个大小的字体
                get = function(self,size)
                    if self.fonts[size] == nil then
                        self.fonts[size] = love.graphics.newFont(self.path,size)
                    end
                    return self.fonts[size]
                end
            }
        end

        if item.type == FILE_TYPE_TILESET then
            resources[item.path] = {
                item = newTileset(item),
                get = function(self,name)
                    if name == nil then
                        return self.item
                    end
                    return self.item.tiles[name]
                end
            }
        end
    end

    function resources:get(path,...)
        local item = self[path]
        if not item then
            return nil
        end
        return item:get(...)
    end

    return resources
end

