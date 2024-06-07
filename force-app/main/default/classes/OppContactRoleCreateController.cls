public with sharing class OppContactRoleCreateController {
    
    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getContacts(Id oppId) {
        Opportunity opp = [Select Id,AccountId From Opportunity Where Id =:oppId];
        List<ContactWrapper> contactsWithAccount = new List<ContactWrapper>();
        for(Contact contactRecord : [SELECT Id, Name, Phone, Email, Account.Name FROM Contact WHERE AccountId = :opp.AccountId AND SAP_Contact_GUID__c != ''  Order By Name ASC]) {
            contactsWithAccount.add(new ContactWrapper(contactRecord));
        }
        return contactsWithAccount;
    }

    @AuraEnabled
    public static SaveResultforOppCustomForm createRecords(String recordsToCreate, String primaryContactId, String oppId) {
        List<OpportunityContactRole> oppConList = new List<OpportunityContactRole>();
        List<Object> jsonDataList = (List<Object>) JSON.deserializeUntyped(recordsToCreate);
        SaveResultforOppCustomForm result = new SaveResultforOppCustomForm();
        Boolean shippingContactCheck = false;
        try {  
            for(Object obj:jsonDataList){
                Map<String,Object> obb = (Map<String,Object>)obj;
                OpportunityContactRole oppCon = new OpportunityContactRole();
                oppCon.OpportunityId = oppId;
                oppCon.Role = (String)obb.get('role');
                if(oppCon.Role == 'S-Shipping Contact'){
                    shippingContactCheck = true;
                }
                Object con = (Object)obb.get('oppcontact');
                Map<String,Object> conmap = (Map<String,Object>)con;  
                oppCon.ContactId = (String)conmap.get('contactId');
                if(oppCon.ContactId == primaryContactId && primaryContactId != null){
                    oppCon.IsPrimary = true;
                }
                oppConList.add(oppCon);
            }
            insert oppConList;
            result.message = 'Contact Role Created Successfully';
            result.success = true; 
            if(shippingContactCheck && checkProceedToQuote(oppId)){
                result.proceedToQuote = true;  
            }
            else{
                result.proceedToQuote = false;
            }
        }
        catch (Exception e) {
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                // Extract the validation rule message
                result.message = OpportunityRelatedListController.extractValidationErrorMessage(e.getMessage());
            } else {
                // Handle other exceptions if needed
                result.message = e.getMessage();
            }            
            result.success = false;
            System.debug(e.getMessage());
        }
        return result;
    }

    public class ContactWrapper {
        @AuraEnabled
        public Id contactId { get; set; }
        @AuraEnabled
        public String contactName { get; set; }
        @AuraEnabled
        public String contactPhone { get; set; }
        @AuraEnabled
        public String contactEmail { get; set; }
        @AuraEnabled
        public String accountName { get; set; }

        public ContactWrapper(Contact contactRecord) {
            this.contactId = contactRecord.Id;
            this.contactName = contactRecord.Name;
            this.contactPhone = contactRecord.Phone;
            this.contactEmail = contactRecord.Email;
            this.accountName = contactRecord.Account != null ? contactRecord.Account.Name : '';
        }
    }

    public class oppConWrapper {
        public conWrap contact { get; set; }
        public String Role { get; set; }
        public String index { get; set; }
        public Boolean isPrimary { get; set; }

        public oppConWrapper(conWrap contact, String Role, String index, Boolean isPrimary) {
            this.contact = contact;
            this.Role = Role;
            this.index = index;
            this.isPrimary = isPrimary;
        }
    }

    public class conWrap {
        public Id contactId;        
        public String contactName;        
        public String contactPhone;        
        public String contactEmail;        
        public String accountName; 
        public conWrap(Id contactId, String contactName, String contactPhone,String contactEmail, String accountName) {
            this.contactId = contactId;
            this.contactName = contactName;
            this.contactPhone = contactPhone;
            this.contactEmail = contactEmail;
            this.accountName = accountName;
        }
    }

    public static Boolean checkProceedToQuote(String oppId){
        List<Product_Line__c> allProdLine = [Select Id From Product_Line__c Where Opportunity__c =:oppId];
        if(allProdLine.size()>0){
            return true;
        }
        else {
            return false;
        }
    }
}