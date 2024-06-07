public class ContactWhereUsedTriggerHandler {
	public static void afterInsert(list<ContactWhereUsed__c> newItems){
		id ids = newItems[0].id;        
        list<ContactWhereUsed__c> cont = [select id,Contact__c,UsedInQuote__c,UsedInOpportunity__c,UsedInCampaignMember__c,Used_in_B2B_Order__c,Used_in_B2B_User__c from ContactWhereUsed__c where id =: ids];//iba-4493
        //cont.add(newItems[0]);
        Id cwu = cont[0].Contact__c;
        
        list<quote> qt = [SELECT id FROM Quote WHERE Shipping_Contact__c = :cwu];
        list<OpportunityContactRole> opp = [SELECT ContactId FROM OpportunityContactRole WHERE ContactId = :cwu];
        list<CampaignMember> cm = [SELECT ContactId FROM CampaignMember WHERE ContactId = :cwu];
        list<ccrz__E_Order__c> ord = [select id,ccrz__Contact__c from ccrz__E_Order__c where ccrz__Contact__c =: cwu];//iba-4493
        list<user> usr = [select id,ContactId from user where ContactId =: cwu];//iba-4493
       
        for(ContactWhereUsed__c c : cont){
            if(qt.size() > 0){
                system.debug('inside q');
                c.UsedInQuote__c = true;
            }
            
            if(opp.size() > 0){
                c.UsedInOpportunity__c = true;
                system.debug('inside p');
            }
            
            if(cm.size() > 0){
                c.UsedInCampaignMember__c = true;
                system.debug('inside m');
            }
            
            //iba-4493 start
           
            if(ord.size() > 0){
                c.Used_in_B2B_Order__c =true;
            }
            
            if(usr.size() > 0){
                c.Used_in_B2B_User__c =true;
            }
           //iba-4493 end
        }
       update cont;
        
    }
}