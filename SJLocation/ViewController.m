//
//  ViewController.m
//  SJLocation
//
//  Created by Soldier on 15/5/14.
//  Copyright (c) 2015年 Soldier. All rights reserved.
//

#import "ViewController.h"
#import "SJLocationManager.h"

@interface ViewController ()

@property(nonatomic, strong) UILabel *locaLabel;

@end




@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height * 0.25, self.view.frame.size.width - 20, 50)];
    _locaLabel.textColor = [UIColor orangeColor];
    _locaLabel.font = [UIFont systemFontOfSize:20];
    _locaLabel.numberOfLines = 0;
    _locaLabel.textAlignment = NSTextAlignmentCenter;
    _locaLabel.clipsToBounds = YES;
    _locaLabel.layer.borderWidth = 1;
    _locaLabel.layer.cornerRadius = 5;
    _locaLabel.layer.borderColor = [UIColor orangeColor].CGColor;
    [self.view addSubview:_locaLabel];
    
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(self.view.frame.size.width * 0.5 - 120 * 0.5, _locaLabel.frame.origin.y + 100, 120, 40);
    [locationBtn setTitle:@"getCoordinate" forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(getLocationCoordinate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    
    UIButton *locationBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn2.frame = CGRectMake(self.view.frame.size.width * 0.5 - 100 * 0.5, locationBtn.frame.origin.y + 70 , 100, 40);
    [locationBtn2 setTitle:@"getCity" forState:UIControlStateNormal];
    [locationBtn2 setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [locationBtn2 addTarget:self action:@selector(getCity) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn2];
    
    UIButton *locationBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn3.frame = CGRectMake(self.view.frame.size.width * 0.5 - 100 * 0.5, locationBtn2.frame.origin.y + 70, 100, 40);
    [locationBtn3 setTitle:@"getAddress" forState:UIControlStateNormal];
    [locationBtn3 setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [locationBtn3 addTarget:self action:@selector(getAddress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn3];
}

- (void)getLocationCoordinate {
    [[SJLocationManager shareManager] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
        _locaLabel.text = [NSString stringWithFormat:@"%f   %f",locationCorrrdinate.latitude,locationCorrrdinate.longitude];
    }];
}

- (void)getCity {
    [[SJLocationManager shareManager] getCity:^(NSString *cityString) {
        _locaLabel.text = cityString;
    }];
}

- (void)getAddress {
    [[SJLocationManager shareManager] getAddress:^(NSString *addressString) {
        _locaLabel.text = addressString;
    }];
}

@end
