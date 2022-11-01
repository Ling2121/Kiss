local Sandbox = require"source/entity/sandbox/sandbox"

local sandbox = Sandbox()

function sandbox:load()
    print("【测试1 List】")
    print(" [插入测试]")
    local list = core.Containers.List()
    print(" >插入 100")
    list:add(100)
    print(" >插入 200")
    list:add(200)
    print(" >插入 300")
    list:add(300)
    print(" >插入 400")
    list:add(400)
    print(" >插入完毕")
    local list_insert_expect = {
        100,
        200,
        300,
        400,
    }
    local list_expect_len = 4
    local list_practical_len = 0
    print(" >迭代测试")
    for i,v in ipairs(list) do
        print(string.format(">  index : %d  value : %d   是否正确:%s",i,v,list_insert_expect[i] == v))
        list_practical_len = list_practical_len + 1
    end
    print(string.format(">迭代预期长度 %d  实际长度 %d 是否正确:%s",list_expect_len,list_practical_len,list_expect_len == list_practical_len))
    
    print(" [删除测试]")
    print(" >删除 1")
    list:remove(1)
    print(string.format(">预期长度 3  实际长度 %d 是否正确:%s",#list,#list == 3))
    list_insert_expect = {
        200,
        300,
        400,
    }
    print(" >迭代测试")
    for i,v in ipairs(list) do
        print(string.format(">  index : %d  value : %d   是否正确:%s",i,v,list_insert_expect[i] == v))
    end

    print(" >删除 1")
    list:remove(1)
    print(string.format(">预期长度 2  实际长度 %d 是否正确:%s",#list,#list == 2))
    list_insert_expect = {
        300,
        400,
    }
    print(" >迭代测试")
    for i,v in ipairs(list) do
        print(string.format(">  index : %d  value : %d   是否正确:%s",i,v,list_insert_expect[i] == v))
    end


    print(" [插入测试]")
    print(" >插入 1 到 1")
    list:insert(1,100)
    list_insert_expect = {
        100,
        300,
        400,
    }
    print(string.format(">预期长度 3  实际长度 %d 是否正确:%s",#list,#list == 3))
    print(" >迭代测试")
    for i,v in ipairs(list) do
        print(string.format(">  index : %d  value : %d   是否正确:%s",i,v,list_insert_expect[i] == v))
    end
    
    
    print("List 测试完毕 \n")

    local dict = core.Containers.Dictionary({x = 100})
    dict.y = 300

    dict.x = nil
    dict.x = 400
    dict.y = nil
    dict.x = nil

    print(#dict)

    for k,v in pairs(dict) do
        print(k,v)
    end
    
end

return sandbox