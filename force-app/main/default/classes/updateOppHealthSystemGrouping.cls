public class updateOppHealthSystemGrouping {
    
    public static void updateOpp(list<account> accounts){
        list<id> aId = new list<id>();
        string topCsn = '';
        for(account a:accounts){
            aId.add(a.id);            
        }
        
        //Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'Q1',2 => 'Q1',3 => 'Q1',4 => 'Q2',5 => 'Q2',6 => 'Q2',7 => 'Q3',8 => 'Q3',9 => 'Q3',10 => 'Q4',11 => 'Q4',12 => 'Q4'}; commented out for IBA-5820
            topCsn = accounts[0].Top_Level_Parent_CSN_Number__c;
        system.debug('acc '+aId);
        List<Opportunity> oppList = [Select Id, Health_System_Grouping__c From Opportunity Where  account.Id =: aId and (StageName != '6 Closed Won' and StageName != '7 Closed Lost')];//IBA-4878 soumyad //removed CloseDate,account.SAP_Customer_Number__c for IBA-5820
        
        if(oppList.size() > 0){
            for(Opportunity opp:oppList){
                /*string closy = string.valueof(opp.CloseDate.year()); //commented IBA-5820 AMAN
                integer closd = opp.CloseDate.month(); //commented IBA-5820 AMAN
                opp.Health_System_Grouping__c = topCsn + ' - ' + opp.account.SAP_Customer_Number__c + ' - ' + closy + ' ' + string.valueof(monthMap.get(closd));//IBA-4878 soumyad
                
                opp.Health_System_Grouping__c = topCsn + ' - ' + 'NEW'; //IBA-5820 AMAN*/
                }
            
            opportunitytriggerhandler.triggerdisabled = true;
            List<Database.SaveResult> results = Database.update(oppList, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()){
                    for (Database.Error err : result.getErrors()){
                        
                        string e = result.getId() + ',' + err.getStatusCode() + ' ' + err.getMessage();
                        System.debug('Error: '+ e);
                    }
                    
                }
            }
        }
        
    }
    
}