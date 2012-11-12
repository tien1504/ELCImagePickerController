//
//  AlbumPickerController.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"

@interface ELCAlbumPickerController ()
@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;
@end


@implementation ELCAlbumPickerController

@synthesize parent, assetGroups = _assetGroups, assetsFilter, assetsLibrary = _assetsLibrary;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];
	[cancelButton release];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [self loadAssetGroups];
    });
}

-(void)selectedAssets:(NSArray*)_assets {
	
	[parent selectedAssets:_assets];

}

-(BOOL)canSelectAsset:(ELCAsset *)asset {

    return [parent canSelectAsset:asset];

}

-(BOOL)canDeselectAsset:(ELCAsset *)asset {

    return [parent canDeselectAsset:asset];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self assetGroups] ? 1 : 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self assetGroups] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[[self assetGroups] objectAtIndex:indexPath.row];
    [g setAssetsFilter:[self assetsFilter]];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[[self assetGroups] objectAtIndex:indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
	picker.parent = self;

    // Move me
    picker.assetGroup = [[self assetGroups] objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[self assetsFilter]];
    
	[self.navigationController pushViewController:picker animated:YES];
	[picker release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 57;
}

#pragma mark -
#pragma mark - Asset group management

- (void)loadAssetGroups
{
	[self setTitle:[self titleForLoadingAlbums]];

    NSMutableArray *assetGroups = [NSMutableArray array];
    ALAssetsLibrary *library = [self assetsLibrary];
    NSArray *types = @[ @(ALAssetsGroupSavedPhotos), @(ALAssetsGroupPhotoStream), @(ALAssetsGroupAlbum) ];
    __block NSInteger count = [types count];
    [types enumerateObjectsUsingBlock:^(NSNumber *type, NSUInteger idx, BOOL *stop) {
        [self loadAssetsGroupsWithType:[type integerValue] fromLibrary:library completion:^(NSArray *groups) {
            [assetGroups addObjectsFromArray:groups];
            if (--count == 0) {
                [self setTitle:[self titleForSelectingAlbums]];

                [self setAssetGroups:assetGroups];
                NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
                [[self tableView] insertSections:sections  withRowAnimation:UITableViewRowAnimationBottom];
            }
        }];
    }];
}

- (void)loadAssetsGroupsWithType:(ALAssetsGroupType)groupType
                     fromLibrary:(ALAssetsLibrary *)library
                      completion:(void (^)(NSArray *groups))completion
{
    NSMutableArray *groups = [NSMutableArray array];
    [library enumerateGroupsWithTypes:groupType
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               if (group)
                                   [groups addObject:group];
                               else
                                   completion(groups);
                           }
                         failureBlock:^(NSError *error) {
                             NSString *msg = [NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]];
                             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                              message:msg
                                                                             delegate:nil cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                             [alert show];
                             [alert release];
                             NSLog(@"A problem occured %@", error);
                         }];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{	
    [_assetGroups release];
    [_assetsLibrary release];
    [super dealloc];
}

- (NSString *)titleForLoadingAlbums
{
    return @"Loading...";
}

- (NSString *)titleForSelectingAlbums
{
    return @"Select an Album";
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary)
        _assetsLibrary = [[ALAssetsLibrary alloc] init];

    return _assetsLibrary;
}

@end

