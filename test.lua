local x = 100

function a(x)
    print("aaaa",x,_G)
end

function b(x)
    a(100)
end

local d = string.dump(b)

load(d)()