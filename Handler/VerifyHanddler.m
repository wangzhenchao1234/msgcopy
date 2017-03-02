//
//  VerifyHanddler.m
//  msgcopy
//
//  Created by wngzc on 15/5/22.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "VerifyHanddler.h"

@implementation VerifyHanddler
+(BOOL)verifyied:(NSString *)str{
    
    RegegistType type = kRegisterType;
    
    switch (type) {
            
        case RegegistTypeNormal:{
            
            return true;
            
        }
            break;
        case RegegistTypeEmail | RegegistTypePhone:{
            
            return [VerifyHanddler verifyPhone:str]||[VerifyHanddler verifyEmail:str];
            
        }
            break;
        case RegegistTypeEmail:{
            
            return [VerifyHanddler verifyEmail:str];
            
        }
            break;
        case RegegistTypePhone:{
            
            return [VerifyHanddler verifyPhone:str];
            
        }
            break;
        default:
            break;
            
    }
    return true;
    
}

+(BOOL)verifyPhone:(NSString*)str{
    
    NSString *regTags = @"((13[0-9]|15[0-3|5-9]|18[0-9]|1349|17[0|6-8]|14[5|7])\\d{8})";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regTags];
    BOOL result = [emailTest evaluateWithObject:str];
    if (str.length != 11) {
        return false;
    }
    return result;
    
}

+(BOOL)verifyEmail:(NSString*)email{
    
    NSString *regTags = @"\\w+((-\\w+)|(.\\w+))*@[A-Za-z0-9]+((.|-)[A-Za-z0-9]+)*\\.[A-Za-z0-9]+";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regTags];
    BOOL result = [emailTest evaluateWithObject:email];
    return result;
    
}

@end
