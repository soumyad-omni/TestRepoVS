trigger ChangeOrderQuoteLineTrigger on Change_Order_Quote_Line__c (After insert,After update) {
    Map<Id,Change_Order_Quote_Line__c> quoteLines = new Map<Id,Change_Order_Quote_Line__c>();
    List<Change_Order_Quote_Line__c> changeOrderQLToUpdate = new List<Change_Order_Quote_Line__c>();
    for(Change_Order_Quote_Line__c line : [Select id, Derived_Portfolio_Segment__c, name,Quote_Line__r.Product__r.Portfolio_Segment__c, 
                                           Quote_Line__r.SAP_Quote_Number__c,Quote_Line__r.Quote__r.Status,
                                           Quote_Line__r.Quote__r.Order_Type__c, 
                                           Quote_Line__r.Quote__r.Opportunity.OpportunityGroup__c,
                                           Quote_Line__r.Quote__r.Opportunity.Opportunity__c,//IBA-5787 Saptarsha Panthi
                                           Quote_Line__r.Product__r.SAP_Product_Type__c 
                                           from Change_Order_Quote_Line__c where id in :Trigger.New])
    {
        quoteLines.put(line.id,line);
    }
    for(Change_Order_Quote_Line__c changeOrderLine:Trigger.New){
        Change_Order_Quote_Line__c line = quoteLines.get(changeOrderLine.id);
        String derivedPortSegment = '';
        String productPortfolioSegment = line.Quote_Line__c==null?null:line.Quote_Line__r.Product__r.Portfolio_Segment__c;
        System.debug('productPortfolioSegment:'+productPortfolioSegment);
        String orderType = line.Quote_Line__r.Quote__r.Order_Type__c;
        String quoteStatus = line.Quote_Line__r.Quote__r.Status;
        String oppGroup = line.Quote_Line__r.Quote__r.Opportunity.OpportunityGroup__c;
        String OppType = line.Quote_Line__r.Quote__r.Opportunity.Opportunity__c;//IBA-5787 Saptarsha Panthi
        String productType = line.Quote_Line__r.Product__r.SAP_Product_Type__c;
        if(orderType == 'ZORB' || orderType == 'ZORX')
        {
            derivedPortSegment = 'Consumables / Core Machines';
        }
        else if((quoteStatus == 'E0024' || oppGroup == 'Advanced Services'|| OppType=='Adv Svc Renewal' || orderType == 'ZQRS')
                || productPortfolioSegment == 'Services' || productPortfolioSegment == 'Central Pharmacy Dispensing Service'   //IBA-4331
                || productPortfolioSegment == 'IV Compounding Service' || productPortfolioSegment == 'IV Legacy'
                || productPortfolioSegment == 'IVX Workflow')//IBA-5787 updated if condition with oppType =='Adv Svc Renewal' Saptarsha Panthi
        {
            derivedPortSegment = 'Advanced Services';
        }
        else if(productType  == 'Subscription')
        {
            derivedPortSegment = 'Subscriptions';
        }
        else if(productPortfolioSegment == 'MA Consumable' || productPortfolioSegment == 'Core Machine' 
                || productPortfolioSegment == 'MA Raw/MA tooling' || productPortfolioSegment == 'MultiMed Automation'
                || productPortfolioSegment == 'Packagers' || productPortfolioSegment == 'SingleDose Automation' || productPortfolioSegment == 'Acute Consumable')
        {
            derivedPortSegment = 'Consumables / Core Machines';
        }
        else if(productPortfolioSegment == 'Cloud Hosted OmniCenter' || productPortfolioSegment == 'Infrastructure' 
                || productPortfolioSegment == 'Inventory Optimization Service and Platform')  //IBA-4331
        {
            derivedPortSegment = 'Infrastructure / Shared';
        }
        else if(productPortfolioSegment == 'Carousels' || productPortfolioSegment == 'Central Pharmacy' 
                || productPortfolioSegment == 'Central Pharmacy Legacy')
        {
            derivedPortSegment = 'Central Pharmacy';
        }
        else if(productPortfolioSegment == 'Anesthesia Workstation' || productPortfolioSegment == 'Automated Dispensing Cabinets' 
                || productPortfolioSegment == 'Supply')
        {
            derivedPortSegment = 'Automated Dispensing Cabinets';
        }
        else{
            derivedPortSegment = 'Others';
        }
        if(derivedPortSegment != changeOrderLine.Derived_Portfolio_Segment__c){
            Change_Order_Quote_Line__c lineData = new Change_Order_Quote_Line__c(id=changeOrderLine.id);
            lineData.Derived_Portfolio_Segment__c = derivedPortSegment;
            changeOrderQLToUpdate.add(lineData);
        }
    }
    if(!changeOrderQLToUpdate.isEmpty()){
        update changeOrderQLToUpdate;
    }
}