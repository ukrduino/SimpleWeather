//
//  WXController.m
//  SimpleWeather
//
//  Created by Romaniuk Sergey on 24.09.14.
//  Copyright (c) 2014 Romaniuk Sergey. All rights reserved.
//

#import "WXController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "AFNetworking.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"
#import "WXManager.h"



@interface WXController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) WXCondition *Condition; // экз класса WXCondition с текущими погодными условиями

@property (nonatomic, strong) NSMutableDictionary *params; // параметры запроса к серверу
@property (nonatomic, strong) NSMutableArray *conditionsHourlyWeatherForecastListArray; // массив экз класса WXCondition по 3-х часовый погноз на 1 день
@property (nonatomic, strong) NSMutableArray *conditionsDaylyWeatherForecastListArray; // массив экз класса WXCondition погноз на 5 дней

@property (nonatomic, strong) NSMutableArray *hourlyWeatherForecastListArray; //массив list из weatherJsonDict о 3-х часовый погноз на 1 день
@property (nonatomic, strong) NSMutableArray *daylyWeatherForecastListArray; //массив list weatherJsonDict погноз на 5 дней
@property (nonatomic, strong) NSMutableArray *searchtListArray;
@property (nonatomic, strong) NSMutableArray *cityListArray;


#pragma mark - ЭЛЕМЕНТЫ ОТОБРАЖЕНИИЯ ПОГОДЫ
@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UILabel *hiloLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *conditionsLabel;
@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) UIButton *settings;

@property (nonatomic, strong) NSDateFormatter *tableHourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *tableDailyFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;




@end

@implementation WXController


- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    // Высота экрана для задания шапке таблицы
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    // Установка фона
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // Задание размытого слоя
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0; // пока полностью прозрачный
    [self.blurredImageView setImageToBlur:background blurRadius:5 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    // Установка tableView
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES; // постраничная прокрутка
    [self.view addSubview:self.tableView];
    

    
    // Размер шапки таблицы = размеру экрана
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    // Внутренние отступы
    CGFloat inset = 20;
    // Высоты надписей
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    // рамки (расположение) для надписей и кнопок
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    CGRect settings = CGRectMake(headerFrame.size.width - inset- 32, //x
                                  headerFrame.size.height - inset- 32, //y
                                  32, //width
                                  32); //height
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    // 5
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    

    
  
    
    
    // Создание UIView для шапки таблицы
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // температура
    self.temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    self.temperatureLabel.backgroundColor = [UIColor clearColor];
    self.temperatureLabel.textColor = [UIColor whiteColor];
    self.temperatureLabel.text = @"0";
    self.temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:80];
    [header addSubview:self.temperatureLabel];
    
    // минимальная/максимальная температура
    self.hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    self.hiloLabel.backgroundColor = [UIColor clearColor];
    self.hiloLabel.textColor = [UIColor whiteColor];
    self.hiloLabel.text = @"0° / 0°";
    self.hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    [header addSubview:self.hiloLabel];
    
    // город
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    self.cityLabel.backgroundColor = [UIColor clearColor];
    self.cityLabel.textColor = [UIColor whiteColor];
    self.cityLabel.text = @"Loading...";
    self.cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    self.cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:self.cityLabel];
    
    //дата прогноза
    self.date = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 30)];
    self.date.backgroundColor = [UIColor clearColor];
    self.date.textColor = [UIColor whiteColor];
    self.date.text = @"Forecast";
    self.date.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.date.textAlignment = NSTextAlignmentRight;
    [header addSubview:self.date];
    
    //время прогноза
    self.time = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 30)];
    self.time.backgroundColor = [UIColor clearColor];
    self.time.textColor = [UIColor whiteColor];
    self.time.text = @"for.....";
    self.time.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.time.textAlignment = NSTextAlignmentRight;
    [header addSubview:self.time];
    
    // - ????
    self.conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    self.conditionsLabel.backgroundColor = [UIColor clearColor];
    self.conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    self.conditionsLabel.textColor = [UIColor whiteColor];
    self.conditionsLabel.text = @"Weather.....";
    [header addSubview:self.conditionsLabel];
    
    // Иконка погоды
    self.iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.backgroundColor = [UIColor clearColor];
