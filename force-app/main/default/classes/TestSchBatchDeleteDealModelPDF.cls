@isTest
private class TestSchBatchDeleteDealModelPDF {

	private static testMethod void test1() {
	    Deal_Modeling_PDF__c objPDF = new Deal_Modeling_PDF__c(Name = 'Test PDF');
	    insert objPDF;
        Test.startTest();
        Database.executebatch( new BatchToDeleteDealModelPDF(), 200);
        Test.stopTest();

	}
	private static testMethod void test2() {
        Test.startTest();
        System.schedule('Test','0 0 0 3 9 ? 2045', new ScheduledBatchToDeleteDealModelPDF());
        Test.stopTest();
	}

}