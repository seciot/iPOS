//
//  MainMenuViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AlertUtils.h"
#import "ProductItem.h"

#include "AddItemView.h"
#include "CustomerViewController.h"
#include "CartItemsViewController.h"

#include "Order.h"

@interface MainMenuViewController()
- (void) showAddItemOverlay: (NSArray *) foundItems;

- (void) customerPressed:(id)sender;
- (void) cartPressed:(id)sender;

- (void) performSearch: (ExtUITextField *) textField;
@end


@implementation MainMenuViewController

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"iPOS"];
	[self setTitle:@"iPOS"];

	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
    facade = [iPOSFacade sharedInstance];
	orderCart = [OrderCart sharedInstance];
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIView *) contentView
{
	return (UIView *)[self view];
}

#pragma mark -
#pragma mark Linea Delegate
-(void)barcodeData:(NSString *)barcode type:(int)type {
    ProductItem *item = [facade lookupProductItem:barcode];
    NSArray *foundItemList = nil;
    
    if(item != nil && [item.sku isEqualToNumber:[NSNumber numberWithInt:0]] == NO) {
        foundItemList = [NSArray arrayWithObject: item];
    }
    
    [self showAddItemOverlay:foundItemList];

}

#pragma mark -
#pragma mark UIViewController overrides

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
	bgView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	[self setView:bgView];
	[bgView release];
	
	scanItemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	scanItemLabel.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	scanItemLabel.textColor = [UIColor blackColor];
	scanItemLabel.text = @"-- SCAN ITEM --";
	scanItemLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:scanItemLabel];
	[scanItemLabel release];
	
    lookupItemNameField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	lookupItemNameField.textColor = [UIColor blackColor];
	lookupItemNameField.borderStyle = UITextBorderStyleRoundedRect;
	lookupItemNameField.textAlignment = UITextAlignmentCenter;
	lookupItemNameField.clearsOnBeginEditing = YES;
	lookupItemNameField.placeholder = @"Item By Name";
	lookupItemNameField.tagName = @"LookupItemName";
    lookupItemNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    lookupItemNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    lookupItemNameField.returnKeyType = UIReturnKeySearch;
	lookupItemNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

	[super addSearchAndCancelToolbarForTextField:lookupItemNameField];
	[self.view addSubview:lookupItemNameField];
	[lookupItemNameField release];
    
	lookupItemSkuField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	lookupItemSkuField.textColor = [UIColor blackColor];
	lookupItemSkuField.borderStyle = UITextBorderStyleRoundedRect;
	lookupItemSkuField.textAlignment = UITextAlignmentCenter;
	lookupItemSkuField.clearsOnBeginEditing = YES;
	lookupItemSkuField.placeholder = @"Item By SKU";
	lookupItemSkuField.tagName = @"LookupItemSku";
	lookupItemSkuField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	lookupItemSkuField.keyboardType = UIKeyboardTypeNumberPad;
	[super addSearchAndCancelToolbarForTextField:lookupItemSkuField];
	[self.view addSubview:lookupItemSkuField];
	[lookupItemSkuField release];
	
	customerButton = [[[MOGlassButton alloc] initWithFrame:CGRectZero] autorelease];
	[customerButton setTitle:@"Customer" forState:UIControlStateNormal];
	[customerButton setupAsBlackButton];
	[self.view addSubview:customerButton];
	
	cartButton = [[[MOGlassButton alloc] initWithFrame:CGRectZero] autorelease];
	[cartButton setTitle:@"Order Cart" forState:UIControlStateNormal];
	[cartButton setupAsBlackButton];
	[self.view addSubview:cartButton];
	 
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	lookupItemNameField.delegate = self;
    lookupItemSkuField.delegate = self;
    
	[customerButton addTarget:self action:@selector(customerPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cartButton addTarget:self action:@selector(cartPressed:) forControlEvents:UIControlEventTouchUpInside];
	
    // Add itself as a delegate
    linea = [Linea sharedDevice];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {

    // Add this controller as a Linea Device Delegate
    [linea addDelegate:self];


	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Main" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	}
	
	CGRect viewBounds = self.view.bounds;
	CGFloat labelButtonWidth = viewBounds.size.width * 0.60f;
	CGFloat	labelButtonSpacing = viewBounds.size.height * 0.15f;
	
	scanItemLabel.frame = CGRectMake(0.0f, 0.0f, labelButtonWidth, 40.0f);
	scanItemLabel.center = CGPointMake((viewBounds.size.width / 2.0f), labelButtonSpacing);
	
	lookupItemNameField.frame = CGRectOffset(scanItemLabel.frame, 0.0f, labelButtonSpacing);
    lookupItemSkuField.frame = CGRectOffset(lookupItemNameField.frame, 0.0f, labelButtonSpacing);
    	
	// Change to work from lookupOrderField position when that is implemented
	customerButton.frame = CGRectOffset(lookupItemSkuField.frame, 0.0f, labelButtonSpacing);
	
	cartButton.frame = CGRectOffset(customerButton.frame, 0.0f, labelButtonSpacing);
	
	// Do this last
	[super viewWillAppear:animated];
}
	 
- (void)viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {

    // Remove this controller as a linea delegate
    [linea removeDelegate: self];
	
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	// Do this at the end
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark ExtUIViewController delegate
- (void)extTextFieldFinishedEditing:(ExtUITextField *)textField {
    // Do nothing
}

- (void) dismissKeyboard:(id)sender {
    ExtUITextField *textField = (ExtUITextField *) self.currentFirstResponder;
    
    [super dismissKeyboard:sender];
    
    [self performSearch:textField];
}

- (BOOL)textFieldShouldReturn:(ExtUITextField *)textField {
	[textField resignFirstResponder];
    
    [self performSearch:textField];
	return YES;
}




#pragma mark -
#pragma mark AddItemViewDelegate
- (void) cancelAddItem:(AddItemView *)addItemView {
	[addItemView removeFromSuperview];
	[linea addDelegate:self];
	[self addKeyboardListeners];
}

- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure {
	
	ProductItem *item = addItemView.itemToAdd;
    
    [orderCart addItem:item withQuantity:quantity];
    if ([orderCart getOrder].errorList && [[orderCart getOrder].errorList count] > 0) {
        [AlertUtils showModalAlertForErrors:[orderCart getOrder].errorList];
        return;
    }
    
    [addItemView removeFromSuperview];

    CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
	[[self navigationController] pushViewController:cartViewController animated:TRUE];
	[cartViewController release];
}

#pragma mark -
#pragma mark UIButton callbacks
- (void)customerPressed:(id)sender {
	[linea removeDelegate:self];
	[self removeKeyboardListeners];
    CustomerViewController *customerViewController = [[CustomerViewController alloc] init];
	[[self navigationController] pushViewController:customerViewController animated:TRUE];
	[customerViewController release];
}

- (void)cartPressed:(id)sender {
	[linea removeDelegate:self];
	[self removeKeyboardListeners];
    CartItemsViewController *cartViewController = [[CartItemsViewController alloc] init];
	[[self navigationController] pushViewController:cartViewController animated:TRUE];
	[cartViewController release];
}

#pragma mark -
#pragma mark Private Methods
- (void) showAddItemOverlay:(NSArray *)foundItems {
    if (foundItems && [foundItems count] > 0) {
        [linea removeDelegate:self];
        [self removeKeyboardListeners];
        
        AddItemView *overlay = [[AddItemView alloc] initWithFrame:self.view.bounds];
        [overlay setViewDelegate:self];
        
        [self.view addSubview:overlay];
        
        if ([foundItems count] == 1) {
            [overlay setItemToAdd:(ProductItem *) [foundItems objectAtIndex:0]];
        } else {
            [overlay setProductItemList:foundItems];
        }
        
        [overlay release];
    } else {
        [AlertUtils showModalAlertMessage:@"No item(s) found"];
    }
}

- (void) performSearch:(ExtUITextField *)textField {
    if (textField && [textField.text length] > 0) {
        NSString *lookupText = textField.text;
        NSArray *foundItemList = nil;

        if ([textField.tagName isEqualToString:@"LookupItemSku"] && [textField.text length] > 0) {
            // Call the service and display the overlay view
            ProductItem *item = [facade lookupProductItem:lookupText];
            
            if(item != nil && [item.sku isEqualToNumber:[NSNumber numberWithInt:0]] == NO) {
                foundItemList = [NSArray arrayWithObject:item];
                textField.text = nil;
            }
            
            [self showAddItemOverlay:foundItemList];
        } else if ([textField.tagName isEqualToString:@"LookupItemName"] && [textField.text length] > 0) {
            // Call the service to get a list of items
            foundItemList = [facade lookupProductItemByName:lookupText];
            
            if (foundItemList && [foundItemList count] > 0) {
                textField.text = nil;
            } 
            
            [self showAddItemOverlay:foundItemList];
        }
    }
    
}
@end
