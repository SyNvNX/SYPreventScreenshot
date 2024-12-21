//
//  SYFontUtil.h
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/17.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYFontUtilUtil : NSObject
+ (UIFont *)fontAdjustedUsingFont:(UIFont *)font
                  traitCollection:(UITraitCollection *)col;
@end

NS_ASSUME_NONNULL_END
