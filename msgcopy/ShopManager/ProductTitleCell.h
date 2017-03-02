//
//  ProductTitleCell.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/6.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductTitleCell : MsgTableCell<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleView;
@property(nonatomic,retain)NSMutableDictionary *titleData;
@end
