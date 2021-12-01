return core.ComponentCountructor("PositionComponent",{
    make = function(self,component,x,y)
        component.x = x or 0
        component.y = y or 0
    end
})