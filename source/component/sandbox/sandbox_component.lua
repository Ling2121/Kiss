--[[
    sandbox
        L sandbox_component
            L region ...
]]
return core.ComponentConstructor("SandboxComponent",{
    make = function (_,self)
        self.regions = {} 
        function self:addRegion(region,x,y)
            if self.regions[y] == nil then
                self.regions[y] = {}
            end
            self.regions[y][x] = region
        end

        function self:getRegion(x,y)
            if self.regions[y] == nil then
                self.regions[y] = {}
            end
            return self.regions[y][x]
        end
    end
})