@isTest
private class InputDeleteTest {
    
    @isTest
    static void testInputDelete() {
        //Setup
        List<sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c> records = new List<sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c>();
        records.add(new sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c(Name = 'auto_test'));
        records.add(new sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c(Name = 'OUT auto_test'));
        insert records;

        //Run
        //setupOvcCustomSetting('LogKeepDays', '5');//Commented by Sourav for Overcast uninstall
        Test.startTest();
        InputDelete sched = new InputDelete();
        database.executebatch(new InputDeleteBatch('sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c'));
        database.executebatch(new InputDeleteBatch('sapCustomerDetail_RETURN__c'));
        //sched.run(null, null);//Commented by Sourav for Overcast uninstall
        Test.stopTest();

        //Verify
        List<sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c> recs = [SELECT Id FROM sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c];
        System.assertEquals(2, recs.size());
    }

    @isTest
    static void testInputDeleteNoKeep() {
        //Setup
        List<sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c> records = new List<sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c>();
        records.add(new sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c(Name = 'auto_test'));
        records.add(new sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c(Name = 'OUT auto_test'));
        insert records;

        //Run
        //setupOvcCustomSetting('LogKeepDays', '0');//Commented by Sourav for Overcast uninstall
        Test.startTest();
        InputDelete sched = new InputDelete();
        database.executebatch(new InputDeleteBatch('sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c'));
        //sched.run(null, null);//Commented by Sourav for Overcast uninstall
        InputDeleteBatch test1 = new InputDeleteBatch('sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c');
        test1.execute(null,records);
        Test.stopTest();

        //Verify
        List<sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c> recs = [SELECT Id FROM sapCustomerDetail_ZBAPIECCCUSTOVERCAST__c];
        //System.assertEquals(0, recs.size());
    }

    /*private static void setupOvcCustomSetting(String key, String val){
        overcast__EpgwSettings__c settings = overcast__EpgwSettings__c.getInstance(key);
        if (settings == null){
            settings = new overcast__EpgwSettings__c();
            settings.Name = key;
            settings.overcast__Value__c = val;
            insert settings;
        }
    }*/
    
}