public with sharing class LookupPageController {
    
    public Boolean render1 { get; set; }
    public Boolean render2 {get; set; }
    public Boolean render3 {get; set; }
    public Boolean render4 {get; set; }
    public Boolean render5 {get; set; }
    public Boolean render6 {get; set; } //IBA-1678
    //public String norec{get;set;}
    List<SObject> records=new List<SObject>();
    List<User> listUsers = new List<User>();   //IBA-1678
    List<Relationship__c> relationRecords = new List<Relationship__c>();
    List<SAP_Sales_Org__c> sapsalesorgrecords = new List<SAP_Sales_Org__c>();
    List<AccountTeamMember> actmRecords = new List<AccountTeamMember>();
    List<AccountTeamMember> actmdealdesk = new List<AccountTeamMember>();
    List<AccountTeamMember> actmpharmacy = new List<AccountTeamMember>();
    List<AccountTeamMember> actminsidesales = new List<AccountTeamMember>();
    List<AccountTeamMember> actmsalesconsultant = new List<AccountTeamMember>();
    List<Quote> quotes = new List<Quote>();
    List<Id> accids = new List<Id>();
    List<Contact> contacts = new List<Contact>();
    List<List<Contact>> Listcontacts = new List<List<Contact>>();//IBA-2961
    String norecords;
    public String searchvalue { get; set; }
    
    public LookupPageController()
    {
        try
        {
            norecords = System.Label.LookUp_Page_No_Records_Found_Error;
            String lookuptype = ApexPages.currentPage().getParameters().get('lookuptype');
            searchvalue=ApexPages.currentPage().getParameters().get('parentname');
            //String id=ApexPages.currentPage().getParameters().get('parentid');
           /* if(lookuptype == 'Quote'){
                render4 = true;
                quotes = [select id,Name from Quote];
                System.debug('Quotes : '+quotes);
            }
            else{*/
            String accid = ApexPages.currentPage().getParameters().get('accid');
            actmdealdesk = [select user.Name,TeamMemberRole,userid from AccountTeamMember where accountid=:accid and TeamMemberRole = 'Deal Desk'];
            actmpharmacy = [select user.Name,TeamMemberRole,userid from AccountTeamMember where accountid=:accid and TeamMemberRole = 'Pharmacy Consultant'];
            actminsidesales = [select user.Name,TeamMemberRole,userid from AccountTeamMember where accountid=:accid and TeamMemberRole = 'Inside Sales Rep'];
            actmsalesconsultant = [select user.Name,TeamMemberRole,userid from AccountTeamMember where accountid=:accid and TeamMemberRole = 'Sales Consultant'];
            //IBA-1678
            String searchText = '%'+ searchvalue + '%';
            listUsers = [Select id,name,Profile.UserLicense.Name from User where IsActive = true and (NOT Profile.UserLicense.Name like 'Customer Community%') AND name like :searchText];
            //listUsers = [Select id,name,Profile.UserLicense.Name from User where IsActive = true and (NOT Profile.UserLicense.Name like 'Customer Community%')];
            System.debug('Accid :'+accid);
            System.debug('Lookup Type : '+lookuptype);
                
            if(lookuptype == 'shipto'){
                relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='WE'];
                for(Relationship__c rel : relationRecords){
                    accids.add(rel.Secondary_Account__c);
                }   
                //Developed by Balaji on 29/07/2019. Bug - SF-BUG-541//
                   //It will display the account address of 'Sold-to, Bill-to, Ship-to, Payer, GPO, IDN' section on Quote page//
                   accIds.add(accid);
                render1=true;
                String sSearchValue = '%'+ searchvalue + '%';
                list<Account> lstAcc =[Select Name,id,billingState,BillingStreet,BillingCity,BillingPostalCode,BillingCountry,SAP_Customer_Number__c  from Account where id =:accids and ( BillingStreet like :sSearchValue OR Name Like :sSearchValue OR SAP_Customer_Number__c Like :sSearchValue ) limit 1001];
                if(lstAcc.size() > 1000){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'More records found ... appy filters'));
                    lstAcc.remove(1000);
                }
                records= lstAcc;
            }
            else if(lookuptype == 'billto'){
                relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='RE'];
                for(Relationship__c rel : relationRecords){
                    accids.add(rel.Secondary_Account__c);
                }
                //Developed by Balaji on 29/07/2019. Bug - SF-BUG-541//
                   //It will display the account address of 'Sold-to, Bill-to, Ship-to, Payer, GPO, IDN' section on Quote page//
                   accIds.add(accid);
                render1=true;
                String sSearchValue = '%'+ searchvalue + '%';
                list<Account> lstAcc =[Select Name,id,billingState,BillingStreet,BillingCity,BillingPostalCode,BillingCountry, SAP_Customer_Number__c  from Account where id =:accids and ( BillingStreet like :sSearchValue OR Name Like :sSearchValue OR SAP_Customer_Number__c Like :sSearchValue ) limit 1001];
                if(lstAcc.size() > 1000){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'More records found ... appy filters'));
                    lstAcc.remove(1000);
                }
                records= lstAcc;
            }
            else if(lookuptype == 'payer'){
                relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='RG'];
                for(Relationship__c rel : relationRecords){
                    accids.add(rel.Secondary_Account__c);
                }
                //Developed by Balaji on 29/07/2019. Bug - SF-BUG-541//
                   //It will display the account address of 'Sold-to, Bill-to, Ship-to, Payer, GPO, IDN' section on Quote page//
                   accIds.add(accid);
                render1=true;
                    records=[Select Name,id,billingState,BillingStreet,BillingCity,BillingPostalCode,BillingCountry from Account where id =:accids];
            }
            else if(lookuptype == 'gpo'){
                relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='ZG'];
                for(Relationship__c rel : relationRecords){
                    accids.add(rel.Secondary_Account__c);
                }
                render1=true;
                    records=[Select Name,id,billingState,BillingStreet,BillingCity,BillingPostalCode,BillingCountry from Account where id =:accids];
            }
            else if(lookuptype == 'idn'){
                relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid and Relationship__c='ZI'];
                for(Relationship__c rel : relationRecords){
                    accids.add(rel.Secondary_Account__c);
                }
                render1=true;
                    records=[Select Name,id,billingState,BillingStreet,BillingCity,BillingPostalCode,BillingCountry from Account where id =:accids];
            }
            else if(lookuptype == 'sapsalesorg'){
                accids.add(accid);
                render2=true;
                sapsalesorgrecords = [select Name,Sales_Org__c from SAP_Sales_Org__c where Account__c=:accid];
            }
            else if(lookuptype == 'dealdesk'){
                render3 = true;
                actmRecords = actmdealdesk;
            }
            else if(lookuptype == 'clinicalconsultant'){
                //render3 = true;
                //actmRecords = actmpharmacy;
                render6 = true;
            }
            else if(lookuptype == 'salesconsultant'){
                Account acc = [select RecordTypeId from Account where id=:accid];
                render3 = true;
                if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId())
                    actmRecords = actmsalesconsultant;
                else
                    actmRecords = actminsidesales;
            }
            else{
                render5 = true;
                List<id> acids = new List<Id>();
                acids.add(accid);
                if(lookuptype != '')
                	acids.add(lookuptype);
                
                contacts = [select id,Name from contact where (accountid=:acids and SAP_Contact_Id__c != null) Order by LastName ASC Nulls First];
                
            }
            System.debug('Records : '+records);
            System.debug('accids : '+accids);
            
            }   
        catch(Exception e)
        {
        }
    }
    
    public List<Account> getRecords() {
        if(records.size()!=0)
        {
            return records;
        }else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,norecords));
            return null;
        }
    }
    public List<List<Contact>> getContacts() {//IBA-2961
        List<Contact> tempList = new List<Contact>();
        if(contacts.size()!=0)
        {
            for(Contact c: contacts) {
                tempList.add(c) ;
                if(tempList.size()==1000) {
                    Listcontacts.add(tempList);
                    tempList = new List<Contact>();
                }
                
            }
           	Listcontacts.add(tempList);
            return Listcontacts;
        }else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,norecords));
            return null;
        }
    }
    public List<AccountTeamMember> getACTMRecords() {
        if(actmRecords.size()!=0)
        {
            return actmRecords;
        }else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,norecords));
            return null;
        }
    }
     public List<Quote> getQuotes() {
        if(quotes.size()!=0)
        {
            return quotes;
        }else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,norecords));
            return null;
        }
    }
    //IBA-1678
    public List<User> getlistUsers() {
        if(listUsers.size()!=0)
        {
            return listUsers;
        }else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,norecords));
            return null;
        }
    }
    
     public List<SAP_Sales_Org__c> getSAPSalesOrgRecords() {
        if(sapsalesorgrecords.size()!=0)
        {
            return sapsalesorgrecords;
        }else
        {
            return null;
        }
    }
    
    /*public PageReference onkeyupAction() {
        searchAction();
        return null;
    }
    
    public PageReference searchAction() {
        render1=true;
        String accid = ApexPages.currentPage().getParameters().get('accid');
            
            relationRecords = [select Secondary_Account__c from Relationship__c where Primary_Account__c=:accid];
            for(Relationship__c rel : relationRecords){
                accids.add(rel.Secondary_Account__c);
            }
        records=[Select Name,id from Account where id =:accids];
        if(records.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,norecords));
        }
        return null;
    }*/
}