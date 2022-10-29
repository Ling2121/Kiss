local carray = require"source/core/base/carray"

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

return core.ComponentConstructor("SandboxRegionComponent",{
    make = function(_,self,x,y,width,height,tile_size)
        x = x or 0
        y = y or 0
        width = width or 32
        height = height or 32
        tile_size = tile_size or 16
        
        local canvas_width = width * tile_size
        local canvas_height = height * tile_size
        local count = width * height;

        self.x = x
        self.y = y
        self.world_x = x * canvas_width
        self.world_y = y * canvas_height
        self.width = width
        self.height = height
        self.tile_size = tile_size
        self.tile_index_hash = {_index = 0}
        self.tiles = carray(CARRAY_TYPE_UINT32,count,0)
        self.canvas = love.graphics.newCanvas(canvas_width,canvas_height)
        self._draw_buffer = {}

        function self:setTile(tileset_name,tile_name,index,y)
            if y ~= nil then
                index = y * width + index
            end

            if index < 0 or index >= (self.width * self.height) then return end

            local tileset = core.Resources:getFromGroup("TileSets",tileset_name)
            local tile_index = getTileIndex(self.tile_index_hash,tileset_name,tile_name)
            local tile = tileset:getTile(tile_name)
            if tile ~= nil then
                self.tiles[index] = tile_index

                

                y = math.floor(index / self.height)
                local x = math.abs(y * self.width - index)
                --设置Tile不会立即在画布上生效，需要redraw
                --为什么？
                --有时候需要对大片区域进行设置，这样做避免了频繁的对画布进行重复设置
                table.insert(self._draw_buffer,{x * self.tile_size,y * self.tile_size,tile})
            end
        end

        function self:redraw()
            if next(self._draw_buffer) == nil then return end

            love.graphics.setCanvas(self.canvas)

            for i,item in ipairs(self._draw_buffer) do
                local tile = item[3]
                tile:draw(item[1],item[2])
            end

            love.graphics.setCanvas()

            self._draw_buffer = {}
        end

        function self:draw(camera)
            love.graphics.draw(self.canvas,self.world_x,self.world_y)
        end

    end
})