function f(w,h,i)
    local y = math.floor(i / h)
    local x = math.abs(y * w - i)
    print(i,string.format("x %d  y %d",x,y))
end

function f2(rx,rs,wx)
    local lx = wx - (rx * rs)
    print(lx)
end

-- local w,h = 3,3

function f3(rx,rs,x)
    return rx * rs + x
end

local rx,rs = -14,16

f2(rx,rs,f3(rx,rs,14))

-- for i = 0,8 do
--     f(w,h,i)
-- end