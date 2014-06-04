//
//  Region+Flickr.m
//  Top Regions
//
//  Created by Skylar Peterson on 11/15/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "Region+Flickr.h"
#import "Photographer.h"

@implementation Region (Flickr)

+ (Region *)regionWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Region *region = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        if (!matches || error || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                   inManagedObjectContext:context];
            region.name = name;
            region.numPhotographers = 0;
        } else {
            region = [matches lastObject];
        }
    }
    
    return region;
}

- (void)addPhotographer:(Photographer *)photographer
{
    NSMutableSet *set = [self.photographers mutableCopy];
    if (![set containsObject:photographer]) {
        [set addObject:photographer];
        self.photographers = set;
        
        NSMutableSet *photographerSet = [photographer.regions mutableCopy];
        [photographerSet addObject:self];
        photographer.regions = photographerSet;
        
        self.numPhotographers = [NSNumber numberWithDouble:self.numPhotographers.integerValue + 1];
    }
}

@end
