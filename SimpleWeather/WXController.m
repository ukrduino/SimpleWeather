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
// #import "QuartzCore/QuartzCore.h"



@interface WXController ()

// Индикатор UIActivityIndicatorView

@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;




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
@property (nonatomic, strong) NSString *cityId;
@property (nonatomic, strong) UIButton *settings;
@property (nonatomic, strong) UITextField * searchField;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

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
    
    UIImage *btnImage = [UIImage imageNamed:@"worldwide-location-32.png"];
    [self.settings setBackgroundImage:btnImage forState:UIControlStateNormal];
    self.settings.frame = settings;
    [header addSubview:self.settings];
    
   
    self.tableHourlyFormatter = [[NSDateFormatter alloc] init];
    self.tableHourlyFormatter.dateFormat = @"h a";
    
    self.tableDailyFormatter = [[NSDateFormatter alloc] init];
    self.tableDailyFormatter.dateFormat = @"EEEE";
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter.dateFormat = @"HH:mm";
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"dd.MM.yyyy";
    

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(fetchCurrentWeatherConditions:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
  
    
//    - (void)refresh:(UIRefreshControl *)refreshControl {
//        [refreshControl endRefreshing];
//    }
    
    // Индикатор UIActivityIndicatorView
    
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
    self.loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.loadingView.clipsToBounds = YES;
    self.loadingView.layer.cornerRadius = 10.0;
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.frame = CGRectMake(65, 40, self.activityView.bounds.size.width, self.activityView.bounds.size.height);
    [self.loadingView addSubview:self.activityView];
    
    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.textColor = [UIColor whiteColor];
    self.loadingLabel.adjustsFontSizeToFitWidth = YES;
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.text = @"Загрузка...";
    [self.loadingView addSubview:self.loadingLabel];
    
    [self.view addSubview:self.loadingView];
    [self.activityView startAnimating];
    
    
    
    [self fetchCurrentWeatherConditions:self.refreshControl];


}


