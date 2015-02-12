//
//  ViewController.m
//  LocalizableSupport
//
//  Created by Deniss Kaibagarovs on 2/11/15.
//  Copyright (c) 2015 Deniss Kaibagarovs. All rights reserved.
//

#import "ViewController.h"
#import "LocalizationManager.h"

@interface ViewController () < UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelMain;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_localize];
    
    // Subscribe to notifications from LocalizationManager
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_localize) name:LocalizationManagerLanguageDidChangeNotification object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2; /// TBD change to languages count
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = (indexPath.row) ? @"en" : @"ru";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   [LocalizationManager updateLanguage:(indexPath.row) ? @"en" : @"ru"];
}

- (void)p_localize {
    self.labelMain.text = [LocalizationManager translationForKey:@"hello"];
}



@end
