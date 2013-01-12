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
@property (nonatomic, strong) NSArray *assetGroups;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end


@implementation ELCAlbumPickerController

#pragma mark - UI actions

- (void)cancelButtonTapped:(UIBarButtonItem *)sender
{
    [[self delegate] albumPickerControllerDidCancel:self];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelButtonTapped:)];
	[self.navigationItem setRightBarButtonItem:cancelButton];

    [[self tableView] setRowHeight:57];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [self loadAssetGroups];
    });
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self assetGroups] ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self assetGroups] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
    [picker setDelegate:self];

    // Move me
    picker.assetGroup = [[self assetGroups] objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[self assetsFilter]];
    
	[self.navigationController pushViewController:picker animated:YES];
}

#pragma mark - ELCAssetTablePickerDelegate implementation

- (NSString *)assetTablePickerTitleForLoadingMedia:(ELCAssetTablePicker *)pickerController
{
    return @"Loading...";
}

- (NSString *)assetTablePickerTitleForSelectingMedia:(ELCAssetTablePicker *)pickerController
{
    return @"Pick Photos";
}

- (UIImage *)selectedAssetOverlayImage:(ELCAssetTablePicker *)pickerController
{
    return [UIImage imageNamed:@"Overlay"];
}

- (BOOL)assetTablePicker:(ELCAssetTablePicker *)pickerController canSelectAsset:(ALAsset *)asset
{
    return [[self delegate] albumPickerController:self canSelectAsset:asset];
}

- (void)assetTablePicker:(ELCAssetTablePicker *)pickerController didSelectAsset:(ALAsset *)asset
{
    return [[self delegate] albumPickerController:self didSelectAsset:asset];
}

- (BOOL)assetTablePicker:(ELCAssetTablePicker *)pickerController canDeselectAsset:(ALAsset *)asset
{
    return [[self delegate] albumPickerController:self canDeselectAsset:asset];
}

- (void)assetTablePicker:(ELCAssetTablePicker *)pickerController didDeselectAsset:(ALAsset *)asset
{
    return [[self delegate] albumPickerController:self didDeselectAsset:asset];
}

- (BOOL)assetTablePicker:(ELCAssetTablePicker *)pickerController isAssetSelected:(ALAsset *)asset
{
    return [[self delegate] albumPickerController:self isAssetSelected:asset];
}

- (void)assetTablePickerIsDone:(ELCAssetTablePicker *)pickerController
{
    [[self delegate] albumPickerControllerIsDone:self];
}

- (BOOL)assetTablePicker:(ELCAssetTablePicker *)pickerController isAssetPreSelected:(ALAsset *)asset {
    return [self.delegate albumPickerController:self isAssetPreSelected:asset];
}

#pragma mark -
#pragma mark - Asset group management

- (void)loadAssetGroups
{
    [self displayActivityViewAnimated:NO];
    __block BOOL isShowingActivityView = YES;
	[self setTitle:[[self delegate] albumPickerControllerTitleForLoadingAlbums:self]];

    NSMutableArray *assetGroups = [NSMutableArray array];
    ALAssetsLibrary *library = [self assetsLibrary];
    NSArray *types = @[ @(ALAssetsGroupSavedPhotos),
                        @(ALAssetsGroupLibrary),
                        @(ALAssetsGroupPhotoStream),
                        @(ALAssetsGroupAlbum),
                        @(ALAssetsGroupEvent),
                        @(ALAssetsGroupFaces) ];
    __block NSInteger count = [types count];
    [types enumerateObjectsUsingBlock:^(NSNumber *type, NSUInteger idx, BOOL *stop) {
        [self loadAssetsGroupsWithType:[type integerValue] fromLibrary:library completion:^(NSArray *groups) {
            [assetGroups addObjectsFromArray:groups];
            if (--count == 0) {
                [self setTitle:[[self delegate] albumPickerControllerTitleForSelectingAlbums:self]];

                [self setAssetGroups:assetGroups];
                NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
                [[self tableView] insertSections:sections  withRowAnimation:UITableViewRowAnimationFade];

                if (isShowingActivityView) {
                    [self hideActivityViewAnimated:NO];
                    isShowingActivityView = NO;
                }
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
                             NSLog(@"A problem occured %@", error);
                         }];
}

#pragma mark - Activity view management

- (void)displayActivityViewAnimated:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.2 : 0;
    UIActivityIndicatorView *activityIndicator = [self activityIndicator];
    CGRect viewFrame = [[self view] frame];
    CGRect activityIndicatorFrame = [activityIndicator frame];
    activityIndicatorFrame.origin.x = round((viewFrame.size.width - activityIndicatorFrame.size.width) / 2);
    activityIndicatorFrame.origin.y = round((viewFrame.size.height - activityIndicatorFrame.size.height) / 2);
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

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicator setHidesWhenStopped:YES];
    }

    return _activityIndicator;
}

@end

