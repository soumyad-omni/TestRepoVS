global class SAPC4CTickets_AppConnect {
/* 
 * Generated by Overcast UTC 2019-03-02 18:53:02Z.
 * Changes to this class may cause incorrect behavior and will be lost if the scenario is re-activated.
 */
    public class SAPC4CTickets_AppConnectException extends Exception {}
    
    global SAPC4CTickets_AppConnect() {
        this.ServiceRequestCollection = new list<SAPC4CTickets_AppConnect.ServiceRequestCollection>();
       // this.SRActivityReferenceCollection = new list<SAPC4CTickets_AppConnect.SRActivityReferenceCollection>();
       // this.SRBTDocRefCollection = new list<SAPC4CTickets_AppConnect.SRBTDocRefCollection>();
       // this.ServiceRequestItemCollection = new list<SAPC4CTickets_AppConnect.ServiceRequestItemCollection>();
       // this.ServiceRequestItemFulfilledCollection = new list<SAPC4CTickets_AppConnect.ServiceRequestItemFulfilledCollection>();
       // this.ServiceRequestItemRequestedCollection = new list<SAPC4CTickets_AppConnect.ServiceRequestItemRequestedCollection>();
       // this.ServiceRequestItemTextCollection = new list<SAPC4CTickets_AppConnect.ServiceRequestItemTextCollection>();
       // this.ServiceRequestServiceReferenceObjectCollection = new list<SAPC4CTickets_AppConnect.ServiceRequestServiceReferenceObjectCollection>();
        this.ServiceRequestTextCollection = new list<SAPC4CTickets_AppConnect.ServiceRequestTextCollection>();
    }

    public class ServiceRequestCollection {
        @AuraEnabled public String ActionName { get; set; }
        @AuraEnabled public String AssignedToName { get; set; }
        @AuraEnabled public String ContactName { get; set; }
        @AuraEnabled public String ID { get; set; }
        @AuraEnabled public String ProductID { get; set; }
        @AuraEnabled public String ReportedOnDate { get; set; }
        @AuraEnabled public String SerialID { get; set; }
        @AuraEnabled public String ServicePriorityCodeText { get; set; }
        @AuraEnabled public String ServiceRequestUserLifeCycleStatusCodeText { get; set; }
        @AuraEnabled public String Subject { get; set; }
        
        
        
       /* @AuraEnabled public String ActionID { get; set; }
      //  @AuraEnabled public String ActionName { get; set; }
        @AuraEnabled public String ApprovalStatusCode { get; set; }
        @AuraEnabled public String ApprovalStatusCodeText { get; set; }
        @AuraEnabled public String AssignedTo { get; set; }
       // @AuraEnabled public String AssignedToName { get; set; }
        @AuraEnabled public String AssignedToUUID { get; set; }
        @AuraEnabled public String ChangedBy { get; set; }
        @AuraEnabled public String ChangedByID { get; set; }
        @AuraEnabled public String CityName { get; set; }
        @AuraEnabled public String ContactID { get; set; }
     //   @AuraEnabled public String ContactName { get; set; }
        @AuraEnabled public String ContactUUID { get; set; }
        @AuraEnabled public String ContractID { get; set; }
        @AuraEnabled public String ContractName { get; set; }
        @AuraEnabled public String ContractUUID { get; set; }
        @AuraEnabled public String CountryCode { get; set; }
        @AuraEnabled public String CountryCodeText { get; set; }
        @AuraEnabled public String CreatedBy { get; set; }
        @AuraEnabled public String CreatedByID { get; set; }
        @AuraEnabled public Datetime CreationDate { get; set; }
        @AuraEnabled public String Customer { get; set; }
        @AuraEnabled public String CustomerComplaintCodeID { get; set; }
        @AuraEnabled public String CustomerComplaintCodeName { get; set; }
        @AuraEnabled public String CustomerID { get; set; }
        @AuraEnabled public String CustomerUUID { get; set; }
        @AuraEnabled public Boolean CustomerUpdated { get; set; }
        @AuraEnabled public String DataOriginTypeCode { get; set; }
        @AuraEnabled public String DataOriginTypeCodeText { get; set; }
        @AuraEnabled public Datetime ETag { get; set; }
        @AuraEnabled public String EscalationStatusCode { get; set; }
        @AuraEnabled public String EscalationStatusCodeText { get; set; }
        @AuraEnabled public String Fax { get; set; }
        @AuraEnabled public String HouseID { get; set; }
      //  @AuraEnabled public String ID { get; set; }
        @AuraEnabled public String InitalReviewDateCompleted { get; set; }
        @AuraEnabled public String InitialReviewDate { get; set; }
        @AuraEnabled public String InstallationPointID { get; set; }
        @AuraEnabled public String InstallationPointUUID { get; set; }
        @AuraEnabled public String LastAgentInteraction { get; set; }
        @AuraEnabled public String LastCustomerInteractionDate { get; set; }
        @AuraEnabled public String Mobile { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String Phone { get; set; }
        @AuraEnabled public String ProcessingTypeCode { get; set; }
        @AuraEnabled public String ProcessingTypeCodeText { get; set; }
        @AuraEnabled public String ProductCategoryDescription { get; set; }
        @AuraEnabled public String ProductDescription { get; set; }
       // @AuraEnabled public String ProductID { get; set; }
        @AuraEnabled public String RegionCode { get; set; }
        @AuraEnabled public String RegionCodeText { get; set; }
       // @AuraEnabled public String ReportedOnDate { get; set; }
        @AuraEnabled public String ReporterEmail { get; set; }
        @AuraEnabled public String RequestFinishedAtDateTime { get; set; }
        @AuraEnabled public String RequestFullfilmentEndDateTime { get; set; }
        @AuraEnabled public String RequestFullfilmentStartDateTime { get; set; }
        @AuraEnabled public String RequestTotalProcessingDuration { get; set; }
        @AuraEnabled public String ResolutionCodeID { get; set; }
        @AuraEnabled public String ResolutionCodeName { get; set; }
        @AuraEnabled public String ResolvedOnDateTime { get; set; }
        @AuraEnabled public String ResponseByProcessorDueDateTime { get; set; }
        @AuraEnabled public String ResponseByProcessorReferenceDateTime { get; set; }
       // @AuraEnabled public String SerialID { get; set; }
        @AuraEnabled public String ServiceCodeID { get; set; }
        @AuraEnabled public String ServiceCodeName { get; set; }
        @AuraEnabled public String ServicePriorityCode { get; set; }
      //  @AuraEnabled public String ServicePriorityCodeText { get; set; }
        @AuraEnabled public String ServiceRequestLifeCycleStatusCode { get; set; }
        @AuraEnabled public String ServiceRequestLifeCycleStatusCodeText { get; set; }
        @AuraEnabled public String ServiceRequestUserLifeCycleStatusCode { get; set; }
      //  @AuraEnabled public String ServiceRequestUserLifeCycleStatusCodeText { get; set; }
        @AuraEnabled public String ServiceTechnicianID { get; set; }
        @AuraEnabled public String ServiceTechnicianName { get; set; }
        @AuraEnabled public String ServiceTechnicianUUID { get; set; }
        @AuraEnabled public String SiebelTicketURL { get; set; }
        @AuraEnabled public String StreetPostalCode { get; set; }
        @AuraEnabled public String StreetPostalCodeText { get; set; }
        @AuraEnabled public String SubAreaID { get; set; }
        @AuraEnabled public String SubAreaName { get; set; }
        //@AuraEnabled public String Subject { get; set; }
        @AuraEnabled public String UUID { get; set; }
        @AuraEnabled public String accountSpecialNotes { get; set; }
        @AuraEnabled public String alternateCallbackNumber { get; set; }
        @AuraEnabled public String contactNumber { get; set; }
        @AuraEnabled public String externalReferenceID { get; set; }
        @AuraEnabled public Datetime lastModifiedDate { get; set; }
        @AuraEnabled public Datetime onsiteDueDate { get; set; }
        @AuraEnabled public String onsiteDueTime { get; set; } //Time
        @AuraEnabled public String resolution { get; set; }
        @AuraEnabled public String specialCustomerNotes { get; set; }
        @AuraEnabled public Boolean thirdParty { get; set; }
        @AuraEnabled public Boolean virtual_x { get; set; }
        @AuraEnabled public String virtualSR { get; set; }*/

        public ServiceRequestCollection() {}

      //  public ServiceRequestCollection(String pActionID, String pActionName, String pApprovalStatusCode, String pApprovalStatusCodeText, String pAssignedTo, String pAssignedToName, String pAssignedToUUID, String pChangedBy, String pChangedByID, String pCityName, String pContactID, String pContactName, String pContactUUID, String pContractID, String pContractName, String pContractUUID, String pCountryCode, String pCountryCodeText, String pCreatedBy, String pCreatedByID, Datetime pCreationDate, String pCustomer, String pCustomerComplaintCodeID, String pCustomerComplaintCodeName, String pCustomerID, String pCustomerUUID, Boolean pCustomerUpdated, String pDataOriginTypeCode, String pDataOriginTypeCodeText, Datetime pETag, String pEscalationStatusCode, String pEscalationStatusCodeText) {
            public ServiceRequestCollection(String pActionName, String pAssignedToName, String pContactName) {
                this.ActionName = pActionName;
                this.AssignedToName = pAssignedToName;
                this.ContactName = pContactName;
            /*this.ActionID = pActionID;
            this.ActionName = pActionName;
            this.ApprovalStatusCode = pApprovalStatusCode;
            this.ApprovalStatusCodeText = pApprovalStatusCodeText;
            this.AssignedTo = pAssignedTo;
            this.AssignedToName = pAssignedToName;
            this.AssignedToUUID = pAssignedToUUID;
            this.ChangedBy = pChangedBy;
            this.ChangedByID = pChangedByID;
            this.CityName = pCityName;
            this.ContactID = pContactID;
            this.ContactName = pContactName;
            this.ContactUUID = pContactUUID;
            this.ContractID = pContractID;
            this.ContractName = pContractName;
            this.ContractUUID = pContractUUID;
            this.CountryCode = pCountryCode;
            this.CountryCodeText = pCountryCodeText;
            this.CreatedBy = pCreatedBy;
            this.CreatedByID = pCreatedByID;
            this.CreationDate = pCreationDate;
            this.Customer = pCustomer;
            this.CustomerComplaintCodeID = pCustomerComplaintCodeID;
            this.CustomerComplaintCodeName = pCustomerComplaintCodeName;
            this.CustomerID = pCustomerID;
            this.CustomerUUID = pCustomerUUID;
            this.CustomerUpdated = pCustomerUpdated;
            this.DataOriginTypeCode = pDataOriginTypeCode;
            this.DataOriginTypeCodeText = pDataOriginTypeCodeText;
            this.ETag = pETag;
            this.EscalationStatusCode = pEscalationStatusCode;
            this.EscalationStatusCodeText = pEscalationStatusCodeText;*/
        }
    }

  /*  public class SRActivityReferenceCollection {
        @AuraEnabled public String ActivityID { get; set; }
        @AuraEnabled public Datetime ActivityLastChangeDate { get; set; }
        @AuraEnabled public String ActivityTypeCode { get; set; }
        @AuraEnabled public String ActivityTypeCodeText { get; set; }
        @AuraEnabled public String ActivityUUID { get; set; }
        @AuraEnabled public Datetime ETag { get; set; }
        @AuraEnabled public String LifeCycleStatusCode { get; set; }
        @AuraEnabled public String LifeCycleStatusCodeText { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String ParentObjectID { get; set; }
        @AuraEnabled public String ServiceRequestID { get; set; }
        @AuraEnabled public String SubjectName { get; set; }

        public SRActivityReferenceCollection() {}

        public SRActivityReferenceCollection(String pActivityID, Datetime pActivityLastChangeDate, String pActivityTypeCode, String pActivityTypeCodeText, String pActivityUUID, Datetime pETag, String pLifeCycleStatusCode, String pLifeCycleStatusCodeText, String pObjectID, String pParentObjectID, String pServiceRequestID, String pSubjectName) {
            this.ActivityID = pActivityID;
            this.ActivityLastChangeDate = pActivityLastChangeDate;
            this.ActivityTypeCode = pActivityTypeCode;
            this.ActivityTypeCodeText = pActivityTypeCodeText;
            this.ActivityUUID = pActivityUUID;
            this.ETag = pETag;
            this.LifeCycleStatusCode = pLifeCycleStatusCode;
            this.LifeCycleStatusCodeText = pLifeCycleStatusCodeText;
            this.ObjectID = pObjectID;
            this.ParentObjectID = pParentObjectID;
            this.ServiceRequestID = pServiceRequestID;
            this.SubjectName = pSubjectName;
        }
    }

    public class SRBTDocRefCollection {
        @AuraEnabled public String ActivityID { get; set; }
        @AuraEnabled public Datetime ActivityLastChangeDate { get; set; }
        @AuraEnabled public String ActivityTypeCode { get; set; }
        @AuraEnabled public String ActivityTypeCodeText { get; set; }
        @AuraEnabled public String ActivityUUID { get; set; }
        @AuraEnabled public Datetime ETag { get; set; }
        @AuraEnabled public String LifeCycleStatusCode { get; set; }
        @AuraEnabled public String LifeCycleStatusCodeText { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String ParentObjectID { get; set; }
        @AuraEnabled public String ServiceRequestID { get; set; }
        @AuraEnabled public String SubjectName { get; set; }

        public SRBTDocRefCollection() {}

        public SRBTDocRefCollection(String pActivityID, Datetime pActivityLastChangeDate, String pActivityTypeCode, String pActivityTypeCodeText, String pActivityUUID, Datetime pETag, String pLifeCycleStatusCode, String pLifeCycleStatusCodeText, String pObjectID, String pParentObjectID, String pServiceRequestID, String pSubjectName) {
            this.ActivityID = pActivityID;
            this.ActivityLastChangeDate = pActivityLastChangeDate;
            this.ActivityTypeCode = pActivityTypeCode;
            this.ActivityTypeCodeText = pActivityTypeCodeText;
            this.ActivityUUID = pActivityUUID;
            this.ETag = pETag;
            this.LifeCycleStatusCode = pLifeCycleStatusCode;
            this.LifeCycleStatusCodeText = pLifeCycleStatusCodeText;
            this.ObjectID = pObjectID;
            this.ParentObjectID = pParentObjectID;
            this.ServiceRequestID = pServiceRequestID;
            this.SubjectName = pSubjectName;
        }
    }

    public class ServiceRequestItemCollection {
        @AuraEnabled public Datetime CreationDateTime { get; set; }
        @AuraEnabled public String Description { get; set; }
        @AuraEnabled public String InvoicingMethodCode { get; set; }
        @AuraEnabled public String InvoicingMethodCodeText { get; set; }
        @AuraEnabled public Datetime LastChangeDateTime { get; set; }
        @AuraEnabled public String LineNo { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String ParentObjectID { get; set; }
        @AuraEnabled public String ProcessingTypeCode { get; set; }
        @AuraEnabled public String ProcessingTypeCodeText { get; set; }
        @AuraEnabled public String ProductID { get; set; }
        @AuraEnabled public String QuantityMeasureUnitCode { get; set; }
        @AuraEnabled public String QuantityMeasureUnitCodeText { get; set; }
        @AuraEnabled public String ServiceRequestID { get; set; }
        @AuraEnabled public String ServiceRequestUUID { get; set; }
        @AuraEnabled public String WorkProgressCode { get; set; }
        @AuraEnabled public String WorkProgressCodeText { get; set; }
        @AuraEnabled public String accountSpecialNotes { get; set; }
        @AuraEnabled public String hlLine { get; set; }
        @AuraEnabled public Boolean nonFRU { get; set; }
        @AuraEnabled public String serialNumber { get; set; }

        public ServiceRequestItemCollection() {}

        public ServiceRequestItemCollection(Datetime pCreationDateTime, String pDescription, String pInvoicingMethodCode, String pInvoicingMethodCodeText, Datetime pLastChangeDateTime, String pLineNo, String pObjectID, String pParentObjectID, String pProcessingTypeCode, String pProcessingTypeCodeText, String pProductID, String pQuantityMeasureUnitCode, String pQuantityMeasureUnitCodeText, String pServiceRequestID, String pServiceRequestUUID, String pWorkProgressCode, String pWorkProgressCodeText, String paccountSpecialNotes, String phlLine, Boolean pnonFRU, String pserialNumber) {
            this.CreationDateTime = pCreationDateTime;
            this.Description = pDescription;
            this.InvoicingMethodCode = pInvoicingMethodCode;
            this.InvoicingMethodCodeText = pInvoicingMethodCodeText;
            this.LastChangeDateTime = pLastChangeDateTime;
            this.LineNo = pLineNo;
            this.ObjectID = pObjectID;
            this.ParentObjectID = pParentObjectID;
            this.ProcessingTypeCode = pProcessingTypeCode;
            this.ProcessingTypeCodeText = pProcessingTypeCodeText;
            this.ProductID = pProductID;
            this.QuantityMeasureUnitCode = pQuantityMeasureUnitCode;
            this.QuantityMeasureUnitCodeText = pQuantityMeasureUnitCodeText;
            this.ServiceRequestID = pServiceRequestID;
            this.ServiceRequestUUID = pServiceRequestUUID;
            this.WorkProgressCode = pWorkProgressCode;
            this.WorkProgressCodeText = pWorkProgressCodeText;
            this.accountSpecialNotes = paccountSpecialNotes;
            this.hlLine = phlLine;
            this.nonFRU = pnonFRU;
            this.serialNumber = pserialNumber;
        }
    }

    public class ServiceRequestItemFulfilledCollection {
        @AuraEnabled public Datetime ETag { get; set; }
        @AuraEnabled public Datetime EndDateTime { get; set; }
        @AuraEnabled public String ID { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String ParentObjectID { get; set; }
        @AuraEnabled public Decimal Quantity { get; set; }
        @AuraEnabled public Datetime StartDateTime { get; set; }

        public ServiceRequestItemFulfilledCollection() {}

        public ServiceRequestItemFulfilledCollection(Datetime pETag, Datetime pEndDateTime, String pID, String pObjectID, String pParentObjectID, Decimal pQuantity, Datetime pStartDateTime) {
            this.ETag = pETag;
            this.EndDateTime = pEndDateTime;
            this.ID = pID;
            this.ObjectID = pObjectID;
            this.ParentObjectID = pParentObjectID;
            this.Quantity = pQuantity;
            this.StartDateTime = pStartDateTime;
        }
    }

    public class ServiceRequestItemRequestedCollection {
        @AuraEnabled public Datetime ETag { get; set; }
        @AuraEnabled public Datetime EndDateTime { get; set; }
        @AuraEnabled public String ID { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String ParentObjectID { get; set; }
        @AuraEnabled public Decimal Quantity { get; set; }
        @AuraEnabled public Datetime StartDateTime { get; set; }

        public ServiceRequestItemRequestedCollection() {}

        public ServiceRequestItemRequestedCollection(Datetime pETag, Datetime pEndDateTime, String pID, String pObjectID, String pParentObjectID, Decimal pQuantity, Datetime pStartDateTime) {
            this.ETag = pETag;
            this.EndDateTime = pEndDateTime;
            this.ID = pID;
            this.ObjectID = pObjectID;
            this.ParentObjectID = pParentObjectID;
            this.Quantity = pQuantity;
            this.StartDateTime = pStartDateTime;
        }
    }

    public class ServiceRequestItemTextCollection {
        @AuraEnabled public String AuthorName { get; set; }
        @AuraEnabled public String AuthorUUID { get; set; }
        @AuraEnabled public String CreatedBy { get; set; }
        @AuraEnabled public Datetime CreatedOn { get; set; }
        @AuraEnabled public Datetime ETag { get; set; }
        @AuraEnabled public String LanguageCode { get; set; }
        @AuraEnabled public String LanguageCodeText { get; set; }
        @AuraEnabled public String LastUpdatedBy { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String ParentObjectID { get; set; }
        @AuraEnabled public String Text { get; set; }
        @AuraEnabled public String TypeCode { get; set; }
        @AuraEnabled public String TypeCodeText { get; set; }
        @AuraEnabled public Datetime UpdatedOn { get; set; }

        public ServiceRequestItemTextCollection() {}

        public ServiceRequestItemTextCollection(String pAuthorName, String pAuthorUUID, String pCreatedBy, Datetime pCreatedOn, Datetime pETag, String pLanguageCode, String pLanguageCodeText, String pLastUpdatedBy, String pObjectID, String pParentObjectID, String pText, String pTypeCode, String pTypeCodeText, Datetime pUpdatedOn) {
            this.AuthorName = pAuthorName;
            this.AuthorUUID = pAuthorUUID;
            this.CreatedBy = pCreatedBy;
            this.CreatedOn = pCreatedOn;
            this.ETag = pETag;
            this.LanguageCode = pLanguageCode;
            this.LanguageCodeText = pLanguageCodeText;
            this.LastUpdatedBy = pLastUpdatedBy;
            this.ObjectID = pObjectID;
            this.ParentObjectID = pParentObjectID;
            this.Text = pText;
            this.TypeCode = pTypeCode;
            this.TypeCodeText = pTypeCodeText;
            this.UpdatedOn = pUpdatedOn;
        }
    }

    public class ServiceRequestServiceReferenceObjectCollection {
        @AuraEnabled public Datetime ETag { get; set; }
        @AuraEnabled public String InstallationPointID { get; set; }
        @AuraEnabled public String InstallationPointUUID { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String ParentObjectID { get; set; }

        public ServiceRequestServiceReferenceObjectCollection() {}

        public ServiceRequestServiceReferenceObjectCollection(Datetime pETag, String pInstallationPointID, String pInstallationPointUUID, String pObjectID, String pParentObjectID) {
            this.ETag = pETag;
            this.InstallationPointID = pInstallationPointID;
            this.InstallationPointUUID = pInstallationPointUUID;
            this.ObjectID = pObjectID;
            this.ParentObjectID = pParentObjectID;
        }
    }*/

    public class ServiceRequestTextCollection {
        @AuraEnabled public String AuthorName { get; set; }
        @AuraEnabled public String AuthorUUID { get; set; }
        @AuraEnabled public String CreatedBy { get; set; }
        @AuraEnabled public Datetime CreatedOn { get; set; }
        @AuraEnabled public Datetime ETag { get; set; }
        @AuraEnabled public String LanguageCode { get; set; }
        @AuraEnabled public String LanguageCodeText { get; set; }
        @AuraEnabled public String LastUpdatedBy { get; set; }
        @AuraEnabled public String ObjectID { get; set; }
        @AuraEnabled public String ParentObjectID { get; set; }
        @AuraEnabled public String Text { get; set; }
        @AuraEnabled public String TypeCode { get; set; }
        @AuraEnabled public String TypeCodeText { get; set; }
        @AuraEnabled public Datetime UpdatedOn { get; set; }

        public ServiceRequestTextCollection() {}

        public ServiceRequestTextCollection(String pAuthorName, String pAuthorUUID, String pCreatedBy, Datetime pCreatedOn, Datetime pETag, String pLanguageCode, String pLanguageCodeText, String pLastUpdatedBy, String pObjectID, String pParentObjectID, String pText, String pTypeCode, String pTypeCodeText, Datetime pUpdatedOn) {
            this.AuthorName = pAuthorName;
            this.AuthorUUID = pAuthorUUID;
            this.CreatedBy = pCreatedBy;
            this.CreatedOn = pCreatedOn;
            this.ETag = pETag;
            this.LanguageCode = pLanguageCode;
            this.LanguageCodeText = pLanguageCodeText;
            this.LastUpdatedBy = pLastUpdatedBy;
            this.ObjectID = pObjectID;
            this.ParentObjectID = pParentObjectID;
            this.Text = pText;
            this.TypeCode = pTypeCode;
            this.TypeCodeText = pTypeCodeText;
            this.UpdatedOn = pUpdatedOn;
        }
    }

    @AuraEnabled public list<SAPC4CTickets_AppConnect.ServiceRequestCollection> ServiceRequestCollection { get; set; }
    //@AuraEnabled public list<SAPC4CTickets_AppConnect.SRActivityReferenceCollection> SRActivityReferenceCollection { get; set; }
    //@AuraEnabled public list<SAPC4CTickets_AppConnect.SRBTDocRefCollection> SRBTDocRefCollection { get; set; }
    //@AuraEnabled public list<SAPC4CTickets_AppConnect.ServiceRequestItemCollection> ServiceRequestItemCollection { get; set; }
    //@AuraEnabled public list<SAPC4CTickets_AppConnect.ServiceRequestItemFulfilledCollection> ServiceRequestItemFulfilledCollection { get; set; }
    //@AuraEnabled public list<SAPC4CTickets_AppConnect.ServiceRequestItemRequestedCollection> ServiceRequestItemRequestedCollection { get; set; }
    //@AuraEnabled public list<SAPC4CTickets_AppConnect.ServiceRequestItemTextCollection> ServiceRequestItemTextCollection { get; set; }
    //@AuraEnabled public list<SAPC4CTickets_AppConnect.ServiceRequestServiceReferenceObjectCollection> ServiceRequestServiceReferenceObjectCollection { get; set; }
    @AuraEnabled public list<SAPC4CTickets_AppConnect.ServiceRequestTextCollection> ServiceRequestTextCollection { get; set; }

    public string inputSetName { get; set; }

    public string getBackendMessage() {
        return this.backendMessage;
    }

    global string serialize() {
        if (dynamicBody != null) {
            return JSON.serialize(dynamicBody, true);
        }
        return JSON.serialize(this, true);
    }
    
    public static SAPC4CTickets_AppConnect deserialize(string responsedata) {
        System.debug('response123.......' +responsedata);
        map<string, string> m = getOutputData(responsedata);
        string outputData = m.get('output');
        string backendMessage = m.get('backendMessage');
        if (outputData == null) {
            return new SAPC4CTickets_AppConnect();
        }
        if(outputData.contains('0000-00-00')){
            outputData = outputData.replace('0000-00-00','2020-03-03');
        }
        SAPC4CTickets_AppConnect obj = (SAPC4CTickets_AppConnect)JSON.deserialize(outputData, SAPC4CTickets_AppConnect.class);
        obj.outputData = outputData;
        obj.backendMessage = backendMessage;
        return obj;
    }

    private static map<string, string> getOutputData(string responseData) {
        if (string.isblank(responsedata)) {
            throw new SAPC4CTickets_AppConnectException('Response null for SAPC4CTickets_AppConnect request.');
        }

        map<string, string> m = new map<string, string>();

        JSONParser jresponse = JSON.createParser(responsedata);
        jresponse.nextValue();

        boolean hasOutput = false;
        while (jresponse.nextValue() != JSONToken.END_OBJECT && jresponse.getCurrentToken() != null) {
            if (jresponse.getCurrentName() == 'output') {
                jresponse.skipChildren();
                hasOutput = true;
                continue;
            }
            if (jresponse.getCurrentName() == 'backendMessage') {
                m.put('backendMessage', (string)jresponse.readValueAs(string.class));
                continue;
            }
            if (jresponse.getCurrentName() == 'error') {
                string[] errors = (string[])jresponse.readValueAs(list<string>.class);
                throw new SAPC4CTickets_AppConnectException(string.join(errors, ';'));
            }
        }
        if (!hasOutput) {
            throw new SAPC4CTickets_AppConnectException('Malformed response for SAPC4CTickets_AppConnect request.');
        }
        integer start = responsedata.indexOf(':') + 1;
        integer lastIndex = m.get('backendMessage') == null
            ? responsedata.length() - 2
            : responsedata.lastIndexOf('backendMessage');
        integer finish = responsedata.lastIndexOf('}', lastIndex) + 1;
        m.put('output', responseData.substring(start, finish));
        return m;
    }


    public transient string testResponse;
    private transient map<string, object> dynamicBody;
    private transient string outputData;
    //private transient map<string, overcast.TypeInfo> metadata;
    private transient string backendMessage;

    global void set(string typeName, object records) {
        if (typeName == '@testResponse') {
            dynamicBody = (map<string, object>)records;
            return;
        }
        if (dynamicBody == null) {
            dynamicBody = new map<string, object>();            
        }
        
        dynamicBody.put(typeName, records);
    }
    
    global object get(string typeName) {
        if (dynamicBody == null && outputData != null) {           
            dynamicBody = (map<string, object>)JSON.deserializeUntyped(outputData);
        }
        if (dynamicBody == null) { 
            return null;
        }
        return dynamicBody.get(typeName);
    }
    
    

    global string getTopTypeName() {
        return 'ServiceRequestCollection';
    }

    
}