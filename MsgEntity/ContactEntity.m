//
//  KaokeContactEntity.m
//  kaoke
//
//  Created by 谷少坤 on 13-12-7.
//  Copyright (c) 2013年 Msgcopy. All rights reserved.
//

#import "ContactEntity.h"
#import "ContactGroupEntity.h"

@implementation ContactEntity

+(ContactEntity*)buildInstanceByJson:(NSDictionary*)json{
    
    ContactEntity* contact = [[ContactEntity alloc] init];
    contact.isSelected          = NO;
    contact.title               = [Utility dictionaryValue:json forKey:@"title"];
    contact.cid                 = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    NSMutableString* ctime      = [Utility dictionaryValue:json forKey:@"ctime"];
    contact.occupation               = [Utility dictionaryValue:json forKey:@"occupation"];
    contact.remarks               = [Utility dictionaryValue:json forKey:@"remarks"];
    contact.company               = [Utility dictionaryValue:json forKey:@"company"];

    contact.cTime               = [NSString getDateFromeString:ctime];
    contact.phone               = [Utility dictionaryValue:json forKey:@"phone"];
    if (contact.phone){
        [contact profile];
    }
    contact.prov            = [Utility dictionaryValue:json forKey:@"prov"];
    contact.gender          = [[Utility dictionaryValue:json forKey:@"_gender"] boolValue];
    NSMutableString* birth  = [Utility dictionaryValue:json forKey:@"birthday"];
    contact.birthday        = birth;
    NSDictionary* jsonGroup = [Utility dictionaryValue:json forKey:@"group"];
    contact.parent          = [ContactGroupEntity buildInstanceByJson:jsonGroup];
    contact.inited = true;
    return contact;
}
-(void)buildByProfile:(NSDictionary*)json{
    
    self.city = [Utility dictionaryValue:json forKey:@"city"];
    self.firstName = [Utility dictionaryValue:json forKey:@"first_name"];
    self.lastName = [Utility dictionaryValue:json forKey:@"last_name"];
    self.userName = [Utility dictionaryValue:json forKey:@"username"];
    self.mood = [Utility dictionaryValue:json forKey:@"mood"];
    self.gender = [[Utility dictionaryValue:json forKey:@"gender"] boolValue];
    self.company = [Utility dictionaryValue:json forKey:@"company"];
    self.birthday = [Utility dictionaryValue:json forKey:@"birthday"];
    self.prov = [Utility dictionaryValue:json forKey:@"prov"];
    self.email = [Utility dictionaryValue:json forKey:@"email"];
    NSDictionary* headJson = [Utility dictionaryValue:json forKey:@"head"];
    self.head100 = [Utility dictionaryValue:headJson forKey:@"head100"];
    self.head50 = [Utility dictionaryValue:headJson forKey:@"head50"];
    self.head320 = [Utility dictionaryValue:headJson forKey:@"head320"];
    self.headId = [[Utility dictionaryValue:headJson forKey:@"id"] integerValue];
    self.inited = true;
    
}
-(void)profile
{
    NSString* requestUrlString = [NSString stringWithFormat:@"%@ee/user/profile/%@?%@", URL_API,self.phone.length==11?self.phone:self.userName,URL_CHANNEL];
    NSURL *baseURL = [NSURL URLWithString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        id result = [NSJSONSerialization JSONObjectWithData:respData options:NSJSONReadingMutableContainers error:&error];
        if (CRJSONIsDictionary(result)) {
            [self buildByProfile:result];
        }
    }
}

-(void)getProfileComplete:(requestComplete)complete{
    
    NSString* requestUrlString = [NSString stringWithFormat:@"%@ee/user/profile/%@?%@", URL_API,self.phone.length==11?self.phone:self.userName,URL_CHANNEL];
    CRWeekRef(self);
    [MSGRequestManager Get:requestUrlString params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self buildByProfile:data];
        if (complete) {
            complete(nil, code, data, requestURL);
        }
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (complete) {
            complete(nil, code, data, requestURL);
        }
    }];
}
-(id)initWithName:(NSString*)name Phone:(NSString*)phone{
    self = [super init];
    _title = name;
    _phone = phone;
    _parent = nil;
    return self;
}
-(void)changeGroup:(NSInteger)gid success:(requestComplete)success failed:(requestComplete)failed
{
    NSDictionary *params = @{
                             @"title":self.title,
                             @"phone":self.phone,
                             @"group":CRString(@"%d",gid)
                             };
    [self changeAttrWithParams:params success:success failed:failed];
    
}
-(void)changeTitle:(NSString*)title success:(requestComplete)success failed:(requestComplete)failed
{
    NSDictionary *params = @{
                             @"title":title,
                             @"phone":self.phone,
                             @"group":CRString(@"%d",self.parent.gid)
                             };
    [self changeAttrWithParams:params success:success failed:failed];
    
}
-(void)changePhone:(NSString*)phone success:(requestComplete)success failed:(requestComplete)failed
{
    NSDictionary *params = @{
                             @"title":self.title,
                             @"phone":phone,
                             @"group":CRString(@"%d",self.parent.gid)
                             };
    [self changeAttrWithParams:params success:success failed:failed];
    
}
-(void)changeAttrWithParams:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed
{
    CRWeekRef(self);
    [MSGRequestManager MKUpdate:kAPIEditeContact(self.cid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        __self.title = params[@"title"];
        __self.phone = params[@"phone"];
        success(msg,code,data,requestURL);
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
}
- (NSString *)description
{
    return self.title;
}
@end
