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


@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize assetGroup, elcAssets;

-(void)viewDidLoad {
        
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
	UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
	[self setTitle:[self titleForLoadingMedia]];

    //int64_t delayInSeconds = 2.0;
    //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self preparePhotos];
    //});

    // Show partial while full list loads
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
}

-(void)preparePhotos {

    NSMutableArray *assets = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        NSLog(@"enumerating photos");
        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
         {         
             if(result == nil) 
             {
                 return;
             }
             
             ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
             [elcAsset setParent:self];
             [assets addObject:elcAsset];
         }];
        NSLog(@"done enumerating photos");

        dispatch_async(dispatch_get_main_queue(), ^{
            self.elcAssets = [NSArray arrayWithArray:assets];
            [self.tableView reloadData];

            NSInteger nrows = [self tableView:[self tableView] numberOfRowsInSection:0];
            NSIndexPath *lastRow = [NSIndexPath indexPathForRow:nrows - 1 inSection:0];
            [[self tableView] scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            [self setTitle:[self titleForSelectingMedia]];
        });

        [pool release];
    });
}

- (void) doneAction:(id)sender {
	
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	    
	for(ELCAsset *elcAsset in self.elcAssets) 
    {		
		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [self.parent selectedAssets:selectedAssetsImages];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.assetGroup numberOfAssets] / 4.0);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*4);
	int maxIndex = (_indexPath.row*4+3);
    
	// NSLog(@"Getting assets for %d to %d with array count %d", index, maxIndex, [assets count]);

    NSArray *assets = nil;
    
	if(maxIndex < [self.elcAssets count]) {
        
		assets = [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                  [self.elcAssets objectAtIndex:index+1],
                  [self.elcAssets objectAtIndex:index+2],
                  [self.elcAssets objectAtIndex:index+3],
                  nil];
	}
    
	else if(maxIndex-1 < [self.elcAssets count]) {
        
		assets = [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                  [self.elcAssets objectAtIndex:index+1],
                  [self.elcAssets objectAtIndex:index+2],
                  nil];
	}
    
	else if(maxIndex-2 < [self.elcAssets count]) {
        
		assets = [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
                  [self.elcAssets objectAtIndex:index+1],
                  nil];
	}
    
	else if(maxIndex-3 < [self.elcAssets count]) {
        
		assets = [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
	}

    [assets makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    
	return assets;
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
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) 
    {
		if([asset selected]) 
        {            
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    [elcAssets release];
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
