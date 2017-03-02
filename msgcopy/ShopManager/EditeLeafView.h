//
//  EditeLeafView.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/12.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AddType 0
#define EditeType 1


@interface EditeLeafView : UIView
@property (nonatomic,retain)LeafEntity *leaf;
@property (nonatomic,retain)LimbEntity *limb;
@property (nonatomic,copy)void(^callBack)(BOOL confirm);
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic,assign) NSInteger type;
+(void)showEdite:(LeafEntity*)leaf complete:(void(^)(BOOL confirm))complete;
+(void)showAdd:(LimbEntity*)limb complete:(void(^)(BOOL confirm))complete;

@end
