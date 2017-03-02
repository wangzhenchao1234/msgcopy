//
//  LocationManager.m
//  Tushuo
//
//  Created by wngzc on 15/3/24.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager
+(instancetype)sharedManager
{
    //单例方法
    static LocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LocationManager alloc] init];
    });
    return manager;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self regestLocationManager];
    }
    return self;
}
//启动定位
-(void)regestLocationManager{
    
    self.geocoder = [[CLGeocoder alloc] init];
    self.LManager = [[CLLocationManager alloc] init];
    self.LManager.delegate = self;
    self.LManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.LManager.distanceFilter = kCLDistanceFilterNone;
    [self refreshServer];
}
-(void)refreshServer
{
    if ([self.LManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.LManager performSelector:@selector(requestAlwaysAuthorization) withObject:nil];
    }
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)){
        [self.LManager startUpdatingLocation];
    }

}
-(void)stopLocationServer{
    
    [self.LManager stopUpdatingLocation];
    
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    [manager stopUpdatingLocation];
    self.baiduLocation = nil;
    self.marsthLocation = nil;
    self.earthLocation = nil;

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *earthLocation = [locations lastObject];
    [self.geocoder reverseGeocodeLocation:earthLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil) {
            if ([placemarks count]>0) {
                CLPlacemark *placemark = placemarks[0];
                NSMutableArray *lcs = [NSMutableArray new];
                [lcs addObject:placemark.country?placemark.country:@""];
                [lcs addObject:placemark.administrativeArea?placemark.administrativeArea:@""];
                [lcs addObject:placemark.subLocality?placemark.subLocality:@""];
                [lcs addObject:placemark.thoroughfare?placemark.thoroughfare:@""];
                self.locations = lcs;
            }
        }
    }];

    CLLocation *marsthLocation = [earthLocation locationMarsFromEarth];
    CLLocation *baiduLocation = [marsthLocation locationBaiduFromMars];
    self.baiduLocation = baiduLocation;
    self.marsthLocation = marsthLocation;
    self.earthLocation = earthLocation;
    
}
+(CLLocationDistance)disdanceToLocation:(CLLocation*)toLocation type:(LocationType)type
{
    CLLocation *fromLocation = [LocationManager sharedManager].earthLocation;
    if (type == LocationTypeBaidu) {
        fromLocation = [LocationManager sharedManager].baiduLocation;
    }else if (type == LocationTypeMars) {
        fromLocation = [LocationManager sharedManager].marsthLocation;
    }else {
        fromLocation = [LocationManager sharedManager].earthLocation;
    }
    CLLocationDistance dis = [fromLocation distanceFromLocation:toLocation];
    return dis;;
}
@end
