local function newDDSListNode(item,depth_f)
    return {
        item = item,
        _depth = depth_f,
        _up_depth = math.huge,
        _up = nil,
        _next = nil,
        getDepth = function(self)
            if type(self._depth) == "function" then
                return self._depth(self.item)
            end
            return self.depth or 0
        end,
    }
end

local function newDDSList(segment_size)
    local list = {
        _head = nil,
        _size = 0,
        _segment_size = segment_size,
        _items = {},
        _segments = {},
    }

    list.getSegmentIndex = function(self,depth)
        return math.floor(depth / self._segment_size)
    end

    list.getSegmentHead = function(self,depth)
        local seg_idx = math.floor(depth / self._segment_size)
        return self._segments[seg_idx],seg_idx
    end

    list.clear = function(self)
        self._head = nil
        self._size = 0
        self._segments = {}
        self._items = {}
    end

    list._add = function(self,node)
        depth = node:getDepth()
        
        self._size = self._size + 1
        
        if self._head == nil then
            self._head = node
            self._segments[self:getSegmentIndex(depth)] = node
            return node
        end

        local seg,segi = self:getSegmentHead(depth)
        if seg == nil then
            seg = self._head
            self._segments[segi] = node
        end

        --0  1 2 3 

        local fnode = seg
        local up = fnode
        
        while fnode ~= nil and fnode:getDepth() > depth do
            up = fnode
            fnode = fnode._next
        end
        if fnode ~= nil then
            --找到时在前面插入
            local up = fnode._up
            local next = fnode
            if up ~= nil then
                up._next = node
            else
                self._head = node
            end
            node._up = up
            node._next = next
            next._up = node

            if fnode == seg then
                self._segments[segi] = node
            end
        else
            --要不就在末尾插入
            up._next = node
            node._up = up
            node._next = nil
        end

        return node
    end

    list.add = function(self,item,depth_f)
        if self._items[item] ~= nil then
            return
        end
        local node = newDDSListNode(item,depth_f)
        self._items[item] = node
        return item,self:_add(node)
    end

    list._remove = function(self,item)
        local node = self._items[item]

        self._size = self._size - 1

        local node_up = node._up
        local node_next = node._next

        if node_up ~= nil then
            node_up._next = node_next
        else
            self._head = node_next
        end

        if node_next ~= nil then
            node_next._up = node_up
        end

        local seg,segi = self:getSegmentHead(node:getDepth())
        if node == seg then
            if node_next ~= nil then
                if self:getSegmentIndex(node_next:getDepth()) == segi then
                    self._segments[segi] = node_next
                else
                    self._segments[segi] = nil
                end
            else
                self._segments[segi] = nil
            end
        end

        node._up = nil
        node._next = nil

        return node
    end

    list.remove = function(self,item)
        local node = self._items[item]
        if node == nil then return nil end
        self._items[item] = nil
        return self:_remove(item)
    end

    list.iter = function(self)
        local node = self._head
        return function()
            local rnode = node
            if node == nil then
                return nil
            end
            node = node._next
            return rnode.item
        end
    end

    list.iterNodes = function(self)
        local node = self._head
        return function()
            local rnode = node
            if node == nil then
                return nil
            end
            node = node._next
            return rnode
        end
    end

    return list
end

function addItem(vv)
    list:add({value = vv or v},function(item) return item.value end)
    if vv == nil then
        v = v + 1
    end
end

function testSortCorrect(list)
    local up_node = list._head
    local node = list._head._next
    while node ~= nil do
        if up_node:getDepth() >= node:getDepth() then
            up_node = node
            node = node._next
        else
            return false
        end
    end

    return true
end

local  socket = require"socket"

function calcTime(f,s,p)
    local t = socket.gettime()
    f()
    local et = (socket.gettime() - t) * 1000
    if p then
        print(s,"time : (ms)",et)
    end
    return et
end

math.randomseed(2333)

local gen = 10000
local items = {}


local list = newDDSList(math.floor(gen * 0.022))

print("段大小",list._segment_size)

local df = function(item) return item.value end

for i = 1,gen do
    local v = math.random(-32767,32767)
    table.insert(items,{value = v})
end

calcTime(function()
    for i,item in pairs(items) do
        list:add(item,df)
    end
end,string.format("插入速度(%s个/ms)",gen),true)

print('-------------------------是否顺序:',testSortCorrect(list))

calcTime(function()
    local i = 0
    for item in list:iter() do
        i = i + 1
    end
end,string.format("迭代速度(%s个)",gen),true)

print('-------------------------是否顺序:',testSortCorrect(list))

calcTime(function()
    local n = math.floor(gen * 0.4)
    local i = 0
    local rm = {}
    for item in list:iter() do
        if i >= n then
            break
        end
        table.insert(rm,list:_remove(item))
        i = i + 1
    end
    for i,node in ipairs(rm) do
        list:_add(node)
    end
end,string.format("动态插入速度(%s个)",gen),true)

print('-------------------------是否顺序:',testSortCorrect(list))

-- local up_segi = math.huge
-- for item in list:iter() do
--     --local segi = list:getSegmentIndex(item.value)
--     -- if segi ~= up_segi then
--     --     up_segi = segi
--     --     print("     "..tostring(segi));
--     -- end
--     print(item.value)
-- end