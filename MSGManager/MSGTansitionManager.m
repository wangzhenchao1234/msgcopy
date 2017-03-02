//
//  TansitionManager.m
//  msgcopy
//
//  Created by Gavin on 15/7/12.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MSGTansitionManager.h"
#import "BroserController.h"
#import "PubOpenHanddler.h"
#import "MsgOpenHandler.h"
#import "XMTabBarController.h"
#import "VirtualPayController.h"
#import "SignView.h"
#import "ServerListController.h"


@implementation MSGTansitionManager

+(void)openPub:(PubEntity *)pub withParams:(id)params
{
    [PubOpenHanddler openWithPub:pub placeholderView:nil];
}
+(void)openPubWithID:(NSInteger)pubID withParams:(id)params
{
    [PubOpenHanddler openWithPubID:pubID placeholderView:nil];
}
+(void)openMsg:(ArticleEntity *)msg withParams:(id)params
{
    [MsgOpenHandler openWithMsg:msg placeholderView:nil];
}
+(void)openMsgWithID:(NSInteger)msgID withParams:(id)params
{
    [MsgOpenHandler openWithMsgID:msgID placeholderView:nil];
}

+(void)openLimb:(LimbEntity *)limb withParams:(id)params
{
    if (limb) {
        LimbController *limbCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LimbController"];
        [limbCon reloadDataWithLimb:limb];
        [CRRootNavigation() pushViewController:limbCon animated:true];
    }else{
        [CustomToast showMessageOnWindow:@"您访问的内容不存在！"];
    }

}
+(void)openLimbWithID:(NSInteger)limbID withParams:(id)params
{
    if(limbID == 0){
        [CustomToast showMessageOnWindow:@"您访问的内容不存在！"];
        return;
    }
    LimbController *limbCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LimbController"];
    [limbCon reloadDataWithLimbID:limbID];
    [CRRootNavigation() pushViewController:limbCon animated:true];

}
+(void)openLeaf:(LeafEntity *)leaf withParams:(id)params
{
    if(!leaf){
        [CustomToast showMessageOnWindow:@"您访问的内容不存在！"];
        return;
    }
    LimbController *limbCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LimbController"];
    [limbCon reloadDataWithLeafID:leaf.lid];
    [CRRootNavigation() pushViewController:limbCon animated:true];

}
+(void)openLeafWithID:(NSInteger)leafID withParams:(id)params
{
    if(leafID == 0){
        [CustomToast showMessageOnWindow:@"您访问的内容不存在！"];
        return;
    }
    LimbController *limbCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LimbController"];
    [limbCon reloadDataWithLeafID:leafID];
    [CRRootNavigation() pushViewController:limbCon animated:true];

}
+(void)openWebApp:(WebAppEntity *)app
{
    [MSGTansitionManager openWebApp:app withParams:nil goBack:nil callBack:nil];
}
+(void)openWebappWithID:(NSInteger)appid
{
    [MSGTansitionManager openWebappWithID:appid withParams:nil goBack:nil callBack:nil];
}

