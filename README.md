# SJLocation
##LocationManager
###获取当前的地理位置

* `CLLocationManager` `MKMapView` 
* 2种方法，`MKMapView`修正`CLLocationManager`中国地区定位火星坐标偏移

```
    iOS8 在info.plist添加 （value可缺省）
    NSLocationAlwaysUsageDescription string     //将根据您的地理位置信息，提供精准服务
    NSLocationWhenInUseUsageDescription string  //若不允许，您将无法使用地图定位等相关的功能
```

***

```
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
```

```
eg:
- (void)getLocationCoordinate {
    [[SJLocationManager shareManager] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
        _locaLabel.text = [NSString stringWithFormat:@“%f   %f”,locationCorrrdinate.latitude,locationCorrrdinate.longitude];
    }];
}
```
