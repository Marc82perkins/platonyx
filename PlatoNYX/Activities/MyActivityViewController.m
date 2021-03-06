//
//  MyActivityViewController.m
//  PlatoNYX
//
//  Created by mobilestar on 8/17/16.
//  Copyright © 2016 marc. All rights reserved.
//

#import "MyActivityViewController.h"
#import "UpActivityTableViewCell.h"
#import "rankingTableViewCell.h"
#import "RankingViewController.h"

@interface MyActivityViewController ()<UITableViewDataSource, UITableViewDelegate>{
    
    IBOutlet UITableView *upTableView;
    IBOutlet UIView *rankingView;
    IBOutlet UIButton *tab1Btn;
    IBOutlet UIButton *tab2Btn;
    
    NSMutableArray *upPostArray;
    
    CLLocationCoordinate2D location;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
}
@end

@implementation MyActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    rankingView.hidden = YES;
}

- (void)initUI {
    
    CGRect itemRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RankingViewController *itemView = (RankingViewController*)[storyboard instantiateViewControllerWithIdentifier:@"rankingView"];
    [self addChildViewController:itemView];
    UIView *view = [[UIView alloc] initWithFrame:itemRect];
    [view addSubview:itemView.view];
    [rankingView addSubview:view];

}

- (void)initData {
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[appController.currentUser objectForKey:@"user_id"] forKey:@"user_id"];
    [self requestAPIPost:paramDic];
}

#pragma mark - API Request - get Recommended Post
- (void)requestAPIPost:(NSMutableDictionary *)dic {
    [commonUtils showActivityIndicatorColored:self.view];
    [NSThread detachNewThreadSelector:@selector(requestDataPost:) toTarget:self withObject:dic];
}

- (void)requestDataPost:(id) params {
    NSDictionary *resObj = nil;
    resObj = [commonUtils httpJsonRequest:API_URL_MY_POST withJSON:(NSMutableDictionary *) params];
    
    [commonUtils hideActivityIndicator];
    if (resObj != nil) {
        NSDictionary *result = (NSDictionary *)resObj;
        NSDecimalNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 1) {
            upPostArray = [[NSMutableArray alloc] init];
            upPostArray = [result objectForKey:@"up_posts"];
            
            appController.pastPostArray = [[result objectForKey:@"up_posts"] mutableCopy];
            
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
    [upTableView reloadData];
    [self initUI];
}

- (IBAction)upTabBtn:(id)sender {
    [tab1Btn setBackgroundColor:RGBA(28, 36, 51, 1.0f)];
    [tab2Btn setBackgroundColor:RGBA(35, 45, 62, 1.0f)];
    rankingView.hidden = YES;
    upTableView.hidden = NO;
}
- (IBAction)rantabkBtn:(id)sender {
    [tab2Btn setBackgroundColor:RGBA(28, 36, 51, 1.0f)];
    [tab1Btn setBackgroundColor:RGBA(35, 45, 62, 1.0f)];
    upTableView.hidden = YES;
    rankingView.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableViewDelegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [upPostArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == upTableView){
        return [UIScreen mainScreen].bounds.size.height - 190;
    }else {
        return [UIScreen mainScreen].bounds.size.height - 190;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UpActivityTableViewCell *cell = (UpActivityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UpActivityTableCell"];
    cell.activityNamelbl.text = [[upPostArray objectAtIndex:indexPath.row] objectForKey:@"post_caption"];
    cell.descTxt.text = [[upPostArray objectAtIndex:indexPath.row] objectForKey:@"post_desc"];
    
    span.latitudeDelta = 0.5;
    span.longitudeDelta = 0.5;
    
    location.latitude = [[[upPostArray objectAtIndex:indexPath.row] objectForKey:@"post_lati"] doubleValue];
    location.longitude = [[[upPostArray objectAtIndex:indexPath.row] objectForKey:@"post_long"] doubleValue];
    
    region.span = span;
    region.center = location;
    
    [cell.mapView setRegion:region animated:YES];
    
//        rankingTableViewCell *cell = (rankingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"rankingTableViewCell"];
  
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
