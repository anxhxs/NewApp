//
//  ViewController.m
//  NewApp
//
//  Created by 安雄浩 on 16/4/11.
//  Copyright © 2016年 安雄浩. All rights reserved.
//

#import "ViewController.h"
#import "HYBNetworking.h"
#import "Url.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MyCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>
{
    UIProgressView *progrV;
    float i;
    UISlider *slider;
    
}
@property(nonatomic,retain)UICollectionView *collectionView;
@property(nonatomic,retain)UILongPressGestureRecognizer *longPress;
@property(nonatomic,retain)UIPanGestureRecognizer *panGes;
@property(nonatomic,retain)NSMutableArray *dataArr;
@property(nonatomic,retain)UIImageView *snapshotImg;

@property(nonatomic,retain)NSIndexPath *presentIndex;
@property(nonatomic,retain)NSIndexPath *currentIndex;
@property (nonatomic, assign) CGPoint panTranslation;

@property(nonatomic,assign)int dx;
@property(nonatomic,assign)int dy;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"NewApp";
    i = 50.0;
    
    slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 260, 300, 20)];
    slider.value = 0.1;
    [slider addTarget:self action:@selector(addChange) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:slider];
    
    progrV = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    progrV.progressTintColor = [UIColor redColor];
    progrV.trackTintColor = [UIColor yellowColor];
    progrV.progressImage = [UIImage imageNamed:@"test"];
    
    [progrV setFrame:CGRectMake(50, 100, 200, 20)];
    progrV.progress = 0.5;
    progrV.transform = CGAffineTransformMakeScale(1, 30);
    progrV.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
//    [self.view addSubview:progrV];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 80, 50, 30)];
    [btn setBackgroundColor:[UIColor blueColor]];
    [btn setTitle:@"增加" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addChange) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
    
    [HYBNetworking getWithUrl:kLoginUrl refreshCache:NO success:^(id response) {
        NSLog(@"%@",response[@"data"]);
        NSArray  *arr = [NSArray arrayWithArray:response[@"data"]];
        self.dataArr = [NSMutableArray arrayWithArray:arr];
        NSLog(@"%@",arr[0]);
        
        [self.collectionView reloadData];
    } fail:^(NSError *error) {
        
    }];
    [HYBNetworking cacheGetRequest:NO shoulCachePost:NO];
    NSLog(@"%llu",[HYBNetworking totalCacheSize]);
    
    self.snapshotImg = [[UIImageView alloc]init];
    self.snapshotImg.bounds = CGRectMake(0, 0, MAX_WIDTH_15 / 3, MAX_WIDTH_15 / 3);
    self.snapshotImg.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(MAX_WIDTH_15 / 3, MAX_WIDTH_15 / 3);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor whiteColor];
    UILongPressGestureRecognizer *  longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    longPressGesture.delegate = self;
    panGesture.delegate = self;
    [self.collectionView addGestureRecognizer:longPressGesture];
    [self.collectionView addGestureRecognizer:panGesture];
    self.longPress = longPressGesture;
    self.panGes = panGesture;

}
-(void)addChange{
//    NSLog(@"%f -- %f",i / 100.0,i);
    progrV.progress = slider.value;
//    i++;
}

