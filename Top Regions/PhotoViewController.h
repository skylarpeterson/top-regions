//
//  PhotoViewController.h
//  Top Places
//
//  Created by Skylar Peterson on 11/6/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) NSURL *imageURL;

@end
