//
//  MContentController.m
//  msgcopy
//
//  Created by wngzc on 15/7/14.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MContentController.h"
#import "TYAttributedLabel.h"
#import "TYLinkTextStorage.h"

@interface MContentController ()<TYAttributedLabelDelegate>
{
    NSDateFormatter *formatter;
}
@property(nonatomic,retain)UIScrollView *scrollView;
@end

@implementation MContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configScrollview];
    [self rendView];
    // Do any additional setup after loading the view.
}
-(void)configScrollview
{
    //config some
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
    [self.view addSubview:_scrollView];
    
}
-(void)rendView
{
    self.title = @"消息详情";
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.width - 30 - 68, 25)];
    title.font = MSGFont(16);
    title.textColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
    UILabel *timeView = [[UILabel alloc] initWithFrame:CGRectMake(AppWindow.width - 15 - 60 , 15, 60, 20)];
    timeView.font = MSGFont(12);
    timeView.textAlignment = NSTextAlignmentRight;
    timeView.textColor = [UIColor colorFromHexRGB:@"aaaaaa"];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:title];
    [self.scrollView addSubview:timeView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,40 , self.view.width - 30, 0.5)];
    line.backgroundColor = [UIColor colorFromHexRGB:@"eaeaea"];
    [self.scrollView addSubview:line];
    
    title.text = _message.title;
    timeView.text = [formatter stringFromDate:_message.cTime];
    
    TYAttributedLabel *contentlabel = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(15,45 , self.view.width - 30, 20)];
    contentlabel.font = MSGFont(14);
    contentlabel.delegate = self;
    contentlabel.textColor = [UIColor colorFromHexRGB:@"aaaaaa"];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *contentDict = [parser objectWithString:_message.content];
    if (contentDict) {
        NSInteger pubId          = [[Utility dictionaryValue:contentDict forKey:@"pub_id"] integerValue];
        NSString *pubTitle       = [Utility dictionaryValue:contentDict forKey:@"pub_title"];
        
        NSInteger formID          = [[Utility dictionaryValue:contentDict forKey:@"form_id"] integerValue];
        NSString *initData       = [Utility dictionaryValue:contentDict forKey:@"form_init"];
        
        NSString *linkStr = nil;
        if (pubTitle||pubId!=0) {
            linkStr = CRString(@"{\"pub_id\":%d}",pubId);
        }else if(formID!=0&&initData){
            linkStr =  CRString(@"{\"form_id\":%d,\"init_data\":%@}",formID,initData);
        }
        NSString *content = [Utility dictionaryNullValue:contentDict forKey:@"content"];
        if (content) {
            NSMutableArray *textRunArray = [NSMutableArray array];
            if (pubId != 0||formID!=0) {
                NSString *title = (pubTitle ? pubTitle:@"详情");
                content = CRString(@"%@。查看详情请点击“%@”",content, title);
                TYLinkTextStorage *linkTextStorage = [[TYLinkTextStorage alloc]init];
                linkTextStorage.range = NSMakeRange(content.length - 2 - title.length, 2+title.length);
                linkTextStorage.font = MSGFont(14);
                linkTextStorage.textColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
                linkTextStorage.linkStr = linkStr;
                [textRunArray addObject:linkTextStorage];
            }
            contentlabel.text = content;
            [contentlabel addTextStorageArray:textRunArray];
        }

    }else{
        contentlabel.text = _message.content;
    }
    [contentlabel sizeToFit];
    [self.scrollView addSubview:contentlabel];


}
-(void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage
{
    TYLinkTextStorage *st = (TYLinkTextStorage*)textStorage;
    NSDictionary* dict = [[[SBJsonParser alloc] init] objectWithString:st.linkStr];
    NSInteger pubId          = [[Utility dictionaryValue:dict forKey:@"pub_id"] integerValue];
    NSInteger formID          = [[Utility dictionaryValue:dict forKey:@"form_id"] integerValue];
    if (pubId!=0) {
        [MSGTansitionManager openPubWithID:pubId withParams:nil];

    }else if(formID!=0){
        NSDictionary *initDict = [Utility dictionaryNullValue:dict forKey:@"init_data"];
        NSString *initData = [[[SBJsonWriter alloc] init] stringWithObject:initDict];
        NSDictionary *params = @{@"init_data":initData};
        [MSGTansitionManager openWebappWithID:formID withParams:params goBack:nil callBack:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
