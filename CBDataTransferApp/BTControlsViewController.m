//
//  BTControlsViewController.m
//  CBDataTransferApp
//
//  Created by Krishna Shanbhag on 09/11/16.
//  Copyright © 2016 WireCamp Interactive. All rights reserved.
//

#import "BTControlsViewController.h"

typedef enum : NSUInteger {
    locate,
    lock,
    unlock,
    name,
    password,
    fpRegister,
    fpmatch,
    weight,
    beacon,
    beaconOff,
    
} controlType;

@interface BTControlsViewController ()

@property (nonatomic, assign) controlType ctrlType;
@property (nonatomic, strong) CommunicationHandler *handler;
@end

@implementation BTControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.handler = [CommunicationHandler sharedInstance];
    self.handler.delegate = self;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) makeRequest {
    
    [self.handler writeValueForCharacteristicWithString:@"654321"];
}
- (IBAction)lockButtonAction:(id)sender {
    
    
}
- (IBAction)unlockButtonAction:(id)sender {
    
    self.ctrlType = unlock;
    [self makeRequest];
}

- (IBAction)locateButtonAction:(id)sender {

    self.ctrlType = locate;
    [self makeRequest];
}
- (IBAction)nameButtonAction:(id)sender {
    self.ctrlType = name;
    [self makeRequest];
}
- (IBAction)passwordButtonAction:(id)sender {
    
    self.ctrlType = password;
    [self makeRequest];
}
- (IBAction)fpRegisterButtonAction:(id)sender {
    
    self.ctrlType = fpRegister;
    [self makeRequest];

}
- (IBAction)fpMatchButtonAction:(id)sender {
    
    self.ctrlType = fpmatch;
    [self makeRequest];
}
- (IBAction)checkWeightButtonAction:(id)sender {
    
    self.ctrlType = weight;
    [self makeRequest];
}
- (IBAction)beaconButtonAction:(id)sender {
    
    self.ctrlType = beacon;
    [self makeRequest];
}
- (IBAction)beaconOffButtonAction:(id)sender {
    
    self.ctrlType = beaconOff;
    [self makeRequest];
}
- (IBAction)trackViaGpsAction:(id)sender {
    
    [self performSegueWithIdentifier:@"trackViaGps" sender:self];
}
#pragma mark - Datasource and delegates

- (void) btCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
}
- (void) btCentralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}
- (void) btDidWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}
- (void) btUpdateValueForCharacteristic:(NSString *)characteristic error:(NSError *)error {
    
    if (characteristic.length > 0 && [[characteristic lowercaseString] isEqualToString:@"swd+ok"]) {
        
        CommunicationHandler *handler = [CommunicationHandler sharedInstance];

        switch (self.ctrlType) {
            case locate : [handler writeValueForCharacteristicWithString:@"LOC"];break;
            case lock : [handler writeValueForCharacteristicWithString:@"654321"]; break;
            case unlock : [handler writeValueForCharacteristicWithString:@"UNLOCK:10"]; break;
            case name : [handler writeValueForCharacteristicWithString:@"NAME?"]; break;
            case password  : [handler writeValueForCharacteristicWithString:@"PASSWD"]; break;
            case fpRegister : [handler writeValueForCharacteristicWithString:@"FPREG:11"]; break;
            case fpmatch  : [handler writeValueForCharacteristicWithString:@"FPMATCH"]; break;
            case weight  : [handler writeValueForCharacteristicWithString:@"LOADWT"]; break;
            case beacon  : [handler writeValueForCharacteristicWithString:@"IBEACON"]; break;
            case beaconOff : [handler writeValueForCharacteristicWithString:@"IBEACOFF"]; break;
                
            default:
                break;
        }
        
    }
    else {
        //something went wrong try again.
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"ALERT" message:[characteristic lowercaseString] preferredStyle:UIAlertControllerStyleAlert];
        [alertcontroller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertcontroller animated:YES completion:nil];
    }
}
- (void) btdisconnectedPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"Disconnected" message:@"Bluetooth has been disconnected, Please reconnect" preferredStyle:UIAlertControllerStyleAlert];
    [alertcontroller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        //[[CommunicationHandler sharedInstance] startScan];
    }]];
    [self presentViewController:alertcontroller animated:YES completion:nil];
}
@end
