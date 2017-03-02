//
//  UnionPay.h
//  Kaoke
//
//  Created by xiaogu on 14-8-5.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnionPay : NSObject

+(void)doUnionPay:(NSString*)tradeNum delegate:(id)delegate;

@end
