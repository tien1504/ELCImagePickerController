//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"

@interface ELCImagePickerController ()
@property (nonatomic, strong) NSMutableArray *mutableSelectedAssets;
@end


@implementation ELCImagePickerController

#pragma mark - ELCAlbumPickerControllerDelegate implementation

- (NSString *)albumPickerControllerTitleForLoadingAlbums:(ELCAlbumPickerController *)controller
{
    return [NSString stringWithFormat:@"%@...", [L(@"global.loading") uppercaseString]];
}

- (NSString *)albumPickerControllerTitleForSelectingAlbums:(ELCAlbumPickerController *)controller
{
    return [L(@"global.select-album") uppercaseString];
}

- (BOOL)albumPickerController:(ELCAlbumPickerController *)controller canSelectAsset:(ALAsset *)asset
{
    return YES;
}

- (void)albumPickerController:(ELCAlbumPickerController *)controller didSelectAsset:(ALAsset *)asset
{
    [[self mutableSelectedAssets] addObject:asset];
}

- (BOOL)albumPickerController:(ELCAlbumPickerController *)controller canDeselectAsset:(ALAsset *)asset
{
    return YES;
}

- (void)albumPickerController:(ELCAlbumPickerController *)controller didDeselectAsset:(ALAsset *)asset
{
    [[self mutableSelectedAssets] removeObjectAtIndex:[self indexOfAsset:asset]];
}

- (BOOL)albumPickerController:(ELCAlbumPickerController *)controller isAssetSelected:(ALAsset *)asset
{
    return [self indexOfAsset:asset] != NSNotFound;
}

- (void)albumPickerControllerDidCancel:(ELCAlbumPickerController *)controller
{
    [[self delegate] elcImagePickerControllerDidCancel:self];
}

- (void)albumPickerControllerIsDone:(ELCAlbumPickerController *)controller
{
    [[self delegate] elcImagePickerController:self didFinishPickingMediaWithInfo:[self selectedAssets]];
}

#pragma mark - Asset helpers

- (NSInteger)indexOfAsset:(ALAsset *)asset
{
    BOOL isURLPropertyAvailable = &ALAssetPropertyAssetURL != NULL;  // only available on iOS 6 and later
    NSURL *assetURL = isURLPropertyAvailable ? [asset valueForProperty:ALAssetPropertyAssetURL] : [[asset defaultRepresentation] url];
    NSArray *selectedAssets = [self mutableSelectedAssets];

    return [selectedAssets indexOfObjectPassingTest:^(ALAsset *candidate, NSUInteger idx, BOOL *stop) {
        NSURL *candidateURL =
            isURLPropertyAvailable ? [candidate valueForProperty:ALAssetPropertyAssetURL] : [[candidate defaultRepresentation] url];
        return [candidateURL isEqual:assetURL];
    }];
}

#pragma mark - Accessors

- (NSArray *)selectedAssets
{
    return [NSArray arrayWithArray:[self mutableSelectedAssets]];
}

- (NSMutableArray *)mutableSelectedAssets
{
    if (!_mutableSelectedAssets)
        _mutableSelectedAssets = [[NSMutableArray alloc] init];

    return _mutableSelectedAssets;
}

@end