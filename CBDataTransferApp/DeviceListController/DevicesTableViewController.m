//
//  DevicesTableViewController.m
//  CBDataTransferApp
//
//  Created by Krishna Shanbhag on 09/11/16.
//  Copyright © 2016 WireCamp Interactive. All rights reserved.
//

#import "DevicesTableViewController.h"

@interface DevicesTableViewController ()

@property (nonatomic, strong) CommunicationHandler *communicationHandler;
@property (strong, nonatomic) NSString       *passwordString;

@end

@implementation DevicesTableViewController
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.devicesDataSource = [NSMutableArray new];
    [self.tableView reloadData];
    self.communicationHandler = nil;
    
    self.communicationHandler = [CommunicationHandler sharedInstance];
    self.communicationHandler.delegate = self;
     [self.communicationHandler startScan];

}
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.devicesDataSource count];
}
- (void) updateDataSource:(NSMutableArray *)array {
    
    [self.devicesDataSource removeAllObjects];
    [self.devicesDataSource addObjectsFromArray:array];
    [self.tableView reloadData];
    
}
#pragma mark - Data source.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
    CBPeripheral *device = [self.devicesDataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = device.name;
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBPeripheral *device = [self.devicesDataSource objectAtIndex:indexPath.row];
    NSString *name = device.name;
    NSString *messagestring = [NSString stringWithFormat:@"Enter Password for %@",name];
    
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"" message:messagestring preferredStyle:UIAlertControllerStyleAlert];
    [alertcontroller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *pwd = alertcontroller.textFields.firstObject.text;
        [[CommunicationHandler sharedInstance] connectDevice:device withPassword:pwd];
        
        
    }]];
    [alertcontroller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"password";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = YES;
        self.passwordString = textField.text;
    }];
    [self presentViewController:alertcontroller animated:YES completion:nil];
    
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
        [self performSegueWithIdentifier:@"connectionSuccess" sender:self];
    }
    else {
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong please try again" preferredStyle:UIAlertControllerStyleAlert];
        [alertcontroller addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertcontroller animated:YES completion:nil];
    }
}

@end
