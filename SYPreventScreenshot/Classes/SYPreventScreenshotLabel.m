//
//  SYPreventScreenshotLabel.m
//  SYPreventScreenshot
//
//  Created by sy on 2024/12/16.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYPreventScreenshotLabel.h"
#import "SYFontUtil.h"
#import "SYPreventScreenshotImageView.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

@interface SYPreventScreenshotLabel ()

@property(nonatomic, strong)
    NSLayoutConstraint *preventViewImageViewBottomConstraint;
@property(nonatomic, strong)
    NSLayoutConstraint *preventViewImageViewTrailingConstraint;
@property(nonatomic, strong) SYPreventScreenshotImageView *preventViewImageView;
@property(nonatomic, assign) CGRect usedRect;
@property(nonatomic, strong) NSTextContainer *textContainer;
@property(nonatomic, strong) NSLayoutManager *layoutManager;
@property(nonatomic, strong) NSTextStorage *textStorage;
@property(nonatomic, assign) BOOL adjustsFontForContentSizeCategory;
@property(nonatomic, readonly, assign) NSError *error;
@property(nonatomic, readonly, assign)
    SYPreventScreenshotImageViewStatus status;
@property(nonatomic, readonly, assign) UIView *screenCaptureView;
@property(nonatomic, readonly, getter=isCaptured) BOOL captured;
@property(nonatomic, assign) CGSize originContainerSize;
@property(nonatomic, strong) UILabel *placeholderLabel;

@end

IB_DESIGNABLE
@implementation SYPreventScreenshotLabel

