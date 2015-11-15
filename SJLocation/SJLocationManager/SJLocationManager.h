//
//  SJLocationManager.h
//  SJLocation
//
//  Created by Soldier on 15/5/14.
//  Copyright (c) 2015年 Soldier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  iOS8 在info.plist添加 （value可缺省）
 *  NSLocationAlwaysUsageDescription string      //将根据您的地理位置信息，提供精准服务
 *  NSLocationWhenInUseUsageDescription string   //若不允许，您将无法使用地图定位等相关的功能
 */

@protocol LocationErrorDelegate <NSObject>

@optional

//定位失败
- (void)locationError:(NSError *)error;

//不允许使用定位服务
- (void)locationServicesNotEnabled;

@end




typedef void (^LocationBlock) (CLLocationCoordinate2D locationCorrrdinate);
typedef void (^NSStringBlock) (NSString *cityString);
typedef void (^NSStringBlock) (NSString *addressString);

@interface SJLocationManager : NSObject<CLLocationManagerDelegate, MKMapViewDelegate>
@property (nonatomic) CLLocationCoordinate2D lastCoordinate;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;

@property (nonatomic, assign) BOOL isShowAllert;

@property (nonatomic, weak) id<LocationErrorDelegate> erroeDelegate;


+ (SJLocationManager *)shareManager;

- (void)startLocation;

/**
 *  获取坐标(经纬度)
 */
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock;

/**
 *  获取城市
 */
- (void)getCity:(NSStringBlock)cityBlock;

/**
 *  获取详细地址
 */
- (void)getAddress:(NSStringBlock)addressBlock;

/**
 *  是否允许使用定位服务
 */
+ (BOOL)locationServicesEnabled;

@end
