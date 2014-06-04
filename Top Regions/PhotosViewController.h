//
//  PhotosViewController.h
//  Top Places
//
//  Created by Skylar Peterson on 11/6/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "TopRegionsViewController.h"
#import "Region.h"

@interface PhotosViewController : CoreDataTableViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Region *region;

@end
