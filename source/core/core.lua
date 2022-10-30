

love.graphics.setDefaultFilter("nearest","nearest")

core = {
    Containers = require"source/core/base/container/containers";                    --基本容器
    Utilities = require"source/core/base/utilities";                                --实用工具集
    EntityCountructor = require"source/core/constructor/entity_constructor";        --实体构造器
    ComponentConstructor = require"source/core/constructor/component_constructor";  --组件构造器

    Thread;                                                                         --多线程模块
    Resources;                                                                      --资源管理模块
}

function core:load()
    self.Thread = require"source/core/thread/thread"()
    self.Resources = require"source/core/resources/resources"("")
end

function core:update()
    self.Thread:update()
end

function core:quit()
    self.Thread:quit()
end

return core