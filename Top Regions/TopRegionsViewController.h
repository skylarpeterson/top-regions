//
//  TopRegionsViewController.h
//  Top Regions
//
//  Created by Skylar Peterson on 11/14/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface TopRegionsViewController : CoreDataTableViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
