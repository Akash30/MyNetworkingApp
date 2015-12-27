//
//  PeersTableViewCell.h
//  NetworkingApp
//
//  Created by Akash Subramanian on 11/27/15.
//  Copyright © 2015 Akash Subramanian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@end
