//
//  WXCondition.m
//  SimpleWeather
//
//  Created by Romaniuk Sergey on 26.09.14.
//  Copyright (c) 2014 Romaniuk Sergey. All rights reserved.
//

#import "WXCondition.h"

@implementation WXCondition

+ (NSDictionary *)imageMap {
    // 1 Create a static NSDictionary since every instance of WXCondition will use the same data mapper.
    

    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        // 2 Map the condition codes to an image file (e.g. “01d” to “weather-clear.png”).
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

// 3 Declare the public message to get an image file name.
- (NSString *)imageName {
    
    // не по тьюториалу... т.к. weather.icon - не строка, а массив из 1 строки....
    
    NSString *iconStr = [self.icon objectAtIndex:0];
    return [WXCondition imageMap][iconStr];
}

//setup JSON to model properties mappings. In this case, the dictionary key is WXCondition‘s property name, while the dictionary value is the keypath from the JSON.

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"dateInText": @"dt_txt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    // 1  You return a MTLValueTransformer using blocks to transform values to and from Objective-C properties.
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

// 2 You only need to detail how to convert between Unix time and NSDate once, so just reuse -dateJSONTransformer for sunrise and sunset.
+ (NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}



@end
