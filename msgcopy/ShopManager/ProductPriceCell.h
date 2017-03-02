//
//  ProductPriceCell.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/11.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductTextView.h"
#import <VPImageCropper/VPImageCropperViewController.h>


@class PriceEntity;

@interface ProductPriceCell : UITableViewCell<VPImageCropperDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,ProductTextViewDelegate>
@property (weak, nonatomic) IBOutlet ProductTextView *curPrice;
@property (weak, nonatomic) IBOutlet ProductTextView *prePrice;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (retain, nonatomic) PriceEntity *priceData;
@property (weak, nonatomic) IBOutlet UIView *mainView;
-(void)load:(NSString*)price pre:(NSString*)prePrice thumbnail:(NSString*)url;
@end
