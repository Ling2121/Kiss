local BaseMoveControlComponent = require"source/component/move_system/move_control_component/base_move_control_component"

return core.ComponentConstructor("MoveControlComponent",{
    --control_func(self,dt) return vx,vy
    make = function(self,component,move_component,speed,control_func)
        control_func = control_func or function(self,key) return 0,0 end
        BaseMoveControlComponent.make(self,component,move_component,speed,control_func)

        component.update = function(self,entity,dt)
            local vx,vy = self:control(dt)
            self.move_component.vx = vx
            self.move_component.vy = vy
        end
    end
})