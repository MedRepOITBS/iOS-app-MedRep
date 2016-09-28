//
//  ShareOptionsViewController.m
//  MedRep
//
//  Created by Vamsi Katragadda on 7/2/16.
//  Copyright © 2016 MedRep. All rights reserved.
//

#import "MRShareOptionsViewController.h"
#import "MRConstants.h"
#import "MRContact.h"
#import "MRGroup.h"
#import "MRSharePost.h"
#import "MRAppControl.h"
#import "MRShareOptionTableViewCell.h"

@interface MRShareOptionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *emptyMessageLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *contacts;
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MRShareOptionTableViewCell"
                                               bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MRShareOptionTableViewCell"];
    
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
    [MRDatabaseHelper getGroups:^(id result){
        [MRDatabaseHelper getContacts:^(id result) {
            self.contacts = [[MRDataManger sharedManager] fetchObjectList:kContactEntity
                                                                   attributeName:@"firstName"
                                                             sortOrder:true];
            
            self.groups = [[MRDataManger sharedManager] fetchObjectList:kGroupEntity
                                                          attributeName:@"group_name"
                                                              sortOrder:true];
            [self updateUI];
            [self.tableView reloadData];
        }];
    }];
}

- (void)updateUI {
   // self.groups = [MRDatabaseHelper getGroups];
    
    if ((self.contacts == nil || self.contacts.count == 0) &&
        (self.groups == nil || self.groups.count == 0)) {
        [self.searchBar setHidden:true];
        [self.emptyMessageLabel setHidden:false];
        [self.tableView setHidden:true];
        
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        [self.emptyMessageLabel setHidden:true];
        [self.tableView setHidden:false];
        [self.searchBar setHidden:false];
        
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:kDone
                                                                            style:UIBarButtonItemStyleDone target:self
                                                                           action:@selector(doneButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
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
    static NSString *cellIdentifier = @"MRShareOptionTableViewCell";
    MRShareOptionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil )
    {
        cell = [[MRShareOptionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        [cell setContactDataInCell:[self.contacts objectAtIndex:indexPath.row]];
    } else {
        [cell setGroupDataInCell:[self.groups objectAtIndex:indexPath.row]];
    }

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
    
    NSInteger uniqueId = [self getUniqueId:indexPath];
    
    if (indexPath.section == 0) {
        
        BOOL currentValue = ((NSNumber*)self.checkedContacts[indexPath.row]).boolValue;
        self.checkedContacts[indexPath.row] = [NSNumber numberWithBool:!currentValue];
        
        if (currentValue) {
            [self.selectedContactsName removeObject:[NSNumber numberWithLong:uniqueId]];
        } else {
            [self.selectedContactsName addObject:[NSNumber numberWithLong:uniqueId]];
        }
    } else {
        BOOL currentValue = ((NSNumber*)self.checkedGroups[indexPath.row]).boolValue;
        self.checkedGroups[indexPath.row] = [NSNumber numberWithBool:!currentValue];
        
        if (currentValue) {
            [self.selectedGroupsName removeObject:[NSNumber numberWithLong:uniqueId]];
        } else {
            [self.selectedGroupsName addObject:[NSNumber numberWithLong:uniqueId]];
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)doneButtonClicked {
    NSMutableDictionary *postMessage = [NSMutableDictionary new];
    
    NSArray *selectedContacts = nil;
    NSArray *selectedGroups = nil;
    
    if (self.selectedContactsName.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", @"doctorId", self.selectedContactsName];
        selectedContacts = [MRDatabaseHelper getObjectsForType:kContactEntity
                                                           andPredicate:predicate];
        
        if (selectedContacts != nil && selectedContacts.count > 0) {
            [postMessage setValue:[selectedContacts valueForKey:@"doctorId"] forKey:@"receiverId"];
        }
    }
    
    if (self.selectedGroupsName.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", @"group_id", self.selectedGroupsName];
        selectedGroups = [MRDatabaseHelper getObjectsForType:kGroupEntity
                                                  andPredicate:predicate];
        
        if (selectedGroups != nil && selectedGroups.count > 0) {
            [postMessage setValue:[selectedGroups valueForKey:@"group_id"] forKey:@"groupId"];
        }
    }
    
    if (selectedContacts != nil || selectedGroups != nil) {
        [postMessage setObject:[NSNumber numberWithInteger:1] forKey:@"postType"];
        [postMessage setObject:self.parentPost.short_desc forKey:@"message"];
        [postMessage setObject:self.parentPost.message_type forKey:@"message_type"];
        
        NSDictionary *dataDict = @{@"topic_id" : [NSNumber numberWithLong:self.parentPost.sharePostId.longValue],
                                   @"postMessage" : postMessage
                                   };
        
        [MRDatabaseHelper postANewTopic:dataDict withHandler:^(id result) {
            if (result) {
                [MRCommon showAlert:@"Successfully shared the topic!!!" delegate:nil];
                NSInteger currentSharesCount = 0;
                
                if (self.parentPost != nil && self.parentPost.shareCount != nil) {
                    currentSharesCount = self.parentPost.shareCount.longValue;
                }
                
                self.parentPost.shareCount = [NSNumber numberWithLong:currentSharesCount + 1];
                [self.parentPost.managedObjectContext save:nil];
                 
                [self.navigationController popViewControllerAnimated:true];
                 
                 if (self.delegate != nil && [self.delegate respondsToSelector:@selector(shareToSelected)]) {
                     [self.delegate shareToSelected];
                 }
            } else {
                [MRCommon showAlert:@"Failed to share the topic !!!" delegate:nil];
            }
        }];
    }
}

- (MRSharePost*)createSharePostFrom:(NSManagedObjectContext*)context
                  postedByProfileId:(NSString*)profileId
                        profileName:(NSString*)profileName
                      andprofilePic:(NSData*)profilePic {
    MRSharePost *newPost = (MRSharePost*)[[MRDataManger sharedManager] createObjectForEntity:kMRSharePost inContext:context];
    newPost.parentSharePostId = self.parentPost.sharePostId;
    newPost.sharePostId = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    newPost.postedOn = [NSDate date];
    
    newPost.parentTransformPostId = self.parentPost.parentTransformPostId;
    newPost.contentType = self.parentPost.contentType;
    newPost.titleDescription = self.parentPost.titleDescription;
    newPost.shortText = self.parentPost.shortText;
    newPost.detailedText = self.parentPost.detailedText;
    newPost.url = self.parentPost.url;
    newPost.source = self.parentPost.source;
    
    // Set the current user in sharedBy
    newPost.sharedByProfileName = profileName;
    
    return newPost;
}

- (NSInteger)getUniqueId:(NSIndexPath*)indexPath {
    NSInteger uniqueId = 0;
    
    if (indexPath.section == 0) {
        uniqueId = [self getContactId:self.contacts andIndex:indexPath.row];
    } else {
        uniqueId = [self getGroupId:self.groups andIndex:indexPath.row];
    }
    
    return uniqueId;
}

- (NSInteger)getContactId:(NSArray*)dataArray andIndex:(NSInteger)index {
    
    MRContact *contact = [self.contacts objectAtIndex:index];
    return contact.doctorId.longValue;
}

- (NSInteger)getGroupId:(NSArray*)dataArray andIndex:(NSInteger)index {
    MRGroup *group = [self.groups objectAtIndex:index];
    return group.group_id.longValue;
}

@end
