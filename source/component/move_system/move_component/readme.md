# 移动系统

## 相关组件

MoveComponent 移动组价

CollisionBodyMoveComponent 碰撞体移动组件

MoveClearComponent 移动清除组件



## 继承结构

MoveComponent

​        L CollisionBodyMoveComponent

MoveClearComponent



## 组件介绍

### MoveComponent 

​	基础的移动组件有vx和vy两个量，这两个量表示移动的方向

### CollisionBodyMoveComponent

​	带碰撞的移动组件，继承自MoveComponent ，用于碰撞体的移动，当碰撞到对象时会发出_Collision(collisions)信号

### MoveClearComponent

​	移动清除组件，一般放在最底部（移动组件的vx和vy只要有值就会一直计算，需要清零才能停止）。

