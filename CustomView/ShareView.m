//
//  ShareView.m
//  msgcopy
//
//  Created by Gavin on 15/6/25.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ShareView.h"
#import "WXApi.h"
#import "ShareCollectionCell.h"
#import "SinaPanView.h"
#import "ShareEntity.h"
#import "PubEntity.h"
#import "ArticleEntity.h"
#import "SinaOauthController.h"

#define CellSize  floor((AppWindow.width - 40)/3.0f)
#define MenuHeight CellSize+20

static ShareView *share = nil;


@implementation ShareView

+(instancetype)sharedView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [Utility nibWithName:@"ShareView" index:0];
    });
    return share;
}
-(void)awakeFromNib
{
    self.frame = AppWindow.bounds;
    _menuView.frame = CGRectMake(10, AppWindow.height, AppWindow.width - 20, MenuHeight);
    [_menuView registerNib:[UINib nibWithNibName:@"ShareCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ShareIcon"];
    _menuView.layer.shadowColor = CRCOLOR_BLACK.CGColor;
    _menuView.layer.shadowOffset = CGSizeMake(2,-2);
    _menuView.layer.shadowRadius = 5;
    _menuView.layer.shadowOpacity = .4;
    _menuView.layer.cornerRadius = 5;
    NSMutableArray *menus = [[NSMutableArray alloc] init];
    
    if (![AppKey_Sina isEqualToString:@"null"]&&![AppKey_Sina length]==0) {
        
        [menus addObject:@{
                           @"title":@"新浪微博",
                           @"icon":@"ic_share_sina",
                           @"tag":@"1"
                           }];
        
    }
    if (![WXAppID isEqualToString:@"null"]&&[WXAppID length]> 0) {
        [menus addObject:@{
                           @"title":@"微信好友",
                           @"icon":@"ic_share_weichat",
                           @"tag":@"2"
                        }];
        [menus addObject:@{
                           @"title":@"朋友圈",
                           @"icon":@"ic_share_circle",
                           @"tag":@"3"
                           }];
    }
//    [menus addObject:@{
//                       @"title":@"通讯录",
//                       @"icon":@"ic_share_contact",
//                       @"tag":@"4"
//                       }];
    _menus = menus;
    [_menuView reloadData];
}
# pragma mark - collectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _menus.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CellSize, CellSize);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"ShareIcon";
    ShareCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
    NSDictionary *item = CRArrayObject(_menus, indexPath.row);
    if (item) {
        cell.titleView.text = item[@"title"];
        cell.iconView.image = CRImageNamed(item[@"icon"]);
    }
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [ShareView hidden];
    NSDictionary *item = CRArrayObject(_menus, indexPath.row);
    if (item) {
        NSInteger tag = [item[@"tag"] integerValue];
        switch (tag) {
            case 1:{
                //新浪
                CRWeekRef(self);
                if (_isH5Share== 0 || _title.length == 0 || _title==nil) {
                    [ShareView hidden:^{
                        SinaPanView *panview = [SinaPanView sharedView];
                        panview.imageView.image = self.image?__self.image:[__self capture];
                        [panview show:__self];
                    }];
 
                }
                           }
                break;
            case 2:
            {
                //微信好友
//                if (self.pub) {
//                    [[MsgThreadManager getInstance] startAppBackgroundThreadTarget:self selector:@selector(actionWeixin:) data:_pub];
//                }
                
                if (_isH5Share == 1) {
                    [self sendH5WeiXinMessage:0];
                }else{
                    [self changeScene:WXSceneSession];
                    [self sendMessageContent];
                
                }
                if (_pub) {
                    [UserActionManager userDoShareWeichat:_pub];
                }
            }
                break;
            case 3:
            {
                //朋友圈
               
                if (_isH5Share == 1) {
                    [self sendH5WeiXinMessage:1];
   
                }else{
                
                    [self changeScene:WXSceneTimeline];
                    [self sendMessageContent];
                }
                if (_pub) {
                    [UserActionManager userDoShareCircleFriends:_pub];
                }

            }
                break;
            case 4:
            {
                //通讯录
                
            }
                break;
  
            default:
                break;
        }
    }
    
}
- (IBAction)tocuBegin:(id)sender {
    [ShareView hidden];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *view = [touch view];
    if (view!=self) {
        return false;
    }
    return true;
}

