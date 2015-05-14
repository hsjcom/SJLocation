//
//  SJLocationManager.m
//  SJLocation
//
//  Created by Soldier on 15/5/14.
//  Copyright (c) 2015年 Soldier. All rights reserved.
//

#import "SJLocationManager.h"

@interface SJLocationManager (){
    CLLocationManager *_manager;
}

@property (nonatomic, copy) LocationBlock locationBlock;
@property (nonatomic, copy) NSStringBlock cityBlock;
@property (nonatomic, copy) NSStringBlock addressBlock;

@end



@implementation SJLocationManager

+ (SJLocationManager *)shareManager {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)getLocationCoordinate:(LocationBlock)locaiontBlock {
    self.locationBlock = locaiontBlock;
    [self startLocation];
}

- (void)getCity:(NSStringBlock)cityBlock {
    self.cityBlock = cityBlock;
    [self startLocation];
}

- (void)getAddress:(NSStringBlock)addressBlock {
    self.addressBlock = addressBlock;
    [self startLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    CLGeocoder *geocoder =[[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
         if (placemarks.count > 0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             _city = [NSString stringWithFormat:@"%@ %@", placemark.administrativeArea, placemark.locality];
             
             _address = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", placemark.country, placemark.administrativeArea, placemark.locality, placemark.subLocality, placemark.thoroughfare, placemark.subThoroughfare];
         }
        
         if (_cityBlock) {
             _cityBlock(_city);
             _cityBlock = nil;
         }
        
         if (_addressBlock) {
             _addressBlock(_address);
             _addressBlock = nil;
         }
        
     }];
    
    _lastCoordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    if (_locationBlock) {
        _locationBlock(_lastCoordinate);
        _locationBlock = nil;
    }
    
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    [self stopLocation];
}

- (void)startLocation {
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        if (!_manager) {
            _manager = [[CLLocationManager alloc]init];
        }
        _manager.delegate = self;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        _manager.distanceFilter = 100;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [_manager requestAlwaysAuthorization];
        }
        
        [_manager startUpdatingLocation];
        
    } else {
        UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启定位服务,请到设置->隐私,打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alvertView show];
    }
}

- (void)stopLocation {
    _manager = nil;
}


@end
