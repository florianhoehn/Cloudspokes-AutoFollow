/*******************************************************************
    Account_automateFollowForAccountTeam - 2012-03-02
    Author: Florian Hoehn
    trigger to let account team members auto follow the accounts
    when these are edited
*******************************************************************/
trigger Account_automateFollowForAccountTeam on Account (after update) {
    if(trigger.isAfter
            && trigger.isUpdate){
        Set<Id> allAccountIds = trigger.newMap.KeySet();
        SmartEntitySubscription thisSmartEntitySubscription = new SmartEntitySubscription(allAccountIds);
        for(AccountTeamMember thisAccountTeamMember : [SELECT AccountId, UserId 
                                                         FROM AccountTeamMember
                                                        WHERE AccountId IN: allAccountIds]){
            thisSmartEntitySubscription.addEntitySubscriptions(thisAccountTeamMember.AccountId, thisAccountTeamMember.UserId);
        }
        thisSmartEntitySubscription.insertNewEntitySubscriptions();
    }
}