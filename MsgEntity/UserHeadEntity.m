//
//  UserHeadEntity.m
//  Kaoke
//
//  Created by ning wang on 13-06-13.
//
//

#import "UserHeadEntity.h"

@implementation UserHeadEntity

@synthesize head100 = m_head100;
@synthesize head320 = m_head320;
@synthesize head50  = m_head50;
@synthesize hid     = m_id;


+(UserHeadEntity*)buildInstanceByJson:(NSDictionary*)json
{
    UserHeadEntity* head = [UserHeadEntity new];
    head.head100         = [Utility dictionaryValue:json forKey:@"head100"];
    head.head320         = [Utility dictionaryValue:json forKey:@"head320"];
    head.head50          = [Utility dictionaryValue:json forKey:@"head50"];
    head.hid             = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    return head;
}


@end
