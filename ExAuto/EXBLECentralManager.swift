//
//  EXBLECentralManager.swift
//  ExRemote
//
//  Created by wendy on 16/5/5.
//  Copyright © 2016年 AppStudio. All rights reserved.
//

import UIKit
import CoreBluetooth

public protocol BLECentralDelegate: NSObjectProtocol{
    //    func didDiscoverConnection(connection: BLEConnection)
    //    func didConnectConnection(connection: BLEConnection)
    //Mark:CC中实现
    func didUpdataValue(Central:EXBLECentralManager,value:NSString)
    func getConnetStateString(errorString:connectState) -> connectState
}

public class EXBLECentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
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
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        
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
    
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("didDiscoverPeripheral");
        self.errorString = connectState.connecting
        self.delegate?.getConnetStateString(errorString)
        self.peripheral = peripheral
        self.peripheral.delegate = self;
        self.manager.connectPeripheral(peripheral, options: nil)
        self.manager.stopScan()
    }
    
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.errorString = connectState.connected
        self.delegate?.getConnetStateString(errorString)
        self.peripheral.discoverServices([self.serviceUUIDs])
    }
    
    // MARK: CBPeripheralDelegate
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
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
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
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
    
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
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

public protocol CBPeripheralServerDelegate:NSObjectProtocol{
    
    //Mark:暂时用不到 用于中心给外设传值
    func peripheralServer(peripheral:EXBLEPeripheralManager, centralDidSubscribe central:CBCentral)
    func peripheralServer(peripheral:EXBLEPeripheralManager, centralDidUnsubscribe central:CBCentral)
    
}

public class EXBLEPeripheralManager: NSObject,CBPeripheralManagerDelegate {
    
    let characteristicUUIDString = "DABCAF22-9D34-4C8C-9EC6-D7DB80E89788"
    let seviceUUID = "3E4EA42A-AF5D-4D6A-8ABE-A29935B5EA8C"
    var errorString:NSString!
    var connection:NSString!
    var serviceName:NSString!
    var pendingData:NSData!
    
    var serviceUUID : CBUUID!
    var characteristicUUID : CBUUID!
    
    var manager : CBPeripheralManager!
    var service : CBMutableService!
    var characteristic : CBMutableCharacteristic!
    var data : NSData!
    
    weak var delegate:CBPeripheralServerDelegate?
    
    //super override
    override init() {
        super.init()
        self.manager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    init(delegate: CBPeripheralManagerDelegate?,queue:dispatch_queue_t?,options:[String : AnyObject]?) {
        super.init()
        self.manager = CBPeripheralManager(delegate: delegate, queue: queue, options: options)
    }
    
    func sendToSubcribers(data:NSData){
        if self.manager.state == CBPeripheralManagerState.PoweredOn{
            let isSuccess = self.manager.updateValue(data, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
            if !isSuccess {
                self.pendingData = data;
            }
        }
    }
    
    //  MARK:广播
    func startAdvertisingING(){
        if self.manager.isAdvertising {
            self.manager.stopAdvertising()
        }
        self.manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [self.service.UUID]])
    }
    
    func stopAdvertising() {
        self.manager.stopAdvertising()
    }
    
    func isAdvertising() -> Bool {
        return self.manager.isAdvertising
    }
    
    
    //  MARK:peripheralManageDelegate
    public func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state != CBPeripheralManagerState.PoweredOn {
            return
        }
        self.characteristicUUID = CBUUID(string:characteristicUUIDString)
        self.serviceUUID = CBUUID(string: seviceUUID)
        
        self.characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
        self.service = CBMutableService(type: self.serviceUUID, primary:true)
        self.service.characteristics = [self.characteristic!]
        
        self.manager.addService(self.service)
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if (error != nil) {
            errorString = error?.localizedDescription
        }
        self.startAdvertisingING()
    }
    
    public func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if (error != nil) {
            errorString = error?.localizedDescription
            print("startAdvertising \(errorString)")
        }
    }
    public func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        self.delegate?.peripheralServer(self, centralDidSubscribe: central)
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        self.delegate?.peripheralServer(self, centralDidUnsubscribe: central)
    }
    
    public func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        if (self.pendingData != nil) {
            let data = self.pendingData.copy();
            self.pendingData = nil
            self.sendToSubcribers(data as! NSData)
        }
    }
    
    //MARK:后期实现
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        
    }
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
    }
    
}

public enum RemoteEnum:NSInteger {
    case up = 200//上
    case left//左
    case down//下
    case right//右
    case enter//确认
    case plus//音量增大
    case dec//音量减小
    case voice//语音
    case menu//菜单
    case back//返回
}

public enum connectState:NSString{
    case scan
    case connecting;
    case connected;
    case poweredOn
    case poweredOff
    case unauthorized
}






























