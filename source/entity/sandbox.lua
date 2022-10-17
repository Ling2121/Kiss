local Scene = require"source/core/scene/scene"
local Camera = require"library/camera"
local regulatory_callbacks = require"source/core/scene/regulatory_callbacks"

return core.EntityCountructor("Sandbox",{
    base_make = function(self,...) return Scene(256) end;

    make = function (self,sandbox)
        sandbox.camera = Camera(0,0)
        sandbox._addEntity = sandbox.addEntity

        sandbox.addEntity = function(self,entity,name)
            local sandbox_object = entity:getComponent("SandboxObjectComponent")
            local depth_f = function(self)
                return 0
            end
            if sandbox_object then
                depth_f = function(self)
                    return sandbox_object.depth
                end
            end
            self:_addEntity(entity,name,depth_f)
        end

        --生成回调函数
        for i,name in ipairs(regulatory_callbacks) do
            sandbox[name] = function(self,...)
                for entity in sandbox._list:iter() do
                    if entity[name] ~= nil then
                        local sandbox_object = entity:getComponent("SandboxObjectComponent")
                        if sandbox_object == nil then
                            entity[name](entity,...)
                        else
                            if sandbox_object.is_process then
                                entity[name](entity,...)
                            end
                        end
                    end
                end
            end
        end

        sandbox.update = function(self,dt)
            local d
            for node in sandbox._list:iterNodes() do
                d = node:getDepth()
                if d ~= node.up_depth then
                    node.up_depth = d
                    sandbox._list:_remove(node)
                    sandbox._list:_add(node)
                end
            end

            for item in sandbox._list:iter() do
                if item.update then
                    local sandbox_object = item:getComponent("SandboxObjectComponent")
                    if sandbox_object == nil then
                        item:update(dt)
                    else
                        if sandbox_object.is_process then
                            item:update(dt)
                        end
                    end
                end
            end
        end

        sandbox.draw = function(self)
            self.camera:attach()
            for item in self._list:iter() do
                if item.draw then
                    local sandbox_object = item:getComponent("SandboxObjectComponent")
                    if sandbox_object == nil then
                        item:draw(self.camera)
                    else
                        if sandbox_object.is_process and sandbox_object.is_display then
                            item:draw(self.camera)
                        end
                    end
                end
            end
            self.camera:detach()
        end

    end
})