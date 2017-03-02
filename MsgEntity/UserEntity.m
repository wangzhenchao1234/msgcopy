//
//  UserEntity.m
//  msgcopy
//
//  Created by Gavin on 15/4/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "UserEntity.h"
#import "UserHeadEntity.h"

@implementation UserEntity

+(UserEntity*)buildInstanceByJson:(NSDictionary*)json
{
    NSString* username = [json valueForKey:@"username"];
    NSString* firstName = [json valueForKey:@"first_name"];
    NSString* lastName = [json valueForKey:@"last_name"];
    
    UserEntity* user = [[UserEntity alloc] initWithUser:username First:firstName Last:lastName];
    NSDictionary* headJson = [Utility dictionaryValue:json forKey:@"get_profile"];
    user.head100 = [Utility dictionaryValue:headJson forKey:@"head100"];
    user.head50 = [Utility dictionaryValue:headJson forKey:@"head50"];
    user.head320 = [Utility dictionaryValue:headJson forKey:@"head320"];
    user.headId = [[Utility dictionaryValue:headJson forKey:@"id"] integerValue];
    
    return user;
}
+(instancetype)buildInstanceByMasterJson:(NSDictionary*)json
{
    NSString* username = [json valueForKey:@"username"];
    NSString* firstName = [json valueForKey:@"first_name"];
    NSString* lastName = [json valueForKey:@"last_name"];
    UserEntity* user = [[UserEntity alloc] initWithUser:username First:firstName Last:lastName];
    NSDictionary* profile = [Utility dictionaryValue:json forKey:@"get_profile"];
    NSDictionary* headJson = [Utility dictionaryValue:profile forKey:@"head"];
    user.head100 = [Utility dictionaryValue:headJson forKey:@"head100"];
    user.head50 = [Utility dictionaryValue:headJson forKey:@"head50"];
    user.head320 = [Utility dictionaryValue:headJson forKey:@"head320"];
    user.headId = [[Utility dictionaryValue:headJson forKey:@"id"] integerValue];
    return user;
}

