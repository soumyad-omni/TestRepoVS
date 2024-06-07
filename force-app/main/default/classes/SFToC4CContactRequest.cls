public with sharing class SFToC4CContactRequest {
	public static SFToC4CAccountRequest createRequestWrapper(Id contactId){
        DateTime dateNow = DateTime.now();
        String dateString = dateNow.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		String dateUniqueFormat = dateNow.format('yyyyMMddhhmmsss');
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
        Contact con =[Select id,name,Is_Active__c ,FirstName, LastName,MiddleName,Salutation,Omnicell_Job_Code__c,Phone,Phone_Country_Code__c, 
                      		 MobilePhone, Fax,Fax_Country_Code__c,Email,SAP_Contact_Number__c,SAP_Contact_GUID__c, Language_Code__c,account.Address_Line_2__c, 
                      		 account.BillingCity,account.BillingCountryCode,account.BillingCountry,account.PO_BOX__c,
                      	 	 account.BillingPostalCode,account.Region__c,account.Account_Role__c,account.BillingStateCode,
                      		 account.BillingState,account.BillingStreet,account.Primary_Language__c,account.SAP_Customer_Number__c      
                      From Contact Where id =: contactId];
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
        businessPartner.InternalID = Decimal.valueOf(con.SAP_Contact_Number__c);
        //businessPartner.ReceiverInternalID = Decimal.valueOf(con.SAP_Contact_Number__c);
        businessPartner.SenderSequenceNumberValue = dateUniqueFormat;
        businessPartner.CategoryCode = 1;
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
        SFToC4CAccountRequest.CommunicationPreference communicationPreference =  new SFToC4CAccountRequest.CommunicationPreference();
        communicationPreference.CorrespondenceLanguageCode =con.account.Primary_Language__c;
        communicationPreference.PreferredCommunicationMediumTypeCode = 'FAX';
        address.CommunicationPreference = communicationPreference;
        SFToC4CAccountRequest.OrganisationName organisationName = new SFToC4CAccountRequest.OrganisationName();
        SFToC4CAccountRequest.PostalAddress postalAddress = new SFToC4CAccountRequest.PostalAddress();
        postalAddress.AddressRepresentationCode = '';
        postalAddress.CountryCode = con.account.BillingCountryCode;
        postalAddress.CityName = con.account.BillingCity;
        postalAddress.StreetPostalCode = con.account.BillingPostalCode;
        postalAddress.StreetName = con.account.BillingStreet;
        //postalAddress.HouseID ='High';
        postalAddress.TimeZoneCode='GMTUK';
        postalAddress.StreetPrefixName=con.account.Address_Line_2__c;
        postalAddress.POBoxID=con.account.BillingPostalCode;
        postalAddress.POBoxPostalCode = con.account.PO_BOX__c;
        postalAddress.RegionCode = con.account.BillingStateCode;
        address.PostalAddress = postalAddress;
        SFToC4CAccountRequest.Telephone telephone = new SFToC4CAccountRequest.Telephone();
        telephone.UsageDeniedIndicator = false;
        telephone.ValidityPeriod=validityPeriod;
        SFToC4CAccountRequest.TelephoneNumber telephoneNumber = new SFToC4CAccountRequest.TelephoneNumber();
        telephoneNumber.SubscriberID = con.Phone;
        if(con.Phone != null){
            telephoneNumber.CountryCode = con.Phone_Country_Code__c;
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
        faxNumber.SubscriberID = con.Fax;
        if(con.Fax != null){
            faxNumber.CountryCode = con.Fax_Country_Code__c;
        }
        facsimile.TelephoneNumber = faxNumber;
        SFToC4CAccountRequest.TelephoneUsage FacsimileUsage = new SFToC4CAccountRequest.TelephoneUsage();
        SFToC4CAccountRequest.Usage faxUsage = new SFToC4CAccountRequest.Usage();
        faxUsage.Code = 'AD_DEFAULT';
		faxUsage.ValidityPeriod = validityPeriod;
        FacsimileUsage.Usage = faxUsage;
        facsimile.FacsimileUsage = telephoneUsage;
        address.Facsimile = facsimile;
        if(con.Email != null){
            SFToC4CAccountRequest.Email Email = new SFToC4CAccountRequest.Email();
            Email.URI = con.Email;
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
        addressInformation.UUID='';
        /*if(con.SAP_Contact_GUID__c == null){
            addressInformation.UUID='';
        }else{
            addressInformation.UUID = con.SAP_Contact_GUID__c;
        }*/
        businessPartner.AddressInformation = addressInformation;
        //Common
        SFToC4CAccountRequest.Common common = new SFToC4CAccountRequest.Common();
        common.ReleasedIndicator=true;
        //common.ContactAllowedCode = 1;
		SFToC4CAccountRequest.Person Person = new SFToC4CAccountRequest.Person();
        SFToC4CAccountRequest.Name name = new SFToC4CAccountRequest.Name();
        name.GivenName = con.FirstName;
        name.MiddleName=con.MiddleName;
        name.FamilyName=con.LastName;
		Person.Name=name;
		//Person.Birthdate=con.Birthdate;   
		//
		common.Person = Person;
        businessPartner.Common = common;
        SFToC4CAccountRequest.Role role = new SFToC4CAccountRequest.Role();
        role.RoleCode='BUP001';
        businessPartner.Role = role;
        List<SFToC4CAccountRequest.Identification> Identification = new List<SFToC4CAccountRequest.Identification>();
        SFToC4CAccountRequest.Identification partnerIdentification = new SFToC4CAccountRequest.Identification();
        partnerIdentification.PartyIdentifierTypeCode = 'CRM002';
        partnerIdentification.BusinessPartnerID = con.SAP_Contact_Number__c;
        //partnerIdentification.IdentifierIssuingAgencyName = 'SFDCCNT300';
        partnerIdentification.IdentifierIssuingAgencyName = c4cSettings.External_Party_Internal_Id__c;
        partnerIdentification.EntryDate = dateNow.format('yyyy-MM-dd');
        partnerIdentification.ValidityPeriod = validityPeriod;
        Identification.add(partnerIdentification);
       	businessPartner.Identification = Identification;	
        businessPartnerReqMessage.BusinessPartner   =   businessPartner;  
        //Starting the relationship
        List <SFToC4CAccountRequest.BusinessPartnerRelationshipData > BusinessPartnerRelationship = new List < SFToC4CAccountRequest.BusinessPartnerRelationshipData > ();
        SFToC4CAccountRequest.BusinessPartnerRelationshipData relationshipData = new SFToC4CAccountRequest.BusinessPartnerRelationshipData();
        relationshipData.BusinessPartnerInternalID = Decimal.valueOf(con.account.SAP_Customer_Number__c);
        relationshipData.RelationshipBusinessPartnerInternalID=Decimal.valueOf(con.SAP_Contact_Number__c);
        relationshipData.senderSequenceNumberValue=dateUniqueFormat;
        relationshipData.DefaultIndicator=false;
        relationshipData.RoleCode='BUR001';
        SFToC4CAccountRequest.ContactPerson ContactPerson=new SFToC4CAccountRequest.ContactPerson();
        ContactPerson.businessPartnerFunctionalAreaCode='Z12';
        ContactPerson.businessPartnerFunctionTypeCode = 28;
        relationshipData.ContactPerson =ContactPerson;
        BusinessPartnerRelationship.add(relationshipData);
        businessPartnerReqMessage.BusinessPartnerRelationship = BusinessPartnerRelationship;
        //Ending the relationship
		businessReplicateRequest.BusinessPartnerSUITEReplicateRequestMessage = businessPartnerReqMessage;
        reqData.BusinessPartnerSUITEBulkReplicateRequest = businessReplicateRequest;     
        return reqData;
    }
}