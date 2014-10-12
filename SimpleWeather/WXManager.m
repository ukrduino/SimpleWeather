//
//  WXManager.m
//  SimpleWeather
//
//  Created by Romaniuk Sergey on 26.09.14.
//  Copyright (c) 2014 Romaniuk Sergey. All rights reserved.
//

#import "WXManager.h"
#import "AFNetworking.h"
#import "WXController.h"



@interface WXManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;


@end


@implementation WXManager


+ (WXManager*) sharedManager {
    
    static WXManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WXManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/"];
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}


-(void)fetchWeatherDataForPeriod:(NSString*) period  // на теперь, на сегодня по-часово, на 5 дней
                      withParams:(NSDictionary*) params // город, язык, единицы, к-во данных
                       onSuccess:(void(^)(NSDictionary* weatherJsonDict)) success // возвращаем словарь с погодой для парсинга
                       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    [self.requestOperationManager
     GET:period
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
       
             
//             NSLog(@"WXManager responseObject : %@", responseObject);
             
             // преобразование JSON в словарь
             NSDictionary *weatherJsonDict = responseObject;
             
//             NSLog(@"WXManager weatherJsonDict: %@", weatherJsonDict);
         
         
             // возвращаем словарь weatherJsonDict
         if (success) {
             success(weatherJsonDict);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}

-(void)searchCityNameWithParams:(NSDictionary*) searchParams // название города который ищем, тип данных
                      onSuccess:(void(^)(NSDictionary* weatherJsonDict)) success // возвращаем словарь с погодой для городов с похож назв для извлечения из него названий городов
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    NSLog(@"params: %@", searchParams);
    
    [self.requestOperationManager
     GET:@"find?"
     parameters:searchParams
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         
         
         NSLog(@"WXManager responseObject : %@", responseObject);
         
         // преобразование JSON в словарь
         NSDictionary *weatherJsonDict = responseObject;
         
         //             NSLog(@"WXManager weatherJsonDict: %@", weatherJsonDict);
         
         
         // возвращаем словарь weatherJsonDict
         if (success) {
             success(weatherJsonDict);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}


@end

