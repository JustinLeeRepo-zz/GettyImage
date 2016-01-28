//
//  ViewController.m
//  GettyImage
//
//  Created by Justin Lee on 1/26/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import "ViewController.h"
#import "NetworkAccess.h"

@interface ViewController () {
	int keyboard_flag;
}

@property (nonatomic,retain) UITextField * searchTextField;
@property (nonatomic,retain) UITextChecker *checker;

@end

@implementation ViewController

@synthesize searchTextField;
@synthesize checker;


-(BOOL)isDictionaryWord:(NSString*)word {
	checker = [[UITextChecker alloc] init];
//	NSLocale *currentLocale = [NSLocale currentLocale];
//	NSString *currentLanguage = [currentLocale objectForKey:NSLocaleLanguageCode];
	NSRange searchRange = NSMakeRange(0, [word length]);
	NSRange misspelledRange = [checker rangeOfMisspelledWordInString:word range: searchRange startingAt:0 wrap:NO language: @"en" ];
	return misspelledRange.location == NSNotFound;
}

- (NSString *)removeNonAlpha:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
	NSUInteger originalCursorPosition = *cursorPosition;
	NSMutableString *alphaOnlyString = [NSMutableString new];
	for (NSUInteger i=0; i<[string length]; i++) {
		unichar characterToAdd = [string characterAtIndex:i];
		if (isalpha(characterToAdd)) {
			NSString *stringToAdd =[NSString stringWithCharacters:&characterToAdd length:1];
			[alphaOnlyString appendString:stringToAdd];
		}
		else {
			if (i < originalCursorPosition) {
				(*cursorPosition)--;
			}
		}
	}
	
	return alphaOnlyString;
}

-(void)reformatAsAlphaOnly:(UITextField *)textField
{
	NSUInteger targetCursorPosition = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
	
	NSString *searchWithoutSpaces = [self removeNonAlpha:textField.text andPreserveCursorPosition:&targetCursorPosition];
	
	
	textField.text = searchWithoutSpaces;
	UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument] offset:targetCursorPosition];
	
	[textField setSelectedTextRange: [textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
}

- (void)searchButtonNormal:(UIButton *)sender
{
	
//	NSLog([self isDictionaryWord:searchTextField.text] ? @"Yes" : @"No");
	if(![self isDictionaryWord:searchTextField.text]){
//		NSLog(@"NOTREAL");
		NSArray * guesses = [checker guessesForWordRange:NSMakeRange(0, [searchTextField.text length]) inString:searchTextField.text language:@"en"];
		searchTextField.text = [guesses count] > 0 ? [guesses objectAtIndex:0] : searchTextField.text;
		
	}
	self.pictureViewController = [[PictureViewController alloc] init];
	[NetworkAccess accessServer:searchTextField.text success:^(NSURLSessionTask *task, NSArray *responseObject){
		self.pictureViewController.data = (NSDictionary *)responseObject;
//		NSLog(@"LOL %@", self.pictureViewController.data);
		self.pictureViewController.title = searchTextField.text;
		[self presentViewController:self.pictureViewController animated:YES completion:nil];
	} failure:^(NSURLSessionTask *operation, NSError *error){
		NSLog(@"FAIL %@", error);
		return;
	}];
}

- (void)searchTouchDown:(UIButton *)sender
{
	
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
	CGSize keyboardSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	int height = MIN(keyboardSize.height,keyboardSize.width);
	
	[self.view setFrame:CGRectMake(0,-height,self.view.frame.size.width,self.view.frame.size.height)];
	keyboard_flag = 1;
	
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
	[self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
	keyboard_flag = 0;
}

- (void)registerForKeyboardNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
	
}

- (void) handleSingleTap:(UITapGestureRecognizer *)sender {
	if (keyboard_flag == 1) {
		[self.view endEditing:YES];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor colorWithRed:181.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1.0];
	
	searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height / 2 - 35 / 2, self.view.frame.size.width - (10 + 10),35)];
	[searchTextField setBackgroundColor:[UIColor whiteColor]];
	searchTextField.borderStyle = UITextBorderStyleRoundedRect;
	[searchTextField setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
	[searchTextField setFont:[UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium]];
	[searchTextField setTextColor:[UIColor colorWithRed:108.0/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:1.0]];
	[searchTextField setTextAlignment:NSTextAlignmentCenter];
	searchTextField.delegate = self;
	[searchTextField setReturnKeyType:UIReturnKeySearch];
	searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	searchTextField.placeholder = @"Image";
	[searchTextField addTarget:self action:@selector(reformatAsAlphaOnly:) forControlEvents:UIControlEventEditingChanged];
	
	UIButton * searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[searchButton setTitle:@"Search" forState:UIControlStateNormal];
	[searchButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	[searchButton.titleLabel setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
	searchButton.frame = CGRectMake(self.view.frame.size.width / 2 - 75 / 2, searchTextField.frame.origin.y + searchTextField.frame.size.height + 15, 75, 30);
	searchButton.tintColor = [UIColor colorWithRed:145.0/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1.0];
	[searchButton addTarget:self action:@selector(searchTouchDown:) forControlEvents:UIControlEventTouchDown];
	[searchButton addTarget:self action:@selector(searchButtonNormal:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:searchButton];
	[self.view addSubview:searchTextField];
	
	UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
														  initWithTarget:self action:@selector(handleSingleTap:)];
	
	singleTapGestureRecognizer.numberOfTapsRequired = 1;
	[self.view addGestureRecognizer:singleTapGestureRecognizer];
	self.view.userInteractionEnabled = YES;

	
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
