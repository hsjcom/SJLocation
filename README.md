# SJLocation
LocationManager

*获取当前的地理位置

'CLLocationManager'

'''
    iOS8 在info.plist添加
    NSLocationAlwaysUsageDescription Boolean ＝ YES     //将根据您的地理位置信息，提供精准服务
    NSLocationWhenInUseUsageDescription Boolean ＝ YES  //若不允许，您将无法使用地图定位等相关的功能
'''

'''
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
'''
