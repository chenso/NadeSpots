//
//  MapTableViewCell.h
//  Nade Spots
//
//  Created by Songge Chen on 5/28/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * mapTitle;
@property (nonatomic, weak) IBOutlet UILabel * mapSubtitle;
@property (nonatomic, weak) IBOutlet UIImageView * mapImage;
@property (nonatomic, weak) IBOutlet UIButton * downloadButton;
@end
