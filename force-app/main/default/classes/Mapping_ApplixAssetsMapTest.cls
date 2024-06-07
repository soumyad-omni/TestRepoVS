// This code was generated by Overcast for running the outbound mappings. 2019-01-02 18:55:55Z
//
// Update this test class to correspond to your updates to Mapping_ApplixAssetsMap.
@istest
private class Mapping_ApplixAssetsMapTest {
   /*
    // Assert in code that your mapping configuration is correct
    @istest
    private static void testObjectMapping() {
         overcast__Run__c r = getExecution();
        
        overcast__IntegrationFieldMap__c mapping = new overcast__IntegrationFieldMap__c(overcast__Active__c=true, overcast__Direction__c='Inbound');
        mapping.overcast__ApexClass__c = 'Mapping_ApplixAssetsMap';
        mapping.overcast__ScenarioName__c = 'ApplixAssetsData';
        mapping.overcast__Target__c = 'Applix_Assets__c';
        mapping.overcast__TargetObjectName__c = 'Applix_Assets__c';
        mapping.overcast__Source__c = 'ApplixAssetsData_Ov_assets_for_account__c';
        mapping.overcast__SourceObjectName__c = 'ApplixAssetsData_Ov_assets_for_account__c';
        // Query your actual mapping records and add the field data here
        // mapping.overcast__Joins__c = '';
        // mapping.overcast__Map__c = '';
        
        // set the input record fields and assert that output record matches your mapping.
        ApplixAssetsData_Ov_assets_for_account__c input = new ApplixAssetsData_Ov_assets_for_account__c();
        
        Mapping_ApplixAssetsMap plugin = new Mapping_ApplixAssetsMap();
        
        Test.startTest();
        
        //plugin.execute(r, new ApplixAssetsData_Ov_assets_for_account__c[]{ input });
        //Test.stoptest();
        
        Applix_Assets__c[] output = [SELECT Id FROM Applix_Assets__c LIMIT 1];
        // Add your assertions about your mapping configuration here.
        system.assert(true);
    }
    */
    @istest
    private static void testBeforeUpsert() {
        Mapping_ApplixAssetsMap plugin = new Mapping_ApplixAssetsMap();
        //plugin.m_logger = new overcast.Logger(getExecution().Id);
        ApplixAssetsData_Ov_assets_for_account__c source = new ApplixAssetsData_Ov_assets_for_account__c();
        Applix_Assets__c target = new Applix_Assets__c();
        //boolean response = plugin.beforeUpsert(source, target);
        
        // Assert any transformations on the target record you perform in beforeUpsert()
        //system.assertEquals(true, response);
    }
    /*
    @istest
    private static void testAfterInsert() {
        Mapping_ApplixAssetsMap plugin = new Mapping_ApplixAssetsMap();
        plugin.m_logger = new overcast.Logger(getExecution().Id);
        Applix_Assets__c target = new Applix_Assets__c();
        
        overcast.ObjectMapping.InboundMappingIsRunning = true;
        sobject[] inserted = new sobject[]{ target };
        Database.SaveResult[] saveResults = Database.insert(inserted, false);
        plugin.afterInsert(inserted, saveResults);
        
        // afterInsert allows for post-processing and may not require any assertions.
        system.assert(true);
    }
    
    @istest
    private static void testAfterUpdate() {
        Mapping_ApplixAssetsMap plugin = new Mapping_ApplixAssetsMap();
        plugin.m_logger = new overcast.Logger(getExecution().Id);
        Applix_Assets__c target = new Applix_Assets__c();
        
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
        Mapping_ApplixAssetsMap plugin = new Mapping_ApplixAssetsMap();
        plugin.m_logger = new overcast.Logger(r.Id);
        
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
        system.assertEquals(400, plugin.m_logger.getStatusCode());
        overcast__Run__c r2 = [SELECT overcast__StatusCode__c FROM overcast__Run__c WHERE Id = :r.Id];
        system.assertEquals(400, r2.overcast__StatusCode__c);
    }

    private static overcast__Run__c getExecution() {
        overcast__Scenario__c scen = overcast.TestingUtilities.SetupTestEnvironment('ApplixAssetsData');
        scen.overcast__LogLevel__c = 'INFO';
        update scen;
        overcast__Run__c r = new overcast__Run__c(overcast__Scenario__c=scen.Id, overcast__Input__c='A', overcast__Mode__c='Run', overcast__Operation__c='Read');
        insert r;
        return r;
    }*///Commented by Sourav for Overcast uninstall
}