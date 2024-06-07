public class OppDuplicateManagement {
	public String showMessage{get; set;}
    public String showMessage1{get; set;}
    public String MessageInGreen {get; set;}                                             //IBA-4979 AMAN
    public String MessageInRed {get; set;}                                              //IBA-4979 AMAN
    public String oppID {get; set;}
    public OppDuplicateManagement(ApexPages.StandardController controller){
        try{
            showMessage='';
            showMessage1='';
            MessageInGreen='';                                                 //IBA-4979 AMAN
            MessageInRed='';                                                  //IBA-4979 AMAN  
            oppID = controller.getId();
            System.debug('OppId : '+oppID);
           // oppID = controller.ApexPages.currentPage().getParameters().get('Id');
            List<Opportunity> oppList=[SELECT Name, AccountId, CloseDate, Opportunity__c, Credit_Approval_Date1__c,Date_Approved__c,OppStatus__c FROM Opportunity Where Id=:oppID];             //IBA-4979 AMAN
            
            Integer num=[SELECT count() FROM Opportunity Where AccountId=:oppList[0].AccountId AND closedate=:oppList[0].CloseDate AND Opportunity__c=:oppList[0].Opportunity__c And Name Like :('%' + oppList[0].Name + '%')];
            If(num>1){
                showMessage = System.Label.Duplicate_Message;
            }
            Integer gap = (oppList[0].Credit_Approval_Date1__c != NULL) ? (oppList[0].Credit_Approval_Date1__c).daysBetween(Date.today()) - 730 : 0;//IBA-6220
            If(oppList[0].Credit_Approval_Date1__c!=NULL && oppList[0].Credit_Approval_Date1__c<Date.Today() && gap > 0){
                showMessage1 = System.Label.Credit_Approval_Date_Message+' '+gap+' '+System.Label.Credit_Approval_Date_Message2;
            }            
            if(oppList[0].OppStatus__c == 'Open' && oppList[0].Date_Approved__c != null){                             //IBA-4979 AMAN STARTS
                Integer daysSinceApproval = (oppList[0].Date_Approved__c).daysbetween(Date.today()) ;
                if(daysSinceApproval <= 180 && daysSinceApproval >=0){
                    daysSinceApproval = 0;
                    MessageInGreen = System.Label.Credit_Date_Approved + ' ' + daysSinceApproval + ' ' + System.Label.Credit_Approval_Date_Message2;
                }
                else if(daysSinceApproval > 180){ 
                    daysSinceApproval = daysSinceApproval - 180;
                    MessageInRed = System.Label.Credit_Date_Approved + ' ' + daysSinceApproval + ' ' + System.Label.Credit_Approval_Date_Message2;
                     }
                }                                                                                                      //IBA-4979 AMAN ENDS
        }
        
        catch(Exception e){
            System.debug('errMessage' + ': ' + e.getMessage());
        }
    }
}