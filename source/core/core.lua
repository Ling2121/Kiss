

love.graphics.setDefaultFilter("nearest","nearest")

core = {
    Thread;                 --多线程模块
    Resources;              --资源管理模块
    EntityCountructor;      --实体构造器
    ComponentConstructor;   --组件构造器
    Utilities;              --实用工具集
}

function core:load()
    self.Resources = require"source/core/resources/resources"("")
    self.EntityCountructor = require"source/core/constructor/entity_constructor"
    self.ComponentConstructor = require"source/core/constructor/component_constructor"
    self.Utilities = require"source/core/base/utilities"
end

function core:quit()
    
end

return core