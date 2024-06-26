// This class allows advanced customizations for the mapping of records from sapCustomerDetail_GT_CUST_TC__c to SAP_Sales_Org__c.
//
// Scenario: sapCustomerDetail
// Source Object: sapCustomerDetail_GT_CUST_TC__c
// Target Object: SAP_Sales_Org__c
// Mapping Record Name: Customer_TaxClassification
// Direction: Inbound
// 
// Generated by Overcast 2019-02-08 19:53:19Z
// Your changes will not be overwritten when resaving the mapping.
//
global class Mapping_Customer_TaxClassification {//implements overcast.ObjectMapping.EventPlugin, overcast.ObjectMapping.BatchableEventPlugin {//Commented by Sourav for Overcast uninstall
    //Custom
    /*private Map<String, Id> salesOrgCompoundKeyToIds = new Map<String, Id>();
    //End custom
    global void execute(overcast__Run__c scenarioExecution, sapCustomerDetail_GT_CUST_TC__c[] records) {
        overcast.EpgwController.MappingConfig config = new overcast.EpgwController.MappingConfig('sapCustomerDetail_GT_CUST_TC__c', records);
        config.rollbackOnError = true;
        config.eventplugin = this;
        config.mappings = [SELECT overcast__Target__c, overcast__Map__c, overcast__Joins__c
                    FROM overcast__IntegrationFieldMap__c 
                    WHERE overcast__ApexClass__c = 'Mapping_Customer_TaxClassification'];

        m_logger = new overcast.Logger(scenarioExecution.Id);
        
        //Custom
        Set<String> salesAreaKeys = new Set<String>();
        for (sapCustomerDetail_GT_CUST_TC__c tc : records) {
            salesAreaKeys.add(tc.CompoundKey__c);
        }
        for (SAP_Sales_Org__c sa : [SELECT Id, CompoundKey__c FROM SAP_Sales_Org__c WHERE CompoundKey__c IN :salesAreaKeys LIMIT 1000]) {
            salesOrgCompoundKeyToIds.put(sa.CompoundKey__c, sa.Id);
        }
        //End custom
        
        overcast.EpgwController.RunMappingTrigger(config);

        this.saveLogs();
    }

    // Begin ObjectMapping.EventPlugin interface implementation

    // BeforeUpsert Is called for each record that will be inserted/updated into the target object.
    // If the target record has an ID it will be updated, otherwise inserted.
    // Return true to accept the record for insert/update. False to reject the record.
    global boolean beforeUpsert(sobject sourceRecord, sobject targetRecord) {
        //Custom
        sapCustomerDetail_GT_CUST_TC__c source = (sapCustomerDetail_GT_CUST_TC__c)sourceRecord;
        SAP_Sales_Org__c target = (SAP_Sales_Org__c)targetRecord;
        
        if (salesOrgCompoundKeyToIds.containsKey(source.CompoundKey__c)) {
            target.Id = salesOrgCompoundKeyToIds.get(source.CompoundKey__c);
            return true;
        } else {
            //Don't create new records, only update existing
            return false;
        }
        //End custom
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
        m_logger.addLog('ERROR', '[Mapping_Customer_TaxClassification] ' + message);
    }
    
    // Log an warning message to the scenario execution log
    global void logWarning(String message) {
        m_logger.addLog('WARN', '[Mapping_Customer_TaxClassification] ' + message);
    }
    
    // Log an info message to the scenario execution log
    global void logInfo(String message) {
        m_logger.addLog('INFO', '[Mapping_Customer_TaxClassification] ' + message);
    }

    // Log a debug message to the scenario execution log
    global void logDebug(String message) {
        m_logger.addLog('DEBUG', '[Mapping_Customer_TaxClassification] ' + message);
    }
    
    // Set the scenario execution status to error
    global void setStatusToError() {
        m_logger.setStatusCode(400);
    }
    
    // Set the scenario execution status to warning
    global void setStatusToWarning() {
        m_logger.setStatusCode(500);
    }
    
    global void saveLogs() {
        m_logger.commitToDatabase();
    }
    
    // End helper methods

    @testvisible
    private overcast.Logger m_logger;*///Commented by Sourav for Overcast uninstall
}