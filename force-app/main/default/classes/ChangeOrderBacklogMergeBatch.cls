global class ChangeOrderBacklogMergeBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT id,WBS_Status__c, Quote__c, Opportunity_Forecast_Category_Order__c, SAP_Line_Number__c, SAP_Quote_Number__c';
        query = query + ' FROM Backlog_Inflow_Outflow_Tableau__c';
        query = query + ' WHERE WBS_Status__c NOT IN (\'100\',\'101\',\'102\',\'103\',\'104\',\'105\')';
        query = query + ' AND Opportunity_Forecast_Category_Order__c = \'7-Backlog As Of Today\'';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Backlog_Inflow_Outflow_Tableau__c> backlogList) 
    {
        List<String> quoteNumberList = new List<String>();
        Map<String, Backlog_Inflow_Outflow_Tableau__c> backLogMap = new Map<String, Backlog_Inflow_Outflow_Tableau__c>();
        
        for(Backlog_Inflow_Outflow_Tableau__c backlog : backlogList)
        {
            quoteNumberList.add(backlog.SAP_Quote_Number__c);
            backLogMap.put(backlog.SAP_Quote_Number__c+''+backlog.SAP_Line_Number__c, backlog);
        }
        
       	Map<String,List<Change_Order_Tableau__c>> changeOrderMap = new Map<String, List<Change_Order_Tableau__c>>();
        List<Change_Order_Tableau__c> updateTableauList = new List<Change_Order_Tableau__c>();
        
        for(Change_Order_Tableau__c cot : [SELECT id, SAP_Line_Number__c, Higher_Level_Item__c, 
                                            Change_Order_Quote_Line__r.Quote_Line__r.Quote__c,
                                            Backlog_Status__c, WBS_Status__c, Primary_Quote_Number__c
                                            FROM Change_Order_Tableau__c
                                            WHERE Primary_Quote_Number__c IN :quoteNumberList])
        {
            if(backLogMap.containsKey(cot.Primary_Quote_Number__c+''+cot.Higher_Level_Item__c))
            {
                cot.Backlog_Status__c = 'Backlog';
                //cot.Status__c = 'Backlog';
                cot.WBS_Status__c = backLogMap.get(cot.Primary_Quote_Number__c+''+cot.Higher_Level_Item__c).WBS_Status__c;
                   
                updateTableauList.add(cot);
            }
            else if(backLogMap.containsKey(cot.Primary_Quote_Number__c+''+cot.SAP_Line_Number__c))
            {
                cot.Backlog_Status__c = 'Backlog';
                //cot.Status__c = 'Backlog';
                cot.WBS_Status__c = backLogMap.get(cot.Primary_Quote_Number__c+''+cot.SAP_Line_Number__c).WBS_Status__c;
                
                updateTableauList.add(cot);
            }
        }
        
        if(!updateTableauList.isEmpty())
        {
            update updateTableauList;
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}