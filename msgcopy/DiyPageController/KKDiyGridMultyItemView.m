//
//  KKDiyGridMultyItemView.m
//  Kaoke
//
//  Created by wngzc on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "KKDiyGridMultyItemView.h"
#import "KKDiyGridSingleItemView.h"
#import "KKDiyModule2View.h"
#import "KKDiyGridMultyItemView.h"
#import "KKdiyBannerView.h"
#import "KKDiyListView.h"

#define WIDTH(columns) self.frame.size.width/columns

#define HEIGHT(rows) self.frame.size.height/rows


@interface KKDiyGridMultyItemView()
{
    DiyMultyGridEntiy *gridData;
}
@end


@implementation KKDiyGridMultyItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backGroundImageView = [[UIImageView alloc] initWithFrame:_contentView.frame];
        [_contentView addSubview:_backGroundImageView];
        [self addSubview:_contentView];
        
    }
    return self;
}

-(void)layoutSubviews{
    _backGroundImageView.backgroundColor = [UIColor blueColor];
    _backGroundImageView.frame = CGRectMake(0, 0,_contentView.frame.size.width , _contentView.frame.size.height);

}

-(void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets{
    
    _contentView.frame = CGRectMake(contentEdgeInsets.left, contentEdgeInsets.top, _contentView.frame.size.width - contentEdgeInsets.left - contentEdgeInsets.right,_contentView.frame.size.height - contentEdgeInsets.bottom - contentEdgeInsets.top);
    [self setNeedsDisplay];
    
}

-(void)buildByData:(DiyMultyGridEntiy*)data page:(DiyPageEntity *)page action:(onClick)action{
    
    gridData = data;
    if ([data.bg_color length]==7) {
        self.contentView.backgroundColor = [UIColor colorFromHexRGB:[data.bg_color substringFromIndex:1]];
    }
    [self.backGroundImageView sd_setImageWithURL:[NSURL URLWithString:gridData.bg_img]];
    for (id obj in gridData.controls) {
         if([obj isMemberOfClass:[DiySingleGridEntity class]]){
            
            DiySingleGridEntity *entity = obj;
            KKDiyGridSingleItemView *gridView = [[KKDiyGridSingleItemView alloc] initWithFrame:CGRectMake([[entity.grid_position valueForKey:@"column"] integerValue]*WIDTH(gridData.columns), [[entity.grid_position valueForKey:@"row"] integerValue]*HEIGHT(gridData.rows),[[entity.grid_position valueForKey:@"column_span"] integerValue]*WIDTH(gridData.columns), [[entity.grid_position valueForKey:@"row_span"] integerValue]*HEIGHT(gridData.rows))];
             [gridView buildByData:entity page:page action:action];
             [_contentView addSubview:gridView];
            
        }else if([obj isMemberOfClass:[DiyMultyGridEntiy class]]){
            DiyMultyGridEntiy *entity = obj;
            KKDiyGridMultyItemView *gridView = [[KKDiyGridMultyItemView alloc] initWithFrame:CGRectMake([[entity.grid_position valueForKey:@"column"] integerValue]*WIDTH(gridData.columns), [[entity.position valueForKey:@"row"] integerValue]*HEIGHT(gridData.rows),[[entity.grid_position valueForKey:@"column_span"] integerValue]*WIDTH(gridData.columns), [[entity.grid_position valueForKey:@"row_span"] integerValue]*HEIGHT(gridData.rows))];
            [gridView buildByData:entity page:page action:action];
            [_contentView addSubview:gridView];
            
            
        }else if([obj isMemberOfClass:[DiyModule2Entity class]]){
            
            DiyModule2Entity*entity = obj;
            KKDiyModule2View *listView = [[KKDiyModule2View alloc] initWithFrame:CGRectMake([[entity.grid_position valueForKey:@"column"] integerValue]*WIDTH(gridData.columns), [[entity.grid_position valueForKey:@"row"] integerValue]*HEIGHT(gridData.rows),[[entity.grid_position valueForKey:@"column_span"] integerValue]*WIDTH(gridData.columns), [[entity.grid_position valueForKey:@"row_span"] integerValue]*HEIGHT(gridData.rows))];
            [listView buildByData:entity page:page action:action];
            [_contentView addSubview:listView];
            
        }else if([obj isMemberOfClass:[DiyLeafContentEntity class]]){
            
            DiyLeafContentEntity *entity = obj;
            LeafEntity *leaf = entity.leaf;
//            FilterManager *manager = [FilterManager sharedManager];
//            NSInteger filterID = manager.valid?[manager.curID integerValue]:0;
            NSInteger filterID = 0;
            [MSGRequestManager Get:kAPILeafPubs(leaf.lid, 0, @"0",filterID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                UIScrollView *scrollView = (UIScrollView*)self.superview;
                NSArray *publications = data;
                
                
                
                NSMutableArray  *pubs = [NSMutableArray new];
                for (NSDictionary *pub in publications) {
                    
                    PubEntity *entity = [PubEntity buildInstanceByJson:pub];
               
                    [pubs addObject:entity];
                    
                     
                }
                [leaf.publications removeAllObjects];
                [leaf.publications addObjectsFromArray:pubs];
                [pubs removeAllObjects];
                
                if (leaf.publications.count > 0) {
                    UIEdgeInsets inset = UIEdgeInsetsMake([[gridData.padding valueForKeyPath:@"top"] floatValue]*SQR(page.column), [[gridData.padding valueForKeyPath:@"left"] floatValue]*SQR(page.column), [[gridData.padding valueForKeyPath:@"bottom"] floatValue]*SQR(page.column), [[gridData.padding valueForKeyPath:@"right"] floatValue]*SQR(page.column));
                    KKDiyListView *listView = [KKDiyListView buildByLeaf:leaf frame:CGRectMake(SQR(page.column)*[[gridData.position valueForKey:@"left"] floatValue],SQR(page.column)*[[gridData.position valueForKey:@"top"] floatValue],SQR(page.column)*[[gridData.position valueForKey:@"width"] floatValue],SQR(page.column)*[[gridData.position valueForKey:@"height"] floatValue]) inset:inset action:action];
                    CGRect frame = _contentView.frame;
                    frame.size.height = listView.frame.size.height;
                    _contentView.frame = frame;
                    [_contentView addSubview:listView];
                    CGSize size = scrollView.contentSize;
                    frame = _contentView.frame;
                    frame.size.height = _contentView.frame.size.height;
                    _contentView.frame = frame;
                    frame = self.frame;
                    frame.size.height = _contentView.frame.size.height;
                    self.frame = frame;
                    size.height = self.frame.origin.y + self.frame.size.height;
                    if (page.isHome) {
                        size.height += TAB_H;
                    }
                    scrollView.contentSize = size;
                }else{
                    CGRect frame = self.frame;
                    frame.size.height = .01;
                    self.frame = frame;
                }

            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [CustomToast showMessageOnWindow:msg];
            }];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