+(void)openWebApp:(WebAppEntity *)app withParams:(id)params goBack:(WebGoBackAction)goBackAction callBack:(WebCallBackAction)callBackAction
{
    [MSGTansitionManager openWebappWithID:app.aid withParams:params goBack:goBackAction callBack:callBackAction];
    
}
+(void)openWebappWithID:(NSInteger)appid withParams:(id)params goBack:(WebGoBackAction)goBackAction callBack:(WebCallBackAction)callBackAction
{
    WebAppEntity *app = CRWebAppID(appid);
    if (!app) {
        [CustomToast showMessageOnWindow:@"您访问的内容不存在！"];
        return;
    }
    if (app.isRequirelogin&&!LoginState) {
        [LoginHandler showLoginControllerFromController:CRRootNavigation() complete:^(BOOL loginState) {
            if (LoginState) {
                [MSGTansitionManager openWebappWithID:appid withParams:params goBack:goBackAction callBack:callBackAction];
            }
        }];
        return;
    }
    
    if ([app.systitle isEqualToString:@"shopstore"]) {
        /**
         *  webapp指向店铺
         *  @param app appentity
         */
        ShopStoreListController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ShopStoreListController"];
        [CRRootNavigation() pushViewController:webAppCon animated:true];
        
    }else if ([app.systitle isEqualToString:@"chatroom"]) {
        /**
         *  webapp指向聊天
         *  @param app appentity
         */
        XMTabBarController *xmVC = [[XMTabBarController alloc] init];
        [CRRootNavigation() pushViewController:xmVC animated:true];

        
        
    }else if([app.systitle isEqualToString:@"customerservice"]){
        /**
         *  webapp指向客服
         *  @param app appentity
         */
        
        ServerListController *server = [[ServerListController alloc] init];
        server.master = nil;
        [CRRootNavigation() pushViewController:server animated:YES];
        
    }else if([app.systitle isEqualToString:@"signin"]){
        /**
         *  webapp签到
         *  @param app appentity
         */
        [SignView show];
        
    }else if([app.systitle isEqualToString:@"virtualpay"]){
        /**
         *  webapp指向虚拟充值
         *  @param app appentity
         */
        VirtualPayController *virtual = [[VirtualPayController alloc] init];
        [CRRootNavigation() pushViewController:virtual animated:true];
                
    }else if([app.systitle isEqualToString:@"myshopstore"]){
        /**
         *  webapp指向其他标准app
         *  @param app appentity
         */
        NSLog(@"kAPIShops=====%@",kAPIShops);
        [MSGRequestManager Get:KAPIMyShopStore(kCurUserName) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
    
            NSMutableArray *shops = [NSMutableArray new];
            NSLog(@"data==%@",data);
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ShopStoreEntity *shop = [ShopStoreEntity buildWithJson:obj];
                NSLog(@"shop===%@",shop);
                if ([shop.master.userName isEqualToString:kCurUser.userName]||[kCurApp.master.userName isEqualToString:kCurUser.userName]) {
                    [shops addObject:shop];
                }
            }];
            if (shops.count == 0) {
        
                WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
//                webAppCon.appid = appid;
                webAppCon.params = params;
                webAppCon.goBackAction = goBackAction;
                webAppCon.callBackAction = callBackAction;
                [CRRootNavigation() pushViewController:webAppCon animated:true];
            }else{
              
                WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
                
                [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if (idx==0) {
                        if ([[NSUserDefaults standardUserDefaults] objectForKey:KsaveChannelID]) {
                            ShopStoreEntity *shop = [ShopStoreEntity buildWithJson:obj];
                            webAppCon.appid = appid;
                            webAppCon.sid = shop.sid;
                            webAppCon.params = params;
                            webAppCon.desr = shop.descr;
                            webAppCon.channel = [[NSUserDefaults standardUserDefaults] objectForKey:KsaveChannelID];
                            webAppCon.sharetitle = shop.title;
                            webAppCon.imgUrl = shop.thumbnail.turl;
                            webAppCon.goBackAction = goBackAction;
                            webAppCon.callBackAction = callBackAction;
                            [CRRootNavigation() pushViewController:webAppCon animated:true];
                        }else{
                            [MSGRequestManager Get:GetChannel params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                NSArray*array = data;
                                for (NSDictionary*dic in array) {
                                    if ([dic[@"platform_id"] intValue]==4) {
                                        NSString*channel = dic[@"title"];
                                        [[NSUserDefaults standardUserDefaults] setObject:channel forKey:KsaveChannelID];
                                        ShopStoreEntity *shop = [ShopStoreEntity buildWithJson:obj];
                                        webAppCon.appid = appid;
                                        webAppCon.sid = shop.sid;
                                        webAppCon.params = params;
                                        webAppCon.desr = shop.descr;
                                        webAppCon.channel = [[NSUserDefaults standardUserDefaults] objectForKey:KsaveChannelID];
                                        webAppCon.sharetitle = shop.title;
                                        webAppCon.imgUrl = shop.thumbnail.turl;
                                        webAppCon.goBackAction = goBackAction;
                                        webAppCon.callBackAction = callBackAction;
                                        [CRRootNavigation() pushViewController:webAppCon animated:true];
                                    }
                                }
                                
                            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                
                            }];

                        
                        }
                        
                      
                    }else{
                        
                        
                    }
                    
                }];
                

            
                
            }
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
          
        }];

    }else{
    
        WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
        webAppCon.appid = appid;
        webAppCon.params = params;
        webAppCon.goBackAction = goBackAction;
        webAppCon.callBackAction = callBackAction;
        [CRRootNavigation() pushViewController:webAppCon animated:true];

    }
//    else if ([app.systitle isEqualToString:@"myshopstore"]){
//        
//        /**
//         *  webapp 店铺管理
//         *  @param app appentity
//         */
//        MyShopStores *manager = [Utility controllerInStoryboard:@"Main" withIdentifier:@"MyShopStores"];
//        [CRRootNavigation() pushViewController:manager animated:true];
//        
//        
//    }
}
+(void)openDiyPage:(DiyPageEntity *)page withParams:(id)params
{
    [MSGTansitionManager openDiyPageWithID:page.dpid withParams:params];
}
+(void)openDiyPageWithID:(NSInteger)pageID withParams:(id)params
{
    DiyPageController *pageCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"DiyPageController"];
    pageCon.pageID = pageID;
    [CRRootNavigation() pushViewController:pageCon animated:true];
}
+(void)openBase:(NSString*)baseName withParams:(id)params
{
    NSString *title = params[@"title"];
    IconEntity *icon = params[@"icon"];
    BaseTabItemEntity *base = [[BaseTabItemEntity alloc] initWithType:baseName title:title icon:icon];
    [base doAction];
}
+(void)openLink:(NSString*)url
{
    if (!url||[url isEqualToString:@" "]||url.length == 0) {
//        [CustomToast showMessageOnWindow:@"对不起url不存在"];
        return;
    }
    NSURL *webUrl = CRURL(url);
    BroserController *browser = [Utility controllerInStoryboard:@"Main" withIdentifier:@"BroserController"];
    browser.webURL = webUrl;
    [CRRootNavigation() pushViewController:browser animated:true];

}
+(void)playVideo:(NSString*)url title:(NSString*)title
{
    if (!url) {
        [CustomToast showMessageOnWindow:@"对不起url不存在"];
        return;
    }
    MovieController *movie = [MovieController movieViewControllerWithContentPath:url parameters:nil title:title];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:movie];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [CRRootNavigation() presentViewController:nc animated:true completion:^{
    }];

}
+(void)playAudio:(NSString*)url
{
    if (!url) {
        [CustomToast showMessageOnWindow:@"对不起url不存在"];
        return;
    }
    [[UIApplication sharedApplication] openURL:CRURL(url)];
}


@end
