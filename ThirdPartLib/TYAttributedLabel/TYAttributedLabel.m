//
//  TYAttributedLabel.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAttributedLabel.h"
#import <CoreText/CoreText.h>

// 文本颜色
#define kTextColor       [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kSelectAreaColor [UIColor colorWithRed:204/255.0 green:211/255.0 blue:236/255.0 alpha:1]
#define kCursorColor     [UIColor colorWithRed:28/255.0 green:107/255.0 blue:222/255.0 alpha:1]

NSString *const kTYTextRunAttributedName = @"TYTextRunAttributedName";

@interface TYAttributedLabel ()
{
    struct {
        unsigned int textStorageClicked :1;
    }_delegateFlags;
    
    CTFramesetterRef            _framesetter;
    CTFrameRef                  _frameRef;
    NSInteger                   _replaceStringNum;   // 图片替换字符数
}
@property (nonatomic, strong)   NSMutableAttributedString   *attString;         // 文字属性
@property (nonatomic, strong)   NSMutableArray              *textStorageArray;  // run数组
@property (nonatomic,strong)    NSDictionary                *runRectDictionary; // runRect字典
@property (nonatomic, strong)   UITapGestureRecognizer      *singleTap;         // 点击手势

@end

@implementation TYAttributedLabel

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupProperty];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperty];
    }
    return self;
}

#pragma mark - getter

- (NSMutableArray *)textStorageArray
{
    if (_textStorageArray == nil) {
        _textStorageArray = [NSMutableArray array];
    }
    return _textStorageArray;
}

- (NSString *)text{
    return _attString.string;
}

- (NSAttributedString *)attributedText
{
    return _attString;
}

#pragma mark - setter
- (void)setupProperty
{
    if (self.backgroundColor == nil) {
        self.backgroundColor = [UIColor whiteColor];
    }
    self.userInteractionEnabled = NO;
    _font = [UIFont systemFontOfSize:15];
    _characterSpacing = 1;
    _linesSpacing = 5;
    _textAlignment = kCTLeftTextAlignment;
    _lineBreakMode = kCTLineBreakByCharWrapping;
    _textColor = kTextColor;
    _replaceStringNum = 0;
}

- (void)setDelegate:(id<TYAttributedLabelDelegate>)delegate
{
    if (delegate == _delegate)  return;
    _delegate = delegate;
    
    _delegateFlags.textStorageClicked = [delegate respondsToSelector:@selector(attributedLabel:textStorageClicked:)];
}

- (void)setText:(NSString *)text
{
    _attString = [self createTextAttibuteStringWithText:text];
    [self resetAllAttributed];
    [self resetFramesetter];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _attString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    [self resetAllAttributed];
    [self resetFramesetter];
}

- (void)setTextColor:(UIColor *)textColor
{
    if (textColor && _textColor != textColor){
        _textColor = textColor;
        
        [_attString addAttributeTextColor:textColor];
        [self resetFramesetter];
    }
}

- (void)setFont:(UIFont *)font
{
    if (font && _font != font){
        _font = font;
        
        [_attString addAttributeFont:font];
        [self resetFramesetter];
    }
}

- (void)setCharacterSpacing:(unichar)characterSpacing
{
    if (characterSpacing && _characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
        
        [_attString addAttributeCharacterSpacing:characterSpacing];
        [self resetFramesetter];
    }
}

- (void)setLinesSpacing:(CGFloat)linesSpacing
{
    if (linesSpacing > 0 && _linesSpacing != linesSpacing) {
        _linesSpacing = linesSpacing;
        
        [_attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFramesetter];
    }
}

- (void)setTextAlignment:(CTTextAlignment)textAlignment
{
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        
        [_attString addAttributeAlignmentStyle:textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFramesetter];
    }
}

#pragma mark - add textStorage
- (void)addTextStorage:(id<TYTextStorageProtocol>)textStorage
{
    if (textStorage) {
        [self.textStorageArray addObject:textStorage];
    }
}

- (void)addTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        for (id<TYTextStorageProtocol> textStorage in textStorageArray) {
            if ([textStorage conformsToProtocol:@protocol(TYTextStorageProtocol)]) {
                [self addTextStorage:textStorage];
            }
        }
        [self resetFramesetter];
    }
}

- (void)resetAllAttributed
{
    _runRectDictionary = nil;
    _textStorageArray = nil;
    _replaceStringNum = 0;
    [self removeSingleTapGesture];
}

#pragma mark reset framesetter
- (void)resetFramesetter
{
    if (_framesetter){
        CFRelease(_framesetter);
        _framesetter = nil;
    }
    
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
    
    [self setNeedsDisplay];
}

