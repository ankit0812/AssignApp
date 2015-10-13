//
//  MapPlotter.m
//  AssignApp
//
//  Created by optimusmac4 on 10/12/15.
//  Copyright © 2015 optimusmac4. All rights reserved.
//

#import "MapPlotter.h"

@implementation MapPlotter

-(id)initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate{
    if(self == [super init])
    {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
    }
    return self;
    
}
-(NSString *)title{
    if([_name isKindOfClass:[NSNull class]])
        return @"Unknown";
    else
        return _name;
}
-(NSString *)subtitle{
    return _address;
}

@end
