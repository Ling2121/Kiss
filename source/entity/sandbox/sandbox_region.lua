local SandboxRegionComponent = require"source/component/sandbox/sandbox_region_component"

return core.EntityCountructor("SandboxRegion",{
    make = function(_,self,x,y,width,height,tile_size)
        self:addComponent(SandboxRegionComponent(x,y,width,height,tile_size))
    end
})