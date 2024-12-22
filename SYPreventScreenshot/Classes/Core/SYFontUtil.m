//
//  SYFontUtil.m
//  SYPreventScreenshot
//
//  Created by SyNvNX on 2024/12/17.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYFontUtil.h"
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@implementation SYFontUtilUtil

+ (BOOL)isSupportedTextStyle:(UIFontTextStyle)style {
    static dispatch_once_t onceToken;
    static NSSet *_set = nil;
    dispatch_once(&onceToken, ^{
      NSArray *array = @[];
      if (@available(iOS 11.0, *)) {
          array = @[
              UIFontTextStyleLargeTitle, UIFontTextStyleTitle1,
              UIFontTextStyleTitle2, UIFontTextStyleTitle3,
              UIFontTextStyleHeadline, UIFontTextStyleSubheadline,
              UIFontTextStyleBody, UIFontTextStyleCallout,
              UIFontTextStyleFootnote, UIFontTextStyleCaption1,
              UIFontTextStyleCaption2
          ];
      } else {
          array = @[
              UIFontTextStyleTitle1, UIFontTextStyleTitle2,
              UIFontTextStyleTitle3, UIFontTextStyleHeadline,
              UIFontTextStyleSubheadline, UIFontTextStyleBody,
              UIFontTextStyleCallout, UIFontTextStyleFootnote,
              UIFontTextStyleCaption1, UIFontTextStyleCaption2
          ];
      }
      _set = [NSSet setWithArray:array];
    });
    return [_set containsObject:style];
}

+ (UIFont *)fontAdjustedUsingFont:(UIFont *)font
                  traitCollection:(UITraitCollection *)col {
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    UIFontTextStyle style =
        [fontDescriptor objectForKey:UIFontDescriptorTextStyleAttribute];
    if (style && [self isSupportedTextStyle:style]) {
        return [UIFont preferredFontForTextStyle:style
                   compatibleWithTraitCollection:col];
    }

    return font;
}

@end
