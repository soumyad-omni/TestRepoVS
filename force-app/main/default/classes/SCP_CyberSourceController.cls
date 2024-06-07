/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-30-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class SCP_CyberSourceController{
	public String fileName {get;set;} // SCP-769
    public Blob fileBody {get;set;} // SCP-769
 @RemoteAction
    global static ccrz.cc_RemoteActionResult getBillingAddressContactList(ccrz.cc_RemoteActionContext ctx, String newBillId){
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
         String cartId = ccrz.cc_CallContext.currCartId; 
        try{
            ccrz__E_Cart__c cartObj= [select Id,ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__LastName__c,ccrz__BillTo__r.ccrz__CompanyName__c,ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__City__c,ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__BillTo__r.ccrz__PostalCode__c,ccrz__BillTo__r.ccrz__CountryISOCode__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
            ccRemoteActionResult.success = true;
            if(newBillId != Null && newBillId != ''){
                ccrz__E_ContactAddr__c newBillAdd = [Select Id,ccrz__FirstName__c,ccrz__LastName__c,ccrz__CompanyName__c,ccrz__AddressFirstline__c,ccrz__City__c,ccrz__StateISOCode__c,ccrz__PostalCode__c,ccrz__CountryISOCode__c from ccrz__E_ContactAddr__c Where id =:newBillId Limit 1];
            	outputMap.put('newBill',newBillAdd);
            }
            else{
            	outputMap.put('cartObjJSON',cartObj); 
            }
        }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }



    @RemoteAction
    global static ccrz.cc_RemoteActionResult getBillingAddressList(ccrz.cc_RemoteActionContext ctx){
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
         String cartId = ccrz.cc_CallContext.currCartId; 
         List<SCP_CyberSourceController.wrapperAddress> conList = new List<SCP_CyberSourceController.wrapperAddress>();
        try{
            ccrz__E_Cart__c cartObj= [select Id,ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__LastName__c,ccrz__BillTo__r.ccrz__CompanyName__c,ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__City__c,ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__BillTo__r.ccrz__PostalCode__c,ccrz__BillTo__r.ccrz__CountryISOCode__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
            ccRemoteActionResult.success = true; 
            SCP_CyberSourceController.wrapperAddress con = new SCP_CyberSourceController.wrapperAddress();
            con.name = cartObj.name;
            conList.add(con);
            ccrz__E_ContactAddr__c conObj = [Select Name from ccrz__E_ContactAddr__c Limit 1];
            SCP_CyberSourceController.wrapperAddress conAdd = new SCP_CyberSourceController.wrapperAddress();
            conAdd.name = conObj.Name;
            conList.add(conAdd);
            outputMap.put('cartObjJSON',conList); 
        }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }

    public class wrapperAddress{
    public String name;
    }
	// SCP-769 start 
    @RemoteAction
    global static ccrz.cc_RemoteActionResult doUploadAttachment(ccrz.cc_RemoteActionContext ctx, String attachmentBody, String attachmentName, String attachmentId) {
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId;
        ccRemoteActionResult.success = true;
        if(cartId != null) {
			list<ccrz__E_Cart__c> cartObj= [select Id,Attachment_id__c,ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__LastName__c,ccrz__BillTo__r.ccrz__CompanyName__c,ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__City__c,ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__BillTo__r.ccrz__PostalCode__c,ccrz__BillTo__r.ccrz__CountryISOCode__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
            ccrz__E_Cart__c acct = cartObj[0];
            list<Attachment> oldatt = [SELECT Id FROM Attachment WHERE parentId =: acct.id];
            if(oldatt.size() > 0){
                delete oldatt;
            }
            if(acct != null) {
                if(attachmentBody != null) {
                    Attachment att = new Attachment();
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    if(attachmentId == null) {
                        att.Name = attachmentName;
                        att.parentId = acct.Id;
                    }
                    upsert att;
                    //IBA-6018
                    list<Agreement_Tag__c> relatedTag = [select Parent_Id__c, Tag__c from Agreement_Tag__c where Parent_Id__c =:att.id];
                    if(relatedTag.size()==0){
                        Agreement_Tag__c tag = new Agreement_Tag__c(Parent_Id__c = att.id, Tag__c = 'PO');
                        insert tag;
                    }
                    cartObj[0].Attachment_id__c = att.id;
                    update cartObj[0];
                    return ccRemoteActionResult ;
                } else {
                    return ccRemoteActionResult ;
                }
            } else {
                return ccRemoteActionResult ;
            }
        } else {
            return ccRemoteActionResult ;
        }
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult dAttachment(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId;
        ccRemoteActionResult.success = true;
        if(cartId != null) {
			list<ccrz__E_Cart__c> cartObj= [select Id,Attachment_id__c,ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__LastName__c,ccrz__BillTo__r.ccrz__CompanyName__c,ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__City__c,ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__BillTo__r.ccrz__PostalCode__c,ccrz__BillTo__r.ccrz__CountryISOCode__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
            ccrz__E_Cart__c acct = cartObj[0];
            list<Attachment> oldatt = [SELECT Id FROM Attachment WHERE parentId =: acct.id];
            if(oldatt.size() > 0){
                delete oldatt;
                cartObj[0].Attachment_id__c = '';
                update cartObj[0];
            }
            return ccRemoteActionResult ;
        } else {
            return ccRemoteActionResult ;
        }
        
    }
    // SCP-769 end
    
}