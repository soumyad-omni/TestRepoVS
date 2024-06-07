global class BatchKlarityDataUpload implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global String query;
    global String QuoteStatus = '(\'E0013\', \'E0014\', \'E0019\', \'E0023\', \'E0024\')';
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'select echosign_dev1__SignedPDF__c,echosign_dev1__StatusVisible__c,Id,ProcessedForKlarity__c,QuoteInfo__c,'+
            'Quote_Approval__r.Status__c,QuoteOrderType__c,QuoteStatus__c,Quote_Approval__r.Quote__r.Primary_Quote__c,Quote_Approval__r.id,'+
            'Quote_Approval__r.Opportunity_Status__c,Quote_Approval__r.name,Quote_Approval__r.Quote__r.id,Quote_Approval__r.Quote__r.name,'+
            'Quote_Approval__r.Quote__r.Master_Agreement__c,Quote_Approval__r.Quote__r.ECC_Sales_Order_Number__c,Quote_Approval__r.Quote__r.Account_CSN__c,'+
            'Quote_Approval__r.Account_Name__c, Quote_Approval__r.Quote__r.Account_ID__c, Quote_Approval__r.Opportunity_Name__c,Quote_Approval__r.Opportunity_Close_Date__c,'+
            'Quote_Approval__r.Quote__r.OpportunityId,Quote_Approval__r.Opportunity_Number__c, Quote_Approval__r.AccountCaseSafeID__c,Contracts__c,'+
            'Contracts__r.name,Contracts__r.account__r.name,Contracts__r.account__r.id,Contracts__r.account__r.SAP_Customer_Number__c,'+
            'Contracts__r.account__r.RecordTypeID,Contracts__r.account__r.texcellency__DefHC_HospitalID__c,	Contracts__r.account__r.Definitive_Id__c,'+
            'Contracts__r.account__r.Top_Level_CaseSafeID__c,Contracts__r.account__r.Country_Cluster__c,Contracts__r.account__r.Top_level_2__c,'+
            'Contracts__r.account__r.Top_Level_Parent_CSN_Number__c,Contracts__r.account__r.Master_Agreement__c,Quote_Approval__r.Quote__r.Opportunity_Record_Type__c,'+
            'echosign_dev1__Document_Key__c, Quote_Approval__r.Quote__r.Account_region__c, Quote_Approval__r.Quote__r.Division__c, Quote_Approval__r.Account_Country_Cluster__c,Quote_Approval__r.AccountTerritory__c'+
            ' FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__SignedPDF__c != null'+
            ' AND echosign_dev1__StatusVisible__c = \'Signed\' AND Quote_Approval__c != null AND Quote_Approval__r.Quote__r.Primary_Quote__c = true AND ProcessedForKlarity__c = false AND CreatedDate >=' + Label.KlarityUploadDate + 
            ' and QuoteStatus__c in '+ QuoteStatus + 'and Quote_Approval__r.Status__c = \'Approved\'';
           
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<echosign_dev1__SIGN_Agreement__c> signedDocuments){
        String NAARecTypeId = SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        List<echosign_dev1__SIGN_Agreement__c> ProcessedDocs = new List<echosign_dev1__SIGN_Agreement__c>();
        list<ContentVersion> CVList = new list<ContentVersion>();
        list<ContentDistribution> CDList = new list<ContentDistribution>();
        Map<String, ContentDistribution> ctd = new Map<String, ContentDistribution>(); //IBA-5326 SH
        String jsonArrCon = '';
        String jsonArrQAP = '';
        String finalJson = '';
        //system.debug('signedDocuments.. '+signedDocuments.size());
        
        // Doc Start
        try{
            for(echosign_dev1__SIGN_Agreement__c sa: signedDocuments){
                if(sa.Quote_Approval__c != null &&
                   //sa.Quote_Approval__r.Quote__r.Opportunity_Record_Type__c == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId() &&
                   (sa.Quote_Approval__r.Quote__r.Opportunity_Record_Type__c == OpportunityTriggerHandler.opptyRecordTypeNameId('NAA_Opportunity','Id') ||
                    sa.Quote_Approval__r.Quote__r.Opportunity_Record_Type__c == OpportunityTriggerHandler.opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') ||
                    sa.Quote_Approval__r.Quote__r.Opportunity_Record_Type__c == OpportunityTriggerHandler.opptyRecordTypeNameId('US_Canada_Specialty','Id')) &&	//IBA-5992
                   sa.Quote_Approval__r.Status__c == 'Approved' &&
                   sa.Quote_Approval__r.Quote__r.Primary_Quote__c == true &&
                   (sa.Quote_Approval__r.Opportunity_Status__c == Label.Non_Comissionable_Booking ||
                    sa.Quote_Approval__r.Opportunity_Status__c == Label.Commissionable_Book_No_Service_PO ||
                    sa.Quote_Approval__r.Opportunity_Status__c == Label.Non_Comm_Book_No_Service_PO ||
                    sa.Quote_Approval__r.Opportunity_Status__c == Label.Non_Comm_Book_No_Proj_Plan ||
                    sa.Quote_Approval__r.Opportunity_Status__c == Label.Fully_Booked) &&
                   (sa.QuoteStatus__c == 'E0013' ||
                    sa.QuoteStatus__c == 'E0014' ||
                    sa.QuoteStatus__c == 'E0019' ||
                    sa.QuoteStatus__c == 'E0023' ||
                    sa.QuoteStatus__c == 'E0024')){
                        Attachment a = [SELECT id, name, body, ParentId FROM Attachment WHERE ParentId =: sa.Id order by CreatedDate desc limit 1];
                        ContentVersion cont = new ContentVersion();
                        cont.Title = a.ParentId + '.pdf';
                        cont.PathOnClient =  a.Name;
                        cont.VersionData = a.Body;
                        CVList.add(cont);
                    }
            }
        
        	//ContentDocLinkTriggerHandler.TriggerDisabled = true; need to check
        	Insert CVList;
        
            for(ContentVersion cont : CVList){
                ContentDistribution cd = new ContentDistribution();
                cd.name = cont.Title;
                cd.ContentVersionId = cont.id;
                cd.PreferencesAllowOriginalDownload = true;
                cd.PreferencesAllowPDFDownload = true;
                cd.PreferencesAllowViewInBrowser = true;
                CDList.add(cd);
            }
        
            Insert CDList;
            
            for(ContentDistribution cd : [SELECT Name, ContentDownloadUrl, PdfDownloadUrl FROM ContentDistribution WHERE id In :CDList]){ //IBA-5326 SH
                ctd.put(cd.name,cd);
            }
            // Doc End
        
            
            for(echosign_dev1__SIGN_Agreement__c sa: signedDocuments){
                if(sa.Quote_Approval__c != null &&
                   //sa.Quote_Approval__r.Quote__r.Opportunity_Record_Type__c == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId() &&
                   (sa.Quote_Approval__r.Quote__r.Opportunity_Record_Type__c == OpportunityTriggerHandler.opptyRecordTypeNameId('NAA_Opportunity','Id') ||
                    sa.Quote_Approval__r.Quote__r.Opportunity_Record_Type__c == OpportunityTriggerHandler.opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') ||
                    sa.Quote_Approval__r.Quote__r.Opportunity_Record_Type__c == OpportunityTriggerHandler.opptyRecordTypeNameId('US_Canada_Specialty','Id')) &&	//IBA-5992
                   sa.Quote_Approval__r.Status__c == 'Approved' &&
                   sa.Quote_Approval__r.Quote__r.Primary_Quote__c == true &&
                   (sa.Quote_Approval__r.Opportunity_Status__c == Label.Non_Comissionable_Booking ||
                    sa.Quote_Approval__r.Opportunity_Status__c == Label.Commissionable_Book_No_Service_PO ||
                    sa.Quote_Approval__r.Opportunity_Status__c == Label.Non_Comm_Book_No_Service_PO ||
                    sa.Quote_Approval__r.Opportunity_Status__c == Label.Non_Comm_Book_No_Proj_Plan ||
                    sa.Quote_Approval__r.Opportunity_Status__c == Label.Fully_Booked) &&
                   (sa.QuoteStatus__c == 'E0013' ||
                    sa.QuoteStatus__c == 'E0014' ||
                    sa.QuoteStatus__c == 'E0019' ||
                    sa.QuoteStatus__c == 'E0023' ||
                    sa.QuoteStatus__c == 'E0024')){
                        String AttachmentId = sa.id + '.pdf';
                        ContentDistribution cd = ctd.get(AttachmentId); //replaced [SELECT ContentDownloadUrl, PdfDownloadUrl FROM ContentDistribution WHERE Name =: AttachmentId limit 1] from ctd.get(AttachmentId) IBA-5326  
                        String AccountID = sa.Quote_Approval__r.AccountCaseSafeID__c;
                        String AccountNAME = sa.Quote_Approval__r.Account_Name__c;
                        String AccountCSN = sa.Quote_Approval__r.Quote__r.Account_CSN__c;
                        String OpportunityID = sa.Quote_Approval__r.Quote__r.OpportunityId;
                        String OpportunityNAME = sa.Quote_Approval__r.Opportunity_Name__c;
                        String OpportunityNUMBER = sa.Quote_Approval__r.Opportunity_Number__c;
                        String QuoteID = sa.Quote_Approval__r.Quote__r.id;
                        String QuoteNAME = sa.Quote_Approval__r.Quote__r.name;
                        String MasterAgreementNUMBER = sa.Quote_Approval__r.Quote__r.Master_Agreement__c;
                        String ECCSONUMBER = sa.Quote_Approval__r.Quote__r.ECC_Sales_Order_Number__c;
                        String QAPID = sa.Quote_Approval__r.id;
                        String QAPNUMBER = sa.Quote_Approval__r.name;
                        String AgreementID = sa.Id;
                        String Expected_Close_Date = string.valueof(sa.Quote_Approval__r.Opportunity_Close_Date__c);
                        String Document_Key = sa.echosign_dev1__Document_Key__c;
                        String Country_Cluster = sa.Quote_Approval__r.Account_Country_Cluster__c;
                        String Division = sa.Quote_Approval__r.Quote__r.Division__c;
                        String Region = sa.Quote_Approval__r.Quote__r.Account_region__c;
                        String Account_Territory = sa.Quote_Approval__r.AccountTerritory__c;
                        String AgreementSignedPDFURL = cd.PdfDownloadUrl;
                        
                        String jsonQAP = '{"AccountID" : "'+AccountID+'","AccountNAME": "'+AccountNAME+'","AccountCSN": "'+AccountCSN+'","OpportunityID": "'+OpportunityID+'","OpportunityNAME": "'+OpportunityNAME+'","OpportunityNUMBER": "'+OpportunityNUMBER+'","QuoteID": "'+QuoteID+'","QuoteNAME": "'+QuoteNAME+'","MasterAgreementNUMBER": "'+MasterAgreementNUMBER+'","ECCSONUMBER": "'+ECCSONUMBER+'","QAPID": "'+QAPID+'","QAPNUMBER": "'+QAPNUMBER+'","AgreementID": "'+AgreementID+'","AgreementSignedPDFURL": "'+AgreementSignedPDFURL+'","Expected_Close_Date": "'+Expected_Close_Date+'","Document_Key": "'+Document_Key+'","Country_Cluster": "'+Country_Cluster+'","Division": "'+Division+'","Region": "'+Region+'","Account_Territory": "'+Account_Territory+'"}';
                        jsonArrQAP = jsonArrQAP +jsonQAP+',';
                        //sa.ProcessedForKlarity__c = true; Commented as part of IBA-5772 as mulesoft is updating this field now SH
                        
                        //ProcessedDocs.add(sa); Commented as part of IBA-5772 as mulesoft is updating this field now SH
                    }
                
            } // for loop ends
            
            
            
            jsonArrCon = jsonArrCon.removeEnd(',');
            jsonArrCon = '"Contracts": ' + '['+jsonArrCon+']';
            
                        
            if(!String.isEmpty(jsonArrQAP)){ //added this if check as part of IBA-5772            
                jsonArrQAP = jsonArrQAP.removeEnd(',');
                jsonArrQAP = '"QAP": ' + '['+jsonArrQAP+']';
                
            	finalJson = '{'+jsonArrCon+','+jsonArrQAP+'}';
            }
            
            if(!String.isEmpty(finalJson)){ //added this if check as part of IBA-5772
                KlarityCalloutQueueable job = new KlarityCalloutQueueable();
                job.FinalJSON = finalJson;
                //job.Processed_Docs = ProcessedDocs; Commented as part of IBA-5772 as mulesoft is updating this field now SH
                if(!Test.isRunningTest()){
                    System.enqueueJob(job);
                }                
            }
            
        }catch(Exception ex){
            System.debug('KlarityException : '+ex.getMessage()+' Line no. : '+ex.getLineNumber());
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}