+(void)show:(id)data{
    
    if ([data isMemberOfClass:[ArticleEntity class]]) {
        share.msg = data;
    }else if([data isMemberOfClass:[PubEntity class]]){
        share.pub = data;
        share.msg =share.pub.article;
    }else if([data isMemberOfClass:[ShareEntity class]]){
        ShareEntity *shareData = data;
        share.msg = shareData.article;
    }
    ShareView *share = [ShareView sharedView];
    [AppWindow addSubview:share];
    [UIView animateWithDuration:.35 animations:^{
        share.menuView.y = AppWindow.height - share.menuView.height - 10;
    }];
    
}
+(void)hidden
{
    [ShareView hidden:nil];
}
+(void)hidden:(void(^)(void))complete{
    
    ShareView *share = [ShareView sharedView];
    [UIView animateWithDuration:.35 animations:^{
        share.menuView.y = AppWindow.height + 10;
    } completion:^(BOOL finished) {
        [share removeFromSuperview];
        if (complete) {
            complete();
        }
    }];

}
-(void)sendShareMessage:(NSString *)message
{
    
    NSString *token = CRUserObj(CRString(@"%@_sina_token",kCurUserName));
    CRWeekRef(self);
    if (!token||!(LoginState)) {
        [SinaOauthController doOauth:^(BOOL result, id data, NSString *msg) {
            if (result) {
                [__self sendShareMessage:message];
            }else{
                [CustomToast showMessageOnWindow:msg];
            }
        } target:CRRootNavigation()];
        return;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    hud.removeFromSuperViewOnHide = true;
    NSData *data = nil;
    UIImage *postImage = [self capture];
    if (UIImagePNGRepresentation(postImage) == nil) {
        data = UIImageJPEGRepresentation(postImage, 1);
    } else {
        data = UIImagePNGRepresentation(postImage);
    }
    if (data == nil) {
        data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon@2x" ofType:@"png"]];
    }
    NSMutableDictionary *params         = [NSMutableDictionary dictionaryWithObjectsAndKeys:token,@"access_token",AppKey_Sina,@"source",message,@"status",nil];
    MKNetworkEngine *engine             = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
    MKNetworkOperation *op              = [engine operationWithURLString:[kAPIShareMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:params httpMethod:@"POST"];
    [op addData:data forKey:@"pic" mimeType:@"multipart/form-data" fileName:@"filename.jpg"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [hud hide:true];
        if (_pub) {
            [UserActionManager userDoShareSina:_pub];
        }
        [CustomToast showMessageOnWindow:@"分享成功"];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:error.localizedDescription];
    }];
    [engine enqueueOperation:op];

}
#pragma mark - 分享到微信
-(void)sendMessageContent{
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        WXMediaMessage *message = [WXMediaMessage message];
        NSInteger sid;
        NSString *descr = _msg.descr;
        if (_msg.descr==nil||[_msg.descr length]==0) {
            descr = @"点击加载更多";
        }
        message.title = _msg.title;
        message.description = descr;
        sid = _msg.mid;
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(_msg.thumbnail.turl) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (image) {
                CGFloat max = image.size.height>image.size.width?image.size.width:image.size.height;
                UIImage *scaleImage = [self scaleImage:image toScale:80/max];
                if (scaleImage) {
                    [message setThumbImage:scaleImage];
                }
            }
            NSString *domain = CRUserObj(kThirdShare);
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = [NSString stringWithFormat:@"http://%@/third/s/%d/?%@",domain,sid,URL_CHANNEL];
            message.mediaObject = ext;
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = _scene;
            [WXApi sendReq:req];
        }];
        
    }else{
        
        [GVAlertView showAlert:nil message:@"你的iPhone上还没有安装微信,无法使用此功能" confirmButton:@"马上下载" action:^{
            NSString *weiXinLink = @"itms-apps://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weiXinLink]];
        } cancelTitle:@"取消" action:nil];
    }
    
}
-(void)sendH5WeiXinMessage:(NSInteger)wxLeiXing{
    if (_title.length == 0 || _title==nil) {
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = @"我的店铺";
            message.description = @"进入我的店铺管理";
            
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = _loadUrl;
            message.mediaObject = ext;
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = wxLeiXing;
            [WXApi sendReq:req];
            
            
        }else{
            
            [GVAlertView showAlert:nil message:@"你的iPhone上还没有安装微信,无法使用此功能" confirmButton:@"马上下载" action:^{
                NSString *weiXinLink = @"itms-apps://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weiXinLink]];
            } cancelTitle:@"取消" action:nil];
        }
        
    }else{
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = _title;
            message.description = _desr;
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(_imgUrl) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (image) {
                    CGFloat max = image.size.height>image.size.width?image.size.width:image.size.height;
                    UIImage *scaleImage = [self scaleImage:image toScale:80/max];
                    if (scaleImage) {
                        [message setThumbImage:scaleImage];
                    }
                }
                WXWebpageObject *ext = [WXWebpageObject object];
                ext.webpageUrl = [NSString stringWithFormat:@"%@",_loadUrl];
                message.mediaObject = ext;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = wxLeiXing;
                [WXApi sendReq:req];
            }];
            
        }else{
            
            [GVAlertView showAlert:nil message:@"你的iPhone上还没有安装微信,无法使用此功能" confirmButton:@"马上下载" action:^{
                NSString *weiXinLink = @"itms-apps://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weiXinLink]];
            } cancelTitle:@"取消" action:nil];
        }
        
        
    }
    
}

