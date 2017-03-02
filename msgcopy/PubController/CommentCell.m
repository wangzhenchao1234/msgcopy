//
//  CommentCell.m
//  msgcopy
//
//  Created by wngzc on 15/6/29.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CommentCell.h"
#import "TYAttributedLabel.h"
#import "TYImageStorage.h"
#import "MediaCell.h"
#import "MovieController.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>

#define GridHeight 60.0f
#define GridPan 10.0f

#define LeftInset 52.0f

#define TopInset 50.0f

#define ContentPan 15.0f


@implementation CommentCell

-(void)awakeFromNib
{
     [super awakeFromNib];
    _attrView.font = MSGFont(14);
    _attrView.textColor = [UIColor colorFromHexRGB:@"bababa"];
    _attrView.x = LeftInset;
    _mediaView.width = 3 * GridHeight + 2*GridPan;
    _mediaView.height = 0;
    _attrView.width = AppWindow.width - LeftInset - ContentPan;
    _mediaView.x = _attrView.x;
    _timeView.x = AppWindow.width - ContentPan - _timeView.width;
    _nickView.width = AppWindow.width - _nickView.x - _timeView.width - 8 - ContentPan;
    _nickView.font = MSGFont(15);
    _headView.layer.cornerRadius = _headView.height/2.0f;
    _headView.clipsToBounds = true;
    [self setLineLeftInset:15];
    [self setLineRightInset:0];
    
    [_mediaView registerNib:[UINib nibWithNibName:@"MediaCell" bundle:nil] forCellWithReuseIdentifier:@"MediaCell"];
}

-(void)buildByData:(CommentEntity*)comment
{
    [self.headView sd_setImageWithURL:CRURL(comment.master.head50) forState:UIControlStateNormal];
    self.timeView.text = [NSString getTimeString:comment.cTime];
    self.nickView.text = comment.master.firstName;
    self.attrView.text = comment.content;
    
    medias = [NSMutableArray new];
    [medias addObjectsFromArray:comment.images];
    [medias addObjectsFromArray:comment.audios];
    [medias addObjectsFromArray:comment.videos];
    commentData = comment;
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    [CBRegularExpressionManager itemIndexesWithPattern:@"\\[[\\u4e00-\\u9fa5a-z]{1,3}\\]" inString:comment.content usingBlock:^(NSString *name,NSRange range,  NSInteger idx, BOOL *const stop) {
        // 图片信息储存
        TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
        NSString *pic = [EmotionManager emotionForKey:name];
        if (pic) {
            imageStorage.imageName = pic;
            imageStorage.range = range;
            imageStorage.size = CGSizeMake(20, 20);
            [tmpArray addObject:imageStorage];
        }
    }];
    
    // 添加图片信息数组到label
    [self.attrView addTextStorageArray:tmpArray];
    _attrView.y = TopInset;
    [_attrView sizeToFit];
    if (comment.videos.count == 0 && comment.images.count == 0) {
        _mediaView.height = 0;
    }else{
        CGFloat mediaHeight = 0;
        NSInteger count = comment.images.count + comment.videos.count;// + comment.audios.count;
        NSInteger rows = count%3==0?(count/3):(count/3+1);
        if (rows == 1) {
            mediaHeight += GridHeight;
        }else if(rows == 2){
            mediaHeight += 2*GridHeight+ GridPan;
        }else if(rows >= 3){
            mediaHeight += 3*GridHeight + GridPan * 2;
        }
        _mediaView.y = _attrView.y + _attrView.height + GridPan;
        _mediaView.height = mediaHeight;
    }
    [_mediaView reloadData];
    
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    [medias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KaokeImage class]]) {
            KaokeImage *img = obj;
            MWPhoto *photo = [[MWPhoto alloc] initWithURL:CRURL(img.ourl)];
            NSLog(@"---------%@",img.ourl);
            [imgs addObject:photo];
        }
    }];
    imagesItem = nil;
    imagesItem = imgs;
}

