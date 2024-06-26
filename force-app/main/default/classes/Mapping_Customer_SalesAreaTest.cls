// This code was generated by Overcast for running the outbound mappings. 2018-09-07 18:38:57Z
//
// Update this test class to correspond to your updates to Mapping_Customer_SalesArea.
@istest
private class Mapping_Customer_SalesAreaTest {
    
    // Assert in code that your mapping configuration is correct
    @istest
    private static void testObjectMapping() {
        /*overcast__Run__c r = getExecution();
        
        overcast__IntegrationFieldMap__c mapping = new overcast__IntegrationFieldMap__c(overcast__Active__c=true, overcast__Direction__c='Inbound');
        mapping.overcast__ApexClass__c = 'Mapping_Customer_SalesArea';
        mapping.overcast__ScenarioName__c = 'sapCustomerDetail';
        mapping.overcast__Target__c = 'SAP_Sales_Org__c';
        mapping.overcast__TargetObjectName__c = 'SAP_Sales_Org__c';
        mapping.overcast__Source__c = 'sapCustomerDetail_GT_CUST_SALESAREA__c';
        mapping.overcast__SourceObjectName__c = 'sapCustomerDetail_GT_CUST_SALESAREA__c';
        // Query your actual mapping records and add the field data here
        // mapping.overcast__Joins__c = '';
        // mapping.overcast__Map__c = '';
        
        // set the input record fields and assert that output record matches your mapping.
        sapCustomerDetail_GT_CUST_SALESAREA__c input = new sapCustomerDetail_GT_CUST_SALESAREA__c();
        
        Mapping_Customer_SalesArea plugin = new Mapping_Customer_SalesArea();
        
        Test.startTest();
        
        plugin.execute(r, new sapCustomerDetail_GT_CUST_SALESAREA__c[]{ input });
        
        Test.stoptest();
        
        SAP_Sales_Org__c[] output = [SELECT Id FROM SAP_Sales_Org__c LIMIT 1];
        // Add your assertions about your mapping configuration here.
        system.assert(true);*/ //Commented by Sourav for Overcast uninstall
    }
    
    @istest
    private static void testBeforeUpsert() {
        Mapping_Customer_SalesArea plugin = new Mapping_Customer_SalesArea();
        //plugin.m_execution = getExecution();//Commented by Sourav for Overcast uninstall
        sapCustomerDetail_GT_CUST_SALESAREA__c source = new sapCustomerDetail_GT_CUST_SALESAREA__c();
        SAP_Sales_Org__c target = new SAP_Sales_Org__c();
        //boolean response = plugin.beforeUpsert(source, target);//Commented by Sourav for Overcast uninstall
        
        // Assert any transformations on the target record you perform in beforeUpsert()
        //system.assertEquals(true, response);
    }
    
    @istest
    private static void testAfterInsert() {
        Mapping_Customer_SalesArea plugin = new Mapping_Customer_SalesArea();
        //plugin.m_execution = getExecution();//Commented by Sourav for Overcast uninstall
        SAP_Sales_Org__c target = new SAP_Sales_Org__c(Incoterms_1__c='a',Sales_Office__c='a',Service_Level__c='a',Default_GPO_Price_List__c='a',Default_IDN_Price_List__c='a');
        
        //overcast.ObjectMapping.InboundMappingIsRunning = true;//Commented by Sourav for Overcast uninstall
        sobject[] inserted = new sobject[]{ target };
        Database.SaveResult[] saveResults = Database.insert(inserted, false);
        //plugin.afterInsert(inserted, saveResults);//Commented by Sourav for Overcast uninstall
        
        // afterInsert allows for post-processing and may not require any assertions.
        system.assert(true);
    }
    
    @istest
    private static void testAfterUpdate() {   
        Mapping_Customer_SalesArea plugin = new Mapping_Customer_SalesArea(); 
       // plugin.m_execution = getExecution(); //Commented by Sourav for Overcast uninstall
        SAP_Sales_Org__c target = new SAP_Sales_Org__c(Incoterms_1__c='a',Sales_Office__c='a',Service_Level__c='a',Default_GPO_Price_List__c='a',Default_IDN_Price_List__c='a');
        
        //overcast.ObjectMapping.InboundMappingIsRunning = true; //Commented by Sourav for Overcast uninstall
        sobject[] updated = new sobject[]{ target };
        Database.SaveResult[] saveResults = Database.insert(updated, false);
        //plugin.afterUpdate(updated, saveResults);//Commented by Sourav for Overcast uninstall
        
        // afterUpdate allows for post-processing and may not require any assertions.
        system.assert(true);
    }
    
    @istest
    private static void testLogging() {       
        //overcast__Run__c r = getExecution();//Commented by Sourav for Overcast uninstall
        Mapping_Customer_SalesArea plugin = new Mapping_Customer_SalesArea();
        //plugin.m_execution = r;//Commented by Sourav for Overcast uninstall
        
        /*plugin.logInfo('MESSAGE');
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
        
        system.assertEquals(0, Mapping_Customer_SalesArea.GetLogLevelValue('NONE'));
        system.assertEquals(1, Mapping_Customer_SalesArea.GetLogLevelValue('FATAL'));
        system.assertEquals(2, Mapping_Customer_SalesArea.GetLogLevelValue('ERROR'));
        system.assertEquals(3, Mapping_Customer_SalesArea.GetLogLevelValue('WARN'));
        system.assertEquals(4, Mapping_Customer_SalesArea.GetLogLevelValue('INFO'));
        system.assertEquals(5, Mapping_Customer_SalesArea.GetLogLevelValue('DEBUG'));
        system.assertEquals(6, Mapping_Customer_SalesArea.GetLogLevelValue('VERBOSE'));
        system.assertEquals(4, Mapping_Customer_SalesArea.GetLogLevelValue(null));
        system.assertEquals(4, Mapping_Customer_SalesArea.GetLogLevelValue('UNKNOWN'));*///Commented by Sourav for Overcast uninstall
    }

    /*private static overcast__Run__c getExecution() {        
        overcast__Scenario__c scen = overcast.TestingUtilities.SetupTestEnvironment('sapCustomerDetail');
        scen.overcast__LogLevel__c = 'INFO';
        update scen;
        overcast__Run__c r = new overcast__Run__c(overcast__Scenario__c=scen.Id, overcast__Input__c='A', overcast__Mode__c='Run', overcast__Operation__c='Read');
        insert r;
        return r;
    }*///Commented by Sourav for Overcast uninstall
}