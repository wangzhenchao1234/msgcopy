//
//  DeskTopItemModaul.h
//  Kaoke
//
//  Created by xiaogu on 13-12-31.
//
//

#import <Foundation/Foundation.h>

@interface DeskTopItemModaul : NSObject
@property (nonatomic,copy  ) NSString  *title;
@property (nonatomic,assign) NSInteger size;
@property (nonatomic,retain) NSArray   *imageUrls;
@property (nonatomic,retain) NSArray   *subTitles;
@end
