//
//  CommunicationHandler.m
//  CBDataTransferApp
//
//  Created by Krishna Shanbhag on 09/11/16.
//  Copyright © 2016 WireCamp Interactive. All rights reserved.
//

#import "CommunicationHandler.h"

@interface CommunicationHandler ()

@property (nonatomic, strong) NSMutableArray *deviceListArray;
@property (strong, nonatomic) NSMutableData  *data;
@property (strong, nonatomic) NSString       *passwordString;

@end


@implementation CommunicationHandler

+ (id)sharedInstance {
    
    static CommunicationHandler *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[CommunicationHandler alloc] init];
        
    });
    
    return manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.deviceListArray = [NSMutableArray new];
        
        CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.centralManager = centralManager;

    }
    return self;
}
- (void) startScan {
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:service_uid]]
                                                options:nil];
    
    NSLog(@"Scanning started");
}
- (void) stopScan {
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
}
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (self.polarH7HRMPeripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.polarH7HRMPeripheral.services != nil) {
        for (CBService *service in self.polarH7HRMPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristic_uid]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.polarH7HRMPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.polarH7HRMPeripheral];
}
// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBManagerStatePoweredOn) {
        
        [self startScan];
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        
    }
    else if ([central state] == CBManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}
// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:characteristic_uid]] forService:service];
    }
}
// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (![localName isEqual:@""]) {
        // We found the Heart Rate Monitor
        if (self.deviceListArray == nil) {
            self.deviceListArray = [NSMutableArray new];
        }
        [self.deviceListArray addObject:peripheral];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateDataSource:)]) {
        [self.delegate performSelector:@selector(updateDataSource:) withObject:self.deviceListArray];
    }
    //send details to view controller
}
- (void) connectDevice:(CBPeripheral *)device withPassword:(NSString *)password {
    
    [self stopScan];
    self.polarH7HRMPeripheral = device;
    device.delegate = self;
    [self.centralManager connectPeripheral:device options:nil];
    self.passwordString = password;

}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:service_uid]]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(btCentralManager:didConnectPeripheral:)]) {
        [self.delegate performSelector:@selector(btCentralManager:didConnectPeripheral:) withObject:central withObject:peripheral];
    }

    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    if (self.delegate && [self.delegate respondsToSelector:@selector(btdidFailToConnectPeripheral:error:)]) {
        [self.delegate performSelector:@selector(btdidFailToConnectPeripheral:error:) withObject:peripheral withObject:error];
    }

    [self cleanup];
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristic_uid]]) {
            
            // If it is, subscribe to it
            
            NSString *str = [NSString stringWithFormat:@"SWD+%@\n",self.passwordString];
            NSData *data = [NSData dataWithBytes:str.UTF8String length:str.length];;
            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            if(characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
                [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            else
                [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            
            
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"written %@",stringFromData);
    if (self.delegate && [self.delegate respondsToSelector:@selector(btDidWriteValueForCharacteristic:error:)]) {
        [self.delegate performSelector:@selector(btDidWriteValueForCharacteristic:error:) withObject:characteristic withObject:error];
    }
}
- (void) writeValueForCharacteristicWithString:(NSString *)string {
    
    if (self.polarH7HRMPeripheral != nil) {
        if (self.polarH7HRMPeripheral.services != nil) {
            for (CBService *service in self.polarH7HRMPeripheral.services) {
                if (service.characteristics != nil) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristic_uid]]) {
                            
                            NSString *str = [NSString stringWithFormat:@"SWD+%@\n",string];
                            NSLog(@"trying for : %@",str);
                            NSData *data = [NSData dataWithBytes:str.UTF8String length:str.length];;
                            
                            [self.polarH7HRMPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                            
                            if(characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
                                [self.polarH7HRMPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                            else
                                [self.polarH7HRMPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                            
                        }
                    }
                }
            }
        }
    }
    else {
        //move to root view controller and start scanning.
    }
}
// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        if (self.delegate && [self.delegate respondsToSelector:@selector(btUpdateValueForCharacteristic:error:)]) {
            [self.delegate performSelector:@selector(btUpdateValueForCharacteristic:error:) withObject:@"" withObject:error];
        }

        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        //        // We have, so show the data,
        //        [self.textview setText:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
        
        // Cancel our subscription to the characteristic
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
        // Log it
    NSLog(@"Received: %@", stringFromData);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(btUpdateValueForCharacteristic:error:)]) {
        [self.delegate performSelector:@selector(btUpdateValueForCharacteristic:error:) withObject:stringFromData withObject:error];
    }

    
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristic_uid]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}
/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.polarH7HRMPeripheral = nil;
    [self.deviceListArray removeAllObjects];
    self.deviceListArray = nil;
    // We're disconnected, so start scanning again
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateDataSource:)]) {
        [self.delegate performSelector:@selector(updateDataSource:) withObject:self.deviceListArray];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(btdisconnectedPeripheral:error:)]) {
        [self.delegate performSelector:@selector(btdisconnectedPeripheral:error:) withObject:error];
    }
    //move to rootview controller
   // [self startScan];
}


@end
