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

    _longitude = [NSString stringWithFormat:@"%lf", newLocation.coordinate.longitude];    _latitude = [NSString stringWithFormat:@"%lf", newLocation.coordinate.latitude];
    
    CLGeocoder *geocoder =[[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
         if (placemarks.count > 0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             if (placemark.locality != nil) {
                 _city = [NSString stringWithFormat:@"%@", placemark.locality];
             } else { //when locality = nil ，use subLocality.
                 _city = [NSString stringWithFormat:@"%@", placemark.subLocality];
             }
             
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
    if (_erroeDelegate && [_erroeDelegate respondsToSelector:@selector(locationError:)]) {
        [_erroeDelegate locationError:error];
    }
    
    [manager stopUpdatingLocation];
    [self stopLocation];
}

- (void)startLocation {
    if([SJLocationManager locationServicesEnabled]) {
        if (!_manager) {
            _manager = [[CLLocationManager alloc]init];
        }
        _manager.delegate = self;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [_manager requestAlwaysAuthorization];
        }
        _manager.distanceFilter = 100;
        
        [_manager startUpdatingLocation];
        
    } else {
        if (_erroeDelegate && [_erroeDelegate respondsToSelector:@selector(locationServicesNotEnabled)]) {
            [_erroeDelegate locationServicesNotEnabled];
        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:@"需要开启定位服务" message:@"请在设置 - 隐私 - 定位服务中开启定位" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开启定位", nil];
            alvertView.tag = 1434696837;
            [alvertView show];
        } else {
            UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:@"需要开启定位服务" message:@"请在设置 - 隐私 - 定位服务中开启定位" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alvertView show];
        }
    }
}

- (void)stopLocation {
    _manager = nil;
}

+ (BOOL)locationServicesEnabled {
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1434696837 && buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
