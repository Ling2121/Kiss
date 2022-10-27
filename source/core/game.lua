local core = require"source/core/core"
local CollisionWorld = require"source/core/collision/collision_world"

return function(config)
    config.CollisionWorldRegionSize = config.CollisionWorldRegionSize or 256;
    config.CollisionPort = config.CollisionPort or "Bump"
    -- 场景集合根目录 ->用于自动场景加载器，不为nil时则为开启
    -- 目录结构
    -- ScenesRootDirectory
    --      L Screne1
    --          L init.lua //返回自定义的场景即可
    config.ScenesRootDirectory = config.ScenesRootDirectory
    config.DefaultSceneName = config.DefaultSceneName or "main"

    local game = {
        CollisionWorld = nil,
        CurrentScene = nil,

        _config = config,
        _scenes = {},
        _load_args = {},
    }

    function game:load(args)
        self._load_args = args or {}

        game.CollisionWorld = CollisionWorld{
            CellSize = config.CollisionWorldRegionSize,
            Port = config.CollisionPort
        }

        local ScenesRootDirectory = self._config.ScenesRootDirectory
        if ScenesRootDirectory ~= nil then
            local fitem = love.filesystem.getDirectoryItems(ScenesRootDirectory)
            for k,name in pairs(fitem) do
                local type = love.filesystem.getInfo(ScenesRootDirectory.."/"..name).type
                if type == "directory" then
                    local path = ScenesRootDirectory.."/"..name
                    local scene = require(path)
                    game._scenes[name] = scene
                end
            end
    
            game:switchScene(self._config.DefaultSceneName,true)
        end
    end

    function game:switchScene(name,is_print_log)
        local scene = self._scenes[name]
        if is_print_log then
            print(string.format("加载%s场景...",name))
        end
        if not scene then
            if is_print_log then
                print("加载失败，请检查是否存在此场景")
            end
            return false 
        end
        scene:applyToLoveCallback()
        scene:load(game._load_args)
        scene:ready()

        if is_print_log then
            print("加载成功")
        end
        return true
    end
    
    function game:quit()
        if self.CurrentScene ~= nil then
            self.CurrentScene:quit()
        end
    end

    return game
end

