//
//  ProductController.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/4.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "ProductController.h"
#import "ProductBannerCell.h"
#import "ProductTitleCell.h"
#import "ProductCell.h"
#import "ShareCategoryView.h"
#import "ProductPriceCell.h"

static NSString *TitleIdenfire = @"Title";
static NSString *BannerIdenfire = @"Banner";
static NSString *ProductIdenfire = @"Product";


@interface ProductController ()<ProductCellDelegate,ShareCategoryViewDelegate>
{
    NSMutableArray *bannerDatas;
    NSMutableArray *products;
    NSDictionary *formData;
    NSMutableArray *createdGoods;
    PriceEntity *priceData;
}
@property(nonatomic,retain) NSMutableArray *deleteBannerDatas;
@property(nonatomic,retain) NSMutableArray *addBannerDatas;
@property(nonatomic,retain) NSMutableArray *deleteProducts;
@property(nonatomic,retain) NSMutableArray *addProducts;
@property(nonatomic,retain) NSMutableDictionary *titleData;

@property(nonatomic,retain) ShareCategoryView *shareCategoryView;
@end

@implementation ProductController

- (void)viewDidLoad {
    [super viewDidLoad];
    bannerDatas = [NSMutableArray new];
    products = [NSMutableArray new];
    _deleteBannerDatas = [NSMutableArray new];
    _addBannerDatas = [NSMutableArray new];
    _titleData = [NSMutableDictionary new];
    _shareCategoryView = [Utility nibWithName:@"ShareCategoryView" index:0];
    _shareCategoryView.delegate = self;
    _shareCategoryView.frame = self.view.bounds;
    priceData = [[PriceEntity alloc] init];
    if ([_type integerValue] == GoodsTypeEdite) {
        self.title = _pub.article.title;
        [_titleData setValue:_pub.article.title forKey:@"title"];
        priceData.curPrice = _pub.article.descr;
        priceData.prePrice = _pub.article.source;
        priceData.thumbnail = _pub.article.thumbnail;
        [bannerDatas addObjectsFromArray:_pub.article.images];
        [self getFormData:_pub.article.content];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)getFormData:(NSString*)xmlStr{
    
    NSString *pattern = @"form_id=[\"|'](.*?)[\"|']";
    __block NSString *formID = nil;
    [CBRegularExpressionManager itemIndexesWithPattern:pattern inString:xmlStr usingBlock:^(NSString *name,NSRange range,  NSInteger idx, BOOL *const stop) {
        CRLog(@"%@",name);
        NSString *patternStr = [name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        patternStr = [patternStr stringByReplacingOccurrencesOfString:@"'" withString:@""];
        NSArray *attrs = [patternStr componentsSeparatedByString:@"="];
        formID = CRArrayObject(attrs, 1);
    }];
    CRWeekRef(self);
    [MBProgressHUD showMessag:nil toView:AppWindow];
    [MSGRequestManager Get:kAPIFormData(formID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [MBProgressHUD hideAllHUDsForView:AppWindow animated:true];
        formData = data;
        NSArray *ctls = [data objectForKey:@"controls"];
        if (ctls) {
            NSArray *itemctls = [ctls[0] objectForKey:@"items_ctl"];
            if (itemctls.count>0) {
                [itemctls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([[obj valueForKey:@"type"] isEqualToString:@"Goods"]) {
                        ProductEntity *prd = [ProductEntity buildWithJson:itemctls[0]];
                        [products addObject:prd];
                    }
                }];
                [__self.tableView reloadData];
            }
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [MBProgressHUD hideAllHUDsForView:AppWindow animated:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    if (section == 0) {
        return 2;
    }
    if (section == 1||section == 3) {
        return 1;
    }
    if ([_type integerValue]== GoodsTypeEdite) {
        return products.count;
    }
    return products.count+1;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"轮播图";
    }
    if (section == 2) {
        return @"商品项";
    }
    return @"";
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        return 16 +floor((tableView.width - 70 )/5);
    }
    if (indexPath.section == 2) {
        if (indexPath.row<products.count) {
            return 288+16;
        }
        return 64;
    }
    if (indexPath.row == 1) {
        return 201;
    }
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ProductTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Title"];
            NSString *title = [_titleData valueForKey:@"title"];
            cell.titleView.text = title;
            cell.titleData = _titleData;
            return cell;
        }
        ProductPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Price"];
        cell.priceData = priceData;
        if ([_type integerValue] == GoodsTypeEdite) {
            [cell load:_pub.article.descr pre:_pub.article.source thumbnail:_pub.article.thumbnail.turl];
        }
        return cell;
     
    }
    if (indexPath.section == 1) {
        ProductBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Banner"];
        cell.datas = bannerDatas;
        cell.deleteDatas = _deleteBannerDatas;
        cell.addDatas = _addBannerDatas;
//        if ([_type integerValue] == GoodsTypeEdite) {
//            
//        }
        [cell.collectionView reloadData];
        return cell;
    }
    // Configure the cell...
    if (indexPath.section == 2) {
        if (indexPath.row<products.count) {
            ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Product"];
            ProductEntity *product = CRArrayObject(products, indexPath.row);
            cell.deleteButton.enabled = ([_type integerValue] != GoodsTypeEdite);
            cell.indexPath = indexPath;
            cell.delegate = self;
            [cell loadProduct:product];
            return cell;
        }
        ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddProduct"];
        return cell;
    }
    if ([_type integerValue] == GoodsTypeEdite) {
        ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Done"];
        return cell;
    }
    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Category"];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CRWeekRef(self);
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 2&&indexPath.row == products.count) {
        ProductEntity *prd = [[ProductEntity alloc] init];
        prd.isAdd = true;
        [products addObject:prd];
        [self.tableView reloadData];
    }else if (indexPath.section == 3){
        
        if ([_type integerValue] == GoodsTypeEdite) {
      
            if ([self checkParamslegal]) {
                
                if (![self checkProductsParams]) {
                    return;
                }
                [MBProgressHUD showMessag:nil toView:AppWindow];
                [self updateBannerForArticle:_pub.article.mid complete:^(BOOL result) {
                    [__self updateArtileInfo:^(BOOL result) {
                        [__self updateAllGoods:^(BOOL result) {
                            if (_completeCallBack) {
                                [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
                                _completeCallBack(result);
                            }
                        }];
                    }];
                }];
            }
            
        }else{
            _shareCategoryView.shop = _shop;
            [_shareCategoryView show];
        }
    }
}
-(void)categoryView:(ShareCategoryView *)categoryView clickLeaf:(LeafEntity *)leaf limb:(LimbEntity *)limb
{
    if (![self checkParamslegal]) {
        return;
    }
    if (![self checkProductsParams]) {
        return;
    }
    CRWeekRef(self);
    [MBProgressHUD showMessag:nil toView:AppWindow];
    __block BOOL productFinished = false;
    __block BOOL pubFinished = false;
    [__self createForm:^(BOOL result, NSDictionary *data) {
        formData = data;
        NSInteger fid = [[data valueForKey:@"id"] integerValue];
        CRLog(@"formid == %d",fid);
        [__self createListBox:^(BOOL result, NSDictionary *data) {
            if (data) {
                NSInteger boxID = [[data valueForKey:@"id"] integerValue];
                NSString *boxIDStr = CRString(@"%d",(int)boxID);
                CRLog(@"boxID == %d",boxID);

                [self createAllGoods:^(NSArray *prds) {
                    
                    [__self createPayButton:^(BOOL result, NSDictionary *data) {
                        NSString *bid = nil;
                        if (data) {
                            NSInteger idInteger = [[data valueForKey:@"id"] integerValue];
                            bid = CRString(@"%d",(int)idInteger);
                            CRLog(@"buttonId == %d",idInteger);

                        }
                        [__self linkAllGoods:prds toBox:boxIDStr complete:^(BOOL result) {
                            [__self linkBox:boxIDStr toForm:CRString(@"%d",(int)fid) complete:^(BOOL result) {
                                if (bid) {
                                    [__self linkPayButton:bid toForm:CRString(@"%d",(int)fid) complete:^(BOOL result) {
                                        productFinished = true;
                                        if (pubFinished) {
                                            //结束
                                            [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
                                            if (_completeCallBack) {
                                                _completeCallBack(true);
                                            }
                                        }
                                    }];
                                }else{
                                    productFinished = true;
                                    if (pubFinished) {
                                        //结束
                                        [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
                                        if (_completeCallBack) {
                                            _completeCallBack(true);
                                        }
                                    }
                                }
                            }];
                        }];
                        
                    }];
                    
                }];
            }else{
                productFinished = true;
                if (pubFinished) {
                    //结束
                    if (_completeCallBack) {
                        [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
                        _completeCallBack(true);
                    }
                }
            }
        }];
        if (formData) {
            [self createArtile:^(BOOL result,ArticleEntity*msg) {
                
                __block NSInteger finished = 0;
                [bannerDatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([bannerDatas count]==0){
                        NSDictionary *params = @{
                                                 @"article":CRString(@"%d",msg.mid),
                                                 @"leaf":CRString(@"%d",leaf.lid),
                                                 @"app":CRString(@"%d",kCurApp.aid),
                                                 };
                        [MSGRequestManager Post:kAPICreatePub params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                            //            PubEntity *pub = [PubEntity buildInstanceByJson:data];
                            pubFinished = true;
                            if (productFinished) {
                                //成功
                                if (_completeCallBack) {
                                    [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
                                    _completeCallBack(true);
                                }
                            }
                            
                        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                            [CustomToast showMessageOnWindow:msg];
                        }];

                        return ;
                    }
                    
                    KaokeImage *image = obj;
                    NSMutableDictionary *params  = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"descr",[NSString stringWithFormat:@"%d",image.oid],@"obj",nil];
                    
                    [MSGRequestManager MKUpdate:kAPILinkMsgMedia(msg.mid,@"image") params:params success:^(NSString *message, NSInteger code, id data, NSString *requestURL) {
                        finished ++;
                        if (finished == bannerDatas.count) {
                            NSDictionary *params = @{
                                                     @"article":CRString(@"%d",msg.mid),
                                                     @"leaf":CRString(@"%d",leaf.lid),
                                                     @"app":CRString(@"%d",kCurApp.aid),
                                                     };
                            [MSGRequestManager Post:kAPICreatePub params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                //            PubEntity *pub = [PubEntity buildInstanceByJson:data];
                                pubFinished = true;
                                if (productFinished) {
                                    //成功
                                    if (_completeCallBack) {
                                        [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
                                        _completeCallBack(true);
                                    }
                                }
                                
                            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                [CustomToast showMessageOnWindow:msg];
                            }];
                        }
                    } failed:^(NSString *message, NSInteger code, id data, NSString *requestURL) {
                        finished ++;
                        if (finished == bannerDatas.count) {
                            NSDictionary *params = @{
                                                     @"article":CRString(@"%d",msg.mid),
                                                     @"leaf":CRString(@"%d",leaf.lid),
                                                     @"app":CRString(@"%d",kCurApp.aid),
                                                     };
                            [MSGRequestManager Post:kAPICreatePub params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                //            PubEntity *pub = [PubEntity buildInstanceByJson:data];
                                pubFinished = true;
                                if (productFinished) {
                                    //成功
                                    if (_completeCallBack) {
                                        [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
                                        _completeCallBack(true);
                                    }
                                }
                                
                            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                [CustomToast showMessageOnWindow:msg];
                            }];
                        }
                    }];
                }];
                
            }];

        }else{
            [CustomToast showMessageOnWindow:@"创建失败"];
        }
    }];
    
  
}

-(BOOL)checkParamslegal{
    
    NSString *title = [_titleData valueForKey:@"title"];
    if ([title length]==0) {
        [CustomToast showMessageOnWindow:@"请输入标题"];
        [self.tableView scrollsToTop];
        return false;
    }else if([priceData.curPrice length]==0){
        [CustomToast showMessageOnWindow:@"请输入价格"];
        [self.tableView scrollsToTop];
        return false;
    }
    return true;
}


//创建投稿
-(void)createArtile:(void(^)(BOOL result,ArticleEntity *msg))complete{
    
    [MSGRequestManager Get:kAPIAllGroup params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (CRJSONIsArray(data)) {
            NSMutableArray *groups = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ArticleGroupEntity *group = [ArticleGroupEntity buildInstanceByJson:obj];
                [groups addObject:group];
            }];
            ArticleGroupEntity *group = groups[0];
            NSDictionary *params = nil;
            NSInteger formID = [[formData valueForKey:@"id"] integerValue];
            NSString *buttonTitle = @"立即购买";
            WebAppEntity *form = CRWebAppTitle(@"form");
            NSString *contentStr = CRString(@"<div class='shopinfo'><div webappid='%d' descr='' class='form' form_id='%d'></div><div class='price' descr='%@'></div></div><div class='content'></div>",form.aid,formID,buttonTitle);
            NSString *descr = priceData.curPrice?priceData.curPrice:@"";
            NSString *prePrice = priceData.prePrice?priceData.prePrice:@"";

            NSString *title = [_titleData valueForKey:@"title"];
            ThumbnailEntity *thumnail = priceData.thumbnail;
            if (thumnail) {
                params = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",contentStr,@"content",[NSString stringWithFormat:@"%d",group.gid],@"group",@"10",@"ctype",[NSString stringWithFormat:@"%d",thumnail.tid],@"thumbnail",descr,@"descr",prePrice,@"source",nil];
                
            }else{
                params = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",contentStr,@"content",[NSString stringWithFormat:@"%d",group.gid],@"group",@"10",@"ctype",descr,@"descr",prePrice,@"source",nil];
                
            }
            [MSGRequestManager Post:kAPIAllMsg params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                __block ArticleEntity *article = [ArticleEntity buildInstanceByJson:data];
                complete(true,article);
            
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                complete(false,nil);
            }];
            
        }else{
            [CustomToast showMessageOnWindow:@"获取分组信息失败"];
        }
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
    }];
    
}
//更新投稿
-(void)updateArtileInfo:(void(^)(BOOL result))complete{
    
    NSString *title = [_titleData valueForKey:@"title"];
    NSDictionary *params = nil;
    NSInteger formID = [[formData valueForKey:@"id"] integerValue];
    NSString *buttonTitle = @"立即购买";
    WebAppEntity *form = CRWebAppTitle(@"form");
    NSString *contentStr = CRString(@"<div class='shopinfo'><div webappid='%d' descr='' class='form' form_id='%d'></div><div class='price' descr='%@'></div></div><div class='content'></div>",form.aid,formID,buttonTitle);
    NSString *descr = priceData.curPrice?priceData.curPrice:@"";
    NSString *prePrice = priceData.prePrice?priceData.prePrice:@"";
    ThumbnailEntity *thumnail = priceData.thumbnail;
    if (thumnail) {
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",contentStr,@"content",[NSString stringWithFormat:@"%d",thumnail.tid],@"thumbnail",descr,@"descr",prePrice,@"source",nil];
    }else{
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",contentStr,@"content",descr,@"descr",prePrice,@"source",nil];
    }
    [MSGRequestManager MKUpdate:kAPIMSG(_pub.article.mid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
    {
        complete(true);
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        complete(false);
        
    }];
}
//创建轮播图
-(void)createBannersForArticle:(NSInteger)articleID complete:(void(^)(BOOL result))complete{
    
    __block NSInteger success = 0;
    __block NSInteger failed = 0;
    if (bannerDatas.count == 0) {
        complete(true);
        return;
    }
    for (KaokeImage *image in bannerDatas) {
        
        NSDictionary *params  = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"descr",[NSString stringWithFormat:@"%d",image.oid],@"obj",nil];
        [MSGRequestManager MKUpdate:kAPILinkMsgMedia(articleID,@"image") params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            CRLog(@"%@",data);
            success ++;
            if (success + failed == bannerDatas.count) {
                complete(true);
            }
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            failed ++;
            if (success + failed == bannerDatas.count) {
                BOOL result = success>0;
                complete(result);
            }
            CRLog(@"%@",msg);
        }];
    }
}
//更新播图
-(void)updateBannerForArticle:(NSInteger)articleID complete:(void(^)(BOOL result))complete{
    CRWeekRef(self);
    [self deleteImagesForArticle:articleID complete:^(BOOL result) {
        if (result) {
            [__self addImagesForArticle:articleID complete:^(BOOL result) {
                complete(result);
            }];
        }else{
            complete(result);
        }
    }];
    
}

