//
//  MapsTableViewController.m
//  Nade Spots
//
//  Created by Songge Chen on 2/23/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "MapsTableViewController.h"
#import "DetailViewController.h"

@implementation MapsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.debug = YES;
    
    self.title = @"MAPS";
    UINavigationBar * navbar = self.navigationController.navigationBar;
    [navbar setBarTintColor:UIColorFromRGB(0xF44336)];
    [navbar setTintColor:[UIColor whiteColor]];
    navbar.translucent = NO;
    navbar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    navbar.layer.shadowColor = [UIColor blackColor].CGColor;
    navbar.layer.shadowOffset = CGSizeMake(0.0f, 2.25f);
    navbar.layer.shadowRadius = 4.0f;
    navbar.layer.shadowOpacity = 0.5f;
    self.tableView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.NSFM = [[NSFileManager alloc] init];
    
    /*
     Maps.plist arranged as:
     item #
     -> { mapname(contained in item#), nadetype[] }
     -> { destination[] }
     -> { xCord, yCord, origin[] }
     -> { xCord, yCord, creator, path}
     */
    
    NSString * mapsPath = [[NSBundle mainBundle]pathForResource:@"Maps" ofType:@"plist"];
    self.maps = [NSArray arrayWithContentsOfFile:mapsPath];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    MapTableViewCell * cell = (MapTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary * mapInfo = self.maps[indexPath.row];
    NSString * mapName = mapInfo[@"MapName"];
    
    if ([self filesFoundForNadeType:mapInfo[@"Smokes"]]
        && [self fileFoundForOrigin:mapInfo[@"Flashes"]]) {
        [cell.downloadButton setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
    } else {
        
    }
    
    [[cell mapTitle] setText:mapName];
    [[cell mapTitle] setTextColor:[UIColor blackColor]];
    
    [[cell mapImage] setImage:[UIImage imageNamed:[mapName stringByAppendingString:@"_icon.png"]]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell mapImage].layer.shadowColor = [UIColor blackColor].CGColor;
    [cell mapImage].layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    [cell mapImage].layer.shadowRadius = 2.0f;
    [cell mapImage].layer.shadowOpacity = 0.5f;
    
    UIView * seperator = [[UIView alloc] initWithFrame:CGRectMake([cell mapImage].frame.size.width + 25, cell.frame.size.height - 1, fmaxf(cell.frame.size.width, cell.frame.size.height), 1)];
    seperator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
    
    [cell addSubview:seperator];
    
    return cell;
}

-(BOOL) filesFoundForNadeType:(NSDictionary *) destinationDictionary {
    if (self.debug) NSLog(@"Iterating through Type Dictionary");
    for (id key in destinationDictionary) {
            if(![self filesFoundForDestination:[destinationDictionary objectForKey:key]]) return NO;
    }
    return YES;
}

-(BOOL) filesFoundForDestination:(NSDictionary *) destination {
        for (id key in destination) {
        if (![key isEqualToString:@"xCord"] && ![key isEqualToString:@"yCord"]) {
            NSDictionary * origin = [destination objectForKey:key];
            if (![self fileFoundForOrigin:origin]) return NO;
        }
    }
    return YES;
}

-(BOOL) fileFoundForOrigin:(NSDictionary *) origin {
    NSString * path = [[NSBundle mainBundle] pathForResource:[origin objectForKey:@"path"] ofType:@"mp4"];
    if (self.debug) NSLog(@"%@ found: %@", path, ([self.NSFM fileExistsAtPath:[origin objectForKey:path]])? @"YES" : @"NO");
    return [self.NSFM fileExistsAtPath:path];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MapTableViewCell * cell = (MapTableViewCell *) sender;
    NSString * theMap = [[cell mapTitle] text];
    DetailViewController * DVC = [segue destinationViewController];
    NSIndexPath * path = [self.tableView indexPathForSelectedRow];

    NSDictionary * mapDetails = [self.maps objectAtIndex:path.row];
    DVC.mapName = theMap;
    DVC.title = theMap;
    DVC.mapDetails = mapDetails;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}



@end
