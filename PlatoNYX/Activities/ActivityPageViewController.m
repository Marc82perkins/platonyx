//
//  ActivityPageViewController.m
//  PlatoNYX
//
//  Created by mobilestar on 8/14/16.
//  Copyright © 2016 marc. All rights reserved.
//

#import "ActivityPageViewController.h"
#import "ActivityListViewController.h"
#import "ActivityDetailViewController.h"

@interface ActivityPageViewController () {
    

    IBOutlet UIButton *joinActivityBtn;
    IBOutlet UIButton *attendantBtn;
    IBOutlet UIButton *detailActivityBtn;
    
    IBOutlet UIImageView *photoImg;
    IBOutlet UILabel *namelbl;
    IBOutlet UILabel *placelbl;
    IBOutlet UILabel *timelbl;
    IBOutlet UILabel *pricelbl;
    IBOutlet UITextView *aboutlbl;
    
    IBOutlet UIView *bottomBar;
    
}

@end

@implementation ActivityPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void) initUI {
    NSString* actImageUrl = [[NSString alloc] initWithFormat:@"%@/%@", SERVER_URL, [_itemDic objectForKey:@"post_photo_url"]];
    [commonUtils setImageViewAFNetworking:photoImg withImageUrl:actImageUrl withPlaceholderImage:[UIImage imageNamed:@"empty_photo"]];
    namelbl.text = [_itemDic objectForKey:@"post_caption"];
    aboutlbl.text = [_itemDic objectForKey:@"post_desc"];
    placelbl.text = [_itemDic objectForKey:@"post_place"];
    timelbl.text = [_itemDic objectForKey:@"post_date"];
    pricelbl.text = [_itemDic objectForKey:@"post_price"];
    
    bottomBar.hidden = YES;
    
    [commonUtils setCircleBorderButton:joinActivityBtn withBorderWidth:1.0f withBorderColor:[appController appMainColor]];
    [commonUtils setCircleBorderButton:attendantBtn withBorderWidth:1.0f withBorderColor:[appController appMainColor]];
    [commonUtils setCircleBorderButton:detailActivityBtn withBorderWidth:1.0f withBorderColor:[appController appMainColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goActivityList:(id)sender {
    [self performSegueWithIdentifier:@"goAttendants" sender:nil];
}

- (IBAction)goActivityDetail:(id)sender {
    [self performSegueWithIdentifier:@"goActivityDetail" sender:nil];
}

- (IBAction)joinActivity:(id)sender {

    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[_itemDic objectForKey:@"post_id"] forKey:@"post_id"];
    [paramDic setObject:[appController.currentUser objectForKey:@"user_id"] forKey:@"user_id"];
    [paramDic setObject:@"1" forKey:@"is_join"];
    [self requestAPIPost:paramDic];
}

#pragma mark - API Request - get Recommended Post
- (void)requestAPIPost:(NSMutableDictionary *)dic {
    [commonUtils showActivityIndicatorColored:self.view];
    [NSThread detachNewThreadSelector:@selector(requestDataPost:) toTarget:self withObject:dic];
}

- (void)requestDataPost:(id) params {
    NSDictionary *resObj = nil;
    resObj = [commonUtils httpJsonRequest:API_URL_JOIN_POST withJSON:(NSMutableDictionary *) params];
    
    [commonUtils hideActivityIndicator];
    if (resObj != nil) {
        NSDictionary *result = (NSDictionary *)resObj;
        NSDecimalNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 1) {
            
            [self performSelector:@selector(requestOverPost) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
        } else {
            NSString *msg = (NSString *)[resObj objectForKey:@"msg"];
            if([msg isEqualToString:@""]) msg = @"Please complete entire form";
            [commonUtils showVAlertSimple:@"Failed" body:msg duration:1.4];
        }
    } else {
        [commonUtils showVAlertSimple:@"Connection Error" body:@"Please check your internet connection status" duration:1.0];
    }
}

- (void)requestOverPost {
    bottomBar.hidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goAttendants"]) {
        ActivityListViewController *controller = segue.destinationViewController;
        controller.postId = [_itemDic objectForKey:@"post_id"];
    }else {
        ActivityDetailViewController *controller = segue.destinationViewController;
        controller.postDic = [_itemDic mutableCopy];
    }
}

@end
