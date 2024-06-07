public class SFToC4CRelationshipRequest {
    public BusinessPartnerRelationshipSUITEBulkReplicateRequest BusinessPartnerRelationshipSUITEBulkReplicateRequest;
    public class BusinessPartnerRelationshipSUITEBulkReplicateRequest{
        public MessageHeader MessageHeader;
        public BusinessPartnerRelationshipSUITEReplicateRequestMessage BusinessPartnerRelationshipSUITEReplicateRequestMessage;
    }
    public class BusinessPartnerRelationshipSUITEReplicateRequestMessage{
        public MessageHeader MessageHeader;
        public List<BusinessPartnerRelationship> BusinessPartnerRelationship;
    }
    
    public class ContactPerson{
        public Decimal BusinessPartnerFunctionTypeCode;
        public String BusinessPartnerFunctionalAreaCode;
    }
    public class MessageHeader{
        public String ID;
        public String UUID;
        public String CreationDateTime;
        public SenderParty SenderParty;
        public RecipientParty RecipientParty;
    }
    
    public class RecipientParty{
        public String InternalID;
    }
    
    public class SenderParty{
        public String InternalID;
    }
    public class BusinessPartnerRelationship{
        public String BusinessPartnerInternalID;
        public String RelationshipBusinessPartnerInternalID;
        public String SenderSequenceNumberValue;
        public String RoleCode;
        public boolean DefaultIndicator;
        public ContactPerson ContactPerson;
    }
}