MJGallery
=========

MJGallery is a view controller that displays a list of images as the Photos app does in your iOS device.

Key features:

- User friendly interface.
- Works with `UIImages`, image file paths and server urls (`NSURL` and `NSString` paths).
- Caching system to store downloaded images.
- Supports zooming.
- Supports landscape and portrait layouts.
- Smooth animations and transitions.
- It simply works.

##Install MJGallery

MJGallery still under development. Therefore you won't find it in the public CocoaPods repository. However, you can download MJGallery using CocoaPods by linking directly to this repository.

```
pod 'MJGallery', :git => 'https://github.com/mobilejazz/MJGallery.git'
```

Otherwise, you can simply download the files in the folder *SourceCode* of this repository.

##How to use MJGallery

To use MJGallery, simply instantiate a `MJImageViewerGalleryViewController` and assign to it an array of images. 

Images can be instnaces of `UIImage` or simply url paths to the image (`NSURL` or `NSString`). You can mix them in a single array.

```
NSArray *images = @[@"myImage1"
                    [UIImage imageNamed:@"myImage2"], 
                    @"http://server.com/image.png",
                    [NSURL URLWithString:@"http://server.com/image.png"]
                    ];
MJImageViewerGalleryViewController *galleryViewController = [[MJImageViewerGalleryViewController alloc] initWithImages:array];
```

The interface of MJGallery is very simple too. You only can check for the current displayed index or assign a new displayed image.

```
// Get the current index
NSInteger currentIndex =  galleryViewController.currentImageIndex;
// Display the next image
galleryViewController.currentImageIndex = currentIndex + 1;
```

Also, to avoid you having to subclass the controller, you can customize manually the status bar style by calling `-setPreferredStatusBarStyle:` method.

```
[galleryViewController setPreferredStatusBarStyle:UIStatusBarStyleLightContent];
```

##Important

MJGallery still under development. If you find any bug or issue, please, feel free to send a pull request with your solution. However, if you are too lazy to fix the issue by yourself, just create an issue in the issue tracker of this project.
