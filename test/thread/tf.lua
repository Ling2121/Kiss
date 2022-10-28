require"love.timer"

local t = nil
print("start")
while true do
    local c = love.thread.getChannel("c1")
    local s = c:peek()5
    if s then
        t = s
        break
    end
end
print("~~~")
local f = io.open("a.txt",'w+')

while true do
    if not pcall(t.getSize,t) then
        f:write("exit")
        f:flush()
        break 
    end

    f:write("hello")
    f:flush()

    love.timer.sleep(2)
    
end

f:close()
print("exit")