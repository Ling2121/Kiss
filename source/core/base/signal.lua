return function()
    local signal = {
        _connects = {}
    }

    function signal:connect(name,fn)
        self._connects[name] = fn
    end

    function signal:disconnect(name)
        self._connects[name] = nil
    end

    function signal:emit(...)
        for name,fn in pairs(self._connects) do
            fn(...)
        end
    end

    return signal
end