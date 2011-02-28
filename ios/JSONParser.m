//
//  JSONParser.m
//  Shuttle-Tracker
//
//  Created by Brendon Justin on 2/12/11.
//  Copyright 2011 Brendon Justin. All rights reserved.
//

#import "JSONParser.h"
#import "TouchJSON/Extensions/NSDictionary_JSONExtensions.h"
#import "EtaWrapper.h"


@implementation JSONParser

@synthesize vehicles;
@synthesize etas;


//  Assume a call to init is for a shuttle JSON parser
- (id)init {
    [self initWithUrl:[NSURL URLWithString:@"http://www.abstractedsheep.com/~ashulgach/data_service.php?action=get_shuttle_positions"]];
    
    return self;
}


//  Init and parse JSON from some specified URL
- (id)initWithUrl:(NSURL *)url {
    if ((self = [super init])) {
        jsonUrl = url;
        [jsonUrl retain];
        
    }
    
    return self;
}


//  Parse the shuttle data we will get from http://www.abstractedsheep.com/~ashulgach/data_service.php?action=get_shuttle_positions
//  Note: parseShuttles and parseEtas are very similar
- (BOOL)parseShuttles {
    NSError *theError = nil;
    NSString *jsonString = [NSString stringWithContentsOfURL:jsonUrl encoding:NSUTF8StringEncoding error:&theError];
    NSDictionary *jsonDict = nil;
    
    [vehicles release];
    
    vehicles = [[NSMutableArray alloc] init];
    
    if (theError) {
        NSLog(@"Error retrieving JSON data");
        
        return NO;
    } else {
        if (jsonString) {
            jsonDict = [NSDictionary dictionaryWithJSONString:jsonString error:&theError];
        } else {
            jsonDict = nil;
			
			return NO;
        }
        
        //  Each dictionary corresponds to one set of curly braces ({ and })
        for (NSDictionary *dict in jsonDict) {
            JSONVehicle *vehicle = [[JSONVehicle alloc] init];
            
            CLLocationCoordinate2D coordinate;
            
            //  Set the vehicle properties to the corresponding JSON values
            for (NSString *string in dict) {
                if ([string isEqualToString:@"shuttle_id"]) {
                    vehicle.name = [dict objectForKey:string];
                } else if ([string isEqualToString:@"latitude"]) {
                    coordinate.latitude = [[dict objectForKey:string] floatValue];
                } else if ([string isEqualToString:@"longitude"]) {
                    coordinate.longitude = [[dict objectForKey:string] floatValue];
                } else if ([string isEqualToString:@"heading"]) {
                    vehicle.heading = [[dict objectForKey:string] intValue];
                } else if ([string isEqualToString:@"update_time"]) {
					NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
					[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
					
					vehicle.updateTime = [dateFormatter dateFromString:[dict objectForKey:string]];
					[dateFormatter release];
				} else if ([string isEqualToString:@"route_id"]) {
					vehicle.routeNo = [[dict objectForKey:string] intValue];
				}
            }
            
            //  Set the coordinate of the vehicle after both the latitude and longitude are set
            vehicle.coordinate = coordinate;
            
            [vehicles addObject:vehicle];
            [vehicle release];
        }
        
        return YES;
    }
    
    return NO;
}


//  Parse the ETAs we will get, as formatted at http://abstractedsheep.com/~ashulgach/data_service.php?action=get_all_eta
//  Note: parseShuttles and parseEtas are very similar
- (BOOL)parseEtas {
    NSError *theError = nil;
    NSString *jsonString = [NSString stringWithContentsOfURL:jsonUrl encoding:NSUTF8StringEncoding error:&theError];
    NSDictionary *jsonDict = nil;
    
    [etas release];
    
    etas = [[NSMutableArray alloc] init];
    
    if (theError) {
        NSLog(@"Error retrieving JSON data");
        
        return NO;
    } else {
        if (jsonString) {
            jsonDict = [NSDictionary dictionaryWithJSONString:jsonString error:&theError];
        } else {
            jsonDict = nil;
			
			return NO;
        }
        
        
        //  Each dictionary corresponds to one set of curly braces ({ and })
        for (NSDictionary *dict in jsonDict) {
            EtaWrapper *eta = [[EtaWrapper alloc] init];
            
            //  Set the eta properties to the corresponding JSON values
            for (NSString *string in dict) {
                if ([string isEqualToString:@"shuttle_id"]) {
                    eta.shuttleId = [dict objectForKey:string];
                } else if ([string isEqualToString:@"stop_id"]) {
                    eta.stopId = [dict objectForKey:string];
                } else if ([string isEqualToString:@"eta"]) {
                    eta.eta = [NSDate dateWithTimeIntervalSinceNow:[[dict objectForKey:string] floatValue]/1000.0f];
                } else if ([string isEqualToString:@"route"]) {
                    eta.route = [[dict objectForKey:string] intValue];
                }
            }
            
            [etas addObject:eta];
            [eta release];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)dealloc {
    [super dealloc];
    [etas release];
    [vehicles release];
    [jsonUrl release];
}


@end


@implementation JSONPlacemark

@synthesize name;
@synthesize description;
@synthesize coordinate;
@synthesize annotationView;

- (id)init {
    if ((self = [super init])) {
        name = nil;
        description = nil;
        
        annotationView = nil;
    }
    
    return self;
}

//  Title is the main line of text displayed in the callout of an MKAnnotation
- (NSString *)title {
	return name;
}

//  Subtitle is the secondary line of text displayed in the callout of an MKAnnotation
- (NSString *)subtitle {
	return description;
}


@end

@implementation JSONStop


- (id)init {
    if ((self = [super init])) {
        name = nil;
        description = nil;
        
        annotationView = nil;
    }
    
    return self;
}

@end


@implementation JSONVehicle

@synthesize ETAs;
@synthesize heading;
@synthesize updateTime;
@synthesize routeNo;


- (id)init {
    if ((self = [super init])) {
        name = nil;
        description = nil;
        ETAs = nil;
        annotationView = nil;
        
        heading = 0;
		routeNo = 0;
    }

    return self;
}


@end
