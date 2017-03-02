//
//  ShareEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/9.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareEntity : ArticleEntity
@property (nonatomic       ) NSInteger      sid;
@property (nonatomic,retain) NSDate         * readTime;
@property (nonatomic,assign) BOOL           newComment;
@property (atomic,retain) ArticleEntity * article;
@property (atomic,retain) UserEntity     * master;
@property (atomic,retain) UserEntity     * shareMaster;

+(ShareEntity*)buildInstanceByJson:(NSDictionary*)json;


@end
