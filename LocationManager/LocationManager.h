//
//  LocationManager.h
//  Tushuo
//
//  Created by wngzc on 15/3/24.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

//单例时刻更新位置信息

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, LocationType){
    LocationTypeMars,
    LocationTypeEarth,
    LocationTypeBaidu
};


@interface LocationManager : NSObject<CLLocationManagerDelegate>

@property (nonatomic,retain ) CLLocationManager       *LManager;
@property (nonatomic,retain ) CLLocation              *baiduLocation;
@property (nonatomic,retain ) CLLocation              *earthLocation;
@property (nonatomic,retain ) CLLocation              *marsthLocation;
@property (nonatomic,retain ) CLGeocoder              *geocoder;
@property (nonatomic,retain ) NSArray                 *locations;


+(instancetype)sharedManager;
-(void)refreshServer;
+(CLLocationDistance)disdanceToLocation:(CLLocation*)toLocation type:(LocationType)type;
@end
