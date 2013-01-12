//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCThumbnailsTableViewCell.h"


static const NSInteger MAX_THUMBNAILS_PER_ROW = 4;


@interface ELCAssetTablePicker ()
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end


@implementation ELCAssetTablePicker

#pragma mark - UI actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    [[self delegate] assetTablePickerIsDone:self];
}

#pragma mark - UITableViewController implementation

-(void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

	UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(doneButtonTapped:)];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    [self setTitle:[[self delegate] assetTablePickerTitleForSelectingMedia:self]];

    [[self tableView] setRowHeight:[ELCThumbnailsTableViewCell cellHeight]];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([ELCThumbnailsTableViewCell class]) bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[ELCThumbnailsTableViewCell reuseIdentifier]];
    
    [self loadAssets];
}

- (void)loadAssets
{
    [self displayActivityViewAnimated:NO];

    // Set to high priority since it's the only thing we are on the page and waiting.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *assets = [NSMutableArray arrayWithCapacity:[[self assetGroup] numberOfAssets]];
        [[self assetGroup] enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset)
                [assets addObject:asset];
            else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self hideActivityViewAnimated:NO];

                    [self setAssets:assets];
                    [self.tableView reloadData];
                    [self setTitle:[[self delegate] assetTablePickerTitleForSelectingMedia:self]];

                    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
                    if (rowCount) {
                        NSIndexPath *path = [NSIndexPath indexPathForRow:rowCount - 1 inSection:0];
                        [[self tableView] scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    }
                });
            }
        }];
    });
}

#pragma mark - ELCThumbnailsTableViewCellDelegate implementation

- (BOOL)tumbnailsTableViewCell:(ELCThumbnailsTableViewCell *)cell canToggleSelectionOfAsset:(ALAsset *)asset
{
    if ([self isAssetSelected:asset])
        return [[self delegate] assetTablePicker:self canDeselectAsset:asset];
    else
        return [[self delegate] assetTablePicker:self canSelectAsset:asset];
}

- (void)tumbnailsTableViewCell:(ELCThumbnailsTableViewCell *)cell didToggleSelectionOfAsset:(ALAsset *)asset
{
    if ([self isAssetSelected:asset])
        [[self delegate] assetTablePicker:self didDeselectAsset:asset];
    else
        [[self delegate] assetTablePicker:self didSelectAsset:asset];
}

#pragma mark UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil([[self assets] count] / (float) MAX_THUMBNAILS_PER_ROW);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [ELCThumbnailsTableViewCell reuseIdentifier];
    ELCThumbnailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    [cell setSelectedAssetOverlayImage:[[self delegate] selectedAssetOverlayImage:self]];
    [cell setDelegate:self];

    NSArray *assets = [self assetsForIndexPath:indexPath];
    [cell setAssets:assets];
    [cell setSelectedAssetIndexes:[self indexesOfSelectedAssets:assets]];
    [cell setPreSelectedAssetIndexes:[self indexesOfPreSelectedAssets:assets]];

    return cell;
}

#pragma mark - Asset helpers

- (NSArray*)assetsForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger startIndex = [indexPath row] * MAX_THUMBNAILS_PER_ROW;
    NSInteger endIndex = startIndex + MIN([[self assets] count] - startIndex, MAX_THUMBNAILS_PER_ROW);
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, endIndex - startIndex)];

    return [[self assets] objectsAtIndexes:indexes];
}


- (NSIndexSet *)indexesOfSelectedAssets:(NSArray *)assets
{
    return [assets indexesOfObjectsPassingTest:^BOOL(ALAsset *asset, NSUInteger idx, BOOL *stop) {
        return [self isAssetSelected:asset];
    }];
}

- (BOOL)isAssetSelected:(ALAsset *)asset
{
    return [[self delegate] assetTablePicker:self isAssetSelected:asset];
}

- (NSIndexSet *)indexesOfPreSelectedAssets:(NSArray *)assets
{
    return [assets indexesOfObjectsPassingTest:^BOOL(ALAsset *asset, NSUInteger idx, BOOL *stop) {
        return [self isAssetPreSelected:asset];
    }];
}

- (BOOL)isAssetPreSelected:(ALAsset *)asset
{
    return [[self delegate] assetTablePicker:self isAssetPreSelected:asset];
}


#pragma mark - Activity view management

- (void)displayActivityViewAnimated:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.2 : 0;
    UIActivityIndicatorView *activityIndicator = [self activityIndicator];
    CGRect viewFrame = [[self view] frame];
    CGRect activityIndicatorFrame = [activityIndicator frame];
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect navBarFrame = [[[self navigationController] navigationBar] frame];
    viewFrame.size.height = screenBounds.size.height - statusBarFrame.size.height - navBarFrame.size.height;
    activityIndicatorFrame.origin.x = round((viewFrame.size.width - activityIndicatorFrame.size.width) / 2);
    activityIndicatorFrame.origin.y = round((viewFrame.size.height - activityIndicatorFrame.size.height) / 2);
    [activityIndicator setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
    [activityIndicator setFrame:activityIndicatorFrame];
    [activityIndicator setAlpha:0];
    [activityIndicator startAnimating];
    [[self tableView] addSubview:activityIndicator];
    [[self tableView] setScrollEnabled:NO];
    [UIView animateWithDuration:duration animations:^{ [activityIndicator setAlpha:1]; }];
}

- (void)hideActivityViewAnimated:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.2 : 0;
    [UIView animateWithDuration:duration
                     animations:^{
                         [[self activityIndicator] setAlpha:0];
                     }
                     completion:^(BOOL finished) {
                         [[self activityIndicator] removeFromSuperview];
                         [self setActivityIndicator:nil];
                         [[self tableView] setScrollEnabled:YES];
                     }];
}

- (BOOL)isDisplayingActivityView
{
    return !!_activityIndicator;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicator setHidesWhenStopped:YES];
    }

    return _activityIndicator;
}

@end
