//
//  EmotionManager.h
//  Kaoke
//
//  Created by 谷少坤 on 13-10-10.
//
//

#import <Foundation/Foundation.h>

@interface EmotionManager : NSObject
+(NSArray*)emotions;
+(NSString *)emotionForKey:(NSString *)key;
@end
