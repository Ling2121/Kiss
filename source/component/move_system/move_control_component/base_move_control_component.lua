return core.ComponentCountructor("BaseMoveControlComponent",{
    make = function(self,component,move_component,speed,control_func)
        component.speed = speed or 0
        component.add_speed = 0
        component.move_component = move_component

        component.addSpeed = function(self,speed)
            self.add_speed = self.add_speed + speed
        end

        component.getEndSpeed = function(self)
            return self.speed + self.add_speed
        end

        component.control = control_func or function(self,...) return 0,0 end
    end
})