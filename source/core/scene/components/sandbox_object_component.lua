local ComponentConstructor = require"source/core/ec/component_constructor"

return ComponentConstructor("SandboxObjectComponent",{
    make = function(self,component,depth,is_process,is_display)
        component.depth = depth or 0 --更新以及绘制顺序
        component.is_display = is_display or true --是否进行绘制
        component.is_process = is_process or true --为true时才会进行更新
    end
})