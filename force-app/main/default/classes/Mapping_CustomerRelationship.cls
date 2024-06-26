// This class allows advanced customizations for the mapping of records from sapCustomerDetail_GT_CUST_PF__c to Relationship__c.
//
// Scenario: sapCustomerDetail
// Source Object: sapCustomerDetail_GT_CUST_PF__c
// Target Object: Relationship__c
// Mapping Record Name: CustomerRelationship
// Direction: Inbound
// 
// Generated by Overcast 2018-09-11 19:13:49Z
// Your changes will not be overwritten when resaving the mapping.
//
global class Mapping_CustomerRelationship{ // implements overcast.ObjectMapping.EventPlugin, overcast.ObjectMapping.BatchableEventPlugin { //Commented by Sourav for Overcast uninstall
    // Custom: maps to relate KUNNR to AccountId, SAP_Sales_Org CompoundKey__c to Id
    /*private Map<String,Id> kunnrToAccountIds = new Map<String,Id>();
    private Map<String, Id> relationshipCompoundKeyToIds = new Map<String, Id>();    
    private Map<String, Id> salesOrgCompoundKeyToIds = new Map<String, Id>();
    // End custom
    
    global void execute(overcast__Run__c scenarioExecution, sapCustomerDetail_GT_CUST_PF__c[] records) {
        overcast.EpgwController.MappingConfig config = new overcast.EpgwController.MappingConfig('sapCustomerDetail_GT_CUST_PF__c', records);
        config.rollbackOnError = true;
        config.eventplugin = this;
        config.mappings = [SELECT overcast__Target__c, overcast__Map__c, overcast__Joins__c
                    FROM overcast__IntegrationFieldMap__c 
                    WHERE overcast__ApexClass__c = 'Mapping_CustomerRelationship'];

        m_execution = scenarioExecution;
        m_loglevel = GetLogLevel(scenarioExecution.Id);

        // Custom: get AccountIds and the SAP_Sales_Orgs for all KUNNRs in the record set
        Set<String> kunnrs = new Set<String>();
        Set<String> customerSalesAreas = new Set<String>();
        Set<String> customerRelationships = new Set<String>();
        for (sapCustomerDetail_GT_CUST_PF__c pf : records) {
            kunnrs.add(pf.KUNNR__c);
            kunnrs.add(pf.KUNN2__c);
            customerSalesAreas.add(pf.CustomerSalesAreaKey__c);
            customerRelationships.add(pf.CompoundKey__c);
        }
        for (Account refAccount : [SELECT Id, SAP_Account_ID__c FROM Account WHERE SAP_Account_ID__c IN :kunnrs LIMIT 1000]) {
            kunnrToAccountIds.put(refAccount.SAP_Account_ID__c, refAccount.Id);
        }
        for (SAP_Sales_Org__c sa : [SELECT Id, CompoundKey__c FROM SAP_Sales_Org__c WHERE CompoundKey__c IN :customerSalesAreas LIMIT 1000]) {
            salesOrgCompoundKeyToIds.put(sa.CompoundKey__c, sa.Id);
        }
        for (Relationship__c rel : [SELECT Id, CompoundKey__c FROM Relationship__c WHERE CompoundKey__c IN :customerRelationships LIMIT 1000]) {
            relationshipCompoundKeyToIds.put(rel.CompoundKey__c, rel.Id);
        }
        System.debug(LoggingLevel.INFO, relationshipCompoundKeyToIds);
        // End custom  
        
        overcast.EpgwController.RunMappingTrigger(config);
    
        this.saveLogs();    
    }

    // Begin ObjectMapping.EventPlugin interface implementation

    // BeforeUpsert Is called for each record that will be inserted/updated into the target object.
    // If the target record has an ID it will be updated, otherwise inserted.
    // Return true to accept the record for insert/update. False to reject the record.
    global boolean beforeUpsert(sobject sourceRecord, sobject targetRecord) {
        // Custom: lookup the AccountId for the KUNNR value and map it to the target record
        sapCustomerDetail_GT_CUST_PF__c source = (sapCustomerDetail_GT_CUST_PF__c)sourceRecord;
        Relationship__c target = (Relationship__c)targetRecord;
        if (kunnrToAccountIds.containsKey(source.KUNNR__c) && kunnrToAccountIds.containsKey(source.KUNN2__c)) {
            target.Primary_Account__c = kunnrToAccountIds.get(source.KUNNR__c);
            target.Secondary_Account__c = kunnrToAccountIds.get(source.KUNN2__c);
        } else {
            return false;
        }
        
        //String compoundKey = target.Primary_Account__c + ':' + source.VKORG__c + ':' + source.VTWEG__c + ':' + source.SPART__c;
        if (salesOrgCompoundKeyToIds.containsKey(source.CustomerSalesAreaKey__c)) {
            target.Primary_Account_Sales_Org__c = salesOrgCompoundKeyToIds.get(source.CustomerSalesAreaKey__c);
        }
        //compoundKey += ':' + source.PARVW__c + ':' + source.PARZA__c;
        
        if (relationshipCompoundKeyToIds.containsKey(source.CompoundKey__c)) {
            target.Id = relationshipCompoundKeyToIds.get(source.CompoundKey__c);
        }
    
        // End custom
        return true;
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
            logs.add(new overcast__Log__c(overcast__Run__c=m_execution.Id, overcast__Message__c='[Mapping_CustomerRelationship] ' + message, overcast__LogLevel__c = 'ERROR', overcast__Time__c=DateTime.now()));            
        }
    }
        
    // Log an warning message to the scenario execution log        
    global void logWarning(String message) {
        if (m_loglevel >= 3) {
            logs.add(new overcast__Log__c(overcast__Run__c=m_execution.Id, overcast__Message__c='[Mapping_CustomerRelationship] ' + message, overcast__LogLevel__c = 'WARN', overcast__Time__c=DateTime.now()));        
        }
    }
        
    // Log an info message to the scenario execution log
    global void logInfo(String message) {
        if (m_loglevel >= 4) {
            logs.add(new overcast__Log__c(overcast__Run__c=m_execution.Id, overcast__Message__c='[Mapping_CustomerRelationship] ' + message, overcast__LogLevel__c = 'INFO', overcast__Time__c=DateTime.now()));
        }
    } 

    // Log a debug message to the scenario execution log
    global void logDebug(String message) {
        if (m_loglevel >= 5) {
            logs.add(new overcast__Log__c(overcast__Run__c=m_execution.Id, overcast__Message__c='[Mapping_CustomerRelationship] ' + message, overcast__LogLevel__c = 'DEBUG', overcast__Time__c=DateTime.now()));
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