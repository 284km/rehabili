//
//  TimelineViewController.m
//  rehabili
//
//  Created by kazuma on 3/19/14.
//  Copyright (c) 2014 kazuma. All rights reserved.
//

#import "TimelineViewController.h"

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface TimelineViewController ()

@end

@implementation TimelineViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:twitterAccountType
                            withCompletionHandler:^(BOOL granted, NSError *error)
     {
         if (!granted) {
             NSLog(@"ユーザーがアクセスを拒否しました。");
         }else{
             NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
             if ([twitterAccounts count] > 0) {
                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                 TWRequest *request = [[TWRequest alloc] initWithURL:url
                                                          parameters:nil
                                                       requestMethod:TWRequestMethodGET];
                 [request setAccount:account];
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if(!responseData){
                          NSLog(@"%@", error);
                      }else{
                          NSError* error;
                          statuses = [NSJSONSerialization JSONObjectWithData:responseData
                                                                              options:NSJSONReadingMutableLeaves
                                                                                error:&error];
                          if(statuses){
//                              NSLog(@"%@", statuses);
                              NSLog(@"%@", @"success");
                              dispatch_async(dispatch_get_main_queue(), ^{ // 追加
                                  [self.tableView reloadData]; // 追加
                              }); // 追加
                          }else{
                              NSLog(@"%@", error);
                          }
                      }
                  }];
             }
         }
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSLog(@"%lu", (unsigned long)[statuses count]);
    return [statuses count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...

    if(cell == nil){ // 追加
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault // 追加
                                      reuseIdentifier:CellIdentifier]; // 追加
        cell.textLabel.font = [UIFont systemFontOfSize:11.0]; // 追加
    } // 追加
    
    NSDictionary *status = [statuses objectAtIndex:indexPath.row]; // 追加
    NSString *text = [status objectForKey:@"text"]; // 追加
    cell.textLabel.text = text; // 追加

    
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressComposeButton:(id)sender {

    // ツイートできるかどうかをチェックする
    if([TWTweetComposeViewController canSendTweet]){
        // TWTweetComposeViewControllerオブジェクトを作成する
        TWTweetComposeViewController *composeViewController = [[TWTweetComposeViewController alloc] init];
        // TWTweetComposeViewControllerオブジェクトを表示する
        [self presentModalViewController:composeViewController animated:YES];
    }
}
@end
