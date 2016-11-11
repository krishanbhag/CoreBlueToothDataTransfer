//
//  CommunicationHandler.h
//  CBDataTransferApp
//
//  Created by Krishna Shanbhag on 09/11/16.
//  Copyright © 2016 WireCamp Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;
@import QuartzCore;

#define service_uid @"FFE0"
#define characteristic_uid @"FFE1"

@protocol bluetoothUpdateNotification <NSObject>

- (void) updateDataSource:( NSMutableArray * _Nonnull)array;

@optional
- (void) btCentralManagerDidUpdateState:(CBCentralManager *)central;
- (void) btPeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
- (void) btCentralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void) btCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void) btdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void) btPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
- (void) btDidWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
- (void) btUpdateValueForCharacteristic:(NSString *)characteristic error:(NSError *)error;
- (void) btUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (void) btCentralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void) btdisconnectedPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
@end

@interface CommunicationHandler : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *polarH7HRMPeripheral;

@property (nonatomic, weak) id <bluetoothUpdateNotification> delegate;


+ (id)sharedInstance;
- (void) startScan;
- (void) stopScan;
- (void) connectDevice:(CBPeripheral *)device withPassword:(NSString *)password;
- (void) writeValueForCharacteristicWithString:(NSString *)string;
@end
