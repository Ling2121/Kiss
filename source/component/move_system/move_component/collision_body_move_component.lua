local Signal = require"source/core/base/signal"
local MoveComponent = require"source/component/move_system/move_component/move_component"

return core.ComponentCountructor("CollisionBodyMoveComponent",{
    make = function(self,component,collision_body_component)
        MoveComponent:make(component)
        component.body = collision_body_component
        component._Collision = Signal()
        component.update = function(self,entity,dt)
            local collisions = self.body:moveAndSyncToPosition(self.vx,self.vy)
            if collisions ~= nil and next(collisions) ~= nil then
                component._Collision:emit(collisions)
            end
        end
    end
})