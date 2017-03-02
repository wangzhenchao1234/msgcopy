//
//  UserHeadEntity.h
//  Kaoke
//
//  Created by ning wang on 13-06-13.
//
//

#import <Foundation/Foundation.h>

@interface UserHeadEntity : NSObject

@property (nonatomic,copy) NSString * head100;
@property (nonatomic,copy) NSString * head50;
@property (nonatomic,copy) NSString * head320;

@property (nonatomic,assign)NSInteger hid;

+(UserHeadEntity*)buildInstanceByJson:(NSDictionary*)json;

@end