-(void)buildProfileByJson:(NSDictionary*)json
{
    self.userName = [Utility dictionaryValue:json forKey:@"username"];
    self.city = [Utility dictionaryValue:json forKey:@"city"];
    self.firstName = [Utility dictionaryValue:json forKey:@"first_name"];
    self.lastName = [Utility dictionaryValue:json forKey:@"last_name"];
    self.mood = [Utility dictionaryValue:json forKey:@"mood"];
    self.gender = [[Utility dictionaryValue:json forKey:@"gender"] boolValue];
    self.company = [Utility dictionaryValue:json forKey:@"company"];
    self.birthday = [Utility dictionaryValue:json forKey:@"birthday"];
    self.prov = [Utility dictionaryValue:json forKey:@"prov"];
    self.email = [Utility dictionaryValue:json forKey:@"email"];
    self.sina_uid = [Utility dictionaryValue:json forKey:@"uid"];
    self.qq_openid = [Utility dictionaryValue:json forKey:@"openid"];
    self.wx_openid = [Utility dictionaryValue:json forKey:@"wx_openid"];
    self.qrpath = [Utility dictionaryValue:json forKey:@"qrpath"];

    NSDictionary* headJson = [Utility dictionaryValue:json forKey:@"head"];
    self.head100 = [Utility dictionaryValue:headJson forKey:@"head100"];
    self.head50 = [Utility dictionaryValue:headJson forKey:@"head50"];
    self.head320 = [Utility dictionaryValue:headJson forKey:@"head320"];
    self.headId = [[Utility dictionaryValue:headJson forKey:@"id"] integerValue];
    
}
-(UserEntity*)init:(NSString*)name Pw:(NSString*)pw firstName:(NSString *)firstName headImage:(NSString*)headImage mood:(NSString *)mood{
    self = [super init];
    _userName = name;
    _firstName = firstName;
    _passWord = pw;
    _head100 = headImage;
    _mood = mood;
    return self;
}
-(id)initWithCoder:(NSCoder *)coder{
    if(self= [super init])
    {
        self.firstName=[coder decodeObjectForKey:@"firstName"];
        self.lastName=[coder decodeObjectForKey:@"lastName"];
        self.userName=[coder decodeObjectForKey:@"userName"];
        self.passWord=[coder decodeObjectForKey:@"passWord"];
        self.head100=[coder decodeObjectForKey:@"head100"];
        self.head50 = [coder decodeObjectForKey:@"head50"];
        self.head320 = [coder decodeObjectForKey:@"head320"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.mood = [coder decodeObjectForKey:@"mood"];
        self.gender = [[coder decodeObjectForKey:@"gender"] boolValue];
        self.company = [coder decodeObjectForKey:@"company"];
        self.birthday = [coder decodeObjectForKey:@"birthday"];
        self.prov = [coder decodeObjectForKey:@"prov"];
        self.email = [coder decodeObjectForKey:@"email"];
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder{
    
    [coder encodeObject:self.firstName forKey:@"firstName"];
    [coder encodeObject:self.lastName forKey:@"lastName"];
    [coder encodeObject:self.userName forKey:@"userName"];
    [coder encodeObject:self.passWord forKey:@"passWord"];
    [coder encodeObject:self.mood forKey:@"mood"];
    [coder encodeObject:self.head100 forKey:@"head100"];
    [coder encodeObject:self.head50 forKey:@"head50"];
    [coder encodeObject:self.head320 forKey:@"head320"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:[NSNumber numberWithBool:self.gender] forKey:@"gender"];
    [coder encodeObject:self.company forKey:@"company"];
    [coder encodeObject:self.birthday forKey:@"birthday"];
    [coder encodeObject:self.prov forKey:@"prov"];
    [coder encodeObject:self.email forKey:@"email"];
    
}


-(UserEntity*)initWithUser:(NSString*)user First:(NSString*)first Last:(NSString*)last
{
    self = [super init];
    _userName  = user;
    _firstName = first;
    _lastName  = last;
    return self;
}

-(UserEntity*)init:(NSString*)name Pw:(NSString*)pw{
    self = [super init];
    _userName = name;
    _passWord = pw;
    return self;
}

-(void) changeAttr:(NSString*)attr value:(NSString*)value success:(requestComplete)success failed:(requestComplete)failed{
    
    
    NSDictionary *params = @{
                             attr:value
                             };
    CRWeekRef(self);
    [MSGRequestManager MKUpdate:kAPIUserInfo params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if([attr isEqualToString:@"company"]) __self.company        = value;
        else if([attr isEqualToString:@"gender"]) __self.gender     = [value boolValue];
        else if([attr isEqualToString:@"prov"]) __self.prov         = value;
        else if([attr isEqualToString:@"city"]) __self.city         = value;
        else if([attr isEqualToString:@"birthday"]) __self.birthday = value;
        else if([attr isEqualToString:@"mood"]) __self.mood         = value;
        else if([attr isEqualToString:@"head"]) __self.head100      = value;
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
}
-(void)changeUserName:(NSString *)userName andNewPass:(NSString *)newPW success:(requestComplete)success failed:(requestComplete)failed{
    
    NSDictionary *params = @{
                             @"old_username":kCurUserName,
                             @"new_username":userName,
                             @"new_pwd":newPW
                             };
    CRWeekRef(self);
    [MSGRequestManager MKUpdate:kAPIUserFix params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        __self.userName = userName;
        __self.passWord = newPW;
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
    
}
-(NSString*) description
{
    return self.userName;
}

/**
 *  QQ更新个信息
 */
+(void)updateUserInfoWithWeiboInfo:(void(^)(void))complete{
    
    UserEntity *user = kCurUser;
    NSDictionary *info =[LocalManager objectForKey:@"sina_user_info"];
    if (info) {
        NSString *firstname = [info valueForKey:@"screen_name"];
        NSString *mood = [info valueForKey:@"description"];
        NSString *sex = [[info valueForKey:@"gender"] isEqualToString:@"m"] ?@"true":@"false";
        NSString *location = [info valueForKey:@"location"];
        NSArray *objs = [location componentsSeparatedByString:@" "];
        NSString *prov = @"";
        NSString *city = @"";
        if (objs.count > 0) {
            prov = objs[0];
        }
        if (objs.count >1 ) {
            city = objs[1];
        }
        NSString *head = [info valueForKey:@"avatar_hd"];
        
        /**
         *  用户名
         */
        NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
        NSString* requestUrlString = kAPIUserSign;
        NSURL *baseURL = [NSURL URLWithString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
        [request setHTTPMethod:@"PUT"];
        request.timeoutInterval = 30;
        NSString* postString = [NSString stringWithFormat:@"first_name=%@", firstname];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            kCurUser.firstName = firstname;
            [userInfo setObject:firstname forKey:@"first_name"];
        }
        BOOL genderResult = [user changeAttr:@"gender" value:sex];
        if (genderResult) {
            kCurUser.gender = [sex boolValue];
            [userInfo setObject:sex forKey:@"gender"];
        }
        BOOL moodResult =[user changeAttr:@"mood" value:mood];
        if (moodResult) {
            kCurUser.mood = mood;
            [userInfo setObject:mood forKey:@"mood"];
        }
        BOOL cityResult = [user changeAttr:@"city" value:city];
        if (cityResult) {
            kCurUser.city = city;
            [userInfo setObject:city forKey:@"city"];
        }
        
        BOOL provResult = [user changeAttr:@"prov" value:prov];
        if (provResult) {
            kCurUser.prov = prov;
            [userInfo setObject:prov forKey:@"prov"];
        }
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(head) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            UIImage *head320 = image;
            UIImage *head100 = [UIImage imageByScalingAndCroppingForSourceImage:head320 targetSize:CGSizeMake(100, 100)];
            UIImage *head50 = [UIImage imageByScalingAndCroppingForSourceImage:head320 targetSize:CGSizeMake(50, 50)];
            NSData *data320 = UIImagePNGRepresentation(head320);
            NSData *data100 = UIImagePNGRepresentation(head100);
            NSData *data50 = UIImagePNGRepresentation(head50);
            NSMutableDictionary *headImages = [NSMutableDictionary new];
            [headImages setObject:data320 forKey:@"s320"];
            [headImages setObject:data100 forKey:@"s100"];
            [headImages setObject:data50 forKey:@"s50"];
            NSString* requestUrlString = kAPIUserHead;
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
            MKNetworkOperation *op = [engine operationWithURLString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil httpMethod:@"POST"];
            NSArray *keys = headImages.allKeys;
            for (int i = 0;i<keys.count;i++) {
                [op addData:[headImages objectForKey:keys[i]] forKey:keys[i] mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"head%d.png",i]];
            }
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
            [AppWindow addSubview:hud];
            hud.removeFromSuperViewOnHide = true;
            [hud show:true];
            [op onCompletion:^(MKNetworkOperation *completedOperation) {
                NSError *error = nil;
                NSDictionary* jsonHead = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
                UserHeadEntity *head = [UserHeadEntity buildInstanceByJson:jsonHead];
                [kCurUser changeAttr:@"head" value:CRString(@"%d",head.hid) success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    kCurUser.head100 = head.head100;
                    kCurUser.head50 = head.head50;
                    kCurUser.head320 = head.head320;
                    kCurUser.headId = head.hid;
                    complete();
               
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    complete();
                }];
                
            } onError:^(NSError *error) {
                [hud hide:true];
                complete();
            }];
            [engine enqueueOperation:op];
        }];
    }
}
/**
 *  qq数据更新
 */
+(void)updateUserInfoWithQQInfo:(void(^)(void))complete{

    UserEntity *user = kCurUser;
    NSDictionary *QQInfo = [LocalManager objectForKey:@"qq_user_info"];
    if (QQInfo) {
        NSString *firstname = [QQInfo valueForKey:@"nickname"];
        NSString *mood = @"";
        NSString *sex = [[QQInfo valueForKey:@"gender"] isEqualToString:@"男"] ?@"true":@"false";
        NSString *prov = [QQInfo valueForKey:@"province"];
        NSString *city = [QQInfo valueForKey:@"city"];
        NSString *head = [QQInfo valueForKey:@"figureurl_qq_2"];
        
        /**
         *  用户名
         */
        NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
        NSString* requestUrlString = kAPIUserSign;
        NSURL *baseURL = [NSURL URLWithString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
        [request setHTTPMethod:@"PUT"];
        request.timeoutInterval = 30;
        NSString* postString = [NSString stringWithFormat:@"first_name=%@", firstname];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            kCurUser.firstName = firstname;
            [userInfo setObject:firstname forKey:@"first_name"];
        }
        BOOL genderResult = [user changeAttr:@"gender" value:sex];
        if (genderResult) {
            kCurUser.gender = [sex boolValue];
            [userInfo setObject:sex forKey:@"gender"];
        }
        BOOL moodResult =[user changeAttr:@"mood" value:mood];
        if (moodResult) {
            kCurUser.mood = mood;
            [userInfo setObject:mood forKey:@"mood"];
        }
        BOOL cityResult = [user changeAttr:@"city" value:city];
        if (cityResult) {
            kCurUser.city = city;
            [userInfo setObject:city forKey:@"city"];
        }
        
        BOOL provResult = [user changeAttr:@"prov" value:prov];
        if (provResult) {
            kCurUser.prov = prov;
            [userInfo setObject:prov forKey:@"prov"];
        }
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(head) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            UIImage *head320 = image;
            UIImage *head100 = [UIImage imageByScalingAndCroppingForSourceImage:head320 targetSize:CGSizeMake(100, 100)];
            UIImage *head50 = [UIImage imageByScalingAndCroppingForSourceImage:head320 targetSize:CGSizeMake(50, 50)];
            NSData *data320 = UIImagePNGRepresentation(head320);
            NSData *data100 = UIImagePNGRepresentation(head100);
            NSData *data50 = UIImagePNGRepresentation(head50);
            NSMutableDictionary *headImages = [NSMutableDictionary new];
            [headImages setObject:data320 forKey:@"s320"];
            [headImages setObject:data100 forKey:@"s100"];
            [headImages setObject:data50 forKey:@"s50"];
            NSString* requestUrlString = kAPIUserHead;
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
            MKNetworkOperation *op = [engine operationWithURLString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil httpMethod:@"POST"];
            NSArray *keys = headImages.allKeys;
            for (int i = 0;i<keys.count;i++) {
                [op addData:[headImages objectForKey:keys[i]] forKey:keys[i] mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"head%d.png",i]];
            }
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
            [AppWindow addSubview:hud];
            hud.removeFromSuperViewOnHide = true;
            [hud show:true];
            [op onCompletion:^(MKNetworkOperation *completedOperation) {
                NSError *error = nil;
                NSDictionary* jsonHead = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
                UserHeadEntity *head = [UserHeadEntity buildInstanceByJson:jsonHead];
                [kCurUser changeAttr:@"head" value:CRString(@"%d",head.hid) success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    kCurUser.head100 = head.head100;
                    kCurUser.head50 = head.head50;
                    kCurUser.head320 = head.head320;
                    kCurUser.headId = head.hid;
                    complete();
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    complete();
                }];
                
            } onError:^(NSError *error) {
                [hud hide:true];
                complete();
            }];
            [engine enqueueOperation:op];
        }];

    }
}

