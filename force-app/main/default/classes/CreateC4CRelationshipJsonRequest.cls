public class CreateC4CRelationshipJsonRequest {
    public SFToC4CRelationshipRequest createRelationshipRequestWrapper(List<Relationship__c> relations){
        DateTime dateNow = DateTime.now();
        String dateString = dateNow.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String dateUniqueFormat = dateNow.format('yyyyMMddhhmmsss');
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
        SFToC4CRelationshipRequest C4CReltionRequest = new SFToC4CRelationshipRequest();
        SFToC4CRelationshipRequest.BusinessPartnerRelationshipSUITEBulkReplicateRequest BusinessPartnerRelationshipSUITEBulkReplicateRequest = new SFToC4CRelationshipRequest.BusinessPartnerRelationshipSUITEBulkReplicateRequest();
        SFToC4CRelationshipRequest.MessageHeader MessageHeader = new SFToC4CRelationshipRequest.MessageHeader();
        String requestId = Request.getCurrent().getRequestId().toUppercase();
        MessageHeader.ID = requestId.substring(4,requestId.length());
        MessageHeader.UUID = '';
        MessageHeader.CreationDateTime = dateString;
        SFToC4CRelationshipRequest.SenderParty SenderParty= new SFToC4CRelationshipRequest.SenderParty();
        SenderParty.InternalID = c4cSettings.Sender_Party_Internal_Id__c;
        SFToC4CRelationshipRequest.RecipientParty RecipientParty= new SFToC4CRelationshipRequest.RecipientParty();
        RecipientParty.InternalID = c4cSettings.Recipient_Party_Internal_Id__c;
        MessageHeader.SenderParty = SenderParty;
        MessageHeader.RecipientParty = RecipientParty;
        BusinessPartnerRelationshipSUITEBulkReplicateRequest.MessageHeader = MessageHeader;
        SFToC4CRelationshipRequest.BusinessPartnerRelationshipSUITEReplicateRequestMessage BusinessPartnerRelationshipSUITEReplicateRequestMessage = new SFToC4CRelationshipRequest.BusinessPartnerRelationshipSUITEReplicateRequestMessage();
        SFToC4CRelationshipRequest.MessageHeader RequestMessageHeader = new SFToC4CRelationshipRequest.MessageHeader();
        RequestMessageHeader.ID = dateUniqueFormat;
		BusinessPartnerRelationshipSUITEReplicateRequestMessage.MessageHeader = RequestMessageHeader;
        List<SFToC4CRelationshipRequest.BusinessPartnerRelationship> BusinessPartnerRelationship = new List<SFToC4CRelationshipRequest.BusinessPartnerRelationship>();
            for(Relationship__c relationshipData : relations){
                SFToC4CRelationshipRequest.BusinessPartnerRelationship BusinessPartnerRelationshipData = new SFToC4CRelationshipRequest.BusinessPartnerRelationship();
                BusinessPartnerRelationshipData.BusinessPartnerInternalID = relationshipData.Primary_CSN__c;
                BusinessPartnerRelationshipData.RelationshipBusinessPartnerInternalID = relationshipData.Secondary_CSN__c;
                DateTime dateNowNew = DateTime.now();
                String dateUniqueFormatNow = dateNowNew.format('yyyyMMddhhmmsss');
                BusinessPartnerRelationshipData.SenderSequenceNumberValue = dateUniqueFormatNow;
                BusinessPartnerRelationshipData.RoleCode = GetC4CRoleCode(relationshipData.Relationship__c);  
                BusinessPartnerRelationshipData.DefaultIndicator = false;
                BusinessPartnerRelationship.add(BusinessPartnerRelationshipData);
            }
        BusinessPartnerRelationshipSUITEReplicateRequestMessage.BusinessPartnerRelationship = BusinessPartnerRelationship;
        BusinessPartnerRelationshipSUITEBulkReplicateRequest.BusinessPartnerRelationshipSUITEReplicateRequestMessage = BusinessPartnerRelationshipSUITEReplicateRequestMessage;
        C4CReltionRequest.BusinessPartnerRelationshipSUITEBulkReplicateRequest = BusinessPartnerRelationshipSUITEBulkReplicateRequest;
        return C4CReltionRequest;
    }
    public SFToC4CRelationshipRequest createContactRelationshipRequestWrapper(String accountId, String contactId){
        DateTime dateNow = DateTime.now();
        String dateString = dateNow.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String dateUniqueFormat = dateNow.format('yyyyMMddhhmmsss');
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
        SFToC4CRelationshipRequest C4CReltionRequest = new SFToC4CRelationshipRequest();
        SFToC4CRelationshipRequest.BusinessPartnerRelationshipSUITEBulkReplicateRequest BusinessPartnerRelationshipSUITEBulkReplicateRequest = new SFToC4CRelationshipRequest.BusinessPartnerRelationshipSUITEBulkReplicateRequest();
        SFToC4CRelationshipRequest.MessageHeader MessageHeader = new SFToC4CRelationshipRequest.MessageHeader();
        String requestId = Request.getCurrent().getRequestId().toUppercase();
        MessageHeader.ID = requestId.substring(4,requestId.length());
        MessageHeader.UUID = '';
        MessageHeader.CreationDateTime = dateString;
        SFToC4CRelationshipRequest.SenderParty SenderParty= new SFToC4CRelationshipRequest.SenderParty();
        SenderParty.InternalID = c4cSettings.Sender_Party_Internal_Id__c;
        SFToC4CRelationshipRequest.RecipientParty RecipientParty= new SFToC4CRelationshipRequest.RecipientParty();
        RecipientParty.InternalID = c4cSettings.Recipient_Party_Internal_Id__c;
        MessageHeader.SenderParty = SenderParty;
        MessageHeader.RecipientParty = RecipientParty;
        BusinessPartnerRelationshipSUITEBulkReplicateRequest.MessageHeader = MessageHeader;
        SFToC4CRelationshipRequest.BusinessPartnerRelationshipSUITEReplicateRequestMessage BusinessPartnerRelationshipSUITEReplicateRequestMessage = new SFToC4CRelationshipRequest.BusinessPartnerRelationshipSUITEReplicateRequestMessage();
        SFToC4CRelationshipRequest.MessageHeader RequestMessageHeader = new SFToC4CRelationshipRequest.MessageHeader();
        RequestMessageHeader.ID = dateUniqueFormat;
		BusinessPartnerRelationshipSUITEReplicateRequestMessage.MessageHeader = RequestMessageHeader;
        List<SFToC4CRelationshipRequest.BusinessPartnerRelationship> BusinessPartnerRelationship = new List<SFToC4CRelationshipRequest.BusinessPartnerRelationship>();
           // for(Relationship__c relationshipData : relations){
                SFToC4CRelationshipRequest.BusinessPartnerRelationship BusinessPartnerRelationshipData = new SFToC4CRelationshipRequest.BusinessPartnerRelationship();
                BusinessPartnerRelationshipData.BusinessPartnerInternalID = accountId;
                BusinessPartnerRelationshipData.RelationshipBusinessPartnerInternalID = contactId;
                DateTime dateNowNew = DateTime.now();
                String dateUniqueFormatNow = dateNowNew.format('yyyyMMddhhmmsss');
                BusinessPartnerRelationshipData.SenderSequenceNumberValue = dateUniqueFormatNow;
                BusinessPartnerRelationshipData.RoleCode = 'BUR001';  
                SFToC4CRelationshipRequest.ContactPerson ContactPerson=new SFToC4CRelationshipRequest.ContactPerson();
                ContactPerson.businessPartnerFunctionalAreaCode='Z12';
                ContactPerson.businessPartnerFunctionTypeCode = 28;
                BusinessPartnerRelationshipData.ContactPerson =ContactPerson;
                BusinessPartnerRelationshipData.DefaultIndicator = false;
                BusinessPartnerRelationship.add(BusinessPartnerRelationshipData);
            //}
        BusinessPartnerRelationshipSUITEReplicateRequestMessage.BusinessPartnerRelationship = BusinessPartnerRelationship;
        BusinessPartnerRelationshipSUITEBulkReplicateRequest.BusinessPartnerRelationshipSUITEReplicateRequestMessage = BusinessPartnerRelationshipSUITEReplicateRequestMessage;
        C4CReltionRequest.BusinessPartnerRelationshipSUITEBulkReplicateRequest = BusinessPartnerRelationshipSUITEBulkReplicateRequest;
        return C4CReltionRequest;
    }
    Public String GetC4CRoleCode(String relationCode){
        String c4cRelationCode = '';
        if(relationCode == 'WE'){
            c4cRelationCode = 'CRMH02';
        }else if(relationCode == 'RG'){
            c4cRelationCode = 'CRMH03';
        }else if(relationCode == 'RE'){
            c4cRelationCode = 'CRMH04';
        }else if(relationCode == 'ZG'){
            c4cRelationCode = 'ZGPO00';
        }else if(relationCode == 'ZI'){
            c4cRelationCode = 'ZIDN00';
        }else if(relationCode =='AG'){
            c4cRelationCode = 'ZCPG01';
        }
        return c4cRelationCode;
    }

}