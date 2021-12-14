core = require"source/core/core"
game = require"source.core/game"{
    CollisionWorldRegionSize = 256,
    ScenesRootDirectory = "source/scenes",
    DefaultSceneName = "main"
}

function love.load(args)
    game:load(args)
end