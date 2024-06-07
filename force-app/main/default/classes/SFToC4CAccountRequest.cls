public class SFToC4CAccountRequest {
    public String Event;
    public BusinessPartnerSUITEBulkReplicateRequest BusinessPartnerSUITEBulkReplicateRequest;
    public class BusinessPartnerSUITEBulkReplicateRequest {
        public MessageHeader MessageHeader;
        public BusinessPartnerSUITEReplicateRequestMessage BusinessPartnerSUITEReplicateRequestMessage;
    }
    public class BusinessPartnerSUITEReplicateRequestMessage {
        public MessageHeader MessageHeader;
        public BusinessPartner BusinessPartner;
        public List <BusinessPartnerRelationshipData > BusinessPartnerRelationship = new List < BusinessPartnerRelationshipData > (); 
    }
    public class BusinessPartnerRelationshipData{
        public Decimal BusinessPartnerInternalID;
        public Decimal RelationshipBusinessPartnerInternalID;
        public String SenderSequenceNumberValue;
        public String RoleCode;
        public boolean DefaultIndicator;
        public ContactPerson ContactPerson;
    }
    public class ContactPerson{
        public Decimal BusinessPartnerFunctionTypeCode;
        public String BusinessPartnerFunctionalAreaCode;
    }
    public class BusinessPartner {
        public Decimal InternalID;
        public Decimal ReceiverInternalID;
        public String SenderSequenceNumberValue;
        public Decimal CategoryCode;
        public Customer Customer;
        public AddressInformation AddressInformation;
        public Common Common;
        public Role Role;
        public List < Identification > Identification = new List < Identification > ();
        public TextCollection TextCollection;
    }
    public class Identification{
        public String PartyIdentifierTypeCode;
        public  Object BusinessPartnerID;
        public String IdentifierIssuingAgencyName;
        public String EntryDate;
        public ValidityPeriod ValidityPeriod;
    }
    public class TextCollection {
        public Text Text;
    }
    public class Text {
        public String TypeCode;
        public String LanguageCode;
        public String ContentText;
    }
    public class Role {
        public String RoleCode;
        public ValidityPeriod ValidityPeriod;
    }
    public class Common {
        public boolean ReleasedIndicator;
        public boolean BlockedIndicator;
        public boolean DeletedIndicator;
        public String SalutationText;
        public Decimal ContactAllowedCode;
        public Organisation Organisation;
        public Person Person;
        public String Division;
        public String CountryCluster;
        public String MarketSegment;
        public String Suite;
        public String ReplacedBy;
        public String MasterAgreement;
        public String Segment;
        public String FacilityType;
        public String ParentAccountId;
        public String DefinitiveIDNew;
        public String TransportationZone;
        public String ValidationStatus;
        public String AdvancedServicesSegment;
        public Date CustomerSinceDate;
        public String SalesTerritory;
        public String VendorCredentialing;
        public String Region;
    }
    public class Organisation {
        public Name Name;
        public String CompanyLegalFormCode;
    }
    public class Person {
        public Name Name;
        public Date Birthdate;
    }
    public class Name {
        public String FirstLineName;
        public String SecondLineName;
        public String ThirdLineName;
        public String FourthLineName;
        public String FamilyName;
        public String MiddleName;
        public String GivenName;
        
    }
    public class AddressInformation {
        public AddressUsage AddressUsage;
        public Address Address;
        public String UUID;
        public ValidityPeriod ValidityPeriod;
    }
    public class ValidityPeriod {
        public String StartDate;
        public String EndDate;
    }
    public class Address {
        public CommunicationPreference CommunicationPreference;
        public OrganisationName OrganisationName;
        public PostalAddress PostalAddress;
        public Telephone Telephone;
        public Facsimile Facsimile;
        public Web Web;
        public Email Email;
    }
    public class Email{
        public String URI;
        public Boolean UsageDeniedIndicator;
        public ValidityPeriod ValidityPeriod;
        public TelephoneUsage EmailUsage;
    }
    public class Web{
        public String URI;
        public Boolean UsageDeniedIndicator;
        public TelephoneUsage WebUsage;
        
    }
    public class Telephone {
        public TelephoneNumber TelephoneNumber;
        public boolean UsageDeniedIndicator;
        public ValidityPeriod ValidityPeriod;
        public TelephoneUsage TelephoneUsage;
        public boolean MobilePhoneNumberIndicator;
    }
    public class Facsimile{
        public TelephoneNumber TelephoneNumber;
        public boolean UsageDeniedIndicator;
        public ValidityPeriod ValidityPeriod;
        public TelephoneUsage FacsimileUsage;
    }
    public class TelephoneUsage {
        public Usage Usage;
    }
    public class Usage {
        public String Code;
        public ValidityPeriod ValidityPeriod;
    }
    public class TelephoneNumber {
        public String SubscriberID;
        public String ExtensionID;
        public String CountryCode;
    }
    public class PostalAddress {
        public String AddressRepresentationCode;
        public String CountryCode;
        public String RegionCode;
        public String CityName;
        public String DistrictName;
        public String StreetPostalCode;
        public String POBoxPostalCode;
        public String CompanyPostalCode;
        public String StreetPrefixName;
        public String StreetName;
        public String StreetSuffixName;
        public String AdditionalStreetSuffixName;
        public String HouseID;
        public String BuildingID;
        public String RoomID;
        public String FloorID;
        public String CareOfName;
        public String POBoxDeviatingCountryCode;
        public String POBoxDeviatingRegionCode;
        public String POBoxDeviatingCityName;
        public String POBoxID;
        public String TimeZoneCode;
    }
    public class OrganisationName {
        public String AddressRepresentationCode;
        public Name Name;
    }
    public class CommunicationPreference {
        public String CorrespondenceLanguageCode;
        public String PreferredCommunicationMediumTypeCode;
    }
    public class AddressUsage {
        public String AddressUsageCode;
        public ValidityPeriod ValidityPeriod;
        public boolean DefaultIndicator;
    }
    public class Customer {
        public MarketingAttributes MarketingAttributes;
        public SaleSalesAndDistributionBlocks SaleSalesAndDistributionBlocks;
        public List<SalesArrangement> SalesArrangement;
    }
    public class SalesArrangement {
        public decimal LifeCycleStatusCode;
        public String SalesOrganisationID;
        public String DistributionChannelCode;
        public String SalesOfficeID;
        public String SalesGroupID;
        public String GroupCode;
        public String CashDiscountTermsCode;
        public String CurrencyCode;
        public DeliveryTerms DeliveryTerms;
        public String OrderBlockingReasonCode;
        public String BillingBlockingReasonCode;
        public String DeliveryBlockingReasonCode;
    }
    public class DeliveryTerms {
        public Incoterms Incoterms;
    }
    public class Incoterms {
        public String ClassificationCode;
        public String TransferLocationName;
    }
    public class SaleSalesAndDistributionBlocks {
        public String OrderBlockingReasonCode;
        public String BillingBlockingReasonCode;
        public String DeliveryBlockingReasonCode;
    }
    public class MarketingAttributes {
        public String CustomerNielsenRegionCode;
        public String CustomerGroupCode;
    }
    public class MessageHeader {
        public String ID;
        public String UUID;
        public String CreationDateTime;
        public SenderParty SenderParty;
        public RecipientParty RecipientParty;
    }
    public class RecipientParty {
        public String InternalID;
    }
    public class SenderParty {
        public String InternalID;
    }
    public class AccountResponse{
        public String UUID;
    }
}