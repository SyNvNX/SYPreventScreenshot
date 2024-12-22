//
//  SYFontUtil.m
//
// Copyright (c) 2024 SyNvNX (https://github.com/SyNvNX)
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
