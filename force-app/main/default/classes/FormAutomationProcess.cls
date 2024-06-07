/**
 * @File Name          : FormAutomationProcess.cls
 * @Description        : Returns the parlocation object for Form 
 * @Author             : Pritha Nandi
 * @Created date       : 18-01-2022
**/
public class FormAutomationProcess {
   @InvocableMethod (label = 'Parlocation Object Return' description = 'returns parlocation from the list')
    public static List<List<Par_location__c>> createForm(List<String>parlocationId){
        String[] VarIds = parlocationId[0].split(';');
       System.debug('ParlocationIds:'+ VarIds ); 
        List<Par_location__c> parLocationDetails = [SELECT Id,Name FROM Par_location__c WHERE Id in :VarIds];
        System.debug('Map Opportunity Size '+ parLocationDetails);
         List<List<Par_location__c>> listOfPar = new List<List<Par_location__c>>();
        listOfPar.add(parLocationDetails);
             System.debug('Map Opportunity Size '+ listOfPar.size());
            System.debug('=== contents of opptymap: ' +listOfPar);

      return listOfPar;
    }
}