-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.collectionView.userInteractionEnabled = NO;
            
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[sender locationInView:self.collectionView]];
            _currentIndex = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
            _presentIndex = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
            self.collectionView.scrollsToTop = NO;
            MyCollectionViewCell *cell = (MyCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            _snapshotImg.center = cell.center;
            
            _snapshotImg.image = cell.imageView.image;
            [self.collectionView addSubview:_snapshotImg];
            //////////
            _dx = cell.center.x-[sender locationInView:self.collectionView].x;
            _dy = cell.center.y-[sender locationInView:self.collectionView].y;
            
            CGRect fakeViewRect = cell.frame;
            fakeViewRect.size = CGSizeMake(MAX_WIDTH_15 / 3 +20, MAX_WIDTH_15 / 3 + 20);
            [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                NSLog(@"----%f",fakeViewRect.size.width);
                _snapshotImg.frame = fakeViewRect;
                _snapshotImg.center = cell.center;
            } completion:^(BOOL finished) {
                cell.hidden = YES;
            }];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            self.collectionView.userInteractionEnabled = YES;
            
            self.collectionView.scrollsToTop = NO;
            
            CGPoint point = [sender locationInView:self.collectionView];
            point = CGPointMake(point.x+_dx ,point.y+_dy);
            
            MyCollectionViewCell *cell = (MyCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:_currentIndex];
            
            CGRect fakeViewRect = cell.frame;
            fakeViewRect.size = CGSizeMake(MAX_WIDTH_15 / 3, MAX_WIDTH_15 / 3);
            [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                _snapshotImg.frame = fakeViewRect;
                _snapshotImg.center = cell.center;
                _snapshotImg.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            } completion:^(BOOL finished) {
                cell.hidden = NO;
                [_snapshotImg removeFromSuperview];
                
            }];
        }
            break;
        default:
            break;
    }
}
-(void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        {
            _panTranslation = [sender locationInView:self.collectionView];
            _snapshotImg.center = CGPointMake(_panTranslation.x+_dx, _panTranslation.y+_dy);
            
            NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:_snapshotImg.center];
            
            if (index) {
                _currentIndex = [NSIndexPath indexPathForItem:index.item inSection:index.section];
                if (_currentIndex.item == _presentIndex.item) {
                    
                    return;
                }
                
                [self.collectionView moveItemAtIndexPath:_presentIndex toIndexPath:_currentIndex];
            }
            
            NSObject *obj = _dataArr[_presentIndex.item];
            [_dataArr removeObjectAtIndex:_presentIndex.item];
            [_dataArr insertObject:obj atIndex:_currentIndex.item];
            
            _presentIndex = [NSIndexPath indexPathForItem:_currentIndex.item inSection:_currentIndex.section];
        }
            
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"结束移动");
            
            break;
        default:
            break;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArr.count;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = (MyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];

    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_dataArr[indexPath.row][@"pic_url"]] placeholderImage:[UIImage imageNamed:@""]];

    NSLog(@"%@",cell.imageView.image);
    return  cell;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.panGes isEqual:gestureRecognizer]) {
        if (self.longPress.state == 0 || self.longPress.state == 5) {
            return NO;
        }
    }else if ([self.longPress isEqual:gestureRecognizer]) {
        if (self.collectionView.panGestureRecognizer.state != 0 && self.collectionView.panGestureRecognizer.state != 5) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.panGes isEqual:gestureRecognizer]) {
        if (self.longPress.state != 0 && self.longPress.state != 5) {
            if ([self.longPress isEqual:otherGestureRecognizer]) {
                return YES;
            }
            return NO;
        }
    }else if ([self.longPress isEqual:gestureRecognizer]) {
        if ([self.longPress isEqual:otherGestureRecognizer]) {
            return YES;
        }
    }else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
        if (self.longPress.state == 0 || self.longPress.state == 5) {
            return NO;
        }
    }
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
//    AVAudioPlayer *palyer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:_dataArr[indexPath.row][@""]] error:nil];
//    UIWindow *window1 = [[UIApplication sharedApplication].delegate window];
//    window1.backgroundColor = [UIColor whiteColor];
//    MyCollectionViewCell *cell = (MyCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    
//    TheSecondViewController *vc = [[TheSecondViewController alloc]init];
//    vc.img = cell.imageView.image;
//    
//    UIImageView *imageView = [[UIImageView alloc]init];
//    imageView.image = cell.imageView.image;
//    imageView.bounds = cell.bounds;
//    imageView.center = CGPointMake(cell.center.x,cell.center.y-collectionView.contentOffset.y);
//    
//    [window1 addSubview:imageView];
//    
//    
//    AppDelegate *appdele = [UIApplication sharedApplication].delegate;
//    appdele.img = imageView;
//    
//    appdele.pushCenter = imageView.center;
//    appdele.popCenter = CGPointMake(70, 200);
//    
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        self.view.alpha = 0;
//        
//    } completion:^(BOOL finished) {
//        
//        [UIView animateWithDuration:0.5 animations:^{
//            imageView.bounds = CGRectMake(0, 0, 110, 110);
//            imageView.layer.shadowOffset = CGSizeMake(4, 4);
//            imageView.layer.shadowRadius = 30;
//            imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//            imageView.layer.shadowOpacity = 0.9;
//            imageView.center = appdele.popCenter;
//            
//        } completion:^(BOOL finished) {
//            
//            [UIView animateWithDuration:0.2 animations:^{
//                imageView.bounds = CGRectMake(0,0, 100, 100);
//                
//            } completion:^(BOOL finished) {
//                imageView.layer.shadowOffset = CGSizeMake(0, 0);
//                imageView.layer.shadowRadius = 0;
//                imageView.layer.shadowColor = [UIColor clearColor].CGColor;
//                [self performSelector:@selector(goToNextVc:) withObject:vc afterDelay:0.1];
//            }];
//        }];
//    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
