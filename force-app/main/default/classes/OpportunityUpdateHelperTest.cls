@isTest
private class OpportunityUpdateHelperTest {
    @isTest private static void unitTest(){
        Profile lstProfile = [select id, name from Profile where name ='Sales Manager' limit 1];
        User retUser = new User();
        retUser.FirstName = 'firstName';
        retUser.LastName = 'lastName';
        retUser.UserName = retUser.FirstName + '.' + retUser.LastName + '@unitTest.com';
        
        retUser.Email = 'testusermail@omnicell.com';
        retUser.Alias = retUser.FirstName.substring(0, 1) + retUser.LastName.left(7);
        retUser.CommunityNickname = retUser.FirstName + ' ' + retUser.LastName;
        retUser.TimeZoneSidKey = 'America/New_York';
        retUser.LocaleSidKey = 'en_US';
        retUser.EmailEncodingKey = 'UTF-8';
        retUser.LanguageLocaleKey = 'en_US';
        retUser.User_Division__c = 'Inside';
        retUser.User_Territory__c = 'Inside';
        retUser.Position_Name__c = 'Bookings Team';
        retUser.Country_Cluster__c = 'US&CA';
        retUser.Region_User__c = 'Central';
        retUser.Division__c = 'Atlantic';
        retUser.Territory__c = 'East OH';
        retUser.ProfileId = lstProfile.Id;
        insert retUser;
        
        string opp1;
        System.runAs(retUser){
            Id recTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Customer').getRecordTypeId();
            Account acc=new Account();
            acc.name='Test Account';
            acc.BillingCity='Musterstadt';
            acc.BILLINGSTREET = '41 Moss';
            acc.BillingCountry = 'United States';
            acc.BillingState = 'Alabama';
            acc.BillingPostalCode = '77777';
            acc.Account_role__c='ZCSN';
            acc.Recordtypeid=recTypeAccount;
            acc.Facility_Type__c = 'Pharmacy';
            acc.Transportation_Zone_Country__c = 'AQ';
            acc.Transport_Zone__c = 'IN00000001';
            
            insert acc;
            
            Contact retCon = new Contact();
            retCon.AccountId = acc.Id;
            retCon.FirstName = 'test ';
            retCon.LastName = 'Contact';
            retCon.SAP_Contact_ID__c = '1234';
            insert retCon;
            
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.name = 'Test Opportunity';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today() + 28;
            opp.ExpectedInstallDate__c = System.today() + 60;
            insert opp;
            
            opp1 = opp.Id;
            
            
            
            Task newTask = new Task();
            newTask.Subject = 'Follow up on inquiry';
            newTask.WhatId = opp1;
            //newTask.Status = 'Completed';
            newTask.Completed_Date__c = System.today()+60;
            insert newTask;
            System.debug('@Developer --> newTask :' + newTask);
            
            System.debug('@Developer --> newTask.whatId :' + newTask.whatId);
            System.debug('@Developer --> opp1 :' +opp1);
            
            System.debug('@Developer --> newTask :' + [SELECT Id,Subject,Completed_Date__c,WhatId FROM Task WHERE WhatId = :opp1]);
            
            Quote q = new Quote();
            q.name = 'Quote-' + opp.name;
            q.opportunityId = opp1;
            q.Order_Type__c = 'ZQR';
            q.Shipping_Contact__c = retCon.Id;
            insert q;
            
            
            Quote_Field_History__c qfh = new Quote_Field_History__c();
            
            qfh.Quote__c = q.id;
            qfh.FIELD__c = 'Order_Type__c';
            qfh.ORIGINAL_VALUE__c = String.valueof(q.Account_CSN__c);
            qfh.NEW_VALUE__c = String.valueof(q.Account_CSN__c);
            insert qfh;
            
            list<Quote_Field_History__c>lst = [SELECT Id, Quote__c, CreatedDate,CreatedBy.Name ,CreatedBy.Profile.Name/*, FIELD__c, ORIGINAL_VALUE__c, NEW_VALUE__c */
                                               FROM Quote_Field_History__c where Quote__c = :q.Id limit 1
                                              ];
            system.debug('qfh==> '+ lst[0].CreatedBy.Name + lst[0].CreatedBy.Profile.Name );
            
            CastIronIntegration__c  setting = new CastIronIntegration__c ();
            setting.Name = 'CastIronIntegration';
            setting.EndPoint__c = 'https://castirondev.omnicell.com';
            setting.Print_Compare_End_Point__c = 'https://printcastirondev.omnicell.com';
            setting.compare_button_endpoint__c = 'https://castirondatadev.omnicell.com/QuotePrintOutSFDCtoSAPtoSFDCUAT';
            setting.compare_button_timeout__c = '120000';
            insert setting;
            
            
            ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
            setting1.Name = 'AU SalesOrg Omnicell';
            setting1.CRM_Code__c = 'O 50008662';
            insert setting1;
            
            
            ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
            setting2.Name = 'MACH4 - GmbH';
            setting2.CRM_Code__c = 'O 50008662';
            insert setting2;
            
            ECC_Sales_Org_to_CRM__c  setting3 = new ECC_Sales_Org_to_CRM__c ();
            setting3.Name = 'Omnicell - St.Petes';
            setting3.CRM_Code__c = 'O 50008663';
            insert setting3;
            
            ECC_Sales_Org_to_CRM__c  setting4 = new ECC_Sales_Org_to_CRM__c ();
            setting4.Name = 'Omnicell Inc.';
            setting4.CRM_Code__c = 'O 50000029';
            insert setting4;
            
            ECC_Sales_Org_to_CRM__c  setting5 = new ECC_Sales_Org_to_CRM__c ();
            setting5.Name = 'Omnicell Ltd';
            setting5.CRM_Code__c = 'O 50008655';
            insert setting5;
            
            ECC_Sales_Org_to_CRM__c  setting6 = new ECC_Sales_Org_to_CRM__c ();
            setting6.Name = 'Omnicell SAS';
            setting6.CRM_Code__c = 'O 50011128';
            insert setting6;
        }
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(opp1, yesterday); 
        Test.startTest();
        
        list<OpportunityFieldHistory> lstOFH = new list<OpportunityFieldHistory>();
        OpportunityFieldHistory ofh;
        
        ofh = new OpportunityFieldHistory(OpportunityId = opp1, Field = 'StageName'); 
        lstOFH.add(ofh);
        
        ofh = new OpportunityFieldHistory(OpportunityId = opp1, Field = 'CloseDate'); 
        lstOFH.add(ofh);
        
        ofh = new OpportunityFieldHistory(OpportunityId = opp1, Field = 'ExpectedInstallDate__c'); 
        lstOFH.add(ofh);
        
        ofh = new OpportunityFieldHistory(OpportunityId = opp1, Field = 'Pipeline_Category__c'); 
        lstOFH.add(ofh);
        
        ofh = new OpportunityFieldHistory(OpportunityId = opp1, Field = 'Expected_Bookings__c'); 
        lstOFH.add(ofh);
        
        insert lstOFH;
        
        // list<OpportunityFieldHistory>lst = [SELECT Id, OpportunityId, CreatedDate, Field, DataType, OldValue, NewValue FROM OpportunityFieldHistory where OpportunityId = :opp.id];
        System.debug('@Developer --> ### :' + [SELECT Id, OpportunityId, CreatedDate, Field, OldValue, NewValue FROM OpportunityFieldHistory Where Opportunityid = :opp1 Order By CreatedDate Desc]);	
        //System.debug('lst===> '+lst);
        OpportunityUpdateHelper ba= new OpportunityUpdateHelper(new list<String>{opp1});
        Id jobid= Database.executeBatch(ba);
        Test.stopTest();
        
    }
}