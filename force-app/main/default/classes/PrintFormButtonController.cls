public class PrintFormButtonController {    
    
    public PrintFormButtonController(){
        
    }
/*
    @AuraEnabled
    public static boolean getFormDetails(String accountid){
        system.debug('accountid: '+ accountid);
        List<disco__Form__c> qf = [SELECT Id, disco__Form_Template_Name__c FROM disco__Form__c where disco__Form_Account__r.Id =: accountid and disco__Status__c = 'SUBMITTED' and disco__Form_Template_Name__c LIKE 'Walkthrough Form%'];
        if(qf!=null && qf.size()>0){
            System.debug('Call Flow');
            CallFlow(accountid);
            return true;
        }
        else{
            return false;
        }
    }
    
    Public Static void CallFlow(String accountid){
    	Map<String, Object> variables = new Map<String, Object>();
    	variables.put('RecordId', accountid);
        System.debug('Inside Call Flow For Account:'+accountid );
        System.debug('Inside Call Flow For variables:'+variables );
    	//Flow.Interview.Updatecheckbox myFlow = new Flow.Interview.Updatecheckbox(variables);
    	//myFlow.start();
        System.debug('Flow Starts');
    }*/
}