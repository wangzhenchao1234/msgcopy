//
//  UnionPay.m
//  Kaoke
//
//  Created by xiaogu on 14-8-5.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "UnionPay.h"

#import "UPPayPlugin.h"

@implementation UnionPay

+(void)doUnionPay:(NSString*)tradeNum delegate:(id)delegate{
    [UPPayPlugin startPay:tradeNum mode:@"00" viewController:delegate delegate:delegate];
}

@end
