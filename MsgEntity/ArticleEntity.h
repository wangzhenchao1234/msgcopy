//
//  ArticleEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/9.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ArticleGroupEntity;
@class UserEntity;
@class ThumbnailEntity;
@class KaokeImageSet;
@class CtypeModal;
@class IconEntity;

typedef NS_ENUM(NSInteger, MSGCtype) {
    
    MSGCtypeHunpai = 0,
    MSGCtypeZhuanti,
    MSGCtypeDianshang,
    MSGCtypeTuji,
    MSGCtypeShipin,
    MSGCtypeBiaodan,
    MSGCtypeYouhuiquan,
    MSGCtypeChoujiang,
    MSGCtypeLianjie
};

@interface ArticleEntity : NSObject

@property (nonatomic,assign ) BOOL               commentEvent;
@property (nonatomic,assign ) BOOL               enableComment;
@property (nonatomic, assign) NSInteger          mid;
@property (nonatomic, assign) NSInteger          pubid;
@property (atomic, assign   ) NSInteger          comment_count;
@property (atomic, assign   ) NSInteger          newCommentCount;
@property (atomic, retain   ) NSDate             * uTime;
@property (atomic, retain   ) NSDate             * cTime;
@property (nonatomic, copy  ) NSString           *title;
@property (nonatomic, copy  ) NSString           *content;
@property (nonatomic, assign) NSInteger           like;
@property (nonatomic, copy  ) NSString           *descr;
@property (nonatomic, copy  ) NSString           *source;
@property (atomic, copy     ) NSString           *msgJson;
@property (atomic, copy     ) NSString           *msgCommentsJson;
@property (nonatomic,retain ) NSMutableArray     *links;
@property (nonatomic, retain) ArticleGroupEntity *parent;
@property (atomic, retain   ) UserEntity         * master;
@property (nonatomic, retain) ThumbnailEntity    * thumbnail;
@property (nonatomic, retain) NSMutableArray     *images;
@property (nonatomic, retain) KaokeImageSet      *imageSet;
@property (nonatomic, retain) NSMutableArray     *videos;
@property (nonatomic, retain) CtypeModal         *ctype;
@property (nonatomic, retain) CLLocation       *location;
@property (nonatomic,retain ) IconEntity         *icon;
@property (nonatomic,assign ) BOOL               isSelected;
@property (nonatomic,assign ) MSGCtype           msgCtype;

@property(nonatomic,retain)NSArray *comments;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;
-(id)initWithTitle:(NSString*)title Content:(NSString*)content;
//-(ServiceData*)getComments;
//-(ServiceData*)getContent;
@end

@interface ArticleGroupEntity : NSObject

@property (nonatomic       ) BOOL           isDefault;
@property (nonatomic       ) BOOL           commentEvent;
@property (nonatomic       ) BOOL           isSystemType;
@property (nonatomic       ) NSInteger      gid;
@property (nonatomic,copy  ) NSString       *title;
@property (atomic,copy     ) NSDate         * ctime;
@property (atomic,retain   ) NSMutableArray *msgs;
@property (nonatomic,retain) NSMutableArray * images;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;

-(id)initWithTitle:(NSString*)title;
-(void)addMsg:(ArticleEntity*)msg;
-(void)addNewMsg:(ArticleEntity *)msg;
-(void)removeMsg:(ArticleEntity*) msg;

@end

@interface KaokeMedia : NSObject

@property (nonatomic,assign ) NSInteger           oid;
@property (nonatomic,assign ) NSInteger           mid;
@property (nonatomic,copy   ) NSString            * ourl;
@property (nonatomic,copy   ) NSString            * otitle;
@property (nonatomic,copy   ) NSString            * descr;
@property (nonatomic,assign   ) BOOL            isAdd;


@end

@interface KaokeWebpage : NSObject




@end

@interface KaokeAttach : NSObject




@end

@interface KaokeAudio : KaokeMedia

+(KaokeAudio*)buildInstanceByJson:(NSDictionary*)json;



@end

@interface KaokeImage : KaokeMedia

+(KaokeImage*)buildInstanceByJson:(NSDictionary*)json;

@end

@interface KaokeVideo : KaokeMedia

@property (nonatomic,copy   ) NSString            * thumbnail;

+(KaokeVideo*)buildInstanceByJson:(NSDictionary*)json;

@end

@interface KaokeImageSet : NSObject

@property (nonatomic,assign ) NSInteger           isid;
@property (nonatomic,copy   ) NSString            * descr;
@property (nonatomic,copy   ) NSString            * title;
@property (nonatomic,retain ) NSMutableArray      *images;

+(KaokeImageSet*)buildInstanceByJson:(NSDictionary*)json;
@end
