//
//  SYViewController.m
//  SYPreventScreenshot
//
//  Created by SyNvNX on 12/19/2024.
//  Copyright (c) 2024 SyNvNX. All rights reserved.
//

#import "SYViewController.h"
#import <SYPreventScreenshot/SYPreventScreenshot.h>
#import "SYPreventScreenshot_Example-Swift.h"
#import "SYSDViewController.h"

@interface SYViewController ()

@property (nonatomic, strong) SYPreventScreenshotLabel *label;
@property (nonatomic, strong) SYPreventScreenshotImageView *imageView;

@end

@implementation SYViewController

+ (void)load {
    [SYPreventScreenshot setLevel:SYLogLevelOn];
    [SYPreventScreenshot setLoggerBlock:^(NSString * _Nullable message) {
        NSLog(@"SYPreventScreenshot: %@", message);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)setUp {
    UIImage *image = [UIImage imageNamed:@"image"];
    SYPreventScreenshotImageView *imageView = [[SYPreventScreenshotImageView alloc] initWithImage:image];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    
    [NSLayoutConstraint activateConstraints:@[
        [imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
    SYPreventScreenshotLabel *label = [[SYPreventScreenshotLabel alloc] initWithText:self.class.systemVerson];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.topAnchor constraintEqualToAnchor:imageView.bottomAnchor constant:10]
    ]];
    
    self.label = label;
    self.imageView = imageView;
}

+ (NSString *)systemVerson {
    NSString *systemVersion = UIDevice.currentDevice.systemVersion;
    return [NSString stringWithFormat:@" System Verson: iOS %@ ", systemVersion];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SYSDViewController *vc = [SYSDViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
