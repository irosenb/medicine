//
//  ViewController.swift
//  Medicine
//
//  Created by Isaac Rosenberg on 9/9/14.
//  Copyright (c) 2014 Isaac Rosenberg. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate  {
    
    var manager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral!
    var opened: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        
//        var characteristic = CBMutableCharacteristic(type: CBUUID.UUIDWithString("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"), properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
//        var service = CBMutableService(type: CBUUID.UUIDWithString("6E400001-B5A3-F393-E0A9-E50E24DCCA9E"), primary: true)
//        service.characteristics = [characteristic]
//        var server = MYBluetoothBlocksServer.shared()
//
//        server.setupServer("hello", services: [service])
//        server.startPeripheral()
//
//        server.didReadyServer = { () in
//            println("Ready set go")
//        }
//        
//        server.didAddService = { (service: CBService!, error: NSError!) in
//            println("yay")
//            println(service)
//        }
//        
//        server.didReceiveData = { (request: CBATTRequest!, data: NSData!) in
//            println("Recieved Data")
//            var string = NSString(data: data, encoding: NSUTF8StringEncoding)
//            
//            println(string)
//        }
        
    }
    func buttonAction(sender:UIButton!) {
        println("I'm tapped")
    }
     
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if (central.state == CBCentralManagerState.PoweredOn) {
            println("I'm scanning")
            manager.scanForPeripheralsWithServices([CBUUID.UUIDWithString("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")], options: nil)
        }
        else {
            NSLog("bluetooth disabled")
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Discovered \(peripheral.name)");
        discoveredPeripheral = peripheral
        manager.connectPeripheral(peripheral, options: nil)
        println(RSSI)
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("failed to connect")
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected")
        
        manager.stopScan()
        println("Scan stopped")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services {
            peripheral.discoverCharacteristics([CBUUID.UUIDWithString("6E400003-B5A3-F393-E0A9-E50E24DCCA9E")], forService: service as CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
 
        for characteristic in service.characteristics {
            if characteristic.UUID == CBUUID.UUIDWithString("6E400003-B5A3-F393-E0A9-E50E24DCCA9E") {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
                println(characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        opened = characteristic.value
        println(opened)
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        if ((opened) == nil) {
            println("Disconnected")
            var notify = UILocalNotification()
            notify.fireDate = nil
            notify.alertBody = "You haven't taken your medicine!"
            notify.soundName = UILocalNotificationDefaultSoundName
            notify.applicationIconBadgeNumber = 1
            
            UIApplication.sharedApplication().scheduleLocalNotification(notify)
        }
        opened = nil
        centralManagerDidUpdateState(manager)
    }
    
//    func register
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

