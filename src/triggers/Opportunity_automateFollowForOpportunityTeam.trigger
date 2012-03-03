/*******************************************************************
    Opportunity_automateFollowForOpportunityTeam - 2012-03-02
    Author: Florian Hoehn
    trigger to let opportunity team members auto follow the 
    opportunities when these are edited
*******************************************************************/
trigger Opportunity_automateFollowForOpportunityTeam on Opportunity (after update) {
    if(trigger.isAfter
            && trigger.isUpdate){
        Set<Id> allOpportunityIds = trigger.newMap.KeySet();
        SmartEntitySubscription thisSmartEntitySubscription = new SmartEntitySubscription(allOpportunityIds);
        for(OpportunityTeamMember thisOpportunityTeamMember : [SELECT OpportunityId, UserId 
                                                                 FROM OpportunityTeamMember
                                                                WHERE OpportunityId IN: allOpportunityIds]){
            thisSmartEntitySubscription.addEntitySubscriptions(thisOpportunityTeamMember.OpportunityId, thisOpportunityTeamMember.UserId);
        }
        thisSmartEntitySubscription.insertNewEntitySubscriptions();
    }
}