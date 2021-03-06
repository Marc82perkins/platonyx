//
//  ActivityListViewController.m
//  PlatoNYX
//
//  Created by mobilestar on 8/12/16.
//  Copyright © 2016 marc. All rights reserved.
//

#import "ActivityListViewController.h"
#import "ProfileViewController.h"

@interface ActivityListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    
    NSUInteger originalIndex, selectedIndex;
    NSArray* mainArray;
    NSMutableDictionary *itemDic;
}
@property (strong, nonatomic) IBOutlet UICollectionView *attendCollectionView;

@end

@implementation ActivityListViewController

//@synthesize mainCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    [self initData];
}

- (void)initUI {
    int kCellsPerRow = 2, kCellsPerCol = 6;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*) _attendCollectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(_attendCollectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow - 1);
    CGFloat cellWidth = availableWidthForCells / (float)kCellsPerRow;
    
    CGFloat availableHeightForCells = CGRectGetHeight(_attendCollectionView.frame) - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom - flowLayout.minimumInteritemSpacing * (kCellsPerCol - 1);
    CGFloat cellHeight = availableHeightForCells / (float)kCellsPerCol;
    
    flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData {
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:_postId forKey:@"post_id"];
    [self requestAPIPost:paramDic];
}

#pragma mark - API Request - get Recommended Post
- (void)requestAPIPost:(NSMutableDictionary *)dic {
    [commonUtils showActivityIndicatorColored:self.view];
    [NSThread detachNewThreadSelector:@selector(requestDataPost:) toTarget:self withObject:dic];
}

- (void)requestDataPost:(id) params {
    NSDictionary *resObj = nil;
    resObj = [commonUtils httpJsonRequest:API_URL_POST_ATTEND withJSON:(NSMutableDictionary *) params];
    
    [commonUtils hideActivityIndicator];
    if (resObj != nil) {
        NSDictionary *result = (NSDictionary *)resObj;
        NSDecimalNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 1) {
            mainArray = [[NSMutableArray alloc] init];
            mainArray = [result objectForKey:@"attend"];
            
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
    [_attendCollectionView reloadData];
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [mainArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ActivityListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"attendantCell" forIndexPath:indexPath];
    
    itemDic = [mainArray objectAtIndex:indexPath.item];
    NSString* imageUrl = [[NSString alloc] initWithFormat:@"%@/%@", SERVER_URL, [itemDic objectForKey:@"user_photo_url"]];
    [commonUtils setImageViewAFNetworking:cell.activityPhotoImgView withImageUrl:imageUrl withPlaceholderImage:[UIImage imageNamed:@"empty_photo"]];
    
    [commonUtils cropCircleImage:cell.activityPhotoImgView];
    [commonUtils setCircleBorderImage:cell.activityPhotoImgView withBorderWidth:2.0f withBorderColor:[UIColor whiteColor]];
    
    cell.activityUnamelbl.text = @"";
    cell.activityGenderlbl.text = @"";
    cell.activityAgelbl.text = @"";
    
//    [cell.activityGenderlbl setText:[dic objectForKey:@"photo_id"]];
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ProfileViewController* myController = [self.storyboard instantiateViewControllerWithIdentifier:@"otherProfile"];
    myController.itemDic = [itemDic mutableCopy];
    [self.navigationController pushViewController:myController animated:YES];
}

@end
