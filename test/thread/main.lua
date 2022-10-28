local d = love.data.newByteData("a")



function love.load()
    local f = function() print("Hello")end
    local t = love.thread.newThread(string.dump(f))
    t:start()
    
end