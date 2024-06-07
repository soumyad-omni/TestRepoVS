/**
 * @File Name          : NewQuoteCreateLayoutController.cls
 * @Description        : 
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 7/1/2020, 1:44:21 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/29/2020       Initial Version
**/
public with sharing class NewQuoteCreateLayoutController {
    Quote quote{get;set;} 
    public boolean statusrender {get;set;}
    public boolean showlease {get;set;}
    public Account shipto {get;set;}
    public String shiptoId {get;set;}
    public String conId {get;set;}
    public String conname {get;set;}
    public String dealDeskuserid {get;set;}
    public String dealDeskuserName {get;set;}
    public String clinicalconsultantid {get;set;}
    public String clinicalconsultantName {get;set;}
    public String salesconsultantid {get;set;}
    public String salesconsultantName {get;set;}
    public String shiptoId2{get;set;}
    public String shiptoName {get;set;}
    public String shiptoAddress {get;set;}
    public Boolean overrideshipto {get;set;}
    public Account billto {get;set;}
    public boolean renderSec{get;set;}
    public String billtoId {get;set;}
    public String billtoName {get;set;}
    public String billtoAddress {get;set;}
    public Boolean overridebillto {get;set;}
    public Account payer {get;set;}
    public String payerId {get;set;}
    public String payerName {get;set;}
    public String payerAddress {get;set;}
    public Account gpo {get;set;}
    public String gpoId {get;set;}
    public String gpoName {get;set;}
    public Account idn {get;set;}
    public String idnId {get;set;}
    public String idnName {get;set;}
    public Boolean overridepayer {get;set;}
    public String ssoName {get;set;}
    public boolean error = false;
    public String errormsg;
    public String selectedSalesOrgID {get;set;}
    public String accountName {get;set;}
    public String accountAddress {get;set;}
    String Sales_Org;
    String billingCountry;
    String defaultgpo;
    public String lostOppError;
    public String payerError;
    public String billToError;
    public String shipToError;
    public String invalidAcctError;
    public String cls1 {get; set;} //1678
    public String cls2 {get; set;} //1678
    public boolean acountDisabled {get;set;} 	//IBA-2374
    public boolean contactroleshipping {get;set;} //IBA-3824
    //Remove for IBA-4189
    public string contRoleError; //IBA-3824
    //Remove for IBA-4189
    List<Relationship__c> relationRecordsgpo = new List<Relationship__c>();
    List<Relationship__c> relationRecordsidn = new List<Relationship__c>();
    List<SObject> records=new List<SObject>();
    public String accid = ApexPages.currentPage().getParameters().get('accid');
    public String oppid = ApexPages.currentPage().getParameters().get('oppid');
    public NewQuoteCreateLayoutController(ApexPages.StandardController controller){
        acountDisabled=false;
        contactroleshipping = false; //IBA-3824
        Opportunity oppRecord = [Select Id,RecordType.DeveloperName from Opportunity where Id =: oppId]; //IBA-1678
        //if(oppRecord.RecordType.Name == 'U.S & Canada Opportunity') { //IBA-1678
        if(oppRecord.RecordType.DeveloperName =='NAA_Opportunity' || oppRecord.RecordType.DeveloperName == 'US_Canada_Advanced_Services' || oppRecord.RecordType.DeveloperName == 'US_Canada_Specialty'){ 	//IBA-5992
            cls1 = 'requiredInput';
            cls2 = 'requiredBlock';
        }
        //IBA-3824 Starts
        OpportunityContactRole[] contRoleRec = [Select ContactId, Role from OpportunityContactRole where OpportunityId =: oppId And Role = 'S-Shipping Contact'];
        if(contRoleRec.size() == 0){
            contactroleshipping = true;
        }
        contRoleError=System.Label.No_Contact_Role;
        //If(oppRecord.RecordType.Name == 'U.S & Canada Opportunity' && contactroleshipping == true){
        if((oppRecord.RecordType.DeveloperName == 'NAA_Opportunity' || oppRecord.RecordType.DeveloperName == 'US_Canada_Advanced_Services' || oppRecord.RecordType.DeveloperName == 'US_Canada_Specialty') 	//IBA-5992   
            && contactroleshipping == true){
            ApexPages.Message pgMsg = setPageMessageForNoContactRole();
            ApexPages.addMessage(pgMsg);
            acountDisabled=true; //IBA-3824 change  Save Button disabled
        }
        //IBA-3824 Ends
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName == Label.Booking_Team || profileName == Label.DealDesk_Legal || profileName == Label.Business_Admin || profileName == Label.System_Admin)
            statusrender = true;
        else
            statusrender = false;
        
         Set<Id> territoryIds = new  Set<Id>();
         Account accnt = [Select Id, Territory_Name__c,RecordTypeId,IsValidated__c from account where id =:accid];
       	//IBA-2374 Pabitra
       	invalidAcctError=System.Label.INVALID_ACCOUNT_ERROR;
        if(!accnt.IsValidated__c)	
        	{
                ApexPages.Message pgMsg = setPageMessageForBlankSalesOrg();
                ApexPages.addMessage(pgMsg);
                acountDisabled=true;
                 return;
        	} //IBA-2374
         for(ObjectTerritory2Association ota:[Select ObjectId, Territory2Id, Territory2.Territory2Type.Priority from ObjectTerritory2Association
                                              where objectId =:accid]){           
            if(!territoryIds.contains(ota.Territory2Id))
            {
                territoryIds.add(ota.Territory2Id);
            }          
        }
        
        List<UserTerritory2Association> actmdealdesk = new List<UserTerritory2Association>();
       
        String territoryName = accnt.Territory_Name__c;
        actmdealdesk = [select user.Name,RoleInTerritory2,userid from UserTerritory2Association where territory2Id in:territoryIds and RoleInTerritory2 = 'Deal Desk' LIMIT 1];
        System.debug('Deal Desk : '+actmdealdesk);
        if(actmdealdesk.size()>0){
            dealDeskuserid = actmdealdesk[0].userid;
            dealDeskuserName = actmdealdesk[0].user.Name;
        }
        List<UserTerritory2Association> actmpharmacy = new List<UserTerritory2Association>();
        
        actmpharmacy = [select user.Name,RoleInTerritory2,userid from UserTerritory2Association where territory2Id in:territoryIds and RoleInTerritory2 = 'Pharmacy Consultant' LIMIT 1];
        //IBA-1678
        //if(oppRecord.RecordType.Name != 'U.S & Canada Opportunity') {
        if(oppRecord.RecordType.DeveloperName != 'NAA_Opportunity' && oppRecord.RecordType.DeveloperName != 'US_Canada_Advanced_Services' && oppRecord.RecordType.DeveloperName != 'US_Canada_Specialty'){ 	//IBA-5992

                if(actmpharmacy.size()>0){
                    clinicalconsultantid = actmpharmacy[0].userid;
                    clinicalconsultantName = actmpharmacy[0].user.Name;   
                }
        }
        List<UserTerritory2Association> actminsidesales = new List<UserTerritory2Association>();
        List<UserTerritory2Association> actmsalesconsultant = new List<UserTerritory2Association>();
        List<UserTerritory2Association> nacActmSalesConsultant = new List<UserTerritory2Association>();
        actminsidesales = [select user.Name,RoleInTerritory2,userid from UserTerritory2Association where territory2Id in:territoryIds and RoleInTerritory2 = 'Inside Sales Rep' LIMIT 1];
        actmsalesconsultant = [select user.Name,RoleInTerritory2,userid from UserTerritory2Association where territory2Id in:territoryIds and RoleInTerritory2 = 'Sales Consultant' LIMIT 1];
        nacActmSalesConsultant = [select user.Name,RoleInTerritory2,userid from UserTerritory2Association where territory2Id in:territoryIds and RoleInTerritory2 = 'NAC Sales Associate' LIMIT 1];
        
        if(accnt.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId()){
            if(nacActmSalesConsultant.size()>0){
                salesconsultantid = nacActmSalesConsultant[0].userid;
                salesconsultantName = nacActmSalesConsultant[0].user.Name;
            }
            else if(actmsalesconsultant.size()>0){
                salesconsultantid = actmsalesconsultant[0].userid;
                salesconsultantName = actmsalesconsultant[0].user.Name;
            }
            
        }
        else if(accnt.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Customer').getRecordTypeId()){
            if(actminsidesales.size()>0){
                salesconsultantid = actminsidesales[0].userid;   
                salesconsultantName = actminsidesales[0].user.Name;
            }
        }  
        relationRecordsgpo = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='ZG'];
        System.debug('relationRecords : '+relationRecordsgpo);
        Account recordsgpo;
        if(relationRecordsgpo.size()>0){
          if(String.valueOf(relationRecordsgpo[0].Secondary_Account__c) == null || String.valueOf(relationRecordsgpo[0].Secondary_Account__c) == '')
           {
                 ApexPages.Message pgMsg = setPageMessageForSecondaryAccount();
                 ApexPages.addMessage(pgMsg);
                 return;
           }
            recordsgpo=[Select Name,id,billingState,BillingStreet,BillingCity,BillingPostalCode,BillingCountry from Account where id =:relationRecordsgpo[0].Secondary_Account__c];
            gpoId = recordsgpo.Id;
            gpoName = recordsgpo.Name;
        }
        relationRecordsidn = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='ZI'];
        List<Account> recordsidn = new List<Account>(); //SF-BUG-672
        if(relationRecordsidn.size()>0){
           if(String.valueOf(relationRecordsidn[0].Secondary_Account__c) == null || String.valueOf(relationRecordsidn[0].Secondary_Account__c) == '')
           {
                 ApexPages.Message pageMsg = setPageMessageForSecondaryAccount();
                 ApexPages.addMessage(pageMsg);
                 return;
           }
            recordsidn=[Select Name,id,billingState,BillingStreet,BillingCity,BillingPostalCode,BillingCountry from Account where id =:relationRecordsidn[0].Secondary_Account__c];
            if(recordsidn.size()>0)   //Added this condition by Sourav SF-BUG-672
            {
            	idnId = recordsidn[0].Id;
            	idnName = recordsidn[0].Name;
            }
        }
        lostOppError = System.Label.Lost_Opportunity_Error;
        this.quote = (Quote)controller.getRecord();
        quote.opportunityId = oppid;
        quote.Service_Duration__c = 12;
        quote.From__c = System.today();
        quote.ExpirationDate = System.today().addDays(90);
        //SF-BUG-1083 fix
        Opportunity opp = [select OppStatus__c,stageName,CurrencyIsoCode,owner.Managerid,ownerid,name from opportunity where id=:oppid];
         quote.name = opp.name;
        List<Quote> primarychecklist = [select id from Quote where opportunityid =:oppid];
        if(primarychecklist.size()>0){
            quote.Primary_Quote__c = false;
        }
        else
            quote.Primary_Quote__c = true;
        if(opp.OppStatus__c == 'Lost'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,lostOppError);
            ApexPages.addMessage(myMsg);
        }
        quote.SSM_RD__c = opp.owner.Managerid;
        quote.Opportunity_Owner__c = opp.OwnerId;
        //default to the first sales org and load those associated values
        selectedSalesOrgId='';
        List<SAP_Sales_Org__c> so = new List<SAP_Sales_Org__c>();
        so = [select Sales_Org__c,Terms_of_Payment__c,Pricing_Date__c,Shipping_Conditions__c,Incoterms_1__c,Incoterms_2__c,CurrencyIsoCode,Id,Service_Level__c,
              Default_GPO_Price_List__c,Default_IDN_Price_List__c from SAP_Sales_Org__c
              where Account__c=:accid];  
      
        if (so.size()>0) {
            //quote.Sales_Org__c = so[0].sales_org__c;
            Sales_Org = so[0].Sales_Org__c;
            
            quote.SAP_Sales_Org__c=so[0].id;
            quote.Incoterms_2__c = so[0].Incoterms_2__c;
            quote.Incoterms_1__c=so[0].Incoterms_1__c;
            quote.Terms_of_Payment__c=so[0].Terms_of_Payment__c;
            quote.Shipping_Conditions__c = so[0].Shipping_Conditions__c;
            quote.GPO_Price_Lists__c=so[0].Default_GPO_Price_List__c;
            defaultgpo = so[0].Default_GPO_Price_List__c;
            quote.IDN_Price_List__c=so[0].Default_IDN_Price_List__c;
            quote.Service_Level__c = so[0].Service_Level__c;
            quote.Currency__c = so[0].CurrencyIsoCode;
            quote.CurrencyIsoCode = so[0].CurrencyIsoCode;
            if(so[0].Pricing_Date__c != null)
                quote.Pricing_Reference_Date__c = so[0].Pricing_Date__c;
            else
                quote.Pricing_Reference_Date__c = System.today();
        }  
        //get account fields
        Account acc = [select name,id,Shipping_Instructions__c, BillingStreet, BillingCity,
                       BillingState, BillingPostalCode, BillingCountry,Master_Agreement__c from Account where id=:accid];
        billingcountry = acc.BillingCountry;
        shiptoid = accid;
        shiptoName = acc.Name;
        billtoid = accid;
        billtoname = acc.Name;
        payerid = accid;
        payername = acc.Name;
        quote.Master_Agreement__c = acc.Master_Agreement__c;
        quote.Bill_to_Account__c=accid;
        quote.Ship_to_Account__c=accid;
        quote.Payer__c=accid;
        accountName = acc.name;
        accountAddress = acc.BillingStreet+' '+acc.BillingCity+', '+acc.BillingState+' '+acc.BillingPostalCode;
        billtoAddress=accountAddress;
        shiptoAddress=accountAddress;
        payerAddress=accountAddress;
        quote.Shipping_Instructions__c = acc.Shipping_Instructions__c;
        overrideshipto=true;
        overridebillto=true;
        overridepayer=true;
        
        List<Contact> conts = [select id,Name from contact where accountid=:accid and SAP_Contact_Id__c != null];
        //if(conts.size() == 1 && oppRecord.RecordType.Name != 'U.S & Canada Opportunity'){ //IBA-3824
        if(conts.size() == 1 && oppRecord.RecordType.DeveloperName != 'NAA_Opportunity'  && oppRecord.RecordType.DeveloperName != 'US_Canada_Advanced_Services'  && oppRecord.RecordType.DeveloperName != 'US_Canada_Specialty'){ 	//IBA-5992
            conId = conts[0].id;
            conname = conts[0].Name;
            quote.Shipping_Contact__c = conts[0].id;
        }
        //IBA-3824 Start
        List<OpportunityContactRole> oppContRole = [SELECT ContactId, Role,Contact.Name FROM OpportunityContactRole WHERE OpportunityId =: oppId AND Role = 'S-Shipping Contact'];
        //if(oppContRole.size() == 1 && oppRecord.RecordType.Name == 'U.S & Canada Opportunity'){
        if(oppContRole.size() == 1 && (oppRecord.RecordType.DeveloperName == 'NAA_Opportunity' || oppRecord.RecordType.DeveloperName =='US_Canada_Advanced_Services' || oppRecord.RecordType.DeveloperName == 'US_Canada_Specialty')){ 	//IBA-5992
            conId = oppContRole[0].ContactId;
            conname = oppContRole[0].contact.Name;
            quote.Shipping_Contact__c = oppContRole[0].ContactId;
        }
        //IBA-3824 End
    }
    Public pagereference updateSalesOrg(){
        
        if(quote.Sales_Org__c!=null){
        List<SAP_Sales_Org__c> slist = [select id from SAP_Sales_Org__c where sales_org__c =: quote.Sales_Org__c and account__c=:accid];
        selectedSalesOrgId = slist[0].id;
        List<SAP_Sales_Org__c> so = new List<SAP_Sales_Org__c>();    
        so = [select Sales_Org__c,Terms_of_Payment__c,Shipping_Conditions__c,Incoterms_1__c,Incoterms_2__c,CurrencyIsoCode,Id,Service_Level__c,
              Default_GPO_Price_List__c,Default_IDN_Price_List__c,Pricing_Date__c from SAP_Sales_Org__c
              where id=:selectedSalesOrgID];                                 
        if (so.size()>0) {
            quote.SAP_Sales_Org__c = so[0].id;
            quote.sales_org__c = so[0].sales_org__c;
            Sales_org = so[0].sales_org__c;    
            quote.Incoterms_1__c=so[0].Incoterms_1__c;
            quote.Incoterms_2__c = so[0].Incoterms_2__c;
            quote.Terms_of_Payment__c=so[0].Terms_of_Payment__c;
            quote.Shipping_Conditions__c = so[0].Shipping_Conditions__c;
            quote.GPO_Price_Lists__c=so[0].Default_GPO_Price_List__c;
            System.debug('GPO after update : '+quote.GPO_Price_Lists__c);
            defaultgpo = so[0].Default_GPO_Price_List__c; 
            System.debug('Default GPO after update : '+so[0].Default_GPO_Price_List__c);
            quote.IDN_Price_List__c=so[0].Default_IDN_Price_List__c;
            quote.Service_Level__c = so[0].Service_Level__c; 
            quote.Currency__c = so[0].CurrencyIsoCode; 
            quote.CurrencyIsoCode = so[0].CurrencyIsoCode;  
            if(so[0].Pricing_Date__c != null && quote.Order_Type__c != 'ZQRS')
                quote.Pricing_Reference_Date__c = so[0].Pricing_Date__c;
            else
                quote.Pricing_Reference_Date__c = System.today();

                
        }
        }
              
        return null;       
    } 
    //IBA-2432 Pabitra
    public List<SelectOption> getIDNPriceList(){
       	List<SelectOption> idnPriceOptions = new List<SelectOption>();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        Schema.DescribeFieldResult fieldResult = Schema.Quote.IDN_Price_List__c.getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        if(profileName == Label.Booking_Team || profileName == Label.DealDesk_Legal || profileName == Label.Business_Admin || profileName == Label.System_Admin){
	    	for( Schema.PicklistEntry f : ple){
                       idnPriceOptions.add(new SelectOption(f.getValue(),f.getLabel()));
               }    
        }
        else{
	        List<SAP_Sales_Org__c> so = [select Sales_Org__c,Default_IDN_Price_List__c from SAP_Sales_Org__c where Account__c=:accid];  
            Set<String> orgIdnPriceList = new Set<String>();
            for(SAP_Sales_Org__c salesorg : so){
                orgIdnPriceList.add(salesorg.Default_IDN_Price_List__c);
            } 
            
            idnPriceOptions.add(new SelectOption('','None'));
            
            for (String orgDftPrice:orgIdnPriceList) {
             	for( Schema.PicklistEntry f : ple){
                    if(orgDftPrice == f.getValue()){
         	         	idnPriceOptions.add(new SelectOption(f.getValue(),f.getLabel()));
                        break;
                    }
                }
              	}
        }
       return idnPriceOptions; 
    } //IBA-2432
    
    public List<selectOption> getSOS() {
        List<selectOption> options = new List<selectOption>();
        for (SAP_Sales_Org__c so : [SELECT ID, Sales_Org__c FROM SAP_Sales_Org__c WHERE Account__c=:accid])
        {
            Schema.DescribeFieldResult F = SAP_Sales_Org__c.Sales_Org__c.getDescribe();
            List<Schema.PicklistEntry> P = F.getPicklistValues();
            for(Schema.PicklistEntry pe : p){
                if(pe.getValue() == so.sales_org__c){
                    options.add(new selectOption(so.Sales_Org__c, pe.getLabel() ));
                }
            }
            
            
        }
        return options;
    }   
    //Praneeth added this method for SF bug 51 fix for getting sibling gpo values on quote
    public List<selectOption> getpricelists() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption( '','--None--' ));
        List< SAP_Sales_Org__c> lstSAPSalesOrg = [select id, name, Default_GPO_Price_List__c from SAP_Sales_Org__c where Account__c =:accid];
        List<String> lstString = new List<String>();
        for(SAP_Sales_Org__c objSAP : lstSAPSalesOrg){
            System.debug('**** objSAP ' + objSAP);
            lstString.add(objSAP.Default_GPO_Price_List__c);
        }
        System.debug('**** lstString ' + lstString);
        List< Pricelist_Selection_custom__mdt > lstPricelistSel = [select id, Key__c, DeveloperName, MasterLabel , GPO_CSN__c   from Pricelist_Selection_custom__mdt where DeveloperName  IN : lstString];
        List<String> lstGPO = new List<String>();
        for(Pricelist_Selection_custom__mdt objPS : lstPricelistSel){
            lstGPO.add(objPS.Key__c);
        }
        System.debug('**** lstGPO ' + lstGPO);
        List< Pricelist_Selection_custom__mdt > lstPricelistSelGPO = [select id, DeveloperName, MasterLabel , GPO_CSN__c   from Pricelist_Selection_custom__mdt where Key__c IN : lstGPO];
        for(Pricelist_Selection_custom__mdt objPS : lstPricelistSelGPO){
            options.add(new selectOption( objPS.DeveloperName, objPS.MasterLabel   ));
        }
        
        System.debug('options : '+options);
        return options;
    } 
    //Praneeth changed the old method from getpricelists to getpricelists_Old for sf bug 51
    public List<selectOption> getpricelists_Old() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption( '--None--','--None--' ));
        List< SAP_Sales_Org__c> lstSAPSalesOrg = [select id, name, Default_GPO_Price_List__c from SAP_Sales_Org__c where Account__c =:accid];
        List<String> lstString = new List<String>();
        for(SAP_Sales_Org__c objSAP : lstSAPSalesOrg){
            lstString.add(objSAP.Default_GPO_Price_List__c);
        }
        
        List< Pricelist_Selection__c > lstPricelistSel = [select id, name, Pricelist_API_Name__c, GPO_CSN__c   from Pricelist_Selection__c where Pricelist_API_Name__c IN : lstString];
        List<String> lstGPO = new List<String>();
        for(Pricelist_Selection__c objPS : lstPricelistSel){
            lstGPO.add(objPS.GPO_CSN__c);
        }
        
        List< Pricelist_Selection__c > lstPricelistSelGPO = [select id, name, Pricelist_Name__c , Pricelist_API_Name__c , GPO_CSN__c   from Pricelist_Selection__c where GPO_CSN__c IN : lstGPO];
        for(Pricelist_Selection__c objPS : lstPricelistSelGPO){
            options.add(new selectOption( objPS.Pricelist_API_Name__c, objPS.Pricelist_Name__c   ));
        }
        /*List<Id> sac = new List<Id>();
        List<Pricelist_Selection__c> ps = new List<Pricelist_Selection__c>();
        List<String> pn = new List<String>();
        List<String> papi = new List<String>();
        List<Relationship__c> rel = [select id,Secondary_Account__c from Relationship__c where relationship__c = 'ZG' and primary_account__c =:accid];
        List<String> sapids = new List<String>();
        System.debug('Rel : '+rel);
        if(rel.size()>0){
            for(Relationship__c r : rel){
                sac.add(r.Secondary_Account__c);
            }
        }
        System.debug('Secondary Accounts : '+sac);
        if(sac.size()>0){
            for(Id acId : sac){
                Account sapId = [select SAP_Account_ID__c from Account where id =:acId];
                sapids.add(sapId.SAP_Account_ID__c);
            }        
        }
        System.debug('Sap Ids : '+sapids);
        System.debug('Sales_Org : '+Sales_Org);
        System.debug('Billing Country : '+billingcountry);
        Schema.DescribeFieldResult F = SAP_Sales_Org__c.Default_GPO_Price_List__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        system.debug('P..'+P);
        /*ECC_Sales_Org_to_CRM__c csValue4 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell - St.Petes');
        String salesorgapi = csValue4.CRM_Code__c;
        System.debug('Sales Org Api : '+salesorgapi);
        /////
        ECC_Sales_Org_to_CRM__c csValue4 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell - St.Petes');
        String salesorgapi = csValue4.ECC_Code__c;
        System.debug('Sales Org Api : '+salesorgapi);
        ECC_Sales_Org_to_CRM__c csValue5 = ECC_Sales_Org_to_CRM__c.getInstance('GPOPricelist-None');
        String gpopricelist = csValue5.GPOPricelist__c;
        System.debug('gpopricelist : '+gpopricelist);
        
        
        if(Sales_org == salesorgapi && billingcountry != 'Canada'){
            for(Pricelist_Selection__c psc : [select Pricelist_Name__c,Pricelist_API_Name__c from Pricelist_Selection__c where GPO_CSN__c=:sapids or MTS__c=true]){
                
                pn.add(psc.Pricelist_Name__c);
                papi.add(psc.Pricelist_API_Name__c);
            }
        }
        else if(Sales_org == salesorgapi && billingcountry == 'Canada'){
            for(Pricelist_Selection__c psc : [select Pricelist_Name__c,Pricelist_API_Name__c from Pricelist_Selection__c where GPO_CSN__c=:sapids or Canadian__c=true or MTS__c=true]){
                pn.add(psc.Pricelist_Name__c);
                papi.add(psc.Pricelist_API_Name__c);
            }
        }
        else if(Sales_org != salesorgapi && billingcountry == 'Canada'){
            for(Pricelist_Selection__c psc : [select Pricelist_Name__c,Pricelist_API_Name__c from Pricelist_Selection__c where GPO_CSN__c=:sapids or Canadian__c=true]){
                pn.add(psc.Pricelist_Name__c);
                papi.add(psc.Pricelist_API_Name__c);
            }
        }
        else if(Sales_org != salesorgapi && billingcountry != 'Canada'){
            for(Pricelist_Selection__c psc : [select Pricelist_Name__c,Pricelist_API_Name__c from Pricelist_Selection__c where GPO_CSN__c=:sapids ]){
                pn.add(psc.Pricelist_Name__c);
                papi.add(psc.Pricelist_API_Name__c);
            }
        }
        System.debug('PriceList Names : '+Pn);
        
        options.add(new selectOption('' ,'--None--' ));
        
        if(pn.size()>0){
            System.debug('Default GPo : '+defaultgpo);
            for(Schema.PicklistEntry pe : p){
                if(pe.getValue() == gpopricelist){
                  system.debug('pe.getValue()..'+pe.getValue());
                  options.add(new selectOption(pe.getValue(), pe.getLabel() ));
                }
                if(pe.getValue() == defaultgpo){
                    
                    options.add(new selectOption(defaultgpo, pe.getLabel() ));
                    
                }
                
                
            }
            for(String pne : pn){
                Integer i=0;
                
                options.add(new selectOption(papi[i],pne));
                i=i+1;
            }
        }
        else{
            for(Schema.PicklistEntry pe : p){
               if(pe.getValue() == gpopricelist){
               system.debug('pe.getValue()..'+pe.getValue());
                    
                    options.add(new selectOption(pe.getValue(), pe.getLabel() ));
                }
                if(pe.getValue() ==  quote.GPO_Price_Lists__c){
                   
                    system.debug('pe.getValue()..'+pe.getValue()+'quote.GPO_Price_Lists__c : '+quote.GPO_Price_Lists__c);
                    options.add(new selectOption(defaultgpo, pe.getLabel() ));
                    //options.add(new selectOption(gpopricelist ,'--None--' ));
                    //options.add(new selectOption('' ,'--None--' ));
                   }
              }
              
            //options.add(new selectOption(defaultgpo,defaultgpo));
            
        }
        */
       
        System.debug('options : '+options);
        return options;
    }    
    Public String getOppName(){
        Opportunity opp = [select name,id from opportunity where id=:oppid];
        //String oppName = opp.name;
        //System.debug('Opp Name : '+oppName);
        return opp.Name;
    }
     
    public PageReference save(){        
        Opportunity opp = [select OppStatus__c,CurrencyIsoCode from opportunity where id=:oppid];
        if(opp.OppStatus__c == 'Lost'){
            error=true;
            errormsg=lostOppError;
        }
        //on the first quote create, we want to update the opp.CurrencyIsoCode to match this quote.
        opp.CurrencyIsoCode=quote.CurrencyIsoCode;

        
        System.debug('billtoId'+billtoId);
        System.debug('Ship to override : '+overrideshipto);
        
        //Code Added BY JAY - CR-18666
        if(quote.Order_Type__c != 'ZQRS')
        {
           quote.subscription_Months__c = 0;
           quote.Statement_Of_Work__c = '';
           quote.Auton__c = '';
        } 
        else
        {
           quote.GPO_Price_Lists__c= '';  
           quote.IDN_Price_List__c = ''; 
           quote.Milestone_Invoice_Term__c = '00';             
        }
        
        
        
        //End of CR-18666
        
        
        if(shiptoId != '')
            quote.Ship_to_Account__c = shiptoId;
        else
            quote.Ship_to_Account__c = accid;
        if(billtoId != '')
            quote.Bill_to_Account__c = billtoId;
        else
            quote.Bill_to_Account__c = accid;
        if(payerId != '')
            quote.Payer__c = payerId;
        else
            quote.Payer__c = accid;
        if(gpoId != '')
            quote.GPO_Account__c = gpoId;
        if(idnId != '')
            quote.IDN_Account__c = idnId;
        if(dealDeskuserid != '')
            quote.Sales_Operation_Counterpart__c = dealDeskuserid;
        if(clinicalconsultantid != '')
            quote.Consultant__c = clinicalconsultantid;

        if(salesconsultantid != '')
            quote.Sales_Consultant__c = salesconsultantid;
        quote.Supplement_Version__c = 1;
        System.debug('Contact Id : '+conId);
        System.debug('Contact Name : '+conname);
        List<Contact> conList = [select id,Name from Contact where accountid=:accId and SAP_Contact_Id__c != null];
        
        if(conname == '')
            conId = '';
        if(conId != ''){
            System.debug('ConId : '+conId);
            for(Contact c:conList){
                if(c.name == conname && c.Id == conId){//IBA-4681 - Sourav
                    quote.Shipping_Contact__c = c.Id;
                    conid = c.Id;
                }
            }
            Contact c = [select id,email,phone from contact where id=:conId];
            quote.Email = c.Email;
            quote.Phone = c.Phone;
        }
        
            try{
                quote.OpportunityId=oppid;
                //update below code for SF-BUG-672 by sravan on 11 MARCH START
                List<relationship__c> relrecord = [select id,Primary_Account__c,Secondary_Account__c,Relationship__c from Relationship__c where Relationship__c = 'ZI' and Primary_Account__c=:accid];
        List<Id> idnacc = new List<Id>();
        //Remove for IBA-4189
        if(relrecord.size() > 0){
            for(relationship__c r : relrecord){
                idnacc.add(r.Secondary_Account__c);
            }
            List<Account> idndeletedacc = [select id,IsDeleted__c from account where IsDeleted__c = true and id=:idnacc];
            if(idndeletedacc.size()>0){
                ApexPages.Message isdeletederrormsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Account_isdeleted_error);
            	ApexPages.addMessage(isdeletederrormsg);
                return null;
            }
            else{
                    //update opp; // IBA-3929 - Sourav
                if(quote.Primary_Quote__c == true){//Added For IBA-920 by Sourav
                    uncheckoldPrimaryQuote(oppid);
                }
                insert quote;
               
                PageReference pr = new PageReference('/'+quote.id);
                pr.setRedirect(true);
               //Remove for IBA-4189
                return pr;
            }
        }
        else{
                //update opp; // IBA-3929 - Sourav
            	if(quote.Primary_Quote__c == true){//Added For IBA-920 by Sourav
                    uncheckoldPrimaryQuote(oppid);
                }
                insert quote;
               
                PageReference pr = new PageReference('/'+quote.id);
                pr.setRedirect(true);
                //Remove for IBA-4189
                return pr;
                //}
                }
            }
            catch(DMLException e) { 
                ApexPages.addMessages(e); 
                return null; 
            }
        
    }
    public PageReference cancel(){
        PageReference pr = new PageReference('/'+oppid);
        pr.setRedirect(true);
        return pr;
    }
     public void syncServiceDuration() { //Added by tribhuvan on 30th sep'19 for xr2 project line 610 to 612
        quote.Service_Duration__c = quote.subscription_months__c;
    }
   Public pagereference showleaseduration(){
        showlease = false;
        if(quote.Order_Type__c == 'ZQRL' || quote.Order_Type__c == 'ZQR3' || quote.Order_Type__c == 'ZQL3' || quote.Order_Type__c == 'ZQLI'){
            showlease = true;
            quote.Lease_Duration__c = 60;
            quote.Service_Duration__c = 60;
        }
        else if(quote.Order_Type__c == 'ZQR')
        {
            quote.Service_Duration__c = 12;
            quote.Lease_Duration__c = 0; //Added by bharath mulpuri on June 25th 2020 for Bug sf-bug-653
        } else if(quote.Order_Type__c == 'ZQRS') //Added by tribhuvan on 30th sep'19 for xr2 project line 622 to 626
        {
            quote.subscription_months__c = null; // Initialized with null as part of IBA-3688
            quote.Service_Duration__c = 84;
            quote.Lease_Duration__c = 0; //Added by bharath mulpuri on June 25th 2020 for Bug sf-bug-653
            quote.Resident_Operator_Duration__c = null; //Pavan Palla -- Initialized with null as part of IBA-3688
        }
       	 else if(quote.Order_Type__c == 'ZQD')//Added by Sourav for IBA-1484
        {
            quote.Service_Duration__c = 12;
            quote.Lease_Duration__c = 0;
        }
        quote.Professional_services_duration__c = 12; //soumya 965
        
        updateSalesOrg(); //Added by JAY for CR-18666
        
        return null;
    }
    public PageReference updateshipto(){
        shiptoId2 = shiptoId;
        System.debug('Shipto Id Change : '+shiptoId2);
        return null;
    }
    public String getoppOwner(){
        Opportunity opp = [select OppStatus__c,stageName,owner.Manager.Name,ownerid from opportunity where id=:oppid];
        return opp.owner.Manager.Name;
    }
    public Integer getShiptocount(){
        List<Relationship__c> relationRecords = new List<Relationship__c>();
        relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='WE'];
        return relationRecords.size();      
    }
    public Integer getBilltocount(){
        List<Relationship__c> relationRecords = new List<Relationship__c>();
        relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='RE'];
        return relationRecords.size();      
    }
    public Integer getPayercount(){
        List<Relationship__c> relationRecords = new List<Relationship__c>();
        relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='RG'];
        return relationRecords.size();      
    }
    public Integer getGpocount(){
        List<Relationship__c> relationRecords = new List<Relationship__c>();
        relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='ZG'];
        return relationRecords.size();      
    }
    public Integer getIdncount(){
        List<Relationship__c> relationRecords = new List<Relationship__c>();
        relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='ZI'];
        return relationRecords.size();      
    }
    public Integer getDealDeskcount(){
        return 0;
    }
    public Integer getClinicalConsultantcount(){
        return 0;
    }
    public Integer getSalesConsultantcount(){
        return 0;
    }
    
    public ApexPages.Message setPageMessageForSecondaryAccount()
    {
       ApexPages.Message pageMsg= new ApexPages.Message(ApexPages.Severity.ERROR,'Secondary account should be populated for relationship');
       return pageMsg;
    }
    //IBA-2374 Pabitra
     public ApexPages.Message setPageMessageForBlankSalesOrg()
    {
       ApexPages.Message pageMsg= new ApexPages.Message(ApexPages.Severity.ERROR,invalidAcctError);
       return pageMsg;
    }//END IBA-2374
    //Start IBA-3824
    public ApexPages.Message setPageMessageForNoContactRole(){
        ApexPages.Message pageMsg= new ApexPages.Message(ApexPages.Severity.ERROR,contRoleError);
       return pageMsg;
    }//End IBA-3824
    public void uncheckoldPrimaryQuote(Id oppId){//Added For IBA-920 by Sourav
        List<Quote> primaryQuote = new List<Quote>();
        primaryQuote = [Select id,Primary_Quote__c From Quote Where OpportunityId = :oppId AND Primary_Quote__c =true];
    	if(primaryQuote.size()>0){
			primaryQuote[0].Primary_Quote__c = false;  
            update primaryQuote[0];
        }
    }
    
}