trigger QuoteLineBacklogTrigger on Quote_Line_Backlog__c  (before insert, before update)
{
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate))
    {
        List<String> quoteIds = new List<String>();
        List<Id> prodIds = new List<Id>();
        Map<String,Quote> quoteMap = new Map<String,Quote>();
        for(Quote_Line_Backlog__c qlb : trigger.new)
        {
            //if(qlb.Derived_Portfolio_Segment__c == NULL || qlb.Derived_Portfolio_Segment__c == '')
            //{
                if(qlb.SAP_Quote_Number__c <> NULL)
                    quoteIds.add(qlb.SAP_Quote_Number__c);
                if(qlb.Product__c <> NULL)
                    prodIds.add(qlb.Product__c);
            //}
        }
        
        List<Quote> quoteList = [SELECT id, SAP_Quote_Number_Truncated__c,Status, opportunity.OpportunityGroup__c, 
                                 opportunity.Opportunity__c, //IBA-5787 Saptarsha Panthi
                                 Order_Type__c FROM Quote WHERE SAP_Quote_Number_Truncated__c IN :quoteIds];
        for(Quote q:quoteList){
            quoteMap.put(q.SAP_Quote_Number_Truncated__c, q);
        }
        
        system.debug('prodIds-->'+prodIds);
        Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT ID, Portfolio_Segment__c 
                                                           FROM product2
                                                           WHERE id IN :prodIds]);
        
        for(Quote_Line_Backlog__c qlb : trigger.new)
        {
            String derivedPortSegment = '';
            String productPortfolioSegment = prodMap.containsKey(qlb.Product__c) ? prodMap.get(qlb.Product__c).Portfolio_Segment__c : '';
            system.debug('productPortfolioSegment-->'+productPortfolioSegment+';;;'+prodMap);
            if(qlb.Order_Type__c == 'ZORB' || qlb.Order_Type__c == 'ZORX')
            {
                derivedPortSegment = 'Consumables / Core Machines';
            }
            else if((quoteMap.containsKey(qlb.SAP_Quote_Number__c) && (quoteMap.get(qlb.SAP_Quote_Number__c).Status == 'E0024' 
                    || quoteMap.get(qlb.SAP_Quote_Number__c).opportunity.OpportunityGroup__c == 'Advanced Services' 
                    ||quoteMap.get(qlb.SAP_Quote_Number__c).opportunity.Opportunity__c == 'Adv Svc Renewal' ////IBA-5787 updated if condition with "quoteMap.get(qlb.SAP_Quote_Number__c).opportunity.Opportunity__c == 'Adv Svc Renewal'" Saptarsha Panthi
                    || quoteMap.get(qlb.SAP_Quote_Number__c).Order_Type__c == 'ZQRS'))
                    || productPortfolioSegment == 'Services' || productPortfolioSegment == 'Central Pharmacy Dispensing Service'   //IBA-4331
                    || productPortfolioSegment == 'IV Compounding Service' || productPortfolioSegment == 'IV Legacy'
                    || productPortfolioSegment == 'IVX Workflow')
            {
                derivedPortSegment = 'Advanced Services';
            }
            else if(qlb.SAPProductType__c  == 'Subscription')
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
            if(quoteMap.containsKey(qlb.SAP_Quote_Number__c)){
                qlb.Quote__c = quoteMap.get(qlb.SAP_Quote_Number__c).id;
            }
            qlb.Derived_Portfolio_Segment__c = derivedPortSegment;
        }
    }
}