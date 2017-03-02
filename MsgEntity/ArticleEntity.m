//
//  ArticleEntity.m
//  msgcopy
//
//  Created by wngzc on 15/4/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ArticleEntity.h"

@implementation ArticleEntity
+(instancetype)buildInstanceByJson:(NSDictionary*)json
{
    if (json == nil) return nil;
    ArticleEntity* msg = [[ArticleEntity alloc] init];
    msg.title           = [Utility dictionaryValue:json forKey:@"title"];
    msg.mid             = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    msg.descr           = [Utility dictionaryValue:json forKey:@"descr"];
    msg.newCommentCount = 0;
    msg.isSelected      = NO;
    msg.videos          = [NSMutableArray new];
    msg.images          = [NSMutableArray new];
    
    NSArray* videosJson = [Utility dictionaryValue:json forKey:@"videos"];
    for (NSDictionary *videoJson in videosJson) {
        KaokeVideo *video   = [KaokeVideo buildInstanceByJson:videoJson];
        [msg.videos addObject:video];
    }
    NSArray* imagesJson = [Utility dictionaryValue:json forKey:@"images"];
    for (NSDictionary *imageJson in imagesJson) {
        KaokeImage *image   = [KaokeImage buildInstanceByJson:imageJson];
        [msg.images addObject:image];
    }
    NSDictionary *group        = [Utility dictionaryValue:json forKey:@"group"];
    msg.parent                 = [ArticleGroupEntity buildInstanceByJson:group];
    NSDictionary* imagesetJson = [Utility dictionaryValue:json forKey:@"imageset"];
    msg.imageSet               = [KaokeImageSet buildInstanceByJson:imagesetJson];
    NSDictionary *jsonCtype    = [Utility dictionaryValue:json forKey:@"ctype"];
    msg.ctype                  = [CtypeModal buildInstanceByJson:jsonCtype];
    
    //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////

    if ([msg.ctype.systitle isEqualToString:@"hunpai"]) {
        msg.msgCtype = MSGCtypeHunpai;
    }else if ([msg.ctype.systitle isEqualToString:@"zhuanti"]){
        msg.msgCtype = MSGCtypeZhuanti;
    }else if ([msg.ctype.systitle isEqualToString:@"tuji"]){
        msg.msgCtype = MSGCtypeTuji;
    }else if ([msg.ctype.systitle isEqualToString:@"shipin"]){
        msg.msgCtype = MSGCtypeShipin;
    }else if ([msg.ctype.systitle isEqualToString:@"dianshang"]){
        msg.msgCtype = MSGCtypeDianshang;
    }else if ([msg.ctype.systitle isEqualToString:@"biaodan"]){
        msg.msgCtype = MSGCtypeBiaodan;
    }else if ([msg.ctype.systitle isEqualToString:@"youhuiquan"]){
        msg.msgCtype = MSGCtypeYouhuiquan;
    }else if ([msg.ctype.systitle isEqualToString:@"choujiang"]){
        msg.msgCtype = MSGCtypeChoujiang;
    }else if ([msg.ctype.systitle isEqualToString:@"lianjie"]){
        msg.msgCtype = MSGCtypeLianjie;
    }
    
    //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////
    
    msg.links                  = [NSMutableArray new];
    NSArray *linksJson         = [Utility dictionaryValue:json forKey:@"weblinks"];
    for (NSDictionary *link in linksJson) {
        NSString *url = [Utility dictionaryValue:link forKey:@"url"];
        if (link) {
            [msg.links addObject:url];
        }
    }
    if (msg.links.count==0) {
        msg.links = nil;
    }
    NSMutableString* ctime = [Utility dictionaryValue:json forKey:@"ctime"];
    NSMutableString* utime = [Utility dictionaryValue:json forKey:@"utime"];
    msg.cTime              = [NSString getDateFromeString:ctime];
    msg.uTime              = [NSString getDateFromeString:utime];
    
    NSDictionary *master    = [Utility dictionaryValue:json forKey:@"master"];
    msg.master              = [UserEntity buildInstanceByJson:master];
    
    msg.content             = [Utility dictionaryValue:json forKey:@"content"];
    msg.like                = [[Utility dictionaryValue:json forKey:@"like"] integerValue];
    msg.enableComment       = [[Utility dictionaryValue:json forKey:@"enable_comment"] boolValue];
    NSDictionary* thumbnail = [Utility dictionaryValue:json forKey:@"thumbnail"];
    msg.thumbnail           = [ThumbnailEntity buildInstanceByJson:thumbnail];
    msg.comment_count       = [[Utility dictionaryValue:json forKey:@"comment_count"] integerValue];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    msg.msgJson             = [writer stringWithObject:json];
    msg.source              = [Utility dictionaryValue:json forKey:@"source"];
    NSMutableString *coord  = [Utility dictionaryValue:json forKey:@"coord"];
    if (coord) {
        if ([coord rangeOfString:@","].location!=NSNotFound) {
            NSArray *coorArray = [coord componentsSeparatedByString:@","];
            CGFloat lng = [coorArray[0] floatValue];
            CGFloat lat = [coorArray[1] floatValue];
            msg.location =  [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        }
    }
    return msg;
}
-(id) init
{
    self = [super init];
    _enableComment = YES;
    _commentEvent  = NO;
    
    return self;
}

-(id)initWithTitle:(NSString*)title Content:(NSString*)content
{
    self = [self init];
    _enableComment = YES;
    _title         = title;
    _content       = content;
    _parent        = nil;
    return self;
}
//-(ServiceData*)getComments
//{
//    ServiceData* data = [ServerService getAllMsgComments:self];
//    return data;
//}
//
//-(ServiceData*)getContent
//{
//    ServiceData *data =[ServerService getMsg:self.mid];
//    if ([ServerServiceUtil isSuccess:data]) {
//        KaokeMsgEntity *msg = data.data;
//        self.content        = msg.content;
//        self.msgJson        = msg.msgJson;
//        self.master         = msg.master;
//        self.thumbnail      = msg.thumbnail;
//        self.imageSet       = msg.imageSet;
//        self.videos         = msg.videos;
//        self.images         = msg.images;
//        self.source         = msg.source;
//        self.links          = msg.links;
//        self.ctype          = msg.ctype;
//        self.cTime          = msg.cTime;
//        self.uTime          = msg.uTime;
//        self.isInited       = true;
//        data.data           = self;
//    }
//    return data;
//}

- (NSString *)description
{
    return self.title;
}

-(NSInteger) getEntityId
{
    return self.mid;
}
-(NSArray*) getSearchableAttribute
{
    return @[@"title"];
}


@end

@implementation KaokeMedia

@synthesize oid    = _oid;
@synthesize mid    = _mid;
@synthesize ourl   = _oUrl;
@synthesize otitle = _oTitle;
@synthesize descr  = _descr;

@end

@implementation KaokeWebpage

@end

@implementation KaokeAttach

@end

@implementation KaokeAudio
+(KaokeAudio*)buildInstanceByJson:(NSDictionary*)json
{
    if (json == nil) return nil;
    KaokeAudio *audio = [[KaokeAudio alloc] init];
    audio.mid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    audio.descr = [Utility dictionaryValue:json forKey:@"descr"];
    
    NSDictionary *jsonObj = [Utility dictionaryValue:json forKey:@"obj"];
    audio.oid = [[Utility dictionaryValue:jsonObj forKey:@"id"] integerValue];
    audio.ourl = [Utility dictionaryValue:jsonObj forKey:@"url"];
    audio.otitle = [Utility dictionaryValue:jsonObj forKey:@"title"];
    return audio;
}
@end

@implementation KaokeImage

+(KaokeImage*)buildInstanceByJson:(NSDictionary*)json{
    if (json == nil) return nil;
    KaokeImage *image = [[KaokeImage alloc] init];
    image.mid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    image.descr = [Utility dictionaryValue:json forKey:@"descr"];
    
    NSDictionary *jsonObj = [Utility dictionaryValue:json forKey:@"obj"];
    image.oid = [[Utility dictionaryValue:jsonObj forKey:@"id"] integerValue];
    image.ourl = [Utility dictionaryValue:jsonObj forKey:@"url"];
    image.otitle = [Utility dictionaryValue:jsonObj forKey:@"title"];
    
    return image;
}

@end

@implementation KaokeVideo

@synthesize thumbnail;

+(KaokeVideo*)buildInstanceByJson:(NSDictionary*)json{
    
    if (json == nil) return nil;
    KaokeVideo *video     = [[KaokeVideo alloc] init];
    video.mid             = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    video.descr           = [Utility dictionaryValue:json forKey:@"descr"];
    video.thumbnail       = [Utility dictionaryValue:json forKey:@"thumbnail"];
    
    NSDictionary *jsonObj = [Utility dictionaryValue:json forKey:@"obj"];
    video.oid             = [[Utility dictionaryValue:jsonObj forKey:@"id"] integerValue];
    video.ourl            = [Utility dictionaryValue:jsonObj forKey:@"url"];
    video.otitle          = [Utility dictionaryValue:jsonObj forKey:@"title"];
    return video;
}

@end

@implementation KaokeImageSet

@synthesize isid;
@synthesize descr;
@synthesize title;
@synthesize images;

+(KaokeImageSet*)buildInstanceByJson:(NSDictionary*)json{
    
    if (json == nil) return nil;
    KaokeImageSet *imageset = [[KaokeImageSet alloc] init];
    imageset.isid           = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    imageset.descr          = [Utility dictionaryValue:json forKey:@"descr"];
    imageset.title          = [Utility dictionaryValue:json forKey:@"title"];
    imageset.images         = [NSMutableArray new];
    NSArray *imagesJson = [Utility dictionaryValue:json forKey:@"images"];
    for (NSDictionary *imageJson in imagesJson) {
        KaokeImage *image = [KaokeImage buildInstanceByJson:imageJson];
        [imageset.images addObject:image];
    }
    return imageset;
}

@end
@implementation ArticleGroupEntity

+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    
    NSInteger id               = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    BOOL defaut                 = [[Utility dictionaryValue:json forKey:@"is_default"] boolValue];
    BOOL system                = [[Utility dictionaryValue:json forKey:@"systype"] boolValue];
    NSString* title            = [Utility dictionaryValue:json forKey:@"title"];
    if ([title isEqualToString:@"MY_ARTICLES"]) {
        title                      = @"我的收藏";
    }
    NSMutableString* ctime     = [Utility dictionaryValue:json forKey:@"ctime"];
    ArticleGroupEntity* group = [[ArticleGroupEntity alloc] initWithTitle:title Id:id IsDefault:defaut IsSystem:system];
    group.ctime                = [NSString getDateFromeString:ctime];
    group.msgs                 = [NSMutableArray new];
    return group;
}

