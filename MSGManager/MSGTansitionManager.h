//
//  TansitionManager.h
//  msgcopy
//
//  Created by Gavin on 15/7/12.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebAppEntity;

typedef NS_ENUM(NSInteger, BaseFuncName) {
    BaseFuncNameChat,
};


@interface MSGTansitionManager : NSObject
/**
 *  通过pub打开pub
 *
 *  @param pub    pub
 *  @param params 参数
 */
+(void)openPub:(PubEntity*)pub withParams:(id)params;
/**
 *  通过article打开article
 *
 *  @param msg    article
 *  @param params 参数
 */

+(void)openMsg:(ArticleEntity*)msg withParams:(id)params;
/**
 *  通过webapp打开webapp
 *
 *  @param app    webapp
 *  @param params 参数
 */

+(void)openWebApp:(WebAppEntity*)app withParams:(id)params goBack:(WebGoBackAction)goBackAction callBack:(WebCallBackAction)callBackAction;
/**
 *  通过leaf打开leaf
 *
 *  @param leaf    leaf
 *  @param params 参数
 */

+(void)openLeaf:(LeafEntity*)leaf withParams:(id)params;
/**
 *  通过limb打开limb
 *
 *  @param limb    pub
 *  @param params 参数
 */

+(void)openLimb:(LimbEntity*)limb withParams:(id)params;

/**
 *  通过pubid打开pub
 *
 *  @param pubid    pubid
 *  @param params 参数
 */

+(void)openPubWithID:(NSInteger)pubID withParams:(id)params;
/**
 *  通过articleID打开article
 *
 *  @param msgid    msgid
 *  @param params 参数
 */

+(void)openMsgWithID:(NSInteger)msgID withParams:(id)params;
/**
 *  通过webappid打开webapp
 *
 *  @param appid    webappid
 *  @param params 参数
 */

+(void)openWebappWithID:(NSInteger)appid withParams:(id)params goBack:(WebGoBackAction)goBackAction callBack:(WebCallBackAction)callBackAction;
/**
 *  通过limbid打开limb
 *
 *  @param limbid    limbid
 *  @param params 参数
 */

+(void)openLimbWithID:(NSInteger)limbID withParams:(id)params;
/**
 *  通过leafid打开leaf
 *
 *  @param leafid    leafid
 *  @param params 参数
 */

+(void)openLeafWithID:(NSInteger)leafID withParams:(id)params;
/**
 *  打开自定义页面
 *
 *  @param page
 *  @param params 参数
 */

+(void)openDiyPage:(DiyPageEntity*)page withParams:(id)params;
/**
 *  打开自定义页面
 *
 *  @param pageid
 *  @param params 参数
 */

+(void)openDiyPageWithID:(NSInteger)pageID withParams:(id)params;

/**
 *  打开基础功能
 *
 *  @param baseName    基础功能名字
 *  @param params 参数
 */

+(void)openBase:(NSString*)baseName withParams:(id)params;

/**
 *  打开web链接
 *
 *  @param url    网址
 *  @param params 参数
 */
+(void)openLink:(NSString*)url;

/**
 *  播放视频
 *
 *  @param url    网址
 *  @param params 参数
 */
+(void)playVideo:(NSString*)url  title:(NSString*)title;

/**
 *  播放音频
 *
 *  @param url    网址
 *  @param params 参数
 */
+(void)playAudio:(NSString*)url;


@end
