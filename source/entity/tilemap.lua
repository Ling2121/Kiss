local TileMapComponent = require"source/component/tilemap_component"

return core.EntityCountructor("TileMap",{
    make = function(_,self,width,height,tile_size)
        self:addComponent(TileMapComponent(width,height,tile_size))
    end
})