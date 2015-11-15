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
    MKMapView *_mapView;
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
        self.isShowAllert = YES;

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

- (void)startLocation {
    [self startLocationUseLocation];
    
    [self startLocationUseMap];
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

#pragma mark - CLLocationManager method

/**
 * 使用 CLLocationManager 方法
 * 中国地区会有“火星坐标“偏移
 */
- (void)startLocationUseLocation {
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    /**
     * 英文系统下强制显示中文地址信息
     */
    //保存 Device 的现语言 (英语 法语 ，，，)
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    
    NSMutableArray *userDefaultLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
    if (![language isEqualToString:@"zh-Hans"]) {
        // 强制 成 简体中文
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-Hans", nil] forKey:@"AppleLanguages"];
    }

    _longitude = [NSString stringWithFormat:@"%lf", newLocation.coordinate.longitude];
    _latitude = [NSString stringWithFormat:@"%lf", newLocation.coordinate.latitude];
    
    _lastCoordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    if (_locationBlock) {
        _locationBlock(_lastCoordinate);
        _locationBlock = nil;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
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
        
        if (![language isEqualToString:@"zh-Hans"]) {
            //恢复当前系统语言
            [[NSUserDefaults standardUserDefaults] setObject:userDefaultLanguages forKey:@"AppleLanguages"];
        }
     }];
    
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

#pragma mark - MKMapView method
/**
 * 使用 MKMapView 方法
 * 解决中国地区“火星坐标“偏移
 */
-(void)startLocationUseMap {
    if([SJLocationManager locationServicesEnabled]) {
        if (_mapView) {
            _mapView = nil;
        }
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        _mapView.frame = CGRectMake(0, 0, 1, 1); //iOS8
        [[[[UIApplication sharedApplication] delegate] window] addSubview:_mapView];
        
    } else {
        _city = nil;
        _longitude = nil;
        _latitude = nil;
        
        if (_erroeDelegate && [_erroeDelegate respondsToSelector:@selector(locationServicesNotEnabled)]) {
            [_erroeDelegate locationServicesNotEnabled];
        }
        
        if (_isShowAllert) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"needOpenLocation", nil) message:NSLocalizedString(@"locationSetting", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"openLocation", nil), nil];
                alvertView.tag = 1434696837;
                [alvertView show];
            } else {
                UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"needOpenLocation", nil) message:NSLocalizedString(@"locationSetting", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"iKnow", nil) otherButtonTitles:nil, nil];
                [alvertView show];
            }
        }
    }
}

- (void)stopLocationUseMap {
    _mapView.showsUserLocation = NO;
    [_mapView removeFromSuperview];
    _mapView = nil;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocation *newLocation = userLocation.location;
    _lastCoordinate = mapView.userLocation.location.coordinate;
    
    _longitude = [NSString stringWithFormat:@"%lf", _lastCoordinate.longitude];
    if (_longitude.length <= 0) {
        _longitude = @"";
    }
    _latitude = [NSString stringWithFormat:@"%lf", _lastCoordinate.latitude];
    if (_latitude.length <= 0) {
        _latitude = @"";
    }
    
    if (_locationBlock) {
        _locationBlock(_lastCoordinate);
        _locationBlock = nil;
    }
    
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    CLGeocodeCompletionHandler handle = ^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if (placemark.locality != nil) {
                _city = [NSString stringWithFormat:@"%@", placemark.locality];
            } else { //when locality = nil，use subLocality.
                _city = [NSString stringWithFormat:@"%@", placemark.subLocality];
            }
            
            NSString *subLocality = placemark.subLocality.length <= 0 ? @"" : placemark.subLocality;
            NSString *thoroughfare = placemark.thoroughfare.length <= 0 ? @"" : placemark.thoroughfare;
            NSString *subThoroughfare = placemark.subThoroughfare <= 0 ? @"" : placemark.subThoroughfare;
            _address = [NSString stringWithFormat:@"%@%@%@", subLocality, thoroughfare, subThoroughfare];
        }
        
        if (_cityBlock) {
            _cityBlock(_city);
            _cityBlock = nil;
        }
        
        if (_addressBlock) {
            _addressBlock(_address);
            _addressBlock = nil;
        }
    };
    
    [clGeoCoder reverseGeocodeLocation:newLocation completionHandler:handle];
    [self stopLocationUseMap];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if (_erroeDelegate && [_erroeDelegate respondsToSelector:@selector(locationError:)]) {
        [_erroeDelegate locationError:error];
    }
    [self stopLocationUseMap];
}


@end
