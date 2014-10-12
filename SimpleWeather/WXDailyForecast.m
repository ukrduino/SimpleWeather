//
//  WXDailyForecast.m
//  SimpleWeather
//
//  Created by Romaniuk Sergey on 26.09.14.
//  Copyright (c) 2014 Romaniuk Sergey. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    // 1 Get WXCondition‘s map and create a mutable copy of it.
    
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    
    // 2 Change the max and min key maps to what you’ll need for the daily forecast.
    
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    
    
    // 3 Return the new mapping.
   
    return paths;
}

@end
