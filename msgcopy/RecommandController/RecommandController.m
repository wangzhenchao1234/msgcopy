//
//  KKMessageShareViewController.m
//  Kaoke
//
//  Created by xiaogu on 14-2-17.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "RecommandController.h"
#import <MessageUI/MessageUI.h>
#import "WXApi.h"
#import "SBJsonParser.h"
@interface RecommandController ()<MFMessageComposeViewControllerDelegate,UIWebViewDelegate,UIScrollViewDelegate>{
    UIActivityIndicatorView *act;
    UIWebView *mainView;
    UIView *shareView;
    NSString*_imgurl;
    NSString*_desr;
    NSString*_title;
    NSString*_ico;
    NSString*_m_url;
}

@end

@implementation RecommandController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"好友推荐";
    [self loadData];
    [self loadWebView];

	// Do any additional setup after loading the view.
}
-(void)loadData{
    NSString*sid = [NSString stringWithFormat:@"%ld",kCurAppID];
    NSString*urlStr = [NSString stringWithFormat:@"http://cloud1.kaoke.me/iapi/app/%@/info/",sid];
    [MSGRequestManager Get:urlStr params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
       // NSString*jsonstring = [NSString stringWithFormat:@"%@",data];
    NSDictionary*dic = data;
    NSLog(@"dic===%@",dic);
    _m_url = dic[@"m_url"];
    _title = dic[@"title"];
    _ico = dic[@"ico"];
        
    NSString*sting = dic[@"descr"];
    if (sting ==nil || sting.length==0) {
            
            _desr = @"打开有惊喜";
   
        }else{
        
            _desr = dic[@"descr"];
        }
    
} failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
    
}];

}

