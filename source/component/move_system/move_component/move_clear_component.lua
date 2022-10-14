return core.ComponentConstructor("MoveClearComponent",{
    make = function(self,component,move_component)
        component.is_clear = true
        component.move_component = move_component

        component.update = function(self,entity,dt)
            if self.is_clear then
                component.move_component.vx = 0
                component.move_component.vy = 0
            end
        end
    end
})