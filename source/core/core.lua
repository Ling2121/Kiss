core = {
    Resources = require"source/core/resources/resources"("assets"),
    Scene = require"source/core/scene/scene",
    Sandbox = require"source/core/scene/sandbox",

    EntityCountructor = require"source/core/ec/entity_constructor",
    ComponentCountructor = require"source/core/ec/component_constructor"
}

return core