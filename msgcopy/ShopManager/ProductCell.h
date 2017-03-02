//
//  ProductCell.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/6.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VPImageCropper/VPImageCropperViewController.h>

#import "ProductTextView.h"

@protocol ProductCellDelegate <NSObject>
-(void)deleteItem:(NSIndexPath*)index;
@end

@class ProductEntity;
@interface ProductCell : UITableViewCell<VPImageCropperDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,ProductTextViewDelegate>
{
    ProductEntity *curProduct;
}
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet ProductTextView *titleTextView;
@property (weak, nonatomic) IBOutlet ProductTextView *priceTextView;
@property (weak, nonatomic) IBOutlet ProductTextView *remainTextView;
@property (weak, nonatomic) IBOutlet ProductTextView *descrTextView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (retain, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<ProductCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
-(void)loadProduct:(ProductEntity*)product;
@end
