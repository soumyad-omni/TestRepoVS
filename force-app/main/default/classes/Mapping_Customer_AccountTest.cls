// This code was generated by Overcast for running the outbound mappings. 2018-09-07 17:58:32Z
//
// Update this test class to correspond to your updates to Mapping_Customer_Account.
@istest
private class Mapping_Customer_AccountTest {
    /*
    // Assert in code that your mapping configuration is correct
    @istest
    private static void testObjectMapping() {
        overcast__Run__c r = getExecution();
        
        overcast__IntegrationFieldMap__c mapping = new overcast__IntegrationFieldMap__c(overcast__Active__c=true, overcast__Direction__c='Inbound');
        mapping.overcast__ApexClass__c = 'Mapping_Customer_Account';
        mapping.overcast__ScenarioName__c = 'sapCustomerDetail';
        mapping.overcast__Target__c = 'Account';
        mapping.overcast__TargetObjectName__c = 'Account';
        mapping.overcast__Source__c = 'sapCustomerDetail_GT_CUST_ADDRDATA__c';
        mapping.overcast__SourceObjectName__c = 'sapCustomerDetail_GT_CUST_ADDRDATA__c';
        // Query your actual mapping records and add the field data here
        // mapping.overcast__Joins__c = '';
        // mapping.overcast__Map__c = '';
        
        // set the input record fields and assert that output record matches your mapping.
        sapCustomerDetail_GT_CUST_ADDRDATA__c input = new sapCustomerDetail_GT_CUST_ADDRDATA__c();
        
        Mapping_Customer_Account plugin = new Mapping_Customer_Account();
        
        Test.startTest();
        
        plugin.execute(r, new sapCustomerDetail_GT_CUST_ADDRDATA__c[]{ input });
        
        Test.stoptest();
        
        Account[] output = [SELECT Id FROM Account LIMIT 1];
        // Add your assertions about your mapping configuration here.
        system.assert(true);
    }
    */
    @istest
    private static void testBeforeUpsert() {
        Mapping_Customer_Account plugin = new Mapping_Customer_Account();
        //plugin.m_execution = getExecution();
        sapCustomerDetail_GT_CUST_ADDRDATA__c source = new sapCustomerDetail_GT_CUST_ADDRDATA__c();
        Account target = new Account();
        //boolean response = plugin.beforeUpsert(source, target);
        
        // Assert any transformations on the target record you perform in beforeUpsert()
        //system.assertEquals(true, response);
    }
    /*
    @istest
    private static void testAfterInsert() {
        Mapping_Customer_Account plugin = new Mapping_Customer_Account();
        plugin.m_execution = getExecution();
        Account target = new Account(Name='a',Account_Territory__c='a');
        
        overcast.ObjectMapping.InboundMappingIsRunning = true;
        sobject[] inserted = new sobject[]{ target };
        Database.SaveResult[] saveResults = Database.insert(inserted, false);
        plugin.afterInsert(inserted, saveResults);
        
        // afterInsert allows for post-processing and may not require any assertions.
        system.assert(true);
    }
    
    @istest
    private static void testAfterUpdate() {   
        Mapping_Customer_Account plugin = new Mapping_Customer_Account(); 
        plugin.m_execution = getExecution(); 
        Account target = new Account(Name='a',Account_Territory__c='a');
        
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
        Mapping_Customer_Account plugin = new Mapping_Customer_Account();
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
        
        system.assertEquals(0, Mapping_Customer_Account.GetLogLevelValue('NONE'));
        system.assertEquals(1, Mapping_Customer_Account.GetLogLevelValue('FATAL'));
        system.assertEquals(2, Mapping_Customer_Account.GetLogLevelValue('ERROR'));
        system.assertEquals(3, Mapping_Customer_Account.GetLogLevelValue('WARN'));
        system.assertEquals(4, Mapping_Customer_Account.GetLogLevelValue('INFO'));
        system.assertEquals(5, Mapping_Customer_Account.GetLogLevelValue('DEBUG'));
        system.assertEquals(6, Mapping_Customer_Account.GetLogLevelValue('VERBOSE'));
        system.assertEquals(4, Mapping_Customer_Account.GetLogLevelValue(null));
        system.assertEquals(4, Mapping_Customer_Account.GetLogLevelValue('UNKNOWN'));
    }

    private static overcast__Run__c getExecution() {        
        overcast__Scenario__c scen = overcast.TestingUtilities.SetupTestEnvironment('sapCustomerDetail');
        scen.overcast__LogLevel__c = 'INFO';
        update scen;
        overcast__Run__c r = new overcast__Run__c(overcast__Scenario__c=scen.Id, overcast__Input__c='A', overcast__Mode__c='Run', overcast__Operation__c='Read');
        insert r;
        return r;
    }*///Commented by Sourav for Overcast uninstall
}