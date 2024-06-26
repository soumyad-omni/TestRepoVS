// This class allows advanced customizations for the mapping of records from SAPC4CAssets_SaFoRePr__c to C4C_Assets__c.
//
// Scenario: SAPC4CAssets
// Source Object: SAPC4CAssets_SaFoRePr__c
// Target Object: C4C_Assets__c
// Mapping Record Name: c
// Direction: Inbound
// 
// Generated by Overcast 2018-10-29 19:41:08Z
// Your changes will not be overwritten when resaving the mapping.
//
global class Mapping_c {//implements overcast.ObjectMapping.EventPlugin, overcast.ObjectMapping.BatchableEventPlugin {//Commented by Sourav for Overcast uninstall
   
   //========================================Custom Code To Map C4C Assets with Accounts -- Sambhavi Amarapalli --- Start==============================
    private Map<String, String> mapSAPCustomerToAccountID = new Map<String, String>();
    //==============================================Custom Code To Map C4C Assets with Accounts -- Sambhavi Amarapalli --- End===========================
    /*
    global void execute(overcast__Run__c scenarioExecution, SAPC4CAssets_SaFoRePr__c[] records) {
        overcast.EpgwController.MappingConfig config = new overcast.EpgwController.MappingConfig('SAPC4CAssets_SaFoRePr__c', records);
        config.rollbackOnError = true;
        config.eventplugin = this;
        config.mappings = [SELECT overcast__Target__c, overcast__Map__c, overcast__Joins__c
                    FROM overcast__IntegrationFieldMap__c 
                    WHERE overcast__ApexClass__c = 'Mapping_c'];
        
        m_execution = scenarioExecution;
        m_loglevel = GetLogLevel(scenarioExecution.Id);
        
        //===================================Custom Code To Map C4C Assets with Accounts -- Sambhavi Amarapalli --- Start===================================
        
        Set<String> setCustomerNumber = new Set<String>();
        for (SAPC4CAssets_SaFoRePr__c sa : records) {
            setCustomerNumber.add(sa.ShipToAccountID__c); 
        }
        for(Account objAccount : [SELECT Id, Name, SAP_Customer_Number__c FROm Account WHERE SAP_Customer_Number__c IN: setCustomerNumber]){
            mapSAPCustomerToAccountID.put(objAccount.SAP_Customer_Number__c, objAccount.Id);
        }
        
        //====================================Custom Code To Map C4C Assets with Accounts -- Sambhavi Amarapalli --- End===================================
        
        overcast.EpgwController.RunMappingTrigger(config);
    
        this.saveLogs();   
    }

    // Begin ObjectMapping.EventPlugin interface implementation

    // BeforeUpsert Is called for each record that will be inserted/updated into the target object.
    // If the target record has an ID it will be updated, otherwise inserted.
    // Return true to accept the record for insert/update. False to reject the record.
    global boolean beforeUpsert(sobject sourceRecord, sobject targetRecord) {
      
      //================================================Custom Changes for C4C Assets Mapping -- Start====================================================
        SAPC4CAssets_SaFoRePr__c source = (SAPC4CAssets_SaFoRePr__c) sourceRecord;
        C4C_Assets__c target = (C4C_Assets__c)targetRecord;
        if(source.ShipToAccountID__c != null && mapSAPCustomerToAccountID.containsKey(source.ShipToAccountID__c) && mapSAPCustomerToAccountID.get(source.ShipToAccountID__c) != null){
            logInfo('Mapping record with ShipToAccountID [' + source.ShipToAccountID__c + ']');
            target.Account__c = mapSAPCustomerToAccountID.get(source.ShipToAccountID__c);
            return true;
        }
        
        logWarning('Skipping record with ShipToAccountID [' + source.ShipToAccountID__c + ']');
        return false;
        
        //=============================================Custom Changesfor C4C Assets Mapping -- End ===========================================
    }
                
    // AfterInsert Is called after both insert And update DML operations are successfull. 
    // If rollbackOnError Is true And a DML exception occurs when inserting Or updating, the transaction Is rolled back And AfterInsert Is Not called.
    // If rollbackOnError Is false And a DML exception occurs when inserting Or updating, AfterInsert Is called And saveResults will contain the error messages.
    global void afterInsert(sobject[] insertedRecords, Database.SaveResult[] saveResults) { 
        for (Database.Saveresult r : saveResults) {
            if (!r.isSuccess()) {
                logWarning(r.getErrors()[0].getMessage());
                setStatusToWarning();
            }
        } 
    }
        
    // AfterUpdate Is called after both insert And update DML operations are successfull. 
    // If rollbackOnError Is true And a DML exception occurs when inserting Or updating, the transaction Is rolled back And AfterUpdate Is Not called.
    // If rollbackOnError Is false And a DML exception occurs when inserting Or updating, AfterUpdate Is called And saveResults will contain the error messages.
    global void afterUpdate(sobject[] updatedRecords, Database.SaveResult[] saveResults) {  
        for (Database.Saveresult r : saveResults) {
            if (!r.isSuccess()) {
                logWarning(r.getErrors()[0].getMessage());
                setStatusToWarning();
            }
        } 
    }

    // End of interface implementation
        
    // Begin helper methods        
        
    // Log an error message to the scenario execution log
    global void logError(String message) {
        if (m_loglevel >= 1) {
            logs.add(new overcast__Log__c(overcast__Run__c=m_execution.Id, overcast__Message__c='[Mapping_c] ' + message, overcast__LogLevel__c = 'ERROR', overcast__Time__c=DateTime.now()));            
        }
    }
        
    // Log an warning message to the scenario execution log        
    global void logWarning(String message) {
        if (m_loglevel >= 3) {
            logs.add(new overcast__Log__c(overcast__Run__c=m_execution.Id, overcast__Message__c='[Mapping_c] ' + message, overcast__LogLevel__c = 'WARN', overcast__Time__c=DateTime.now()));        
        }
    }
        
    // Log an info message to the scenario execution log
    global void logInfo(String message) {
        if (m_loglevel >= 4) {
            logs.add(new overcast__Log__c(overcast__Run__c=m_execution.Id, overcast__Message__c='[Mapping_c] ' + message, overcast__LogLevel__c = 'INFO', overcast__Time__c=DateTime.now()));
        }
    } 

    // Log a debug message to the scenario execution log
    global void logDebug(String message) {
        if (m_loglevel >= 5) {
            logs.add(new overcast__Log__c(overcast__Run__c=m_execution.Id, overcast__Message__c='[Mapping_c] ' + message, overcast__LogLevel__c = 'DEBUG', overcast__Time__c=DateTime.now()));
        }
    }
        
    // Set the scenario execution status to error
    global void setStatusToError() {
        this.m_execution.overcast__StatusCode__c = 400;
    }
        
    // Set the scenario execution status to warning
    global void setStatusToWarning() {
        this.m_execution.overcast__StatusCode__c = 500;
    }
        
    global void saveLogs() {
        If (!logs.isempty()) {
            insert logs;
        }
        update m_execution;

        logs.clear();
    }
        
    // End helper methods
            
    private final List<overcast__Log__c> logs = new List<overcast__Log__c>();
    
    @testvisible
    private overcast__Run__c m_execution;   
    
    private integer m_loglevel = 4;
            
    private static integer GetLogLevel(Id runid) {
        string base = GetLogLevel();
        overcast__Run__c run = [SELECT overcast__Scenario__r.overcast__LogLevel__c FROM overcast__Run__c WHERE Id = :runId];
        string selected = run.overcast__Scenario__r.overcast__LogLevel__c != null ? run.overcast__Scenario__r.overcast__LogLevel__c : base;
        
        return GetLogLevelValue(selected);
    }
    
    @testvisible
    private static integer GetLogLevelValue(string ll)
    {
        if (ll == null) return 4;
        ll = ll.toUpperCase();
        if (ll == 'DEBUG') return 5;
        if (ll == 'INFO') return 4;
        if (ll == 'WARN') return 3;
        if (ll == 'ERROR') return 2;
        if (ll == 'FATAL') return 1;
        if (ll == 'NONE') return 0;
        if (ll == 'VERBOSE') return 6;
        return 4;
    }
    
    private static string GetLogLevel()
    {
        overcast__EpgwSettings__c ll = overcast__EpgwSettings__c.getInstance('LogLevel');
        if (ll == null) return null;
        return ll.overcast__Value__c;
    }*///Commented by Sourav for Overcast uninstall
}