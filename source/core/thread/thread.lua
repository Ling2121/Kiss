--[[
    多线程模块

    组成
    Thread 主模块用于创建和管理线程
    ThreadCore 线程的核心

    使用多线程时需要非常小心，如果控制不好不要使用,非常危险！
]]

local ThreadCore = require"source/core/thread/thread_core"


local THREAD_EXIT_CODE = -1

return function()
    local self = {
        threads = {},
        channels = {},
        
        task_return_queue = {},
    }

    function self:createThread(type,name,f,exit_f)
        if self.thread[name] ~= nil then return end

        f = ThreadCore(type,f);

        local thread = love.thread.newThread(string.dump(f))
        self.threads[name] = {thread,exit_f}
    end

    function self:createChannel(name)
        local channel = love.thread.getChannel(name)

        if self.channels[name] == nil then
            self.channels[name] = channel 
        end

        return channel
    end

    function self:getChannel(name)
        return self.channels[name]
    end

    function self:channelPush(name,data)
        local channel = self.channels[name]
        if not channel then return end
        channel:push(data)
    end

    function self:channelPop(name,data)
        local channel = self.channels[name]
        if not channel then return -1 end
        return channel:pop()
    end

    function self:update()
        for i,thread in pairs(self.threads) do
            --释放结束运行的线程
            if not thread:isRunning() then
                -- self.threads[i] = nil
                -- thread:release()
            end
        end
    end

    function self:quit()
        for i,thread in pairs(self.threads) do
            --传输结束码并等待线程执行结束
            self:channelPush("thread_control",THREAD_EXIT_CODE)
            thread:wait()
        end
    end

    function self:startThread(name,...)
        local thread_item = self.threads[name]
        if thread_item ~= nil then
            local name = 
        end
    end


    self:createChannel("thread_control")
    self:createChannel("task_return")
    
    return self
end