- (instancetype)initWithAttributeText:(NSAttributedString *)attributeText {
    if (self = [super initWithFrame:CGRectZero]) {
        [self setUp];
        self.attributedText = attributeText;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text {
    __auto_type attr = [self.class _attributedTextFromText:text];
    return [[SYPreventScreenshotLabel alloc] initWithAttributeText:attr];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setUp];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGRect usedRect = self.usedRect;
    BOOL isNull = CGRectIsNull(usedRect);
    BOOL isEmpty = CGRectIsEmpty(usedRect);
    CGFloat scale = UIScreen.mainScreen.scale;
    if (isNull || isEmpty) {
        [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
        usedRect =
            [self.layoutManager usedRectForTextContainer:self.textContainer];
    }
    usedRect.size.width = ceil(usedRect.size.width * scale) / scale;
    return usedRect.size;
}

- (void)setHideContentEnabled:(BOOL)hideContentEnabled {
    _hideContentEnabled = hideContentEnabled;
    self.preventViewImageView.hideContentEnabled = hideContentEnabled;
}

- (SYPreventScreenshotImageViewStatus)status {
    return self.preventViewImageView.status;
}

- (void)setAdjustsFontForContentSizeCategory:
    (BOOL)adjustsFontForContentSizeCategory {
    if (_adjustsFontForContentSizeCategory !=
        adjustsFontForContentSizeCategory) {
        _adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory;
        [self _adjustPreferredFontForCurrentContentSizeCategory];
    }
}

- (void)setOpaque:(BOOL)opaque {
    BOOL isOpaque = self.isOpaque;
    [super setOpaque:opaque];
    self.preventViewImageView.canShowScreenCaptureView = opaque;
    if (isOpaque != opaque) {
        [self invalidatePreventView];
    }
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    UILabel *label = [[UILabel alloc] init];
    [self addSubview:label];
    label.attributedText = self.attributedText;
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = NO;

    NSArray<NSLayoutConstraint *> *constraints = @[
        [label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [label.trailingAnchor
            constraintLessThanOrEqualToAnchor:self.trailingAnchor],
        [label.topAnchor constraintEqualToAnchor:self.topAnchor],
        [label.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor]
    ];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (NSString *)text {
    return self.textStorage.string;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __auto_type pre = previousTraitCollection.preferredContentSizeCategory;
    __auto_type cur = self.traitCollection.preferredContentSizeCategory;
    BOOL isEqual = [pre isEqualToString:cur];
    if (!isEqual) {
        [self _adjustPreferredFontForCurrentContentSizeCategory];
    }
    if (@available(iOS 13.0, *)) {
        BOOL diff = [self.traitCollection
            hasDifferentColorAppearanceComparedToTraitCollection:
                previousTraitCollection];
        if (diff) {
            [self _invalidateIfResolvedColorDidChange:previousTraitCollection];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat scale = UIScreen.mainScreen.scale;
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat width = floor(viewWidth * scale) / scale;
    CGFloat height = self.bounds.size.height;
    self.textContainer.size = CGSizeMake(width, 0);
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    CGRect usedRect =
        [self.layoutManager usedRectForTextContainer:self.textContainer];
    usedRect.size.width = ceil(usedRect.size.width);
    if (usedRect.size.width != self.usedRect.size.width ||
        usedRect.size.height != self.usedRect.size.height) {
        self.usedRect = usedRect;
        CGFloat maxX = CGRectGetMaxX(usedRect);
        CGFloat maxY = CGRectGetMaxY(usedRect);
        BOOL useAVPlayer = [SYPreventScreenshotImageView useAVPlayer];
        BOOL isOpaque = self.isOpaque;
        if (usedRect.size.width == 0) {
            usedRect.size.width = DBL_MIN;
        }

        if (usedRect.size.height == 0) {
            usedRect.size.height = DBL_MIN;
        }
        UIGraphicsBeginImageContextWithOptions(usedRect.size, NO,
                                               UIScreen.mainScreen.scale);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        BOOL notFill = !useAVPlayer && !isOpaque;
        if (!notFill) {
            [[UIColor whiteColor] setFill];
            CGContextFillRect(ctx, usedRect);
        }
        if (!notFill) {
            UIColor *backgroudColor =
                self.backgroundColor ?: self.superview.backgroundColor;
            if (backgroudColor) {
                [backgroudColor setFill];
                CGContextFillRect(ctx, usedRect);
            }
        }

        NSRange range =
            [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        [self.layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        if (self.placeholderTextEnabled) {
            self.preventViewImageView.placeholderImage = image;
        }
        self.preventViewImageView.image = image;
        UIGraphicsEndImageContext();
        self.preventViewImageViewTrailingConstraint.constant = -(maxX - width);
        self.preventViewImageViewBottomConstraint.constant = (maxY - height);
        [self invalidateIntrinsicContentSize];
    }
}

- (BOOL)isCaptured {
    return self.preventViewImageView.isCaptured;
}

- (void)_adjustPreferredFontForCurrentContentSizeCategory {
    if (self.adjustsFontForContentSizeCategory) {
        UITraitCollection *traitCollection = self.traitCollection;
        __auto_type textStorage = self.textStorage;
        __block BOOL invalidatePreventView = NO;
        [self.textStorage
            enumerateAttributesInRange:NSMakeRange(0, self.textStorage.length)
                               options:0
                            usingBlock:^(NSDictionary<NSAttributedStringKey, id>
                                             *_Nonnull attrs,
                                         NSRange range, BOOL *_Nonnull stop) {
                              UIFont *font = attrs[NSFontAttributeName];
                              UIFont *adFont = [SYFontUtilUtil
                                  fontAdjustedUsingFont:font
                                        traitCollection:traitCollection];
                              BOOL fontNil = NO;
                              if (font) {
                                  fontNil = !adFont;
                              } else {
                                  fontNil = YES;
                              }
                              if (!fontNil && ![font isEqual:adFont]) {
                                  invalidatePreventView = YES;
                                  [textStorage addAttribute:NSFontAttributeName
                                                      value:adFont
                                                      range:range];
                              }
                            }];
        if (invalidatePreventView) {
            [self invalidatePreventView];
        }
    }
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingCaptured {
    return [NSSet setWithObject:@"preventViewImageView.captured"];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingError {
    return [NSSet setWithObject:@"preventViewImageView.error"];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingStatus {
    return [NSSet setWithObject:@"preventViewImageView.status"];
}

+ (NSAttributedString *)_attributedTextFromText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = text;
    return label.attributedText;
}

- (void)setText:(NSString *)text {
    __auto_type attr = [self.class _attributedTextFromText:text];
    self.attributedText = attr;
    self.placeholderLabel.attributedText = attr;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText =
        [attributedText copy] ?: [[NSAttributedString alloc] init];
    [self.textStorage setAttributedString:_attributedText];
    [self invalidatePreventView];
}

- (void)invalidatePreventView {
    self.usedRect = CGRectNull;
    self.textContainer.size = self.originContainerSize;
    self.accessibilityLabel = self.textStorage.string;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (NSError *)error {
    return self.preventViewImageView.error;
}

- (void)_invalidateIfResolvedColorDidChange:
    (UITraitCollection *)previousTraitCollection {
    __block BOOL invalidatePreventView = NO;
    BOOL useAVPlayer = [SYPreventScreenshotImageView useAVPlayer];
    [self.attributedText
        enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length)
                           options:0
                        usingBlock:^(NSDictionary<NSAttributedStringKey, id>
                                         *_Nonnull attrs,
                                     NSRange range, BOOL *_Nonnull stop) {
                          [attrs enumerateKeysAndObjectsUsingBlock:^(
                                     NSAttributedStringKey _Nonnull key,
                                     id _Nonnull obj, BOOL *_Nonnull stop) {
                            if ([obj isKindOfClass:UIColor.class]) {
                                UIColor *color = (UIColor *)obj;
                                if (@available(iOS 13.0, *)) {
                                    UIColor *curColor =
                                        [color resolvedColorWithTraitCollection:
                                                   self.traitCollection];
                                    UIColor *preColor =
                                        [color resolvedColorWithTraitCollection:
                                                   previousTraitCollection];
                                    if (![preColor isEqual:curColor] &&
                                        !useAVPlayer) {
                                        invalidatePreventView = YES;
                                    }
                                }
                            }
                          }];
                        }];
    if (invalidatePreventView) {
        [self invalidatePreventView];
    } else {

        if (useAVPlayer || self.isOpaque) {
            if (self.backgroundColor || self.superview.backgroundColor) {
                UIColor *color =
                    self.backgroundColor ?: self.superview.backgroundColor;
                if (@available(iOS 13.0, *)) {
                    UIColor *preColor = [color resolvedColorWithTraitCollection:
                                                   previousTraitCollection];
                    UIColor *curColor = [color
                        resolvedColorWithTraitCollection:self.traitCollection];
                    if (![preColor isEqual:curColor] && !useAVPlayer) {
                        [self invalidatePreventView];
                    }
                }
            }
        }
    }
}

- (void)setUp {
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitStaticText;
    self.clipsToBounds = YES;
    self.usedRect = CGRectNull;

    self.textStorage = [[NSTextStorage alloc] init];
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.textContainer = [[NSTextContainer alloc] init];

    self.originContainerSize = self.textContainer.size;

    self.textContainer.lineFragmentPadding = 0;
    [self.textStorage addLayoutManager:self.layoutManager];

    [self.layoutManager addTextContainer:self.textContainer];

    self.preventViewImageView =
        [[SYPreventScreenshotImageView alloc] initWithImage:nil];
    self.preventViewImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.preventViewImageView];

    self.preventViewImageViewTrailingConstraint =
        [self.preventViewImageView.trailingAnchor
            constraintLessThanOrEqualToAnchor:self.trailingAnchor];
    self.preventViewImageViewBottomConstraint =
        [self.preventViewImageView.bottomAnchor
            constraintLessThanOrEqualToAnchor:self.bottomAnchor];
    NSArray *cons = @[
        self.preventViewImageViewTrailingConstraint,
        self.preventViewImageViewBottomConstraint,
        [self.preventViewImageView.topAnchor
            constraintEqualToAnchor:self.topAnchor],
        [self.preventViewImageView.leadingAnchor
            constraintEqualToAnchor:self.leadingAnchor]
    ];
    [NSLayoutConstraint activateConstraints:cons];

    self.hideContentEnabled = YES;
}

@end
