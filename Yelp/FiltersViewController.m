//
//  FiltersViewController.m
//  Yelp
//
//  Created by Liz Chaddock on 9/16/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "SelectorCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, SelectorCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property NSArray *sectionTitles;
@property NSDictionary *content;
@property BOOL deals;
@property NSNumber *distance;
@property NSInteger sortIndex;

- (void)initCategories;

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}forState:UIControlStateNormal];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectorCell" bundle:nil] forCellReuseIdentifier:@"SelectorCell"];
    [self.tableView reloadData];
    
    self.sectionTitles = @[@"Deals", @"Distance", @"Sort By", @"Category"];
    self.deals = NO;
}

- (NSDictionary *)filters
{
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    if (self.deals) {
        [filters setObject:@YES forKey:@"deals_filter"];
    }
    
    if (self.distance) {
        //set distance key
        [filters setObject:self.distance forKey:@"radius_filter"];
    }
    
    if (self.sortIndex) {
        //set sort key to index
        [filters setObject:@(self.sortIndex) forKey:@"sort"];
    }
    
    return filters;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 3) {
        return [self.categories count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 || indexPath.section == 0) {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        if (indexPath.section == 3) {
            cell.titleLabel.text = self.categories[indexPath.row][@"name"];
            cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
        } else if (indexPath.section == 0) {
            cell.titleLabel.text = @"Deals";
            cell.on = self.deals;
        }
        cell.delegate = self;
        return cell;
    } else {
        SelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectorCell"];
        cell.delegate = self;
        
        if (indexPath.section == 1) {
            //distance
            [cell.selector setTitle:@"0.3 mile" forSegmentAtIndex:0];
            [cell.selector setTitle:@"1 mile" forSegmentAtIndex:1];
            [cell.selector setTitle:@"5 miles" forSegmentAtIndex:2];
        } else {
            //sort by
            [cell.selector setTitle:@"Best match" forSegmentAtIndex:0];
            [cell.selector setTitle:@"Distance" forSegmentAtIndex:1];
            [cell.selector setTitle:@"Highest rated" forSegmentAtIndex:2];
        }
        return cell;
    }
}

#pragma mark - Selector Cell delegate methods
- (void)selectorCell:(SelectorCell *)cell didUpdateValue:(NSInteger)value
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSNumber *distances[3] = {@482, @1609, @8046};
    switch (indexPath.section) {
        case 1: {
            self.distance = distances[value];
            break;
        }
        case 2:
            self.sortIndex = value;
            break;
    }
}

#pragma mark - Switch Cell delegate methods
- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.section) {
        case 0:
            self.deals = value;
            break;
        case 3: {
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
            break;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method
-(void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initCategories {
    self.categories =
    @[
      @{@"name" : @"American, New", @"code": @"newamerican"},
      @{@"name" : @"American, Traditional", @"code": @"tradamerican"},
      @{@"name" : @"Asian Fusion", @"code": @"asianfusion"},
      @{@"name" : @"Burgers", @"code": @"burgers"},
      @{@"name" : @"Chinese", @"code": @"chinese" },
      @{@"name" : @"Fondue", @"code": @"fondue" },
      @{@"name" : @"Greek", @"code": @"greek" },
      @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
      @{@"name" : @"Hot Pot", @"code": @"hotpot" },
      @{@"name" : @"Japanese", @"code": @"japanese" },
      @{@"name" : @"Korean", @"code": @"korean" },
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name" : @"Sushi Bars", @"code": @"sushi" },
      @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
      @{@"name" : @"Thai", @"code": @"thai" },
      @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
    ];
}
@end