- (void)updateFramesetterIfNeeded
{
    // 是否更新了内容
    if (_framesetter == nil) {
        
        // 添加文本run属性
        [self addTextStoragesWithAtrributedString:_attString];
        
        _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attString);
        
    }
}

#pragma mark - create text attibuteString
- (NSMutableAttributedString *)createTextAttibuteStringWithText:(NSString *)text
{
    if (text.length <= 0) {
        return [[NSMutableAttributedString alloc]init];
    }
    // 创建属性文本
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:text];
    
    // 添加文本颜色 字体属性
    [self addTextColorAndFontWithAtrributedString:attString];
    
    // 添加文本段落样式
    [self addTextParaphStyleWithAtrributedString:attString];
    
    return attString;
}

// 添加文本颜色 字体属性
- (void)addTextColorAndFontWithAtrributedString:(NSMutableAttributedString *)attString
{
    // 添加文本字体
    [attString addAttributeFont:_font];
    
    // 添加文本颜色
    [attString addAttributeTextColor:_textColor];
    
}

// 添加文本段落样式
- (void)addTextParaphStyleWithAtrributedString:(NSMutableAttributedString *)attString
{
    // 字体间距
    if (_characterSpacing)
    {
        [attString addAttributeCharacterSpacing:_characterSpacing];
    }
    
    // 添加文本段落样式
    [attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
}

#pragma mark -  add text storage atrributed
- (void)addTextStoragesWithAtrributedString:(NSMutableAttributedString *)attString
{
    if (attString && _textStorageArray.count > 0) {
        
        // 排序range
        [self sortTextStorageArray:_textStorageArray];
        
        NSMutableArray *drawStorageArray = [NSMutableArray array];
        for (id<TYTextStorageProtocol> textStorage in _textStorageArray) {
            
            // 修正图片替换字符来的误差
            if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol) ]) {
                [drawStorageArray addObject:textStorage];
                continue;
            }
            
            // 验证范围
            if (NSMaxRange(textStorage.range) <= attString.length) {
                [textStorage addTextStorageWithAttributedString:attString];
            }
            
        }
        [_textStorageArray removeAllObjects];
        
        for (id<TYDrawStorageProtocol> drawStorage in drawStorageArray) {
            NSInteger currentLenght = _attString.length;
            [drawStorage setOwnerView:self];
            [drawStorage addTextStorageWithAttributedString:attString];
            _replaceStringNum += currentLenght - _attString.length;
        }
    }
}

- (void)sortTextStorageArray:(NSMutableArray *)textStorageArray
{
    [textStorageArray sortUsingComparator:^NSComparisonResult(id<TYTextStorageProtocol> obj1, id<TYTextStorageProtocol> obj2) {
        if (obj1.range.location < obj2.range.location) {
            return NSOrderedAscending;
        } else if (obj1.range.location > obj2.range.location){
            return NSOrderedDescending;
        }else {
            return obj1.range.length > obj2.range.length ? NSOrderedAscending:NSOrderedDescending;
        }
    }];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    
    if (_attString == nil) {
        return;
    }

    //	跟很多底层 API 一样，Core Text 使用 Y翻转坐标系统，而且内容的呈现也是上下翻转的，所以需要通过转换内容将其翻转
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // CTFramesetter 是使用 Core Text 绘制时最重要的类。它管理您的字体引用和文本绘制帧。这里在 framesetter 之后通过一个所选的文本范围（这里我们选择整个文本）与需要绘制到的矩形路径创建一个帧。
    [self updateFramesetterIfNeeded];
    
    if (_frameRef == nil) {
        _frameRef = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_attString length]), path, NULL);
    }
    
    CTFrameDraw(_frameRef, context);	// CTFrameDraw 将 frame 描述到设备上下文

    // 画其他元素
    [self drawTextStorageWithFrame:_frameRef context:context];
    
    CFRelease(path);
}

#pragma mark - drawTextStorage
- (void)drawTextStorageWithFrame:(CTFrameRef)frame context:(CGContextRef)context
{
    // 获取每行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    
    NSMutableDictionary *runRectDictionary = [NSMutableDictionary dictionary];
    // 获取每行有多少run
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        // 获得每行的run
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            // run的属性字典
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            id<TYTextStorageProtocol> textStorage = [attributes objectForKey:kTYTextRunAttributedName];
            if (textStorage) {
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                
                if (viewWidth > 0 && runWidth > viewWidth) {
                    runWidth  = viewWidth;
                }
                CGRect runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runWidth, runAscent + runDescent);
                
                if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
                    [(id<TYDrawStorageProtocol>)textStorage drawStorageWithRect:runRect];
                }
                
                [runRectDictionary setObject:textStorage forKey:[NSValue valueWithCGRect:runRect]];
                
            }

        }
    }
    
    if (runRectDictionary.count > 0) {
        // 添加响应点击rect
        [self addRunRectDictionary:[runRectDictionary copy]];
    }
}