- (void)sendMusicContent
{
    
    //    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
    //        WXMediaMessage *message = [WXMediaMessage message];
    //        message.title = @"五月天<后青春期的诗>";
    //        message.description = @"人群中哭着你只想变成透明的颜色\
    //        你再也不会梦或痛或心动了\
    //        你已经决定了你已经决定了\
    //        你静静忍着紧紧把昨天在拳心握着\
    //        而回忆越是甜就是越伤人\
    //        越是在手心留下密密麻麻深深浅浅的刀割\
    //        重新开始活着";
    //        [message setThumbImage:[UIImage imageNamed:@"res3.jpg"]];
    //
    //        WXMusicObject *ext = [WXMusicObject object];
    //        ext.musicUrl = @"http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4BDA0E4B88DE698AFE79C9FE6ADA3E79A84E5BFABE4B990222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696332342E74632E71712E636F6D2F586B303051563558484A645574315070536F4B7458796931667443755A68646C2F316F5A4465637734356375386355672B474B304964794E6A3770633447524A574C48795333383D2F3634363232332E6D34613F7569643D32333230303738313038266469723D423226663D312663743D3026636869643D222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31382E71716D757369632E71712E636F6D2F33303634363232332E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E5889BE980A0EFBC9AE5B08FE5B7A8E89B8B444E414C495645EFBC81E6BC94E594B1E4BC9AE5889BE7BAAAE5BD95E99FB3222C22736F6E675F4944223A3634363232332C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E4BA94E69C88E5A4A9222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D31354C5569396961495674593739786D436534456B5275696879366A702F674B65356E4D6E684178494C73484D6C6A307849634A454B394568572F4E3978464B316368316F37636848323568413D3D2F33303634363232332E6D70333F7569643D32333230303738313038266469723D423226663D302663743D3026636869643D2673747265616D5F706F733D38227D";
    //
    //        message.mediaObject = ext;
    //
    //        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    //        req.bText = NO;
    //        req.message = message;
    //        req.scene = _scene;
    //        [WXApi sendReq:req];
    //
    //    }else{
    //
    //        UIAlertView *alView = [[UIAlertView alloc]initWithTitle:@"" message:@"你的iPhone上还没有安装微信,无法使用此功能，使用微信可以方便的把你喜欢的作品分享给好友。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"免费下载微信", nil];
    //        alView.tag = 100;
    //        [alView show];
    //
    //    }
    
}

- (void)sendVideoContent
{
    
    //    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
    //        WXMediaMessage *message = [WXMediaMessage message];
    //        message.title = @"步步惊奇";
    //        message.description = @"只能说胡戈是中国广告界的一朵奇葩！！！这次真的很多人给跪了、、、";
    //        [message setThumbImage:[UIImage imageNamed:@"res2.jpg"]];
    //
    //        WXVideoObject *ext = [WXVideoObject object];
    //        ext.videoUrl = @"http://www.tudou.com/programs/view/6vx5h884JHY/?fr=1";
    //
    //        message.mediaObject = ext;
    //
    //        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    //        req.bText = NO;
    //        req.message = message;
    //        req.scene = _scene;
    //
    //    }else{
    //        UIAlertView *alView = [[UIAlertView alloc]initWithTitle:@"" message:@"你的iPhone上还没有安装微信,无法使用此功能，使用微信可以方便的把你喜欢的作品分享给好友。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"免费下载微信", nil];
    //        alView.tag = 100;
    //        [alView show];
    //
    //    }
    
}


-(void) changeScene:(NSInteger)scene{
    _scene = scene;
}

-(UIImage *)capture{
    
    CGRect originalFrame = _webView.frame;
    CGPoint originalOffset = _webView.scrollView.contentOffset;
    CGSize entireSize = [_webView sizeThatFits:CGSizeZero];
    [_webView setFrame: CGRectMake(0, 0, entireSize.width, entireSize.height)];
    
    //截图
    UIGraphicsBeginImageContext(entireSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_webView.layer renderInContext:context];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //还原大小 和偏移
    [_webView setFrame:originalFrame];
    _webView.scrollView.contentOffset = originalOffset;
    return screenshot;
    
}
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


-(UIImage*)captureView:(UIView *)theView frame:(CGRect)frame{
    
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, frame);
    UIImage *i = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return i;
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
