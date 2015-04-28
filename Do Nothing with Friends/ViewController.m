#import "ViewController.h"
@import AFNetworking;
@import SwiftSpinner;

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *forHowLongLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfNothingers;
@property (strong, nonatomic) IBOutlet UILabel *alsoDoingNothingLabel;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIButton *hourButton;
@property (strong, nonatomic) IBOutlet UIButton *fifteenMinButton;
@property (strong, nonatomic) IBOutlet UIButton *doNothingButton;

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSDate *lastDate;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.numberOfNothingers.text = @"";
    self.alsoDoingNothingLabel.text = @"";
    self.forHowLongLabel.text = @"";
    self.uuid = [[NSUUID UUID] UUIDString];

    self.lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"date"];

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(checkForNothingers) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)checkForNothingers
{
    if ([self.lastDate earlierDate:[NSDate date]] == self.lastDate) {
        self.doNothingButton.hidden = NO;
        self.forHowLongLabel.hidden = NO;

    } else {
        self.doNothingButton.hidden = YES;

        // So we dont do it while it says "forhowlong?"
        if (self.hourButton.hidden == YES) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.lastDate];
            self.forHowLongLabel.text = [NSString stringWithFormat:@"Seeyouin%@", @(roundf(interval/-60))];
        }
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://do-nothing-with-friends.herokuapp.com/nothing" parameters:@{ @"uuid" : self.uuid } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.numberOfNothingers.text = [NSString stringWithFormat:@"%@", @(responseObject[@"count"] || 0)];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (IBAction)doNothingTapped:(UIButton *)sender
{
    sender.hidden = YES;
    self.hourButton.hidden = NO;
    self.fifteenMinButton.hidden = NO;
    self.forHowLongLabel.hidden = NO;
    self.forHowLongLabel.text = @"forhowlong?";
}

- (IBAction)hourTapped:(UIButton *)sender
{
    [self sendNothingForMinutes:60];
}

- (IBAction)minTapped:(UIButton *)sender
{
    [self sendNothingForMinutes:15];
}

- (void)sendNothingForMinutes:(CGFloat)minutes
{
    self.hourButton.hidden = YES;
    self.fifteenMinButton.hidden = YES;

    NSDate *nextDate = [NSDate dateWithTimeIntervalSinceNow:minutes * 60];
    [[NSUserDefaults standardUserDefaults] setObject:nextDate forKey:@"date"];
    self.lastDate = nextDate;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{ @"uuid": self.uuid, @"minutes": @(minutes) };
    [manager POST:@"https://do-nothing-with-friends.herokuapp.com/nothing" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self.numberOfNothingers.text = [NSString stringWithFormat:@"%@", @(responseObject[@"count"] || 0)];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
