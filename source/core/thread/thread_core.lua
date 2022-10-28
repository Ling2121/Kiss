--[[
    type : 
        'task' : 任务，表示执行完成线程立即退出
        'loop' ：循环，表示线程的退出由线程自己决定
--]]
return function(name,type,f)
    if type == 'task' then
        return function()
            local ret = f() or 0
            love.thread.getChannel("task_return"):push({})
        end
    end

    if type == 'loop' then
        return function()
            local thread_control = love.thread.getChannel("thread_control")
            print("[info] 线程 %s 启动":format(name))
            while true do 
                local command = thread_control:peek()
                if command == -1 then
                    break
                end

                if f() then break end
            end
            print("[info] 线程 %s 关闭":format(name))
        end
    end
end