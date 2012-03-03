/*******************************************************************
    SmartEntitySubscription - 2012-03-02
    Author: Florian Hoehn
    class to control adding new Followers to a Set of records
*******************************************************************/
public with sharing class SmartEntitySubscription{
    /*******************************************************************
        Exception for SmartEntitySubscription class
    *******************************************************************/
    public class SmartEntitySubscriptionException extends Exception{}
    
    /*******************************************************************
        maps to control existing & new EntitySubscriptions
    *******************************************************************/
    private Map<String, EntitySubscription> existingEntitySubscriptionsMap;
    private Map<String, EntitySubscription> newEntitySubscriptionsMap;
    
    /*******************************************************************
        constructor to get all existing EntitySubscriptions from Set of RecordIds
    *******************************************************************/
    public SmartEntitySubscription(Set<Id> allParentIds){
        this.existingEntitySubscriptionsMap = new Map<String, EntitySubscription>();
        this.newEntitySubscriptionsMap = new Map<String, EntitySubscription>();
        for(EntitySubscription thisEntitySubscription : [SELECT ParentId, SubscriberId 
                                                           FROM EntitySubscription
                                                          WHERE ParentId IN: allParentIds]){
            this.existingEntitySubscriptionsMap.put(thisEntitySubscription.ParentId + '|' + thisEntitySubscription.SubscriberId, thisEntitySubscription);
        }
    }

    /*******************************************************************
        add EntitySubscription to new Map if it does not exist yet
    *******************************************************************/
    public void addEntitySubscriptions(Id parentId, Id subscriberId){
        EntitySubscription thisEntitySubscription = new EntitySubscription(ParentId = parentId, 
                                                                           SubscriberId = subscriberId);
        if(this.existingEntitySubscriptionsMap.get(thisEntitySubscription.ParentId + '|' + thisEntitySubscription.SubscriberId) == null){
            this.newEntitySubscriptionsMap.put(thisEntitySubscription.ParentId + '|' + thisEntitySubscription.SubscriberId, thisEntitySubscription);
        }
    }

    /*******************************************************************
        insert all new EntitySubscriptions
    *******************************************************************/
    public void insertNewEntitySubscriptions(){
        try{
            insert this.newEntitySubscriptionsMap.Values();
        } catch (Exception e){
            throw new SmartEntitySubscriptionException(e.getMessage());
        }
    }
}