+(CGFloat)getHeightWithContent:(NSString *)content mediaCount:(NSInteger)count{
    
    CommentCell *cell = [Utility nibWithName:@"CommentCell" index:0];
    TYAttributedLabel *label = cell.attrView;
    label.text = content;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    NSMutableArray *tmpArray = [NSMutableArray array];
    [CBRegularExpressionManager itemIndexesWithPattern:@"\\[[\\u4e00-\\u9fa5a-z]{1,3}\\]" inString:content usingBlock:^(NSString *name,NSRange range,  NSInteger idx, BOOL *const stop) {
        // 图片信息储存
        TYImageStorage *imageStorage = [[TYImageStorage alloc] init];
        NSString *pic = [EmotionManager emotionForKey:name];
        if (pic) {
            imageStorage.imageName = pic;
            imageStorage.range = range;
            imageStorage.size = CGSizeMake(20, 20);
            [tmpArray addObject:imageStorage];
        }
    }];
    // 添加图片信息数组到label
    [label addTextStorageArray:tmpArray];
    label.y = TopInset;
    [label sizeToFit];
    
    CGFloat textHeight = label.height;
    CGFloat mediaHeight = GridPan;
    NSInteger rows = count%3==0?(count/3):(count/3+1);
    if (rows == 1) {
        mediaHeight += GridHeight;
    }else if(rows == 2){
        mediaHeight += 2*GridHeight+ GridPan;
    }else if(rows >= 3){
        mediaHeight += 3*GridHeight + GridPan*2;
    }
    return ceil(TopInset + textHeight + GridPan + mediaHeight);
}


# pragma mark - collectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (medias.count>0) {
        return 1;
    }
    return 0;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return medias.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(GridHeight, GridHeight);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return GridPan;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
    KaokeMedia *media = CRArrayObject(medias, indexPath.row);
    if (media) {
        if (![media isKindOfClass:[KaokeVideo class]]) {
            cell.playView.hidden = true;
            UIImage *thumbnail = [media isKindOfClass:[KaokeImage class]]?ImagePlaceImage:AudioPlaceImage;
            [cell.iconView sd_setImageWithURL:CRURL(media.ourl) placeholderImage:[UIImage imageByScalingImage:thumbnail toSize:CGSizeMake(GridHeight, GridHeight)]];
        }else{
            cell.playView.hidden = false;
            KaokeVideo *video = (KaokeVideo*)media;
            [cell.iconView sd_setImageWithURL:CRURL(video.thumbnail) placeholderImage:[UIImage imageByScalingImage:VideoPlaceImage toSize:CGSizeMake(GridHeight, GridHeight)]];
        }
    }    
    return cell;

}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    KaokeMedia *media = CRArrayObject(medias, indexPath.row);
    if (media) {
      
        if ([media isKindOfClass:[KaokeImage class]]) {
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:(id<MWPhotoBrowserDelegate>)self];
            browser.displayActionButton = false;
            browser.displayNavArrows = true;
            browser.displaySelectionButtons = false;
            browser.alwaysShowControls = false;
            browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            browser.enableGrid = false;
            browser.startOnGrid = false;
            browser.enableSwipeToDismiss = YES;
            NSInteger index = [commentData.images indexOfObject:media];
            [browser setCurrentPhotoIndex:index];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [CRRootNavigation() presentViewController:nc animated:true completion:^{
            }];

            
        }else if([media isKindOfClass:[KaokeAudio class]]){
            
            KaokeAudio *audio =(KaokeAudio*)media;
            UIWebView *web = [[UIWebView alloc] init];
            NSURLRequest *request = [NSURLRequest requestWithURL:CRURL(audio.ourl)];
            [web loadRequest:request];

        }else if([media isKindOfClass:[KaokeVideo class]]){
            
            KaokeVideo *video = (KaokeVideo*)media;
            MovieController *movie = [MovieController movieViewControllerWithContentPath:video.ourl parameters:nil title:video.otitle];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:movie];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [CRRootNavigation() presentViewController:nc animated:true completion:^{
            }];
            
        }
        
    }else{
        [CustomToast showMessageOnWindow:@"发生未知错误!"];
    }
    
}

- (IBAction)showUser:(id)sender {
    if (commentData.master.userName) {
        ContactContentController *content = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ContactContentController"];
        content.userName = commentData.master.userName;
        content.disableEdite = true;
        [CRRootNavigation() pushViewController:content animated:true];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return imagesItem.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    return CRArrayObject(imagesItem, index);
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return CRArrayObject(imagesItem, index);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
