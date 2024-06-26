// This code was generated by Overcast for running the outbound mappings. 2018-09-11 19:13:49Z
//
// Update this test class to correspond to your updates to Mapping_CustomerRelationship.
@istest
private class Mapping_CustomerRelationshipTest {
    /*
    // Assert in code that your mapping configuration is correct
    @istest
    private static void testObjectMapping() {
        overcast__Run__c r = getExecution();
        
        overcast__IntegrationFieldMap__c mapping = new overcast__IntegrationFieldMap__c(overcast__Active__c=true, overcast__Direction__c='Inbound');
        mapping.overcast__ApexClass__c = 'Mapping_CustomerRelationship';
        mapping.overcast__ScenarioName__c = 'sapCustomerDetail';
        mapping.overcast__Target__c = 'Relationship__c';
        mapping.overcast__TargetObjectName__c = 'Relationship__c';
        mapping.overcast__Source__c = 'sapCustomerDetail_GT_CUST_PF__c';
        mapping.overcast__SourceObjectName__c = 'sapCustomerDetail_GT_CUST_PF__c';
        // Query your actual mapping records and add the field data here
        // mapping.overcast__Joins__c = '';
        // mapping.overcast__Map__c = '';
        
        // set the input record fields and assert that output record matches your mapping.
        sapCustomerDetail_GT_CUST_PF__c input = new sapCustomerDetail_GT_CUST_PF__c();
        
        Mapping_CustomerRelationship plugin = new Mapping_CustomerRelationship();
        
        Test.startTest();
        
        plugin.execute(r, new sapCustomerDetail_GT_CUST_PF__c[]{ input });
        
        Test.stoptest();
        
        Relationship__c[] output = [SELECT Id FROM Relationship__c LIMIT 1];
        // Add your assertions about your mapping configuration here.
        system.assert(true);
    }
    */
    @istest
    private static void testBeforeUpsert() {
        Mapping_CustomerRelationship plugin = new Mapping_CustomerRelationship();
        //plugin.m_execution = getExecution();
        sapCustomerDetail_GT_CUST_PF__c source = new sapCustomerDetail_GT_CUST_PF__c();
        Relationship__c target = new Relationship__c();
        //boolean response = plugin.beforeUpsert(source, target);
        
        // Assert any transformations on the target record you perform in beforeUpsert()
        //system.assertEquals(true, response);
    }
    /*
    @istest
    private static void testAfterInsert() {
        Mapping_CustomerRelationship plugin = new Mapping_CustomerRelationship();
        plugin.m_execution = getExecution();
        Relationship__c target = new Relationship__c();
        
        overcast.ObjectMapping.InboundMappingIsRunning = true;
        sobject[] inserted = new sobject[]{ target };
        Database.SaveResult[] saveResults = Database.insert(inserted, false);
        plugin.afterInsert(inserted, saveResults);
        
        // afterInsert allows for post-processing and may not require any assertions.
        system.assert(true);
    }
    
    @istest
    private static void testAfterUpdate() {   
        Mapping_CustomerRelationship plugin = new Mapping_CustomerRelationship(); 
        plugin.m_execution = getExecution(); 
        Relationship__c target = new Relationship__c();
        
        overcast.ObjectMapping.InboundMappingIsRunning = true;
        sobject[] updated = new sobject[]{ target };
        Database.SaveResult[] saveResults = Database.insert(updated, false);
        plugin.afterUpdate(updated, saveResults);
        
        // afterUpdate allows for post-processing and may not require any assertions.
        system.assert(true);
    }
    
    @istest
    private static void testLogging() {       
        overcast__Run__c r = getExecution();
        Mapping_CustomerRelationship plugin = new Mapping_CustomerRelationship();
        plugin.m_execution = r;
        
        plugin.logInfo('MESSAGE');
        plugin.logWarning('WARNING');
        plugin.setStatusToWarning();
        plugin.logError('ERROR');
        plugin.logDEBUG('DEBUG');
        plugin.setStatusToError();
        plugin.saveLogs();
                
        overcast__Log__c[] logs = [SELECT Id, overcast__LogLevel__c, overcast__Message__c FROM overcast__Log__c];
        system.assert(logs.size() >= 3);
        for (overcast__Log__c l : logs) {
            if (l.overcast__LogLevel__c == 'DEBUG') {
                system.assert(false, 'DEBUG message not filtered out');
            }
        }
        system.assertEquals(400, r.overcast__StatusCode__c);
        
        system.assertEquals(0, Mapping_CustomerRelationship.GetLogLevelValue('NONE'));
        system.assertEquals(1, Mapping_CustomerRelationship.GetLogLevelValue('FATAL'));
        system.assertEquals(2, Mapping_CustomerRelationship.GetLogLevelValue('ERROR'));
        system.assertEquals(3, Mapping_CustomerRelationship.GetLogLevelValue('WARN'));
        system.assertEquals(4, Mapping_CustomerRelationship.GetLogLevelValue('INFO'));
        system.assertEquals(5, Mapping_CustomerRelationship.GetLogLevelValue('DEBUG'));
        system.assertEquals(6, Mapping_CustomerRelationship.GetLogLevelValue('VERBOSE'));
        system.assertEquals(4, Mapping_CustomerRelationship.GetLogLevelValue(null));
        system.assertEquals(4, Mapping_CustomerRelationship.GetLogLevelValue('UNKNOWN'));
    }

    private static overcast__Run__c getExecution() {        
        overcast__Scenario__c scen = overcast.TestingUtilities.SetupTestEnvironment('sapCustomerDetail');
        scen.overcast__LogLevel__c = 'INFO';
        update scen;
        overcast__Run__c r = new overcast__Run__c(overcast__Scenario__c=scen.Id, overcast__Input__c='A', overcast__Mode__c='Run', overcast__Operation__c='Read');
        insert r;
        return r;
    }*/ //Commented by Sourav for Overcast uninstall
}