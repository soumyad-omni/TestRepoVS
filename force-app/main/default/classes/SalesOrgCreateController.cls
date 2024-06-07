public with sharing class SalesOrgCreateController {

    public static boolean isTriggerExecuting = false;
    public static boolean isFirstRun = true;
   
    @future (callout=true)
    public static void CreateNewSalesOrg(String salesOrg,String oldsalesOrg) {
        
        // used to update Sales Organization
        String accountRole;

        SAP_Sales_Org__c rec = (SAP_Sales_Org__c)Json.deserialize(salesOrg,SAP_Sales_Org__c.class);
        SAP_Sales_Org__c oldSO;
        if(oldsalesOrg != ''){
            oldSO = (SAP_Sales_Org__c)Json.deserialize(oldsalesOrg,SAP_Sales_Org__c.class);
        }
        
        Account a = [Select Id, Name,Account_Name2__c,Account_Name3__c,Account_Name4__c, RecordTypeId,Validation_Status__c,IsDeleted__c,Transport_Zone__c,Website,Email__c,
                          Phone,Fax, Classification__c, Po_Box__c, Primary_Language__c,Pricing_Code__c,
                         Search_Term__c,Account_Territory__c,SAP_Account_ID__c, Partner_Type__c, BillingCountryCode,
                         BillingStreet,BillingStateCode,BillingCity,BillingCountry,BillingPostalCode, Account_Status__c, Account_Role__c
						,Customer_SO_Notes__c,Shipping_Notes__c,Customer_AR_Notes__c,Sales_Notes__c //IBA-2484
                     	,Address_Line_2__c //IBA-2359 - Shuvodev
                     	,ParentId //IBA-3083
                     	,House_Number__c //IBA-3070 Added by Abhrajitc
                         From Account where Id =: rec.Account__c LIMIT 1]; //IBA-1992 Abhrajitc
            
        // Mapped values
        if (a.Account_Role__c == 'ZGPO' || a.Account_Role__c == 'ZIDN'){ accountRole = 'ZCSP'; } else accountRole = a.Account_Role__c;         
        
        // get record type for International Customer
        Id internationalRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'International_Customer'LIMIT 1].Id;
        
        try{ 
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

            ZCSNCREATEUPDATE request  = new ZCSNCREATEUPDATE();
            
            list<ZCSNCREATEUPDATE.I_KNA1> kna1List = new list<ZCSNCREATEUPDATE.I_KNA1>();
            list<ZCSNCREATEUPDATE.I_BAPIADDR1> addressList = new list<ZCSNCREATEUPDATE.I_BAPIADDR1>();
            list<ZCSNCREATEUPDATE.I_KNVV> knvvList = new list<ZCSNCREATEUPDATE.I_KNVV>();
            list<ZCSNCREATEUPDATE.I_KNVI> knviList = new list<ZCSNCREATEUPDATE.I_KNVI>();//Added by Sam on 04/02/2019
                       
            ZCSNCREATEUPDATE.I_KNA1 kna1 = new ZCSNCREATEUPDATE.I_KNA1();
            kna1.KUNNR = a.SAP_Account_ID__c; //'0000010101' '0000013151' '3100000261'; // pass SAP Id for an update 
            kna1.KTOKD = accountRole; //'ZCSN'; 'ZCSS' //* Role - GPO or IDN
            kna1.SORTL = a.Search_Term__c;
            kna1.BRSCH = a.Partner_Type__c;
            kna1.KNURL = a.Website; // March 7 2018..
            kna1.KUKLA = a.Classification__c;
            kna1.SPRAS = a.Primary_Language__c;
            kna1.PARENTCSN = ParentCSN;//IBA-3083
            kna1.shippingNote = shippingNote;//IBA-2484 Start
            kna1.customerARNote = customerARNote;
            kna1.customerSONote = customerSONote;
            kna1.salesNote = salesNote;//IBA-2484 End
            System.debug('I_KNVV ' + kna1);
            kna1List.Add(kna1);
          
            ZCSNCREATEUPDATE.I_KNVV knvv = new ZCSNCREATEUPDATE.I_KNVV();
            knvv.VKORG = rec.Sales_Org__c; //'OM01'; //* Sales Organization
            knvv.VTWEG = rec.Distribution_Channel__c; //'01'; // Distribution Channel
            knvv.KDGRP = rec.Default_IDN_Price_List__c; //'A1'; //* IDN Price List
            knvv.KONDA = rec.Default_GPO_Price_List__c; //'A0'; //* GPO Price List
            knvv.PLTYP = rec.Service_Level__c; //'PP'; //* Service Level
            knvv.INCO1 = rec.Incoterms_1__c; //'FOB'; //* Incoterms
            knvv.INCO2 = rec.Incoterms_2__c; //'MOUNTAIN VIEW'; //* Incoterms 2
            knvv.VSBED = rec.Shipping_Conditions__c; //'01'; //* Shipping Conditions
            knvv.WAERS = rec.CurrencyIsoCode; //'USD'; //* Currency
            knvv.ZTERM = rec.Terms_of_Payment__c; //'NT30'; //* Terms of Payment
            knvv.VKBUR = rec.Sales_Office__c; //'OMW'; //* Sales Office
            knvv.KVGR5 = rec.Default_Price_Code__c; // Added Pricing code 10/8/2018 LJN - per Sarabjeet Singh  // Changed on 23 Aug - Capgemini
            knvv.ZPRICING_DATE = rec.Pricing_Date__c; // Added Pricing Date 10/8/2018 LJN - per Capgemini
            knvv.KALKS = rec.Customer_Pricing_Procedure__c; // Added Pricing Procedure 10/24/2018 LJN - per Capgemini    
            knvv.SPART = '00'; // Added Division 12/6/2018 LJN - per Capgemini
            knvv.BZIRK = rec.District__c;//added by Sam
            knvv.VWERK = rec.Default_Plant__c; //Added by Aravind for SCP-753
            knvv.FTERMS = rec.Freight_Terms__c;
            //knvv.KVGR3 = a.Customer_Class__c;
            
            //knvv.KVGR1 = a.Agreement_Type__c;
            //knvv.KVGR2 = a.Credit_Rating__c != null ? String.valueOf(a.Credit_Rating__c) : '';
            
            System.debug('I_KNVV ' + knvv);
            knvvList.Add(knvv);
            ZCSNCREATEUPDATE.I_KNVI knvi = new ZCSNCREATEUPDATE.I_KNVI();//Added by Sam Amarapalli 05/02/19
            knvi.TAXKD = rec.Tax_Classification__c;//Added by Sam Amarapalli 05/02/19
            knviList.add(knvi); //Added by Sam Amarapalli 05/02/19
            System.debug('====knviList====='+knviList);
            ZCSNCREATEUPDATE.I_BAPIADDR1 addr = new ZCSNCREATEUPDATE.I_BAPIADDR1(); // CSN address
            addr.NAME = a.Name;
            addr.NAME_2 = a.Account_Name2__c;  // Account Name  Fields Integration Added by Abhilash
            addr.NAME_3 = a.Account_Name3__c;
            addr.NAME_4 = a.Account_Name4__c;
            
            // system.debug('Name 2 '+addr.NAME_2);
          //  system.debug('Name 3 '+addr.NAME_3);
            //system.debug('Name  4'+addr.NAME_4);
            
            //addr.NAME = a.Name.length() > 40 ? a.Name.substring(0,39) : a.Name;
            //system.debug('===AccountName1==='+addr.NAME);
            //addr.NAME_4 = a.Name.length() > 40 ?  a.Name.substring(40,a.Name.length()) : '';
            addr.COUNTRY = a.BillingCountryCode; //'US'; //* Country 
            addr.LANGU = a.Primary_Language__c; //'EN'; //* Language
            addr.REGION = a.BillingStateCode; //'CA'; //* State
            addr.CITY = a.BillingCity; //'MOUNTAIN VIEW'; //* City
            addr.POSTL_COD1 = String.valueOf(a.BillingPostalCode); //'94045'; //* Postal Code
            //Added by SAM..
            addr.TEL1_NUMBR = a.Phone;
            addr.FAX_NUMBER = a.fax;
            addr.PO_BOX = a.PO_BOX__c;
            addr.E_MAIL = a.Email__c;
            
            
           // if (a.RecordTypeId == internationalRecordTypeId) 
           //     addr.STREET = a.BillingStreet; //* Street
          //  else{
                //addr.HOUSE_NO = a.BillingStreet != null && (a.BillingStreet.split(' ')[0].isAlphaNumeric() || a.BillingStreet.split(' ')[0].isNumeric() ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Sam Amarapalli on 28 Jan 2019
            //IBA-3070 Abhrajit 01/06/23
            if(a.BillingStreet != NULL){
                if(a.BillingCountryCode == 'US' || a.BillingCountryCode == 'CA' || a.BillingCountryCode == 'PR' || a.BillingCountryCode == 'VG' || a.BillingCountryCode == 'KN' || a.BillingCountryCode == 'BS'){ //IBA-3070 Added By Abhrajitc
                    if(a.BillingStreet.split(' ')[0].isNumeric() == true ){
                        string HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isAlpha() && a.BillingStreet.split(' ')[0].length() <= 10 ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Pavan for SF-BUG-1056
                        addr.HOUSE_NO = HOUSE_NO;
                        addr.STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //'E. MIDDLEFIELD ROAD'; //* Street
                        addr.STREET = addr.STREET.trim();
                    }
                    else if(a.billingStreet.split(' ')[0].isalpha() == true){
                        addr.STREET = a.BillingStreet;
                        addr.STREET = addr.STREET.trim();
                    }
                    else if (a.BillingStreet.split(' ')[0].isAsciiprintable() == true){
                        string HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isnumeric()) ? a.BillingStreet.split(' ')[0] : '';
                        HOUSE_NO.replace(',', '');
                        addr.HOUSE_NO = HOUSE_NO;
                        addr.STREET = String.isNotBlank(HOUSE_NO) && String.isNotEmpty(HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet;
                        addr.STREET = addr.STREET.trim();
                    }
                }
                else{
                    if(a.House_Number__c != null){
                        addr.HOUSE_NO = a.House_Number__c;
                    }
                    addr.STREET = a.BillingStreet;
                    addr.STREET.trim();
                }
            }
            System.debug('@developer --> House_No:' +addr.HOUSE_NO);
            System.debug('@developer --> StreetName:' +addr.STREET);
            /*string HOUSE_NO = a.BillingStreet != null && (!a.BillingStreet.split(' ')[0].isAlpha() && a.BillingStreet.split(' ')[0].length() <= 10 ) ? a.BillingStreet.split(' ')[0] : ''; //Added by Pavan for SF-BUG-1056
            addr.HOUSE_NO = HOUSE_NO;
            addr.STREET = String.isNotBlank(addr.HOUSE_NO) && String.isNotEmpty(addr.HOUSE_NO) ? a.BillingStreet.substring(a.BillingStreet.indexOf(' ') +1 ) : a.BillingStreet; //'E. MIDDLEFIELD ROAD'; //* Street
            addr.STREET.trim();*/
            //IBA-3070 End
            //}
            addr.TRANSPZONE = a.Transport_Zone__c; //'US00000001'; //* Transportation Zone
            addr.STR_SUPPL1 = a.Address_Line_2__c; //IBA-2359 - Shuvodev
            
            System.debug('I_BAPIADDR ' + addr);
            addressList.Add(addr);

            request.I_KNA1 = kna1List;
            request.I_BAPIADDR1 = addressList;
            request.I_KNVV = knvvList;
            request.I_KNVI = knviList;
            System.debug('SalesOrgCreateController request: '+request);
            try{
                
                //overcast.Logger logger = new overcast.Logger('ZCSNCREATEUPDATE');//Commented by Sourav for Overcast uninstall                
                ZCSNCREATEUPDATE response;
                
                if(Test.isRunningTest()){  
                    response = fakeOvercastServiceCalllout();
                }
                else{   
                    //response  = request.run(logger,null);//Commented by Sourav for Overcast uninstall
                }
                if(response!=null){   //Added for IBA-1223 by Sourav
                        system.debug('Response ' + response.serialize()); 
                        if (response.RETURN_x != null && response.RETURN_x.size() > 0 ){
                            
                            // could be multiple messages
                            for (ZCSNCREATEUPDATE.RETURN_x rm : response.RETURN_x) {
             
                                string type_X = rm.TYPE_x;
                                System.debug('Type X ' + type_X);
                                
                                if(type_X != 'S' && type_x != '') { 
                                    // revert values to old if they exist
                                    if(oldsalesOrg != ''){
                                        rec = oldSO;
                                        update rec;
                                    }
                                    AccountErrorLog.Log('Sales Organization failed to Insert/Update', rec.Id);                               
                                }
                                else {
                                    system.debug('Sales Org Updated');
                                }
                            }
                        }
                        else {system.debug('No Response returned ');}
                }
            }
            catch (Exception exc){
                ErrorLogging.Log(exc,'SalesOrgCreateController: Overcast Callout Failure','Integration');
                System.debug('Overcast Sales Org Failure: ' + exc.getMessage());                 
            }
        } 
        catch (Exception ex){            
            ErrorLogging.Log(ex,'SalesOrgCreateController: Overcast General Failure','Integration');
            System.debug('Overcast Failure: ' + ex.getMessage());          
        }
        finally{
            isTriggerExecuting = false;
        }

    }  
    // mock future call
    @testVisible
    static ZCSNCREATEUPDATE fakeOvercastServiceCalllout(){
        
        // Create a fake response
        ZCSNCREATEUPDATE z = new ZCSNCREATEUPDATE();     
        list<ZCSNCREATEUPDATE.RETURN_x> xlist = new list<ZCSNCREATEUPDATE.RETURN_x>();
        
        ZCSNCREATEUPDATE.RETURN_x zr = new ZCSNCREATEUPDATE.RETURN_x();
        zr.MESSAGE = 'Sales Org created successfully.';
        zr.TYPE_x = 'S';
        xlist.Add(zr);
        
        z.RETURN_x = xlist;
        return z;
    } 
}