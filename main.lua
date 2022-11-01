core = require"source/core/core"
game = require"source.core/game"{
    CollisionWorldRegionSize = 256,
    ScenesRootDirectory = "source/scenes",
    DefaultSceneName = "data_file_test"
}

function love.load(args)
    os.execute("chcp 65001")

    core:load()
    game:load(args)
end

function love.update(dt)
    core:update()
    game:update(dt)
end

function love.quit()
    game:quit()
    core:quit()
end