/**
 *  微信数据更新
 */
+(void)updateUserInfoWithWxInfo:(void(^)(void))complete{

    UserEntity *user = kCurUser;
    NSDictionary *WxInfo = [LocalManager objectForKey:@"weichat_user_info"];
    if (WxInfo) {
        /*
         {
         city = Jiujiang;
         country = CN;
         headimgurl = "http://wx.qlogo.cn/mmopen/bOfDib3HXvxmgEyGTEASaIGSjviaGbhmhKAMdlHyian0kgjMK4ywr5CS2MagicTYIHsG2Wt5CYDXvklqUibicQJAYTkPibfnB3Tib3uI/0";
         language = en;
         nickname = nb;
         openid = "ofQ3qtwgA7IJ7xs-2w6kzOXxE3gA";
         privilege =     (
         );
         province = Jiangxi;
         sex = 1;
         unionid = oANsitxU4Vi5CKwVtypPGR4h56ZI;
         }
         */
        NSString *firstname = [WxInfo valueForKey:@"nickname"];
        NSString *mood = @"";
        NSString *sex = [[WxInfo valueForKey:@"gender"] integerValue]==1?@"true":@"false";
        NSString *prov = [WxInfo valueForKey:@"province"];
        NSString *city = [WxInfo valueForKey:@"city"];
        NSString *head = [WxInfo valueForKey:@"headimgurl"];
        
        /**
         *  用户名
         */
        NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
        NSString* requestUrlString = kAPIUserSign;
        NSURL *baseURL = [NSURL URLWithString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
        [request setHTTPMethod:@"PUT"];
        request.timeoutInterval = 30;
        NSString* postString = [NSString stringWithFormat:@"first_name=%@", firstname];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            kCurUser.firstName = firstname;
            user.firstName = firstname;
            
            NSDictionary *params = @{
                                     @"first_name":firstname
                                     };
            
            [MSGRequestManager MKUpdate:kAPIUserSign params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                   
                
                kCurUser.firstName = firstname;
    
                
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                }];

                
            [userInfo setObject:firstname forKey:@"first_name"];

        }
//        BOOL first_nameResult = [user changeAttr:@"first_name" value:firstname];
//        if (first_nameResult) {
//            kCurUser.firstName = firstname;
//            [userInfo setObject:firstname forKey:@"first_name"];
//
//        }
        BOOL genderResult = [user changeAttr:@"gender" value:sex];
        if (genderResult) {
            kCurUser.gender = [sex boolValue];
            [userInfo setObject:sex forKey:@"gender"];
        }
        BOOL moodResult =[user changeAttr:@"mood" value:mood];
        if (moodResult) {
            kCurUser.mood = mood;
            [userInfo setObject:mood forKey:@"mood"];
        }
        BOOL cityResult = [user changeAttr:@"city" value:city];
        if (cityResult) {
            kCurUser.city = city;
            [userInfo setObject:city forKey:@"city"];
        }
        
        BOOL provResult = [user changeAttr:@"prov" value:prov];
        if (provResult) {
            kCurUser.prov = prov;
            [userInfo setObject:prov forKey:@"prov"];
        }
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(head) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            UIImage *head320 = image;
            UIImage *head100 = [UIImage imageByScalingAndCroppingForSourceImage:head320 targetSize:CGSizeMake(100, 100)];
            UIImage *head50 = [UIImage imageByScalingAndCroppingForSourceImage:head320 targetSize:CGSizeMake(50, 50)];
            NSData *data320 = UIImagePNGRepresentation(head320);
            NSData *data100 = UIImagePNGRepresentation(head100);
            NSData *data50 = UIImagePNGRepresentation(head50);
            NSMutableDictionary *headImages = [NSMutableDictionary new];
            [headImages setObject:data320 forKey:@"s320"];
            [headImages setObject:data100 forKey:@"s100"];
            [headImages setObject:data50 forKey:@"s50"];
            NSString* requestUrlString = kAPIUserHead;
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
            MKNetworkOperation *op = [engine operationWithURLString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil httpMethod:@"POST"];
            NSArray *keys = headImages.allKeys;
            for (int i = 0;i<keys.count;i++) {
                [op addData:[headImages objectForKey:keys[i]] forKey:keys[i] mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"head%d.png",i]];
            }
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
            [AppWindow addSubview:hud];
            hud.removeFromSuperViewOnHide = true;
            [hud show:true];
            [op onCompletion:^(MKNetworkOperation *completedOperation) {
                NSError *error = nil;
                NSDictionary* jsonHead = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
                UserHeadEntity *head = [UserHeadEntity buildInstanceByJson:jsonHead];
                [kCurUser changeAttr:@"head" value:CRString(@"%d",head.hid) success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    kCurUser.head100 = head.head100;
                    NSLog(@"kCurUser.head100===%@",kCurUser.head100);
                    kCurUser.head50 = head.head50;
                    kCurUser.head320 = head.head320;
                    kCurUser.headId = head.hid;
                    complete();
                    [[NSNotificationCenter defaultCenter] postNotificationName:KheadImageComed object:nil];
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    complete();
                }];
                
            } onError:^(NSError *error) {
                [hud hide:true];
                complete();
            }];
            [engine enqueueOperation:op];
        }];
    }

}

-(BOOL)changeAttr:(NSString *)attr value:(NSString *)value
{
    NSString* requestUrlString = kAPIUserInfo;
    NSURL *baseURL = [NSURL URLWithString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    [request setHTTPMethod:@"PUT"];
    request.timeoutInterval = 30;
    NSString* postString = [NSString stringWithFormat:@"%@=%@", attr,value];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        return true;
    }
    return false;
}


@end
