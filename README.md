## BluetoothMan(主模式开发)简介
从前有一个客户端开发人员，在蓝牙开发的时候遇到了很多的坑，所以那时候就下决心，开发完后要抽出方法，供大家借鉴与使用，于是BluetoothMan就这么出来了，过不了多久还有BluetoothMan的安卓版本


## BluetoothMan使用方法
直接将BluetoothMan文件夹拖至自己的项目，因为没有依赖，所以放心
> 回调函数简介

```
func getEqNotify(notifyContent:String) //获取到消息的通知回调
func getInsertResult(result:Bool) //写入状态判别回调
func outTimeSignal() //链接超时提示回调
func connectServiceSuccess() //链接服务成功状态回调
func blueToothDisconnect() //蓝牙断开连接回调
func blueToothPowerOffSingal() //蓝牙关闭状态提示回调
func blueToothUnauthorizedSingal() //蓝牙未授权App回调
```

> 类方法介绍

```
startScanPer() //蓝牙链接方法
stopScanPer() //强行停止蓝牙扫描方法
sendMessageToEq(targetCha:CBCharacteristic,var sendMess:String) //向指定字段写入的方法
readTargetCha(targetCha:CBCharacteristic)->String //读取指定字段内容的方法
```

> 模型字段介绍(注意必填字段)

```
//设备名字:(必填)
var perName:String?
//服务字段:(必填)
var serviceUUID:CBUUID?
//设备字段:(必填)
var peripheralUUID:CBUUID?
//扫描列表
var scanUUIDS:[CBUUID]?
//notify字段:(必填)
var notifyCharacteristicUUID:String?
//writeable/readable字段唯一标识符
var chaUUIDS:[CBUUID]?
//读取状态标识
var isWrite:Bool?
//切入状态标识
var isRead:Bool?
//分包长度:(必填)
var bagLength:Int?
//申请一个中心管理设备
var centerManager: CBCentralManager?
//申请链接的periphere
var connectPer:CBPeripheral?
//链接状态记录
var isConnect:Bool?
//申请写入的Character
var targetCha:[CBCharacteristic]?
//申请notice的Character:
var noticCha:CBCharacteristic?
//收到的数据集合
var receiveResult:String?
//报文开头标记:(必填)
var messageHeaderFlag:String?
//报文结尾标记:(必填)
var messageTailFlag:String?
```

## 后记
其实关于蓝牙开发大家切记，最难得并不是蓝牙操作本身，而是与硬件那一块交互的协议，就协议模块，以经验告诫大家，最好还是要设置报文开头标记与结尾标记

## 经验贴
关于蓝牙的开发经验，后续再添加，如下我的博客:
[王师傅的博客](http://blog.dpgeek.cn)