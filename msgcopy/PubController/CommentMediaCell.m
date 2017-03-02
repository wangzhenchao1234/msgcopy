//
//  CommentMediaCell.m
//  msgcopy
//
//  Created by wngzc on 15/7/1.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CommentMediaCell.h"

@implementation CommentMediaCell
-(void)awakeFromNib{
    
    _thumbnailView.layer.cornerRadius = 5;
    _thumbnailView.clipsToBounds = true;
    
}
-(void)buildWithData:(NSDictionary *)data target:(id)target{
    attach = nil;
    _delegate = nil;
    if (CRJSONIsDictionary(data)) {
        attach = data;
        _delegate = target;
        NSString *type = [data valueForKey:@"type"];
        if ([type isEqualToString:@"image"]) {
            NSString *fileName = [data valueForKey:@"name"];
            UIImage *image = [UIImage imageWithContentsOfFile:CRUploadFilePath(fileName)];
            UIImage *scaleImage = [UIImage imageByScalingImage:image toSize:CGSizeMake(_thumbnailView.width, _thumbnailView.height)];
            _thumbnailView.image = scaleImage;
            _playView.hidden = true;
        }else if([type isEqualToString:@"video"]){
            NSString *fileName = [data valueForKey:@"thumbnail"];
            UIImage *image = [UIImage imageWithContentsOfFile:CRUploadFilePath(fileName)];
            UIImage *scaleImage = [UIImage imageByScalingImage:image toSize:CGSizeMake(_thumbnailView.width, _thumbnailView.height)];
            _thumbnailView.image = scaleImage;
            _playView.hidden = false;
        }
    }
}
- (IBAction)deleteAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(deleteItem:)]) {
        [_delegate deleteItem:attach];
    }
}



@end
