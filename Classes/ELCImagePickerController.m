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

-(id)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    if (self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass]) {
        _mutableSelectedAssets = [NSMutableArray array];
    }
    return self;
}

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
    if ([[self mutableSelectedAssets] containsObject:asset]) {
        [[self mutableSelectedAssets] removeObject:asset];
    }
}

- (void)albumPickerControllerDidCancel:(ELCAlbumPickerController *)controller
{
    [[self delegate] elcImagePickerControllerDidCancel:self];
}

- (void)albumPickerControllerIsDone:(ELCAlbumPickerController *)controller
{
    [[self delegate] elcImagePickerController:self didFinishPickingMediaWithInfo:[self selectedAssets]];
}

- (BOOL)albumPickerController:(ELCAlbumPickerController *)controller isAssetSelected:(ALAsset *)asset
{
    return [self indexOfAsset:asset inAssetArray:[self mutableSelectedAssets]] != NSNotFound;
}

- (BOOL)albumPickerController:(ELCAlbumPickerController *)controller isAssetPreSelected:(ALAsset *)asset {
    return [self indexOfAsset:asset inAssetArray:_preSelectedAsset] != NSNotFound;
}

#pragma mark - Asset helpers

- (NSInteger)indexOfAsset:(ALAsset *)asset inAssetArray:(NSArray *)assetArray
{
    //Skip checks if the asset array is empty.
    if (assetArray == nil) {
        return NSNotFound;
    }
    
    BOOL isURLPropertyAvailable = &ALAssetPropertyAssetURL != NULL;  // only available on iOS 6 and later
    NSURL *assetURL = isURLPropertyAvailable ? [asset valueForProperty:ALAssetPropertyAssetURL] : [[asset defaultRepresentation] url];

    return [assetArray indexOfObjectPassingTest:^(ALAsset *candidate, NSUInteger idx, BOOL *stop) {
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

@end