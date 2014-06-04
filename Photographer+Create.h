//
//  Photographer+Create.h
//  Top Regions
//
//  Created by Skylar Peterson on 11/14/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
