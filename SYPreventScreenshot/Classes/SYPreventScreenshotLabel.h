//
//  SYPreventScreenshotLabel.h
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/16.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYPreventScreenshotLabel : UIView
- (instancetype)initWithAttributeText:
    (nullable NSAttributedString *)attributeText;

- (instancetype)initWithText:(nullable NSString *)text;

@property(copy, nonatomic, nullable) NSAttributedString *attributedText;
@property(copy, nonatomic, nullable) IBInspectable NSString *text;
@property(nonatomic, assign) BOOL placeholderTextEnabled;
@property(nonatomic, assign) BOOL hideContentEnabled;
@end

NS_ASSUME_NONNULL_END
