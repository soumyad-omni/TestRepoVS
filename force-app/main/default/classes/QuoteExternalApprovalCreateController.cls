public class QuoteExternalApprovalCreateController {
    @AuraEnabled
    Public static Id createChildRecord(Id quoteId){
        Additional_Quote_Approval__c tcq = new Additional_Quote_Approval__c();
        System.debug('******'+quoteId);
        tcq.Quote_Approval__c = quoteId;
        insert tcq;
        if(tcq.Id!=NULL)
            return tcq.Id;
        else return NULL;
    }
}