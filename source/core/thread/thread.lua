--[[
    多线程模块

    组成
    Thread 主模块用于创建和管理线程
    ThreadCore 线程的核心

    使用多线程时需要非常小心，如果控制不好不要使用,非常危险！
]]


local THREAD_EXIT_CODE = -1
local TASK_CONTROL_CREATE = 0
local TASK_CONTROL_REMOVE = 1

return function()
    local self = {
        tasks = {},
        threads = {},
        channels = {},
        task_return_queue = {},
    }

    -- function self:createThread(type,name,f)
    --     if self.thread[name] ~= nil then return end

    --     f = ThreadCore(type,f);

    --     local thread = love.thread.newThread(string.dump(f))
    --     self.threads[name] = thread
    -- end

    function self:createTask(name,f,ret_f,is_start,...)
        is_start = is_start or false

        local task = {
            name = name,
            func = string.dump(f),
            ret_func = ret_f,
        }
        
        function task.start(this,...)
            self:channelPush("task_control",{TASK_CONTROL_CREATE,this.name,this.func,{...}})
        end

        self.tasks[name] = task

        if is_start then
            self:startTask(name,...)
        end
    end

    function self:removeTask(name)
        self:channelPush("task_control",{TASK_CONTROL_REMOVE,name})
    end

    local thread_func = function(f)
        --为什么要有个print？
        --因为需要用到love.thread.newThread(codestring)重载方法创建线程
        --这个玩意最草蛋的是用\n来区分重载
        --判断输入的字符串没有\n时则用love.thread.newThread(filename)方式来加载
        print("")

        local loop = load(f)()
        local control = love.thread.getChannel("thread_control")
        while true do
            local control_code = control:peek()
            if control_code == -1 then
                break
            end
            loop()
        end
    end

    function self:createThread(name,f,is_start,...)
        is_start = is_start or false

        local thread = love.thread.newThread(string.dump(thread_func,true))

        self.threads[name] = {thread,string.dump(f)}

        if is_start then
            self:startThread(name,...)
        end
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

    function self:channelPop(name)
        local channel = self.channels[name]
        if not channel then return -1 end
        return channel:pop()
    end

    function self:update()
        for i,thread in pairs(self.threads) do
            --释放结束运行的线程
            if not thread[1]:isRunning() then
                self.threads[i] = nil
            end
        end
        local task_ret = love.thread.getChannel("task_return"):pop()
        if task_ret ~= nil then
            local name = task_ret[1]
            local task = self.tasks[name]
            if task ~= nil and task.ret_func ~= nil then
                task.ret_func(task_ret[2])
            end
        end
    end

    function self:quit()
        for i,thread in pairs(self.threads) do
            --传输结束码并等待线程执行结束
            self:channelPush("thread_control",THREAD_EXIT_CODE)
            thread[1]:wait()
        end
    end

    function self:startTask(name,...)
        local task = self.tasks[name]
        if task ~= nil then
            task:start(...)
        end
    end

    function self:startThread(name,...)
        local thread_item = self.threads[name]
        if thread_item ~= nil then
            thread_item[1]:start(thread_item[2],...)
        end
    end

    self:createChannel("thread_control")

    self:createChannel("task_control")
    self:createChannel("task_return")

    self:createThread("task_thread",function()
        local task_control = love.thread.getChannel("task_control")
        local task_return = love.thread.getChannel("task_return")
        local tasks = {}
        local removes = {}

        return function()
            while true do
                local command = task_control:pop()
                if command == nil then break end
                local code = command[1]
                if code == 0 then
                    local name = command[2]
                    local func = load(command[3])
                    local args = command[4]
                    table.insert(tasks,{name,func,args})
                end
            end

            for i,item in ipairs(tasks) do
                local name = item[1]
                local task = item[2]
                local ret =  task(item[3])
                task_return:push({name,ret})
            end

            tasks = {}
        end
    end)

    self:startThread("task_thread")
    
    return self
end