//
//  KaokeContactGroupEntity.m
//  kaoke
//
//  Created by 谷少坤 on 13-12-7.
//  Copyright (c) 2013年 Msgcopy. All rights reserved.
//

#import "ContactGroupEntity.h"
#import "ContactEntity.h"

@implementation ContactGroupEntity

+(ContactGroupEntity*)buildInstanceByJson:(NSDictionary*)json
{
    NSInteger grid                 = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    BOOL defau                     = [[Utility dictionaryValue:json forKey:@"is_default"] boolValue];
    BOOL system                    = [[Utility dictionaryValue:json forKey:@"systype"] boolValue];
    NSString* title                = [Utility dictionaryValue:json forKey:@"title"];
    NSMutableString* ctime         = [Utility dictionaryValue:json forKey:@"ctime"];
    if ([title isEqualToString:@"MY_CONTACTS"]) {
        title = @"我的通讯录";
    }
    ContactGroupEntity* group = [[ContactGroupEntity alloc] initWithTitle:title Id:grid IsDefault:defau IsSystem:system];
    group.cTime                    = [NSString getDateFromeString:ctime];
    return group;
}
-(id)initWithTitle:(NSString*)t Id:(NSInteger)i IsDefault:(BOOL)defau IsSystem:(BOOL)system
{
    self       = [super init];
    _title     = t;
    _gid       = i;
    _isDefault = defau;
    _isSystype = system;
    _contacts  = [[NSMutableArray alloc] init];
    _isLocal   = FALSE;
    return self;
}

-(void)addContact:(ContactEntity*)contact{
    [_contacts addObject:contact];
    [contact setParent:self];
}
-(void) removeContact:(ContactEntity*)contact{
    [_contacts removeObject:contact];
    contact.parent = nil;
}
-(NSInteger)getSumSelectedContacts{
    NSInteger sum = 0;
    for (ContactEntity* contact in self.contacts) {
        if(contact.isSelected)  sum++;
    }
    return sum;
}
-(ContactEntity*)getContactById:(NSInteger)contactId{
   
    for (ContactEntity* contact in self.contacts) {
        if(contact.cid == contactId)
        {
            return contact;
        }
    }
    return nil;
    
}
-(NSString*) description
{
    return self.title;
}
@end
