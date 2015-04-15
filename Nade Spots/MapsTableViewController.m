//
//  MapsTableViewController.m
//  Nade Spots
//
//  Created by Songge Chen on 2/23/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "MapsTableViewController.h"
#import "DetailViewController.h"


@interface MapsTableViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *mapTitle;
@property (nonatomic, strong) NSArray * maps;
@end

@implementation MapsTableViewController
@synthesize maps;
@synthesize mapTitle;

- (void) openJWYT {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/c/jamiew"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MAPS";
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navJWButton.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openJWYT) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 243, 32)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    NSString * mapsPath = [[NSBundle mainBundle]pathForResource:@"Maps" ofType:@"plist"];
    maps = [NSArray arrayWithContentsOfFile:mapsPath];
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, -16, 0, 0);
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_background.png"]];
    
    self.tableView.backgroundView = tempImageView;
    self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    //UIImage * title = [UIImage imageNamed:@"MAPS title.png"];
    //UIImageView * realTitle = [[UIImageView alloc] initWithImage:title];
    //realTitle.frame = CGRectMake(16, 0, 212.5, 85);
    //[self.tableView addSubview:realTitle];
    
    //filler space
    //mapTitle.frame = CGRectMake(0, 0, 1, 85);
    //mapTitle.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.maps count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary * mapInfo = maps[indexPath.row];
    NSString * mapName = mapInfo[@"MapName"];
    NSString * mapCellImagePath = [NSString stringWithFormat:@"%@_cell", mapName];
    [cell.imageView setImage:[UIImage imageNamed:mapCellImagePath]];
    
    [cell.imageView setFrame:CGRectMake(100, 0, [[UIScreen mainScreen]bounds].size.width, 85)];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailViewController * DVC = [segue destinationViewController];
    NSIndexPath * path = [self.tableView indexPathForSelectedRow];
    NSString * theMap = [maps objectAtIndex:path.row][@"MapName"];
    NSDictionary * mapDetails = [maps objectAtIndex:path.row];
    DVC.mapName = theMap;
    //DVC.title = theMap;
    DVC.mapDetails = mapDetails;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}



@end
