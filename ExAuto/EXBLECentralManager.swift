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
    func didUpdataValue(Central:EXBLECentralManager,value:NSString)
    func getConnetStateString(errorString:connectState) -> connectState
}

class EXBLECentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let characteristicUUIDString = "DABCAF22-9D34-4C8C-9EC6-D7DB80E89788"
    let seviceUUID = "3E4EA42A-AF5D-4D6A-8ABE-A29935B5EA8C"
    
    var manager:CBCentralManager!
    var serviceUUIDs : CBUUID!
    var characteristicsUUIDs : CBUUID!
    var data:NSMutableData!
    var peripheral : CBPeripheral!
    var errorString:connectState!
    weak var delegate: BLECentralDelegate!
    
    init(delegate:BLECentralDelegate) {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //MARK:扫描
    func startScan() {
        if self.manager.state == CBCentralManagerState.PoweredOn {
            self.manager.scanForPeripheralsWithServices([self.serviceUUIDs], options: nil)
        }
    }
    func stopScan() {
        self.manager.stopScan()
    }
    
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        switch central.state{
        case CBCentralManagerState.PoweredOn:
            self.characteristicsUUIDs = CBUUID(string:characteristicUUIDString)
            self.serviceUUIDs = CBUUID(string: seviceUUID)
            self.manager.scanForPeripheralsWithServices([self.serviceUUIDs], options: nil)
            self.errorString = connectState.poweredOn
            print("Bluetooth is currently powered on and available to use.")
        case CBCentralManagerState.PoweredOff:
            self.errorString = connectState.poweredOff
            print("Bluetooth is currently powered off.")
        case CBCentralManagerState.Unauthorized:
            self.errorString = connectState.unauthorized
            print("The app is not authorized to use Bluetooth low energy.")
        default:
            print("centralManagerDidUpdateState: \(central.state)")
        }
        self.delegate?.getConnetStateString(errorString)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("didDiscoverPeripheral");
        self.errorString = connectState.connecting
        self.delegate?.getConnetStateString(errorString)
        self.peripheral = peripheral
        self.peripheral.delegate = self;
        self.manager.connectPeripheral(peripheral, options: nil)
        self.manager.stopScan()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.errorString = connectState.connected
        self.delegate?.getConnetStateString(errorString)
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
        self.delegate?.didUpdataValue(self, value: data!)
    }
    
    //MARK:连接  后期实现，找到多个设备以后选择连接
    func connect() {
        
    }
    
    func disconnect() {
        
    }
}




























