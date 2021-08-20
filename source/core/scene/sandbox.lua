local Scene = require"source/core/scene/scene"
local Camera = require"library/camera"

return function()
    local sandbox = Scene(256)
    sandbox.camera = Camera(0,0)
    sandbox._addEntity = sandbox.addEntity

    sandbox.addEntity = function(self,entity,name)
        local depth_comp = entity:getComponent("DepthComponent")
        local depth_f = function(self)
            return 0
        end
        if depth_comp then
            depth_f = function(self)
                return depth_comp.depth
            end
        end
        self:_addEntity(entity,name,depth_f)
    end

    sandbox.draw = function(self)
        self.camera:attach()
        for item in self._list:iter() do
            if item.draw then
                item:draw()
            end
        end
        self.camera:detach()
    end

    return sandbox
end