//    self.iconView.image = [UIImage imageNamed:@"weather-tstorm.png"];
    [header addSubview:self.iconView];
    
    // кнопка настройки
    self.settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settings addTarget:self
                      action:@selector(showSearchView)
            forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *btnImage = [UIImage imageNamed:@"support-32.png"];
    [self.settings setBackgroundImage:btnImage forState:UIControlStateNormal];
    self.settings.frame = settings;
    [header addSubview:self.settings];
    
    // TODO город где получаем прогноз - сделать поиск.
    self.city = @"Kherson";
    // Параметры запроса к серверу
    self.params = [[NSMutableDictionary alloc]  initWithObjectsAndKeys:
                   self.city,  @"q",
                   @"metric", @"units",
                   @"ru",     @"lang",
                   @"json",   @"mode", nil
                   ];
    
    self.tableHourlyFormatter = [[NSDateFormatter alloc] init];
    self.tableHourlyFormatter.dateFormat = @"h a";
    
    self.tableDailyFormatter = [[NSDateFormatter alloc] init];
    self.tableDailyFormatter.dateFormat = @"EEEE";
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter.dateFormat = @"HH:mm";
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"dd.MM.yyyy";
    
    

    
    
    [self fetchCurrentWeatherConditions];


}






-(void)showSearchView{
    
   //// http://ios-blog.co.uk/tutorials/quick-tips/storing-data-with-nsuserdefaults/
//
//    // save data to NSUserDefaults
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setInteger:9001 forKey:@"HighScore"];
//    [defaults synchronize];
//    // reed data from NSUserDefaults
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSInteger theHighScore = [defaults integerForKey:@"HighScore"];
//
//
    // Установка settingsTableView
    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.backgroundColor = [UIColor clearColor];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
//    self.tableView.pagingEnabled = YES; // постраничная прокрутка
   
    CGRect searchHeaderFrame = CGRectMake(0,
                                          0,
                                          self.view.bounds.size.width,
                                          100);
    CGRect searchFieldFrame = CGRectMake((self.view.bounds.size.width - 200)/2,
                                          35,
                                          200,
                                          30);
    
    // Создание UIView для шапки таблицы
    UIView *searchHeader = [[UIView alloc] initWithFrame:searchHeaderFrame];
    searchHeader.backgroundColor = [UIColor clearColor];
    self.searchTableView.tableHeaderView = searchHeader;
    
    UITextField * searchField = [[UITextField alloc]initWithFrame:searchFieldFrame];
    [searchHeader addSubview:searchField];
    
    [self.view addSubview:self.searchTableView];
    [self.view bringSubviewToFront:self.searchTableView];
    [self.view sendSubviewToBack:self.tableView];
    self.blurredImageView.alpha = 1;
    
}


