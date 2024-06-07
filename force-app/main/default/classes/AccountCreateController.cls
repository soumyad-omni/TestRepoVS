/****************************************************************************
Name           AccountCreateController
Purpose        Called from AccountTriggerHandler to update an account in SAP   
Copyright © 2018

History :
---------------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- -------------
Linda Neel             7/1/2018            Initial Creation

*****************************************************************************/
public with sharing class AccountCreateController {
    
    public static boolean isTriggerExecuting = false;
    public static boolean isFirstRun = True;
    
    @AuraEnabled
    public static string checkAccountErrorLog(ID recordId){
        
        System.debug('check SAP AccountNumber Method call ' + recordId); 
        string logMessage = '\n';
        
        Account a = [Select Id, SAP_Account_ID__c From Account where Id =: recordId LIMIT 1];
        system.debug('Sap ' + a.SAP_Account_Id__c);
        
        if (a.SAP_Account_Id__c != null) { //a.SAP_Account_Id__c.length() == 0
            logMessage = a.SAP_Account_Id__c; 
        } 
        else {
            
            list<AccountError__c> logMessages = new List<AccountError__c>([Select Id, Name, Error_Message__c,has_Displayed__c from AccountError__c 
                                                                           where Account_Id__c =: recordId AND has_Displayed__c = False]);
            
            if(logMessages != null && logMessages.size() > 0) {
                for (AccountError__c log: logMessages){
                    logMessage = log.Error_Message__c + '\n';
                    //logMessage = log.Name + ' ' + log.Error_Message__c + '\n';
                    //log.has_Displayed__c = true;
                }
                System.debug('Message count ' + logMessages.size());
                System.debug('Messages ' + logMessage);
            }
            else 
            {
                if (a.SAP_Account_Id__c != null) logMessage = a.SAP_Account_ID__c;
                else logMessage = '';
            }
        }
        return logMessage;       
    }  
    
    @AuraEnabled
    public static string checkSAPNumber(ID recordId){
        
        System.debug('check SAP AccountNumber Method call ' + recordId); 
        
        Account a = [Select Id, SAP_Account_ID__c,Validation_Status__c From Account where Id =: recordId LIMIT 1];
        string logMessage = '';
        if ( a.SAP_Account_Id__c != null) { //a.SAP_Account_Id__c.length() == 0
            logMessage = a.SAP_Account_Id__c; 
        }
        //else if (a.SAP_Account_Id__c != null && a.Validation_status__c == 'Awaiting Validation'){
        //    
        //}
        return logMessage;       
    }  
    
    //@future(callout=true)
    //public static void fetchSAPAccounts(Map<Id, SObject> oldItems, Map<Id, SObject> newItems) {
    
    //List<Account> accounts = [SELECT Id, Name, Beyond_Unique_ID__c FROM Account WHERE Id = :accountIds];
    //for (Account account : accounts) {
    //    GenerateBeyondClientId(account);
    //}
    //}
    
    @future (callout=true)
    public static void CreateAccountFromProspect(ID accountId,String oldValues, string sid){
        System.debug('@Developer -->CreateAccountFromProspect:' );
        
        Set <Id> accid = new Set<Id>();//IBA-4679
        isTriggerExecuting = true;
        String accountRole;
        //String salesDistrict;
        
        // original account values - to be used if Overcast fails
        //Account oldAccount = (Account)Json.deserialize(oldValues,Account.class);
        
        // get record type for International Customer
        Id internationalRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'International_Customer' LIMIT 1].Id;  
        Boolean isSAPAccId = false;
        boolean err = false;
        try{
            System.debug('Account Id in Method call ' + accountId);            
            Account a = [Select Id,OwnerId, Name,Account_Name2__c,Account_Name3__c,Account_Name4__c,RecordTypeId,Validation_Status__c,IsDeleted__c,Transport_Zone__c,Website,Email__c,
                         Phone,Fax, Classification__c, Po_Box__c, Primary_Language__c,Pricing_Code__c, Error__c,
                         Search_Term__c,
                         Customer_SO_Notes__c,Shipping_Notes__c,Customer_AR_Notes__c,Sales_Notes__c,Sales_Notes_Log__c, //IBA-2484
                         Address_Line_2__c,
                         Account_Territory__c,
                         SAP_Account_ID__c,
                         MKOI__c, Region__c, House_Number__c, //Added by Abhrajit Chatterjee For IBA-1884 //Added by Abhrajitc for IBA-3070
                         Master_Agreement__c,//Added by Sam Amarapalli 11/05/18
                         Partner_Type__c, BillingCountryCode,TriggerSync__c,// Added by Pavan Kumar 26/08/2020, IBA-1231 
                         BillingStreet,BillingStateCode,BillingCity,BillingCountry,BillingPostalCode, Account_Status__c, Account_Role__c, ParentId, DEA_Number__c,//IBA-4905 Saptarsha
                         Facility_Type__c	//IBA-5774
                         From Account where Id =: accountId LIMIT 1];
            
            user u = [select Omnicell_Employee_Number__c from User where id =: a.OwnerId];
            system.debug('aaa'+u.Omnicell_Employee_Number__c);
            string own = u.Omnicell_Employee_Number__c;
            
            
            System.debug('AccountID ' + a.Id);
            System.debug('@Developer -->  a.SAP_Account_ID__c :' +  a.SAP_Account_ID__c);
            
            System.debug('sid ' +sid);
            list<SAP_Sales_Org__c> salesOrgList = new list<SAP_Sales_Org__c>();
            if(sid != Null){
                System.debug('inside ' +sid);
                salesOrgList = [SELECT Terms_of_Payment__c, Shipping_Conditions__c, Service_Level__c,Non_Acute_GPO__c, Freight_Terms__c,
                                Sales_Org__c, Sales_Office__c, Name, IsDeleted,Incoterms_2__c,Pricing_Date__c,
                                Incoterms_1__c, Id, District__c, Distribution_Channel__c, Default_IDN_Price_List__c, Customer_Pricing_Procedure__c,
                                Default_GPO_Price_List__c, CurrencyIsoCode,Tax_Classification__c, Account__c, Default_Price_Code__c, Default_Plant__c
                                FROM SAP_Sales_Org__c where id =: sid];
            }else{
                if(a.SAP_Account_ID__c != null && a.SAP_Account_ID__c != ''){
                    isSAPAccId = true;
                }
                System.debug('outside ' +sid);        
                salesOrgList = [SELECT Terms_of_Payment__c, Shipping_Conditions__c, Service_Level__c,Non_Acute_GPO__c, Freight_Terms__c,
                                Sales_Org__c, Sales_Office__c, Name, IsDeleted,Incoterms_2__c,Pricing_Date__c,
                                Incoterms_1__c, Id, District__c, Distribution_Channel__c, Default_IDN_Price_List__c, Customer_Pricing_Procedure__c,
                                Default_GPO_Price_List__c, CurrencyIsoCode,Tax_Classification__c, Account__c, Default_Price_Code__c, Default_Plant__c
                                FROM SAP_Sales_Org__c where Account__c =: accountId];
            }
            // Mapped values
            if (a.Account_Role__c == 'ZGPO' || a.Account_Role__c == 'ZIDN'){ accountRole = 'ZCSP'; } else accountRole = a.Account_Role__c; 
            
            System.debug('Incomming Account Role ' + a.Account_Role__c);
            System.debug('Mapped Account Role ' + accountRole);
            
            //ZCSNCREATEUPDATE request  = new ZCSNCREATEUPDATE();
            
            // create needed lists
            //list<ZCSNCREATEUPDATE.I_KNA1> kna1List = new list<ZCSNCREATEUPDATE.I_KNA1>();
            //list<ZCSNCREATEUPDATE.I_BAPIADDR1> addressList = new list<ZCSNCREATEUPDATE.I_BAPIADDR1>();
            //list<ZCSNCREATEUPDATE.I_KNVV> knvvList = new list<ZCSNCREATEUPDATE.I_KNVV>();
            
            //list<ZCSNCREATEUPDATE.I_KNVI> knviList = new list<ZCSNCREATEUPDATE.I_KNVI>();//Added by Sam on 04/02/2019
            
            System.debug('Lists Created');
            
            /*ZCSNCREATEUPDATE.I_KNA1 kna1 = new ZCSNCREATEUPDATE.I_KNA1();

kna1.KUNNR = a.SAP_Account_ID__c; // pass SAP Id for an update
system.debug('===SAP ID==='+kna1.KUNNR);
kna1.KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
system.debug('===Role==='+kna1.KTOKD);
kna1.SORTL = a.Search_Term__c;
system.debug('===SearchTermValues==='+kna1.SORTL);
kna1.BRSCH = a.Partner_Type__c;
system.debug('===Partner Type==='+kna1.BRSCH);
kna1.ZZMASTERAGRE = a.Master_Agreement__c; //Added value by Sam Amarapalli Dt:11/05/18 to map Master Agreement field.
system.debug('===MasterAgreement==='+kna1.ZZMASTERAGRE);
kna1.ZROLE = a.Account_Role__c; //Added value by Sam Amarapalli Dt: 11/07/2018 to map Role.
system.debug('===Z Role==='+kna1.ZROLE);
kna1.KNURL = a.Website;// mapping website by Sam Amarapalli on 06 MAR 2019..
system.debug('=====Website===='+kna1.KNURL);
//kna1.SFGUID = ''; // Removed 10/11/2018 LJN - per Capgemini (maximum 16 characters)
kna1.ZZSALESFORCE_ID = a.Id; // Added Salesforce Id 10/11/2018 LJN - per Capgemini
system.debug('===SFDC Id==='+kna1.ZZSALESFORCE_ID);
kna1.ZZFLD000004 = a.MKOI__c;


//Archive in SAP if marked as Deleted
if (a.IsDeleted__c) KNA1.LOEVM = 'X';
system.debug('===Is Deleted==='+kna1.LOEVM);

//added by SAM
kna1.KUKLA = a.Classification__c;
kna1.SPRAS = a.Primary_Language__c;

kna1List.Add(kna1);*/
            // soumyad start
            String shippingNote = '';  //IBA-2484 Start  Sales_Notes__c
            String customerARNote = '';
            String customerSONote = '';
            String salesNote = '';
            if(a.Sales_Notes__c!= null && a.Sales_Notes__c!= ''){ 
                salesNote = removeHtmTag(a.Sales_Notes__c);
            }
            if(a.Shipping_Notes__c!= null){ 
                shippingNote = removeHtmTag(a.Shipping_Notes__c);
            }
            if(a.Customer_AR_Notes__c!= null){ 
                customerARNote = removeHtmTag(a.Customer_AR_Notes__c);
            }
            if(a.Customer_SO_Notes__c!= null){
                customerSONote = removeHtmTag(a.Customer_SO_Notes__c);
            }//IBA-2484 End
            String DeaNumber =a.DEA_Number__c;//IBA-4905
            string KUNNR = a.SAP_Account_ID__c; // pass SAP Id for an update
            string KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
            string SORTL = a.Search_Term__c;
            Integer maxSize1 = 10;
            if(SORTL.length() > maxSize1 ){
                SORTL = SORTL.substring(0, maxSize1);
            }
            
            string BRSCH = a.Partner_Type__c;
            string ZZMASTERAGRE = a.Master_Agreement__c; // Master Agreement field.
            string ZROLE = a.Account_Role__c; // Role.
            string NURL = a.Website;// mapping website 
            string ZZSALESFORCE_ID = a.Id; // Salesforce Id 
            string ZZFLD000004 = a.MKOI__c;
            string LOEVM = '';
            if(a.IsDeleted__c)
            {
                LOEVM = 'X';  
            }
            
            string KUKLA = a.Classification__c;
            string SPRAS = a.Primary_Language__c;
            Integer maxSize2 = 1;
            if(SPRAS.length() > maxSize2 ){
                SPRAS = SPRAS.substring(0, maxSize2);
            }
            //IBA-3083  
            String ParentCSN='';
            if(a.ParentId!=null){
                Account acct = [select Id, SAP_Customer_Number__c from Account where Id =:a.ParentId];
                ParentCSN = acct.SAP_Customer_Number__c;
            }//IBA-3083   
            System.debug('ParentCSn:'+ParentCSN);
            string kna1List = '{"KUNNR" : "'+KUNNR+'","shippingNote": "'+shippingNote+'","customerARNote": "'+customerARNote+'","customerSONote": "'+customerSONote+'","salesNote": "'+salesNote+
                '","PARENTCSN": "'+ParentCSN+'","KTOKD" : "'+KTOKD+'","SORTL" : "'+SORTL+'","BRSCH" : "'+BRSCH+'","ZZMASTERAGRE" : "'+ZZMASTERAGRE+'","ZROLE" : "'+ZROLE+'","NURL" : "'+NURL+
                '","ZZ_ID" : "'+ZZSALESFORCE_ID+'","ZZFLD000004" : "'+ZZFLD000004+'","LOEVM" : "'+LOEVM+'","KUKLA" : "'+KUKLA+'","SPRAS" : "'+SPRAS+'", "Dea_Number" : "'+DeaNumber+	//IBA-2484 //IBA-4905
                '","Facility_Type" : "'+a.Facility_Type__c+'"}'; //IBA-5774
            System.debug('kna1List' + kna1List);
            string knvvList= '';
            string knviList= '';
            string PERNR = own;
            string knvpList = '';
            // soumyad end
            // sending all related SAP sales org data to SAP in arrary format
            System.debug('isSAPAccId...1' +isSAPAccId);
            if(!isSAPAccId){
                System.debug('isSAPAccId...2' +isSAPAccId);
                for(SAP_Sales_Org__c rec : salesOrgList){
                    
                    /*ZCSNCREATEUPDATE.I_KNVV knvv = new ZCSNCREATEUPDATE.I_KNVV(); 

knvv.VKORG = rec.Sales_Org__c; //'OM01'; // Sales Organization
system.debug('===Sales Org==='+knvv.VKORG);
knvv.VTWEG = rec.Distribution_Channel__c; //'01'; // Distribution Channel
knvv.KDGRP = rec.Default_IDN_Price_List__c; //'A1'; // IDN Price List
knvv.KONDA = rec.Default_GPO_Price_List__c; //'A0'; // GPO Price List
knvv.PLTYP = rec.Service_Level__c; //'PP'; // Service Level
knvv.INCO1 = rec.Incoterms_1__c; //'FOB'; //*Incoterms
knvv.INCO2 = rec.Incoterms_2__c; //'MOUNTAIN VIEW'; // Incoterms 2
knvv.VSBED = rec.Shipping_Conditions__c; //'01'; // Shipping Conditions
knvv.WAERS = rec.CurrencyIsoCode; //'USD'; //* Currency
knvv.ZTERM = rec.Terms_of_Payment__c; //'NT30'; // Terms of Payment
knvv.VKBUR = rec.Sales_Office__c; //'OMW'; // Sales Office
knvv.KVGR5 = rec.Default_Price_Code__c; // Added Pricing code 10/8/2018 LJN - per Sarabjeet Singh               
knvv.ZPRICING_DATE = rec.Pricing_Date__c; // Added Pricing Date 10/8/2018 LJN - per Capgemini
knvv.KALKS = rec.Customer_Pricing_Procedure__c; // Added Pricing Procedure 10/24/2018 LJN - per Capgemini
knvv.SPART = '00'; // Added Division 12/6/2018 LJN - per Capgemini
knvv.BZIRK = rec.District__c;
//addded by Sam
knvv.KVGR3 = a.Customer_Class__c;

knvv.KVGR1 = a.Agreement_Type__c;
knvv.KVGR2 = a.Credit_Rating__c != null ? String.valueOf(a.Credit_Rating__c) : '';*/
                    
                    //soumyad start
                    string VKORG = rec.Sales_Org__c; //'OM01'; // Sales Organization
                    string VTWEG = rec.Distribution_Channel__c; //'01'; // Distribution Channel
                    string KDGRP = rec.Default_IDN_Price_List__c; //'A1'; // IDN Price List
                    string KONDA = rec.Default_GPO_Price_List__c; //'A0'; // GPO Price List
                    string PLTYP = rec.Service_Level__c; //'PP'; // Service Level
                    string INCO1 = rec.Incoterms_1__c; //'FOB'; //*Incoterms
                    string INCO2 = rec.Incoterms_2__c; //'MOUNTAIN VIEW'; // Incoterms 2
                    string VSBED = rec.Shipping_Conditions__c; //'01'; // Shipping Conditions
                    string WAERS = rec.CurrencyIsoCode; //'USD'; //* Currency
                    string ZTERM = rec.Terms_of_Payment__c; //'NT30'; // Terms of Payment
                    string VKBUR = rec.Sales_Office__c; //'OMW'; // Sales Office
                    string KVGR5 = rec.Default_Price_Code__c; //  Pricing code                
                    string ZPRICING_DATE = string.valueOf(rec.Pricing_Date__c); //  Pricing Date 
                    string KALKS = rec.Customer_Pricing_Procedure__c; //  Pricing Procedure 
                    string SPART = '00'; //  Division 
                    string BZIRK = rec.District__c;
                    string MAGPO = rec.Non_Acute_GPO__c;
                    string FTERMS = rec.Freight_Terms__c;
                    string VWERK = rec.Default_Plant__c; // SCP-753 Default Plant
                    string sog = '{"MAGPO": "'+MAGPO+'","FTERMS" : "'+FTERMS+'","VKORG" : "'+VKORG+'","VTWEG" : "'+VTWEG+'","KDGRP" : "'+KDGRP+'","KONDA" : "'+KONDA+'","PLTYP" : "'+PLTYP+'","INCO1" : "'+INCO1+'","INCO2" : "'+INCO2+'","VSBED" : "'+VSBED+'","WAERS" : "'+WAERS+'","ZTERM" : "'+ZTERM+'","VKBUR" : "'+VKBUR+'","KVGR5" : "'+KVGR5+'","ZPRICING_DATE" : "'+ZPRICING_DATE+'","KALKS" : "'+KALKS+'","SPART" : "'+SPART+'","BZIRK" : "'+BZIRK+'","PERNR" : "'+PERNR+'", "VWERK": "'+VWERK+'"}';
                    knvvList = knvvList + '"'+sog+'",';
                    
                    string TAXKD = rec.Tax_Classification__c;
                    string knvi = '{"TAXKD" : "'+TAXKD+'"}';
                    knviList = knviList + '"'+knvi+'",';
                    
                }
                
                
                string KUNNR11 = '';
                string SPART11 = '';  
                string PARVW = 'ZM'; //relationship value ZM for account Employee relationship in SAP
                PERNR = own;
                string KZ = 'I'; 
                
                
                for(SAP_Sales_Org__c ss : salesOrgList){
                    string knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+ss.Sales_Org__c+'","VTWEG" : "'+ss.Distribution_Channel__c+'","SPART" : "'+SPART11+'","PARVW" : "'+PARVW+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ+'"}';
                    knvpList = knvpList + '"'+knvpList1+'",';  
                }
                
                knvpList = knvpList.removeEnd(',');
                knvpList = '['+knvpList+']';
            }
            
            knvvList = knvvList.removeEnd(',');
            knvvList = '['+knvvList+']';
            knviList = knviList.removeEnd(',');
            knviList = '['+knviList+']';
            System.debug('knvvList...' +knvvList);
            //soumyad end
            /*ZCSNCREATEUPDATE.I_BAPIADDR1 addr = new ZCSNCREATEUPDATE.I_BAPIADDR1(); // CSN address

addr.NAME = a.Name;
addr.NAME_2 = a.Account_Name2__c;  // Account Name Fields Integration Added by Abhilash
addr.NAME_3 = a.Account_Name3__c;  // Account Name  Fields Integration Added by Abhilash
addr.NAME_4 = a.Account_Name4__c;  // Account Name  Fields Integration Added by Abhilash
addr.STR_SUPPL1 = a.Address_Line_2__c; // Address Line 2 field added by Mohan on 04/10/2019
system.debug('Name 2 '+addr.NAME_2);
system.debug('Name 3 '+addr.NAME_3);
system.debug('Name  4'+addr.NAME_4);
//addr.NAME = a.Name.length() > 40 ? a.Name.substring(0,39) : a.Name;
//system.debug('===AccountName1==='+addr.NAME);
//addr.NAME_4 = a.Name.length() > 40 ?  a.Name.substring(40,a.Name.length()) : '';
//system.debug('===AccountName2==='+addr.NAME_2);
addr.COUNTRY = a.BillingCountryCode; //'US'; // Country 
addr.LANGU = a.Primary_Language__c; //'EN'; // Language
addr.REGION = a.BillingStateCode; //'CA'; // State
addr.CITY = a.BillingCity; //'MOUNTAIN VIEW'; // City
addr.POSTL_COD1 = String.valueOf(a.BillingPostalCode); //'94045'; // Postal Code
addr.TRANSPZONE = a.Transport_Zone__c; //'US00000001'; //* Transportation Zone
addr.SORT1 =a.Search_Term__c; //Added by Sam Amarapalli 11/05/18
system.debug('===AddrSearchTermValuesAddr==='+addr.SORT1);
//Added by SAM..
addr.TEL1_NUMBR = a.Phone;
addr.FAX_NUMBER = a.fax;
addr.PO_BOX = a.PO_BOX__c;
addr.E_MAIL = a.Email__c;



system.debug('======Phone======'+addr.TEL1_NUMBR);

if (a.RecordTypeId == internationalRecordTypeId) 
addr.STREET = a.BillingStreet; //* Street
else{
addr.HOUSE_NO = a.BillingStreet != null && (a.BillingStreet.split(' ')[0].isAlphaNumeric() || a.BillingStreet.split(' ')[0].isNumeric() ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Sam Amarapalli on 28 Jan 2019
addr.STREET = String.isNotBlank(addr.HOUSE_NO) && String.isNotEmpty(addr.HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //'E. MIDDLEFIELD ROAD'; //* Street
}*/
            // soumyad start
            string NAME = a.Name;
            string NAME_2 = a.Account_Name2__c;  
            string NAME_3 = a.Account_Name3__c; 
            string NAME_4 = a.Account_Name4__c; 
            string STR_SUPPL1 = a.Address_Line_2__c; 
            string COUNTRY = a.BillingCountryCode;
            string LANGU = a.Primary_Language__c;
            Integer maxSize3 = 1;
            if(LANGU.length() > maxSize3 ){
                LANGU = LANGU.substring(0, maxSize3);
            }
            string REGION = a.BillingStateCode; 
            string CITY = a.BillingCity; 
            string POSTL_COD1 = String.valueOf(a.BillingPostalCode); 
            string TRANSPZONE = a.Transport_Zone__c; 
            string SORT1 =a.Search_Term__c; 
            Integer maxSize4 = 20;
            if(SORT1.length() > maxSize4 ){
                SORT1 = SORT1.substring(0, maxSize4);
            }
            string TEL1_NUMBR = a.Phone;
            string FAX_NUMBER = a.fax;
            string PO_BOX = a.PO_BOX__c;
            string E_MAIL = a.Email__c;
            string ACCOUNT_REGION = a.Region__c;//Account region information is sent to the Appconnect end to. IBA-1884
            string STREET = '';
            String streetNumber = '';
            // if (a.RecordTypeId == internationalRecordTypeId) 
            //    STREET = a.BillingStreet; //* Street
            //  else{
            //string HOUSE_NO = a.BillingStreet != null && (a.BillingStreet.split(' ')[0].isAlphaNumeric() || a.BillingStreet.split(' ')[0].isNumeric() ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Sam Amarapalli on 28 Jan 2019
            //IBA-1506 & IBA-1609 Abhrajit Chatterjee Start
            if(a.BillingStreet != NULL){ //IBA-1791 Pritha Nandi
                if(a.BillingCountryCode == 'US' || a.BillingCountryCode == 'CA' || a.BillingCountryCode == 'PR' || a.BillingCountryCode == 'VG' || a.BillingCountryCode == 'KN' || a.BillingCountryCode == 'BS'){ //IBA-3070 Added By Abhrajitc
                    if(a.BillingStreet.split(' ')[0].isNumeric() == true ){
                        string HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isAlpha() && a.BillingStreet.split(' ')[0].length() <= 10 ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Pavan for SF-BUG-1056
                        streetNumber = HOUSE_NO;
                        STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //'E. MIDDLEFIELD ROAD'; //* Street
                        STREET = STREET.trim();
                    }
                    else if(a.billingStreet.split(' ')[0].isalpha() == true){
                        //string HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isNumeric()) ? a.BillingStreet.split(' ')[0] : ''; //if Street Name is Middletowns Road and no house number. No need to send House Number
                        //streetNumber = HOUSE_NO; //IBA-3070
                        //STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //Code Removed IBA-3070
                        STREET = a.BillingStreet;
                        STREET = STREET.trim();
                    }
                    else if (a.BillingStreet.split(' ')[0].isAsciiprintable() == true){
                        //Integer houseNumberLength = a.BillingStreet.split(' ')[0].length();
                        //if(houseNumberLength <= 10){
                        string HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isnumeric()) ? a.BillingStreet.split(' ')[0] : '';
                        HOUSE_NO.replace(',', '');
                        streetNumber = HOUSE_NO;
                        STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                        STREET = STREET.trim();
                        //}
                        /*else{
STREET = a.BillingStreet != null && (a.BillingStreet.split(' ')[0].isAsciiPrintable() && a.BillingStreet.split(' ')[0].length() <= 40) ? a.BillingStreet.split(' ')[0] : '';
STREET = STREET.trim();
String HOUSE_NO = String.isNotBlank(STREET) && String.isNotEmpty(STREET) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
streetNumber = HOUSE_NO;
}*/
                    }
                }
                else{
                    if(a.House_Number__c != null){
                        streetNumber = a.House_Number__c;
                    }
                    STREET = a.BillingStreet;
                }
                
                /*else{
STREET = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isalpha() && a.BillingStreet.split(' ')[0].length() <= 40) ? a.BillingStreet.split(' ')[0] : '';
STREET = STREET.trim();
String HOUSE_NO = String.isNotBlank(STREET) && String.isNotEmpty(STREET) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
streetNumber = HOUSE_NO;
}*/
            }
            
            System.debug('====request Executed====');//IBA-1506 & IBA-1609 ABhrajit Chatterjee End
            string addressList = '{"NAME" : "'+NAME+'","NAME_2" : "'+NAME_2+'","NAME_3" : "'+NAME_3+'","NAME_4" : "'+NAME_4+'","STR_SUPPL1" : "'+STR_SUPPL1+'","COUNTRY" : "'+COUNTRY+'","LANGU" : "'+LANGU+'","REGION" : "'+REGION+'","CITY" : "'+CITY+'","POSTL_COD1" : "'+POSTL_COD1+'","TRANSPZONE" : "'+TRANSPZONE+'","SORT1" : "'+SORT1+'","TEL1_NUMBR" : "'+TEL1_NUMBR+'","FAX_NUMBER" : "'+FAX_NUMBER+'","PO_BOX" : "'+PO_BOX+'","E_MAIL" : "'+E_MAIL+'","ACCOUNT_REGION" : "'+ACCOUNT_REGION+'","STREET" : "'+STREET+'", "STREET_NUMBER" : "'+streetNumber+'"}';//Added the Region at the address list to form the Json. IBA-1884
            System.debug('@developer --> Street..........' +STREET);
            System.debug('@developer --> housenumber.......'+streetNumber);//IBA-1609 & IBA-1506
            System.debug('addressList..........' +addressList);
            //addressList.Add(addr);
            
            //request.I_KNA1 = kna1List;  
            //request.I_BAPIADDR1 = addressList;
            //request.I_KNVV = knvvList;
            //request.I_KNVI = knviList;
            
            
            string request = '{"kna1List" : "'+kna1List+'","addressList" : "'+addressList+'","knvvList" : "'+knvvList+'","knviList" : "'+knviList+'","knvpList" : "'+knvpList+'"}';
            System.debug('====request===='+request);
            string jsonString = JSON.serialize(request);
            
            jsonString = jsonString.replace('\\"', '"');
            jsonString = jsonString.replace('"{', '{');
            jsonString = jsonString.replace('}"', '}');
            jsonString = jsonString.replace('"[', '[');
            jsonString = jsonString.replace(']"', ']');
            //jsonString = jsonString.replace('"(', ' ');
            //jsonString = jsonString.replace(')"', ' ');
            jsonString = jsonString.replace('null', '');
            jsonString = jsonString.replace('quoteReplaceAfterSerialize', '\\"');//IBA-4332
            
            System.debug('@@@ AccountCreateController jsonString : '+jsonString);
            // getting value from custom settings to send data to Appconnect endpoint
            //CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
            
            //String endpoint = csValue1.Accountendpoint__c; 
            SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_AccountSFDCTOSAP');
            String endpoint =   connectionDetails.SCP_End_Point__c;
            String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
            
            system.debug('endpoint...'+endpoint);
            Http h= new Http();
            HttpRequest req= new HttpRequest();
            req.setHeader('Authorization', 'Bearer '+accessToken);
            req.setHeader('Content-Type','application/json');
            req.setHeader('accept','application/json');
            req.setBody(jsonString);
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            req.setTimeout(120000); 
            HttpResponse res=h.send(req);
            if(res.getstatusCode() == 200){
                System.debug(res+'###123createresp');
                system.debug('res.getBody()..'+res.getBody());
                a.Error__c = ' ';
                if(a.Sales_Notes__c != '' && a.Sales_Notes__c !=null){//IBA-2484
                    
                    String curUname = UserInfo.getName();
                    Datetime UTC = System.now(); 
                    system.debug('Date Time: '+UTC); 
                    Organization orgDetails = [SELECT Id, TimeZoneSidKey FROM Organization WHERE Id = :UserInfo.getOrganizationId()]; 
                    String orgTime = UTC.format('HH:mm:ss', orgDetails.TimeZoneSidKey); 
                    String orgDate = UTC.format('MM/dd/yyyy', orgDetails.TimeZoneSidKey); 
                    system.debug(orgDate+'&nbsp&nbsp'+orgTime+'&nbsp&nbsp'+Name);
                    if(a.Sales_Notes_Log__c!=null && a.Sales_Notes_Log__c!=''){
                        a.Sales_Notes_Log__c = 'Sales Notes<br>'+orgDate+'                 '+orgTime+'              '+curUname+'<br>'
                            +a.Sales_Notes__c+'<br>________________________________<br>'+a.Sales_Notes_Log__c;
                    }
                    else{
                        a.Sales_Notes_Log__c = a.Sales_Notes__c;
                    }
                    
                    a.Sales_Notes__c = '';
                }
                err = true;
                AccountTriggerHandler.TriggerDisabled = true;
                //a.SyncToC4C__c = true;
                update a;
                
                system.debug(a.Error__c+'-res-'+a.name);
            } 
            string errormsg ='';
            if(res.getstatusCode() != 200){
                system.debug('errorbody..'+res.getBody());
                system.debug('errorstatus..'+res.getStatus());              
                errormsg = res.getStatus();
                system.debug('errormsg..'+errormsg);
                if(errormsg!=null){
                    system.debug('callingclass..');
                    ErrorLogging.IntegrationLog(errormsg, 'callOutMethod','App');
                }
                a.Error__c = errormsg;
                
                err = true;
                AccountTriggerHandler.TriggerDisabled = true;
                update a;
                
            }
            
            
            if(res.getBody().length()>0){
                System.debug('AccountCreateController : Line 429');
                Map<string,object> objmap= (Map<string,object>)json.deserializeUntyped(res.getBody());
                string accnt = (string)objmap.get('E_KUNNR');
                if(accnt != null && accnt != ''){
                    Account acc = [Select Id, SAP_Account_ID__c, ParentId, Top_Level_Parent_CSN_Number__c From Account Where Id=:a.Id];//IBA-4910 Start Saptarsha Panthi
                    acc.SAP_Account_ID__c = accnt;
                    acc.SyncToC4C__c = true;
                    accid.add(a.Id);//IBA-4679
                    //system.debug('acct'+accnt);
                    Account_History__c accHistory = new Account_History__c();
                    accHistory.Account__c = acc.Id;
                    accHistory.Field__c = 'SAP Customer Number';
                    accHistory.NEW_VALUE__c = string.valueOf(accnt);
                    //accHistory.User__c = UserInfo.getUserId();
                    insert accHistory;
                    if(acc.ParentId==Null && acc.Top_Level_Parent_CSN_Number__c==Null){
                        String AccCSN = accnt.replaceFirst( '^0+', '');
                        acc.Top_Level_Parent_CSN_Number__c = AccCSN;
                    }
                    update acc;//IBA-4910 End Saptarsha Panthi
                }
                //System.debug('Trigger Sync='+a.TriggerSync__c);
            }
            //IBA-3747 start
            
            if(a.TriggerSync__c==true){// Added by Pavan Kumar 26/08/2020, IBA-1231 
                a.TriggerSync__c = false;
                update a;
            }
            
            //IBA-3747 end
            
            // soumyad end
            
            // soumyad commenting below for move functionality from Overcast to Appconnect 
            /*try{ 
overcast.Logger logger;
ZCSNCREATEUPDATE response;

//ZCSNCREATEUPDATE response  = new ZCSNCREATEUPDATE();
if(Test.isRunningTest()){  
response = fakeOvercastServiceCalllout();
}
else{  
logger = new overcast.Logger('ZCSNCREATEUPDATE');
response  = request.run(logger,null);
}

System.debug('@Developer --> response :' + response);
if (response.RETURN_x != null && response.RETURN_x.size() > 0 ){

String retMsgs = '';
string type_X = ''; // NOTE: E for error, W for warning, I for information, S for success
System.debug('response is ' + response.RETURN_x + 'size is ' + response.RETURN_x.size() );

// could be multiple messages
for (ZCSNCREATEUPDATE.RETURN_x rm : response.RETURN_x) {

type_X = rm.TYPE_x;
System.debug('Type X is ' + type_X);

//mark any existing message as displayed
markErrorsDisplayed(a.Id);

if(type_X == 'S') { // successful, is this a new record

retMsgs += rm.MESSAGE + '\n';
if(a.SAP_Account_Id__c == null || a.SAP_Account_Id__c.length() == 0) {
a.SAP_Account_ID__c = response.ZCUSTOMER_CREATE_OVERCAST.E_KUNNR;
//a.Validation_Status__c = 'Validated'; should already be set
a.Account_Status__c = 'Active';
update a;   
} 
system.debug('Insert Account Successful ' + retMsgs);                             
}
else if(type_X != 'S' && type_x != '') {

system.debug('Account Type value not S ' + retMsgs);

logger.addLog('ERROR', rm.MESSAGE);  
logger.setStatusCode(300);
retMsgs += rm.MESSAGE + '\n';

// reset values to original to keep SAP and Salesforce in sync
a.BillingCountry = oldAccount.BillingCountry;
a.Primary_Language__c = oldAccount.Primary_Language__c;
a.BillingState = oldAccount.BillingState;                        
a.BillingCity = oldAccount.BillingCity;
a.BillingPostalCode = oldAccount.BillingPostalCode;
a.BillingStreet = oldAccount.BillingStreet;                           
a.Validation_Status__c = oldAccount.Validation_Status__c;
a.Account_Status__c = oldAccount.Account_Status__c;
update a;

System.debug('Is executing ' + isTriggerExecuting + 'is first run' + isFirstRun);

system.debug('Account Information Restored ' + retMsgs);

//added by SAM on 01/08/2019.
String errorMsg = !response.RETURN_x.isEmpty() ? response.RETURN_x[0].MESSAGE : 'Attempt to save an invalid value. Please check required fields.';
// NOTE: Message of 'Sales Area xxx Invalid' is default message for any failure
AccountErrorLog.Log(errorMsg,accountId);                            

}

//system.debug('BAPI Message Returned: ' + retMsgs);
}
logger.commitToDatabase();
}
}
catch (Exception exc){
//Exception ex, String ClassName, String typeoferror
//ErrorLogging.Log(exc,'AccountCreateController: Overcast Callout Failure','Integration');
System.debug('Failure calling Accounts through overcast: ' + exc.getMessage()+' at line no: '+exc.getLineNumber());                 
}*/
        } 
        catch (Exception ex){            
            //ErrorLogging.Log(ex,'AccountCreateController: Overcast General Failure','Integration');
            //System.debug('Failure calling overcast: ' + ex.getMessage());   
            System.debug('Exception : '+ex.getMessage()+' Line no. : '+ex.getLineNumber());
            ErrorLogging.Log(ex, 'callOutMethod','App');  
            if(err == false){
                List<Account> a = [SELECT Id, Error__c FROM Account where id=: accountId LIMIT 1];
                a[0].Error__c = ex.getMessage();
                AccountTriggerHandler.TriggerDisabled = true;
                update a;
            }
        }
        finally{
            isTriggerExecuting = false;
        }
        //IBA-4679 Start
        if(accid.size()>0){
            system.enqueueJob(new ContactToCastIroncallqueueableClass(accid));
        }
	 //IBA-4679 End
    }
    
    
    // mark previous errors as displayed
    public static void markErrorsDisplayed(Id acctId) {
        
        list<AccountError__c> errorList = new List<AccountError__c>([Select Id, Name, Error_Message__c,has_Displayed__c from AccountError__c 
                                                                     where Account_Id__c =: acctId ]);
        if (errorList != null){
            for (AccountError__c log: errorList){
                log.has_Displayed__c = true;
            }
            update errorList;
        }
    }
    
    // mock future call
    /*@testVisible
static ZCSNCREATEUPDATE fakeOvercastServiceCalllout(){

// Create a fake response
ZCSNCREATEUPDATE z = new ZCSNCREATEUPDATE();     
list<ZCSNCREATEUPDATE.RETURN_x> xlist = new list<ZCSNCREATEUPDATE.RETURN_x>();

ZCSNCREATEUPDATE.RETURN_x zr = new ZCSNCREATEUPDATE.RETURN_x();
zr.MESSAGE = 'Account created successfully.';
zr.TYPE_x = 'S';
xlist.Add(zr);
z.RETURN_x = xlist;

return z;
}*/ 
    
    public static void validateAddress(List<Account> accList){
        String errorMsg;
        String HOUSE_NO;
        String STREET;
        list<String> lstCountry = new list<String>();
        
        for(Country_Config__mdt cc : [Select Id,Country_Name__c From Country_Config__mdt Where Active__c = true]){
            lstCountry.add(cc.Country_Name__c);    
        }
        System.debug('@Developer --> lstCountry :' + lstCountry);
        
        for(Account a : accList){
            System.debug('for loop Start');
            if(a.BillingStreet != null){//IBA-1791 Pritha Nandi
                
                /*if(lstCountry.contains(a.BillingCountry)){ //@Aravind // Removing this Piece of Code as Not longer splitting is required //IBA-3070
System.debug('@Developer --> Validation Check here');
list<String> lstBillingStreetDetail = a.BillingStreet.split(' ');
String sBillingStreetEndPart = lstBillingStreetDetail.get(lstBillingStreetDetail.size()-1);

lstBillingStreetDetail.remove(lstBillingStreetDetail.size()-1);
System.debug('@Developer --> lstBillingStreetDetail :' + lstBillingStreetDetail);

if(sBillingStreetEndPart.isNumeric()){
System.debug('@Developer --> isNumeric :' );
HOUSE_NO = a.BillingStreet != null ? sBillingStreetEndPart : '';
STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? String.join(lstBillingStreetDetail,' ') : a.BillingStreet;
}
else if(sBillingStreetEndPart.isAlpha()){
System.debug('@Developer --> isAlpha :' );
HOUSE_NO = a.BillingStreet != null ? sBillingStreetEndPart : '';
STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? String.join(lstBillingStreetDetail,' ') : a.BillingStreet;
}
else if(sBillingStreetEndPart.isAsciiPrintable()){
System.debug('@Developer --> isAsciiPrintable :' );
Integer houseNumberLength = sBillingStreetEndPart.length();
if(houseNumberLength >= 10){
STREET = a.BillingStreet != null ? sBillingStreetEndPart : '';
HOUSE_NO = String.isNotBlank(STREET) && String.isNotEmpty(STREET) ? String.join(lstBillingStreetDetail,' ') : a.BillingStreet;
}
else{
HOUSE_NO = a.BillingStreet != null ? sBillingStreetEndPart : '';
STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? String.join(lstBillingStreetDetail,' ') : a.BillingStreet;
}
}

System.debug('@Developer --> HOUSE_NO :' + HOUSE_NO);
System.debug('@Developer --> HOUSE_NO.length():' + HOUSE_NO.length());
System.debug('@Developer --> STREET :' + STREET);
System.debug('@Developer --> STREET.length():' + STREET.length());

if(HOUSE_NO != Null && HOUSE_NO.length() > 10){
errorMsg = 'House No length should be within 10 character';
}
else if(STREET != Null && STREET.length() > 40){
errorMsg = 'Street No length should be within 40 character';
}

if(errorMsg != null){
a.addError(errorMsg);
}
}*/
                if(a.BillingCountryCode == 'US' || a.BillingCountryCode == 'CA' || a.BillingCountryCode == 'PR' || a.BillingCountryCode == 'VG' || a.BillingCountryCode == 'KN' || a.BillingCountryCode == 'BS'){//IBA-3070 Added By Abhrajitc
                    System.debug('@Developer --> Country Cluster is US & CA'); ////IBA-3070 Added By Abhrajitc
                    if(a.BillingStreet.split(' ')[0].isNumeric() == true){ //IBA-1506 & IBA-1609 Abhrajit Chatterjee start
                        HOUSE_NO = a.BillingStreet != null ? a.BillingStreet.split(' ')[0] : '';
                        STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                    }
                    else if(a.BillingStreet.split(' ')[0].isAlpha() == true){
                        //HOUSE_NO = a.BillingStreet != null ? a.BillingStreet.split(' ')[0] : ''; //IBA-3070 Removing the logic as house number is not needed when Numeric not available by Abhrajitc
                        STREET = a.BillingStreet;
                    }
                    else if(a.BillingStreet.split(' ')[0].isAsciiPrintable() == true){
                        /*Integer houseNumberLength = a.BillingStreet.split(' ')[0].length(); //IBA-3070 Removing this Logic as no longer Required Abhrajitc
//if(houseNumberLength >= 10){
STREET = a.BillingStreet != null ? a.BillingStreet.split(' ')[0] : '';
HOUSE_NO = String.isNotBlank(STREET) && String.isNotEmpty(STREET) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
}
else{*/
                        HOUSE_NO = a.BillingStreet != null ? a.BillingStreet.split(' ')[0] : '';
                        STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                        //}
                    }//IBA-1506 & IBA-1609 Abhrajit Chatterjee END
                }else{
                    System.debug('@Developer --> Country Cluster is not US & CA');
                    if(a.House_Number__c != Null)
                        HOUSE_NO = a.House_Number__c;
                    STREET = a.BillingStreet;
                }
                System.debug('@Developer --> HOUSE_NO :' + HOUSE_NO);
                if(HOUSE_NO != null){
                    System.debug('@Developer --> HOUSE_NO.length():' + HOUSE_NO.length());
                }
                System.debug('@Developer --> STREET :' + STREET);
                if(HOUSE_NO != Null && HOUSE_NO.length() > 10){
                    errorMsg = 'House No length should be within 10 character';
                }
                else if(STREET != Null && STREET.length() > 40){
                    errorMsg = 'Street No length should be within 40 character';
                }
                if(errorMsg != null)
                    a.addError(errorMsg);
                System.debug('for loop End');
            }
        }
    }
    
    public static String removeHtmTag(String textToremove){//IBA-2484
        textToremove = textToremove.replace('<p><br></p>', '##');
        textToremove = textToremove.replace('</p>##<p>', '####');
        textToremove = textToremove.replace('<br>', '##');
        textToremove = textToremove.replace('</li><li>', '##');
        textToremove = textToremove.replace('\n', '##');
        textToremove = textToremove.replace('</p><p>', '##');
        textToremove = textToremove.replace('</p><', '##<');
        textToremove = textToremove.replace('</ul>', '##');
        textToremove = textToremove.stripHtmlTags();
        textToremove = textToremove.replace('# ', '#');
        textToremove = textToremove.replace(' #', '#');
        textToremove = textToremove.replace('"', 'quoteReplaceAfterSerialize');//IBA-4332
        textToremove = textToremove.replace('&quot;', 'quoteReplaceAfterSerialize');//IBA-4332
        return textToremove;
    }
}