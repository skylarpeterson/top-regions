//
//  Photographer.h
//  Top Regions
//
//  Created by Skylar Peterson on 11/15/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *regions;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addRegionsObject:(Region *)value;
- (void)removeRegionsObject:(Region *)value;
- (void)addRegions:(NSSet *)values;
- (void)removeRegions:(NSSet *)values;

@end
