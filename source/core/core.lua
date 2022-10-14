love.graphics.setDefaultFilter("nearest","nearest")

core = {
    Resources = require"source/core/resources/resources"("assets"),
    Scene = require"source/core/scene/scene",
    Sandbox = require"source/core/scene/sandbox",
    EntityCountructor = require"source/core/constructor/entity_constructor",
    ComponentConstructor = require"source/core/constructor/component_constructor",
    Utilities = require"source/core/base/utilities"
}

return core