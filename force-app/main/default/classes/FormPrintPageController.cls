public class FormPrintPageController {
    
    public FormPrintPageController(){}
    /*
    @AuraEnabled
    public static List<disco__form__c> fetch(string accountid){
    List<disco__form__c> acc = [SELECT id,Name,disco__Form_Template_Name__c,Form_PAR_Location_Name__c,disco__Status__c, disco__Form_Account__r.Name, disco__Form_Account__r.SAP_Customer_Number__c FROM disco__Form__c where disco__Form_Account__r.Id =: accountid and disco__Status__c = 'SUBMITTED' and disco__Form_Template_Name__c LIKE 'Walkthrough Form%'];
        return acc;
    }
	@AuraEnabled
    public static List<YourekaTemplateId__c> getIds(){
    List<YourekaTemplateId__c> ids = [SELECT queryid__c, templateIds__c from YourekaTemplateId__c];
    system.debug('values:'+ids);
    return ids;
    }

	@AuraEnabled
    public static List<disco__form__c> getForms(String pageSize, String pageNumber, String accountid){
        Integer psize = Integer.valueOf(pageSize);
        Integer pnumber = Integer.valueOf(pageNumber)-1;
         
        List<disco__form__c> accList = [SELECT id,Name,disco__Form_Template_Name__c,Form_PAR_Location_Name__c,disco__Status__c, disco__Form_Account__r.Name, disco__Form_Account__r.SAP_Customer_Number__c FROM disco__Form__c where disco__Form_Account__r.Id =: accountid and disco__Status__c = 'SUBMITTED' and disco__Form_Template_Name__c LIKE 'Walkthrough Form%' LIMIT :Integer.valueOf(psize) OFFSET :(psize*pnumber)];
        //return list of accounts
   //     system.debug('Integer.valueOf(psize) OFFSET :(psize*pnumber): '+ 'Limit: ' + Integer.valueOf(psize)+'OFFSET: '+(psize*pnumber));
        return accList;
    }

    @AuraEnabled
    public static List<disco__form__c> printForm(List<disco__form__c> lstId) {
        List<disco__form__c> rf = [SELECT Id,disco__Form_Account__r.Id FROM disco__form__c WHERE Id IN :lstId];
        String accId = '';
        for(disco__form__c a: rf){
       //     system.debug('a.Id: '+ a.Id);
            accId = a.disco__Form_Account__r.Id;
        }
        yourekaForCheckBatch bcn = new yourekaForCheckBatch(rf,accId) ;
   		 ID batchprocessid = Database.executeBatch(bcn);
     //   System.debug('Value of batchProcess' + batchprocessid );
        if (batchprocessid != Null){
            return rf;           
        }
        return null ;
    }
	
     @AuraEnabled
     public static Account nameReturn(String accountid) {
         Account r = [SELECT Name, SAP_Customer_Number__c FROM Account WHERE Id=:accountid];
         return r;
     }
	

    
    @AuraEnabled
    Public Static void CallFlow(String accountid){
    	Map<String, Object> variables = new Map<String, Object>();
    	variables.put('RecordId', accountid);
  //      System.debug('Inside Call Flow For Account:'+accountid );
  //      System.debug('Inside Call Flow For variables:'+variables );
    	Flow.Interview.Updatecheckbox myFlow = new Flow.Interview.Updatecheckbox(variables);
    	myFlow.start();
  //      System.debug('Flow Starts');
    }*/
}