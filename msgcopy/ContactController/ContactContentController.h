//
//  ContactContentController.h
//  msgcopy
//
//  Created by Gavin on 15/7/27.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactEntity;
@interface ContactContentController : UITableViewController
@property(nonatomic,retain)ContactEntity *contact;
@property(nonatomic,assign)BOOL disableEdite;
@property(nonatomic,copy) NSString *userName;
@end
