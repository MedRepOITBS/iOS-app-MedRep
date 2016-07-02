//
//  ShareOptionsViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/2/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRShareOptionsViewController.h"
#import "MRCommon.h"
#import "MRDatabaseHelper.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "MRGroupPost.h"

@interface MRShareOptionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *emptyMessageLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSArray *groups;

@property (nonatomic) NSMutableArray *checkedContacts;
@property (nonatomic) NSMutableArray *checkedGroups;

@property (nonatomic) NSMutableArray *selectedContactsName;
@property (nonatomic) NSMutableArray *selectedGroupsName;

@end

@implementation MRShareOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(kShareOptionsTitle, "");
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notificationback.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:kDone
                                                                        style:UIBarButtonItemStyleDone target:self
                                                                       action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self fetchContactsAndGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MRCommon applyNavigationBarStyling:self.navigationController];
}

- (void)fetchContactsAndGroups {
    self.contacts = [MRDatabaseHelper getContacts];
    self.groups = [MRDatabaseHelper getGroups];
    
    if ((self.contacts == nil || self.contacts.count == 0) &&
        (self.groups == nil || self.groups.count == 0)) {
        [self.emptyMessageLabel setHidden:false];
        [self.tableView setHidden:true];
    } else {
        [self.emptyMessageLabel setHidden:true];
        [self.tableView setHidden:false];
    }
    
    if (self.contacts != nil && self.contacts.count > 0) {
        self.checkedContacts = [self setDefaultValues:self.contacts.count];
    }
    
    if (self.groups != nil && self.groups.count > 0) {
        self.checkedGroups = [self setDefaultValues:self.groups.count];
    }
    
    self.selectedContactsName = [NSMutableArray new];
    self.selectedGroupsName = [NSMutableArray new];
}

- (NSMutableArray*)setDefaultValues:(NSInteger)maxCount {
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger index = 0; index < maxCount; index++) {
        [array addObject:[NSNumber numberWithBool:false]];
    }
    return array;
}

// UITable View delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    
    if (self.contacts != nil && self.groups != nil) {
        sections = 2;
    } else if (self.contacts == nil || self.groups == nil) {
        sections = 1;
    }
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        rows = self.contacts.count;
    } else {
        rows = self.groups.count;
    }
    return rows;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *text = @"";
    if (section == 0) {
        text = kContacts;
    } else {
        text = kGroups;
    }
    
    return text;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil )
    {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self getName:indexPath];
    
    BOOL value = false;
    if (indexPath.section == 0) {
        value = ((NSNumber*)self.checkedContacts[indexPath.row]).boolValue;
    } else {
        value = ((NSNumber*)self.checkedGroups[indexPath.row]).boolValue;
    }
    
    if (value) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.section == 0) {
        BOOL currentValue = ((NSNumber*)self.checkedContacts[indexPath.row]).boolValue;
        self.checkedContacts[indexPath.row] = [NSNumber numberWithBool:!currentValue];
        
        if (currentValue) {
            [self.selectedContactsName removeObject:[self getName:indexPath]];
        } else {
            [self.selectedContactsName addObject:[self getName:indexPath]];
        }
    } else {
        BOOL currentValue = ((NSNumber*)self.checkedContacts[indexPath.row]).boolValue;
        self.checkedGroups[indexPath.row] = [NSNumber numberWithBool:!currentValue];
        
        if (currentValue) {
            [self.selectedGroupsName removeObject:[self getName:indexPath]];
        } else {
            [self.selectedGroupsName addObject:[self getName:indexPath]];
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)doneButtonClicked {
    NSArray *selectedContacts = nil;
    NSArray *selectedGroups = nil;
    
    if (self.selectedContactsName.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", @"name", self.selectedContactsName];
        selectedContacts = [MRDatabaseHelper getObjectsForType:kContactEntity
                                                           andPredicate:predicate];
    }
    
    if (self.selectedGroupsName.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", @"name", self.selectedGroupsName];
        selectedGroups = [MRDatabaseHelper getObjectsForType:kGroupEntity
                                                  andPredicate:predicate];
    }
    
    NSMutableArray *groupPostsList = [NSMutableArray new];
    
    if (selectedContacts != nil || selectedGroups != nil) {
        
        NSMutableDictionary *postDict = [NSMutableDictionary new];
        postDict[@"postText"] = self.groupPost.postText;
        postDict[@"likes"] = [NSNumber numberWithLong:self.groupPost.numberOfLikes];
        postDict[@"comments"] = [NSNumber numberWithLong:self.groupPost.numberOfComments];
        postDict[@"shares"] = [NSNumber numberWithLong:(self.groupPost.numberOfShares + 1)];
        postDict[@"post_pic"] = self.groupPost.postPic;
        postDict[@"id"] = [NSNumber numberWithLong:self.groupPost.groupPostId];
        
        if (selectedContacts != nil) {
            for (NSInteger index = 0; index < selectedContacts.count; index++) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:postDict];
                MRContact *tempContact = selectedContacts[index];
                tempDict[@"contactId"] = [NSNumber numberWithLong:tempContact.contactId];
                [groupPostsList addObject:tempDict];
            }
        }
        
        if (selectedGroups != nil) {
            for (NSInteger index = 0; index < selectedGroups.count; index++) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:postDict];
                MRGroup *tempGroup = selectedGroups[index];
                tempDict[@"groupId"] = [NSNumber numberWithLong:tempGroup.groupId];
                [groupPostsList addObject:tempDict];
            }
        }
        
        if (groupPostsList.count > 0) {
            [MRDatabaseHelper addGroupPosts:groupPostsList];
        }
    }
    
    self.groupPost.numberOfShares = self.groupPost.numberOfShares + 1;
    NSLog(@"%ld", [NSNumber numberWithLong:self.groupPost.numberOfShares].integerValue);
    [self.groupPost.managedObjectContext save:nil];
    
    [self.navigationController popViewControllerAnimated:true];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(shareToSelected)]) {
        [self.delegate shareToSelected];
    }
}

- (NSString*)getName:(NSIndexPath*)indexPath {
    NSString *text = @"";
    
    if (indexPath.section == 0) {
        text = [self getContactName:self.contacts andIndex:indexPath.row];
    } else {
        text = [self getGroupName:self.groups andIndex:indexPath.row];
    }
    
    return text;
}

- (NSString*)getContactName:(NSArray*)dataArray andIndex:(NSInteger)index {
    NSString *text = @"";
    
    MRContact *contact = self.contacts[index];
    if (contact != nil && contact.name != nil && contact.name.length > 0) {
        text = contact.name;
    }
    
    return text;
}

- (NSString*)getGroupName:(NSArray*)dataArray andIndex:(NSInteger)index {
    NSString *text = @"";
    
    MRGroup *group = self.groups[index];
    if (group != nil && group.name != nil && group.name.length > 0) {
        text = group.name;
    }
    
    return text;
}

@end
