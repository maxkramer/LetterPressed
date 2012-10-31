//
//  ViewController.m
//  Letterpressed
//
//  Created by Max Kramer on 29/10/2012.
//  Copyright (c) 2012 Max Kramer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (void) locateMatches;

- (BOOL) validateWord:(NSString *) word;

- (void) filterMatches;

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *wordMatches;

@property (nonatomic, retain) NSArray *dictionaryWords;

@property (nonatomic, retain) NSString *query;

@end

@implementation ViewController

@synthesize tableView, wordMatches, dictionaryWords, query;

#pragma mark Init Methods

- (id) init {
    return [super initWithNibName:NSStringFromClass([ViewController class]) bundle:nil];
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, self.view.frame.size.height-50) style:UITableViewStylePlain] autorelease];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        [self.view addSubview:self.tableView];
        
        self.wordMatches = [NSMutableArray array];
        
        self.dictionaryWords = [[NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"words" withExtension:@"txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
        
    }
    
    return self;
    
}

#pragma mark ViewDidLoad

- (void)viewDidLoad {
    
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [tf setFont:[UIFont systemFontOfSize:18]];
    [tf setBorderStyle:UITextBorderStyleBezel];
    [tf setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [tf setDelegate:self];
    [tf setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [tf setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [tf setAutocorrectionType:UITextAutocorrectionTypeNo];
    [tf setClearButtonMode:UITextFieldViewModeAlways];
    [self.view addSubview:tf];
    [tf release];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text.length < 2) {
        
        [textField resignFirstResponder];
        
        return YES;
        
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.query = textField.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        
        [self locateMatches];
        
    });
    
    [textField resignFirstResponder];
    
    return YES;
    
}

#pragma mark Word Validation

- (void) locateMatches {
        
    [self.wordMatches removeAllObjects];
    
    NSCharacterSet *allowedChars = [NSCharacterSet characterSetWithCharactersInString:self.query];
        
    for (NSString *word in self.dictionaryWords) {
        
        if (([[word stringByTrimmingCharactersInSet:allowedChars] length] == 0 && ![word isEqualToString:@""]) && [self validateWord:word] == YES) {
                        
            [self.wordMatches addObject:word];
            
        }
        
        
    }
    
    [self filterMatches]; //comment this line out if you want the words to be in alphabetical order.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    });
            
}

- (BOOL) validateWord:(NSString *)word {
    
    BOOL isValid = YES;
    
    const char * selectedLetters = [self.query UTF8String];
    
    for (NSUInteger index = 0; index < strlen(selectedLetters); index ++) {
        
        unichar character = selectedLetters[index];
        
        NSUInteger occurancesOfCharacterInQuery = [self occurrencesOfCharacter:character inWord:self.query];
        
        NSUInteger occurancesOfCharacterInWord  = [self occurrencesOfCharacter:character inWord:word];
        
        if (occurancesOfCharacterInQuery < occurancesOfCharacterInWord) {
            
            isValid = NO;
            break;
            
        }
        
    }
    
    return isValid;
    
}

- (NSUInteger) occurrencesOfCharacter:(unichar) character inWord:(NSString *) word {
    
    NSUInteger count = 0;
    
    const char * characters = [word UTF8String];
    
    for (NSUInteger index = 0; index < strlen(characters); index++) {
        
        const char inChar = characters[index];
        
        if (character == inChar) {
            
            count ++;
            
        }
        
    }
    
    return count;
    
}

- (void) filterMatches {
    
    [self.wordMatches sortUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        
        return [[NSNumber numberWithUnsignedInteger:[obj2 length]] compare:[NSNumber numberWithUnsignedInteger:[obj1 length]]];
        
    }];
    
}

#pragma mark UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.wordMatches count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"]  autorelease];
    
    [cell.textLabel setText:[self.wordMatches objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *)_tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark Dealloc

- (void) dealloc {
    [tableView release];
    [wordMatches release];
    [dictionaryWords release];
    [query release];
    [super dealloc];
}

@end
