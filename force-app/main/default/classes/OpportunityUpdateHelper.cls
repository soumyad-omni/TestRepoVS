global class OpportunityUpdateHelper implements Database.Batchable<Sobject>,Database.stateful{
    global Profile userProfile;
    global list<string> lstOpportunityId;
    
    global OpportunityUpdateHelper(){
        System.debug('@Developer --> OpportunityUpdateHelper -->');
    }
    
    global OpportunityUpdateHelper(list<string> lstOppId){
        System.debug('@Developer --> OpportunityUpdateHelper -->');
        System.debug('@Developer --> lstOppId :' + lstOppId);
        lstOpportunityId = lstOppId;
    }
    
    global Database.queryLocator start(Database.BatchableContext bc){
        System.debug('@Developer --> OpportunityUpdateHelper --> start --> timestamp:' + system.now());
        
        //local variable creation to use in query
        list<string> lstOppId = lstOpportunityId;
        
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1]){
            userProfile = p;
        }
        System.debug('@Developer --> userProfile :' + userProfile);
        
        String sSOQL = 'SELECT Id,CreatedDate ';
        sSOQL += ' ,(SELECT Id,Subject,Completed_Date__c,WhatId FROM Tasks WHERE WhatId != null AND Completed_Date__c != null ORDER BY createdDate DESC limit 1)';
        sSOQL += ', (SELECT Id,LastModifiedDate FROM Quotes Order By LastModifiedDate Desc) ';
        sSOQL += ', (SELECT Id, OpportunityId, CreatedDate, Field, DataType, OldValue, NewValue FROM Histories ORDER BY CreatedDate DESC)';
        sSOQL += ' FROM Opportunity ';	  
        
        string sWhere = '';
        
        if(!test.isRunningTest()){
            sWhere += ' WHERE (Activity_Last_Completed_Date__c = null OR Quote_Last_Modified_Date__c = null OR Last_Interaction_Date__c = null)';
        }
        
        if(lstOppId != null){ 
            if(sWhere.contains('WHERE')){
                sWhere += ' AND Id  IN :lstOppId ';    
            }
            else{
                sWhere += ' WHERE Id  IN :lstOppId ';    
            }
        }
        
        sSOQL += sWhere;
        
        if(test.isRunningTest()){
            sSOQL += ' limit 5 ';
        }
        
        System.debug('@Developer --> sSOQL:' + sSOQL);   
        return Database.getQueryLocator(sSOQL);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        System.debug('@Developer --> OpportunityUpdateHelper --> execute --> timestamp:' + system.now());
        map<Id,Opportunity> mapOpptoUpdate = new map<Id,Opportunity>();
        
        for(Opportunity o : scope){
            
            Opportunity opp = o;
            System.debug('@Developer --> Opportunity :' + opp);
            
            if(mapOpptoUpdate.containsKey (o.Id)){
                opp = mapOpptoUpdate.get (o.Id);
            }
            
            opp.Last_Update_on_Expected_Close_Date__c = opp.CreatedDate.date();
            opp.Last_Update_on_Expected_Install_Date__c = opp.CreatedDate.date();
            opp.Last_Update_on_Opportunity_Stage__c = opp.CreatedDate.date();
            opp.ForecastUpdate_Date__c = opp.CreatedDate.date();
            opp.Expected_Booking_Updated_Date__c = opp.CreatedDate.date();
            
            for(OpportunityFieldHistory ofh : opp.Histories) {
                System.debug('@Developer --> OpportunityFieldHistory :' + ofh);
                
                if(ofh.Field == 'CloseDate'){
                    System.debug('@Developer -->CloseDate:' );
                    if(opp.Last_Update_on_Expected_Close_Date__c < ofh.createdDate.date()){
                        opp.Last_Update_on_Expected_Close_Date__c = ofh.createdDate.date();    
                    }
                }
                
                if(ofh.Field == 'ExpectedInstallDate__c'){
                    System.debug('@Developer -->ExpectedInstallDate__c:' );
                    
                    if(opp.Last_Update_on_Expected_Install_Date__c < ofh.createdDate.date()){
                        opp.Last_Update_on_Expected_Install_Date__c = ofh.createdDate.date();  
                    }
                }   
                
                if(ofh.Field == 'StageName'){
                    System.debug('@Developer -->StageName:' );
                    
                    if(opp.Last_Update_on_Opportunity_Stage__c < ofh.createdDate.date()){
                        opp.Last_Update_on_Opportunity_Stage__c = ofh.createdDate.date();  
                    }
                }
                
                if(ofh.Field == 'Pipeline_Category__c'){
                    System.debug('@Developer -->Pipeline_Category__c:' );
                    
                    if(opp.ForecastUpdate_Date__c < ofh.createdDate.date()){
                        opp.ForecastUpdate_Date__c = ofh.createdDate.date();  
                    }
                }
                
                if(ofh.Field == 'Expected_Bookings__c'){
                    System.debug('@Developer -->Expected_Bookings__c:' );
                    
                    if(opp.Expected_Booking_Updated_Date__c < ofh.createdDate.date()){
                        opp.Expected_Booking_Updated_Date__c = ofh.createdDate.date(); 
                    }
                }	
                
                mapOpptoUpdate.put(opp.Id,opp);
            }
            System.debug('@Developer --> mapOpptoUpdate :' + mapOpptoUpdate);
            
            System.debug('@Developer --> opp.Tasks :' + opp.Tasks);
            
            for(Task tsk : opp.Tasks) {
                opp.Activity_Last_Completed_Date__c = tsk.Completed_Date__c.date();
                System.debug('@Developer --> opp.Activity_Last_Completed_Date__c:' + opp.Activity_Last_Completed_Date__c);
                mapOpptoUpdate.put(opp.Id,opp);
            }
            System.debug('@Developer --> mapOpptoUpdate :' + mapOpptoUpdate);
            
            if(opp.Tasks.isEmpty()) {
                opp.Activity_Last_Completed_Date__c = NULL;
                mapOpptoUpdate.put(opp.Id,opp);
            }
            
            Date qtNonAdminIntegrationLastMofiedDate = null;
            Date qfhNonAdminIntegrationCreatedDate = null;
            Date qtCreatedDate = null;
            
            for(Quote qt : [SELECT Id,LastModifiedDate,CreatedDate,LastModifiedBy.Name, 
                            (SELECT Id, Quote__c, CreatedDate /*, FIELD__c, ORIGINAL_VALUE__c, NEW_VALUE__c */
                             FROM Quote_Field_Histories__r 
                             WHERE CreatedBy.Name != 'Admin Integration'
                             AND CreatedBy.Profile.Name != 'System Administrator'
                             AND CreatedBy.Profile.Name != 'Business Administrator'
                             ORDER BY CreatedDate DESC LIMIT 1) 
                            FROM Quote 
                            WHERE Id In :opp.Quotes 
                            ORDER BY LastModifiedDate DESC]) 
            {
                System.debug('@Developer --> Quote :' + qt);
                
                qtCreatedDate = qt.CreatedDate.date();
                
                System.debug('@Developer --> qt.LastModifiedBy.Name :' + qt.LastModifiedBy.Name);
                if(qt.LastModifiedBy.Name != 'Admin Integration'){
                    if(qtNonAdminIntegrationLastMofiedDate == null){
                        qtNonAdminIntegrationLastMofiedDate = qt.LastModifiedDate.date();
                    }
                }
                
                for(Quote_Field_History__c qfh : qt.Quote_Field_Histories__r){
                    System.debug('@Developer --> Quote_Field_History :' + qfh);
                    
                    if(qfhNonAdminIntegrationCreatedDate == null || qfh.CreatedDate.date() > qfhNonAdminIntegrationCreatedDate){
                        System.debug('@Developer --> qfh.CreatedDate.date() :' + qfh.CreatedDate.date());
                        qfhNonAdminIntegrationCreatedDate = qfh.CreatedDate.date();
                    }
                }
            }
            
            System.debug('@Developer --> qtNonAdminIntegrationLastMofiedDate :' + qtNonAdminIntegrationLastMofiedDate);
            System.debug('@Developer --> qfhNonAdminIntegrationCreatedDate :' + qfhNonAdminIntegrationCreatedDate);
            System.debug('@Developer --> qtCreatedDate :' + qtCreatedDate);
            
            if(qtNonAdminIntegrationLastMofiedDate != null && qfhNonAdminIntegrationCreatedDate != null){
                if(qfhNonAdminIntegrationCreatedDate > qtNonAdminIntegrationLastMofiedDate){
                    opp.Quote_Last_Modified_Date__c = qfhNonAdminIntegrationCreatedDate;
                    mapOpptoUpdate.put(opp.Id,opp);
                }
                else{
                    opp.Quote_Last_Modified_Date__c = qtNonAdminIntegrationLastMofiedDate;
                    mapOpptoUpdate.put(opp.Id,opp);
                }
            }
            else if(qtNonAdminIntegrationLastMofiedDate != null){
                opp.Quote_Last_Modified_Date__c = qtNonAdminIntegrationLastMofiedDate;
                mapOpptoUpdate.put(opp.Id,opp);
            }
            else if(qfhNonAdminIntegrationCreatedDate != null){
                opp.Quote_Last_Modified_Date__c = qfhNonAdminIntegrationCreatedDate;
                mapOpptoUpdate.put(opp.Id,opp);
            }
            else{
                opp.Quote_Last_Modified_Date__c = qtCreatedDate;
                mapOpptoUpdate.put(opp.Id,opp);
            }
            
            /*for(Quote qt : opp.Quotes) {
            if((userProfile.Name != 'System Administrator' && userProfile.Name != 'Business Administrator')|| test.isRunningTest()) {
            opp.Quote_Last_Modified_Date__c = qt.LastModifiedDate.date();
            System.debug('@Developer --> opp.Quote_Last_Modified_Date__c:' + opp.Quote_Last_Modified_Date__c);
            mapOpptoUpdate.put(opp.Id,opp);
            }
            }*/
            
            if(opp.Quotes.isEmpty()){
                opp.Quote_Last_Modified_Date__c = NULL;
                mapOpptoUpdate.put(opp.Id,opp);
            }
        }
        
        System.debug('@Developer --> mapOpptoUpdate.size():' + mapOpptoUpdate.size());
        
        if(mapOpptoUpdate.size() > 0){
            
            //update mapOpptoUpdate.values();
            list<database.SaveResult> lstSaveResult = Database.update(mapOpptoUpdate.values(),false);
            for (Database.SaveResult sr : lstSaveResult){
                if(sr.isSuccess()){
                    System.debug('@Developer --> Processed :' + sr.getId());
                }
                else{
                    String sErr = '';
                    for(Database.Error err : sr.getErrors()) {                                             
                        sErr = err.getStatusCode() + ' - ' + err.getMessage();
                        System.debug('@Developer --> sErr :' + sErr);
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('@Developer --> OpportunityUpdateHelper --> finish --> timestamp:' + system.now()); 	 
        
    }
    
}