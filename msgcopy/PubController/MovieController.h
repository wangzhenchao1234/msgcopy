//
//  MovieController.h
//  msgcopy
//
//  Created by wngzc on 15/7/1.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "KxMovieDecoder.h"
#import "KxAudioManager.h"
#import "KxMovieGLView.h"

@interface MovieController : UIViewController

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters title:(NSString*)title;
@end
