public class AdditionalAppMsgController {
	public String showMessage{get; set;}
    public String qapID {get; set;}
    public AdditionalAppMsgController(ApexPages.StandardController controller){
        try{
            showMessage='';
            qapId = controller.getId();
            Quote_Approval__c qap = [SELECT Id, Recent_Additional_Approval_Status__c FROM Quote_Approval__c WHERE Id =: qapId];
            if(qap.Recent_Additional_Approval_Status__c == 'Waiting'){
                showMessage = 'Waiting for Additional Approval';
            }
        }
        catch(Exception e){
            System.debug('errMessage' + ': ' + e.getMessage());
        }
    }
}