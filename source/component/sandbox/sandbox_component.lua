--[[
    sandbox
        L sandbox_component
            L region ...
]]
return core.ComponentConstructor("SandboxComponent",{
    make = function (self,component)
        component.tile_index_table = {}--数字索引到字符索引的哈希表，用于从TileSet获取Tile
        component.regions = {} 

        function component:addRegion(region,x,y)
            if self.regions[y] == nil then
                self.regions[y] = {}
            end
            self.regions[y][x] = region
        end

        
    end
})