-(void)showSearchView{
    
    // Установка settingsTableView
    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.backgroundColor = [UIColor clearColor];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    // Убирает пустые ячейки в таблице (разделители между ними)
    self.searchTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    
    
    //    self.tableView.pagingEnabled = YES; // постраничная прокрутка
    
    CGRect searchHeaderFrame = CGRectMake(0,
                                          0,
                                          self.view.bounds.size.width,
                                          100);
    CGRect searchFieldFrame = CGRectMake((self.view.bounds.size.width-170)/2,
                                         35,
                                         170,
                                         32);
    CGRect searchButtonFrame = CGRectMake(searchFieldFrame.origin.x+178,
                                          35,
                                          32,
                                          32);
    
    CGRect backButtonFrame = CGRectMake(searchFieldFrame.origin.x-40,
                                        35,
                                        32,
                                        32);
    
    // Создание UIView для шапки таблицы
    UIView *searchHeader = [[UIView alloc] initWithFrame:searchHeaderFrame];
    searchHeader.backgroundColor = [UIColor clearColor];
    self.searchTableView.tableHeaderView = searchHeader;
    
    
    
    // Кнопка поиска
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [searchButton addTarget:self
                     action:@selector(search)
           forControlEvents:UIControlEventTouchUpInside];
    
    searchButton.backgroundColor = [UIColor clearColor];
    searchButton.frame = searchButtonFrame;
    // Кнопка назад
    UIImage *searchButtonImage = [UIImage imageNamed:@"search-2-32.png"];
    [searchButton setBackgroundImage:searchButtonImage forState:UIControlStateNormal];
    [searchHeader addSubview:searchButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton addTarget:self
                   action:@selector(backToMainScreen)
         forControlEvents:UIControlEventTouchUpInside];
    
    backButton.backgroundColor = [UIColor clearColor];
    backButton.frame = backButtonFrame;
    
    UIImage *backButtonImage = [UIImage imageNamed:@"arrow-96-32.png"];
    [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    [searchHeader addSubview:backButton];
    
    self.searchField = [[UITextField alloc]initWithFrame:searchFieldFrame];
    self.searchField.backgroundColor = [UIColor clearColor];
    [self.searchField setBorderStyle:UITextBorderStyleRoundedRect];
    [searchHeader addSubview:self.searchField];
    
//    Swift Xcode 6: keyboard not showing up in ios simulator
//
//    iOS Simulator -> Hardware -> Keyboard
//    Uncheck "Connect Hardware Keyboard"
//    Mine was checked because I was using my mac keyboard, but if you make sure it is unchecked the iPhone keyboard will always come up.
    
    
    [self.view addSubview:self.searchTableView];
    [self.view sendSubviewToBack:self.tableView];
    self.blurredImageView.alpha = 0.8;
    
}

-(void)search{

    
    [self.view endEditing:YES];
    [self searchCityNameWithParams:self.searchField.text];

};

-(void)backToMainScreen{
    
    [self.view endEditing:YES];
    [self.view bringSubviewToFront:self.tableView];
    [self.view sendSubviewToBack:self.searchTableView];
    self.blurredImageView.alpha = 0;
    
    
};

-(void)searchCityNameWithParams:(NSString*) searchCityName {
    
    // Индикатор UIActivityIndicatorView
    
    [self.view addSubview:self.loadingView];
    [self.activityView startAnimating];
    
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
         self.cityListArray = [NSMutableArray new];
         for (int i = 0; i < [self.searchtListArray count]; i++)
         {
             
             NSDictionary * cityDict =[self.searchtListArray objectAtIndex:i];
             NSString *cityName = [cityDict valueForKey:@"name"];
             [self.cityListArray addObject:cityName];

         }
         
// Индикатор UIActivityIndicatorView
         [self.searchTableView reloadData];
         [self.activityView stopAnimating];
         [self.loadingView removeFromSuperview];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
    
    
    
    
}

// Fetching Current Conditions
-(void)fetchCurrentWeatherConditions:(UIRefreshControl *)refreshControl  {
    

    
        // http://ios-blog.co.uk/tutorials/quick-tips/storing-data-with-nsuserdefaults/
        // reed data from NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *cityId = [defaults objectForKey:@"cityId"];
    
    
    self.params = [[NSMutableDictionary alloc]  initWithObjectsAndKeys:
                   cityId,  @"id",
                   @"metric", @"units",
                   @"ru",     @"lang",
                   @"json",   @"mode", nil
                   ];
    [[WXManager sharedManager]
     fetchWeatherDataForPeriod:@"weather"
     withParams:self.params
     onSuccess:^(NSDictionary* weatherJsonDict)
     {
         // преобразование JSON в словарь и WXCondition
         
         self.Condition = [MTLJSONAdapter modelOfClass:WXCondition.class fromJSONDictionary:weatherJsonDict error:NULL];
         NSLog(@"Condition = %@", self.Condition);
         [self fetchHourlyWeatherForecast];
         
         [refreshControl endRefreshing];
         
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

             [self.hourlyWeatherForecastListArray removeObjectAtIndex:d-1-i];
             
         }
         self.conditionsHourlyWeatherForecastListArray = [NSMutableArray new];
         for (int i = 0; i < [self.hourlyWeatherForecastListArray count]; i++)
         {
             
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
         self.conditionsDaylyWeatherForecastListArray = [NSMutableArray new];
         for (int i = 0; i < [self.daylyWeatherForecastListArray count]; i++)
         {

             
             WXDailyForecast * fork = [MTLJSONAdapter modelOfClass:WXDailyForecast.class fromJSONDictionary:[self.daylyWeatherForecastListArray objectAtIndex:i] error:NULL];
             [self.conditionsDaylyWeatherForecastListArray addObject:fork];
//             NSLog(@"fork: %@", fork);
         }
//         [self searchCityNameWithParams:@"Kherson"];
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
    
    // Индикатор UIActivityIndicatorView
    
        [self.activityView stopAnimating];
        [self.loadingView removeFromSuperview];

    
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
        if ([self.cityListArray count]>0) {
            self.searchTableView.backgroundView = nil;

            return 1;
            
        } else {
            
            // Display a message when the table is empty
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            
            messageLabel.text = @"Введите название города для поиска";
            messageLabel.textColor = [UIColor whiteColor];
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
            [messageLabel sizeToFit];
            
            self.searchTableView.backgroundView = messageLabel;
            self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
        }
        
        return 0;
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
   
    if (tableView != self.searchTableView){
        if (indexPath.section == 0) {
            // 1
            if (indexPath.row == 0) {
                [self configureHeaderCell:cell title:@"Суточний прогноз"];
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
                [self configureHeaderCell:cell title:@"Недельный прогноз"];
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
    }
    else {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        NSString *cityName = self.cityListArray[indexPath.row];
        NSMutableDictionary *cityDict = self.searchtListArray[indexPath.row];
        NSMutableDictionary *sysDict = [cityDict objectForKey:@"sys"];
        NSString *country = [sysDict objectForKey:@"country"];
                                        
        cell.textLabel.text = cityName;
        cell.detailTextLabel.text = country;
    
    
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView !=self.searchTableView) {
  
    
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
        return self.screenHeight / (CGFloat)cellCount;}
    else {
        return 44;
    }
        
        
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *citydict = [self.searchtListArray objectAtIndex:indexPath.row];
    self.cityId = [citydict objectForKey:@"id"];
    // save data to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.cityId forKey:@"cityId"];
    [defaults synchronize];

    [self.view sendSubviewToBack:self.searchTableView];
    [self.view bringSubviewToFront:self.tableView];
    
    [self fetchCurrentWeatherConditions:self.refreshControl];
    self.blurredImageView.alpha = 0;
    
    [self.view addSubview:self.loadingView];
    [self.activityView startAnimating];

    
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 1
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // 2
    CGFloat percent = MIN(position / height, 1.0);
    // Если скрол вью это self.tableView то постепенное затемнение работает.
        if(scrollView == self.tableView) {
            // its your tableView
                self.blurredImageView.alpha = percent;
        }

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