// 添加响应点击rect
- (void)addRunRectDictionary:(NSDictionary *)runRectDictionary
{
    if (runRectDictionary.count < _runRectDictionary.count) {
        NSMutableArray *drawStorageArray = [[_runRectDictionary allValues]mutableCopy];
        // 剔除已经画出来的
        [drawStorageArray removeObjectsInArray:[runRectDictionary allValues]];
        
        // 遍历不会画出来的
        for (id<TYTextStorageProtocol>drawStorage in drawStorageArray) {
            if ([drawStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]
                && [drawStorage respondsToSelector:@selector(didNotDrawRun)]) {
                [(id<TYDrawStorageProtocol>)drawStorage didNotDrawRun];
            }
        }
    }
    
    _runRectDictionary = runRectDictionary;
    [self addSingleTapGesture];
}

#pragma mark - add tapGesture
- (void)addSingleTapGesture
{
    if (_singleTap == nil) {
        self.userInteractionEnabled = YES;
        //单指单击
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        //手指数
        _singleTap.numberOfTouchesRequired = 1;
        //点击次数
        _singleTap.numberOfTapsRequired = 1;
        //增加事件者响应者，
        [self addGestureRecognizer:_singleTap];
    }
}

- (void)removeSingleTapGesture
{
    if (_singleTap) {
        [self removeGestureRecognizer:_singleTap];
        _singleTap = nil;
    }
}

#pragma mark - singleTap action
- (void)singleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
        // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    
    __typeof (self) __weak weakSelf = self;
    // 遍历run位置字典
    [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYTextStorageProtocol> obj, BOOL *stop) {
        
        CGRect imgRect = [keyRectValue CGRectValue];
        CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
        // point 是否在rect里
        if(CGRectContainsPoint(rect, point)){
            NSLog(@"点击了 textStorage ");
            // 调用代理
            if (_delegateFlags.textStorageClicked) {
                [_delegate attributedLabel:weakSelf textStorageClicked:obj];
                *stop = YES;
            }
        }
    }];
}

#pragma mark - get Right Height
- (int)getHeightWithWidth:(CGFloat)width
{
    if (_attString == nil) {
        return 0;
    }
    
    // 是否需要更新frame
    [self updateFramesetterIfNeeded];
    
    // 获得建议的size
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width,MAXFLOAT), NULL);
    
    return ceilf(suggestedSize.height)+1;
}

- (void)sizeToFit
{
    [super sizeToFit];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = [self getHeightWithWidth:width];
    return CGSizeMake(width, height);
}

#pragma mark - set right frame
- (void)setFrameWithOrign:(CGPoint)orign Width:(CGFloat)width
{
    // 获得高度
    int height = [self getHeightWithWidth:width];
    
    // 设置frame
    [self setFrame:CGRectMake(orign.x, orign.y, width, height)];
}

- (void)dealloc
{
    if (_framesetter != nil) {
        CFRelease(_framesetter);
    }
    
    if (_frameRef != nil) {
        CFRelease(_frameRef);
    }
    _attString = nil;
}

@end


#pragma mark - append attributedString

@implementation TYAttributedLabel (AppendAttributedString)

- (void)appendText:(NSString *)text
{
    NSAttributedString *attributedText = [self createTextAttibuteStringWithText:text];
    [self appendTextAttributedString:attributedText];
}

- (void)appendTextAttributedString:(NSAttributedString *)attributedText
{
    if (_attString == nil) {
        _attString = [[NSMutableAttributedString alloc]init];
    }
    [_attString appendAttributedString:attributedText];
    [self resetFramesetter];
}

- (void)appendTextStorage:(id<TYAppendTextStorageProtocol>)textStorage
{
    if (textStorage) {
        if ([textStorage conformsToProtocol:@protocol(TYDrawStorageProtocol)]) {
            [(id<TYDrawStorageProtocol>)textStorage setOwnerView:self];
        }
        [self appendTextAttributedString:[textStorage appendTextStorageAttributedString]];
    }
}

- (void)appendTextStorageArray:(NSArray *)textStorageArray
{
    if (textStorageArray) {
        for (id<TYAppendTextStorageProtocol> textStorage in textStorageArray) {
            if ([textStorage conformsToProtocol:@protocol(TYAppendTextStorageProtocol)]) {
                [self appendTextStorage:textStorage];
            }
        }
        [self resetFramesetter];
    }
}

@end

