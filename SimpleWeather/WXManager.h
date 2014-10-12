//
//  WXManager.h
//  SimpleWeather
//
//  Created by Romaniuk Sergey on 26.09.14.
//  Copyright (c) 2014 Romaniuk Sergey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXCondition.h"


@interface WXManager : NSObject

+(WXManager*) sharedManager; // возвращает СИНГЛТОН sharedManager (содержащий AFHTTPRequestOperationManager инициализированный базовым URL)


-(void)fetchWeatherDataForPeriod:(NSString*) period  // на теперь, на сегодня по-часово, на 5 дней
                      withParams:(NSDictionary*) params // город, язык, единицы, тип данных
                       onSuccess:(void(^)(NSDictionary* weatherJsonDict)) success // возвращаем словарь с погодой для парсинга
                       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void)searchCityNameWithParams:(NSDictionary*) params // название города который ищем, тип данных
                      onSuccess:(void(^)(NSDictionary* weatherJsonDict)) success // возвращаем словарь с погодой для городов с похож назв для извлечения из него названий городов
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;




@end
