local TileTypeF = function() return "Tile" end
local TileSetTypeF = function() return "TileSet" end

local function newTileset(path,setting)
    local tile_width = setting.properties.tile_width or 16
    local tile_height = setting.properties.tile_height or 16
    local tile_settings = setting.properties.tile_settings or {}
    local image = love.graphics.newImage(path)
    local image_width,image_height = image:getDimensions()
    local tile_width_size = math.floor(image_width / tile_width)
    local tile_height_size = math.floor(image_height / tile_height)

    local self = {
        tile_width = tile_width,
        tile_height = tile_height,
        tiles = {},
        image = image,
        type = TileSetTypeF
    }

    for y = 0,tile_height_size do
        for x = 0,tile_width_size do    
            local index = y * tile_width_size + x
            local tile_setting = tile_settings[tostring(index + 1)]
            local quad = love.graphics.newQuad(x * tile_width,y * tile_height,tile_width,tile_height,image_width,image_height)
            local tile = {
                type = TileTypeF,
                image = image,
                quad = quad,
                setting = tile_setting,
                draw = function(self,...)
                    love.graphics.draw(self.image,self.quad,...)
                end
            }
            
            self.tiles[index] = tile
            
            if tile_setting ~= nil then
                local name = tile_setting.name
                if name ~= nil and self.tiles[name] == nil then
                    self.tiles[name] = tile
                end
            end
        end
    end

    function self:getTile(index_or_name)
        return self.tiles[index_or_name]
    end

    return self
end

return  {
    name = "tileset",

    has = function(res,path,...) return res.item ~= nil end;

    load = function(res,path,setting)
        if res.item ~= nil then return end;
        res.item = newTileset(path,setting)
    end;

    get = function(res,path)
        return res.item
    end
}