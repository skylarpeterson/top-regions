//
//  Region+Flickr.h
//  Top Regions
//
//  Created by Skylar Peterson on 11/15/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "Region.h"

@interface Region (Flickr)

+ (Region *)regionWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)addPhotographer:(Photographer *)photographer;

@end
