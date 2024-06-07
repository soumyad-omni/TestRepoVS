/**********************************************************************
Name:  OmnicellContactToCastIron_Class
Copyright © 2018
======================================================
======================================================
Purpose: 
Once Contact is created/updated,invoke REST api class to connect to CastIron.                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                  Description
0.1          CG Dev Team         09/03/2018            Developed by CG Team    INITIAL DEVELOPMENT
***********************************************************************/



public class OmnicellContactToCastIron_Class {
    
    public static string getlanguagedesc(string language)
    { 
        string value='';
        Schema.DescribeFieldResult F = Contact.Language_Code__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(Schema.PicklistEntry pe : p){
            if(pe.getValue() == language){
                value = pe.getLabel();
                system.debug('value...'+value);
            }
        }
        return value;
        
    } 
    
    @future(callout=true)
    
    
    public static void callOutMethodInsert(set<Id> newconIds){
        
        system.debug('Test Integration Class...');
        
        //CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        
        
       // String endpoint = csValue1.ContactInsertEndpoint__c; 
        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_ContactSFToCRM');
             String endpoint =   connectionDetails.SCP_End_Point__c;
             String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
        system.debug('endpoint...'+endpoint);
        
        String conname='';
        String jsonstrinsert ='';
        String contactid ='';
        string errormsg ='';
        List<String> jasonstrings = new List<String>();
        List<Contact> JasonConList = new List<Contact>();
        Contact [] conList = [SELECT Id,Name,Salutation,FirstName,LastName,Language_Code__c,AccountId,Account.Name,Omnicell_Job_Code__c,
                              Title,Department__c,Phone_Country_Code__c,Phone,Phone_Extn__c,Mobile_Country_Code__c,MobilePhone,
                              Fax_Country_Code__c,Fax,Email,Preferred_Contact_Method__c,Is_Active__c,Inactive_Reason__c,
                              Opt_in__c,Opt_In_Date__c,SAP_Contact_ID__c,SAP_Contact_GUID__c,Account.SAP_Account_ID__c,Contact_Role__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OwnerId,Notes__c,Account.Validation_Status__c,Account.Account_Role__c,Salesforce_Contact_ID__c FROM Contact WHERE Id IN: newconIds];
        system.debug('conList...'+conList);
        
        if(conList.size()>0)
        {
            for(Contact con : conList) 
            {
                //Contact c = new Contact();
                // c = con;
                conname = con.Name;
                contactid = con.Id;
                system.debug('contactid...'+contactid );
                string sfdcconid = con.Id;
                string name = con.Name;
                //c.name = con.name;
                if(name == null)
                {
                    name = '';
                }
                
                string salutation = con.Salutation;
                //  c.Salutation = con.Salutation;
                if(salutation == null)
                {
                    salutation = '';
                }
                
                string notes = con.Notes__c;
                // c.Notes__c = con.Notes__c;
                if(notes == null)
                { 
                    notes = '';
                }
                string firstname = con.FirstName;
                //  c.FirstName = con.FirstName;
                if(firstname == null)
                {
                    firstname = '';
                }
                string lastname = con.LastName;
                // c.LastName = con.LastName;
                if(lastname == null)
                {
                    lastname = '';
                }
                string language = con.Language_Code__c;
                if(language == null)
                {
                    language = '';
                }
                //string languagedesc = c.Language_Code__c;
                string languagedesc = getlanguagedesc(language);
                system.debug('languagedesc..'+languagedesc);
                if(languagedesc == null)
                {
                    languagedesc = '';
                }
                string sfdcacctid = con.AccountId;
                string sfdcacctname = con.Account.Name;
                string omnicelljobcode = con.Omnicell_Job_Code__c;
                if(omnicelljobcode == null)
                {
                    omnicelljobcode = '';
                }
                
                string title = con.Title;
                if(title == null)
                {
                    title = '';
                }
                string department = con.Department__c;
                if(department == null)
                {
                    department = '';
                }
                string phonecode = con.Phone_Country_Code__c;
                if(phonecode == null)
                {
                    phonecode = '';
                }
                string phone = con.Phone;
                if(phone == null)
                {
                    phone = '';
                }
                
                string phoneext = con.Phone_Extn__c;
                if(phoneext == null)
                {
                    phoneext = '';
                }
                string mobilecode = con.Mobile_Country_Code__c;
                if(mobilecode == null)
                {
                    mobilecode = '';
                }
                string mobilephone = con.MobilePhone;
                if(mobilephone == null)
                {
                    mobilephone = '';
                }
                string faxcode = con.Fax_Country_Code__c;
                if(faxcode == null)
                {
                    faxcode = '';
                }
                string fax = con.Fax;
                if(fax == null)
                {
                    fax = '';
                }
                string email = con.Email;
                if(email == null)
                {
                    email = '';
                }
                string preferredmethod = con.Preferred_Contact_Method__c;
                if(preferredmethod == null)
                {
                    preferredmethod = '';
                }
                string isactive = con.Is_Active__c;
                if(isactive == null)
                {
                    isactive = '';
                }
                string inactivereason = con.Inactive_Reason__c;
                if(inactivereason == null)
                {
                    inactivereason = '';
                }
                
                string optin = con.Opt_in__c;
                if(optin == null)
                {
                    optin = '';
                }
                //date optdate = c.Opt_In_Date__c;
                
                string optdate;
                Date optdte = con.Opt_In_Date__c;
                if(optdte!=null){
                    optdate = Datetime.newInstance(optdte.year(), optdte.month(),optdte.day()).format('YYYYMMdd');}
                System.debug('optdate...'+optdate);
                if(optdate == null)
                {
                    
                    optdate = '';
                }
                string sapcontactid = con.SAP_Contact_ID__c;
                if(sapcontactid == null)
                {
                    sapcontactid = '';
                }
                string sapcontactguid = con.SAP_Contact_GUID__c;
                if(sapcontactguid == null)
                {
                    sapcontactguid = '';
                }        
                
                string sapaccountid = con.Account.SAP_Account_ID__c;
                if(sapaccountid == null)
                {   
                    sapaccountid = '';
                }
                string contactrole = con.Contact_Role__c;
                if(contactrole == null)
                {
                    contactrole = '';
                }
                //JasonConList.add(c);
                jsonstrinsert ='{"Salesforce Contact ID" : "'+sfdcconid +'","Salutation" : "'+salutation+'","First Name": "'+ firstname +'","Last Name" : "'+lastname+'", "Language - Code" : "'+ language+'", "Language - Description" : "'+ languagedesc+'","Name": "'+name+'", "Omnicell Job Title" : "'+omnicelljobcode+'", "Title" : "'+title+'" , "Department" : "'+department+'", "Phone- Country Code" : "'+ phonecode+'" , "Phone - Extn" : "'+phoneext+'","Phone- Number" : "'+phone+'", "Mobile- Country Code": "'+ mobilecode+'", "Mobilenumber" : "'+ mobilephone+'", "Fax- Country Code" : "'+faxcode+'", "Fax - number" : "'+fax+'", "Email" : "'+email+'","Communication method" : "'+ preferredmethod +'", "Status" : "'+ isactive+'", "Inactive Reason" : "'+ inactivereason+'", "Opt-In" : "'+ optin+'", "Opt-in Date" : "'+ optdate+'", "SAP Contact ID" : "'+ sapcontactid+'", "SAP Contact GUID" : "'+ sapcontactguid+'","SAP Account ID" : "'+sapaccountid+'","Account Name" : "'+sfdcacctname+'","Contact Role":"'+ contactrole+'","Notes":"'+notes+'"}';   
                //String genString = jsonstrinsert.getAsString();
                
                
                
                
                jasonstrings.add(jsonstrinsert);
            }
            string jsonString = JSON.serialize(jasonstrings);
            jsonString = jsonString.replace('\\"', '"');
            jsonString = jsonString.replace('"{', '{');
            jsonString = jsonString.replace('}"', '}');
            
            //String jsonCon = JSON.serialize(JasonConList);
            System.debug('jsonString : '+jsonString);
            System.debug('jsonString : '+JasonConList);
            //Contact c = [select Id,Salutation,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,FirstName,Lastname,Account.SAP_Account_ID__c,Phone_Extn__c,Notes__c,Name,OwnerId,Omnicell_Job_Code__c,AccountId,Account.Validation_Status__c,Account.Account_Role__c,Salesforce_Contact_ID__c,SAP_Contact_ID__c,Language_Code__c,Account.Name, Title, Department__c, MailingAddress, Phone_Country_Code__c, Phone, Mobile_Country_Code__c, MobilePhone, Fax_Country_Code__c, Fax, Email, Preferred_Contact_Method__c, Is_Active__c, Inactive_Reason__c, Opt_in__c, Opt_In_Date__c, Contact_Role__c,SAP_Contact_GUID__c FROM Contact WHERE Id =:contactid];
            //system.debug('c..'+c);
            
            try{
                system.debug('in try...');
                if(conname != '' )
                {
                    //system.debug('conname123..'+conname );
                    
                    //jsonstrinsert ='{"Salesforce Contact ID" : "'+sfdcconid +'","Salutation" : "'+salutation+'","First Name": "'+ firstname +'","Last Name" : "'+lastname+'", "Language - Code" : "'+ language+'", "Language - Description" : "'+ languagedesc+'","Notes" : "'+notes+'","Name": "'+name+'", "Function" : "'+omnicelljobcode+'","Function Description" : "'+ omnicelljobtitle+'" , "Title" : "'+title+'" , "Department" : "'+department+'", "Phone- Country Code" : "'+ phonecode+'" , "Phone - Extn" : "'+phoneext+'","Phone- Number" : "'+phone+'", "Mobile- Country Code": "'+ mobilecode+'", "Mobilenumber" : "'+ mobilephone+'", "Fax- Country Code" : "'+faxcode+'", "Fax - number" : "'+fax+'", "Email" : "'+email+'","Communication method" : "'+ preferredmethod +'", "Status" : "'+ isactive+'", "Inactive Reason" : "'+ inactivereason+'", "Opt-In" : "'+ optin+'", "Opt-in Date" : "'+ optdate+'", "SAP Contact ID" : "'+ sapcontactid+'","SAP Account ID" : "'+sapaccountid+'","Name" : "'+sfdcacctname+'","Contact Role" : "'+ contactrole+'" }';
                    // jsonstrinsert ='{"Salesforce Contact ID" : "'+sfdcconid +'","Salutation" : "'+salutation+'","First Name": "'+ firstname +'","Last Name" : "'+lastname+'", "Language - Code" : "'+ language+'", "Language - Description" : "'+ languagedesc+'","Name": "'+name+'", "Omnicell Job Title" : "'+omnicelljobcode+'", "Title" : "'+title+'" , "Department" : "'+department+'", "Phone- Country Code" : "'+ phonecode+'" , "Phone - Extn" : "'+phoneext+'","Phone- Number" : "'+phone+'", "Mobile- Country Code": "'+ mobilecode+'", "Mobilenumber" : "'+ mobilephone+'", "Fax- Country Code" : "'+faxcode+'", "Fax - number" : "'+fax+'", "Email" : "'+email+'","Communication method" : "'+ preferredmethod +'", "Status" : "'+ isactive+'", "Inactive Reason" : "'+ inactivereason+'", "Opt-In" : "'+ optin+'", "Opt-in Date" : "'+ optdate+'", "SAP Contact ID" : "'+ sapcontactid+'", "SAP Contact GUID" : "'+ sapcontactguid+'","SAP Account ID" : "'+sapaccountid+'","Name" : "'+sfdcacctname+'","Contact Role":"'+ contactrole+'","Notes":"'+notes+'"}';   
                    //system.debug('jsonstrinsert...'+jsonstrinsert);
                }
                Http h= new Http();
                HttpRequest req= new HttpRequest();
                //req.setClientCertificateName('CastIronIntegration');
                req.setHeader('Authorization', 'Bearer '+accessToken);
                req.setHeader('Content-Type','application/json');
                req.setHeader('accept','application/json');
                req.setBody(jsonString);
                req.setMethod(connectionDetails.SCP_Method_Type__c);
                req.setEndpoint(endpoint);
                req.setTimeout((Integer)connectionDetails.SCP_Timeout__c);
                HttpResponse res=h.send(req);
                if(res.getstatusCode() == 200){
                    System.debug(res+'###123createresp');
                    system.debug('res.getBody()..'+res.getBody());
                    system.debug('res.getStatus()..'+res.getStatus());
                    
                }
                if(res.getstatusCode() != 200){
                    system.debug('errorbody..'+res.getBody());
                    system.debug('errorstatus..'+res.getStatus());
                    
                    errormsg = res.getStatus();
                    system.debug('errormsg..'+errormsg);
                    if(errormsg!=null){
                        system.debug('callingclass..');
                        ErrorLogging.IntegrationLog(errormsg, 'callOutMethodInsert','App');
                    }
                    
                }  
                
            }  
            catch(Exception e){
                System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
                ErrorLogging.Log(e, 'callOutMethodInsert','App');
                
            }
            
            
        }
    }
    @future (callout=true)
    public static void callOutMethodUpdate(set<Id> newconIds){
        system.debug('method 2...');
        
       // CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        
        Boolean sapcontactidnullflag = false;
       // String endpoint = csValue1.ContactUpdateEndpoint__c; 
             SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_ContactSFToCRM_Update');
             String endpoint =   connectionDetails.SCP_End_Point__c;
             String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
            
        system.debug('endpoint...'+endpoint);
        
        String conname='';
        String contactid ='';
        string errormsg ='';
        List<String> jasonstrings = new List<String>();
        //Contact [] conList = [SELECT Id,Name,Title,Account.Name,Language_Code__c,Salutation,FirstName,LastName,OwnerId,MailingStreet,Account.SAP_Account_ID__c,MailingCity,MailingState,MailingPostalCode,MailingCountry,Notes__c,AccountId,Omnicell_Job_Code__c,Phone_Extn__c,Account.Validation_Status__c,Account.Account_Role__c,Salesforce_Contact_ID__c,SAP_Contact_ID__c, SAP_Contact_GUID__c FROM Contact WHERE Id IN: newconIds];
        Contact [] conList = [SELECT Id,Name,Salutation,FirstName,LastName,Language_Code__c,AccountId,Account.Name,Omnicell_Job_Code__c,
                              Title,Department__c,Phone_Country_Code__c,Phone,Phone_Extn__c,Mobile_Country_Code__c,MobilePhone,
                              Fax_Country_Code__c,Fax,Email,Preferred_Contact_Method__c,Is_Active__c,Inactive_Reason__c,
                              Opt_in__c,Opt_In_Date__c,SAP_Contact_ID__c,SAP_Contact_GUID__c,Account.SAP_Account_ID__c,Contact_Role__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OwnerId,Notes__c,Account.Validation_Status__c,Account.Account_Role__c,Salesforce_Contact_ID__c FROM Contact WHERE Id IN: newconIds];
        system.debug('conList...'+conList);
        
        if(conList.size()>0)
        {
            List<Contact> contactsToUpdate = new List<Contact>(); 
            for(Contact con : conList) 
            {
                conname = con.Name;
                contactid = con.Id;
                system.debug('contactid...'+contactid );
                string sfdcconid = con.Id;
                string name = con.Name;
                if(name == null)
                {
                    name = '';
                }
                string salutation = con.Salutation;
                if(salutation == null)
                {
                    salutation = '';
                }
                string firstname = con.FirstName;
                if(firstname == null)
                {
                    firstname = '';
                }
                string lastname = con.LastName;
                if(lastname == null)
                {
                    lastname = '';
                }
                
                string notes = con.Notes__c;
                if(notes == null)
                {
                    notes = '';
                }
                string language = con.Language_Code__c;
                if(language == null)
                {
                    language = '';
                }
                //string languagedesc = c.Language_Code__c;
                string languagedesc = getlanguagedesc(language);
                system.debug('languagedesc..'+languagedesc);
                if(languagedesc == null)
                {
                    languagedesc = '';
                }
                string sfdcacctid = con.AccountId;
                
                string sapaccountid = con.Account.SAP_Account_ID__c;
                if(sapaccountid == null)
                {
                    sapaccountid = '';
                }
                
                string sfdcacctname = con.Account.Name;
                string omnicelljobcode = con.Omnicell_Job_Code__c;
                if(omnicelljobcode == null)
                {
                    omnicelljobcode = '';
                }
                
                string title = con.Title;
                if(title == null)
                {
                    title = '';
                }
                string department = con.Department__c;
                if(department == null)
                {
                    department = '';
                }
                string phonecode = con.Phone_Country_Code__c;
                if(phonecode == null)
                {
                    phonecode = '';
                }
                string phone = con.Phone;
                if(phone == null)
                {
                    phone = '';
                }
                
                string phoneext = con.Phone_Extn__c;
                if(phoneext == null)
                {
                    phoneext = '';
                }
                
                string mobilecode = con.Mobile_Country_Code__c;
                if(mobilecode == null)
                {
                    mobilecode = '';
                }
                string mobilephone = con.MobilePhone;
                if(mobilephone == null)
                {
                    mobilephone = '';
                }
                string faxcode = con.Fax_Country_Code__c;
                if(faxcode == null)
                {
                    faxcode = '';
                }
                string fax = con.Fax;
                if(fax == null)
                {
                    fax = '';
                }
                string email = con.Email;
                if(email == null)
                {
                    email = '';
                }
                string preferredmethod = con.Preferred_Contact_Method__c;
                if(preferredmethod == null)
                {
                    preferredmethod = '';
                }
                string isactive = con.Is_Active__c;
                if(isactive == null)
                {
                    isactive = '';
                }
                string inactivereason = con.Inactive_Reason__c;
                if(inactivereason == null)
                {
                    inactivereason = '';
                }
                
                string optin = con.Opt_in__c;
                if(optin == null)
                {
                    optin = '';
                }
                //date optdate = c.Opt_In_Date__c;
                
                string optdate;
                Date optdte = con.Opt_In_Date__c;
                if(optdte!=null){
                    optdate = Datetime.newInstance(optdte.year(), optdte.month(),optdte.day()).format('YYYYMMdd');}
                System.debug('optdate...'+optdate);
                if(optdate == null)
                {
                    optdate = '';
                }
                string sapcontactid = con.SAP_Contact_ID__c;
                if(sapcontactid == null)
                {
                    sapcontactidnullflag = true;
                    sapcontactid = '';
                }
                string sapcontactguid = con.SAP_Contact_GUID__c;
                if(sapcontactguid == null)
                {
                    sapcontactguid = '';
                }         
                
                string contactrole = con.Contact_Role__c;
                if(contactrole == null)
                {
                    contactrole = '';
                }
                String jsonstrupdate='{"Salesforce Contact ID" : "'+sfdcconid +'","Salutation" : "'+salutation+'","First Name": "'+ firstname +'","Last Name" : "'+lastname+'", "Language - Code" : "'+ language+'", "Language - Description" : "'+ languagedesc+'","Name": "'+name+'", "Omnicell Job Title" : "'+omnicelljobcode+'", "Title" : "'+title+'" , "Department" : "'+department+'", "Phone- Country Code" : "'+ phonecode+'" , "Phone - Extn" : "'+phoneext+'","Phone- Number" : "'+phone+'", "Mobile- Country Code": "'+ mobilecode+'", "Mobilenumber" : "'+ mobilephone+'", "Fax- Country Code" : "'+faxcode+'", "Fax - number" : "'+fax+'", "Email" : "'+email+'","Communication method" : "'+ preferredmethod +'", "Status" : "'+ isactive+'", "Inactive Reason" : "'+ inactivereason+'", "Opt-In" : "'+ optin+'", "Opt-in Date" : "'+ optdate+'", "SAP Contact ID" : "'+ sapcontactid+'", "SAP Contact GUID" : "'+ sapcontactguid+'","SAP Account ID" : "'+sapaccountid+'","Account Name" : "'+sfdcacctname+'","Contact Role":"'+ contactrole+'","Notes":"'+notes+'"}';   
                jasonstrings.add(jsonstrupdate);        
                //Updating the Integrated_To_C4C__c to false to send the contact updates to C4C
                Contact c = new Contact(id = con.Id, Integrated_To_C4C__c = false);
				contactsToUpdate.add(c);
                system.debug('newconIds..'+newconIds);
            }  
            string jsonString = JSON.serialize(jasonstrings);
            
            jsonString = jsonString.replace('\\"', '"');
            jsonString = jsonString.replace('"{', '{');
            jsonString = jsonString.replace('}"', '}');
            //String jsonCon = JSON.serialize(JasonConList);
            System.debug('jsonString : '+jsonString);
            
            
            
            if(sapcontactidnullflag == false)
            {
                try
                {
                    String EndPoint1 = endPoint;
                    // String jsonstrupdate= '{"Salesforce Contact ID" : "'+sfdcconid +'","Salutation" : "'+salutation+'","First Name": "'+ firstname +'","Last Name" : "'+lastname+'", "Language - Code" : "'+ language+'","Language - Description" : "'+ languagedesc+'","Name": "'+name+'", "Function" : "'+omnicelljobtitle+'","Function Description" : "'+ omnicelljobcode+'" , "Title" : "'+title+'" , "Department" : "'+department+'", "Phone- Country Code" : "'+ phonecode+'" , "Phone - Extn" : "'+phoneext+'","Phone- Number" : "'+phone+'", "Mobile- Country Code": "'+ mobilecode+'", "Mobilenumber" : "'+ mobilephone+'", "Fax- Country Code" : "'+faxcode+'", "Fax - number" : "'+fax+'", "Email" : "'+email+'","Communication method" : "'+ preferredmethod +'", "Status" : "'+ isactive+'", "Inactive Reason" : "'+ inactivereason+'", "Opt-In" : "'+ optin+'", "Opt-in Date" : "'+ optdate+'", "SAP Contact ID" : "'+ sapcontactid+'","Name" : "'+sfdcacctname+'","Contact Role":"'+ contactrole+'","Notes":"'+notes+'"}'; 
                    // system.debug('jsonupdate...'+jsonString);
                    Http h2= new Http();
                    HttpRequest req2= new HttpRequest();
                    //req2.setClientCertificateName('CastIronIntegration');
                      req2.setHeader('Authorization', 'Bearer '+accessToken);
                    req2.setHeader('Content-Type','application/json');
                    req2.setHeader('accept','application/json');
                    req2.setHeader('X-HTTP-METHOD-Override','PATCH');
                    req2.setBody(jsonString);
                    req2.setMethod('POST');
                    req2.setEndpoint(EndPoint1);
                    req2.setTimeout(120000); 
                    HttpResponse res2=h2.send(req2);
                    System.debug(res2+'###123createresp');
                    if(res2.getStatusCode() == 200){
                        System.debug(res2+'###123createresp');
                        system.debug('res2.getBody()..'+res2.getBody());
                        system.debug('res2.getStatus()..'+res2.getStatus());
                        if(!contactsToUpdate.isEmpty()){
                            ContactTriggerHandler.TriggerDisabled = true;
                            update contactsToUpdate;//Updating the Integrated_To_C4C__c to false to send the contact updates to C4C
                        }
                    } 
                    if(res2.getstatusCode() != 200){
                        system.debug('errorbody..'+res2.getBody());
                        system.debug('errorstatus..'+res2.getStatus());
                        errormsg = res2.getStatus();
                        system.debug('errormsg..'+errormsg);
                        system.debug('errormsg..'+errormsg);
                        if(errormsg!=null){
                            system.debug('callingclass..');
                            ErrorLogging.IntegrationLog(errormsg, 'callOutMethodUpdate','App');
                        } 
                    } 
                }
                catch(Exception e){
                    System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
                    ErrorLogging.Log(e, 'callOutMethodUpdate','App');
                } 
            }
            
        }
    }
    
}