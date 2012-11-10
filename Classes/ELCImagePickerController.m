//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"

@implementation ELCImagePickerController

@synthesize delegate;

-(void)cancelImagePicker {
	if([delegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[delegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

-(BOOL)canSelectAsset:(ELCAsset *)asset
{
    BOOL canSelect = YES;
    id<ELCImagePickerControllerDelegate> del = [self delegate];
    if ([del respondsToSelector:@selector(elcImagePickerController:shouldSelectMediaWithInfo:)])
        canSelect = [del elcImagePickerController:self shouldSelectMediaWithInfo:[[asset asset] mediaInfo]];

    return canSelect;
}

- (BOOL)canDeselectAsset:(ELCAsset *)asset
{
    id<ELCImagePickerControllerDelegate> del = [self delegate];
    if ([del respondsToSelector:@selector(elcImagePickerController:shouldDeselectMediaWithInfo:)])
        [del elcImagePickerController:self shouldDeselectMediaWithInfo:[[asset asset] mediaInfo]];

    return YES;
}

-(void)selectedAssets:(NSArray*)_assets {

	NSMutableArray *returnArray = [[[NSMutableArray alloc] init] autorelease];
	
	for(ALAsset *asset in _assets) {
        [returnArray addObject:[asset mediaInfo]];
	}
	
	if([delegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[delegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:[NSArray arrayWithArray:returnArray]];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {    
    NSLog(@"ELC Image Picker received memory warning.");
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    NSLog(@"deallocing ELCImagePickerController");
    self.delegate = nil;
    [super dealloc];
}

@end
