/*******************************************************************
    SmartEntitySubscription_TEST - 2012-03-02
    Author: Florian Hoehn
    unit tests for class SmartEntitySubscription
                   trigger Account_automateFollowForAccountTeam
                   trigger Opportunity_automateFollowForOpportunityTeam
                   trigger FeedItem_automateFollowForAccountAndOpportunityTeam
    all unit tests are written to test BULK transactions
*******************************************************************/
@isTest(seeAllData=false)
private with sharing class SmartEntitySubscription_TEST{
    /*******************************************************************
        tests auto following
    *******************************************************************/
    @isTest(seeAllData=false)
    private static void testAutoFollowSuccess(){
        /*******************************************************************
            prepare test data
        *******************************************************************/
        Integer numberOfUsers = 10;
        Integer numberOfAccounts = 200;

        Set<Id> testUserIds = getTestUserIds(numberOfUsers);

        List<Account> testAccounts = getTestAccounts(numberOfAccounts);
        insert testAccounts;
        Set<Id> testAccountIds = getTestAccountIds(testAccounts);

        createFollowingForHalfOfTheTestUsers(testAccountIds, testUserIds);
        
        /*******************************************************************
            test
        *******************************************************************/
        Test.startTest();
            SmartEntitySubscription testSmartEntitySubscription = new SmartEntitySubscription(testAccountIds);
            for(Id thisAccountId : testAccountIds){
                for(Id thisUserId : testUserIds){
                    testSmartEntitySubscription.addEntitySubscriptions(thisAccountId, thisUserId);
                }
            }
            testSmartEntitySubscription.insertNewEntitySubscriptions();
        Test.stopTest();

        /*******************************************************************
            assert overall number of EntitySubscriptions after tests
        *******************************************************************/
        List<EntitySubscription> assertEntitySubscriptions = [SELECT ParentId, SubscriberId 
                                                                FROM EntitySubscription
                                                               WHERE ParentId IN: testAccountIds
                                                                 AND SubscriberId IN: testUserIds];
        System.AssertEquals(assertEntitySubscriptions.Size(), numberOfAccounts * numberOfUsers);
        
        /*******************************************************************
            assert number of EntitySubscriptions for random account after tests
        *******************************************************************/
        Account assertRandomAccount = testAccounts.get(numberOfAccounts / 2);
        List<EntitySubscription> assertAccountEntitySubscriptions = [SELECT ParentId, SubscriberId 
                                                                       FROM EntitySubscription
                                                                      WHERE ParentId =: assertRandomAccount.Id
                                                                        AND SubscriberId IN: testUserIds];
        System.AssertEquals(assertAccountEntitySubscriptions.Size(), numberOfUsers);
        for(EntitySubscription thisEntitySubscription : assertEntitySubscriptions){
            System.Assert(testUserIds.Contains(thisEntitySubscription.SubscriberId));
        }
    }

    /*******************************************************************
        tests auto following failure
    *******************************************************************/
    @isTest(seeAllData=false)
    private static void testAutoFollowException(){
        /*******************************************************************
            prepare test data
        *******************************************************************/
        Integer numberOfAccounts = 1;

        List<Account> testAccounts = getTestAccounts(numberOfAccounts);
        insert testAccounts;
        Set<Id> testAccountIds = getTestAccountIds(testAccounts);
        
        /*******************************************************************
            test
        *******************************************************************/
        Test.startTest();
            SmartEntitySubscription testSmartEntitySubscription = new SmartEntitySubscription(testAccountIds);
            for(Id thisAccountId : testAccountIds){
                testSmartEntitySubscription.addEntitySubscriptions(thisAccountId, thisAccountId);
            }
            try{
                testSmartEntitySubscription.insertNewEntitySubscriptions();
            } catch (SmartEntitySubscription.SmartEntitySubscriptionException sesE){
                /*******************************************************************
                    assert catching the SmartEntitySubscriptionException
                *******************************************************************/
                System.Assert(sesE.getMessage().Contains('FIELD_INTEGRITY_EXCEPTION'));
            }   
        Test.stopTest();
    }

    /*******************************************************************
        tests auto follow trigger on account
    *******************************************************************/
    @isTest(seeAllData=false)
    private static void testAccountAutoFollow(){
        /*******************************************************************
            prepare test data
        *******************************************************************/
        Integer numberOfUsers = 10;
        Integer numberOfAccounts = 200;

        Set<Id> testUserIds = getTestUserIds(numberOfUsers);
        
        List<Account> testAccounts = getTestAccounts(numberOfAccounts);
        insert testAccounts;
        Set<Id> testAccountIds = getTestAccountIds(testAccounts);

        createAccountTeamMemberForAllTestUsers(testAccountIds, testUserIds);
        createFollowingForHalfOfTheTestUsers(testAccountIds, testUserIds);
        
        /*******************************************************************
            test
        *******************************************************************/
        Test.startTest();
            update testAccounts;
        Test.stopTest();

        /*******************************************************************
            assert overall number of EntitySubscriptions after tests
        *******************************************************************/
        List<EntitySubscription> assertEntitySubscriptions = [SELECT ParentId, SubscriberId 
                                                                FROM EntitySubscription
                                                               WHERE ParentId IN: testAccountIds
                                                                 AND SubscriberId IN: testUserIds];
        System.AssertEquals(assertEntitySubscriptions.Size(), numberOfAccounts * numberOfUsers);
        
        /*******************************************************************
            assert number of EntitySubscriptions for random account after tests
        *******************************************************************/
        Account assertRandomAccount = testAccounts.get(numberOfAccounts / 2);
        List<EntitySubscription> assertAccountEntitySubscriptions = [SELECT ParentId, SubscriberId 
                                                                       FROM EntitySubscription
                                                                      WHERE ParentId =: assertRandomAccount.Id
                                                                        AND SubscriberId IN: testUserIds];
        System.AssertEquals(assertAccountEntitySubscriptions.Size(), numberOfUsers);
        for(EntitySubscription thisEntitySubscription : assertEntitySubscriptions){
            System.Assert(testUserIds.Contains(thisEntitySubscription.SubscriberId));
        }
    }

    /*******************************************************************
        tests auto follow trigger on opportunity
    *******************************************************************/
    @isTest(seeAllData=false)
    private static void testOpportunityAutoFollow(){
        /*******************************************************************
            prepare test data
        *******************************************************************/
        Integer numberOfUsers = 10;
        Integer numberOfOpportunitys = 200;

        Set<Id> testUserIds = getTestUserIds(numberOfUsers);

        List<Opportunity> testOpportunitys = getTestOpportunitys(numberOfOpportunitys);
        insert testOpportunitys;
        Set<Id> testOpportunityIds = getTestOpportunityIds(testOpportunitys);

        createOpportunityTeamMemberForAllTestUsers(testOpportunityIds, testUserIds);
        createFollowingForHalfOfTheTestUsers(testOpportunityIds, testUserIds);
        
        /*******************************************************************
            test
        *******************************************************************/
        Test.startTest();
            update testOpportunitys;
        Test.stopTest();

        /*******************************************************************
            assert overall number of EntitySubscriptions after tests
        *******************************************************************/
        List<EntitySubscription> assertEntitySubscriptions = [SELECT ParentId, SubscriberId
                                                                FROM EntitySubscription
                                                               WHERE ParentId IN: testOpportunityIds
                                                                 AND SubscriberId IN: testUserIds];
        System.AssertEquals(assertEntitySubscriptions.Size(), numberOfOpportunitys * numberOfUsers);

        /*******************************************************************
            assert number of EntitySubscriptions for random opportunity after tests
        *******************************************************************/
        Opportunity assertRandomOpportunity = testOpportunitys.get(numberOfOpportunitys / 2);
        List<EntitySubscription> assertOpportunityEntitySubscriptions = [SELECT ParentId, SubscriberId 
                                                                           FROM EntitySubscription
                                                                          WHERE ParentId =: assertRandomOpportunity.Id
                                                                            AND SubscriberId IN: testUserIds];
        System.AssertEquals(assertOpportunityEntitySubscriptions.Size(), numberOfUsers);
        for(EntitySubscription thisEntitySubscription : assertEntitySubscriptions){
            System.Assert(testUserIds.Contains(thisEntitySubscription.SubscriberId));
        }
    }

    /*******************************************************************
        tests auto follow trigger on feedItem
    *******************************************************************/
    @isTest(seeAllData=false)
    private static void testFeedItemAutoFollow(){
        /*******************************************************************
            prepare test data
        *******************************************************************/
        Integer numberOfUsers = 10;
        Integer numberOfOpportunitys = 200;
        Integer numberOfAccounts = 200;

        Set<Id> testUserIds = getTestUserIds(numberOfUsers);
        List<Account> testAccounts = getTestAccounts(numberOfAccounts);
        insert testAccounts;
        Set<Id> testAccountIds = getTestAccountIds(testAccounts);

        createAccountTeamMemberForAllTestUsers(testAccountIds, testUserIds);
        createFollowingForHalfOfTheTestUsers(testAccountIds, testUserIds);

        List<Opportunity> testOpportunitys = getTestOpportunitys(numberOfOpportunitys);
        insert testOpportunitys;
        Set<Id> testOpportunityIds = getTestOpportunityIds(testOpportunitys);

        createOpportunityTeamMemberForAllTestUsers(testOpportunityIds, testUserIds);
        createFollowingForHalfOfTheTestUsers(testOpportunityIds, testUserIds);
        
        List<FeedItem> testFeedItems = getTestFeedItemsForAllRecords(testAccountIds);
        testFeedItems.addAll(getTestFeedItemsForAllRecords(testOpportunityIds));

        /*******************************************************************
            test
        *******************************************************************/
        Test.startTest();
            insert testFeedItems;
        Test.stopTest();

        /*******************************************************************
            assert overall number of EntitySubscriptions after tests
        *******************************************************************/
        List<EntitySubscription> assertEntitySubscriptions = [SELECT ParentId, SubscriberId
                                                                FROM EntitySubscription
                                                               WHERE (ParentId IN: testAccountIds
                                                                      OR ParentId IN: testOpportunityIds)
                                                                 AND SubscriberId IN: testUserIds];
                                                               
        System.AssertEquals(assertEntitySubscriptions.Size(), (numberOfOpportunitys + numberOfAccounts) * numberOfUsers);

        /*******************************************************************
            assert number of EntitySubscriptions for random account after tests
        *******************************************************************/
        Account assertRandomAccount = testAccounts.get(numberOfAccounts / 2);
        List<EntitySubscription> assertAccountEntitySubscriptions = [SELECT ParentId, SubscriberId 
                                                                       FROM EntitySubscription
                                                                      WHERE ParentId =: assertRandomAccount.Id
                                                                        AND SubscriberId IN: testUserIds];
        System.AssertEquals(assertAccountEntitySubscriptions.Size(), numberOfUsers);
        for(EntitySubscription thisEntitySubscription : assertEntitySubscriptions){
            System.Assert(testUserIds.Contains(thisEntitySubscription.SubscriberId));
        }

        /*******************************************************************
            assert number of EntitySubscriptions for random opportunity after tests
        *******************************************************************/
        Opportunity assertRandomOpportunity = testOpportunitys.get(numberOfOpportunitys / 2);
        List<EntitySubscription> assertOpportunityEntitySubscriptions = [SELECT ParentId, SubscriberId 
                                                                           FROM EntitySubscription
                                                                          WHERE ParentId =: assertRandomOpportunity.Id
                                                                            AND SubscriberId IN: testUserIds];
        System.AssertEquals(assertOpportunityEntitySubscriptions.Size(), numberOfUsers);
        for(EntitySubscription thisEntitySubscription : assertEntitySubscriptions){
            System.Assert(testUserIds.Contains(thisEntitySubscription.SubscriberId));
        }
    }

    /*******************************************************************
        gets standard profile record
    *******************************************************************/
    private static Profile getStandardProfile(String profileName) {
        return [SELECT Id, Name, UserLicense.LicenseDefinitionKey 
                  FROM Profile
                 WHERE Name =: profileName];
    }

    /*******************************************************************
        gets x number of test users
    *******************************************************************/
    private static List<User> getTestUsers(Integer numberOfUsers) {
        Profile testProfile = getStandardProfile('Standard User');
        List<User> bulkTestUsers = new List<User>();
        for(Integer counter = 0; counter < numberOfUsers; counter++){
            User testUser = new User(Alias = 'TUSER' + counter,
                                     Email = 'TEST.USER@TEST.TEST',
                                     EmailEncodingKey = 'UTF-8',
                                     FirstName = 'First_TEST' + counter,
                                     LastName = 'TEST_LAST_NAME' + counter, 
                                     LanguageLocaleKey = 'en_US',
                                     LocaleSidKey = 'en_GB',
                                     ProfileId = testProfile.Id,
                                     TimezonesIdKey = 'Europe/London',
                                     Title = 'TEST TITLE',
                                     Username = 'TEST.USER@TEST.TEST' + counter);
            bulkTestUsers.add(testUser);
        }
        return bulkTestUsers;
    }

    /*******************************************************************
        gets a set with all test user ids
    *******************************************************************/
    private static Set<Id> getTestUserIds(Integer numberOfUsers){
        List<User> testUsers = getTestUsers(numberOfUsers);
        insert testUsers;
        Set<Id> testUserIds = new  Set<Id>();
        for(User thisUser : testUsers){
            testUserIds.add(thisUser.Id);
        }
        return testUserIds;
    }

    /*******************************************************************
        gets x number of test accounts
    *******************************************************************/
    private static List<Account> getTestAccounts(Integer numberOfAccounts) {
        List<Account> bulkTestAccounts = new List<Account>();
        for(Integer counter = 0; counter < numberOfAccounts; counter++){
            Account testAccount = new Account(Name = 'TESTACCOUNTNAME' + counter);
            bulkTestAccounts.add(testAccount);
        }
        return bulkTestAccounts;
    }

    /*******************************************************************
        gets a set with all test account ids
    *******************************************************************/
    private static Set<Id> getTestAccountIds(List<Account> testAccounts){
        Set<Id> testAccountIds = new Set<Id>();
        for(Account thisAccount : testAccounts){
            testAccountIds.add(thisAccount.Id); 
        }
        return testAccountIds;
    }

    /*******************************************************************
        gets x number of test opportunities
    *******************************************************************/
    private static List<Opportunity> getTestOpportunitys(Integer numberOfOpportunitys) {
        Account testAccount = new Account(Name = 'TESTACCOUNTNAME');
        List<Opportunity> bulkTestOpportunitys = new List<Opportunity>();
        for(Integer counter = 0; counter < numberOfOpportunitys; counter++){
            Opportunity testOpportunity = new Opportunity(AccountId = testAccount.Id,
                                                          Name = 'TESTOPPORTUNITYNAME' + counter,
                                                          CloseDate = System.Today(),
                                                          StageName = 'Open');
            bulkTestOpportunitys.add(testOpportunity);
        }
        return bulkTestOpportunitys;
    }

    /*******************************************************************
        gets a set with all test opportunity ids
    *******************************************************************/
    private static Set<Id> getTestOpportunityIds(List<Opportunity> testOpportunitys){
        Set<Id> testOpportunityIds = new Set<Id>();
        for(Opportunity thisOpportunity : testOpportunitys){
            testOpportunityIds.add(thisOpportunity.Id);
        }
        return testOpportunityIds;
    }

    /*******************************************************************
        lets every second test user follow each of the parent records
    *******************************************************************/
    private static void createFollowingForHalfOfTheTestUsers(Set<Id> testParentIds, Set<Id> testUserIds){
        List<EntitySubscription> testEntitySubscriptions = new List<EntitySubscription>();
        for(Id thisParentId : testParentIds){
            Integer counter = 0;
            for(Id thisUserId : testUserIds){
                counter++;
                if(math.mod(counter, 2) == 0){
                    EntitySubscription testEntitySubscription = new EntitySubscription(ParentId = thisParentId,
                                                                                   SubscriberId = thisUserId);
                    testEntitySubscriptions.add(testEntitySubscription);
                }
            }
        }
        insert testEntitySubscriptions;
    }

    /*******************************************************************
        lets each test user be on each account team
    *******************************************************************/
    private static void createAccountTeamMemberForAllTestUsers(Set<Id> testAccountIds, Set<Id> testUserIds){
        List<AccountTeamMember> testAccountTeamMembers = new List<AccountTeamMember>();
        for(Id thisAccountId : testAccountIds){
            Integer counter = 0;
            for(Id thisUserId : testUserIds){
                AccountTeamMember testAccountTeamMember = new AccountTeamMember(AccountId = thisAccountId,
                                                                                   UserId = thisUserId);
                testAccountTeamMembers.add(testAccountTeamMember);
            }
        }
        insert testAccountTeamMembers;
    }

    /*******************************************************************
        lets each test user be on each opportunity team
    *******************************************************************/
    private static void createOpportunityTeamMemberForAllTestUsers(Set<Id> testOpportunityIds, Set<Id> testUserIds){
        List<OpportunityTeamMember> testOpportunityTeamMembers = new List<OpportunityTeamMember>();
        for(Id thisOpportunityId : testOpportunityIds){
            Integer counter = 0;
            for(Id thisUserId : testUserIds){
                OpportunityTeamMember testOpportunityTeamMember = new OpportunityTeamMember(OpportunityId = thisOpportunityId,
                                                                                            UserId = thisUserId);
                testOpportunityTeamMembers.add(testOpportunityTeamMember);
            }
        }
        insert testOpportunityTeamMembers;
    }

    /*******************************************************************
        gets a chatter post for each record
    *******************************************************************/
    private static List<FeedItem> getTestFeedItemsForAllRecords(Set<Id> testParentIds){
        List<FeedItem> testFeedItems = new List<FeedItem>();
        for(Id thisParentId : testParentIds){
            FeedItem testFeedItem = new FeedItem(Body = 'TESTFEEDITEM',
                                                 ParentId = thisParentId);
            testFeedItems.add(testFeedItem);
        }
        return testFeedItems;
    }
}