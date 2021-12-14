local max_v = 10000
function f(x,y)
    return math.ceil(y) * 100000 + math.ceil(x)
end

local n = 100

local list = {
    {n,n},
    {-n + 100,n},
    {-n,-n + 400},
    {n,-n},
}

for i,v in ipairs(list) do
    print(f(v[1],v[2]))
end