//
//  blueToothTool.swift
//  智慧魔盒
//
//  Created by 梓简王 on 2017/4/3.
//  Copyright © 2017年 DW. All rights reserved.
//

import Foundation
import CoreBluetooth

enum MyError: ErrorType {
    case NotExist
    case OutOfRange
}

protocol blueToothTooldelegate {
    func getEqNotify(notifyContent:String) //获取到消息的通知回调
    func getInsertResult(result:Bool) //写入状态判别回调
    func outTimeSignal() //链接超时提示回调
    func connectServiceSuccess() //链接服务成功状态回调
    func blueToothDisconnect() //蓝牙断开连接回调
    func blueToothPowerOffSingal() //蓝牙关闭状态提示回调
    func blueToothUnauthorizedSingal() //蓝牙未授权App回调
}

class blueToothTool:NSObject,CBCentralManagerDelegate,CBPeripheralDelegate {
    var delegate:blueToothTooldelegate?
    //蓝牙模型
    var blueToothMan:blueToothModel?
    //服务和特征的UUID
    var readValue:String?
    var writeValue:NSData?
    var checkStep:Bool = true
    var timer:NSTimer?
    
    required override init() {
        super.init()
    }
    //MARK: - 构造器
    init(blueToothPublicModel:blueToothModel) {
        super.init()
        self.blueToothMan = blueToothPublicModel
        if(blueToothPublicModel.centerManager == nil){
            blueToothPublicModel.centerManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    //蓝牙模块
    //MARK: - 启动蓝牙
    func startScanPer(){
        //如果存在链接，首先中断链接
        if blueToothMan!.centerManager != nil && blueToothMan!.connectPer != nil{
            blueToothMan!.centerManager!.cancelPeripheralConnection(blueToothMan!.connectPer!)
        }
        //设置链接超时为10s
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("CheckTiemOut"), userInfo: nil, repeats: false)
        //按照列表进行扫描
        blueToothMan!.centerManager!.scanForPeripheralsWithServices(nil, options: nil)
    }
    //MARK: - 关闭蓝牙方法
    func stopScanPer(){
        self.timer?.invalidate()
        blueToothMan!.centerManager?.stopScan()
    }
    //MARK: - 扫描信号，检查这个设备是不是支持BLE，代理方法
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state{
        case CBCentralManagerState.PoweredOn:
            break
        case  CBCentralManagerState.Unauthorized:
            blueToothMan!.isConnect = false
            self.delegate?.blueToothUnauthorizedSingal()
        case CBCentralManagerState.PoweredOff:
            blueToothMan!.isConnect = false
            self.delegate?.blueToothPowerOffSingal()
            break
        default:
            break
        }
    }
    //MARK: - 负责发现外设并连接
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if(blueToothMan!.perName == nil){
            print("please init perName in your blueToothModel!")
            return
        }
        if (peripheral.name == blueToothMan!.perName){
            blueToothMan!.connectPer = peripheral
            blueToothMan!.centerManager?.connectPeripheral(peripheral, options: nil)
            blueToothMan!.centerManager?.stopScan() //获取到匹配的设备后关闭扫描
        }
    }
    //MARK: - 连接外设成功的的回调方法
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("与指定服务连接成功")
        delegate?.connectServiceSuccess()
        self.timer?.invalidate()
        //外设连接成功则搜索对应服务
        if(blueToothMan!.serviceUUID == nil){
            print("please init serviceUUID in your blueToothModel!")
        }
        blueToothMan!.connectPer?.discoverServices([blueToothMan!.serviceUUID!])
        peripheral.delegate = self
    }
    //MARK: - 连接外设失败的函数
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("与指定链接连接失败")
    }
    //MARK: - 断开连接的回调
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        delegate?.blueToothDisconnect()
        blueToothMan!.isConnect = false
        print("与已连接的设备断开连接")
    }
    //MARK: -发现服务的回调
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for services in peripheral.services! {
            print("发现了\(services)")
            if (services.UUID == blueToothMan!.serviceUUID){
                print("发现正确的服务")
                let tempService = services as CBService
                blueToothMan?.connectSer = tempService
                peripheral.discoverCharacteristics(nil, forService: tempService)
            }
        }
    }
    //MARK: -发现字段的回调
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        //3.类型（1） 4.查询package数量（1）5.ID长度
        for characteristic in service.characteristics!{
            if(characteristic.UUID == blueToothMan!.notifyCharacteristicUUID){
                blueToothMan!.noticCha = characteristic
                //此时确定蓝牙链接成功
                blueToothMan!.isConnect = true
            }
            if((blueToothMan!.chaUUIDS?.contains(characteristic.UUID)) != nil){
                blueToothMan!.targetCha![(blueToothMan!.chaUUIDS?.indexOf(characteristic.UUID))!] = characteristic
            }
            
        }
        //设置监听对象
        if blueToothMan!.noticCha != nil{
            //发现监听事件
            blueToothMan!.connectPer!.setNotifyValue(true, forCharacteristic: blueToothMan!.noticCha!)
        }
    }
    //MARK: -notice的回调
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil){
            print(error)
            print("读取发生错误")
        }else{
            let backData = characteristic.value
            let tailLength = blueToothMan?.messageTailFlag?.characters.count
            let headerLength = blueToothMan?.messageHeaderFlag?.characters.count
            if(backData != nil){
                var notifyString:NSString = ""
                do {
                    notifyString = try(blueToothTool.UInt8ToString(backData!)) as NSString
                }catch{
                    print("解析发生错误，一般是蓝牙接收到脏数据")
                }
                if(notifyString.length >= 0){
                    blueToothMan!.receiveResult = blueToothMan!.receiveResult! + (notifyString as String)
                }
                if(notifyString.length >= 4){
                    //写入通知内容
                    if(notifyString.substringWithRange(NSMakeRange(0, headerLength!)) == blueToothMan!.messageHeaderFlag!){
                        blueToothMan!.receiveResult = notifyString as String
                        blueToothMan!.isRead = true;
                    }
                }
                var notifyContent = ""
                let tailNotifyStr = (blueToothMan!.receiveResult! as! NSString).substringWithRange(NSMakeRange(blueToothMan!.receiveResult!.characters.count - tailLength!, tailLength!))
                if (tailNotifyStr == blueToothMan!.messageTailFlag){
                    blueToothMan!.isRead = false;
                    let tempNSString:NSString = (blueToothMan!.receiveResult! as! NSString)
                    if(tempNSString.length > tailLength! + headerLength!){
                        notifyContent = tempNSString.substringWithRange(NSMakeRange(headerLength!, tempNSString.length - (tailLength! + headerLength!)))
                        print("blueToothModel.receiveResult 的内容是" + blueToothMan!.receiveResult!)
                    }
                    //获取notify数据
                    self.delegate?.getEqNotify(notifyContent)
                }
            }else{
                print("接收到空字符")
            }
        }
    }
    //MARK: - 检测是否连接超时
    func CheckTiemOut(){
        print("扫描超时，未找到指定设备")
        blueToothMan!.centerManager?.stopScan()
        blueToothMan!.isConnect = false
        self.delegate?.outTimeSignal()
    }
    //MARK: - 写入结果判断
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil){
            delegate?.getInsertResult(false)
            print("写入发生错误")
            print(error)
        }else{
            delegate?.getInsertResult(true)
            print("写入成功")
        }
    }
    //MARK: - 写入方法，支持长报文
    func sendMessageToEq(targetCha:CBCharacteristic,var sendMess:String){
        sendMess = (self.blueToothMan?.messageHeaderFlag)! + sendMess + (self.blueToothMan?.messageTailFlag)!
        print("向设备端写入\(sendMess)")
        var contentArr:NSMutableArray = []
        while(sendMess.characters.count >= blueToothMan!.bagLength){
            contentArr.addObject((sendMess as! NSString).substringWithRange(NSMakeRange(0,blueToothMan!.bagLength!)))
            sendMess = (sendMess as NSString).substringFromIndex(blueToothMan!.bagLength!)
        }
        if(sendMess != ""){
            contentArr.addObject(sendMess)
        }
        blueToothMan!.isWrite = true;
        for item in contentArr {
            print("正在写入\(item)")
            if ("\(item)" != "\(contentArr.lastObject!)"){
                blueToothMan!.connectPer!.writeValue(item.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: targetCha, type: CBCharacteristicWriteType.WithoutResponse)
            }else{
                blueToothMan!.connectPer!.writeValue(item.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: targetCha, type: CBCharacteristicWriteType.WithResponse)
            }
            
        }
        blueToothMan!.isWrite = false;
    }
    func readTargetCha(targetCha:CBCharacteristic)->String{
        let readValue = targetCha.value
        var readValue2String:String = ""
        do {
            readValue2String = try(blueToothTool.UInt8ToString(readValue!))
        }catch{
            print("解析发生错误")
        }
        return readValue2String
    }
    //MARK: - 对传输过去的报文进行处理
    static func handleTransData(handelString:String) -> [UInt8]{
        var tempACKByteData:[UInt8] = []
        let value = UInt8((handelString as NSString).intValue)
        tempACKByteData.append(value)
        return tempACKByteData
    }
    static func UInt8ToString(backData:NSData)throws ->String{
        var backString = ""
        var backIntArr = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(backData.bytes), count: backData.length))
        for i in backIntArr {
            var str = String(bytes: [i], encoding: NSUTF8StringEncoding)
            guard str != nil else {
                throw MyError.NotExist
            }
            backString += str!
        }
        return backString
    }
}