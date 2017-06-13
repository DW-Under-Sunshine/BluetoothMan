//
//  blueToothModel.swift
//  智慧魔盒
//
//  Created by 梓简王 on 2017/4/4.
//  Copyright © 2017年 DW. All rights reserved.
//

import Foundation
import CoreBluetooth

class blueToothModel {
    //设备名字:(必填)
    var perName:String?
    //服务字段:(必填)
    var serviceUUID:CBUUID?
    //设备字段:(必填)
    var peripheralUUID:CBUUID?
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
    //申请链接的服务
    var connectSer:CBService?
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
    
    required init(){
        perName = nil
        serviceUUID = nil
        peripheralUUID = nil
        scanUUIDS = []
        notifyCharacteristicUUID = ""
        chaUUIDS = []
        isWrite = false
        isRead = false
        bagLength = 20
        centerManager = nil
        connectPer = nil
        isConnect = false
        targetCha = nil
        noticCha = nil
        connectSer = nil
        receiveResult = ""
        messageHeaderFlag = ""
        messageTailFlag = ""
    }
}