//
//  locateDeviceViewController.m
//  CBDataTransferApp
//
//  Created by Krishna Shanbhag on 23/11/16.
//  Copyright © 2016 WireCamp Interactive. All rights reserved.
//

#import "locateDeviceViewController.h"
#import "EGSessionManager.h"

@import CoreLocation;
@import MapKit;

@interface locateDeviceViewController () <CLLocationManagerDelegate> {
    
    BOOL deviceLocationAvailable;
}
@property (nonatomic, strong) CLLocationManager *locManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapview;

@property (nonatomic) CLLocationCoordinate2D userLocation;
@property (nonatomic) CLLocation *deviceLocation;

@end

@implementation locateDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.locManager == nil) {
        self.locManager = [[CLLocationManager alloc] init];
    }
    self.locManager.delegate = self;
    self.mapview.showsUserLocation = YES;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locManager requestWhenInUseAuthorization];
    [self.locManager startUpdatingLocation];
    
    // Do any additional setup after loading the view.
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocationCoordinate2D locationCordinate = manager.location.coordinate;
    self.userLocation = CLLocationCoordinate2DMake(0, 0);
    if (locationCordinate.latitude && locationCordinate.latitude) {
        self.userLocation = locationCordinate;
    }
////    if (deviceLocationAvailable == false) {
////        
//        MKCoordinateRegion region = MKCoordinateRegionMake(self.userLocation, MKCoordinateSpanMake(0.01, 0.01));
//        [self.mapview setRegion:region animated:true];
//        
//        [self.mapview removeAnnotations:self.mapview.annotations];
//        
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//        annotation.coordinate = self.userLocation;
//        annotation.title = @"Your location";
//        [self.mapview addAnnotation:annotation];
//    }
//    else {
    
        [self getDeviceLocations];
//    }
    
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
}
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(nullable CLRegion *)region
              withError:(NSError *)error {
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}
- (void) getDeviceLocations {
    
    NSMutableURLRequest *request = [[EGSessionManager sharedManager] requestWithHTTPMethod:@"GET"
                                                       URLPath:@""
                                                    parameters:nil
                                                       headers:nil];
    
    NSURLSessionDataTask *task = [[EGSessionManager sharedManager] dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        //if (!error) {

        if (error) {
            
            //NSArray *deviceLocations = (NSArray *)responseObject;
            
            NSMutableArray *deviceLocations = [NSMutableArray arrayWithObjects:@{},@{},@{}, nil];
            
            
            
            for (NSDictionary *location in deviceLocations) {
                
                deviceLocationAvailable = true;

//                CLLocation *deviceCLLocation = [[CLLocation alloc] initWithLatitude:[location[@"latitude"] doubleValue ] longitude:[location[@"longitude"] doubleValue]];
                
                CLLocation *deviceCLLocation = [[CLLocation alloc] initWithLatitude:19.0151 longitude:72.8581];

                self.deviceLocation = deviceCLLocation;
                //CLLocation *userlocation = [[CLLocation alloc] initWithLatitude:self.userLocation.latitude longitude:self.userLocation.longitude];
                
                //float distance = [userlocation distanceFromLocation:deviceCLLocation];
                
                //float roundedDistance = round(distance *100) / 100;
                
                float latDelta = fabs(deviceCLLocation.coordinate.latitude - self.userLocation.latitude) * 2 + 0.05;
                float longDelta = fabs(deviceCLLocation.coordinate.longitude - self.userLocation.longitude) * 2 + 0.05;
                
                MKCoordinateRegion region = MKCoordinateRegionMake(self.userLocation, MKCoordinateSpanMake(latDelta, longDelta));
                [self.mapview removeAnnotations:self.mapview.annotations];
                [self.mapview setRegion:region];
                
//                MKPointAnnotation *userAnnotation = [[MKPointAnnotation alloc] init];
//                userAnnotation.coordinate = self.userLocation;
//                userAnnotation.title = @"Your location";
//                [self.mapview addAnnotation:userAnnotation];

                MKPointAnnotation *deviceAnotation = [[MKPointAnnotation alloc] init];
                deviceAnotation.coordinate = deviceCLLocation.coordinate;
                deviceAnotation.title = @"Your device";
                [self.mapview addAnnotation:deviceAnotation];

            }
        }
    }];
    
    [task resume];
    
}
- (IBAction)openInMapsAction:(id)sender {
    
//    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
//    [geoCoder reverseGeocodeLocation:self.deviceLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        
//        if ([placemarks count] > 0) {
//            
//            MKPlacemark *placeMark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
//            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
//            mapItem.name = @"Your bag";
//            [mapItem openInMapsWithLaunchOptions:[NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey, nil]];            
//        }
//        
//    }];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Open maps" message:@"Show direction" preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"Google maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
            NSString *urlstring=[NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f",self.userLocation.latitude,self.userLocation.longitude,self.deviceLocation.coordinate.latitude,self.deviceLocation.coordinate.longitude];
            
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstring] options:@{}
                   completionHandler:^(BOOL success) {
                       NSLog(@"Open %@: %d",[NSURL URLWithString:urlstring],success);
                   }];
            } else {
                BOOL success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstring]];
                NSLog(@"Open %@: %d",[NSURL URLWithString:urlstring],success);
            }
        }
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Apple maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
            [geoCoder reverseGeocodeLocation:self.deviceLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
                if ([placemarks count] > 0) {
        
                    MKPlacemark *placeMark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
                    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
                    mapItem.name = @"Your bag";
                    [mapItem openInMapsWithLaunchOptions:[NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey, nil]];
                }
            }];
    }]];
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];

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

@end
