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

@property (nonatomic, strong) NSMutableArray *assetArray;

@end

@implementation ELCAssetTablePicker

#pragma mark - UI actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender
{
    [[self delegate] assetTablePickerIsDone:self];
}

#pragma mark - UITableViewController implementation

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

	UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(doneButtonTapped:)];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
    
    [self setTitle:[[self delegate] assetTablePickerTitleForLoadingMedia:self]];

    [[self tableView] setRowHeight:[ELCThumbnailsTableViewCell cellHeight]];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([ELCThumbnailsTableViewCell class]) bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[ELCThumbnailsTableViewCell reuseIdentifier]];
    
    [self loadAssets];
}

- (void)loadAssets {
    if ([_assetArray count] > 0) {
        return;
    }
    
    //Set to high priority since it's the only thing we are on the page and waiting.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSMutableArray *ALAssetArray = [NSMutableArray array];
        ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            
            if (asset != nil) {
                [ALAssetArray addObject:asset];
            } else {
                //Set array data and reload tableview in main queue.
                dispatch_sync(dispatch_get_main_queue(), ^{
                    _assetArray = ALAssetArray;
                    [self.tableView reloadData];
                    [self setTitle:[[self delegate] assetTablePickerTitleForSelectingMedia:self]];
                    
                    //Scroll to last row - in main queue also.
                    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
                    if (rowCount) {
                        NSIndexPath *path = [NSIndexPath indexPathForRow:rowCount - 1 inSection:0];
                        [[self tableView] scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    }
                });
            }
        };
        
        [_assetGroup enumerateAssetsUsingBlock:resultsBlock];
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
    //return ceil([self.assetGroup numberOfAssets] / (float) MAX_THUMBNAILS_PER_ROW);
    return ceil([_assetArray count] / (float) MAX_THUMBNAILS_PER_ROW);
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

    return cell;
}

#pragma mark - Asset helpers

- (NSArray*)assetsForIndexPath:(NSIndexPath*)indexPath
{
    //ALAssetsGroup *group  = [self assetGroup];
    NSInteger startIndex = [indexPath row] * MAX_THUMBNAILS_PER_ROW;
    NSInteger endIndex = startIndex + MIN([_assetArray count] - startIndex, MAX_THUMBNAILS_PER_ROW);
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, endIndex - startIndex)];
    //NSMutableArray *assets = [NSMutableArray arrayWithCapacity:[indexes count]];
    
    /*
    [group enumerateAssetsAtIndexes:indexes options:0 usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (index != NSNotFound)
            [assets addObject:asset];
    }];
     */
    
    return [_assetArray objectsAtIndexes:indexes];
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

@end
