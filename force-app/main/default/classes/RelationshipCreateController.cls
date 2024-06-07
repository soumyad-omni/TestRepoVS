/**
 * @File Name          : RelationshipCreateController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 18/3/2020, 3:51:00 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    18/3/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class RelationshipCreateController {

    public static boolean isTriggerExecuting = false;
    public static boolean isFirstRun = true;
    
    @future (callout=true)
    public static void CreateNewRelationship(Id primaryAccount, Id primaryAccountSalesOrg, Id secondaryAccount, String distributionChannel, 
                                             String relationshipType, String division , String counter,String defaultFlag) {//IBA-4266
        
        // used to insert new relationship
        String accountRole;
         System.debug('@@ CreateNewRelationship Create ');  
        // get record type for International Customer
        Id internationalRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'International_Customer'LIMIT 1].Id;   
                                                 
        try{ 

            Account a = [Select Id, OwnerId,Name,Account_Name2__c,Account_Name3__c,Account_Name4__c,RecordTypeId,Validation_Status__c,IsDeleted__c,Transport_Zone__c,Website,Email__c,Master_Agreement__c,
                         Phone,Fax, Classification__c, Po_Box__c,Pricing_Code__c,
                         Search_Term__c,Account_Territory__c,SAP_Account_ID__c,Primary_Language__c, Partner_Type__c, BillingCountryCode,
                         BillingStreet,BillingStateCode,BillingCity,BillingCountry,BillingPostalCode, Account_Status__c, Account_Role__c, Region__c //IBA-1884 Abhrjaitc
                         , Address_Line_2__c // IBA-2359 - Shuvodev
                        ,ParentId, House_Number__c //IBA-3083 //IBa-3070 Abhrajitc Adding House Number field
						,Customer_SO_Notes__c,Shipping_Notes__c,Customer_AR_Notes__c,Sales_Notes__c //IBA-2484
                         ,DEA_Number__c//IBA-4905
                         From Account where Id =: primaryAccount LIMIT 1];
            list<SAP_Sales_Org__c>  saleso = new list<SAP_Sales_Org__c>([select Sales_Org__c,Distribution_Channel__c from SAP_Sales_Org__c where Account__c =: primaryAccount]);
            System.debug('Account ' + a);    
            
            user u = [select Omnicell_Employee_Number__c from User where id =: a.OwnerId];
            system.debug('aaa'+u.Omnicell_Employee_Number__c);
            string own = u.Omnicell_Employee_Number__c;
            
            Account a2 = [Select Id, Name, SAP_Account_ID__c
                          From Account where Id =: secondaryAccount LIMIT 1];
            
            System.debug('Account ' + a2);            
            SAP_Sales_Org__c so  = [SELECT Terms_of_Payment__c, Shipping_Conditions__c, Service_Level__c, Default_Price_Code__c,
                                    Sales_Org__c, Sales_Office__c, Name, IsDeleted, Incoterms_2__c, Customer_Pricing_Procedure__c,
                                    Incoterms_1__c, Id, District__c, Distribution_Channel__c, Default_IDN_Price_List__c,Non_Acute_GPO__c,
									Default_GPO_Price_List__c, CurrencyIsoCode, Account__c ,Pricing_Date__c, Default_Plant__c, Freight_Terms__c
                                    FROM SAP_Sales_Org__c where Id =: primaryAccountSalesOrg LIMIT 1]; //IBA-4800 - Sourav
            
            System.debug('Sales Org ' + so);
            
            // Mapped values
            if (a.Account_Role__c == 'ZGPO' || a.Account_Role__c == 'ZIDN'){ accountRole = 'ZCSP'; } else accountRole = a.Account_Role__c; 
            
            /////////////////// soumyad changing below for moving functionality from Overcast to Castiron////////////////
            //
            //
            //ZCSNCREATEUPDATE request  = new ZCSNCREATEUPDATE();
            
            /*list<ZCSNCREATEUPDATE.I_KNA1> kna1List = new list<ZCSNCREATEUPDATE.I_KNA1>();
            list<ZCSNCREATEUPDATE.I_BAPIADDR1> addressList = new list<ZCSNCREATEUPDATE.I_BAPIADDR1>();
            list<ZCSNCREATEUPDATE.I_KNVV> knvvList = new list<ZCSNCREATEUPDATE.I_KNVV>();
            list<ZCSNCREATEUPDATE.I_KNVP> knvpList = new list<ZCSNCREATEUPDATE.I_KNVP>();*/
                      
            /*ZCSNCREATEUPDATE.I_KNA1 kna1 = new ZCSNCREATEUPDATE.I_KNA1();
            kna1.KUNNR = a.SAP_Account_ID__c; //'0000010101' '0000013151' '3100000261'; // pass SAP Id for an update 
            kna1.KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
            kna1.SORTL = a.Search_Term__c;
            kna1.BRSCH = a.Partner_Type__c;
            kna1.ZZMASTERAGRE = a.Master_Agreement__c;
            kna1.ZROLE = a.Account_Role__c;
             //added by SAM
            kna1.KUKLA = a.Classification__c;
            kna1.SPRAS = a.Primary_Language__c;
            kna1.KNURL = a.Website;// mapping website by Sam Amarapalli on 06 MAR 2019..
            
            System.debug('I_KNVV ' + kna1);
            kna1List.Add(kna1);*/
            string KUNNR = a.SAP_Account_ID__c; //'0000010101' '0000013151' '3100000261'; // pass SAP Id for an update 
            string KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
            string SORTL = a.Search_Term__c;
            Integer maxSize1 = 10;
            if(SORTL.length() > maxSize1 ){
                SORTL = SORTL.substring(0, maxSize1);
            }
            string BRSCH = a.Partner_Type__c;
            string ZZMASTERAGRE = a.Master_Agreement__c;
            string ZROLE = a.Account_Role__c;
            string KUKLA = a.Classification__c;
            string SPRAS = a.Primary_Language__c;
            Integer maxSize2 = 1;
            if(SPRAS.length() > maxSize2 ){
                SPRAS = SPRAS.substring(0, maxSize2);
            }
            string KNURL = a.Website;
            
            //IBA-3083 
            String ParentCSN='';
            if(a.ParentId!=null){
                Account acct = [select Id, SAP_Customer_Number__c from Account where Id =:a.ParentId];
                ParentCSN = acct.SAP_Customer_Number__c;
            }//IBA-3083
            
            String shippingNote = '';  //IBA-2484 Start
            String customerARNote = '';
            String customerSONote = '';
            String salesNote = '';
            String DeaNumber =a.DEA_Number__c;//IBA-4905
            if(a.Sales_Notes__c!= null && a.Sales_Notes__c!= ''){ 
                salesNote = AccountCreateController.removeHtmTag(a.Sales_Notes__c);
            }
            if(a.Shipping_Notes__c!= null){ 
                shippingNote = AccountCreateController.removeHtmTag(a.Shipping_Notes__c);
            }
            if(a.Customer_AR_Notes__c!= null){ 
                customerARNote = AccountCreateController.removeHtmTag(a.Customer_AR_Notes__c);
            }
            if(a.Customer_SO_Notes__c!= null){
                customerSONote = AccountCreateController.removeHtmTag(a.Customer_SO_Notes__c);
            } //IBA-2484 End

            string kna1List = '{"KUNNR" : "'+KUNNR+'","shippingNote": "'+shippingNote+'","customerARNote": "'+customerARNote+'","customerSONote": "'+customerSONote+'","salesNote": "'+salesNote+'","PARENTCSN": "'+ParentCSN+'","KTOKD" : "'+KTOKD+'","SORTL" : "'+SORTL+'","BRSCH" : "'+BRSCH+'","ZZMASTERAGRE" : "'+ZZMASTERAGRE+'","ZROLE" : "'+ZROLE+'","KUKLA" : "'+KUKLA+'","SPRAS" : "'+SPRAS+'","KNURL" : "'+KNURL+'","Dea_Number" : "'+DeaNumber+'"}';//IBA-2484 //IBA-4905
                      
            string VKORG = so.Sales_Org__c; //'OM01'; //* Sales Organization
            string VTWEG = so.Distribution_Channel__c; //'01'; // Distribution Channel
            string KDGRP = so.Default_IDN_Price_List__c; //'A1'; //* IDN Price List
            string KONDA = so.Default_GPO_Price_List__c; //'A0'; //* GPO Price List
            string PLTYP = so.Service_Level__c; //'PP'; //* Service Level
            string INCO1 = so.Incoterms_1__c; //'FOB'; //* Incoterms
            string INCO2 = so.Incoterms_2__c; //'MOUNTAIN VIEW'; //* Incoterms 2
            string VSBED = so.Shipping_Conditions__c; //'01'; //* Shipping Conditions
            string WAERS = so.CurrencyIsoCode; //'USD'; //* Currency
            string ZTERM = so.Terms_of_Payment__c; //'NT30'; //* Terms of Payment
            string VKBUR = so.Sales_Office__c; //'OMW'; //* Sales Office
            string KVGR5 = so.Default_Price_Code__c; // Added Pricing code 
            string ZPRICING_DATE = string.valueOf(so.Pricing_Date__c); // Added Pricing Date 
            string KALKS = so.Customer_Pricing_Procedure__c; // Added Pricing Procedure 
            string SPART = '00'; // Added Division 
            string BZIRK = so.District__c;
            String VWERK = so.Default_Plant__c;
            string FTERMS = so.Freight_Terms__c;
            string MAGPO = so.Non_Acute_GPO__c;//IBA-4800 - Sourav
            string knvvList = '[{"MAGPO": "'+MAGPO+'","VKORG" : "'+VKORG+'","VTWEG" : "'+VTWEG+'","KDGRP" : "'+KDGRP+'","KONDA" : "'+KONDA+'","PLTYP" : "'+PLTYP+'","INCO1" : "'+INCO1+'","INCO2" : "'+INCO2+'","WAERS" : "'+WAERS+'","ZTERM" : "'+ZTERM+'","VKBUR" : "'+VKBUR+'","KVGR5" : "'+KVGR5+'","ZPRICING_DATE" : "'+ZPRICING_DATE+'","KALKS" : "'+KALKS+'","SPART" : "'+SPART+'","BZIRK" : "'+BZIRK+'","VSBED" : "'+VSBED+'","VWERK" : "'+VWERK+'","FTERMS" : "'+FTERMS+'"}]';//IBA-4800-Sourav
            
            /*ZCSNCREATEUPDATE.I_BAPIADDR1 addr = new ZCSNCREATEUPDATE.I_BAPIADDR1(); // CSN address
            addr.NAME = a.Name;
            addr.NAME_2 = a.Account_Name2__c;   //Account Name Fields Integration Added by Abhilash
            addr.NAME_3 = a.Account_Name3__c;
            addr.NAME_4 = a.Account_Name4__c;
            
             system.debug('Name 2 '+addr.NAME_2);
            system.debug('Name 3 '+addr.NAME_3);
            system.debug('Name  4'+addr.NAME_4);
            
            //addr.NAME = a.Name.length() > 40 ? a.Name.substring(0,39) : a.Name;
            //addr.NAME_4 = a.Name.length() > 40 ?  a.Name.substring(40,a.Name.length()) : '';
            addr.COUNTRY = a.BillingCountryCode; //'US'; //* Country 
            addr.LANGU = a.Primary_Language__c; //'EN'; //* Language
            addr.REGION = a.BillingStateCode; //'CA'; //* State
            addr.CITY = a.BillingCity; //'MOUNTAIN VIEW'; //* City
            addr.POSTL_COD1 = String.valueOf(a.BillingPostalCode); //'94045'; //* Postal Code
            if (a.RecordTypeId == internationalRecordTypeId) 
                addr.STREET = a.BillingStreet; //* Street
            else{
                addr.HOUSE_NO = a.BillingStreet != null && (a.BillingStreet.split(' ')[0].isAlphaNumeric() || a.BillingStreet.split(' ')[0].isNumeric() ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Sam Amarapalli on 28 Jan 2019
                addr.STREET = String.isNotBlank(addr.HOUSE_NO) && String.isNotEmpty(addr.HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //'E. MIDDLEFIELD ROAD'; //* Street
            }
            addr.TRANSPZONE = a.Transport_Zone__c; //'US00000001'; //* Transportation Zone
            //Added by SAM..
            addr.TEL1_NUMBR = a.Phone;
            addr.FAX_NUMBER = a.fax;
            addr.PO_BOX = a.PO_BOX__c;
            addr.E_MAIL = a.Email__c;
            addr.SORT1 =a.Search_Term__c;
            System.debug('I_BAPIADDR ' + addr);
            addressList.Add(addr);*/
            string NAME = a.Name;
            string NAME_2 = a.Account_Name2__c;   
            string NAME_3 = a.Account_Name3__c;
            string NAME_4 = a.Account_Name4__c;
            string COUNTRY = a.BillingCountryCode; //'US'; //* Country 
            string LANGU = a.Primary_Language__c; //'EN'; //* Language
            Integer maxSize3 = 1;
            if(LANGU.length() > maxSize3 ){
                LANGU = LANGU.substring(0, maxSize3);
            }
            string REGION = a.BillingStateCode; //'CA'; //* State
            string CITY = a.BillingCity; //'MOUNTAIN VIEW'; //* City
            string POSTL_COD1 = String.valueOf(a.BillingPostalCode); //'94045'; //* Postal Code
            string TRANSPZONE = a.Transport_Zone__c; //'US00000001'; //* Transportation Zone
            string TEL1_NUMBR = a.Phone;
            string FAX_NUMBER = a.fax;
            string PO_BOX = a.PO_BOX__c;
            string E_MAIL = a.Email__c;
            string ACCOUNT_REGION = a.Region__c; //Added by Abhrajitc IBA-1884
            string SORT1 =a.Search_Term__c;
            string STR_SUPPL1 = a.Address_Line_2__c; // IBA-2359 - Shuvodev
            Integer maxSize4 = 20;
            if(SORT1.length() > maxSize4 ){
                SORT1 = SORT1.substring(0, maxSize4);
            }
            string STREET = '';
            string HOUSE_NO = '';
          //  if (a.RecordTypeId == internationalRecordTypeId) 
           //     STREET = a.BillingStreet; //* Street
          //  else{
               // string HOUSE_NO = a.BillingStreet != null && (a.BillingStreet.split(' ')[0].isAlphaNumeric() || a.BillingStreet.split(' ')[0].isNumeric() ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Sam Amarapalli on 28 Jan 2019
            //IBA-3070 Abhrajitc Starts
            if(a.BillingStreet != NULL){
                if(a.BillingCountryCode == 'US' || a.BillingCountryCode == 'CA' || a.BillingCountryCode == 'PR' || a.BillingCountryCode == 'VG' || a.BillingCountryCode == 'KN' || a.BillingCountryCode == 'BS'){
                    if(a.BillingStreet.split(' ')[0].isNumeric() == true ){
                        HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isAlpha() && a.BillingStreet.split(' ')[0].length() <= 10 ) ? a.BillingStreet.split(' ')[0] : '';
                        STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                        STREET = STREET.trim();
                    }
                    else if(a.billingStreet.split(' ')[0].isalpha() == true){
                        STREET = a.BillingStreet;
                        STREET = STREET.trim();
                    }
                    else if (a.BillingStreet.split(' ')[0].isAsciiprintable() == true){
                        HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isnumeric()) ? a.BillingStreet.split(' ')[0] : '';
                        HOUSE_NO.replace(',', '');
                        STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                        STREET = STREET.trim();
                    }
                }
                else{
                    if(a.House_Number__c != null){
                        HOUSE_NO = a.House_Number__c;
                    }
                    STREET = a.BillingStreet;
                    STREET = STREET.trim();
                }
            }
            /*HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isAlpha() && a.BillingStreet.split(' ')[0].length() <= 10 ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Pavan for SF-BUG-1056
            STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //'E. MIDDLEFIELD ROAD'; //* Street
            STREET = STREET.trim();*/
            //IBA-3070 Abhrajitc Ends
          //  }

            string addressList = '{"NAME" : "'+NAME+'","NAME_2" : "'+NAME_2+'","NAME_3" : "'+NAME_3+'","NAME_4" : "'+NAME_4+'","COUNTRY" : "'+COUNTRY+'","LANGU" : "'+LANGU+'","REGION" : "'+REGION+'","CITY" : "'+CITY+'","POSTL_COD1" : "'+POSTL_COD1+'","TRANSPZONE" : "'+TRANSPZONE+'","TEL1_NUMBR" : "'+TEL1_NUMBR+'","FAX_NUMBER" : "'+FAX_NUMBER+'","PO_BOX" : "'+PO_BOX+'","E_MAIL" : "'+E_MAIL+'","ACCOUNT_REGION" : "'+ACCOUNT_REGION+'","SORT1" : "'+SORT1+'","STREET" : "'+STREET+'","STREET_NUMBER":"'+HOUSE_NO+'","STR_SUPPL1" : "'+STR_SUPPL1+'"}'; //IBA-1884 Abhrajitc //IBA-2359 Shuvodev (added STR_SUPPL1)
            
            /*ZCSNCREATEUPDATE.I_KNVP knvp = new ZCSNCREATEUPDATE.I_KNVP();
            knvp.KUNNR = a.SAP_Account_ID__c;
            knvp.VKORG= so.Sales_Org__c;
            knvp.VTWEG = so.Distribution_Channel__c;
            knvp.SPART = division; //'00'; 
            knvp.PARVW = relationshipType; // dropdown like Z1, ZI
            knvp.PARZA = counter; // increment as needed
            knvp.KUNN2 = a2.SAP_Account_ID__c; //'3100000231';   
            
            System.debug('KNVP ' + knvp);
            knvpList.Add(knvp);*/
            string KUNNR11 = a.SAP_Account_ID__c;
            //Uncommented By RJ
            string VKORG11= so.Sales_Org__c;
            string VTWEG11 = so.Distribution_Channel__c;
            string SPART11 = division;  
            //Commented By RJ
            //string PARVW = 'ZM'; //relationship value ZM for account Employee relationship in SAP
            //Added By RJ
            string PARVW = relationshipType;
            string PARZA = counter; 
            string KUNN2 = a2.SAP_Account_ID__c;
            string PERNR = own;
            string KZ = 'I'; //insert info
            string knvpList = '';
            
           /* Commented By RJ
            for(SAP_Sales_Org__c ss : saleso){
                string knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+ss.Sales_Org__c+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ+'"}';
                knvpList = knvpList + '"'+knvpList1+'",';  
            }
            
            */
            //Added By RJ
            string knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+VKORG11+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+
                '","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA+'","KUNN2":"'+KUNN2+'","KZ" : "'+KZ+'","defaultFlag" : "'+defaultFlag+'"}'; //IBA-4266        
            knvpList = knvpList + '"'+knvpList1+'",';
            
            knvpList = knvpList.removeEnd(',');
            knvpList = '['+knvpList+']';
            //knvpList = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+VKORG11+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ+'"}';
            
            /*request.I_KNA1 = kna1List;
            request.I_BAPIADDR1 = addressList;
            request.I_KNVV = knvvList;
            request.I_KNVP = knvpList;*/
            
            string request = '{"kna1List" : "'+kna1List+'","addressList" : "'+addressList+'","knvvList" : "'+knvvList+'","knvpList" : ["'+knvpList+'"]}';
            System.debug('====request===='+request);
            //request = '['+request+']';
            string jsonString = JSON.serialize(request);
            
            jsonString = jsonString.replace('\\"', '"');
            jsonString = jsonString.replace('"{', '{');
            jsonString = jsonString.replace('}"', '}');
            jsonString = jsonString.replace('null', '');
            jsonString = jsonString.replace('"[', '[');
            jsonString = jsonString.replace(']"', ']');
            jsonString = jsonString.replace('quoteReplaceAfterSerialize', '\\"');//IBA-4332
            System.debug('@@ CreateAccountRelationship jsonString : '+jsonString);
            //getting custom settings values to send data to Appconnect
           // CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
    
           // String endpoint = csValue1.AccountRelationship__c; 
            SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_AccountRelationshipSFDCtoSAP');
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
                
            }
            
 
            /*try{
                
                overcast.Logger logger = new overcast.Logger('ZCSNCREATEUPDATE');                
                ZCSNCREATEUPDATE response  = request.run(logger,null); 
                system.debug('Response ' + response.serialize());     
                if (response.RETURN_x != null && response.RETURN_x.size() > 0 ){
                    system.debug('Response ' + response.RETURN_x);
                    
                    // could be multiple messages
                    for (ZCSNCREATEUPDATE.RETURN_x rm : response.RETURN_x) {
     
                        string type_X = rm.TYPE_x;
                        System.debug('Type X ' + type_X);
                        if(type_X != 'S' && type_x != '') { 
                            AccountErrorLog.Log('Relationship failed to Create on Insert', primaryAccount);                               
                        }
                    }
                }
                else {system.debug('No Response returned ');}
                
            }
            catch (Exception exc){
                ErrorLogging.Log(exc,'RelationshipCreateController: Overcast Callout Failure','Integration');
                System.debug('Overcast Account Failure: ' + exc.getMessage());                 
            }*/
        } 
        catch (Exception ex){            
            /*ErrorLogging.Log(ex,'RelationshipCreateController: Overcast General Failure','Integration');
            System.debug('Overcast Failure: ' + ex.getMessage());*/
            System.debug('Exception : '+ex.getMessage()+' Line no. : '+ex.getLineNumber());
            ErrorLogging.Log(ex, 'callOutMethod','App');
        }
        finally{
            isTriggerExecuting = false;
        }
    }
    
                                                                                                                                                                                                                                  
    @future (callout=true)
    public static void UpdateAccountRelationship(ID relationshipId, ID primaryId, ID salesorgId , Id secondaryId,String SAP_Division, 
                                                 String Relationship, String PARZA, ID primaryIdo, ID salesorgIdo , Id secondaryIdo,
                                                 String SAP_DivisionN,String PARZAn, String RelationshipN,String defaultFlagOld,
                                                 String defaultFlagNew){//IBA-4266
        
        // used to update an exisitng relationship 
        String accountRole;
        String salesDistrict;
        System.debug('@@ CreateNewRelationship update ');  
        // get record type for International Customer
        Id internationalRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'International_Customer'LIMIT 1].Id;
        
        try{ 
            Relationship__c r = new Relationship__c();
            if(relationshipId != Null){
                r = [Select Id, Primary_Account__c, Primary_Account_Sales_Org__c, Secondary_Account__c, Relationship__c, SAP_Division__c, PARZA__c from Relationship__c 
                                 where id =: relationshipId LIMIT 1];
            
            }else{
                r.Primary_Account__c = primaryId;
                r.Primary_Account_Sales_Org__c = null;
                r.Secondary_Account__c = null;
                r.Relationship__c = '';
                r.SAP_Division__c = '';
                r.PARZA__c = '';
            }
            System.debug('Relationshp ' + r);
            Account a = new Account();
            list<SAP_Sales_Org__c>  saleso = new list<SAP_Sales_Org__c>();
            
            a = [Select Id, OwnerId, Name, Account_Name2__c,Account_Name3__c,Account_Name4__c, RecordTypeId,Validation_Status__c,IsDeleted__c,Transport_Zone__c,Website,Email__c,Master_Agreement__c,
                         Phone,Fax, Classification__c, Po_Box__c,Pricing_Code__c,
                         Search_Term__c,Account_Territory__c,SAP_Account_ID__c,Primary_Language__c, Partner_Type__c, BillingCountryCode,
                         BillingStreet,BillingStateCode,BillingCity,BillingCountry,BillingPostalCode, Account_Status__c, Account_Role__c, Region__c //IBA-1884 Abhrajitc
                         , Address_Line_2__c // IBA-2359 - Shuvodev
                 		,ParentId, House_Number__c  //IBA-3083 //IBA-3070 abhrajitc- Added House Number field in the query
						,Customer_SO_Notes__c,Shipping_Notes__c,Customer_AR_Notes__c,Sales_Notes__c //IBA-2484
                        ,DEA_Number__c //IBA-4905
                         From Account where Id =: r.Primary_Account__c LIMIT 1];
            saleso = [select Sales_Org__c,Distribution_Channel__c,Terms_of_Payment__c, Shipping_Conditions__c, Service_Level__c, Default_Price_Code__c,
                                    Sales_Office__c, Name, IsDeleted, Incoterms_2__c, Customer_Pricing_Procedure__c,
                                    Incoterms_1__c, Id, District__c, Default_IDN_Price_List__c,Non_Acute_GPO__c,
                                    Default_GPO_Price_List__c, CurrencyIsoCode, Account__c ,Pricing_Date__c, Default_Plant__c, Freight_Terms__c 
                      from SAP_Sales_Org__c where Account__c =: r.Primary_Account__c];//IBA-4800 - Sourav
            
            
            System.debug('Account ' + a); 
            
            user u = [select Omnicell_Employee_Number__c from User where id =: a.OwnerId];
            system.debug('aaa'+u.Omnicell_Employee_Number__c);
            string own = u.Omnicell_Employee_Number__c;
                
            Account a2 = new Account();
            if(r.Secondary_Account__c != Null){
             a2 = [Select Id, SAP_Account_ID__c
                          From Account where Id =: r.Secondary_Account__c LIMIT 1];
            }else{
                a2.SAP_Account_ID__c = '';
            }
            SAP_Sales_Org__c so  = new SAP_Sales_Org__c();
            if(salesorgId != null){
            so  = [SELECT Terms_of_Payment__c, Shipping_Conditions__c, Service_Level__c, Default_Price_Code__c,
                                    Sales_Org__c, Sales_Office__c, Name, IsDeleted, Incoterms_2__c, Customer_Pricing_Procedure__c,
                                    Incoterms_1__c, Id, District__c, Distribution_Channel__c, Default_IDN_Price_List__c, 
                                    Default_GPO_Price_List__c, CurrencyIsoCode, Account__c ,Pricing_Date__c, Default_Plant__c, Freight_Terms__c
                                    FROM SAP_Sales_Org__c where Id =: salesorgId LIMIT 1];
            }else{
                so.Sales_Org__c = ''; 
                so.Distribution_Channel__c = ''; 
                so.Default_IDN_Price_List__c = ''; 
                so.Default_GPO_Price_List__c = ''; 
                so.Service_Level__c = ''; 
                so.Incoterms_1__c = ''; 
                so.Incoterms_2__c = ''; 
                so.Shipping_Conditions__c = ''; 
                so.CurrencyIsoCode = ''; 
                so.Terms_of_Payment__c = ''; 
                so.Sales_Office__c = ''; 
                so.District__c = '';
                so.Default_Plant__c = '';
                so.Freight_Terms__c = '';
            }
            System.debug('Sales Org ' + so);
            
            // Mapped values
            if (a.Account_Role__c == 'ZGPO' || a.Account_Role__c == 'ZIDN'){ accountRole = 'ZCSP'; } else accountRole = a.Account_Role__c; 
            
            /////////////////// soumyad changing below for moving functionality from Overcast to Castiron////////////////
            //
            //
            /*ZCSNCREATEUPDATE request  = new ZCSNCREATEUPDATE();
            
            list<ZCSNCREATEUPDATE.I_KNA1> kna1List = new list<ZCSNCREATEUPDATE.I_KNA1>();
            list<ZCSNCREATEUPDATE.I_BAPIADDR1> addressList = new list<ZCSNCREATEUPDATE.I_BAPIADDR1>();
            list<ZCSNCREATEUPDATE.I_KNVV> knvvList = new list<ZCSNCREATEUPDATE.I_KNVV>();
            list<ZCSNCREATEUPDATE.I_KNVP> knvpList = new list<ZCSNCREATEUPDATE.I_KNVP>();*/
                       
            /*ZCSNCREATEUPDATE.I_KNA1 kna1 = new ZCSNCREATEUPDATE.I_KNA1();
            kna1.KUNNR = a.SAP_Account_ID__c; // pass SAP Id for an update 
            kna1.KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
            kna1.SORTL = a.Search_Term__c;
            kna1.BRSCH = a.Partner_Type__c;
            kna1.KNURL = a.Website;
            
            System.debug('I_KNVV ' + kna1);
            kna1List.Add(kna1);*/
            string KUNNR = a.SAP_Account_ID__c; // pass SAP Id for an update 
            string KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
            string SORTL = a.Search_Term__c;
            Integer maxSize1 = 10;
            if(SORTL.length() > maxSize1 ){
                SORTL = SORTL.substring(0, maxSize1);
            }
            string BRSCH = a.Partner_Type__c;
            string ZZMASTERAGRE = a.Master_Agreement__c;
            string ZROLE = a.Account_Role__c;
            string KUKLA = a.Classification__c;
            string SPRAS = a.Primary_Language__c;
            Integer maxSize2 = 1;
            if(SPRAS.length() > maxSize2 ){
                SPRAS = SPRAS.substring(0, maxSize2);
            }
            string KNURL = a.Website;
			String DeaNumber =a.DEA_Number__c;//IBA-4905
            //IBA-3083 
            String ParentCSN='';
            if(a.ParentId!=null){
                Account acct = [select Id, SAP_Customer_Number__c from Account where Id =:a.ParentId];
                ParentCSN = acct.SAP_Customer_Number__c;
            }//IBA-3083
            
			String shippingNote = '';  //IBA-2484 Start
            String customerARNote = '';
            String customerSONote = '';
            String salesNote = '';
            
            if(a.Sales_Notes__c!= null && a.Sales_Notes__c!= ''){ 
                salesNote = AccountCreateController.removeHtmTag(a.Sales_Notes__c);
            }
            if(a.Shipping_Notes__c!= null){ 
                shippingNote = AccountCreateController.removeHtmTag(a.Shipping_Notes__c);
            }
            if(a.Customer_AR_Notes__c!= null){ 
                customerARNote = AccountCreateController.removeHtmTag(a.Customer_AR_Notes__c);
            }
            if(a.Customer_SO_Notes__c!= null){
                customerSONote = AccountCreateController.removeHtmTag(a.Customer_SO_Notes__c);
            } //IBA-2484 End
           
            string kna1List = '{"KUNNR" : "'+KUNNR+'","shippingNote": "'+shippingNote+'","customerARNote": "'+customerARNote+'","customerSONote": "'+customerSONote+'","salesNote": "'+salesNote+'","PARENTCSN": "'+ParentCSN+'","KTOKD" : "'+KTOKD+'","SORTL" : "'+SORTL+'","BRSCH" : "'+BRSCH+'","ZZMASTERAGRE" : "'+ZZMASTERAGRE+'","ZROLE" : "'+ZROLE+'","KUKLA" : "'+KUKLA+'","SPRAS" : "'+SPRAS+'","KNURL" : "'+KNURL+'","Dea_Number" : "'+DeaNumber+'"}';//IBA-2484 //IBA-4905
          
            /*ZCSNCREATEUPDATE.I_KNVV knvv = new ZCSNCREATEUPDATE.I_KNVV();
            knvv.VKORG = so.Sales_Org__c; //'OM01'; //* Sales Organization
            knvv.VTWEG = so.Distribution_Channel__c; //'01'; // Distribution Channel
            knvv.KDGRP = so.Default_IDN_Price_List__c; //'A1'; //* IDN Price List
            knvv.KONDA = so.Default_GPO_Price_List__c; //'A0'; //* GPO Price List
            knvv.PLTYP = so.Service_Level__c; //'PP'; //* Service Level
            knvv.INCO1 = so.Incoterms_1__c; //'FOB'; //* Incoterms
            knvv.INCO2 = so.Incoterms_2__c; //'MOUNTAIN VIEW'; //* Incoterms 2
            knvv.VSBED = so.Shipping_Conditions__c; //'01'; //* Shipping Conditions
            knvv.WAERS = so.CurrencyIsoCode; //'USD'; //* Currency
            knvv.ZTERM = so.Terms_of_Payment__c; //'NT30'; //* Terms of Payment
            knvv.VKBUR = so.Sales_Office__c; //'OMW'; //* Sales Office
            knvv.BZIRK = so.District__c;
            
            knvv.KVGR5 = so.Default_Price_Code__c; // Added Pricing code 10/8/2018 LJN - per Sarabjeet Singh
            //knvv.KVGR3 = a.Customer_Class__c; 
            //knvv.KVGR1 = a.Agreement_Type__c;
            //knvv.KVGR2 = a.Credit_Rating__c != null ? String.valueOf(a.Credit_Rating__c) : '';
            knvv.ZPRICING_DATE = so.Pricing_Date__c; // Added Pricing Date 10/8/2018 LJN - per Capgemini
            knvv.KALKS = so.Customer_Pricing_Procedure__c; // Added Pricing Procedure 10/24/2018 LJN - per Capgemini
            
            System.debug('I_KNVV ' + knvv);
            knvvList.Add(knvv);*/
            string knvvList = '';
            for(SAP_Sales_Org__c soRecord : saleso){
                string VKORG = soRecord.Sales_Org__c; //'OM01'; //* Sales Organization
                string VTWEG = soRecord.Distribution_Channel__c; //'01'; // Distribution Channel
                string KDGRP = soRecord.Default_IDN_Price_List__c; //'A1'; //* IDN Price List
                string KONDA = soRecord.Default_GPO_Price_List__c; //'A0'; //* GPO Price List
                string PLTYP = soRecord.Service_Level__c; //'PP'; //* Service Level
                string INCO1 = soRecord.Incoterms_1__c; //'FOB'; //* Incoterms
                string INCO2 = soRecord.Incoterms_2__c; //'MOUNTAIN VIEW'; //* Incoterms 2
                string VSBED = soRecord.Shipping_Conditions__c; //'01'; //* Shipping Conditions
                string WAERS = soRecord.CurrencyIsoCode; //'USD'; //* Currency
                string ZTERM = soRecord.Terms_of_Payment__c; //'NT30'; //* Terms of Payment
                string VKBUR = soRecord.Sales_Office__c; //'OMW'; //* Sales Office
                string KVGR5 = soRecord.Default_Price_Code__c; // Added Pricing code 
                string VWERK = soRecord.Default_Plant__c;
                string FTERMS = soRecord.Freight_Terms__c;
                string ZPRICING_DATE ='';
                if(soRecord.Pricing_Date__c != null )
                {
                   string.valueOf(soRecord.Pricing_Date__c); // Added Pricing Date  
                }
                string KALKS = soRecord.Customer_Pricing_Procedure__c; // Added Pricing Procedure
                string SPART = '00';
                string BZIRK = soRecord.District__c;
                string MAGPO = soRecord.Non_Acute_GPO__c;//IBA-4800 - Sourav
                if(knvvList == '')
                {
                    knvvList = '[[{"MAGPO": "'+MAGPO+'","VKORG" : "'+VKORG+'","VTWEG" : "'+VTWEG+'","KDGRP" : "'+KDGRP+'","KONDA" : "'+KONDA+'","PLTYP" : "'+PLTYP+'","INCO1" : "'+INCO1+'","INCO2" : "'+INCO2+'","WAERS" : "'+WAERS+'","ZTERM" : "'+ZTERM+'","VKBUR" : "'+VKBUR+'","KVGR5" : "'+KVGR5+'","ZPRICING_DATE" : "'+ZPRICING_DATE+'","KALKS" : "'+KALKS+'","SPART" : "'+SPART+'","BZIRK" : "'+BZIRK+'","VSBED" : "'+VSBED+'","VWERK" : "'+VWERK+'","FTERMS" : "'+FTERMS+'"} ,';//IBA-4800 - Sourav
                }
                else
                {
                   knvvList = knvvList+ '{"MAGPO": "'+MAGPO+'","VKORG" : "'+VKORG+'","VTWEG" : "'+VTWEG+'","KDGRP" : "'+KDGRP+'","KONDA" : "'+KONDA+'","PLTYP" : "'+PLTYP+'","INCO1" : "'+INCO1+'","INCO2" : "'+INCO2+'","WAERS" : "'+WAERS+'","ZTERM" : "'+ZTERM+'","VKBUR" : "'+VKBUR+'","KVGR5" : "'+KVGR5+'","ZPRICING_DATE" : "'+ZPRICING_DATE+'","KALKS" : "'+KALKS+'","SPART" : "'+SPART+'","BZIRK" : "'+BZIRK+'","VSBED" : "'+VSBED+'","VWERK" : "'+VWERK+'","FTERMS" : "'+FTERMS+'"},';//IBA-4800 - Sourav
                }               
            }
            if(knvvList != '')
            {
               knvvList = knvvList.removeEnd(',');
               knvvList = knvvList + ']]'; 
            }else //Added by abhrajitc for IBA-1880 START
            {
                knvvList = +'[]';
            }
            //Added by abhrajitc for IBA-1880 END
            
           
            /*ZCSNCREATEUPDATE.I_BAPIADDR1 addr = new ZCSNCREATEUPDATE.I_BAPIADDR1(); // CSN address
            addr.NAME = a.Name;
            //addr.NAME = a.Name.length() > 40 ? a.Name.substring(0,39) : a.Name;
            //system.debug('===AccountName1==='+addr.NAME);
            //addr.NAME_4 = a.Name.length() > 40 ?  a.Name.substring(40,a.Name.length()) : '';
            addr.COUNTRY = a.BillingCountryCode; //'US'; //* Country 
            addr.LANGU = a.Primary_Language__c; //'EN'; //* Language
            addr.REGION = a.BillingStateCode; //'CA'; //* State
            addr.CITY = a.BillingCity; //'MOUNTAIN VIEW'; //* City
            addr.POSTL_COD1 = String.valueOf(a.BillingPostalCode); //'94045'; //* Postal Code
            addr.TEL1_NUMBR = a.Phone;
            addr.FAX_NUMBER = a.fax;
            addr.PO_BOX = a.PO_BOX__c;
            addr.E_MAIL = a.Email__c;
            
            
            if (a.RecordTypeId == internationalRecordTypeId) 
                addr.STREET = a.BillingStreet; //* Street
            else{
                addr.HOUSE_NO = a.BillingStreet.substring(0,a.BillingStreet.indexOf(' ')); //'6250'; //* House Number
                addr.STREET = a.BillingStreet.substring(a.BillingStreet.indexOf(' ')+1); //'E. MIDDLEFIELD ROAD'; //* Street
            }
            addr.TRANSPZONE = a.Transport_Zone__c; //a.Transportation_Zone__c; //'US00000001'; //* Transportation Zone
            
            System.debug('I_BAPIADDR ' + addr);
            addressList.Add(addr);*/
            string NAME = a.Name;
            string NAME_2 = a.Account_Name2__c;   
            string NAME_3 = a.Account_Name3__c;
            string NAME_4 = a.Account_Name4__c;
            string COUNTRY = a.BillingCountryCode; //'US'; //* Country 
            string LANGU = a.Primary_Language__c; //'EN'; //* Language
            Integer maxSize3 = 1;
            if(LANGU.length() > maxSize3 ){
                LANGU = LANGU.substring(0, maxSize3);
            }
            string REGION = a.BillingStateCode; //'CA'; //* State
            string CITY = a.BillingCity; //'MOUNTAIN VIEW'; //* City
            string POSTL_COD1 = String.valueOf(a.BillingPostalCode); //'94045'; //* Postal Code
            string TRANSPZONE = a.Transport_Zone__c; //'US00000001'; //* Transportation Zone
            string TEL1_NUMBR = a.Phone;
            string FAX_NUMBER = a.fax;
            string PO_BOX = a.PO_BOX__c;
            string E_MAIL = a.Email__c;
            string ACCOUNT_REGION = a.Region__c;//Account region information is sent to the Appconnect end to. IBA-1884
            string SORT1 =a.Search_Term__c;
            Integer maxSize4 = 20;
            if(SORT1.length() > maxSize4 ){
                SORT1 = SORT1.substring(0, maxSize4);
            }
            string STREET = '';
            string HOUSE_NO = '';
            string STR_SUPPL1 = a.Address_Line_2__c; // IBA-2359 - Shuvodev
            //if (a.RecordTypeId == internationalRecordTypeId) 
             //   STREET = a.BillingStreet; //* Street
          //  else{
          //IBA-3070 Starts Abhrajitc Updating split logic
          if(a.BillingStreet != NULL){
              if(a.BillingCountryCode == 'US' || a.BillingCountryCode == 'CA' || a.BillingCountryCode == 'PR' || a.BillingCountryCode == 'VG' || a.BillingCountryCode == 'KN' || a.BillingCountryCode == 'BS'){
                  if(a.BillingStreet.split(' ')[0].isNumeric() == true ){
                      HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isAlpha() && a.BillingStreet.split(' ')[0].length() <= 10 ) ? a.BillingStreet.split(' ')[0] : '';
                      STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                      STREET = STREET.trim();
                  }
                  else if(a.billingStreet.split(' ')[0].isalpha() == true){
                      STREET = a.BillingStreet;
                      STREET = STREET.trim();
                  }
                  else if (a.BillingStreet.split(' ')[0].isAsciiprintable() == true){
                      HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isnumeric()) ? a.BillingStreet.split(' ')[0] : '';
                      HOUSE_NO.replace(',', '');
                      STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                      STREET = STREET.trim();
                  }
              }
              else{
                  if(a.House_Number__c != null){
                      HOUSE_NO = a.House_Number__c;
                  }
                  STREET = a.BillingStreet;
                  STREET = STREET.trim();
              }
          }
                /*HOUSE_NO = a.BillingStreet.substring(0,a.BillingStreet.indexOf(' ')); //'6250'; //* House Number
                STREET = a.BillingStreet.substring(a.BillingStreet.indexOf(' ')+1); //'E. MIDDLEFIELD ROAD'; //* Street
                STREET = STREET.trim();
                //STREET = STREET.substring(0, 40);*/
           // }
           // IBA-3070 ends Abhrajitc
            string addressList = '{"NAME" : "'+NAME+'","NAME_2" : "'+NAME_2+'","NAME_3" : "'+NAME_3+'","NAME_4" : "'+NAME_4+'","COUNTRY" : "'+COUNTRY+'","LANGU" : "'+LANGU+'","REGION" : "'+REGION+'","CITY" : "'+CITY+'","POSTL_COD1" : "'+POSTL_COD1+'","TRANSPZONE" : "'+TRANSPZONE+'","TEL1_NUMBR" : "'+TEL1_NUMBR+'","FAX_NUMBER" : "'+FAX_NUMBER+'","PO_BOX" : "'+PO_BOX+'","E_MAIL" : "'+E_MAIL+'","ACCOUNT_REGION" : "'+ACCOUNT_REGION+'","SORT1" : "'+SORT1+'","STREET" : "'+STREET+'","STREET_NUMBER":"'+HOUSE_NO+'","STR_SUPPL1" : "'+STR_SUPPL1+'"}'; //IBA-1884 Abhrajitc //IBA-2359 Shuvodev (added STR_SUPPL1)
            
            /*ZCSNCREATEUPDATE.I_KNVP knvp = new ZCSNCREATEUPDATE.I_KNVP();
            knvp.KUNNR = a.SAP_Account_ID__c;
            knvp.VKORG= so.Sales_Org__c;
            knvp.VTWEG = so.Distribution_Channel__c;
            knvp.SPART = r.SAP_Division__c; //'00'; 
            knvp.PARVW = r.Relationship__c; // dropdown like Z1, ZI
            knvp.PARZA = r.PARZA__c; //'000'; //increment as needed
            knvp.KUNN2 = a2.SAP_Account_ID__c; //'3100000231';   
            
            System.debug('KNVP ' + knvp);
            knvpList.Add(knvp);*/
            
            string KUNNR11 = '';
            string VKORG11 = '';
            string VTWEG11 = '';
            string SPART11 = '';
            string PARVW = '';
            string PARZA1 = '';
            string PERNR = '';
            string KZ1 = '';
            string KZ2 = '';
            
            /*KUNNR11 = a.SAP_Account_ID__c;
            VKORG11 = so.Sales_Org__c;
            VTWEG11 = so.Distribution_Channel__c;
            SPART11 = r.SAP_Division__c; //'00'; 
            PARVW = 'ZM'; // dropdown like Z1, ZI
            PARZA1 = r.PARZA__c; //'000'; //increment as needed
            //KUNN2 = a2.SAP_Account_ID__c; //'3100000231';
            PERNR = own;
            KZ2 = 'I'; //for update ... insert*/

            //string knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+VKORG11+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA1+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ2+'"}';
            string request1 = '"kna1List" : "'+kna1List+'","addressList" : "'+addressList+'","knvvList" : '+knvvList;
            
            
            ///////////////////////////////////////////////////// getting old relationship values for delete old record /////////////////////////////////////////////////////////
            
            
            
            //Account a11 = [Select Id,OwnerId From Account where Id =: primaryIdo LIMIT 1];
            Account a22 = new Account();
            if(secondaryIdo != Null){
            a22 = [Select Id, SAP_Account_ID__c From Account where Id =: secondaryIdo LIMIT 1];
            }
            SAP_Sales_Org__c soo  = new SAP_Sales_Org__c();
            if(salesorgIdo != null){
            soo  = [SELECT Terms_of_Payment__c, Shipping_Conditions__c, Service_Level__c, Default_Price_Code__c,
                                    Sales_Org__c, Sales_Office__c, Name, IsDeleted, Incoterms_2__c, Customer_Pricing_Procedure__c,
                                    Incoterms_1__c, Id, District__c, Distribution_Channel__c, Default_IDN_Price_List__c, 
                                    Default_GPO_Price_List__c, CurrencyIsoCode, Account__c ,Pricing_Date__c,Default_Plant__c, Freight_Terms__c
                                    FROM SAP_Sales_Org__c where Id =: salesorgIdo LIMIT 1];
            }else{
                soo.Sales_Org__c = ''; 
                soo.Distribution_Channel__c = ''; 
                soo.Default_IDN_Price_List__c = ''; 
                soo.Default_GPO_Price_List__c = ''; 
                soo.Service_Level__c = ''; 
                soo.Incoterms_1__c = ''; 
                soo.Incoterms_2__c = ''; 
                soo.Shipping_Conditions__c = ''; 
                soo.CurrencyIsoCode = ''; 
                soo.Terms_of_Payment__c = ''; 
                soo.Sales_Office__c = ''; 
                soo.District__c = '';
                soo.Default_Plant__c = '';
                soo.Freight_Terms__c = '';
            }
            user uo = [select Omnicell_Employee_Number__c from User where id =: primaryIdo];
            system.debug('aaa'+uo.Omnicell_Employee_Number__c);
            string owno = uo.Omnicell_Employee_Number__c;
            
            
            /*KUNNR11 = a.SAP_Account_ID__c;
            VKORG11 = so.Sales_Org__c;
            VTWEG11 = so.Distribution_Channel__c;
            SPART11 = SAP_Division; //'00'; 
            PARVW = 'ZM'; // dropdown like Z1, ZI
            PARZA1 = PARZA; //'000'; //increment as needed
            //string KUNN2 = a2.SAP_Account_ID__c; //'3100000231';
            PERNR = owno;
            KZ1 = 'D'; //for update ... delete*/
            
            KUNNR11 = a.SAP_Account_ID__c;
            VTWEG11 = so.Distribution_Channel__c;
            
            string knvpList1 = '';
            string knvpList = '';
            // creating array of insert and delete info with all realted sales org data of Primary account
            if(own != owno){
            PARVW = 'ZM';
            for(SAP_Sales_Org__c ss : saleso){
                
                SPART11 = r.SAP_Division__c;
                PARZA1 = r.PARZA__c;
                PERNR = own;
                KZ2 = 'I';
                knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+ss.Sales_Org__c+'","VTWEG" : "'+ss.Distribution_Channel__c+'","SPART" : "'
                    +SPART11+'","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ2+'","defaultFlag" : "'
                    +defaultFlagNew+'"}';//IBA-4266
                knvpList = knvpList + '"'+knvpList1+'",';
                SPART11 = SAP_Division;
                PARZA1 = PARZA;
                PERNR = owno;
                KZ1 = 'D';
                knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+ss.Sales_Org__c+'","VTWEG" : "'+ss.Distribution_Channel__c+'","SPART" : "'
                    +SPART11+'","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ1+'","defaultFlag" : "'
                    +defaultFlagOld+'"}';//IBA-4266
                knvpList = knvpList + '"'+knvpList1+'",';
            }
            knvpList = knvpList.removeEnd(',');
            knvpList = '['+knvpList+']';
            } else{
                KUNNR11 = a.SAP_Account_ID__c;
                VKORG11= so.Sales_Org__c;
                VTWEG11 = so.Distribution_Channel__c;
                SPART11 = SAP_DivisionN;
                PARVW = RelationshipN;
                PARZA1 = PARZAn; 
                string KUNN2 = a2.SAP_Account_ID__c;
                PERNR = own;
                string KZ = 'I'; //insert info
                                
                knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+VKORG11+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'
                    +PARVW+'","PARZA" : "'+PARZA+'","KUNN2":"'+KUNN2+'","KZ" : "'+KZ+'","defaultFlag" : "'+defaultFlagNew+'"}';//IBA-4266          
                knvpList = knvpList + '"'+knvpList1+'",';
                
                
                VKORG11= soo.Sales_Org__c;
                VTWEG11 = soo.Distribution_Channel__c;
                SPART11 = SAP_Division;
                PARVW = Relationship;
                PARZA1 = PARZA; 
                KUNN2 = a22.SAP_Account_ID__c;
                KZ = 'D'; //delete info
                                
                knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+VKORG11+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'
                    +PARVW+'","PARZA" : "'+PARZA+'","KUNN2":"'+KUNN2+'","KZ" : "'+KZ+'","defaultFlag" : "'+defaultFlagOld+'"}';//IBA-4266         
                knvpList = knvpList + '"'+knvpList1+'",';
                
                knvpList = knvpList.removeEnd(',');
                knvpList = '['+knvpList+']';
            }
            //string knvpList2 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+VKORG11+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ1+'"}';
            
            /*request.I_KNA1 = kna1List;
            request.I_BAPIADDR1 = addressList;
            request.I_KNVV = knvvList;
            request.I_KNVP = knvpList;*/
            
            string request2 = '"knvpList" : ["'+knvpList+'"]';
            string request = '{'+request1+','+request2+'}';
            
            System.debug('====request===='+request);
            string jsonString = JSON.serialize(request);
            
            jsonString = jsonString.replace('\\"', '"');
            jsonString = jsonString.replace('"{', '{');
            jsonString = jsonString.replace('}"', '}');
            jsonString = jsonString.replace('null', '');
            jsonString = jsonString.replace('["', '[');
            jsonString = jsonString.replace('"]', ']');
            jsonString = jsonString.replace('quoteReplaceAfterSerialize', '\\"');//IBA-4332
            //System.debug('@@ UpdateAccountRelationship jsonString : '+jsonString);
            //if(own != owno){
            //CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
    
            //String endpoint = csValue1.AccountRelationship__c; 
            SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_AccountRelationshipSFDCtoSAP');
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
            
            }
            //}
 
            /*try{
                
                overcast.Logger logger = new overcast.Logger('ZCSNCREATEUPDATE');                
                ZCSNCREATEUPDATE response  = request.run(logger,null); 
                system.debug('Response ' + response.serialize());     
                if (response.RETURN_x != null && response.RETURN_x.size() > 0 ){
                    system.debug('Response ' + response.RETURN_x);
                    
                    // could be multiple messages
                    for (ZCSNCREATEUPDATE.RETURN_x rm : response.RETURN_x) {
     
                        string type_X = rm.TYPE_x;
                        System.debug('Type X ' + type_X);

                        if(type_X != 'S') { 
                            AccountErrorLog.Log('Relationship failed to Create',relationshipId);   
                        }
                    }
                }
                else {system.debug('No Response returned ');}
                
            }
            catch (Exception exc){
                ErrorLogging.Log(exc,'RelationshipUpdateController: Overcast Callout Failure','Integration');
                System.debug('Overcast Account Failure: ' + exc.getMessage());                 
            }*/
        } 
        catch (Exception ex){            
            /*ErrorLogging.Log(ex,'RelationshipUpdateController: Overcast General Failure','Integration');
            System.debug('Overcast Failure: ' + ex.getMessage());*/
            System.debug('Exception : '+ex.getMessage()+' Line no. : '+ex.getLineNumber());
            ErrorLogging.Log(ex, 'callOutMethod','App');
        }
        finally{
            isTriggerExecuting = false;
        }

    } 
    
    @future (callout=true)
    public static void deleteAccountRelationship(String SAP_Division, String Relationship, String PARZA, ID primaryId, ID salesorgId , 
                                                 Id secondaryId, String defaultFlag){//IBA-4266
        try{
             // used to update an exisitng relationship 
            String accountRole;
            String salesDistrict;
            
            // get record type for International Customer
            Id internationalRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'International_Customer'LIMIT 1].Id;
            Account a = [Select Id,OwnerId, Name,Account_Name2__c,Account_Name3__c,Account_Name4__c, RecordTypeId,Validation_Status__c,IsDeleted__c,Transport_Zone__c,Website,Email__c,Master_Agreement__c,
                         Phone,Fax, Classification__c, Po_Box__c,Pricing_Code__c,
                         Search_Term__c,Account_Territory__c,SAP_Account_ID__c,Primary_Language__c, Partner_Type__c, BillingCountryCode,
                         BillingStreet,BillingStateCode,BillingCity,BillingCountry,BillingPostalCode, Account_Status__c, Account_Role__c, Region__c  //IBA=1884 Abhrajitc
                         , Address_Line_2__c // IBA-2359 - Shuvodev
                         ,Customer_SO_Notes__c,Shipping_Notes__c,Customer_AR_Notes__c,Sales_Notes__c //IBA-2484
                         ,ParentId, House_Number__c //IBA-3083 & IBA-3070
                         From Account where Id =: primaryId LIMIT 1];
            Account a2 = [Select Id, Name, RecordTypeId, SAP_Account_ID__c From Account where Id =: secondaryId LIMIT 1];
            list<SAP_Sales_Org__c>  saleso = new list<SAP_Sales_Org__c>([select Sales_Org__c from SAP_Sales_Org__c where Account__c =: primaryId]);
            user u = [select Omnicell_Employee_Number__c from User where id =: a.OwnerId];
            system.debug('aaa'+u.Omnicell_Employee_Number__c);
            string own = u.Omnicell_Employee_Number__c;
            
            SAP_Sales_Org__c so  = [SELECT Terms_of_Payment__c, Shipping_Conditions__c, Service_Level__c, Default_Price_Code__c,
                                    Sales_Org__c, Sales_Office__c, Name, IsDeleted, Incoterms_2__c, Customer_Pricing_Procedure__c,
                                    Incoterms_1__c, Id, District__c, Distribution_Channel__c, Default_IDN_Price_List__c, 
                                    Default_GPO_Price_List__c, CurrencyIsoCode, Account__c ,Pricing_Date__c, Default_Plant__c, Freight_Terms__c
                                    FROM SAP_Sales_Org__c where Id =: salesorgId LIMIT 1];
            if (a.Account_Role__c == 'ZGPO' || a.Account_Role__c == 'ZIDN'){ accountRole = 'ZCSP'; } else accountRole = a.Account_Role__c; 
            
            /////////////////// soumyad changing below for moving functionality from Overcast to Castiron////////////////
            //
            //
            /*ZCSNCREATEUPDATE request  = new ZCSNCREATEUPDATE();
            
            list<ZCSNCREATEUPDATE.I_KNA1> kna1List = new list<ZCSNCREATEUPDATE.I_KNA1>();
            list<ZCSNCREATEUPDATE.I_BAPIADDR1> addressList = new list<ZCSNCREATEUPDATE.I_BAPIADDR1>();
            list<ZCSNCREATEUPDATE.I_KNVV> knvvList = new list<ZCSNCREATEUPDATE.I_KNVV>();
            list<ZCSNCREATEUPDATE.I_KNVP> knvpList = new list<ZCSNCREATEUPDATE.I_KNVP>();*/
            
            /*ZCSNCREATEUPDATE.I_KNA1 kna1 = new ZCSNCREATEUPDATE.I_KNA1();
            kna1.KUNNR = a.SAP_Account_ID__c; // pass SAP Id for an update 
            kna1.KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
            kna1.SORTL = a.Search_Term__c;
            kna1.BRSCH = a.Partner_Type__c;
            kna1.ZZMASTERAGRE = a.Master_Agreement__c;
            kna1.ZROLE = a.Account_Role__c;
            kna1.KNURL = a.Website;
        
            //added by Sam
            kna1.KUKLA = a.Classification__c;
            kna1.SPRAS = a.Primary_Language__c;
            System.debug('I_KNVV ' + kna1);
            kna1List.Add(kna1);*/
            string KUNNR = a.SAP_Account_ID__c; //'0000010101' '0000013151' '3100000261'; // pass SAP Id for an update 
            string KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
            string SORTL = a.Search_Term__c;
            Integer maxSize1 = 10;
            if(SORTL.length() > maxSize1 ){
                SORTL = SORTL.substring(0, maxSize1);
            }
            string BRSCH = a.Partner_Type__c;
            string ZZMASTERAGRE = a.Master_Agreement__c;
            string ZROLE = a.Account_Role__c;
            string KUKLA = a.Classification__c;
            string SPRAS = a.Primary_Language__c;
            Integer maxSize2 = 1;
            if(SPRAS.length() > maxSize2 ){
                SPRAS = SPRAS.substring(0, maxSize2);
            }
            string KNURL = a.Website;
            //IBA-3083 
            String ParentCSN='';
            if(a.ParentId!=null){
                Account acct = [select Id, SAP_Customer_Number__c from Account where Id =:a.ParentId];
                ParentCSN = acct.SAP_Customer_Number__c;
            }//IBA-3083

            String shippingNote = '';  //IBA-2484 Start
            String customerARNote = '';
            String customerSONote = '';
            String salesNote = '';
            
            if(a.Sales_Notes__c!= null && a.Sales_Notes__c!= ''){ 
                salesNote = AccountCreateController.removeHtmTag(a.Sales_Notes__c);
            }
            if(a.Shipping_Notes__c!= null){ 
                shippingNote = AccountCreateController.removeHtmTag(a.Shipping_Notes__c);
            }
            if(a.Customer_AR_Notes__c!= null){ 
                customerARNote = AccountCreateController.removeHtmTag(a.Customer_AR_Notes__c);
            }
            if(a.Customer_SO_Notes__c!= null){
                customerSONote = AccountCreateController.removeHtmTag(a.Customer_SO_Notes__c);
            } //IBA-2484 End
           
            string kna1List = '{"KUNNR" : "'+KUNNR+'","shippingNote": "'+shippingNote+'","customerARNote": "'+customerARNote+'","customerSONote": "'+customerSONote+'","salesNote": "'+salesNote+'","PARENTCSN": "'+ParentCSN+'","KTOKD" : "'+KTOKD+'","SORTL" : "'+SORTL+'","BRSCH" : "'+BRSCH+'","ZZMASTERAGRE" : "'+ZZMASTERAGRE+'","ZROLE" : "'+ZROLE+'","KUKLA" : "'+KUKLA+'","SPRAS" : "'+SPRAS+'","KNURL" : "'+KNURL+'"}';//IBA-2484
          
            /*ZCSNCREATEUPDATE.I_KNVV knvv = new ZCSNCREATEUPDATE.I_KNVV();
            knvv.VKORG = so.Sales_Org__c; //'OM01'; //* Sales Organization
            knvv.VTWEG = so.Distribution_Channel__c; //'01'; // Distribution Channel
            knvv.KDGRP = so.Default_IDN_Price_List__c; //'A1'; //* IDN Price List
            knvv.KONDA = so.Default_GPO_Price_List__c; //'A0'; //* GPO Price List
            knvv.PLTYP = so.Service_Level__c; //'PP'; //* Service Level
            knvv.INCO1 = so.Incoterms_1__c; //'FOB'; //* Incoterms
            knvv.INCO2 = so.Incoterms_2__c; //'MOUNTAIN VIEW'; //* Incoterms 2
            knvv.VSBED = so.Shipping_Conditions__c; //'01'; //* Shipping Conditions
            knvv.WAERS = so.CurrencyIsoCode; //'USD'; //* Currency
            knvv.ZTERM = so.Terms_of_Payment__c; //'NT30'; //* Terms of Payment
            knvv.VKBUR = so.Sales_Office__c; //'OMW'; //* Sales Office
            
            knvv.KVGR5 = so.Default_Price_Code__c; // Added Pricing code 10/8/2018 LJN - per Sarabjeet Singh  // Changed on 23 Aug - Capgemini
            knvv.ZPRICING_DATE = so.Pricing_Date__c; // Added Pricing Date 10/8/2018 LJN - per Capgemini
            knvv.KALKS = so.Customer_Pricing_Procedure__c; // Added Pricing Procedure 10/24/2018 LJN - per Capgemini
            
            knvv.BZIRK = so.District__c;
            //addded by Sam
            //knvv.KVGR3 = a.Customer_Class__c;
            
            //knvv.KVGR1 = a.Agreement_Type__c;
            //knvv.KVGR2 = a.Credit_Rating__c != null ? String.valueOf(a.Credit_Rating__c) : '';
            
            System.debug('I_KNVV ' + knvv);
            knvvList.Add(knvv);*/
            string VKORG = so.Sales_Org__c; //'OM01'; //* Sales Organization
            string VTWEG = so.Distribution_Channel__c; //'01'; // Distribution Channel
            string KDGRP = so.Default_IDN_Price_List__c; //'A1'; //* IDN Price List
            string KONDA = so.Default_GPO_Price_List__c; //'A0'; //* GPO Price List
            string PLTYP = so.Service_Level__c; //'PP'; //* Service Level
            string INCO1 = so.Incoterms_1__c; //'FOB'; //* Incoterms
            string INCO2 = so.Incoterms_2__c; //'MOUNTAIN VIEW'; //* Incoterms 2
            string VSBED = so.Shipping_Conditions__c; //'01'; //* Shipping Conditions
            string WAERS = so.CurrencyIsoCode; //'USD'; //* Currency
            string ZTERM = so.Terms_of_Payment__c; //'NT30'; //* Terms of Payment
            string VKBUR = so.Sales_Office__c; //'OMW'; //* Sales Office
            string KVGR5 = so.Default_Price_Code__c; // Added Pricing code 
            string ZPRICING_DATE = string.valueOf(so.Pricing_Date__c); // Added Pricing Date 
            string KALKS = so.Customer_Pricing_Procedure__c; // Added Pricing Procedure
            string SPART = '00';
            string BZIRK = so.District__c;
            string VWERK = so.Default_Plant__c;
            string FTERMS = so.Freight_Terms__c;
            string knvvList = '[{"VKORG" : "'+VKORG+'","VTWEG" : "'+VTWEG+'","KDGRP" : "'+KDGRP+'","KONDA" : "'+KONDA+'","PLTYP" : "'+PLTYP+'","INCO1" : "'+INCO1+'","INCO2" : "'+INCO2+'","WAERS" : "'+WAERS+'","ZTERM" : "'+ZTERM+'","VKBUR" : "'+VKBUR+'","KVGR5" : "'+KVGR5+'","ZPRICING_DATE" : "'+ZPRICING_DATE+'","KALKS" : "'+KALKS+'","SPART" : "'+SPART+'","BZIRK" : "'+BZIRK+'","VSBED" : "'+VSBED+'","VWERK" : "'+VWERK+'","FTERMS" : "'+FTERMS+'"}]';

            
            /*ZCSNCREATEUPDATE.I_BAPIADDR1 addr = new ZCSNCREATEUPDATE.I_BAPIADDR1(); // CSN address
            addr.NAME = a.Name;
            //addr.NAME = a.Name.length() > 40 ? a.Name.substring(0,39) : a.Name;
            //system.debug('===AccountName1==='+addr.NAME);
           // addr.NAME_4 = a.Name.length() > 40 ?  a.Name.substring(40,a.Name.length()) : '';
            addr.COUNTRY = a.BillingCountryCode; //'US'; //* Country 
            addr.LANGU = a.Primary_Language__c; //'EN'; //* Language
            addr.REGION = a.BillingStateCode; //'CA'; //* State
            addr.CITY = a.BillingCity; //'MOUNTAIN VIEW'; //* City
            addr.POSTL_COD1 = String.valueOf(a.BillingPostalCode); //'94045'; //* Postal Code
            if (a.RecordTypeId == internationalRecordTypeId) 
                addr.STREET = a.BillingStreet; //* Street
            else{
                addr.HOUSE_NO = a.BillingStreet != null && (a.BillingStreet.split(' ')[0].isAlphaNumeric() || a.BillingStreet.split(' ')[0].isNumeric() ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Sam Amarapalli on 28 Jan 2019
                addr.STREET = String.isNotBlank(addr.HOUSE_NO) && String.isNotEmpty(addr.HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //'E. MIDDLEFIELD ROAD'; //* Street
            }
            addr.TRANSPZONE = a.Transport_Zone__c; //a.Transportation_Zone__c; //'US00000001'; //* Transportation Zone
            //Added by SAM..
            addr.TEL1_NUMBR = a.Phone;
            addr.FAX_NUMBER = a.fax;
            addr.PO_BOX = a.PO_BOX__c;
            addr.E_MAIL = a.Email__c;
            System.debug('I_BAPIADDR ' + addr);
            addressList.Add(addr);*/
            string NAME = a.Name;
            string NAME_2 = a.Account_Name2__c;   
            string NAME_3 = a.Account_Name3__c;
            string NAME_4 = a.Account_Name4__c;
            string COUNTRY = a.BillingCountryCode; //'US'; //* Country 
            string LANGU = a.Primary_Language__c; //'EN'; //* Language
            Integer maxSize3 = 1;
            if(LANGU.length() > maxSize3 ){
                LANGU = LANGU.substring(0, maxSize3);
            }
            string REGION = a.BillingStateCode; //'CA'; //* State
            string CITY = a.BillingCity; //'MOUNTAIN VIEW'; //* City
            string POSTL_COD1 = String.valueOf(a.BillingPostalCode); //'94045'; //* Postal Code
            string TRANSPZONE = a.Transport_Zone__c; //'US00000001'; //* Transportation Zone
            string TEL1_NUMBR = a.Phone;
            string FAX_NUMBER = a.fax;
            string PO_BOX = a.PO_BOX__c;
            string E_MAIL = a.Email__c;
            string ACCOUNT_REGION = a.Region__c;//Account region information is sent to the Appconnect end to. IBA-1884
            string SORT1 =a.Search_Term__c;
            string STR_SUPPL1 = a.Address_Line_2__c; // IBA-2359 - Shuvodev
            Integer maxSize4 = 20;
            if(SORT1.length() > maxSize4 ){
                SORT1 = SORT1.substring(0, maxSize4);
            }
            string STREET = '';
            string HOUSE_NO = '';
            //IBA-3070 Starts Abhrajitc
            if(a.BillingStreet != NULL){
                if(a.BillingCountryCode == 'US' || a.BillingCountryCode == 'CA' || a.BillingCountryCode == 'PR' || a.BillingCountryCode == 'VG' || a.BillingCountryCode == 'KN' || a.BillingCountryCode == 'BS'){
                    if(a.BillingStreet.split(' ')[0].isNumeric() == true ){
                        HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isAlpha() && a.BillingStreet.split(' ')[0].length() <= 10 ) ? a.BillingStreet.split(' ')[0] : '';
                        STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                        STREET = STREET.trim();
                    }
                    else if(a.billingStreet.split(' ')[0].isalpha() == true){
                        STREET = a.BillingStreet;
                        STREET = STREET.trim();
                    }
                    else if (a.BillingStreet.split(' ')[0].isAsciiprintable() == true){
                        HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isnumeric()) ? a.BillingStreet.split(' ')[0] : '';
                        HOUSE_NO.replace(',', '');
                        STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                        STREET = STREET.trim();
                    }
                }
                else{
                    if(a.House_Number__c != null){
                        HOUSE_NO = a.House_Number__c;
                    }
                    STREET = a.BillingStreet;
                    STREET = STREET.trim();
                }
            }
           // if (a.RecordTypeId == internationalRecordTypeId)
           //    STREET = a.BillingStreet; //* Street  test test test
           // else{
           //string HOUSE_NO = a.BillingStreet != null && (a.BillingStreet.split(' ')[0].isAlphaNumeric() || a.BillingStreet.split(' ')[0].isNumeric() ) ? a.BillingStreet.split(' ')[0] : '';
           /*HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isAlpha() && a.BillingStreet.split(' ')[0].length() <= 10 ) ? a.BillingStreet.split(' ')[0] : '';     //Added by Pavan for SF-BUG-105
           STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //'E. MIDDLEFIELD ROAD'; //* Street
		   STREET = STREET.trim();*/
           // STREET = STREET.substring(0, 40);
           //}
           //IBA=3070 Abhrajitc Ends
            
            string addressList = '{"NAME" : "'+NAME+'","NAME_2" : "'+NAME_2+'","NAME_3" : "'+NAME_3+'","NAME_4" : "'+NAME_4+'","COUNTRY" : "'+COUNTRY+'","LANGU" : "'+LANGU+'","REGION" : "'+REGION+'","CITY" : "'+CITY+'","POSTL_COD1" : "'+POSTL_COD1+'","TRANSPZONE" : "'+TRANSPZONE+'","TEL1_NUMBR" : "'+TEL1_NUMBR+'","FAX_NUMBER" : "'+FAX_NUMBER+'","PO_BOX" : "'+PO_BOX+'","E_MAIL" : "'+E_MAIL+'","ACCOUNT_REGION" : "'+ACCOUNT_REGION+'","SORT1" : "'+SORT1+'","STREET" : "'+STREET+'","STREET_NUMBER":"'+HOUSE_NO+'","STR_SUPPL1" : "'+STR_SUPPL1+'"}'; //IBA-1884 Abhrajitc //IBA-2359 Shuvodev (added STR_SUPPL1)
            
            /*ZCSNCREATEUPDATE.I_KNVP knvp = new ZCSNCREATEUPDATE.I_KNVP();
            knvp.KUNNR = a.SAP_Account_ID__c;
            knvp.VKORG= so.Sales_Org__c;
            knvp.VTWEG = so.Distribution_Channel__c;
            knvp.SPART = SAP_Division; //'00'; 
            knvp.PARVW = Relationship; // dropdown like Z1, ZI
            knvp.PARZA = PARZA; //'000'; //increment as needed
            knvp.KUNN2 = a2.SAP_Account_ID__c; //'3100000231';  
            knvp.KZ = 'D';
            
            System.debug('KNVP ' + knvp);
            knvpList.Add(knvp);*/
            string KUNNR11 = a.SAP_Account_ID__c;
            string VKORG11 = so.Sales_Org__c;
            string VTWEG11 = so.Distribution_Channel__c;
            string SPART11 = SAP_Division;  
           // string PARVW = 'ZM'; 
            string PARVW = Relationship; 
            string PARZA1 = PARZA;
            string KUNN2 = a2.SAP_Account_ID__c;
            string PERNR = own;  
            string KZ = 'D';
            string knvpList = '';
            /*
            for(SAP_Sales_Org__c ss : saleso){
                string knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+ss.Sales_Org__c+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA1+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ+'"}';
                knvpList = knvpList + '"'+knvpList1+'",';  
            }*/
            
            string knvpList1 = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+VKORG11+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'+
                PARVW+'","PARZA" : "'+PARZA1+'","KUNN2":"'+KUNN2+'","KZ" : "'+KZ+'","defaultFlag" : "'+defaultFlag+'"}';//IBA-4266
                knvpList = knvpList + '"'+knvpList1+'",'; 
            
            knvpList = knvpList.removeEnd(',');
            knvpList = '['+knvpList+']';
            //string knvpList = '{"KUNNR" : "'+KUNNR11+'","VKORG" : "'+VKORG11+'","VTWEG" : "'+VTWEG11+'","SPART" : "'+SPART11+'","PARVW" : "'+PARVW+'","PARZA" : "'+PARZA1+'","PERNR" : "'+PERNR+'","KZ" : "'+KZ+'"}';
            
            /*request.I_KNA1 = kna1List;
            request.I_BAPIADDR1 = addressList;
            request.I_KNVV = knvvList;
            request.I_KNVP = knvpList;*/           
            
            string request = '{"kna1List" : "'+kna1List+'","addressList" : "'+addressList+'","knvvList" : "'+knvvList+'","knvpList" : ["'+knvpList+'"]}';
            System.debug('====request===='+request);
            //request = '['+request+']';
            string jsonString = JSON.serialize(request);
            
            jsonString = jsonString.replace('\\"', '"');
            jsonString = jsonString.replace('"{', '{');
            jsonString = jsonString.replace('}"', '}');
            jsonString = jsonString.replace('null', '');
            jsonString = jsonString.replace('"[', '[');
            jsonString = jsonString.replace(']"', ']');
            jsonString = jsonString.replace('quoteReplaceAfterSerialize', '\\"');//IBA-4332
           // System.debug('delete jsonString : '+jsonString);
            
          //  CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
     
           // String endpoint = csValue1.AccountRelationship__c; 
           
            SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_AccountRelationshipSFDCtoSAP');
            String endpoint =   connectionDetails.SCP_End_Point__c;
            String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
            
           // system.debug('endpoint...'+endpoint);
           // System.debug('delete jsonString : '+jsonString);
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
            
            }
            /*try{
                overcast.Logger logger = new overcast.Logger('ZCSNCREATEUPDATE');                
                ZCSNCREATEUPDATE response  = request.run(logger,null); 
                system.debug('Response ' + response.serialize());     
                if (response.RETURN_x != null && response.RETURN_x.size() > 0 ){
                    system.debug('Response ' + response.RETURN_x);
                    
                    // could be multiple messages
                    for (ZCSNCREATEUPDATE.RETURN_x rm : response.RETURN_x) {
     
                        string type_X = rm.TYPE_x;
                        System.debug('Type X ' + type_X);

                        if(type_X != 'S') { 
                            AccountErrorLog.Log('Relationship failed to delete',primaryId);   
                        }
                    }
                }
                else {system.debug('No Response returned ');}
                
            }
            catch (Exception exc){
                ErrorLogging.Log(exc,'RelationshipUpdateController: Overcast Callout Failure','Integration');
                System.debug('Overcast Account Failure: ' + exc.getMessage());                 
            }*/
                                    
        }catch(Exception ex){
            /*ErrorLogging.Log(ex,'RelationshipUpdateController: Overcast General Failure','Integration');
            System.debug('Overcast Failure: ' + ex.getMessage());*/
            System.debug('Exception : '+ex.getMessage()+' Line no. : '+ex.getLineNumber());
            ErrorLogging.Log(ex, 'callOutMethod','App');
        }
    } 
    
    public static void UpdateAccountRelationshipmain(ID relationshipId, ID primaryId, ID salesorgId , Id secondaryId,String SAP_Division, 
            String Relationship, String PARZA, ID primaryIdo, ID salesorgIdo , Id secondaryIdo, 
            String SAP_DivisionN,String PARZAn, String RelationshipN, Relationship__c oldrel,
            Relationship__c newRel){//IBA-4266
                   list<account> accOwner = [select id, Ownerid from Account where id =: primaryIdo];
                                                         
                   id own = accOwner[0].Ownerid;
                   //IBA-4266 Start
                   String defaultFlagold = '';
                   String defaultFlagNew = '';
                   if(oldrel.Default_Partner_Flag__c == true){
                       defaultFlagold = 'X';                                  
                   }
                   if(newRel.Default_Partner_Flag__c == true){
                       defaultFlagNew = 'X';                                      
                   }
                   //IBA-4266 End
                   RelationshipCreateController.UpdateAccountRelationship(relationshipId,primaryId, salesorgId, secondaryId,
                                    SAP_Division,Relationship, PARZA, own, salesorgIdo, secondaryIdo, 
                                    SAP_DivisionN, PARZAn, RelationshipN,defaultFlagold,defaultFlagNew);//IBA-4266
           }
}