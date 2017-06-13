//
//  ViewController.swift
//  BlueToothManDemo
//
//  Created by 梓简王 on 2017/6/12.
//  Copyright © 2017年 梓简王. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,blueToothTooldelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //初始化蓝牙模型
        let localBluetoothModel = blueToothModel()
        localBluetoothModel.perName = "MLT-BT05"
        localBluetoothModel.serviceUUID = CBUUID(string: "FFE0")
        localBluetoothModel.peripheralUUID = CBUUID(string: "FFE0")
        localBluetoothModel.notifyCharacteristicUUID = "FFE1"
        localBluetoothModel.messageHeaderFlag = "SB"
        localBluetoothModel.messageTailFlag = "{BS}"
        localBluetoothModel.bagLength = 20
        let localBluetoothMan = blueToothTool(blueToothPublicModel: localBluetoothModel)
        localBluetoothMan.startScanPer()
        localBluetoothMan.delegate = self
        //发送信号方法(传参第一位为需要写的字段，第二位为内容)
        localBluetoothMan.sendMessageToEq(localBluetoothModel.noticCha!, sendMess: "14100")
    }
    //MARK: - 获取到消息的通知回调
    func getEqNotify(notifyContent:String){
    }
    //MARK: - 写入状态判别回调
    func getInsertResult(result:Bool){
    }
    //MARK: - 链接超时提示回调
    func outTimeSignal(){
    }
    //MARK: - 链接服务成功状态回调
    func connectServiceSuccess(){
    }
    //MARK: - 蓝牙断开连接回调
    func blueToothDisconnect(){
    }
    //MARK: - 蓝牙关闭状态提示回调
    func blueToothPowerOffSingal(){
    }
    //MARK: - 蓝牙未授权App回调
    func blueToothUnauthorizedSingal(){
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