-(void)loadWebView{
    
    self.view.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];

    
    mainView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    mainView.delegate = self;
    mainView.scrollView.delegate = self;
    [self.view addSubview:mainView];
    
    
    CGFloat height = 80;
    CGRect frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width,height );
    shareView = [[UIView alloc] initWithFrame:frame];
    shareView.backgroundColor = [UIColor colorWithRed:0 green:160/255.0f blue:232/255.0f alpha:0.9];
    NSString *title = @"短信分享给好友";
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14]];
    UIButton *share = [UIButton buttonWithType:UIButtonTypeCustom];
    share.frame = CGRectMake((self.view.frame.size.width/3+(height-40)/3+ titleSize.width/3-20)*2,15 ,height-40 ,height-40 );
    [share setImage:[UIImage imageNamed:@"duanxin2"] forState:UIControlStateNormal];
    [share addTarget:self action:@selector(shareTo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareView];

   
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3 + titleSize.width/3-20)*2, height-20, titleSize.width+20, titleSize.height)];
    titleLable.text = title;
    titleLable.font = MSGFont(13);
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.textColor = [UIColor whiteColor];
    NSString*wxtitle = @"微信分享到好友";
    CGSize wxtitleSize = [wxtitle sizeWithFont:[UIFont systemFontOfSize:14]];
    UIButton *wxshare = [UIButton buttonWithType:UIButtonTypeCustom];
    wxshare.frame = CGRectMake((height-40)/3+ (wxtitleSize.width/3-20)*2,15 ,height-40 ,height-40 );
    [wxshare setImage:[UIImage imageNamed:@"haoyou2"] forState:UIControlStateNormal];
    wxshare.tag = 10;

    [wxshare addTarget:self action:@selector(sendWXMessageContent:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *wxtitleLable = [[UILabel alloc] initWithFrame:CGRectMake( wxtitleSize.width/3-20, height-20, wxtitleSize.width+20, titleSize.height)];
   
    wxtitleLable.text = wxtitle;
    wxtitleLable.font = MSGFont(13);
    wxtitleLable.backgroundColor = [UIColor clearColor];
    wxtitleLable.textColor = [UIColor whiteColor];
    
    NSString*wxftitle = @"微信分享朋友圈";
    CGSize wxftitleSize = [wxftitle sizeWithFont:[UIFont systemFontOfSize:14]];
    UIButton *wxfshare = [UIButton buttonWithType:UIButtonTypeCustom];
    wxfshare.frame = CGRectMake(self.view.frame.size.width/3+(height-40)/3+ (wxftitleSize.width/3-20)*2,15 ,height-40 ,height-40 );
    [wxfshare setImage:[UIImage imageNamed:@"pengyouquan2"] forState:UIControlStateNormal];
     wxfshare.tag = 11;
    [wxfshare addTarget:self action:@selector(sendWXMessageContent:) forControlEvents:UIControlEventTouchUpInside];
   
    UILabel *wxftitleLable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3 + titleSize.width/3-20, height-20, wxftitleSize.width+20, titleSize.height)];
    
    wxftitleLable.text = wxftitle;
    wxftitleLable.font = MSGFont(13);
    wxftitleLable.backgroundColor = [UIColor clearColor];
    wxftitleLable.textColor = [UIColor whiteColor];
    [shareView addSubview:wxtitleLable];
    [shareView addSubview:share];
    [shareView addSubview:titleLable];
    [shareView addSubview:wxshare];
    [shareView addSubview:wxftitleLable];
    [shareView addSubview:wxfshare];
    act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-30, self.view.frame.size.height/2-30, 60, 60)];
    act.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleGray;
    [self.view addSubview:act];
    act.hidesWhenStopped = YES;
    
    
    NSString *urlStr = kCurApp.downloadUrl;
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [mainView loadRequest:request];
    mainView.scalesPageToFit = true;
}
#pragma mark - 分享到微信
-(void)sendWXMessageContent:(UIButton*)sender{
    NSInteger wxleixing = 0;
    if (sender.tag == 11) {
        wxleixing = 1;
    }else{
        wxleixing = 0;
    
    }
    if (_m_url.length == 0 || [_m_url isEqualToString:@"null"] || _m_url==nil) {
        [CustomToast showMessageOnWindow:@"此app不具有分享微信的连接"];
    }else{
    
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            WXMediaMessage *message = [WXMediaMessage message];
                       message.title = _title;
            message.description = _desr;
            // sid = _msg.mid;
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(_ico) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (image) {
                    CGFloat max = image.size.height>image.size.width?image.size.width:image.size.height;
                    UIImage *scaleImage = [self scaleImage:image toScale:80/max];
                    if (scaleImage) {
                        [message setThumbImage:scaleImage];
                    }
                }
                //NSString *domain = CRUserObj(kThirdShare);
                WXWebpageObject *ext = [WXWebpageObject object];
                ext.webpageUrl = _m_url;
                message.mediaObject = ext;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = wxleixing;
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

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [act stopAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [act stopAnimating];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    [act startAnimating];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
    
    if (velocity.y < 0) {
        CGRect frame = shareView.frame;
        frame.origin.y = self.view.frame.size.height;
        [UIView animateWithDuration:.15 animations:^{
            shareView.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }else if(velocity.y > 0){
        CGRect frame = shareView.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        [UIView animateWithDuration:.15 animations:^{
            shareView.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }
}
- (void)showSMSPicker {
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil) {
        if ([messageClass canSendText]) {
            [self displaySMSComposerSheet];
        }
        else {
            [CustomToast showMessageOnWindow:@"设备没有短信功能"];
        }
    }
    else {
        [CustomToast showMessageOnWindow:@"iOS版本过低,iOS4.0以上才支持程序内发送短信"];
    }
}

- (void)displaySMSComposerSheet {
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    NSString *app_Name = CRAppDisplayName;
    NSString *url = kCurApp.downloadUrl;
    NSString *msg = [NSString stringWithFormat:@"我正在使用【%@】客户端，快来和我互动吧，客户端下载地址: %@ ",app_Name,url];
    picker.body = [[NSString alloc] initWithString:msg];
    [self presentViewController:picker animated:YES completion:^{
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result)
    {
        case MessageComposeResultCancelled:
            //LOG_EXPR(@"Result: SMS sending canceled");
            break;
        case MessageComposeResultSent:
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateTime = [dateFormatter stringFromDate:[NSDate date]];
            [CustomToast showMessageOnWindow:[NSString stringWithFormat:@"发送成功\n时间:%@",dateTime]];
        }
            break;
        case MessageComposeResultFailed:
        {
            [CustomToast showMessageOnWindow:@"发送失败"];
        }
            break;
        default:
            //LOG_EXPR(@"Result: SMS not sent");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)shareTo:(id)sender {
    
    [self showSMSPicker];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
