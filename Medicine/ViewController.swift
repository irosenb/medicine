//
//  ViewController.swift
//  Medicine
//
//  Created by Isaac Rosenberg on 9/9/14.
//  Copyright (c) 2014 Isaac Rosenberg. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral!
    var opened: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
//        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
//        button.frame = CGRectMake(100, 100, 100, 50)
//        button.setTitle("meds", forState: UIControlState.Normal)
//        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
//        
//        
//        
//        
//        self.view.addSubview(button)
        // Do any additional setup after loading the view, typically from a nib.
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

