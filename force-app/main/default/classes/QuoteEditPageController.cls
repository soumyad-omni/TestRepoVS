public with sharing class QuoteEditPageController {
    public Quote quote{get;set;} 
    public String gposelecteddef{get;set;}
    public String orderValueSelected{get;set;} //Added for CR-18666 BY JAY
    public String idnselecteddef{get;set;} /* Added for SF-BUG-684 */    
    public boolean rendermessages{get;set;}
    public boolean statusrender {get;set;}
    public boolean statusout {get;set;}
    public boolean showlease {get;set;}
    public boolean showordertype{get;set;}
    public Account shipto {get;set;}
    public String shiptoId {get;set;}
    public String shiptoName {get;set;}
    public String conId {get;set;}
    public String conname {get;set;}
    public String dealDeskuserid {get;set;}
    public String dealDeskuserName {get;set;}
    public String clinicalconsultantid {get;set;}
    public String clinicalconsultantName {get;set;}
    public String salesconsultantid {get;set;}
    public String salesconsultantName {get;set;}
    public Boolean refreshPage {get;set;}
    public String shiptoAddress {get;set;}
    public Boolean overrideshipto {get;set;}
    public Account billto {get;set;}
    public PickListEntry billtoPick {get;set;}
    public String billtoId {get;set;}
    public String billtoName {get;set;}
    public String billtoAddress {get;set;}
    public Boolean overridebillto {get;set;}
    public Account payer {get;set;}
    public String payerId {get;set;}
    public String payerName {get;set;}
    public String payerAddress {get;set;}
    public Boolean overridepayer {get;set;}
    public Account gpo {get;set;}
    public String gpoId {get;set;}
    public String gpoName {get;set;}
    public String gpoAddress {get;set;}
    public Boolean overridegpo {get;set;}
    public Account idn {get;set;}
    public String idnId {get;set;}
    public String idnName {get;set;}
    public String idnAddress {get;set;}
    public Boolean overrideidn {get;set;}
    public Opportunity opp {get;set;}
    public String quotegpo {get;set;}
    public String OriginalOrderType {get;set;}
    //public String ssoId {get;set;}
    public String ssoName {get;set;}
    public Boolean PrimaryQuote {get; set;}
    public boolean error = false;
    public String errormsg;
    public String selectedSalesOrgID {get;set;}
    public String accountName {get;set;}
    public String accountAddress {get;set;}
    public String selectedstatus;
    String Sales_Org;
    String billingCountry;
    String defaultgpo;
    String selectedGpo;
    String selectedIdn; /* Added for SF-BUG-684*/
    public string accountid{get;set;}
    public String quoteid = ApexPages.currentPage().getParameters().get('Id');
    public String accid;  
    public String oppid;
    public boolean IsFromEditPage{get;set;}
    Id profileId=userinfo.getProfileId();
    public Boolean disabl {get;set;}
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    public boolean renderSalesmessages{get;set;}
    public Boolean changeDate = false; //Added for SF-BUG-830
    //Remove for IBA-4189
    public List<SelectOption> PicklistOptions { get; set; } //IBA-3886
    //Remove for IBA-4189   
    
    //String sapsalesorgid{get;set;}
    //System.debug('Sap Sales Org Id : '+sapsalesorgid);
    //public String accid = ApexPages.currentPage().getParameters().get('accid');
    // public String oppid = ApexPages.currentPage().getParameters().get('oppid');
    public QuoteEditPageController(ApexPages.StandardController controller){
        Quote q = [select Incoterms_1__c,Incoterms_2__c,Terms_of_Payment__c,Pricing_Reference_Date__c,Shipping_Conditions__c,
                   IDN_Price_List__c,GPO_Price_Lists__c,SAP_Sales_Org__c,accountid,Shipping_Contact__c,
                   Sales_Operation_Counterpart__c,Consultant__c,Sales_Consultant__c,opportunityid,Ship_to_Account__c,
                   Bill_to_Account__c,Payer__c,GPO_Account__c,IDN_Account__c,Status from Quote where id=:quoteid];
        accid = q.AccountId;
        oppid = q.OpportunityId;
        //start IBA-3298
        renderSalesmessages = true;
        if((profileName == 'Sales Development' || profileName == 'Sales Manager') && (q.Status == 'E0013'||q.Status == 'E0014')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Sales Manager,Sales Development cannot edit Booked quote');
            ApexPages.addMessage(myMsg);
            renderSalesmessages = false;
        }//end IBA-3298
        
        this.quote = (Quote)controller.getRecord();
        System.debug('Profile : '+profileName);
        //if(quote.Status != Label.Quote_status_open_for_edit_page){
        // Pavan K. Offline Build Jira # IBA-1270, Date Modified - Nov 05, 2020
        // Lines added: 88,89,90,92 and 94.        
        List<PermissionSet> offlineBuildRequestPermissions = [Select Id,Name,(SELECT AssigneeId FROM Assignments Where AssigneeId = :UserInfo.getUserId()) From PermissionSet Where Name = 'OfflineBuildRequestManager' OR Name = 'OfflineBuildRequestUser'];
        Boolean quoteStatusEditable = false;
        for(PermissionSet permissionSet : offlineBuildRequestPermissions){
            if(permissionSet.Assignments != null) quoteStatusEditable = true;
        }        
        
        if(quoteStatusEditable || profileName == Label.Booking_Team || profileName == Label.DealDesk_Legal || profileName == Label.Business_Admin || profileName == Label.System_Admin || profileName == Label.International_Sales_Ops)
        {   
            System.debug('Inside if profile deal desk, statue open check');
            statusrender = true;
            statusout = false;
        }else{
            System.debug('Inside else profile deal desk, statue open check');
            statusrender = false;
            statusout = true;
        }
        //}
        /*else{
            System.debug('Inside open status chek else if');
            statusrender = true;
            statusout = false;
        }*/
        selectedstatus = quote.Status;
        System.debug('Selected Status : '+selectedstatus);
        refreshPage = false;
        quote.opportunityId = oppid;
        accountid = accid;
        showordertype = true;
        selectedgpo = q.GPO_Price_Lists__c;
        selectedIdn = q.IDN_Price_List__c; /*Added for SF-BUG-684*/
        gposelecteddef = selectedgpo;
        idnselecteddef = selectedIdn;  /*Added for SF-BUG-684*/
        System.debug('selected gpo : '+selectedgpo);
        OriginalOrderType=quote.Order_Type__c;
        
        
        if(quote.Service_Duration__c == null) {
         system.debug('quote.Service_Duration__c ..'+quote.Service_Duration__c );
         quote.Service_Duration__c = 12;
        }
        
        system.debug('selectedgpo...'+selectedgpo);
        List<Quote_Line__c> ql = [select product_code__c from Quote_Line__c where quote__c =:quoteid];
        if(ql.size()>0){
            for(Quote_Line__c qli : ql){
                if(qli.product_code__c == 'Lease Renewal' || qli.product_code__c == 'Equipment_Buyout'){
                    showordertype = false;      
                }
            }
        }
        if(quote.Order_Type__c == 'ZQRL' || quote.Order_Type__c == 'ZQR3' || quote.Order_Type__c == 'ZQL3' || quote.Order_Type__c == 'ZQLI'){
            showlease = true;
            if(quote.Lease_Duration__c == null || quote.Lease_Duration__c == 0){
                quote.Lease_Duration__c = 60;
                quote.Service_Duration__c = 60;
            }
        }
        
        else{
            showlease = false;
            //added this condition since it was blocking editing of
            //quotes which are in approved status
            if(quote.Lease_Duration__c != null) {
                quote.Lease_Duration__c = 0;
            }
        }
        opp = [select CurrencyIsoCode,Id,OppStatus__c from opportunity where id=:oppid];
        //if(opp.OppStatus__c == 'Lost'){
        //  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot create quote on lost opportunity');
        //  ApexPages.addMessage(myMsg);
        //}
        if(q.Ship_to_Account__c != null){
            if(q.Ship_to_Account__c == q.AccountId)
                overrideshipto=true;
            else
                overrideshipto=false;
            System.debug('Quote : '+q);
            shiptoId = q.Ship_to_Account__c;
            System.debug('shiptoId : '+shiptoId);
            List<Account> act = [select id,name from Account where id =:q.Ship_to_Account__c];
            if(act.size()>0)
            shiptoName = act[0].Name;
        }
        
        if(q.Bill_to_Account__c != null){
            if(q.Bill_to_Account__c == q.AccountId)
                overridebillto=true;
            else
                overridebillto=false;
            List<Account> act = [select name from Account where id =:q.Bill_to_Account__c];
            billtoId = q.Bill_to_Account__c;
            if(act.size()>0)
            billtoName = act[0].Name;
        }
        
        if(q.Payer__c != null){
            if(q.Payer__c == q.AccountId)
                overridepayer=true;
            else
                overridepayer=false;
            List<Account> act = [select name from Account where id =:q.Payer__c];
            payerId = q.Payer__c;
            if(act.size()>0)
            payerName = act[0].Name;
        }
        if(q.GPO_Account__c != null){
            if(q.GPO_Account__c == q.AccountId)
                overridegpo=true;
            else
                overridegpo=false;
            List<Account> act = [select name from Account where id =:q.GPO_Account__c];
            gpoId = q.GPO_Account__c;
            if(act.size()>0)
            gpoName = act[0].Name;
        }
        if(q.IDN_Account__c!= null){
            if(q.IDN_Account__c == q.AccountId)
                overrideidn=true;
            else
                overrideidn=false;
            List<Account> act = [select name from Account where id =:q.IDN_Account__c];
            idnId = q.IDN_Account__c;
            if(act.size()>0)
            idnName = act[0].Name;
        }
        if(q.Shipping_Contact__c != null){
            List<Contact> c = [select name from Contact where id=:q.Shipping_Contact__c];
            conId = q.Shipping_Contact__c;
            if(c.size()>0)
            conname=c[0].Name;
        }
        if(q.Sales_Operation_Counterpart__c != null){
            List<User> u = [select Name from User where id=:q.Sales_Operation_Counterpart__c];
            dealDeskuserid = q.Sales_Operation_Counterpart__c;
            if(u.size()>0)
            dealDeskuserName = u[0].Name;
        }
        if(q.Consultant__c != null){
            List<User> u = [select Name from User where id=:q.Consultant__c];
            clinicalconsultantid = q.Consultant__c;
            if(u.size()>0)
            clinicalconsultantName = u[0].Name;
        }
        if(q.Sales_Consultant__c != null){
            List<user> u = [select Name from user where id=:q.Sales_Consultant__c];
            salesconsultantid = q.Sales_Consultant__c;
            if(u.size()>0)
            salesconsultantName = u[0].Name;
        }
        //default to the selected sales org and load those associated values
     List<SAP_Sales_Org__c> so = new List<SAP_Sales_Org__c>();
    so = [select Sales_Org__c,Terms_of_Payment__c,Shipping_Conditions__c,Incoterms_1__c,Id,
                Default_GPO_Price_List__c,Default_IDN_Price_List__c from SAP_Sales_Org__c where id=:q.SAP_Sales_Org__c];  
    
    //defaultgpo = quote.GPO_Price_Lists__c;
    //defaultgpo = q.GPO_Price_Lists__c;
    if(so.size()>0 && so[0].Default_GPO_Price_List__c != null)
        defaultgpo = so[0].Default_GPO_Price_List__c;
    Sales_Org = quote.Sales_Org__c; 

/*
if (so.size()>0) {
    defaultgpo = so[0].Default_GPO_Price_List__c;
    Sales_Org = so[0].Sales_Org__c; 
} 
*/  
      //default to the first sales org and load those associated values  
     /*   selectedSalesOrgID='';
List<SAP_Sales_Org__c> so = new List<SAP_Sales_Org__c>();
so = [select Sales_Org__c,Terms_of_Payment__c,Shipping_Conditions__c,Incoterms_1__c,Id,
Default_GPO_Price_List__c,Default_IDN_Price_List__c from SAP_Sales_Org__c
where Account__c=:accid];  
if (so.size()>0) {
//quote.Sales_Org__c = so[0].sales_org__c;
Sales_Org = so[0].Sales_Org__c;
quote.SAP_Sales_Org__c=so[0].id;
quote.Incoterms_1__c=so[0].Incoterms_1__c;
quote.Terms_of_Payment__c=so[0].Terms_of_Payment__c;
quote.Shipping_Conditions__c = so[0].Shipping_Conditions__c;
quote.GPO_Price_Lists__c=so[0].Default_GPO_Price_List__c;
quotegpo = so[0].Default_GPO_Price_List__c;
quote.IDN_Price_List__c=so[0].Default_IDN_Price_List__c;
} */
//get account fields
Account acc = [select name,id,Shipping_Instructions__c, BillingStreet, BillingCity,
BillingState, BillingPostalCode, BillingCountry from Account where id=:accid];
billingcountry = acc.BillingCountry;
/*quote.Bill_to_Account__c=accid;
quote.Ship_to_Account__c=accid;
quote.Payer__c=accid;*/
accountName = acc.name;
accountAddress = acc.BillingStreet+' '+acc.BillingCity+', '+acc.BillingState+' '+acc.BillingPostalCode;
billtoAddress=accountAddress;
shiptoAddress=accountAddress;
payerAddress=accountAddress;
gpoAddress=accountAddress;
idnAddress=accountAddress;
/*quote.Shipping_Instructions__c = acc.Shipping_Instructions__c;
overrideshipto=true;
overridebillto=true;
overridepayer=true;*/
        
    }
    Public pagereference updateSalesOrg(){
        //selectedSalesOrgId=quote.Sales_Org__c;
        System.debug('Quote : '+quote);
        List<SAP_Sales_Org__c> slist = [select id, CurrencyIsoCode from SAP_Sales_Org__c where sales_org__c =: quote.Sales_Org__c and account__c=:accid and CurrencyIsoCode=:opp.CurrencyIsoCode];
        selectedSalesOrgId = slist[0].id;
        List<SAP_Sales_Org__c> so = new List<SAP_Sales_Org__c>();    
        so = [select Sales_Org__c,Terms_of_Payment__c,Pricing_Date__c,Shipping_Conditions__c,Incoterms_1__c,Id,Incoterms_2__c,CurrencyIsoCode,
              Default_GPO_Price_List__c,Default_IDN_Price_List__c from SAP_Sales_Org__c
              where id=:selectedSalesOrgId];                                 
        if (so.size()>0) {
            //quote.SAP_Sales_Org__c=so[0].id;
            quote.sales_org__c = so[0].sales_org__c;
            quote.SAP_Sales_Org__c = so[0].id;
            /*quote.Incoterms_1__c = selectedinco1;
            quote.Incoterms_2__c = selectedinco2;
            quote.Terms_of_Payment__c = selectedtop;
            quote.Pricing_Reference_Date__c = prrefdate;
        selectedshpcon = quote.Shipping_Conditions__c;
        selectedIdn = quote.IDN_Price_List__c;*/   
            Sales_org = so[0].sales_org__c;    
            //quote.Incoterms_1__c=so[0].Incoterms_1__c;
            //quote.Incoterms_2__c=so[0].Incoterms_2__c;
            //quote.Terms_of_Payment__c=so[0].Terms_of_Payment__c;
            //quote.Shipping_Conditions__c = so[0].Shipping_Conditions__c;
            //quote.GPO_Price_Lists__c=so[0].Default_GPO_Price_List__c;
            defaultgpo = so[0].Default_GPO_Price_List__c; 
            //System.debug('Default GPO after update : '+so[0].Default_GPO_Price_List__c);
            //quote.IDN_Price_List__c=so[0].Default_IDN_Price_List__c; 
            //quote.Currency__c=so[0].CurrencyIsoCode; 
            //quote.CurrencyIsoCode=so[0].CurrencyIsoCode;
            //Added if condition for SF-BUG-830
            if(!changeDate){
                if(so[0].Pricing_Date__c != null)
                    quote.Pricing_Reference_Date__c = so[0].Pricing_Date__c;
                else
                    quote.Pricing_Reference_Date__c = System.today();                
            }

            //selectedSalesOrgID=so[0].id;
        }
        return null;       
    } 
    
    public List<selectOption> getSOS() {
        List<selectOption> options = new List<selectOption>();
        for (SAP_Sales_Org__c so : [SELECT ID, Sales_Org__c FROM SAP_Sales_Org__c WHERE Account__c=:accid and CurrencyIsoCode=:opp.CurrencyIsoCode])
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
    //IBA-3886 Abhrajitc Start
    public List<selectOption> getMilestoneInvoiceTerms() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption( '','--None--' ));
        for (Quote qt : [SELECT ID, Milestone_Invoice_Term__c, Opportunity.RecordType.DeveloperName FROM Quote WHERE id=:quoteid]) {
            //if(qt.Opportunity.RecordType.DeveloperName == 'NAA_Opportunity') {
            if(qt.Opportunity.RecordType.DeveloperName == 'NAA_Opportunity' || qt.Opportunity.RecordType.DeveloperName == 'US_Canada_Advanced_Services' || qt.Opportunity.RecordType.DeveloperName == 'US_Canada_Specialty') { //IBA-5992
                options.add(new SelectOption('00', 'Not Applicable'));
                options.add(new SelectOption('01', '80% on Delivery 20% on install'));
                options.add(new SelectOption('02', '30%Down 40%Delivery 30%Install'));
                options.add(new SelectOption('03', '50% Down 50% on Delivery'));
                options.add(new SelectOption('04', '25% Down 75% on Install'));
                options.add(new SelectOption('05', '60% on Delivery 40% on Install'));
                options.add(new SelectOption('06', '75% on Delivery 25% on Install'));
                options.add(new SelectOption('07', '50%Down 25%Delivery 25%Install'));
                options.add(new SelectOption('08', '70% on Delivery 30% on Install'));
                options.add(new SelectOption('09', '50% Down 50% on Install'));
                options.add(new SelectOption('10', '90% on Delivery 10% on Install'));
                options.add(new SelectOption('11', '50% on Delivery 50% on Install'));
                options.add(new SelectOption('12', '50%Down 30%Delivery 20%Install'));
                options.add(new SelectOption('13', '25%Down 25%Delivery 50%Install'));
                options.add(new SelectOption('14', '100% Down Payment'));
                options.add(new SelectOption('21', '100% on Delivery'));
                options.add(new SelectOption('15', '70% Install 30% Acceptance'));
            } else if(qt.Opportunity.RecordType.DeveloperName == 'International_Opportunity') {
                options.add(new SelectOption('00', 'Not Applicable')); /*IBA-4741 Change*/
                options.add(new SelectOption('21', '100% on Delivery'));
                options.add(new SelectOption('14', '100% Down Payment'));
                options.add(new SelectOption('22', '100% on signed pricing supplement'));
                options.add(new SelectOption('23', '40% PS Signature & 60% Bonding Agreement'));
                options.add(new SelectOption('24', '100% signed Bonding Agreement'));
                options.add(new SelectOption('25', '40% Order 40% Delivery & 20% Acceptance'));
                options.add(new SelectOption('26', '40% Order 40% Pre Delivery & 20% Accept'));
            }
        }
        System.debug('Options for milestone' +options);
        return options;
    }
    //IBA-3886 Abhrajitc Start
    /* Below Function added for SF-BUG-684*/  
    public List<SelectOption> getGPOPriceList(){
  List<selectOption> options = new List<selectOption>();    
  Schema.DescribeFieldResult fieldResult = SAP_Sales_Org__c.Default_GPO_Price_List__c.getDescribe();
  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

  options.add(new selectOption( '','--None--' ));

  List<Quote> quoteList = [SELECT Id, name, Account.Name, Account.GPO_AC__r.name,SAP_Sales_Org__r.name
    FROM Quote
    where id=:quoteid];
    
        for(Quote q : quoteList){
            User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
      System.debug('User Profile : '+u.profile.name);
                
      if ( u.profile.name == 'Deal Desk & Legal' ||
         u.profile.name == 'Booking Team' ||
         u.profile.name == 'Business Administrator' ||
         u.profile.name == 'System Administrator' ||
         u.profile.name == 'International Sales Ops'||
         u.profile.name == 'IT Administrator') //IBA-3710
         {  for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel()));    
          System.debug('options added : '+options);
          }
         }
      else if ( u.profile.name == 'Sales Manager' ||
                   u.profile.name == 'Sales Representative' ||
                   u.profile.name == 'Sales Development' ||
                   u.profile.name == 'International Sales Representative' ||
                   u.profile.name == 'International Sales UK' ||
                   u.profile.name == 'International Sales France'||
                     u.profile.name == 'Revenue') {//IBA-4645  

            if (!String.isBlank(q.Account.GPO_AC__r.name)){
        string GPOAcName = q.Account.GPO_AC__r.name;
        for(GPODetails__c cc: [Select name,pick_name__c from GPODetails__c where name = :GPOAcName ]){
          for( Schema.PicklistEntry f : ple){
          if ( cc.pick_name__c == f.getLabel())
          options.add(new SelectOption(f.getValue(),f.getLabel()));    
          System.debug('options added : '+options);
          } //End for ( Schema.PicklistEntry f : ple)
        }//End for (GPODetails__c..)
      }//if (!String.isBlank(qnw.Account.GPO_AC__r.name))
      
      if (String.isBlank(q.Account.GPO_AC__r.name)){
        String AccountName = q.Account.Name;
        String SAPSalesOrgrName = q.SAP_Sales_Org__r.name;

        System.debug('Quote Name : '+q.name);
        System.debug('Account Name : '+q.Account.Name);
      
        List<Relationship__c> relList = [ select Primary_Account__r.name,Secondary_Account__r.name,Primary_Account_Sales_Org__r.name  
        from Relationship__c where 
        Primary_Account__r.name = :AccountName and
        Relationship__c ='ZG' and 
        Primary_Account_Sales_Org__r.name  = :SAPSalesOrgrName ];

        if(relList.size()>0)  // Matching Record obtained 
        {
           for(Relationship__c rel: relList){
             System.debug('Matching Record found in the GPO Relation of the Parent A/c while checking for Default GPO_Price_Lists' + rel.Primary_Account__r.name + ':' +rel.Secondary_Account__r.name + ':' + rel.Primary_Account_Sales_Org__r.name);
             string GPOAcName = rel.Secondary_Account__r.name;
             
             for(GPODetails__c cc: [Select name,pick_name__c from GPODetails__c where name = :GPOAcName ]){
              for( Schema.PicklistEntry f : ple){
              if ( cc.pick_name__c == f.getLabel())
              options.add(new SelectOption(f.getValue(),f.getLabel()));    
              System.debug('options added : '+options);
              } //End for ( Schema.PicklistEntry f : ple)
             }//End for (GPODetails__c..)
           
           } //for(Relationship__c rel
         
         } //if(relList.size()>0)
      
      }
            
        } //if ( u.profile.name == 'Deal Desk'                                  
  } //for(Quote q : quoteList
      
    System.debug('options added : '+options);
    return options;  
    }
  /* Above Function added for SF-BUG-684*/
  /* Below Function added for SF-BUG-684*/  
  public List<SelectOption> getIDNPriceList(){
  List<selectOption> options = new List<selectOption>();
  Schema.DescribeFieldResult fieldResult = SAP_Sales_Org__c.Default_IDN_Price_List__c.getDescribe();
  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
  options.add(new selectOption( '','--None--' ));

    List<Quote> quoteList = [SELECT Id, name, Account.Name, Account.IDN_Account__r.name,
    SAP_Sales_Org__r.Default_IDN_Price_List__c,SAP_Sales_Org__r.name
    FROM Quote
    where id=:quoteid];
    

    for(Quote q : quoteList){
          User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
      System.debug('User Profile : '+u.profile.name);
                
      if ( u.profile.name == 'Deal Desk & Legal' ||
         u.profile.name == 'Booking Team' ||
         u.profile.name == 'Business Administrator' ||
         u.profile.name == 'System Administrator' ||
         u.profile.name == 'International Sales Ops'||
         u.profile.name == 'IT Administrator') //IBA-3710
         {  for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel()));    
          System.debug('options added : '+options);
          }
         }
      else if ( u.profile.name == 'Sales Manager' ||
                   u.profile.name == 'Sales Representative' ||
                   u.profile.name == 'Sales Development' ||
                   u.profile.name == 'International Sales Representative' ||
                   u.profile.name == 'International Sales UK' ||
                   u.profile.name == 'International Sales France' ||
                     u.profile.name == 'Revenue') {//IBA-4645  
    if (!String.isBlank(q.Account.IDN_Account__r.name)){
            for( Schema.PicklistEntry f : ple){
            if ( q.SAP_Sales_Org__r.Default_IDN_Price_List__c == f.getValue()){
            options.add(new SelectOption(f.getValue(),f.getLabel()));    
            System.debug('options added : '+options);}
            } //End for ( Schema.PicklistEntry f : ple)
    }
    if (String.isBlank(q.Account.IDN_Account__r.name)){
    
        String AccountName = q.Account.Name;
        String SAPSalesOrgrName = q.SAP_Sales_Org__r.name;

        System.debug('Quote Name : '+q.name);
        System.debug('Account Name : '+q.Account.Name);
            
                for( Schema.PicklistEntry f : ple){
                if ( q.SAP_Sales_Org__r.Default_IDN_Price_List__c == f.getValue()){
                options.add(new SelectOption(f.getValue(),f.getLabel()));    
                System.debug('options added : '+options);}
                } //End for ( Schema.PicklistEntry f : ple)
      
        List<Relationship__c> relList = [ select Primary_Account__r.name,Secondary_Account__r.name,Primary_Account_Sales_Org__r.name  
        from Relationship__c where 
        Primary_Account__r.name = :AccountName and
        Relationship__c ='ZI' and 
        Primary_Account_Sales_Org__r.name  = :SAPSalesOrgrName ];

        if(relList.size()>0)  // Matching Record obtained 
        {
           for(Relationship__c rel: relList){
             System.debug('Matching Record found in the GPO Relation of the Parent A/c while checking for Default GPO_Price_Lists' + rel.Primary_Account__r.name + ':' +rel.Secondary_Account__r.name + ':' + rel.Primary_Account_Sales_Org__r.name);
             string GPOAcName = rel.Secondary_Account__r.name;
             
             for( Schema.PicklistEntry f : ple){
                            if (q.SAP_Sales_Org__r.Default_IDN_Price_List__c <> f.getValue()){  
              if ( rel.Secondary_Account__r.name == f.getLabel()){
              options.add(new SelectOption(f.getValue(),f.getLabel()));    
              System.debug('options added : '+options);
              } //End if ( rel.Secondary_Account__r.name
                            } //End if (q.SAP_Sales_Org__r.Default_IDN_Price_List__c   
              } //End for ( Schema.PicklistEntry f : ple)
              
              } //End for(Relationship__c rel
             
             
        }//if(relList.size()>0) 
    } //if (String.isBlank(q.Account.IDN_Account__r.name
      } //if ( u.profile.name == 'Deal Desk'                                  
  } //for(Quote q : quoteList
    
    
    System.debug('options : '+options);
    return options;  
    }
    /* Above Function added for SF-BUG-684*/

    //Praneeth added this method to get data from PriceList_Selection_Custom metadata
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
        List<Pricelist_Selection_custom__mdt> lstPricelistSelGPO = new List<Pricelist_Selection_custom__mdt>();
        if(profileName == Label.DealDesk_Legal || profileName == Label.System_Admin)
        {
            lstPricelistSelGPO = [select id, DeveloperName, MasterLabel , GPO_CSN__c   
                                  From Pricelist_Selection_custom__mdt order by MasterLabel];
        } else {
            lstPricelistSelGPO = [select id, DeveloperName, MasterLabel , GPO_CSN__c   
                                  from Pricelist_Selection_custom__mdt 
                                  where Key__c IN : lstGPO order by MasterLabel];
        }
        for(Pricelist_Selection_custom__mdt objPS : lstPricelistSelGPO){
            options.add(new selectOption( objPS.DeveloperName, objPS.MasterLabel   ));
        }
        
        System.debug('options : '+options);
        return options;
    }      
       
    //Praneeth changed the old method from getpricelists to getpricelists_Old
    /*public List<selectOption> getpricelists_Old() {
        
        List<selectOption> options = new List<selectOption>();
        
        List<Id> sac = new List<Id>();
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
        //ECC_Sales_Org_to_CRM__c csValue4 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell - St.Petes');
        //String salesorgapi = csValue4.CRM_Code__c;
        //System.debug('Sales Org Api : '+salesorgapi);
        
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
        options.add(new selectOption('--None--','--None--'));
        if(pn.size()>0){
            
            System.debug('Select GPo : '+selectedgpo);
            System.debug('Default GPo : '+defaultgpo);
            for(Schema.PicklistEntry pe : p){
              
                
              if(pe.getValue() == selectedgpo){
                    
                    options.add(new selectOption(selectedgpo, pe.getLabel() ));
                }
            }
            for(Schema.PicklistEntry pe : p){
                if(pe.getValue() == defaultgpo){
                 System.debug('DefaultGPO : '+defaultgpo);
                  if(selectedgpo != defaultgpo)
                  {
                    System.debug('selectedgpo123: '+selectedgpo);
                    options.add(new selectOption(defaultgpo, pe.getLabel() ));
                  }
               }
                
            }
            
             
            Integer i=0;
            System.debug('Pn Size : '+pn.size());
            System.debug('papi size : '+papi.size());
            for(String pne : pn){
            
            //string allpapivalue = string.join(papi,',');
            //System.debug('All Papi Value.. : '+allpapivalue);
            
            if(selectedgpo != papi[i])
                 {
                   options.add(new selectOption(papi[i],pne));
                   
                 }
                 i=i+1;
              
            }
            //for(Schema.PicklistEntry pe : p){
              //System.debug('DefaultGPO12 : '+defaultgpo);
                // if(pe.getValue() == gpopricelist){
                  //   if(selectedgpo != gpopricelist){
                    //  System.debug('gpopricelist12: '+gpopricelist); 
                      //options.add(new selectOption(pe.getValue(), pe.getLabel() ));
                    // }
                // }
            //  }
              
      }  
        else{
            System.debug('Select GPo : '+selectedgpo);
            for(Schema.PicklistEntry pe : p){
              //if((defaultgpo != gpopricelist) || pe.getValue() == selectedgpo)
               //{
                //System.debug('DefaultGPO12 : '+defaultgpo);
                 //if(pe.getValue() == gpopricelist){
                   // System.debug('gpopricelist12: '+gpopricelist); 
                    //options.add(new selectOption(pe.getValue(), pe.getLabel() ));
                 //}
                
               //}
              if(pe.getValue() == selectedgpo){
                    //System.debug('Select GPo : '+selectedgpo);
                    options.add(new selectOption(selectedgpo, pe.getLabel() ));
                }  
               
              if(pe.getValue() == defaultgpo && pe.getValue()!= selectedgpo){
                
                    system.debug('pe.getValue()..'+pe.getValue());
                    options.add(new selectOption(defaultgpo, pe.getLabel() ));
                    
                   
                 }
                 
                
             }
             
            //options.add(new selectOption(defaultgpo,defaultgpo));
            //options.add(new selectOption('', '--None--')); 
        } 
      
        System.debug('options : '+options);
        return options;
    }*/    
    Public String getOppName(){
        Opportunity opp = [select name,id from opportunity where id=:oppid];
        //String oppName = opp.name;
        //System.debug('Opp Name : '+oppName);
        return opp.Name;
    }
    /*    
Public String getAccName(){
Account acc = [select name,id,Shipping_Instructions__c from Account where id=:accid];
//String accName = acc.name;
quote.Shipping_Instructions__c = acc.Shipping_Instructions__c;
return acc.Name;
}
*/    
    public PageReference save(){
        disabl = true;
        //System.debug('Sap Sales Org : '+quote.SAP_Sales_Org__c);
        //inputTextErrorMessage='An error occurred';
        // List<Quote> quotes = [select id,Primary_Quote__c from Quote where opportunityid =: oppid and primary_quote__c = true];
        //  if(quotes.size() > 0 && quote.Primary_Quote__c == true){
        /*for(Quote q : quotes){
if(q.Primary_Quote__c == true && quote.Primary_Quote__c == true){
error = true;
errormsg = 'Opportunity must have only one primary quote';
}
}*/
        //    error = true;
        //    errormsg = 'Opportunity must have only one primary quote';
        
        //   }
        
        Opportunity opp = [select OppStatus__c from opportunity where id=:oppid];
        // if(opp.OppStatus__c == 'Lost'){
        //     error=true;
        //     errormsg='Cannot create quote on lost opportunity';
        // }
        System.debug('billtoId'+billtoId);
        System.debug('Ship to override : '+overrideshipto);
        
       /* if(overrideshipto == false){
            if(shiptoId != '')
                quote.Ship_to_Account__c = shiptoId;
            else{
                error=true;
                errormsg = 'Ship to Account Required';
            }
        }
        if(overridebillto == false){    
            if(billtoId != '')
                quote.Bill_to_Account__c = billtoId;
            else{
                error=true;
                errormsg = 'Bill to Account Required';
            }
        }
        if(overridepayer == false){
            if(payerId != '')
                quote.Payer__c = payerId;
            else{
                error=true;
                errormsg = 'Payer Required';
            }
        }
        /*if(ssoId != ''){
SAP_Sales_Org__c sso = [select Sales_Org__c,Terms_of_Payment__c,Shipping_Conditions__c,Incoterms_1__c,Default_GPO_Price_List__c,Default_IDN_Price_List__c from SAP_Sales_Org__c
where id=:ssoId];
quote.Terms_of_Payment__c = sso.Terms_of_Payment__c;
quote.Sales_Org__c = sso.Sales_Org__c;
quote.Shipping_Conditions__c = sso.Shipping_Conditions__c;
quote.Incoterms_1__c = sso.Incoterms_1__c;
quote.GPO_Price_Lists__c = sso.Default_GPO_Price_List__c;
quote.IDN_Price_List__c = sso.Default_IDN_Price_List__c;
quote.SAP_Sales_Org__c = ssoId;

}*/     if(gposelecteddef == '--None--')
            quote.GPO_Price_Lists__c = '';
        else
            quote.GPO_Price_Lists__c = gposelecteddef;
        /*Added below lines for SF-BUG-684 */
        if(idnselecteddef == '--None--')
            quote.IDN_Price_List__c = '';
        else
            quote.IDN_Price_List__c = idnselecteddef;
        /*Added below lines for SF-BUG-684 */
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
       // else
       //     quote.GPO_Account__c = accid;
        if(idnId != '')
                quote.IDN_Account__c = idnId;
       // else
        //    quote.IDN_Account__c = accid;
        if(dealDeskuserid != '')
            quote.Sales_Operation_Counterpart__c = dealDeskuserid;
        if(clinicalconsultantid != '')
            quote.Consultant__c = clinicalconsultantid;
        if(salesconsultantid != '' && salesconsultantName != ''){
            quote.Sales_Consultant__c = salesconsultantid;
            System.debug('Inside Sales Consultant : ');
        }
        else{
            quote.Sales_Consultant__c = null;
            System.debug('Inside Sales consultant else');
        }
        List<Contact> conList = [select id,Name from Contact where accountid=:accId and SAP_Contact_Id__c != null];
        
        if(conname == '')
            conId = '';
        if(conId != ''){
            for(Contact c:conList){
                if(c.name == conname && c.Id == conId){//IBA-4681 - Sourav
                    //quote.ContactId = conId;
                    quote.Shipping_Contact__c = c.Id;
                    conid = c.Id;
                }
            }
            List<Contact> c = [select email,phone from contact where id=:conId limit 1];
            if(c.size()>0){
                if(c[0].Email != null)
                    quote.Email = c[0].Email;
                if(c[0].phone != null)
                    quote.Phone = c[0].Phone;
            }
        }
        else{
            error = true;
            errormsg = 'Shipping Contact is required for Quote integration';
        }
        /*if(error){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormsg);
            ApexPages.addMessage(myMsg);
            return null;
        }*/
        
       // else{
       
       //Remove for IBA-4189
       
       
        //quote.GPO_Price_Lists__c=selectedgpo;
       
       String ToggleTo='';
       
       if (OriginalOrderType != quote.Order_Type__c ) {
           //order type changed
           ToggleTo=quote.order_Type__c;
 //          quote.Order_Type__c=OriginalOrderType;
       }
        Boolean statusopencheck = true;
        //quote.status != selectedstatus && 
        /*if(selectedstatus == Label.Quote_Status_Open_for_edit_page)
            statusopencheck = true;
        else if(selectedstatus != quote.status || quote.status != Label.Quote_Status_Open_for_edit_page){
        //if(quote.status != Label.Quote_Status_Open_for_edit_page){
            if(profileName == Label.Booking_Team || profileName == Label.DealDesk_Legal || profileName == Label.Business_Admin || profileName == Label.System_Admin || profileName == Label.International_Sales_Ops){
                statusopencheck = true;
            }
            else
                statusopencheck = false;
        }*/
        if(statusopencheck){
            //ndermessages = false;
            try{
                if(quote.IsFromEditPage__c == False)
                    quote.IsFromEditPage__c= True;
                else
                    quote.IsFromEditPage__c= False;
                
                if(quote.Primary_Quote__c == true){//Added For IBA-920 by Sourav
                    	checkPrimaryQuote(quote.id,quote.OpportunityId);
                        QuoteTriggerHandler.isFirstTime = true;//Added by Sourav for IBA-1178
                }
                update quote;
                
                //if the quote update requires a toggle, then go to the ToggleSave page
                if (ToggleTo.length()>0) {
                PageReference pr = new PageReference('/apex/ToggleSave?Id='+quote.id+'&OT='+ToggleTo);
               //refreshPage = true;
                //return null;
                 pr.getParameters().put('OT',ToggleTo);
                 pr.setRedirect(true);
                return pr;
                }
                else {
                    PageReference pr1 = new PageReference('/'+quote.id);
                    pr1.setRedirect(true);
                    //Remove for IBA-4189
                    return pr1;
                    //}
                      
                                      
                }
            }
            catch(DMLException e) {
                rendermessages = true;
                ApexPages.addMessages(e); 
                return null; 
            }
        }
        else{
            rendermessages = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Quote_Status_Error_Message);
            ApexPages.addMessage(myMsg);
            return null; 
        }
        
    }
    public PageReference cancel(){
        PageReference pr = new PageReference('/'+quote.id);
        pr.setRedirect(true);
        return pr;
    }
    
    
    
     Public pagereference showleaseduration(){
         /*Lease duration and service duration values will be populate based on order type is equal to Q lease InHouse,Q Lease Renwl InHous,Quote - Lease - 3P and Quote Lease Ren 3P*/
        showlease = false;
        if(quote.Order_Type__c == 'ZQRL' || quote.Order_Type__c == 'ZQR3' || quote.Order_Type__c == 'ZQL3' || quote.Order_Type__c == 'ZQLI'){
            showlease = true;
            if(quote.Lease_Duration__c == null || quote.Lease_Duration__c == 0){
                quote.Lease_Duration__c = 60;
            }    
            if(quote.Service_Duration__c == null || quote.Service_Duration__c == 12 ){
                quote.Service_Duration__c = 60;
            }
            
        }
         /*Lease duration and service duration values will be populate based on order type is equal to Hanger Quotation,Quote - Distributors,Quote - Internal,Quote - Purchase and Quote - As Service*/
            if(quote.Order_Type__c == 'ZQR' || quote.Order_Type__c == 'ZHQR' || quote.Order_Type__c == 'ZQD' || quote.Order_Type__c == 'ZINT' || quote.Order_Type__c == 'ZQRS' ){
            showlease = false;
            quote.Lease_Duration__c = 0;
            if(quote.Service_Duration__c != null ) {
               quote.Service_Duration__c = 12;
            }
            
            
        }
         changeDate = true;  //Added for SF-BUG-830
         updateSalesOrg();
         changeDate = false;  //Added for SF-BUG-830
        System.debug('Show Lease : '+showlease);
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
       /* List<AccountTeamMember> actmdealdesk = new List<AccountTeamMember>();
        actmdealdesk = [select user.Name,TeamMemberRole,userid from AccountTeamMember where accountid=:accid and TeamMemberRole = 'Deal Desk'];
        return actmdealdesk.size();*/
    }
    public Integer getClinicalConsultantcount(){
        return 0;
       /* List<AccountTeamMember> actmpharmacy = new List<AccountTeamMember>();
   
        actmpharmacy = [select user.Name,TeamMemberRole,userid from AccountTeamMember where accountid=:accid and TeamMemberRole = 'Pharmacy Consultant'];
          return actmpharmacy.size();*/  
    }
    public Integer getSalesConsultantcount(){
        return 0;
        /*List<AccountTeamMember> actminsidesales = new List<AccountTeamMember>();
        List<AccountTeamMember> actmsalesconsultant = new List<AccountTeamMember>();
        actminsidesales = [select user.Name,TeamMemberRole,userid from AccountTeamMember where accountid=:accid and TeamMemberRole = 'Inside Sales Rep'];
        actmsalesconsultant = [select user.Name,TeamMemberRole,userid from AccountTeamMember where accountid=:accid and TeamMemberRole = 'Sales Consultant'];
        Account acc = [select RecordTypeId from Account where id=:accid];
        if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId())
           return actmsalesconsultant.size();
        else
           return actminsidesales.size();  */  
    }
    
     //Added by JAY - CR-18666
      public List<SelectOption> getOrderList(){
          List<selectOption> options = new List<selectOption>(); 
       // Describe the SObject using its object type.
         Schema.DescribeSObjectResult objDescribe = Quote.getSObjectType().getDescribe();
 
        // Get a map of fields for the SObject
        Map< String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get('Order_Type__c').getDescribe().getPickListValues();
 
         options.add(new selectOption( '','--None--' ));
         for (Schema.PicklistEntry optionItem : values)
         {
           if(optionItem.getValue() != 'ZQRS')
           {
             options.add(new SelectOption(optionItem.getValue(),optionItem.getLabel()));           
           }
           if(optionItem.getValue() == quote.Order_Type__c)
           {
             orderValueSelected = optionItem.getLabel();          
           }
           
         }
         
      
      return options;  
  }
    /*public void rerendersalesorgsec(){
        selectedinco1 = quote.Incoterms_1__c;
        selectedinco2 = quote.Incoterms_2__c;
        selectedtop = quote.Terms_of_Payment__c;
        prrefdate = quote.Pricing_Reference_Date__c;
        selectedshpcon = quote.Shipping_Conditions__c;
        selectedIdn = quote.IDN_Price_List__c;
    }*/
    public void checkPrimaryQuote(Id quoteId,Id oppId){//Added For IBA-920 by Sourav
        List<Quote> primaryQuote = new List<Quote>();
        primaryQuote = [Select id,Primary_Quote__c From Quote Where OpportunityId = :oppId AND id!= :quoteId AND Primary_Quote__c =true];
    	if(primaryQuote.size()>0){
			primaryQuote[0].Primary_Quote__c = false; 
            update primaryQuote[0];
        }
    }
    

}