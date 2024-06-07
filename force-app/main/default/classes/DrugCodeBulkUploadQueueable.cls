/**********************************************************************
Name:  DrugCodeBulkUploadQueueable
Copyright Â© 2023
======================================================
======================================================
Purpose: Handler Bulk Drugs from PDP Page 
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Sourav Das               10/8/2023        INITIAL DEVELOPMENT  Handling Bulk upload Drug
***********************************************************************/
public class DrugCodeBulkUploadQueueable implements Queueable{ //IBA-3841 - Sourav
    public List<Map<String,Object>> cartMachineDatafromCSV = new List<Map<String,Object>>();
    public String cartId;
    
    public DrugCodeBulkUploadQueueable(List<Map<String,Object>> cartMachineDatafromCSV,
                                      String cartId){
        this.cartMachineDatafromCSV = cartMachineDatafromCSV;
        this.cartId = cartId;
    }
    
    public void execute(QueueableContext context) {
        Map<String,object> attributeDataMap = cartMachineDatafromCSV[cartMachineDatafromCSV.size()-1];
        
        String prodSKU = (String)attributeDataMap.get('SKU');
        List<ccrz__E_CartItem__c> cartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                  ccrz__Product__r.ccrz__SKU__c From ccrz__E_CartItem__c Where ccrz__Cart__c =:cartId 
                                                  AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = :prodSKU];        
        if(cartItemList.size() >0){
            //create minor items
            String majorItemstatus = OmnicellProductDetailController.createMinorCartItem(prodSKU,cartItemList[0],attributeDataMap);
        }
        else{
            //create major item and then create minor items
            String majorId = OmnicellProductDetailController.createMajorCartItem(cartId,attributeDataMap);
            if(majorId != 'failed'){
                List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,ccrz__Product__r.ccrz__SKU__c
                                                             From ccrz__E_CartItem__c Where ccrz__Cart__c =:cartId 
                                                             AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = :prodSKU];
                String minorItemstatus = OmnicellProductDetailController.createMinorCartItem(prodSKU,newcartItemList[0],attributeDataMap);
            }            
        }
        cartMachineDatafromCSV.remove(cartMachineDatafromCSV.size()-1);
        if(cartMachineDatafromCSV.size()>0){
            system.enqueueJob(new DrugCodeBulkUploadQueueable(cartMachineDatafromCSV,cartId));
        }
        else{
            //Send email to user that cart is loaded
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> currUserEmail = new List<String>{UserInfo.getUserEmail()};
            Apex_Email_Data__c emaildata = Apex_Email_Data__c.getInstance('DrugCodeBulkUpload');
            email.setReplyTo('no-reply@omnicell.com');
            email.setSubject(emaildata.Subject__c);
            email.setUseSignature(false);
            email.setBccSender(false);
            email.setSaveAsActivity(false);
            email.setPlainTextBody('Hello '+UserInfo.getFirstName()+',\n\n '+emaildata.Body__c);
            email.setToAddresses(currUserEmail);
            if(emaildata.CC__c != '' && emaildata.CC__c != null ){
                email.setCcAddresses(emaildata.CC__c.split('[,;]'));
            }
            if(!Test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }            
        }
    }
}