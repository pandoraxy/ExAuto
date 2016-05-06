//
//  EXBLECentralManager.swift
//  ExRemote
//
//  Created by wendy on 16/5/5.
//  Copyright © 2016年 AppStudio. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BLECentralDelegate: NSObjectProtocol{
//    func didDiscoverConnection(connection: BLEConnection)
//    func didConnectConnection(connection: BLEConnection)
}

class EXBLECentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    let characteristicUUIDString = "DABCAF22-9D34-4C8C-9EC6-D7DB80E89788"
    let seviceUUID = "3E4EA42A-AF5D-4D6A-8ABE-A29935B5EA8C"
    
    var manager:CBCentralManager!
    var serviceUUIDs : CBUUID!
    var characteristicsUUIDs : CBUUID!
    var data:NSMutableData!
    var peripheral : CBPeripheral!
    weak var delegate: BLECentralDelegate!
    
//    self.characteristicUUID = CBUUID(string:characteristicUUIDString)
//    self.serviceUUID = CBUUID(string: seviceUUID)
    
    init(delegate:BLECentralDelegate) {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        if self.manager.state == CBCentralManagerState.PoweredOn {
            self.manager.scanForPeripheralsWithServices([self.serviceUUIDs], options: nil)
        }
    }
    func stopScan() {
        self.manager.stopScan()
    }
    
    func connect() {
        
    }
    
    func disconnect() {
    
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state{
        case CBCentralManagerState.PoweredOn:
            self.manager.scanForPeripheralsWithServices([self.serviceUUIDs], options: nil)
            print("Bluetooth is currently powered on and available to use.")
        case CBCentralManagerState.PoweredOff:
            print("Bluetooth is currently powered off.")
        case CBCentralManagerState.Unauthorized:
            print("The app is not authorized to use Bluetooth low energy.")
        default:
            print("centralManagerDidUpdateState: \(central.state)")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("didDiscoverPeripheral");
        self.peripheral = peripheral
        self.peripheral.delegate = self;
        self.manager.connectPeripheral(peripheral, options: nil)
        self.manager.stopScan()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.peripheral.discoverServices([self.serviceUUIDs])
    }
    
    // MARK: CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            return
        }
        let services : NSArray = peripheral.services!
        for service in services as! [CBService] {
            if service.UUID.isEqual(self.serviceUUIDs) {
                self.peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
            return
        }
        let characteristics : NSArray = service.characteristics!
        for c in characteristics as! [CBCharacteristic] {
            if c.UUID.isEqual(self.characteristicsUUIDs) {
                self.peripheral.setNotifyValue(true, forCharacteristic: c);
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            return
        }
        let data = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
        print("data is \(data)");
    }
}




























