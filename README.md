SYPreventScreenshot [中文介绍](https://github.com/SyNvNX/SYPreventScreenshot/blob/main/README_CN.md)
============

A universal library for preventing screenshots and screen recordings, supporting both ImageView and Label.

## Screenshots

<p float="left">
  <img src="./Screenshots/gif.gif" width="250" />
	<img src="./Screenshots/gif_detal.gif" width="250" />
</p>

The first screenshot actually supports screen recording protection. The effect screenshots has disabled the screen recording prevention feature to display the effect.


## Introduction

This library supports screenshot prevention on iOS 10 and above through DRM (Digital Rights Management) and the preventsCapture feature. 

The implementation in this library does not use the secureTextEntry feature of UITextField to prevent screenshots, as it relies on private classes, leading to poor compatibility across various iOS versions. It is known to be unsupported on iOS 10, 11, 12, 16.7.8, and 18, and it causes issues on versions 15.0.2 and 16.2. There may be more versions with issues.

## How to use

* Objective-C

```objective-c
#import <SYPreventScreenshot/SYPreventScreenshot.h>

UIImage *image = [UIImage imageNamed:@"image"];
SYPreventScreenshotImageView *imageView = [[SYPreventScreenshotImageView alloc] initWithImage:image];
[self.view addSubview:imageView];
    
SYPreventScreenshotLabel *label = [[SYPreventScreenshotLabel alloc] initWithText:@"Hello, world!"];
[self.view addSubview:label];
```

* Swift

```swift
import SYPreventScreenshot

let imageView = SYPreventScreenshotImageView(image: UIImage(named: "image"))
view.addSubview(imageView)
    
let label = SYPreventScreenshotLabel(text: "Hello, world!")
view.addSubview(label)
```

### SDWebImage

* Objective-C

```objective-c
#import <SYPreventScreenshot/SYPreventScreenshotImageView+WebCache.h>

SYPreventScreenshotImageView *imageView = [[SYPreventScreenshotImageView alloc] initWithImage:nil];
NSURL *URL = [NSURL URLWithString:@"http://www.domain.com/path/to/image.png"];
UIImage *placeholderImage = [UIImage imageNamed:@"image"];
[imageView sy_setImageWithURL:URL placeholderImage:placeholderImage];
```

* Swift

```swift
import SYPreventScreenshot

let imageView = SYPreventScreenshotImageView(image: nil)
let placeholderImage = UIImage(named: "image")
let `URL` = URL(string: "http://www.domain.com/path/to/image.png")
imageView.sy_setImage(with: `URL`, placeholderImage: placeholderImage)
```



## Installation

### CocoaPods

Simply add the following line to your Podfile:

```ruby
pod 'SYPreventScreenshot'

# or 

pod 'SYPreventScreenshot/SDWebImage'
```

Then, run the following command:

```bash
$ pod install
```

## Requirements

- iOS 10.0 or late

## TODO

* Support Swift Package Manager
* Support Carthage
* Support Kingfisher
* Support YYWebImage

## License

SYPreventScreenshot is released under the MIT license. See LICENSE for details.
