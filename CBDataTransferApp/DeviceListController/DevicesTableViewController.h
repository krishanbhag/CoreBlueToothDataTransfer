//
//  DevicesTableViewController.h
//  CBDataTransferApp
//
//  Created by Krishna Shanbhag on 09/11/16.
//  Copyright © 2016 WireCamp Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommunicationHandler.h"

@import CoreBluetooth;

@interface DevicesTableViewController : UITableViewController <bluetoothUpdateNotification>

@property (nonatomic, strong) NSMutableArray *devicesDataSource;

@end
