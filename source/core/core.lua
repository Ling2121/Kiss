

love.graphics.setDefaultFilter("nearest","nearest")

core = {
    Resources = require"source/core/resources/resources"(""),
    EntityCountructor = require"source/core/constructor/entity_constructor",
    ComponentConstructor = require"source/core/constructor/component_constructor",
    Utilities = require"source/core/base/utilities"
}

return core