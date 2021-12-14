return function()
    local index_pool = {
        _index = 0,
        _pool = {},
    }

    function index_pool:allocIndex()
        local idx = self._index
        if #self._pool ~= 0 then
            idx = table.remove(self._pool)
            self._pool[idx] = nil
        else
            self._index = self._index + 1
        end
        return idx
    end

    function index_pool:freeIndex(idx)
        if self._pool[idx] == nil then
            self._pool[idx] = idx
            table.insert(self.._pool,idx)
        end
    end

    return index_pool
end