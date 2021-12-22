return core.ComponentCountructor("MoveComponent",{
    make = function(self,component,position_component)
        component.vx = 0
        component.vy = 0
        component.position = position_component

        component.update = function(self,entity,dt)
            component.position.x = component.position.x + vx
            component.position.y = component.position.y + vy
        end
    end
})