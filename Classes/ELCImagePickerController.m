//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"


@interface ALAsset (ELCHelpers)
- (NSDictionary *)mediaInfo;
@end


@interface ELCImagePickerController ()
@property (nonatomic, strong) NSMutableArray *mutableSelectedAssets;
@end


@implementation ELCImagePickerController

#pragma mark - ELCAlbumPickerControllerDelegate implementation

- (NSString *)albumPickerControllerTitleForLoadingAlbums:(ELCAlbumPickerController *)controller
{
    return @"Loading...";
}

- (NSString *)albumPickerControllerTitleForSelectingAlbums:(ELCAlbumPickerController *)controller
{
    return @"Select an Album";
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
    NSArray *selectedAssets = [self selectedAssets];
    NSMutableArray *assetInfo = [NSMutableArray arrayWithCapacity:[selectedAssets count]];
    [selectedAssets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
        [assetInfo addObject:[asset mediaInfo]];
    }];
    
    [[self delegate] elcImagePickerController:self didFinishPickingMediaWithInfo:assetInfo];
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


@implementation ALAsset (ELCHelpers)

- (NSDictionary *)mediaInfo
{
    NSMutableDictionary *workingDictionary = [NSMutableDictionary dictionary];
    [workingDictionary setObject:[self valueForProperty:ALAssetPropertyType] forKey:UIImagePickerControllerMediaType];
    [workingDictionary setObject:[UIImage imageWithCGImage:[[self defaultRepresentation] fullScreenImage]] forKey:UIImagePickerControllerOriginalImage];
    [workingDictionary setObject:[[self valueForProperty:ALAssetPropertyURLs] valueForKey:[[[self valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];

    return [NSDictionary dictionaryWithDictionary:workingDictionary];
}

@end
