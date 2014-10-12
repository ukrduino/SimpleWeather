//
//  WXController.h
//  SimpleWeather
//
//  Created by Romaniuk Sergey on 24.09.14.
//  Copyright (c) 2014 Romaniuk Sergey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXController : UIViewController

<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>



-(void)fetchCurrentWeatherConditions;
-(void)fetchHourlyWeatherForecast;
-(void)fetchDaylyWeatherForecast;
-(void)searchCityNameWithParams:(NSString*) searchCityName;



@end
