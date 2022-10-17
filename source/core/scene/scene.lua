--[独立模块]
--Scene:
--方法
--  addEntity(entity,name,depth) -> bool
--    添加实体到场景
--    entity : 要添加的实体，任意的table都行
--    name : 实体名称，省略则默认为实体的地址
--    depth : 深度,用于排序实体的绘制顺序和更新顺序，数值越小则越先更新以及绘制,
--            可以为数字类型以及函数类型,为数字类型时表示给予一个固定的深度,不可改变，
--            需要动态设置深度时需要传入一个函数:
--                  原型为: function(entity) -> number
--            entity为实体本身,number为这个函数的返回值,表示返回一个深度值,Scene会根据
--            每次返回的值对对象顺序进行更新.
--     返回值 : 添加成功则返回true否则为false 
--
--  removeEntity(entity) -> Entity
--      删除实体
--      entity : 要删除的实体,可以是实体本身也可以是实体的名称
--      返回值 : 返回删除的实体   
--
--  getEntity(name) -> Entity
--      获取实体
--      name ：实体名称
--      返回值 : 返回获得的实体,没有则返回nil
--
--  hasEntity(entity) -> bool
--      判断场景中是否存在实体
--      entity : 要判断的实体(可以为实体名称)
--      返回值 : 存在则返回true否则为false
--      
--  applyToLoveCallback() -> void
--      应用场景到love回调.
--      这会替换掉大部分的love回调函数为Scene的回调函数

--DSList--
--  Dynamic Depth Sort List  动态深度排序链表
--  会自动对节点的深度进行排序
--  注意：
--    它有Hash特性，每个item只会添加一次

--  结构
--              |   segment 1           |    segment2           |    segmentN
--    head <--> | node1<-->node2 | <--> | node3<-->node4 | <--> | node5<-->nodeN | <-->tail
local function newDDSListNode(item,depth_f)
    return {
        item = item,
        _depth = depth_f,
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

    list._remove = function(self,node)
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
        return self:_remove(node)
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
--DSList--

local regulatory_callbacks = require"source/core/scene/regulatory_callbacks"


--Scene--
return function(segment_size)
    local scene = {
        _entities = {},
        _list = newDDSList(segment_size or 200)
    }

    --生成回调函数
    for i,name in ipairs(regulatory_callbacks) do
        scene[name] = function(self,...)
            for entity in scene._list:iter() do
                if entity[name] ~= nil then
                    entity[name](entity,...)
                end
            end
        end
    end

    scene.applyToLoveCallback = function(self)
        for i,name in ipairs(regulatory_callbacks) do
            love[name] = function(...)
                self[name](self,...)
            end
        end
    end

    scene.load = function(args)end

    scene.ready = function(self)
        for node in scene._list:iterNodes() do
            if node.ready then
                node:ready()
            end
        end
    end

    scene.addEntity = function(self,entiy,name,depth)
        name = name or tostring(entiy)
        if self._entities[name] ~= nil then
            return
        end
        entiy.name = name
        self._entities[name] = entiy
        self._entities[entiy] = name
        self._list:add(entiy,depth)
    end

    scene.removeEntity= function(self,entity)
        local name = self._entities[entity]
        if name == nil then
            return
        end
        self._entities[entity] = nil
        self._entities[entity] = nil
        self._list:remove(entity)
    end

    scene.getEntity = function(self,name)
        return self._entities[name]
    end

    scene.hasEntity = function(self,entity)
        return self._entities[entity] ~= nil
    end

    scene.update = function(self,dt)
        local d
        for node in scene._list:iterNodes() do
            d = node:getDepth()
            if d ~= node.up_depth then
                node.up_depth = d
                scene._list:_remove(node)
                scene._list:_add(node)
            end
        end

        for item in scene._list:iter() do
            if item.update then
                item:update(dt)
            end
        end
    end

    return scene
end

--Scene--