global class caseDetailsFromPandoraBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query 	= 'SELECT id,Legacy_Pandora_Id__c FROM Case ';
        query = query + ' where Migration_from_Pandora_Completed__c = FALSE';
        //query = query + ' where Legacy_Pandora_Id__c  IN (\'5004000000VlMCyAAN\')';
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList)
    {
        Map<String,String> resMap = getContactsFromPandoraBatch.calloutPandoraAuth();    
        List<Case> updateCaseList = New List<Case>();
        
        Map<String,String> lookUpUserField = New Map<String, String>();
        lookUpUserField.put('00540000001SO55AAG','0051N000007IZS8');
        lookUpUserField.put('00540000002HC49AAG','0051N000007IZfz');
        lookUpUserField.put('00540000001SeAcAAK','005Ov000009Ff1FIAS');
        
        for(User usr : [select id,name from user where  profile.name <> 'Omnicell B2B Storefront Profile' and isactive = true])
        {
            lookUpUserField.put(usr.name,usr.Id);
        }
        
        for(Group grp : [select id,name from group where type = 'Queue'])
        {
            lookUpUserField.put(grp.name,grp.Id);
        }
        
        system.debug('lookUpUserField-->'+lookUpUserField);
        
        for(Case cs : caseList)
        {
            String endPointPath = resMap.get('instance_url')+'/services/data/v60.0/sobjects/Case/'+cs.Legacy_Pandora_Id__c;
                
            String jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);

            if(test.isRunningTest())
            {
                jsonResponse = '{"Id":"123","name":"12345","CaseNumber":"234"}';
            }
            Case newCs = populateCaseFields(jsonResponse);
            newCs.Legacy_Pandora_Id__c = newCs.Id;
            newCs.Legacy_Case_Number__c = newCs.CaseNumber;
            newCs.Id = cs.Id;
            newCs.OwnerId = userinfo.getUserId();
            
            newCs = getContactDetails(newCs,resMap, lookUpUserField);
            system.debug('newCs-->'+newCs.ETS_Project_Plan_Meeting_Omnicell_Rep__c+':::'+newCs);

            newCs.Migration_from_Pandora_Completed__c = true;
            if(newCs.SuppliedEmail == 'bwu')
            {
                newCs.SuppliedEmail = NULL;
            }
            
            if(newCs.ETS_Project_Plan_Meeting_Omnicell_Rep__c <> NULL && lookUpUserField.containsKey(newCs.ETS_Project_Plan_Meeting_Omnicell_Rep__c))
            {
                newCs.ETS_Project_Plan_Meeting_Omnicell_Rep__c = lookUpUserField.get(newCs.ETS_Project_Plan_Meeting_Omnicell_Rep__c);
            }
            if(newCs.ETSReportOverviewOmnicell_representative__c <> NULL && lookUpUserField.containsKey(newCs.ETSReportOverviewOmnicell_representative__c))
            {
                newCs.ETSReportOverviewOmnicell_representative__c = lookUpUserField.get(newCs.ETSReportOverviewOmnicell_representative__c);
            }
            if(newCs.Omnicell_representative_training_overvie__c <> NULL && lookUpUserField.containsKey(newCs.Omnicell_representative_training_overvie__c))
            {
                newCs.Omnicell_representative_training_overvie__c = lookUpUserField.get(newCs.Omnicell_representative_training_overvie__c);
            }
            updateCaseList.add(newCs);
        }
        
        if(!updateCaseList.isEmpty())
        {
            update updateCaseList;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    public static Case populateCaseFields(String caseString)
    {
        Case caseDetails =  (Case)JSON.deserialize(caseString,Case.class);
        return caseDetails;
    }
    
    public static Case getContactDetails(Case ret_case, Map<String,String> resMap, Map<String,String> lookUpUserField)
    {
        List<String> contactNameList = new List<String>();
        List<String> contactEmailList = new List<String>();
        List<String> contactPhoneList = new List<String>();
        List<String> accountCSNList = new List<String>();
        
        if(ret_case.CSN__c <> NULL && ret_case.CSN__c <> '')
        {
            accountCSNList.add(ret_case.CSN__c);
        }
        
        String fieldsStr = 'Contact.name,Contact.phone,Contact.email,Contact.account.CSN__c'
            +',IT_Contact__r.name,IT_Contact__r.phone,IT_Contact__r.email,IT_Contact__r.account.CSN__c'
            +',ETS_ProjPlanMeeting_Customer_Contact__r.name,ETS_ProjPlanMeeting_Customer_Contact__r.phone,ETS_ProjPlanMeeting_Customer_Contact__r.email,ETS_ProjPlanMeeting_Customer_Contact__r.account.csn__c'
            +',Primary_customer_contact__r.name,Primary_customer_contact__r.phone,Primary_customer_contact__r.email,Primary_customer_contact__r.account.csn__c'
            +',Additional_Contact__r.name,Additional_Contact__r.phone,Additional_Contact__r.email,Additional_Contact__r.account.csn__c'
            +',TrainingOverviewContact__r.name,TrainingOverviewContact__r.phone,TrainingOverviewContact__r.email,TrainingOverviewContact__r.account.csn__c'
            +',Omnicell_representative__r.name,Omnicell_representative__r.phone,Omnicell_representative__r.email,Omnicell_representative__r.account.csn__c'
            +',ETSReportOverviewCustomer_lead__r.name,ETSReportOverviewCustomer_lead__r.phone,ETSReportOverviewCustomer_lead__r.email,ETSReportOverviewCustomer_lead__r.account.csn__c'
            +',ETSTrainingPlanTraining_plan_recipient__r.name,ETSTrainingPlanTraining_plan_recipient__r.phone,ETSTrainingPlanTraining_plan_recipient__r.email,ETSTrainingPlanTraining_plan_recipient__r.account.csn__c'
            +',owner.name';
        
        httpRequest req =  new httpRequest();
        req.setendpoint(resMap.get('instance_url')+'/services/data/v58.0/query/?q=SELECT+'+fieldsStr+'+FROM+case+where+id=\''+ret_case.Legacy_Pandora_Id__c+'\'');
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer '+resMap.get('access_token'));
        
        httpResponse res = new http().send(req);
        system.debug('res-->'+res);
        system.debug('res body-->'+res.getBody());
        
        String responseBody = res.getBody();
        
        Map<String,Object> contactRecordsMap = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
        system.debug('contactFieldDetails-->'+contactRecordsMap.get('records'));
        
        List<object> contactDetailsList =  (List<Object>)contactRecordsMap.get('records');
        system.debug('contactDetailsList-->'+contactDetailsList.size()+'::::'+contactDetailsList);
        Map<String, Object> contactDetails = (Map<String, Object>)contactDetailsList[0];
        system.debug('contactDetails-->'+contactDetails);
        
        Map<String, Object> ownerDetails = (Map<String, Object>)contactDetails.get('Owner');
        Map<String, Object> contactIdDetails = (Map<String, Object>)contactDetails.get('Contact');
        Map<String, Object> itContactDetails = (Map<String, Object>)contactDetails.get('IT_Contact__r');
        Map<String, Object> ETSPrimaryContactDetails = (Map<String, Object>)contactDetails.get('ETS_ProjPlanMeeting_Customer_Contact__r');
        Map<String, Object> primaryContactDetails = (Map<String, Object>)contactDetails.get('Primary_customer_contact__r');
        Map<String, Object> additionalContactDetails = (Map<String, Object>)contactDetails.get('Additional_Contact__r');
        Map<String, Object> trainingOverviewContactDetails = (Map<String, Object>)contactDetails.get('TrainingOverviewContact__r');
        Map<String, Object> omnicellRepresentativeContactDetails = (Map<String, Object>)contactDetails.get('Omnicell_representative__r');
        Map<String, Object> ETSReportOverviewContactDetails = (Map<String, Object>)contactDetails.get('ETSReportOverviewCustomer_lead__r');
        Map<String, Object> ETSTrainingPlanContactDetails = (Map<String, Object>)contactDetails.get('ETSTrainingPlanTraining_plan_recipient__r');
        
        system.debug('ETSPrimaryContactDetails-->'+ETSPrimaryContactDetails);
        
        String contactIdCSN = (contactIdDetails == null || ((Map<String, Object>)contactIdDetails.get('Account')) == null? '' : ''+Integer.valueOf(((Map<String, Object>)contactIdDetails.get('Account')).get('CSN__c')));
        String itContactCSN = (itContactDetails == null || ((Map<String, Object>)itContactDetails.get('Account')) == null? '' : ''+Integer.valueOf(((Map<String, Object>)itContactDetails.get('Account')).get('CSN__c')));
        String ETSPrimaryContactCSN = (ETSPrimaryContactDetails == null || ((Map<String, Object>)ETSPrimaryContactDetails.get('Account')) == null? '' : ''+Integer.valueOf(((Map<String, Object>)ETSPrimaryContactDetails.get('Account')).get('CSN__c')));
        String primaryContactCSN = (primaryContactDetails == null || ((Map<String, Object>)primaryContactDetails.get('Account')) == null? '' : ''+Integer.valueOf(((Map<String, Object>)primaryContactDetails.get('Account')).get('CSN__c')));
        String additionalContactCSN = (additionalContactDetails == null || ((Map<String, Object>)additionalContactDetails.get('Account')) == null? '' : ''+Integer.valueOf(((Map<String, Object>)additionalContactDetails.get('Account')).get('CSN__c')));
        String trainingOverviewContactCSN = (trainingOverviewContactDetails == null || ((Map<String, Object>)trainingOverviewContactDetails.get('Account')) == null? '' : ''+Integer.valueOf(((Map<String, Object>)trainingOverviewContactDetails.get('Account')).get('CSN__c')));
        String omnicellRepresentativeContactCSN = (omnicellRepresentativeContactDetails == null || ((Map<String, Object>)omnicellRepresentativeContactDetails.get('Account')) == null? '' : ''+Integer.valueOf(((Map<String, Object>)omnicellRepresentativeContactDetails.get('Account')).get('CSN__c')));
        String ETSReportOverviewContactCSN = (ETSReportOverviewContactDetails == null || ((Map<String, Object>)ETSReportOverviewContactDetails.get('Account')) == null? '' : ''+Integer.valueOf(((Map<String, Object>)ETSReportOverviewContactDetails.get('Account')).get('CSN__c')));
        String ETSTrainingPlanContactCSN = (ETSTrainingPlanContactDetails == null || ((Map<String, Object>)ETSTrainingPlanContactDetails.get('Account')) == null ? '' : ''+Integer.valueOf(((Map<String, Object>)ETSTrainingPlanContactDetails.get('Account')).get('CSN__c')));
        
        if(contactIdCSN <> '' && contactIdCSN <> NULL) accountCSNList.add(contactIdCSN);
        if(itContactCSN <> '' && itContactCSN <> NULL) accountCSNList.add(itContactCSN);
        if(ETSPrimaryContactCSN <> '' && ETSPrimaryContactCSN <> NULL) accountCSNList.add(ETSPrimaryContactCSN);
        if(primaryContactCSN <> '' && primaryContactCSN <> NULL) accountCSNList.add(primaryContactCSN);
        if(additionalContactCSN <> '' && additionalContactCSN <> NULL) accountCSNList.add(additionalContactCSN);
        if(trainingOverviewContactCSN <> '' && trainingOverviewContactCSN <> NULL) accountCSNList.add(trainingOverviewContactCSN);
        if(omnicellRepresentativeContactCSN <> '' && omnicellRepresentativeContactCSN <> NULL) accountCSNList.add(omnicellRepresentativeContactCSN);
        if(ETSReportOverviewContactCSN <> '' && ETSReportOverviewContactCSN <> NULL) accountCSNList.add(ETSReportOverviewContactCSN);
        if(ETSTrainingPlanContactCSN <> '' && ETSTrainingPlanContactCSN <> NULL) accountCSNList.add(ETSTrainingPlanContactCSN);
        
        system.debug('accountCSNList-->'+accountCSNList);
        
        Map<String, Account> accountMap = New Map<String, Account>();
        
        for(Account acc : [SELECT id, SAP_Customer_Number__c, (SELECT Id, Name, Phone, Email FROM contacts) FROM Account WHERE SAP_Customer_Number__c IN :accountCSNList])
        {
            if(acc.SAP_Customer_Number__c <> NULL && acc.SAP_Customer_Number__c <> '')
            {
                accountMap.put(acc.SAP_Customer_Number__c, acc);
            }
        }
        system.debug('accountMap-->'+accountMap);
        
        ret_case.AccountId = NULL;
        if(ret_case.CSN__c <> NULL && ret_case.CSN__c <> '' && accountMap.containsKey(ret_case.CSN__c))
        {
            ret_case.AccountId = accountMap.get(ret_case.CSN__c).id;
        }
        
        system.debug('Pandora Owner-->'+lookUpUserField.containsKey(String.valueOf(ownerDetails.get('Name'))));
        if(lookUpUserField.containsKey(String.valueOf(ownerDetails.get('Name'))))
        {
            system.debug('pandora owner name -->'+lookUpUserField.get(String.valueOf(ownerDetails.get('Name'))));
            ret_case.OwnerId = lookUpUserField.get(String.valueOf(ownerDetails.get('Name')));
        }
        
        ret_case.ContactId = populateContacts(contactIdCSN, accountMap, contactIdDetails);    
        
        ret_case.IT_Contact__c = populateContacts(itContactCSN, accountMap, itContactDetails);
       
        ret_case.ETS_ProjPlanMeeting_Customer_Contact__c = populateContacts(ETSPrimaryContactCSN, accountMap, ETSPrimaryContactDetails);
        
        ret_case.Primary_customer_contact__c = populateContacts(primaryContactCSN, accountMap, primaryContactDetails);
        
        ret_case.Additional_Contact__c = populateContacts(additionalContactCSN, accountMap, additionalContactDetails);
       
        ret_case.TrainingOverviewContact__c = populateContacts(trainingOverviewContactCSN, accountMap, trainingOverviewContactDetails);
        
        ret_case.Omnicell_representative__c = populateContacts(omnicellRepresentativeContactCSN, accountMap, omnicellRepresentativeContactDetails);
                
        ret_case.ETSReportOverviewCustomer_lead__c = populateContacts(ETSReportOverviewContactCSN, accountMap, ETSReportOverviewContactDetails);
         
        ret_case.ETSTrainingPlanTraining_plan_recipient__c = populateContacts(ETSTrainingPlanContactCSN, accountMap, ETSTrainingPlanContactDetails);
        
        system.debug('ret_case-->'+ret_case.ownerId+':::'+ret_case);
        
        return ret_case;
    }
    
    public static String populateContacts(String contactCSN, Map<String, Account> accountMap, Map<String, Object> contactDetails)
    {
        if(contactCSN <> '' && contactCSN <> NULL && accountMap.containsKey(contactCSN))
        {
            for(Contact con : accountMap.get(contactCSN).contacts)
            {
                if(
                    (con.Name <>NULL && con.Name == String.valueOf(contactDetails.get('Name'))) 
                    || (con.Phone <> NULL && con.Phone == String.valueOf(contactDetails.get('Phone'))) 
                    || (con.Email <> NULL && 
                        (
                            con.Email == String.valueOf(contactDetails.get('Email'))+'.invalid'
                            ||
                            con.Email == String.valueOf(contactDetails.get('Email'))
                        )
                       )
                )
                {
                    return con.Id;
                }
            }
        }
        return null;
    }
}