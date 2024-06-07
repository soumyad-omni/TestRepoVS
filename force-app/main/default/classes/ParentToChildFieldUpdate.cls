/****************************************************************************
 Name           ParentToChildFieldUpdate
 Purpose        Called from AccountTriggerHandler to update an field 'Liklihood To Convert'   


 History :
---------------------------------------------------------------------------
 Developer                  Date                Description
 -------------------------------------------------------------- -------------
 Sahid Hussain             5/12/2021           Initial Creation
 Sahid Hussain             7/12/2021           Added Future method TargetInitiativeUpdate for IBA-1911
*****************************************************************************/

public without sharing class ParentToChildFieldUpdate {
    
   /*IBA-1814 && IBA-1856 Starts*/
    public static List<Account> allChildAccount = new List<Account>();
    public static Set<Id> parentId = new Set<Id>();
    @future
    public static void AllChilAccounts(Set<Id> accId){
        parentId.addAll(accId);
        AllChilAccountsReturnVal(accId);
        AccountTriggerHandler.TriggerDisabled = true;
        Try{
            update allChildAccount;
        }catch(Exception e){
            system.debug('##The following exception has occurred: '+ e.getMessage());
        }
    }
    
    public static Set<Id> AllChilAccountsReturnVal(Set<Id> accountId){
    //Account pData = [Select Likelihood_to_Convert__c From Account Where Id IN :parentId];
    Account pData = [Select Likelihood_to_Convert__c, Customer_Success_Segment__c, Advanced_Services_Segment__c From Account Where Id IN :parentId ];
    List<Account> accListTopChild = [Select id, ParentId, Likelihood_to_Convert__c, Customer_Success_Segment__c, Advanced_Services_Segment__c From Account Where ParentId IN :accountId];
    Set<Id> accIdTopChild = new Set<Id>();
        For(Account ac :accListTopChild){
            accIdTopChild.add(ac.id);
            if(ac.Likelihood_to_Convert__c != pData.Likelihood_to_Convert__c || ac.Customer_Success_Segment__c != pData.Customer_Success_Segment__c || ac.Advanced_Services_Segment__c != pData.Advanced_Services_Segment__c){
                ac.Likelihood_to_Convert__c = pData.Likelihood_to_Convert__c;
                ac.Customer_Success_Segment__c = pData.Customer_Success_Segment__c;
                ac.Advanced_Services_Segment__c = pData.Advanced_Services_Segment__c;
                
            }
        }
    allChildAccount.addAll(accListTopChild);
    List<Account> accListTopChild2 = [Select id,ParentId,Parent.Likelihood_to_Convert__c, Likelihood_to_Convert__c, Parent.Customer_Success_Segment__c, Customer_Success_Segment__c, Parent.Advanced_Services_Segment__c, Advanced_Services_Segment__c From Account Where ParentId IN :accIdTopChild];
        if(accListTopChild2.size()>0){
            return AllChilAccountsReturnVal(accIdTopChild);
        }else 
            return null;
    }
    /*IBA-1814 && IBA-1856 Ends*/
}