-(void)deleteImagesForArticle:(NSInteger)articleID complete:(void(^)(BOOL result))complete{
    
    __block NSInteger success = 0;
    __block NSInteger failed = 0;
    if (_deleteBannerDatas.count==0) {
        complete(true);
        return;
    }
    for (KaokeImage *image in _deleteBannerDatas) {
        
        [MSGRequestManager MKDelete:kAPIRemoveMsgMedia(articleID,@"image",image.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            success ++;
            if (success + failed == _deleteBannerDatas.count) {
                complete(true);
            }
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            failed ++;
            if (success + failed == _deleteBannerDatas.count) {
                BOOL result = success>0;
                complete(result);
            }
            CRLog(@"%@",msg);
        }];
    }
    
    
}
-(void)addImagesForArticle:(NSInteger)articleID complete:(void(^)(BOOL result))complete{
    
    __block NSInteger success = 0;
    __block NSInteger failed = 0;
    if (_addBannerDatas.count == 0) {
        complete(true);
        return;
    }
    for (KaokeImage *image in _addBannerDatas) {
        
        NSDictionary *params  = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"descr",[NSString stringWithFormat:@"%d",image.oid],@"obj",nil];
        [MSGRequestManager MKUpdate:kAPILinkMsgMedia(articleID,@"image") params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            CRLog(@"%@",data);
            success ++;
            if (success + failed >= _addBannerDatas.count) {
                complete(true);
            }
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            failed ++;
            if (success + failed >= _addBannerDatas.count) {
                BOOL result = success>0;
                complete(result);
            }
            CRLog(@"%@",msg);
        }];
    }

}
-(void)createAllGoods:(void(^)(NSArray *goods))complete{
    
    CRWeekRef(self);
    __block NSInteger finished = 0;
    __block NSMutableArray *prds = [NSMutableArray new];
    if (products.count == 0) {
        complete(nil);
        return;
    }
    [products enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ProductEntity *prd = obj;
        [__self createGoods:prd complete:^(BOOL result,ProductEntity*prd) {
            finished ++;
            if (prd) {
                [prds addObject:prd];
            }
            if (finished >= products.count) {
                complete(prds);
            }
        }];
    }];
    
}
-(BOOL)checkProductsParams{
    
    CRWeekRef(self);
    __block BOOL result = true;
    __block NSInteger index;
    [products enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ProductEntity *prd = obj;
        if ([prd.title length]==0) {
            [CustomToast showMessageOnWindow:@"请输入商品名称"];
            result = false;
            index = idx;
            *stop = true;
        }else if([prd.price length]==0){
            [CustomToast showMessageOnWindow:@"请输入商品价格"];
            result = false;
            index = idx;
            *stop = true;
        }else if([prd.stock length]==0){
            [CustomToast showMessageOnWindow:@"请输入商品库存"];
            result = false;
            index = idx;
            *stop = true;
        }
    }];
    if (!result) {
        [__self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:2] atScrollPosition:UITableViewScrollPositionMiddle animated:true];
    }
    return result;
}
-(void)updateAllGoods:(void(^)(BOOL result))complete{
    if (products.count == 0) {
        complete(true);
        return;
    }
    __block NSInteger finished = 0;
    CRWeekRef(self);
    [products enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ProductEntity *prd = obj;
        [__self updateGoods:prd complete:^(BOOL result) {
            finished ++;
            if (finished >= products.count) {
                complete(true);
            }
        }];
    }];
    
}

