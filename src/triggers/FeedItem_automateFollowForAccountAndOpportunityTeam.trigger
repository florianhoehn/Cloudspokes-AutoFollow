/*******************************************************************
    FeedItem_automateFollowForAccountAndOpportunityTeam - 2012-03-02
    Author: Florian Hoehn
    trigger to let account and opportunity team members auto follow the 
    accounts or opportunities when a new chatter post is created on
    these
*******************************************************************/
trigger FeedItem_automateFollowForAccountAndOpportunityTeam on FeedItem (after insert) {
    if(trigger.isAfter
            && trigger.isInsert){
        Set<Id> allAccountIds = new Set<Id>();
        Set<Id> allOpportunityIds = new Set<Id>();
        /*******************************************************************
            checks if feedItem is created on an account or opportunity
        *******************************************************************/
        for(FeedItem thisFeedItem : trigger.new){
            if(String.valueOf(thisFeedItem.parentId).startsWith(Account.SObjectType.getDescribe().getKeyPrefix())){
                allAccountIds.add(thisFeedItem.parentId);
            } else if(String.valueOf(thisFeedItem.parentId).startsWith(Opportunity.SObjectType.getDescribe().getKeyPrefix())){
                allOpportunityIds.add(thisFeedItem.parentId);
            }
        }
        /*******************************************************************
            creates one SmartEntitySubscription object to handle both, 
            accounts and opportunities
        *******************************************************************/
        Set<Id> allParentIds = new Set<Id>();
        allParentIds.addAll(allAccountIds);
        allParentIds.addAll(allOpportunityIds);
        SmartEntitySubscription thisSmartEntitySubscription = new SmartEntitySubscription(allParentIds);
        for(AccountTeamMember thisAccountTeamMember : [SELECT AccountId, UserId 
                                                         FROM AccountTeamMember
                                                        WHERE AccountId IN: allAccountIds]){
            thisSmartEntitySubscription.addEntitySubscriptions(thisAccountTeamMember.AccountId, thisAccountTeamMember.UserId);
        }
        for(OpportunityTeamMember thisOpportunityTeamMember : [SELECT OpportunityId, UserId 
                                                                 FROM OpportunityTeamMember
                                                                WHERE OpportunityId IN: allOpportunityIds]){
            thisSmartEntitySubscription.addEntitySubscriptions(thisOpportunityTeamMember.OpportunityId, thisOpportunityTeamMember.UserId);
        }
        thisSmartEntitySubscription.insertNewEntitySubscriptions();
    }
}