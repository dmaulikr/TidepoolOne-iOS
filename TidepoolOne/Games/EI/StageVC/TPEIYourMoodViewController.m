//
//  TPEIYourMoodViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/2/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEIYourMoodViewController.h"
#import "TPEmotionCellView.h"

@interface TPEIYourMoodViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    TPBarButtonItem *_rightButton;
    NSMutableArray *_eventArray;
}
@end

@implementation TPEIYourMoodViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerClass:[TPEmotionCellView class] forCellWithReuseIdentifier:@"TPEmotionCellView"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    _selectedEmotionIndex = -1;
    _eventArray = [NSMutableArray array];    
//    _rightButton = [[TPBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(submitStage:)];
//    _rightButton.tintColor = [UIColor blueColor];
//    self.gameVC.navigationItem.rightBarButtonItem = _rightButton;
    self.type = @"survey";
    [ self logLevelStarted];
}

- (IBAction)submitStage:(id)sender {
    self.gameVC.navigationItem.rightBarButtonItem = nil;
    NSMutableArray *data = [NSMutableArray array];
    [data addObject:@{@"question_id":@"emotion22",@"topic":@"emotion",@"answer":_emotions[_selectedEmotionIndex]}];
    [self logLevelCompletedWithAdditionalData:nil summary:@{@"data":data}];
    [self stageOver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setData:(NSDictionary *)data
{
    [super setData:data];
    if (data) {
        NSMutableArray *emo = [@[] mutableCopy];
        NSArray *options = data[@"data"][0][@"options"];
        for (NSDictionary *item in options) {
            [emo addObject:item[@"value"]];
        }
        self.emotions = emo;
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.emotions count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TPEmotionCellView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"TPEmotionCellView" forIndexPath:indexPath];
    [cell setEmotion:_emotions[indexPath.row] selected:NO];
    return cell;
}

-(void)setSelectedEmotionIndex:(int)selectedEmotionIndex
{
    // deselect previous if possible
    if (_selectedEmotionIndex != -1) {
        TPEmotionCellView *previousSelectedCell = (TPEmotionCellView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedEmotionIndex inSection:0]];
        [previousSelectedCell setEmotion:_emotions[_selectedEmotionIndex] selected:NO];
    }
    // get new emotion
    _selectedEmotionIndex = selectedEmotionIndex;
    TPEmotionCellView *newlySelectedCell = (TPEmotionCellView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selectedEmotionIndex inSection:0]];
    if (selectedEmotionIndex != -1) {
        [newlySelectedCell setEmotion:_emotions[selectedEmotionIndex] selected:YES];
    }
    _selectedEmotionIndex = selectedEmotionIndex;
    [self submitStage:nil];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedEmotionIndex == indexPath.row) {
        self.selectedEmotionIndex = -1;
    } else {
        self.selectedEmotionIndex = indexPath.row;
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float halfWidth = self.view.bounds.size.width/2 - 5;
    return CGSizeMake(halfWidth, halfWidth + 20);
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


@end
