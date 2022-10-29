local a = {
    arr = {1,2,3,4,5,6}
}

function a.iter(self,i)
    i = i + 1
    if i > #self.arr then return nil end
    return i,self.arr[i]
end

function a:items()
    return self.iter,self,-1
end

setmetatable(a,a)

-- 1,x = iter(self,0)
-- 2,x = iter(self,1)
-- 3,x = iter(self,2)
-- nil = iter(self,2)

for i,v in a:items() do
    print("xxx",i,v)
end