-(id)init
{
    if (self  = [super init]){
        _msgs = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithTitle:(NSString*)title{
    self   = [super init];
    _title = title;
    _msgs  = [[NSMutableArray alloc] init];
    return self;
}

-(id)initWithTitle:(NSString*)t Id:(NSInteger)i IsDefault:(BOOL)defau IsSystem:(BOOL)system
{
    self          = [super init];
    _title        = t;
    _gid          = i;
    _isDefault    = defau;
    _isSystemType = system;
    _msgs         = [[NSMutableArray alloc] init];
    return self;
}

-(void)addMsg:(ArticleEntity*)msg{
    [_msgs addObject:msg];
    [msg setParent:self];
}

-(void)addNewMsg:(ArticleEntity *)msg{
    [_msgs insertObject:msg atIndex:0];
    [msg setParent:self];
}

-(void)removeMsg:(ArticleEntity*) msg{
    [_msgs removeObject:msg];
    msg.parent = nil;
}

-(id)copyWithZone:(NSZone *)zone
{
    ArticleGroupEntity* group = [ArticleGroupEntity new];
    group.title                = [self.title copy];
    group.msgs                 = self.msgs;
    group.gid                  = self.gid;
    group.isDefault            = self.isDefault;
    group.isSystemType         = self.isSystemType;
    group.ctime                = self.ctime;
    return group;
}

- (NSString *)description
{
    return self.title;
}
@end
