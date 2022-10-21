# Base 基础类库

* IndexPool 索引池
* Signal 信号系统
* Utilities 工具函数



## IndexPool  索引池

用于分配独立的数字ID



**包含的方法**

``` lua
IndexPool:allocIndex() -> idx:int //分配ID
IndexPool:freeIndex(idx:int) -> void //释放分配的ID
```

