//
//  PeersViewController.m
//  NetworkingApp
//
//  Created by Akash Subramanian on 11/22/15.
//  Copyright © 2015 Akash Subramanian. All rights reserved.
//

#import "PeersViewController.h"
#import <Parse/Parse.h>
#import "ParseDataManager.h"
#import "PeersTableViewCell.h"
#import "ProfileViewController.h"
#import <linkedin-sdk/LISDK.h>
@import CoreLocation;
#define otherProfileURL @"https://api.linkedin.com/v1/people/id="

@interface PeersViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic, strong) ParseDataManager *dataManager;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *nearbyPeers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *profiles;
@property (nonatomic) NSMutableDictionary *profile;
@end

@implementation PeersViewController
int count = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestAlwaysAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
   
    _dataManager = [ParseDataManager sharedManager];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updatePeers) userInfo:NULL repeats:YES];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _nearbyPeers = [[NSMutableArray alloc] init];
    _profiles = [[NSMutableArray alloc] init];
    _profile = [[NSMutableDictionary alloc] init];
    [self updatePeers];
    
}
- (IBAction)logOutUser:(UIBarButtonItem *)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"logOut" sender:self];
    
}

- (void)updateLocation {
     [self.locationManager startUpdatingLocation];
    NSNumber *lat = [[NSNumber alloc] initWithDouble:_currentLocation.latitude];
    NSNumber *lng = [[NSNumber alloc] initWithDouble:_currentLocation.longitude];
    [[PFUser currentUser] setObject:lat forKey:@"latitude"];
    [[PFUser currentUser] setObject:lng forKey:@"longitude"];
    [[PFUser currentUser] saveInBackground];
    [self.locationManager stopUpdatingLocation];
}

- (void) loadPeers {
    [_dataManager loadNearbyPeersWithCallback:^(NSMutableArray * peers) {
        if (![peers isEqualToArray:_nearbyPeers]) {
            _nearbyPeers = peers;
            
        }
    }];
    // need to reload data in table view

      [_tableView reloadData];
}

- (void)updatePeers {
    [self updateLocation];
    [self loadPeers];
}
- (IBAction)viewMyProfile:(UIBarButtonItem *)sender {
    _profile = [[NSUserDefaults standardUserDefaults] valueForKey:@"profileData"];
     [self performSegueWithIdentifier:@"viewProfile" sender:self];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = locations.lastObject.coordinate;
    if (count == 0) {
        count ++;
        [self updateLocation];
        [self loadPeers];
    }
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"no. of peers = %lu", _nearbyPeers.count);
    return [_nearbyPeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeersTableViewCell *cell = (PeersTableViewCell *) [[UITableViewCell alloc] init];
    cell = [tableView dequeueReusableCellWithIdentifier: @"peerCell"];
    if (cell == NULL) {
        cell = (PeersTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"peerCell"];
    }
    
    PFObject *peer = [_nearbyPeers objectAtIndex:indexPath.row];
    NSString *linkedinID = [peer objectForKey:@"linkedinid"];
    //NSLog(@"linkedinID = %@", linkedinID);
    
    [[LISDKAPIHelper sharedInstance] getRequest:[NSString stringWithFormat:@"%@%@%@", otherProfileURL, linkedinID, @":(id,first-name,last-name,maiden-name,headline,email-address,summary,specialties,picture-urls::(original),positions,public-profile-url)?format=json"] success:^(LISDKAPIResponse * response) {
        NSData *responseData = [[response data] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        
//        if ([dictionary objectForKey:@"emailAdress"] == NULL || [[dictionary objectForKey:@"emailAdress"] length] == 0) {
        NSLog(@"email = %@", [peer objectForKey:@"email"]);
            [dictionary setValue:[peer objectForKey:@"email"] forKey:@"emailAddress"];
       // }
        [_profiles addObject:dictionary];
        //NSLog(@"%@", dictionary);
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [dictionary objectForKey:@"firstName"], [dictionary objectForKey:@"lastName"]];
        cell.headerLabel.text = [dictionary objectForKey:@"headline"];
        NSString *imageURL = [[[dictionary objectForKey:@"pictureUrls"] objectForKey:@"values"] firstObject];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            // Switch to Main Queue as we will be updating the UI.
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.photoImageView.frame = CGRectIntegral(cell.photoImageView.frame);
                cell.photoImageView.image = [UIImage imageWithData:imageData];
            });
        });
        
       
        
    } error:^(LISDKAPIError * error) {
        
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    PFObject *peer = [_nearbyPeers objectAtIndex:indexPath.row];
//    NSString *linkedinID = [peer objectForKey:@"linkedinid"];
    
//    [[LISDKAPIHelper sharedInstance] getRequest:[NSString stringWithFormat:@"%@%@%@", otherProfileURL, linkedinID, @":(id,first-name,last-name,maiden-name,headline,email-address,summary,specialties,picture-url,positions,public-profile-url)?format=json"] success:^(LISDKAPIResponse * response) {
//        NSData *responseData = [[response data] dataUsingEncoding:NSUTF8StringEncoding];
//        _profile = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
//        //NSLog(@"%@", dictionary);
//        
//       
//        
//    } error:^(LISDKAPIError * error) {
//        
//    }];
    _profile = [_profiles objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"viewProfile" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"viewProfile"]) {
        ProfileViewController *pvc = (ProfileViewController *) segue.destinationViewController;
        pvc.profileData = _profile;
    }
}


@end
