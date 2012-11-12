//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"


static const NSInteger MAX_THUMBNAILS_PER_ROW = 4;


@interface ELCAssetTablePicker ()
@property (nonatomic, retain) NSMutableArray *selectedAssets;
@end


@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize assetGroup;
@synthesize selectedAssets = _selectedAssets;

-(void)viewDidLoad {

    [self setSelectedAssets:[NSMutableArray array]];
        
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

	UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
	[self setTitle:[self titleForLoadingMedia]];

    // Show partial while full list loads
	//[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
        if (rowCount) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:rowCount - 1 inSection:0];
            [[self tableView] scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    });
}

- (void) doneAction:(id)sender {
    [self.parent selectedAssets:[self selectedAssets]];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.assetGroup numberOfAssets] / (float) MAX_THUMBNAILS_PER_ROW);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)indexPath {

    ALAssetsGroup *group  = [self assetGroup];
    NSInteger startIndex = [indexPath row] * MAX_THUMBNAILS_PER_ROW;
    NSInteger endIndex = startIndex + MIN([group numberOfAssets] - startIndex, MAX_THUMBNAILS_PER_ROW);
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, endIndex - startIndex)];

    NSMutableArray *views = [NSMutableArray arrayWithCapacity:[indexes count]];
    [group enumerateAssetsAtIndexes:indexes options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        ELCAsset *assetView = [[ELCAsset alloc] initWithAsset:result];
        [assetView setParent:self];
        [assetView setDelegate:self];
        [views addObject:assetView];
        [assetView release];
    }];

    return views;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }	
	else 
    {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    return [[self selectedAssets] count];
}

- (void)dealloc 
{
    [_selectedAssets release];
    [selectedAssetsLabel release];
    [super dealloc];    
}

#pragma mark - ELCAssetDelegate implementation

- (BOOL)assetCanBeSelected:(ELCAsset *)asset
{
    return [[self parent] canSelectAsset:asset];
}

- (BOOL)assetCanBeDeselected:(ELCAsset *)asset
{
    return [[self parent] canDeselectAsset:asset];
}

- (void)asset:(ELCAsset *)assetView wasSelected:(BOOL)selected
{
    if (selected)
        [[self selectedAssets] addObject:[assetView asset]];
    else
        [[self selectedAssets] removeObject:[assetView asset]];
}

#pragma mark - Protected interface

- (NSString *)titleForLoadingMedia
{
    return @"Loading...";
}

- (NSString *)titleForSelectingMedia
{
    return @"Pick Photos";
}

@end