-(void)searchCityNameWithParams:(NSString*) searchCityName{
    
    NSMutableDictionary * searchParams = [[NSMutableDictionary alloc]  initWithObjectsAndKeys:
                                          searchCityName,  @"q",
                                          @"json",   @"mode",
                                          @"like", @"type", nil
                                          ];
    
    
    [[WXManager sharedManager]
     searchCityNameWithParams:searchParams
     onSuccess:^(NSDictionary* weatherJsonDict)
     {
         
         self.searchtListArray = [[NSMutableArray alloc]initWithArray:weatherJsonDict[@"list"]];
         NSLog(@"searchtListArray: %@", self.searchtListArray);
         
         self.cityListArray = [NSMutableArray new];
         for (int i = 0; i < [self.searchtListArray count]; i++)
         {
             NSLog(@"searchtListArray #%i: %@", i, [self.searchtListArray objectAtIndex:i]);
             
             NSDictionary * cityDict =[self.searchtListArray objectAtIndex:i];
             
             NSString *cityName = [cityDict valueForKey:@"name"];
             
             [self.cityListArray addObject:cityName];
             NSLog(@"cityName: %@", cityName);
         }
         
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
    
    
    
    
}






// Fetching Current Conditions
-(void)fetchCurrentWeatherConditions {
    
    [[WXManager sharedManager]
     fetchWeatherDataForPeriod:@"weather"
     withParams:self.params
     onSuccess:^(NSDictionary* weatherJsonDict)
     {
         // преобразование JSON в словарь и WXCondition
         
         self.Condition = [MTLJSONAdapter modelOfClass:WXCondition.class fromJSONDictionary:weatherJsonDict error:NULL];
 //        NSLog(@"self.Condition = %@", self.Condition);
         [self fetchHourlyWeatherForecast];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
}

// Fetching the Hourly Forecast
-(void)fetchHourlyWeatherForecast {
    
    [[WXManager sharedManager]
     fetchWeatherDataForPeriod:@"forecast?"
     withParams:self.params
     onSuccess:^(NSDictionary* weatherJsonDict)
     {
         
         self.hourlyWeatherForecastListArray = [[NSMutableArray alloc]initWithArray:weatherJsonDict[@"list"]];
         
         int i = 0;
         int d =(int)[self.hourlyWeatherForecastListArray count];
         for(i=0; i<d-7; i++) {
//             NSLog(@"removeObjectAtIndex:%i",d-1-i);
             [self.hourlyWeatherForecastListArray removeObjectAtIndex:d-1-i];
             
         }
         self.conditionsHourlyWeatherForecastListArray = [NSMutableArray new];
         for (int i = 0; i < [self.hourlyWeatherForecastListArray count]; i++)
         {
//             NSLog(@"hourlyWeatherForecastListArray #%i: %@", i, [self.hourlyWeatherForecastListArray objectAtIndex:i]);
             
             WXCondition * cond = [MTLJSONAdapter modelOfClass:WXCondition.class fromJSONDictionary:[self.hourlyWeatherForecastListArray objectAtIndex:i] error:NULL];
             [self.conditionsHourlyWeatherForecastListArray addObject:cond];
//             NSLog(@"cond: %@", cond);
         }
         
         [self fetchDaylyWeatherForecast];
         
         
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
}

// Fetching the Dayly Forecast
-(void)fetchDaylyWeatherForecast {
    
    [[WXManager sharedManager]
     fetchWeatherDataForPeriod:@"forecast/daily?"
     withParams:self.params
     onSuccess:^(NSDictionary* weatherJsonDict)
     {
         
         self.daylyWeatherForecastListArray = [[NSMutableArray alloc]initWithArray:weatherJsonDict[@"list"]];
//         NSLog(@"daylyWeatherForecastListArray: %@", self.daylyWeatherForecastListArray);
         
         self.conditionsDaylyWeatherForecastListArray = [NSMutableArray new];
         for (int i = 0; i < [self.daylyWeatherForecastListArray count]; i++)
         {
//             NSLog(@"daylyWeatherForecastListArray #%i: %@", i, [self.daylyWeatherForecastListArray objectAtIndex:i]);
             
             WXDailyForecast * fork = [MTLJSONAdapter modelOfClass:WXDailyForecast.class fromJSONDictionary:[self.daylyWeatherForecastListArray objectAtIndex:i] error:NULL];
             [self.conditionsDaylyWeatherForecastListArray addObject:fork];
//             NSLog(@"fork: %@", fork);
         }
         [self searchCityNameWithParams:@"Kherson"];
         [self displayCondition];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
}

// Displaying Current Conditions
-(void)displayCondition{ 
    
//    // TODO Задержка на получение данных - заменить....
//    
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
////          do something
//        });
        self.temperatureLabel.text = [NSString stringWithFormat:@"%.1f°", [self.Condition.temperature floatValue]];
        self.hiloLabel.text = [NSString stringWithFormat:@"%.1f° / %.1f°", [self.Condition.tempLow floatValue], [self.Condition.tempHigh floatValue]];
        self.cityLabel.text = self.Condition.locationName;
        self.date.text = [self.dateFormatter stringFromDate:self.Condition.date];
        self.time.text = [self.timeFormatter stringFromDate:self.Condition.date];
        
        // weather.main - не строка, а массив из одной строки
        
        self.conditionsLabel.text = [[self.Condition.conditionDescription objectAtIndex:0] capitalizedString];
        self.iconView.image = [UIImage imageNamed:[self.Condition imageName]];
        
        [self.tableView reloadData];
    
}

// Кастомизация StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
} 





#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.tableView) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    if (tableView == self.tableView) {
        if (section == 0) {
            
            return [self.hourlyWeatherForecastListArray count];
        }
        
        return [self.daylyWeatherForecastListArray count];
    }
    else {
        return [self.cityListArray count];
    }
    


}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // 3
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
   
    if (indexPath.section == 0) {
        // 1
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
            
            WXCondition *hourlyForcast = self.conditionsHourlyWeatherForecastListArray[indexPath.row];
            
            cell.textLabel.text = [self.tableHourlyFormatter stringFromDate:hourlyForcast.date];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",hourlyForcast.temperature.floatValue];
            cell.imageView.image = [UIImage imageNamed:[hourlyForcast imageName]];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    else if (indexPath.section == 1) {
        // 1
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
            WXDailyForecast *daylyForcast = self.conditionsDaylyWeatherForecastListArray[indexPath.row];

            cell.textLabel.text = [self.tableDailyFormatter stringFromDate:daylyForcast.date];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                         daylyForcast.tempLow.floatValue,
                                         daylyForcast.tempHigh.floatValue];
            cell.imageView.image = [UIImage imageNamed:[daylyForcast imageName]];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 1
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // 2
    CGFloat percent = MIN(position / height, 1.0);
    // 3
    self.blurredImageView.alpha = percent;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
    self.searchTableView.frame = bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end