//
//  PictureViewController.m
//  GettyImage
//
//  Created by Justin Lee on 1/26/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import "PictureViewController.h"


@interface PictureViewController() {
	BOOL isFullScreen;
	CGRect prevFrame;
	UIImageView *fullview;
	UIImageView *temptumb;
}

@property (nonatomic,retain) UITableView * tableView;
@property (nonatomic,retain) UILabel * headerLabel;

@end

@implementation PictureViewController

@synthesize headerLabel;


- (void)backButtonNormal:(UIButton *)sender
{
	//self.backButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:102.2/255.0 alpha:0.9];
}
- (void)backTouchDown:(UIButton *) sender
{
	//self.backButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:71.0/255.0 blue:71.2/255.0 alpha:0.9];
	[self dismissViewControllerAnimated:YES completion:nil];
}

//This will create a temporary imaget view and animate it to fullscreen
- (void)bannerTapped:(UIGestureRecognizer *)gestureRecognizer {
//	NSLog(@"%@", [gestureRecognizer view]);
	//create new image
	temptumb=(UIImageView *)gestureRecognizer.view;
	
	//fullview is gloabal, So we can acess any time to remove it
	fullview=[[UIImageView alloc]init];
	[fullview setContentMode:UIViewContentModeScaleAspectFit];
	[fullview setBackgroundColor:[UIColor blackColor]];
	fullview.image = [(UIImageView *)gestureRecognizer.view image];
	CGRect point=[self.view convertRect:gestureRecognizer.view.bounds fromView:gestureRecognizer.view];
	[fullview setFrame:point];
	
	[self.view addSubview:fullview];
	[UIView animateWithDuration:0.5
					 animations:^{
						 [fullview setFrame:CGRectMake(0,
													   0,
													   self.view.bounds.size.width,
													   self.view.bounds.size.height)];
					 }];
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullimagetapped:)];
	singleTap.numberOfTapsRequired = 1;
	singleTap.numberOfTouchesRequired = 1;
	[fullview addGestureRecognizer:singleTap];
	[fullview setUserInteractionEnabled:YES];
}

//This will remove the full screen and back to original location.

- (void)fullimagetapped:(UIGestureRecognizer *)gestureRecognizer {
	
	CGRect point=[self.view convertRect:temptumb.bounds fromView:temptumb];
	
	gestureRecognizer.view.backgroundColor=[UIColor clearColor];
	[UIView animateWithDuration:0.5
					 animations:^{
						 [(UIImageView *)gestureRecognizer.view setFrame:point];
					 }];
	[self performSelector:@selector(animationDone:) withObject:[gestureRecognizer view] afterDelay:0.4];
	
}

//Remove view after animation of remove
-(void)animationDone:(UIView  *)view
{
	//view.backgroundColor=[UIColor clearColor];
	[fullview removeFromSuperview];
	fullview=nil;
}

- (void)initTableView
{
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height-80) style:UITableViewStylePlain];
	//	self.view.backgroundColor = [UIColor colorWithRed:181.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1.0];
	self.tableView.dataSource =self;
	self.tableView.delegate = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self.view addSubview:self.tableView];
	[self.view sendSubviewToBack:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self.data objectForKey:@"images"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 200;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	static NSString *CellIdentifier = @"ListingIdentifier";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UIView * panel = nil;
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.backgroundView.backgroundColor = [UIColor whiteColor];
		
		panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
		panel.layer.masksToBounds = NO;
		panel.tag = 10;
		
		[cell.contentView addSubview:panel];
	}
	else{
		panel = [cell.contentView viewWithTag:10];
		NSArray *viewsToRemove = [panel subviews];
		for (UIView *v in viewsToRemove) {
			[v removeFromSuperview];
		}
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		NSString *path =[[[[[self.data objectForKey:@"images"] objectAtIndex:row] objectForKey:@"display_sizes"] objectAtIndex:0] objectForKey:@"uri"];
		NSURL *url = [NSURL URLWithString:path];
		NSData *data = [NSData dataWithContentsOfURL:url];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			UIImage *img = [[UIImage alloc] initWithData:data];
			UIImageView *imgView2 = [[UIImageView alloc] initWithImage:img];
			[imgView2 setFrame:CGRectMake(0, 0, panel.frame.size.width, 200)];
			imgView2.contentMode = UIViewContentModeScaleToFill;
			imgView2.clipsToBounds = YES;
			[panel addSubview:imgView2];
			
			UITapGestureRecognizer *tapPic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
			[imgView2 setUserInteractionEnabled:YES];
			[imgView2 addGestureRecognizer:tapPic];
		});
	});

	return cell;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	isFullScreen = false;
	
	self.view.backgroundColor = [UIColor colorWithRed:181.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1.0];
	
	UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
	
	headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, headerView.frame.size.width, 30)];
	[headerLabel setText:self.title];
	[headerLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	[headerLabel setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
	[headerLabel setTextColor:[UIColor colorWithRed:108.0/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:1.0]];
	headerLabel.textAlignment = NSTextAlignmentCenter;
	
	UIView * headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.origin.y + headerView.frame.size.height, self.view.frame.size.width, 1)];
	headerLine.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.2/255.0 alpha:1.0];
	
	UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState :UIControlStateNormal];
	backButton.tintColor = [UIColor whiteColor];
	backButton.frame = CGRectMake(15, 35, 30, 30);
	[backButton addTarget:self action:@selector(backTouchDown:) forControlEvents:UIControlEventTouchDown];
	[backButton addTarget:self action:@selector(backButtonNormal:) forControlEvents:UIControlEventTouchUpInside];
	
	[headerView addSubview:headerLabel];
	[headerView addSubview:backButton];
	[headerView addSubview:headerLine];
	[self.view addSubview:headerView];

	[self initTableView];
	NSLog(@"%lu", [[self.data objectForKey:@"images"] count]);
	NSLog(@"%d", [[self.data objectForKey:@"result_count"] intValue]);
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