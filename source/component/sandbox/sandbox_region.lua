local ffi = require"ffi"

local function getTileIndex(table,tileset_name,tile_name)
    if table[tileset_name] == nil then
        table[tileset_name] = {}
    end
    local t = table[tileset_name][tile_name];
    if t ~= nil then return t end
    t = table._index;
    table._index = table._index + 1

    table[tileset_name][tile_name] = t
    table[t] = {tileset_name,tile_name}
    return t
end

return function(width,height,tile_size)
    width = width or 32
    height = height or 32
    tile_size = tile_size or 16
    
    local canvas_width = width * tile_size
    local canvas_height = height * tile_size
    local count = width * height;

    local self = {
        width = width,
        height = height,
        tile_index_hash = {_index = 0},
        tiles = ffi.new("int[?]",count,0),
        canvas = love.graphics.newCanvas(canvas_width,canvas_height),
    }

    function self:setTile(tileset_name,tile_name,index,y)
        if y ~= nil then
            index = y * width + index
        end
        local tileset = core.Resources:get()
        local tile_index = getTileIndex(self.tile_index_hash,tileset_name,tile_name)
        
    end

    return self;
end