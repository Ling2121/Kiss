core = require"source/core/core"
game = require"source.core/game"{
    CollisionWorldRegionSize = 256,
    ScenesRootDirectory = "source/scenes",
    DefaultSceneName = "main"
}

function love.load(args)
    core:load()
    game:load(args)
end

function love.quit()
    game:quit()
    core:quit()
end