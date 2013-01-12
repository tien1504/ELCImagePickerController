//
//  AssetTablePicker.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCThumbnailsTableViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>


@protocol ELCAssetTablePickerDelegate;


@interface ELCAssetTablePicker : UITableViewController <ELCThumbnailsTableViewCellDelegate>

@property (nonatomic, weak) id<ELCAssetTablePickerDelegate> delegate;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;

#pragma mark - UI actions

- (void)doneButtonTapped:(UIBarButtonItem *)sender;
- (void)loadAssets;

#pragma mark - Protected interface

- (void)displayActivityViewAnimated:(BOOL)animated;
- (void)hideActivityViewAnimated:(BOOL)animated;
- (BOOL)isDisplayingActivityView;

@end


@protocol ELCAssetTablePickerDelegate <NSObject>

- (NSString *)assetTablePickerTitleForLoadingMedia:(ELCAssetTablePicker *)pickerController;
- (NSString *)assetTablePickerTitleForSelectingMedia:(ELCAssetTablePicker *)pickerController;

- (UIImage *)selectedAssetOverlayImage:(ELCAssetTablePicker *)pickerController;

- (BOOL)assetTablePicker:(ELCAssetTablePicker *)pickerController canSelectAsset:(ALAsset *)asset;
- (void)assetTablePicker:(ELCAssetTablePicker *)pickerController didSelectAsset:(ALAsset *)asset;
- (BOOL)assetTablePicker:(ELCAssetTablePicker *)pickerController canDeselectAsset:(ALAsset *)asset;
- (void)assetTablePicker:(ELCAssetTablePicker *)pickerController didDeselectAsset:(ALAsset *)asset;

- (BOOL)assetTablePicker:(ELCAssetTablePicker *)pickerController isAssetSelected:(ALAsset *)asset;
- (BOOL)assetTablePicker:(ELCAssetTablePicker *)pickerController isAssetPreSelected:(ALAsset *)asset;

- (void)assetTablePickerIsDone:(ELCAssetTablePicker *)pickerController;

@end