//
//  WXCondition.h
//  SimpleWeather
//
//  Created by Romaniuk Sergey on 26.09.14.
//  Copyright (c) 2014 Romaniuk Sergey. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>



//The MTLJSONSerializing protocol tells the Mantle serializer that this object has instructions on how to map JSON to Objective-C properties.

@interface WXCondition : MTLModel <MTLJSONSerializing>


// These are all of your weather data properties. You’ll be using a couple of them, but its nice to have access to all of the data in the event that you want to extend your app down the road.

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *dateInText;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
// не по тьюториалу... т.к. weather.description и weather.main - не строка, а массив из 1 строки....
@property (nonatomic, strong) NSArray *conditionDescription;
@property (nonatomic, strong) NSArray *condition;

@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSArray *icon;

// to map weather conditions to image files
- (NSString *)imageName;

@end
