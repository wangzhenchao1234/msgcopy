//
//  KaokeContactGroupEntity.h
//  kaoke
//
//  Created by 谷少坤 on 13-12-7.
//  Copyright (c) 2013年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContactEntity;
@interface ContactGroupEntity : NSObject

@property BOOL isDefault;
@property BOOL isSystype;
@property BOOL isOpen;
@property BOOL isLocal;
@property (nonatomic,assign) NSInteger      gid;
@property (nonatomic,copy  ) NSString       * title;
@property (atomic,retain) NSDate         * cTime;
@property (nonatomic,copy  ) NSMutableArray * contacts;

+(ContactGroupEntity*)buildInstanceByJson:(NSDictionary*)json;

-(void)addContact:(ContactEntity*)contact;
-(void) removeContact:(ContactEntity*)contact;
-(NSInteger)getSumSelectedContacts;
-(ContactEntity*)getContactById:(NSInteger)contactId;

@end
