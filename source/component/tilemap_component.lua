return core.ComponentConstructor("TileMapComponent",{
    make = function(_,self,width,height,tile_size,...)
        tile_size = tile_size or 16
        local canvas_width = tile_size * (width or 128)
        local canvas_height = tile_size * (height or 128)
        self.window_width = love.graphics.getWidth()
        self.window_height = love.graphics.getHeight()
        self.tile_size = tile_size
        self.canvas = love.graphics.newCanvas(canvas_width,canvas_height)
        self.origin_x = 0
        self.origin_y = 0

        self.setTile = function(self,tileset_or_path,tile_name,x,y)
            local tileset = tileset_or_path
            if type(tileset_or_path) == "string" then
                tileset = core.Resources:getFromGroup("Tilesets",tileset)
            end
            if tileset == nil then
                return
            end
            local tile = tileset:getTile(tile_name)
            if tile == nil then
                return
            end
            love.graphics.setCanvas(self.canvas)
            tile:draw((x or 0) * self.tile_size,(y or 0) * self.tile_size)
            love.graphics.setCanvas()
        end

        self.draw = function(self,camera)
            love.graphics.setScissor(0,0,self.window_width,self.window_height)
            love.graphics.draw(self.canvas,self.origin_x,self.origin_y)

            love.graphics.setScissor()
        end
    end
})