//
//  CommentEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/21.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentEntity : NSObject
@property (nonatomic,assign) NSInteger      cid;
@property (nonatomic,copy  ) NSString       * content;
@property (atomic, retain  ) NSDate         * cTime;
@property (nonatomic,copy  ) NSDate         * readTime;
@property (nonatomic,copy  ) NSString       *commenJson;
@property (nonatomic,retain) NSMutableArray * images;
@property (nonatomic,retain) NSMutableArray * videos;
@property (nonatomic,retain) UserEntity     * master;
@property (nonatomic,retain) ArticleEntity  * article;
@property (nonatomic,retain) NSMutableArray * audios;
+(instancetype)buildInstanceByJson:(NSDictionary*)json;
@end
