//
//  DynamicCellSizeTableViewController.m
//  dynamicCellSizeExample
//
//  Created by Patrick Pierson on 3/27/13.
//  Copyright (c) 2013 PPierson. All rights reserved.
//

#import "SecondTableViewController.h"

#define kLabelWidth 203
#define kLabelHeight 21
#define kCellHeight 44

@interface SecondTableViewController (){
    NSArray * _labelTextArray;
    NSIndexPath * _expandedIndexPath;
    
    UIFont* _labelFont;
}

@end

@implementation SecondTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _expandedIndexPath = nil;
    _labelFont = [UIFont systemFontOfSize:17.0];
    
    _labelTextArray = @[
                        @"Harry Potter is an English series of seven fantasy novels written by British author J. K. Rowling. The series chronicles the various adventures of a young wizard, Harry Potter, the titular character, and his friends Ronald Weasley and Hermione Granger, all of whom are students at Hogwarts School of Witchcraft and Wizardry. The main story arc concerns Harry's quest to defeat the Dark wizard Lord Voldemort, who aims to become immortal, conquer the wizarding world, subjugate non-magical people, and destroy all those who stand in his way, especially Harry Potter.",
                        @"Since the release of the first novel, Harry Potter and the Philosopher's Stone, on 30 June 1997, the books have gained immense popularity, critical acclaim and commercial success worldwide.[2] The series has also had some share of criticism, including concern about the increasingly dark tone as the series progressed. As of May 2015, the books have sold more than 450 million copies worldwide, making the series the best-selling book series in history, and have been translated into 73 languages.[3][4] The last four books consecutively set records as the fastest-selling books in history, with the final installment selling roughly 11 million copies in the United States within the first 24 hours of its release.",
                        @"A series of many genres, including fantasy, coming of age and the British school story (which includes elements of mystery, thriller, adventure and romance), it has many cultural meanings and references.[5] According to Rowling, the main theme is death.[6] There are also many other themes in the series, such as prejudice, corruption, and madness",
                        @"The series was originally printed in English by two major publishers, Bloomsbury in the United Kingdom and Scholastic Press in the United States. The seven books adapted into an eight-part film series by Warner Bros. Pictures, which is the 2nd highest-grossing film series of all time as of August 2015. The series also originated much tie-in merchandise, making the Harry Potter brand worth in excess of $15 billion.[8]"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)getFullSizeOfLabelForText:(NSString*)labelText{
    //up to infinite height
    CGSize maxSize = CGSizeMake(kLabelWidth, FLT_MAX);
    CGSize expectedSize = [labelText sizeWithFont:_labelFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    
    if (expectedSize.width < kLabelWidth) expectedSize.width = kLabelWidth;
    return expectedSize;
}

- (IBAction)expandButtonSelected:(id)sender{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cell.center];
    NSIndexPath* oldPath = _expandedIndexPath;
    if(_expandedIndexPath && [_expandedIndexPath isEqual: indexPath]) {
        _expandedIndexPath = nil;
    }else{
        _expandedIndexPath = indexPath;
    }
    
    NSMutableArray* indexPaths = [NSMutableArray array];
    if(_expandedIndexPath) [indexPaths addObject:_expandedIndexPath];
    if(oldPath) [indexPaths addObject:oldPath];
    if([indexPaths count] > 0) [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat additionalHeight = 0;
    if(_expandedIndexPath && indexPath.row == _expandedIndexPath.row){
        CGSize newSize = [self getFullSizeOfLabelForText:[_labelTextArray objectAtIndex:indexPath.row]];
        additionalHeight = newSize.height - kLabelHeight;
    }
    
    return kCellHeight + additionalHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_labelTextArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel* textLabel = (UILabel*)[cell viewWithTag:101];
    UIButton* expandButton = (UIButton*)[cell viewWithTag:202];
    
    [textLabel setText:[_labelTextArray objectAtIndex:indexPath.row]];
    textLabel.frame = CGRectMake(textLabel.frame.origin.x, textLabel.frame.origin.y, kLabelWidth, kLabelHeight);
    
    if(_expandedIndexPath != nil && _expandedIndexPath.row == indexPath.row){
        //resize label
        CGSize expectedSize = [self getFullSizeOfLabelForText:[_labelTextArray objectAtIndex:indexPath.row]];
        textLabel.frame = CGRectMake(textLabel.frame.origin.x, textLabel.frame.origin.y, expectedSize.width, expectedSize.height);
        [expandButton setTitle:@"Shrink" forState:UIControlStateNormal];
    }else{
        [expandButton setTitle:@"Expand" forState:UIControlStateNormal];
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
