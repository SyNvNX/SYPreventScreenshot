//
//  SYSDViewController.m
//  SYPreventScreenshot_Example
//
//  Created by sy on 2024/12/22.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

#import "SYSDViewController.h"
#import <SYPreventScreenshot/SYPreventScreenshotImageView+WebCache.h>
@interface SYSDViewController ()

@end

@implementation SYSDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self setUp];
}

- (void)setUp {
    SYPreventScreenshotImageView *imageView = [[SYPreventScreenshotImageView alloc] initWithImage:nil];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    
    [NSLayoutConstraint activateConstraints:@[
        [imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [imageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
    UIImage *placeholderImage = [UIImage imageNamed:@"image"];
    [imageView sy_setImageWithURL:[NSURL URLWithString:@"https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png"] placeholderImage:placeholderImage];
}


@end
