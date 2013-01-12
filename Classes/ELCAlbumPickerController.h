//
//  AlbumPickerController.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAssetTablePicker.h"
#import <AssetsLibrary/AssetsLibrary.h>


@protocol ELCAlbumPickerControllerDelegate;

@interface ELCAlbumPickerController : UITableViewController <ELCAssetTablePickerDelegate>
	
@property (nonatomic, assign) id<ELCAlbumPickerControllerDelegate> delegate;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;
@property (nonatomic, strong, readonly) NSArray *assetGroups;

#pragma mark - UI actions

- (void)cancelButtonTapped:(UIBarButtonItem *)sender;

#pragma mark - Protected interface

- (void)displayActivityViewAnimated:(BOOL)animated;
- (void)hideActivityViewAnimated:(BOOL)animated;

@end


@protocol ELCAlbumPickerControllerDelegate <NSObject>

- (NSString *)albumPickerControllerTitleForLoadingAlbums:(ELCAlbumPickerController *)controller;
- (NSString *)albumPickerControllerTitleForSelectingAlbums:(ELCAlbumPickerController *)controller;

- (BOOL)albumPickerController:(ELCAlbumPickerController *)controller canSelectAsset:(ALAsset *)asset;
- (void)albumPickerController:(ELCAlbumPickerController *)controller didSelectAsset:(ALAsset *)asset;
- (BOOL)albumPickerController:(ELCAlbumPickerController *)controller canDeselectAsset:(ALAsset *)asset;
- (void)albumPickerController:(ELCAlbumPickerController *)controller didDeselectAsset:(ALAsset *)asset;

- (BOOL)albumPickerController:(ELCAlbumPickerController *)controller isAssetSelected:(ALAsset *)asset;
- (BOOL)albumPickerController:(ELCAlbumPickerController *)pickerController isAssetPreSelected:(ALAsset *)asset;

- (void)albumPickerControllerDidCancel:(ELCAlbumPickerController *)controller;
- (void)albumPickerControllerIsDone:(ELCAlbumPickerController *)controller;

@end

