//
//  EXBLEPeripheralManager.swift
//  ExRemote
//
//  Created by wendy on 16/4/22.
//  Copyright © 2016年 AppStudio. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol CBPeripheralServerDelegate:NSObjectProtocol{
    
    func peripheralServer(peripheral:EXBLEPeripheralManager, centralDidSubscribe central:CBCentral)
    func peripheralServer(peripheral:EXBLEPeripheralManager, centralDidUnsubscribe central:CBCentral)
    
}

class EXBLEPeripheralManager: NSObject,CBPeripheralManagerDelegate {
//    private var peripheralManager:CBPeripheralManager!
//    private var transferCharacteristic:CBMutableCharacteristic!
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
    
//    var serviceName:NSString
//    var serviceUUIDs:CBUUID
//    var characteristicUUIDs:CBUUID
    
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
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
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
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if (error != nil) {
            errorString = error?.localizedDescription
        }
        self.startAdvertisingING()
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        
        if (error != nil) {
            errorString = error?.localizedDescription
            print("startAdvertising \(errorString)")
        }
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        self.delegate?.peripheralServer(self, centralDidSubscribe: central)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        self.delegate?.peripheralServer(self, centralDidUnsubscribe: central)
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        if (self.pendingData != nil) {
            let data = self.pendingData.copy();
            self.pendingData = nil
            self.sendToSubcribers(data as! NSData)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        
    }
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
    }

}








