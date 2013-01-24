//
//  ELCImagePickerController.h
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAlbumPickerController.h"

@protocol ELCImagePickerControllerDelegate;
@class ELCAsset;

@interface ELCImagePickerController : UIViewController <ELCAlbumPickerControllerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate, ELCImagePickerControllerDelegate> delegate;

@property (nonatomic, copy, readonly) NSArray *selectedAssets;

@end

@protocol ELCImagePickerControllerDelegate <NSObject>

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker;

@end

