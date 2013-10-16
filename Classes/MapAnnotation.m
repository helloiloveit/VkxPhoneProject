//
//  MapAnnotation.m
//  linphone
//
//  Created by NinhNB on 3/10/13.
//
//

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coord{
    coordinate = coord;
    return self;
}

@end
