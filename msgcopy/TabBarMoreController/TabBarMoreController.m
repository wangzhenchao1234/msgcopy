//
//  TabBarMoreController.m
//  msgcopy
//
//  Created by Gavin on 15/4/21.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "TabBarMoreController.h"
#import "TabBarMoreCell.h"

#define CellSize (AppWindow.width-4)/3.0f

@interface TabBarMoreController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,retain)UICollectionView *collectionView;
@end

@implementation TabBarMoreController

static NSString * const reuseIdentifier = @"TabBarMoreCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self configCollectionView];
    // Do any additional setup after loading the view.
}
-(void)configCollectionView
{
    self.title = @"更多";
    self.collectionView.contentInset = UIEdgeInsetsMake( NAV_H + 1.0f,1.0f , 1.0f, 1.0f);
    [self.collectionView registerNib:[UINib nibWithNibName:@"TabBarMoreCell" bundle:nil] forCellWithReuseIdentifier:@"TabBarMoreCell"];
}
-(UICollectionView*)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource= self;
        [_collectionView registerNib:[UINib nibWithNibName:@"TabBarMoreCell.h" bundle:nil] forCellWithReuseIdentifier:@"TabBarMoreCell.h"];
        [self.view addSubview:_collectionView];
        _collectionView.backgroundColor = [UIColor colorFromHexRGB:@"f4f4f4"];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.alwaysBounceVertical = true;
    }
    return _collectionView;
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _items.count;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CellSize, CellSize);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TabBarMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_click"]];
    [self configItemWith:_items[indexPath.row] cell:cell];
    // Configure the cell
    return cell;
}
-(void)configItemWith:(id)data cell:(TabBarMoreCell*)item{
    
    if ([data isMemberOfClass:[HomeConfigEntity class]]) {
        HomeConfigEntity *home  = (HomeConfigEntity*)data;
        item.titleView.text = home.title;
        [item.iconView sd_setImageWithURL:CRURL(home.icon.normal_icon) ];
    }else if ([data isMemberOfClass:[LimbEntity class]]) {
        
        LimbEntity *limb  = (LimbEntity*)data;
        item.titleView.text = limb.title;
        [item.iconView sd_setImageWithURL:CRURL(limb.icon.normal_icon) ];
        
    }else if([data isMemberOfClass:[WebAppEntity class]]){
        
        WebAppEntity *app = (WebAppEntity*)data;
        item.titleView.text = app.title;
        if (app.diyIcon) {
            [item.iconView sd_setImageWithURL:CRURL(app.diyIcon.selected_icon) ];
        }else{
            [item.iconView sd_setImageWithURL:CRURL(app.icon.selected_icon) ];

        }
        
    }else if([data isMemberOfClass:[DiyPageEntity class]]){
        
        DiyPageEntity *page = (DiyPageEntity*)data;
        item.titleView.text = page.text;
        [item.iconView sd_setImageWithURL:CRURL(page.icon.normal_icon) ];
        
    }else if([data isMemberOfClass:[ArticleEntity class]]){
        ArticleEntity *msg = (ArticleEntity*)data;
        item.titleView.text = msg.title;
        [item.iconView sd_setImageWithURL:CRURL(msg.icon.normal_icon) ];
        
    }else if([data isMemberOfClass:[PubEntity class]]){
        PubEntity *pub = (PubEntity*)data;
        item.titleView.text = pub.title;
        [item.iconView sd_setImageWithURL:CRURL(pub.icon.normal_icon) ];
        
    }else if([data isMemberOfClass:[BaseTabItemEntity class]]){
        
        BaseTabItemEntity *tab = (BaseTabItemEntity*)data;
        item.titleView.text = tab.title;
        [item.iconView sd_setImageWithURL:CRURL(tab.icon.normal_icon) ];
    }else if([data isMemberOfClass:[LeafEntity class]]){
        
        LeafEntity *leaf = (LeafEntity*)data;
        item.titleView.text = leaf.title;
        [item.iconView sd_setImageWithURL:CRURL(leaf.icon.normal_icon) ];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    TabBarMoreCell *cell = (TabBarMoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    MenuBarItemEntity *item = _items[indexPath.row];
    if ([item isMemberOfClass:[WebAppEntity class]]) {
        [cell.iconView sd_setImageWithURL:CRURL(item.icon.normal_icon) ];
    }else{
        [cell.iconView sd_setImageWithURL:CRURL(item.icon.selected_icon) ];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    TabBarMoreCell *cell = (TabBarMoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    MenuBarItemEntity *item = _items[indexPath.row];
    if ([item isMemberOfClass:[WebAppEntity class]]) {
        [cell.iconView sd_setImageWithURL:CRURL(item.icon.selected_icon)];
    }else{
        [cell.iconView sd_setImageWithURL:CRURL(item.icon.normal_icon)];
        
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    id data = _items[indexPath.row];
    if ([data isMemberOfClass:[HomeConfigEntity class]]) {
        RDVTabBarController *_rootCenter = self.rdv_tabBarController;
        [_rootCenter setSelectedIndex:0];
    }else if ([data isMemberOfClass:[LimbEntity class]]) {
        LimbEntity *limb  = (LimbEntity*)data;
        [MSGTansitionManager openLimbWithID:limb.lid withParams:nil];
    }else if([data isMemberOfClass:[WebAppEntity class]]){
        WebAppEntity *app = data;
        [MSGTansitionManager openWebApp:app withParams:nil goBack:nil callBack:nil];
    }else if([data isMemberOfClass:[DiyPageEntity class]]){
        
        DiyPageEntity *page = (DiyPageEntity*)data;
        [MSGTansitionManager openDiyPage:page withParams:nil];
        
    }else if([data isMemberOfClass:[PubEntity class]]){
        
        PubEntity *pub = (PubEntity*)data;
        [PubOpenHanddler openWithPubID:pub.pid placeholderView:nil];
        
    }else if([data isMemberOfClass:[BaseTabItemEntity class]]){
        
        BaseTabItemEntity *tab = (BaseTabItemEntity*)data;
        [tab doAction];
    }else if([data isMemberOfClass:[LeafEntity class]]){
        
        LeafEntity *leaf = (LeafEntity*)data;
        [MSGTansitionManager openLeafWithID:leaf.lid withParams:nil];
    }
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