//创建表单
-(void)createForm:(void(^)(BOOL result,NSDictionary *data))complete{
    
    /*
     desc:
     title:发的萨芬范德萨是否的打法
     master:kk_xyym
     status:open
     appid:34
     record_readonly:true
     image:
     shopstore_id:34
     */
    
    [MSGRequestManager Post:kAPIForm params:@{
                                              /*这里是desc不是descr，对这个字段表示无语，坑了多少人*/
                                                  @"desc":@" ",
                                                  @"title":[_titleData valueForKey:@"title"],
                                                  @"master":kCurUser.userName,
                                                  @"status":@"open",
                                                  @"appid":CRString(@"%d",kCurApp.aid),
                                                  @"record_readonly":@"true",
                                                  @"image":@" ",
                                                  @"shopstore_id":CRString(@"%d",_shop.sid)
                                                  
                                              }success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                  
                                                  NSLog(@"%@",data);
                                                  complete(true,data);
                                                  
                                              } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                  NSLog(@"%@",msg);
                                                  complete(false,nil);
                                              }];

}
//创建listBox
-(void)createListBox:(void(^)(BOOL result,NSDictionary *data))complete{
    
    /*
     title:范德萨范德萨
     isrequire:false
     columns:1
     descr:
     shopstore_id:34
     */
    NSString *title = [_titleData valueForKey:@"title"];
    NSDictionary *params = @{
                             
                             @"descr":@"listbox",
                             @"title":title,
                             @"columns":@"1",
                             @"isrequire":@"false",
                             @"shopstore_id":CRString(@"%d",_shop.sid)
                             
                             };
    
    [MSGRequestManager Post:kAPIFormListBox params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {

                                                  NSLog(@"%@",data);
                                                  complete(true,data);
                                                  
                                              } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                  NSLog(@"%@",msg);
                                                  complete(false,nil);
                                              }];

}
//创建Goods
-(void)createGoods:(ProductEntity*)product complete:(void(^)(BOOL result,ProductEntity*prd))complete{
    
    /*
     title:111111
     check_type:CheckBox
     price:11111
     stock:100000
     total:100000
     descr:111111
     pay_type:money
     remain:1    //剩余总数是否显示
     unit:
     shopstore_id:34
     */
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                    
                                                                                    @"check_type":@"CheckBox",
                                                                                    @"title":product.title,
                                                                                    @"price":product.price,
                                                                                    @"stock":CRString(@"%@",product.stock),
                                                                                    @"descr":product.descr?product.descr:@"",
                                                                                    @"total":CRString(@"%@",product.stock),
                                                                                    @"unit":@"￥",
                                                                                    @"pay_type":@"money",
                                                                                    @"remain":@"true",
                                                                                    @"shopstore_id":CRString(@"%d",_shop.sid)
                                                                                    
                                                                                    }];
    if (product.img_url) {
        [params addEntriesFromDictionary:@{@"img_url":product.img_url}];
    }
    
    [MSGRequestManager Post:kAPIFormGoods params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                         NSLog(@"%@",data);
                                                         ProductEntity *prd = [ProductEntity buildWithJson:data];
                                                         complete(true,prd);
                                                         
                                                     } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                         NSLog(@"%@",msg);
                                                         complete(false,nil);
                                                     }];

}
//更新Goods
-(void)updateGoods:(ProductEntity*)product complete:(void(^)(BOOL result))complete{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                    
                                                                                    @"check_type":@"CheckBox",
                                                                                    @"title":product.title,
                                                                                    @"price":product.price,
                                                                                    @"stock":CRString(@"%@",product.stock),
                                                                                    @"descr":product.descr,
                                                                                    @"total":CRString(@"%@",product.stock),
                                                                                    @"unit":@"￥",
                                                                                    @"pay_type":@"money",
                                                                                    @"remain":@"true",
                                                                                    @"shopstore_id":CRString(@"%d",_shop.sid)
                                                                                    
                                                                                    }];
    if (product.img_url) {
        [params addEntriesFromDictionary:@{@"img_url":product.img_url}];
    }
    [MSGRequestManager MKUpdate:kAPIGoods(product.pid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                       
                                                       complete(true);
                                                       
                                                   } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                       complete(false);

                                                   }];
    
}
//创建PayButton
-(void)createPayButton:(void(^)(BOOL result,NSDictionary *data))complete{
    
    /*
     title:支付
     hasaddr:true
     paydelivery:false //货到付款
     points:0   //积分
     shopstore_id:34
     */
    NSString *title = [_titleData valueForKey:@"title"];
    [MSGRequestManager Post:kAPIFormPaybtn params:@{
                                                     
                                                     @"hasaddr":@"true",
                                                     @"title":title,
                                                     @"paydelivery":@"false",
                                                     @"points":@"0",
                                                     @"shopstore_id":CRString(@"%d",_shop.sid)
                                                     
                                                     }success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                         
                                                         NSLog(@"%@",data);
                                                         complete(true,data);
                                                         
                                                     } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                         NSLog(@"%@",msg);
                                                         complete(false,nil);
                                                     }];

}
//关联listBox
-(void)linkBox:(NSString*)boxID toForm:(NSString*)formID complete:(void(^)(BOOL result))complete{
   
    
    /*
     type:ListBox
     ctl_id:2124
     form_id:3610
     shopstore_id:34
     */
    [MSGRequestManager Post:kAPIFormCtl params:@{
                                                    @"type":@"ListBox",
                                                    @"ctl_id":boxID,
                                                    @"form_id":formID,
                                                    @"shopstore_id":CRString(@"%d",_shop.sid)
                                                    
                                                    }success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                        
                                                        NSLog(@"%@",data);
                                                        complete(true);
                                                        
                                                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                        NSLog(@"%@",msg);
                                                        complete(false);
                                                    }];

    
}
//关联PayButton
-(void)linkPayButton:(NSString*)PayButtonID toForm:(NSString*)formID complete:(void(^)(BOOL result))complete{
    
    
    
    /*
     type:ListBox
     ctl_id:2122
     form_id:3595
     shopstore_id:34
     */
    CRLog(@"PayButtonID == %d, formID == %d",PayButtonID,formID);

    [MSGRequestManager Post:kAPIFormCtl params:@{
                                                    
                                                    @"type":@"PayButton",
                                                    @"ctl_id":PayButtonID,
                                                    @"form_id":formID,
                                                    @"shopstore_id":CRString(@"%d",_shop.sid)
                                                    
                                                    }success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                        
                                                        NSLog(@"%@",data);
                                                        complete(true);
                                                        
                                                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                        NSLog(@"%@",msg);
                                                        complete(false);
                                                    }];
    
    
}
//关联Goods
-(void)linkGoods:(NSString*)goodsID toBox:(NSString*)boxID complete:(void(^)(BOOL result))complete{
    /*
     type:goods
     ctl_id:2439
     shopstore_id:34
     */
    CRLog(@"goodsID == %@, boxID == %@",goodsID,boxID);

    [MSGRequestManager Post:kAPIBoxAddItem(boxID) params:@{
                                                           @"type":@"goods",
                                                           @"ctl_id":goodsID,
                                                           @"shopstore_id":CRString(@"%d",_shop.sid)
                                                           }success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                               NSLog(@"%@",data);
                                                               complete(true);

                                                           } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                                               NSLog(@"%@",msg);
                                                               complete(false);
                                                           }];
    
    
    
}
-(void)linkAllGoods:(NSArray*)goods toBox:(NSString*)boxID complete:(void(^)(BOOL result))complete{
    
    if (goods.count == 0) {
        complete(true);
        return;
    }
    CRWeekRef(self);
    __block NSInteger finished = 0;
    [goods enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ProductEntity *prd = obj;
        CRLog(@"goodID == %d, boxID == %@",prd.pid,boxID);
        [__self linkGoods:CRString(@"%d",prd.pid) toBox:boxID complete:^(BOOL result) {
            finished++;
            if (finished >= goods.count) {
                complete(true);
            }
        }];
    }];

}
-(void)deleteItem:(NSIndexPath *)index
{
    ProductEntity *prd = [products objectAtIndex:index.row];
    if (!prd.isAdd) {
        [_deleteProducts addObject:prd];
    }else{
        [_addProducts removeObject:prd];
    }
    [products removeObject:prd];
    [self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation ProductEntity

+(instancetype)buildWithJson:(NSDictionary*)json{
    
    ProductEntity *entity = [[ProductEntity alloc] init];
    entity.check_type = [Utility dictionaryNullValue:json forKey:@"check_type"];
    entity.descr = [Utility dictionaryNullValue:json forKey:@"descr"];
    entity.pid = [[Utility dictionaryNullValue:json forKey:@"id"] integerValue];
    entity.img_url = [Utility dictionaryNullValue:json forKey:@"img_url"];
    entity.pay_type = [Utility dictionaryNullValue:json forKey:@"pay_type"];
    entity.price = CRString(@"%@",[Utility dictionaryNullValue:json forKey:@"price"]);
    entity.remain = [[Utility dictionaryNullValue:json forKey:@"remain"] boolValue];
    entity.stock = CRString(@"%@",[Utility dictionaryNullValue:json forKey:@"stock"]);
    entity.title = [Utility dictionaryNullValue:json forKey:@"title"];
    entity.total = [Utility dictionaryNullValue:json forKey:@"total"];
    entity.type = [Utility dictionaryNullValue:json forKey:@"type"];
    entity.unit = [Utility dictionaryNullValue:json forKey:@"unit"];
    return entity;
}

@end
@implementation PriceEntity


@end
