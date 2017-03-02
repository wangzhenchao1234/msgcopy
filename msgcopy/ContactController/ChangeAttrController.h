//
//  ChangeAttrController.h
//  msgcopy
//
//  Created by Gavin on 15/7/27.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeAttrController : UITableViewController
-(id)initWithTitle:(NSString*)title placeholder:(NSString*)placeholder defautContent:(NSString*)defautContent completeAction:(void(^)(id data))completeAction;
@end
