public class CreateC4CJsonRequest {
    public SFToC4CAccountRequest createRequestWrapper(Id accId,String SAPECCId){
        DateTime dateNow = DateTime.now();
        String dateString = dateNow.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String dateUniqueFormat = dateNow.format('yyyyMMddhhmmsss');
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
        Account acc = [SELECT id, SAP_Account_ID__c ,SAP_Customer_Number__c,Account_Name2__c,Account_Name3__c,
                       Address_Line_2__c,LastModifiedDate,BillingCity,BillingCountryCode,BillingCountry,CreatedById,
                       CreatedDate,Email__c,Fax,Industry_US__c,Primary_Language__c,Master_Agreement__c,Name,OwnerId,
                       ParentId,Phone,PO_BOX__c,BillingPostalCode,Region__c,Account_Role__c,BillingStateCode,
                       BillingState,Account_Status__c,BillingStreet,Vendor_Credentialing__c,Website,
                       texcellency__DefHC_HospitalID__c,Top_Level_Parent_CSN_Number__c,Facility_Type__c,
                       Segment__c,Description,Partner_Type__c,Transport_Zone__c,Validation_Status__c,     //IBA-4149
                       Advanced_Services_Segment__c,texcellency__DefHC_Parent_Network_Name__c,                                         //IBA-4149
                       Account_Territory__c,Top_level_2__c,CurrencyIsoCode,C4C_Address_UUID__c, Division_Account__c, Country_Cluster__c,
                       Market_Segment__c, Suite__c, ReplacedBy__c,parent.SAP_Customer_Number__c,Definitive_Id__c, C4C_Account_Role_Code__c, C4C_Country_Cluster_Code__c        
                       FROM account where id=:accId LIMIT 1];
        //WHERE C4C_Account_ID__c = NULL AND SAP_Account_ID__c != NULL];
        List<SAP_Sales_Org__c> salesOrg = [Select id,name,Sales_Org__c,Sales_Office__c,Terms_of_Payment__c,CurrencyISOCOde,Incoterms_1__c,Incoterms_2__c from SAP_Sales_Org__c where Account__c =: accId order by createddate desc];
        SFToC4CAccountRequest reqData = new SFToC4CAccountRequest();
        reqData.Event = 'Insert';
        SFToC4CAccountRequest.BusinessPartnerSUITEBulkReplicateRequest businessReplicateRequest = new SFToC4CAccountRequest.BusinessPartnerSUITEBulkReplicateRequest();
        SFToC4CAccountRequest.MessageHeader messageHeader= new SFToC4CAccountRequest.MessageHeader();
        messageHeader.UUID = '';
        String requestId = Request.getCurrent().getRequestId().toUppercase();
        messageHeader.ID = requestId.substring(4,requestId.length());
        messageHeader.CreationDateTime = dateString;
        SFToC4CAccountRequest.SenderParty senderParty= new SFToC4CAccountRequest.SenderParty();
        senderParty.InternalID = c4cSettings.Sender_Party_Internal_Id__c;
        SFToC4CAccountRequest.RecipientParty recipientParty= new SFToC4CAccountRequest.RecipientParty();
        recipientParty.InternalID = c4cSettings.Recipient_Party_Internal_Id__c;
        messageHeader.SenderParty = senderParty;
        messageHeader.RecipientParty = recipientParty;
        businessReplicateRequest.MessageHeader = messageHeader;
        SFToC4CAccountRequest.BusinessPartnerSUITEReplicateRequestMessage businessPartnerReqMessage = new SFToC4CAccountRequest.BusinessPartnerSUITEReplicateRequestMessage();
        SFToC4CAccountRequest.MessageHeader businessPartnerMessageHeader= new SFToC4CAccountRequest.MessageHeader();
        businessPartnerMessageHeader.Id = dateUniqueFormat;
        businessPartnerReqMessage.MessageHeader = businessPartnerMessageHeader;
        SFToC4CAccountRequest.BusinessPartner businessPartner = new SFToC4CAccountRequest.BusinessPartner();
        if(acc.SAP_Customer_Number__c != null){
            businessPartner.InternalID = Decimal.valueOf(acc.SAP_Customer_Number__c);
        	businessPartner.ReceiverInternalID = Decimal.valueOf(acc.SAP_Customer_Number__c);
        }else{
            businessPartner.InternalID = Decimal.valueOf(SAPECCId);
        	businessPartner.ReceiverInternalID = Decimal.valueOf(SAPECCId);
        }
        
        businessPartner.SenderSequenceNumberValue = dateUniqueFormat;
        businessPartner.CategoryCode = 2;
        SFToC4CAccountRequest.Customer customer = new SFToC4CAccountRequest.Customer();
        SFToC4CAccountRequest.MarketingAttributes customerMarketingAttributes = new SFToC4CAccountRequest.MarketingAttributes();
        customerMarketingAttributes.CustomerGroupCode = '01';
        customerMarketingAttributes.CustomerNielsenRegionCode = '';
        customer.MarketingAttributes = customerMarketingAttributes;
        SFToC4CAccountRequest.SaleSalesAndDistributionBlocks salesAndDistributionBlocks= new SFToC4CAccountRequest.SaleSalesAndDistributionBlocks();
        salesAndDistributionBlocks.BillingBlockingReasonCode = '';
        salesAndDistributionBlocks.DeliveryBlockingReasonCode = '';
        salesAndDistributionBlocks.OrderBlockingReasonCode = '';
        customer.SaleSalesAndDistributionBlocks = salesAndDistributionBlocks;
        List<SFToC4CAccountRequest.SalesArrangement> salesArrangement = new List<SFToC4CAccountRequest.SalesArrangement>();
        if(!salesOrg.isEmpty()){
            for(SAP_Sales_Org__c salesOrgData : salesOrg){
                SFToC4CAccountRequest.SalesArrangement salesArrangementData = new SFToC4CAccountRequest.SalesArrangement();
                salesArrangementData.LifeCycleStatusCode = 1;
                salesArrangementData.DistributionChannelCode = '01';
                salesArrangementData.GroupCode='';
                salesArrangementData.CurrencyCode=acc.CurrencyIsoCode;
                SFToC4CAccountRequest.DeliveryTerms deliveryTerms = new SFToC4CAccountRequest.DeliveryTerms();
                SFToC4CAccountRequest.Incoterms incoterms = new SFToC4CAccountRequest.Incoterms();
                salesArrangementData.SalesOrganisationID = salesOrgData.Sales_Org__c;
                salesArrangementData.SalesOfficeID = salesOrgData.Sales_Office__c;
                //salesArrangementData.SalesOrganisationID = 'OM31';
                //salesArrangementData.SalesOfficeID = 'E545';
                salesArrangementData.CashDiscountTermsCode = salesOrgData.Terms_of_Payment__c;
                salesArrangementData.CurrencyCode=salesOrgData.CurrencyIsoCode;
                incoterms.ClassificationCode = salesOrgData.Incoterms_1__c;
                incoterms.TransferLocationName = salesOrgData.Incoterms_2__c;
                deliveryTerms.Incoterms = incoterms;
                salesArrangementData.DeliveryTerms = deliveryTerms;
                salesArrangement.add(salesArrangementData);
            }
        } else{
            SFToC4CAccountRequest.SalesArrangement salesArrangementData = new SFToC4CAccountRequest.SalesArrangement();
            salesArrangementData.LifeCycleStatusCode = 1;
            salesArrangementData.DistributionChannelCode = '01';
            salesArrangementData.GroupCode='';
            salesArrangementData.CurrencyCode=acc.CurrencyIsoCode;
            SFToC4CAccountRequest.DeliveryTerms deliveryTerms = new SFToC4CAccountRequest.DeliveryTerms();
            SFToC4CAccountRequest.Incoterms incoterms = new SFToC4CAccountRequest.Incoterms();
            salesArrangementData.SalesOrganisationID = '';
            salesArrangementData.SalesOfficeID = '';
            salesArrangementData.CashDiscountTermsCode = '';
            incoterms.ClassificationCode = '';
            incoterms.TransferLocationName = '';
            deliveryTerms.Incoterms = incoterms;
            salesArrangementData.DeliveryTerms = deliveryTerms;
            salesArrangement.add(salesArrangementData);
        }
        customer.SalesArrangement = salesArrangement;
        businessPartner.Customer = customer;
        //Address Information Mapping
        SFToC4CAccountRequest.AddressInformation addressInformation = new SFToC4CAccountRequest.AddressInformation();
        SFToC4CAccountRequest.ValidityPeriod validityPeriod = new SFToC4CAccountRequest.ValidityPeriod();
        SFToC4CAccountRequest.AddressUsage addressUsage = new SFToC4CAccountRequest.AddressUsage(); 
        addressUsage.AddressUsageCode = 'XXDEFAULT';
        validityPeriod.StartDate = '0001-01-01';
        validityPeriod.EndDate = '9999-12-31';
        addressUsage.ValidityPeriod = validityPeriod;
        addressUsage.DefaultIndicator = false;
        SFToC4CAccountRequest.Address address = new SFToC4CAccountRequest.Address();
        if(acc.Fax != null){
            SFToC4CAccountRequest.CommunicationPreference communicationPreference =  new SFToC4CAccountRequest.CommunicationPreference();
            communicationPreference.CorrespondenceLanguageCode =acc.Primary_Language__c;
            communicationPreference.PreferredCommunicationMediumTypeCode = 'FAX';
            address.CommunicationPreference = communicationPreference;
        }
        SFToC4CAccountRequest.OrganisationName organisationName = new SFToC4CAccountRequest.OrganisationName();
        organisationName.AddressRepresentationCode = '';
        SFToC4CAccountRequest.Name name = new SFToC4CAccountRequest.Name();
        name.FirstLineName = acc.Name;
        name.SecondLineName=acc.Account_Name2__c;
        name.ThirdLineName = acc.Account_Name3__c;
        name.FourthLineName='';
        organisationName.Name = name;
        address.OrganisationName = organisationName;
        SFToC4CAccountRequest.PostalAddress postalAddress = new SFToC4CAccountRequest.PostalAddress();
        postalAddress.AddressRepresentationCode = '';
        postalAddress.CountryCode = acc.BillingCountryCode;
        postalAddress.CityName = acc.BillingCity;
        postalAddress.StreetPostalCode = acc.BillingPostalCode;
        postalAddress.StreetName = acc.BillingStreet;
        //postalAddress.HouseID ='High';
        //postalAddress.TimeZoneCode='GMTUK';
        postalAddress.StreetPrefixName=acc.Address_Line_2__c;
        postalAddress.POBoxID=acc.BillingPostalCode;
        postalAddress.POBoxPostalCode = acc.PO_BOX__c;
        postalAddress.RegionCode = acc.BillingStateCode;
        address.PostalAddress = postalAddress;
        SFToC4CAccountRequest.Telephone telephone = new SFToC4CAccountRequest.Telephone();
        telephone.UsageDeniedIndicator = false;
        telephone.ValidityPeriod=validityPeriod;
        SFToC4CAccountRequest.TelephoneNumber telephoneNumber = new SFToC4CAccountRequest.TelephoneNumber();
        telephoneNumber.SubscriberID = acc.Phone;
        if(acc.Phone != null){
            telephoneNumber.CountryCode = acc.BillingCountryCode;
        }
        telephone.TelephoneNumber = telephoneNumber;
        SFToC4CAccountRequest.TelephoneUsage telephoneUsage = new SFToC4CAccountRequest.TelephoneUsage();
        SFToC4CAccountRequest.Usage usage = new SFToC4CAccountRequest.Usage();
        usage.Code = 'AD_DEFAULT';
        usage.ValidityPeriod = validityPeriod;
        telephoneUsage.Usage = usage;
        telephone.TelephoneUsage = telephoneUsage;
        address.Telephone = telephone;
        SFToC4CAccountRequest.Facsimile facsimile = new SFToC4CAccountRequest.Facsimile();
        facsimile.UsageDeniedIndicator = false;
        facsimile.ValidityPeriod=validityPeriod;
        SFToC4CAccountRequest.TelephoneNumber faxNumber = new SFToC4CAccountRequest.TelephoneNumber();
        faxNumber.SubscriberID = acc.Fax;
        if(acc.Fax != null){
            faxNumber.CountryCode = acc.BillingCountryCode;
        }
        facsimile.TelephoneNumber = faxNumber;
        SFToC4CAccountRequest.TelephoneUsage FacsimileUsage = new SFToC4CAccountRequest.TelephoneUsage();
        SFToC4CAccountRequest.Usage faxUsage = new SFToC4CAccountRequest.Usage();
        faxUsage.Code = 'AD_DEFAULT';
		faxUsage.ValidityPeriod = validityPeriod;
        FacsimileUsage.Usage = faxUsage;
        facsimile.FacsimileUsage = telephoneUsage;
        address.Facsimile = facsimile;
        if(acc.website != null){
            SFToC4CAccountRequest.Web Web = new SFToC4CAccountRequest.Web();
            Web.URI = acc.Website;
            Web.UsageDeniedIndicator = false;
            SFToC4CAccountRequest.TelephoneUsage WebUsage = new SFToC4CAccountRequest.TelephoneUsage();
            SFToC4CAccountRequest.Usage URLUsage = new SFToC4CAccountRequest.Usage();
            URLUsage.Code = 'AD_DEFAULT';
            URLUsage.ValidityPeriod = validityPeriod;
            WebUsage.Usage = URLUsage;
            Web.WebUsage = WebUsage;
            address.Web = Web;
        }
        if(acc.Email__c != null){
            SFToC4CAccountRequest.Email Email = new SFToC4CAccountRequest.Email();
            Email.URI = acc.Email__c;
            Email.UsageDeniedIndicator = false;
            SFToC4CAccountRequest.TelephoneUsage EmailUsage = new SFToC4CAccountRequest.TelephoneUsage();
            SFToC4CAccountRequest.Usage eUsage = new SFToC4CAccountRequest.Usage();
            eUsage.Code = 'AD_DEFAULT';
            eUsage.ValidityPeriod = validityPeriod;
            EmailUsage.Usage = eUsage;
            Email.EmailUsage = EmailUsage;
            address.Email = Email;
        }
        addressInformation.Address = address;
        addressInformation.AddressUsage  =  addressUsage;
        addressInformation.ValidityPeriod = validityPeriod;
        if(acc.C4C_Address_UUID__c == null){
            addressInformation.UUID='';
        }else{
            addressInformation.UUID = acc.C4C_Address_UUID__c;
        }
        businessPartner.AddressInformation = addressInformation;
        SFToC4CAccountRequest.Common common = new SFToC4CAccountRequest.Common();
        common.ReleasedIndicator=true;
        common.BlockedIndicator=false;
        common.DeletedIndicator=false;
        common.SalutationText ='';
        common.ContactAllowedCode = 1;
        SFToC4CAccountRequest.Organisation organisation = new SFToC4CAccountRequest.Organisation();
        organisation.CompanyLegalFormCode = '';
        organisation.Name = name;
        common.Organisation = organisation;
        common.Division = acc.Division_Account__c;
        common.CountryCluster=acc.Country_Cluster__c ;
        common.MarketSegment = acc.Market_Segment__c;
        common.Suite =acc.Suite__c;
        //common.ReplacedBy = acc.Replaced_By__c ; IBA-5798
        common.MasterAgreement=acc.Master_Agreement__c;
        common.ParentAccountId= acc.parent.SAP_Customer_Number__c;
        common.Segment = acc.Segment__c;
        common.DefinitiveIDNew = acc.Definitive_Id__c;
        common.FacilityType = acc.Facility_Type__c;
        common.Region = acc.Region__c;
        List<Schema.PicklistEntry> values = Account.Transport_Zone__c.getDescribe().getPicklistValues();
        Map<String,String> statusApiToLabelMap = new Map<String,String>();
        For(Schema.PicklistEntry sp : values){
            //Map to hold Picklist API as Key and Picklist Label as Value
            statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
        }
        System.debug('Label value of picklist>>'+ statusApiToLabelMap.get(acc.Transport_Zone__c));
        common.TransportationZone=statusApiToLabelMap.get(acc.Transport_Zone__c);
        common.ValidationStatus = acc.Validation_Status__c;
        common.AdvancedServicesSegment = acc.Advanced_Services_Segment__c;
        // common.CustomerSinceDate = acc.Customer_Since_Date__c;     IBA-4149
        common.VendorCredentialing = acc.Vendor_Credentialing__c ;
        common.SalesTerritory = acc.Account_Territory__c;
        businessPartner.Common = common;
        SFToC4CAccountRequest.Role role = new SFToC4CAccountRequest.Role();
        role.RoleCode=acc.C4C_Account_Role_Code__c ;
        role.ValidityPeriod = validityPeriod;
        businessPartner.Role = role;
        List<SFToC4CAccountRequest.Identification> Identification = new List<SFToC4CAccountRequest.Identification>();
        SFToC4CAccountRequest.Identification partnerIdentification = new SFToC4CAccountRequest.Identification();
        partnerIdentification.PartyIdentifierTypeCode = 'CRM002';
        if(acc.SAP_Customer_Number__c != null){
            partnerIdentification.BusinessPartnerID = acc.SAP_Customer_Number__c;
        }else{
            partnerIdentification.BusinessPartnerID = SAPECCId;
        }
        //partnerIdentification.IdentifierIssuingAgencyName = 'SFDCCNT300';
        partnerIdentification.IdentifierIssuingAgencyName = c4cSettings.External_Party_Internal_Id__c;
        partnerIdentification.EntryDate = dateNow.format('yyyy-MM-dd');
        partnerIdentification.ValidityPeriod = validityPeriod;
        SFToC4CAccountRequest.Identification partnerSAPIdentification = new SFToC4CAccountRequest.Identification();
        partnerSAPIdentification.PartyIdentifierTypeCode = 'CRM002';
        if(acc.SAP_Customer_Number__c != null){
            partnerSAPIdentification.BusinessPartnerID = acc.SAP_Customer_Number__c;
        }else{
            partnerSAPIdentification.BusinessPartnerID = SAPECCId;
        }
        
        partnerSAPIdentification.IdentifierIssuingAgencyName = c4cSettings.SAPECCIdentification__c;
        partnerSAPIdentification.EntryDate = dateNow.format('yyyy-MM-dd');
        partnerSAPIdentification.ValidityPeriod = validityPeriod;
        Identification.add(partnerIdentification);
        Identification.add(partnerSAPIdentification);
        businessPartner.Identification = Identification;
        SFToC4CAccountRequest.TextCollection textCollection = new SFToC4CAccountRequest.TextCollection();
        SFToC4CAccountRequest.Text text = new SFToC4CAccountRequest.Text();
        textCollection.Text = text;
        text.TypeCode='1';
        text.LanguageCode='EN';
        text.ContentText = 'TEST2';
        businessPartner.TextCollection = textCollection;
        businessPartnerReqMessage.BusinessPartner   =   businessPartner;   
        List <SFToC4CAccountRequest.BusinessPartnerRelationshipData > BusinessPartnerRelationship = new List < SFToC4CAccountRequest.BusinessPartnerRelationshipData > ();
        SFToC4CAccountRequest.BusinessPartnerRelationshipData relationshipData = new SFToC4CAccountRequest.BusinessPartnerRelationshipData();
        if(acc.SAP_Customer_Number__c != null){
            relationshipData.BusinessPartnerInternalID = Decimal.valueOf(acc.SAP_Customer_Number__c);
        }else{
            relationshipData.BusinessPartnerInternalID = Decimal.valueOf(SAPECCId);
        }
        
        relationshipData.RelationshipBusinessPartnerInternalID=78349;
        relationshipData.senderSequenceNumberValue=dateUniqueFormat;
        relationshipData.DefaultIndicator=false;
        relationshipData.RoleCode='BUR001';
        SFToC4CAccountRequest.ContactPerson ContactPerson=new SFToC4CAccountRequest.ContactPerson();
        ContactPerson.businessPartnerFunctionalAreaCode='Z12';
        ContactPerson.businessPartnerFunctionTypeCode = 28;
        relationshipData.ContactPerson =ContactPerson;
        BusinessPartnerRelationship.add(relationshipData);
        //businessPartnerReqMessage.BusinessPartnerRelationship = BusinessPartnerRelationship;
        businessReplicateRequest.BusinessPartnerSUITEReplicateRequestMessage = businessPartnerReqMessage;
        reqData.BusinessPartnerSUITEBulkReplicateRequest = businessReplicateRequest;
        return reqData;
    }
}