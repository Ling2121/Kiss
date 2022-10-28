local d = love.data.newByteData("a")



function love.load()
    local t = love.thread.newThread(string.dump(function() print("hello") end))
    t:start()
    
end