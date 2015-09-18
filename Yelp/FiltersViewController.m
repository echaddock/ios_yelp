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
      @{@"name" : @"Afghan", @"code": @"afghani"},
      @{@"name" : @"African", @"code": @"african"},
      @{@"name" : @"American, New", @"code": @"newamerican"},
      @{@"name" : @"American, Traditional", @"code": @"tradamerican"},
      @{@"name" : @"Arabian", @"code": @"arabian"},
      @{@"name" : @"Argentine", @"code": @"argentine"},
      @{@"name" : @"Armenian", @"code": @"armenian"},
      @{@"name" : @"Asian Fusion", @"code": @"asianfusion"},
      @{@"name" : @"Asturian", @"code": @"asturian"},
      @{@"name" : @"Australian", @"code": @"australian"},
      @{@"name" : @"Austrian", @"code": @"austrian"},
      @{@"name" : @"Baguettes", @"code": @"baguettes"},
      @{@"name" : @"Bangladeshi", @"code": @"bangladeshi"},
      @{@"name" : @"Barbeque", @"code": @"bbq"},
      @{@"name" : @"Basque", @"code": @"basque"},
      @{@"name" : @"Bavarian", @"code": @"bavarian"},
      @{@"name" : @"Beer Garden", @"code": @"beergarden"},
      @{@"name" : @"Beer Hall", @"code": @"beerhall"},
      @{@"name" : @"Beisl", @"code": @"beisl"},
      @{@"name" : @"Belgian", @"code": @"belgian"},
      @{@"name" : @"Bistros", @"code": @"bistros"},
      @{@"name" : @"Black Sea", @"code": @"blacksea"},
      @{@"name" : @"Brasseries", @"code": @"brassereis"},
      @{@"name" : @"Brazilian", @"code": @"brazilian"},
      @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
      @{@"name" : @"British", @"code": @"british"},
      @{@"name" : @"Buffets", @"code": @"buffets"},
      @{@"name" : @"Bulgarian", @"code": @"bulgarian"},
      @{@"name" : @"Burgers", @"code": @"burgers"},
      @{@"name" : @"Burmese", @"code": @"burmese"},
      @{@"name" : @"Cafes", @"code": @"cafes"},
      @{@"name" : @"Cafeteria", @"code": @"cafeteria"},
      @{@"name" : @"Cajun/Creole", @"code": @"cajun"},
      @{@"name" : @"Cambodian", @"code": @"cambodian"},
      @{@"name" : @"Canadian", @"code": @"New)" },
      @{@"name" : @"Canteen", @"code": @"canteen" },
      @{@"name" : @"Caribbean", @"code": @"caribbean" },
      @{@"name" : @"Catalan", @"code": @"catalan" },
      @{@"name" : @"Chech", @"code": @"chech" },
      @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
      @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
      @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
      @{@"name" : @"Chilean", @"code": @"chilean" },
      @{@"name" : @"Chinese", @"code": @"chinese" },
      @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
      @{@"name" : @"Corsican", @"code": @"corsican" },
      @{@"name" : @"Creperies", @"code": @"creperies" },
      @{@"name" : @"Cuban", @"code": @"cuban" },
      @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
      @{@"name" : @"Cypriot", @"code": @"cypriot" },
      @{@"name" : @"Czech", @"code": @"czech" },
      @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
      @{@"name" : @"Danish", @"code": @"danish" },
      @{@"name" : @"Delis", @"code": @"delis" },
      @{@"name" : @"Diners", @"code": @"diners" },
      @{@"name" : @"Dumplings", @"code": @"dumplings" },
      @{@"name" : @"Eastern European", @"code": @"eastern_european" },
      @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
      @{@"name" : @"Fast Food", @"code": @"hotdogs" },
      @{@"name" : @"Filipino", @"code": @"filipino" },
      @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
      @{@"name" : @"Fondue", @"code": @"fondue" },
      @{@"name" : @"Food Court", @"code": @"food_court" },
      @{@"name" : @"Food Stands", @"code": @"foodstands" },
      @{@"name" : @"French", @"code": @"french" },
      @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
      @{@"name" : @"Galician", @"code": @"galician" },
      @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
      @{@"name" : @"Georgian", @"code": @"georgian" },
      @{@"name" : @"German", @"code": @"german" },
      @{@"name" : @"Giblets", @"code": @"giblets" },
      @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
      @{@"name" : @"Greek", @"code": @"greek" },
      @{@"name" : @"Halal", @"code": @"halal" },
      @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
      @{@"name" : @"Heuriger", @"code": @"heuriger" },
      @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
      @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
      @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
      @{@"name" : @"Hot Pot", @"code": @"hotpot" },
      @{@"name" : @"Hungarian", @"code": @"hungarian" },
      @{@"name" : @"Iberian", @"code": @"iberian" },
      @{@"name" : @"Indian", @"code": @"indpak" },
      @{@"name" : @"Indonesian", @"code": @"indonesian" },
      @{@"name" : @"International", @"code": @"international" },
      @{@"name" : @"Irish", @"code": @"irish" },
      @{@"name" : @"Island Pub", @"code": @"island_pub" },
      @{@"name" : @"Israeli", @"code": @"israeli" },
      @{@"name" : @"Italian", @"code": @"italian" },
      @{@"name" : @"Japanese", @"code": @"japanese" },
      @{@"name" : @"Jewish", @"code": @"jewish" },
      @{@"name" : @"Kebab", @"code": @"kebab" },
      @{@"name" : @"Korean", @"code": @"korean" },
      @{@"name" : @"Kosher", @"code": @"kosher" },
      @{@"name" : @"Kurdish", @"code": @"kurdish" },
      @{@"name" : @"Laos", @"code": @"laos" },
      @{@"name" : @"Laotian", @"code": @"laotian" },
      @{@"name" : @"Latin American", @"code": @"latin" },
      @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
      @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
      @{@"name" : @"Malaysian", @"code": @"malaysian" },
      @{@"name" : @"Meatballs", @"code": @"meatballs" },
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
      @{@"name" : @"Milk Bars", @"code": @"milkbars" },
      @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
      @{@"name" : @"Modern European", @"code": @"modern_european" },
      @{@"name" : @"Mongolian", @"code": @"mongolian" },
      @{@"name" : @"Moroccan", @"code": @"moroccan" },
      @{@"name" : @"New Zealand", @"code": @"newzealand" },
      @{@"name" : @"Night Food", @"code": @"nightfood" },
      @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
      @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
      @{@"name" : @"Oriental", @"code": @"oriental" },
      @{@"name" : @"Pakistani", @"code": @"pakistani" },
      @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
      @{@"name" : @"Parma", @"code": @"parma" },
      @{@"name" : @"Persian/Iranian", @"code": @"persian" },
      @{@"name" : @"Peruvian", @"code": @"peruvian" },
      @{@"name" : @"Pita", @"code": @"pita" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name" : @"Polish", @"code": @"polish" },
      @{@"name" : @"Portuguese", @"code": @"portuguese" },
      @{@"name" : @"Potatoes", @"code": @"potatoes" },
      @{@"name" : @"Poutineries", @"code": @"poutineries" },
      @{@"name" : @"Pub Food", @"code": @"pubfood" },
      @{@"name" : @"Rice", @"code": @"riceshop" },
      @{@"name" : @"Romanian", @"code": @"romanian" },
      @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
      @{@"name" : @"Rumanian", @"code": @"rumanian" },
      @{@"name" : @"Russian", @"code": @"russian" },
      @{@"name" : @"Salad", @"code": @"salad" },
      @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
      @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
      @{@"name" : @"Scottish", @"code": @"scottish" },
      @{@"name" : @"Seafood", @"code": @"seafood" },
      @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
      @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
      @{@"name" : @"Singaporean", @"code": @"singaporean" },
      @{@"name" : @"Slovakian", @"code": @"slovakian" },
      @{@"name" : @"Soul Food", @"code": @"soulfood" },
      @{@"name" : @"Soup", @"code": @"soup" },
      @{@"name" : @"Southern", @"code": @"southern" },
      @{@"name" : @"Spanish", @"code": @"spanish" },
      @{@"name" : @"Steakhouses", @"code": @"steak" },
      @{@"name" : @"Sushi Bars", @"code": @"sushi" },
      @{@"name" : @"Swabian", @"code": @"swabian" },
      @{@"name" : @"Swedish", @"code": @"swedish" },
      @{@"name" : @"Swiss Food", @"code": @"swissfood" },
      @{@"name" : @"Tabernas", @"code": @"tabernas" },
      @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
      @{@"name" : @"Tapas Bars", @"code": @"tapas" },
      @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
      @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
      @{@"name" : @"Thai", @"code": @"thai" },
      @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
      @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
      @{@"name" : @"Trattorie", @"code": @"trattorie" },
      @{@"name" : @"Turkish", @"code": @"turkish" },
      @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
      @{@"name" : @"Uzbek", @"code": @"uzbek" },
      @{@"name" : @"Vegan", @"code": @"vegan" },
      @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
      @{@"name" : @"Venison", @"code": @"venison" },
      @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
      @{@"name" : @"Wok", @"code": @"wok" },
      @{@"name" : @"Wraps", @"code": @"wraps" },
      @{@"name" : @"Yugoslav", @"code": @"yugoslav" },
    ];
}
@end
