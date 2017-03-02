//
//  KaokeContactEntity.h
//  kaoke
//
//  Created by 谷少坤 on 13-12-7.
//  Copyright (c) 2013年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ContactGroupEntity;

@interface ContactEntity : NSObject

@property BOOL gender;
@property (nonatomic, assign     ) NSInteger               cid;
@property (atomic, retain        ) NSDate                  * cTime;
@property (nonatomic, copy       ) NSString                * city;
@property (nonatomic, copy       ) NSString                * birthday;
@property (nonatomic, copy       ) NSString                * prov;
@property (nonatomic, copy)        NSString                * occupation;
@property (nonatomic, copy)        NSString                * company;
@property (nonatomic, copy)        NSString                * remarks;
@property (nonatomic, copy       ) NSString                * title;
@property (nonatomic, copy       ) NSString                * phone;
@property (nonatomic, copy       ) NSString                * head100;
@property (nonatomic, copy       ) NSString                * head320;
@property (nonatomic, copy       ) NSString                * head50;
@property (nonatomic             ) NSInteger               headId;
@property (nonatomic,copy        ) NSString                *confirmPass;
@property (nonatomic,copy        ) NSString                * userName;
@property (nonatomic,copy        ) NSString                * firstName;
@property (nonatomic,copy        ) NSString                * lastName;
@property (nonatomic ,copy       ) NSString                * passWord;
@property (nonatomic  ,copy      ) NSString                * cookie;
@property (nonatomic,copy        ) NSString                * mood;
@property (nonatomic,copy        ) NSString                * email;
@property (nonatomic             ) BOOL                    inited;
@property (nonatomic             ) BOOL                    isSelected;
@property (nonatomic, retain     ) ContactGroupEntity * parent;

-(id)initWithName:(NSString*)name Phone:(NSString*)phone;
+(ContactEntity*)buildInstanceByJson:(NSDictionary*)json;
-(void)buildByProfile:(NSDictionary*)profile;
-(void)getProfileComplete:(requestComplete)complete;
-(void)changeGroup:(NSInteger)gid success:(requestComplete)success failed:(requestComplete)failed;
-(void)changeTitle:(NSString*)title success:(requestComplete)success failed:(requestComplete)failed;
-(void)changePhone:(NSString*)phone success:(requestComplete)success failed:(requestComplete)failed;

@end
