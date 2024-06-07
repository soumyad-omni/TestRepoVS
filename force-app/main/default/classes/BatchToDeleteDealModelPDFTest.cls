@isTest
private class BatchToDeleteDealModelPDFTest {

	private static testMethod void test1() {
        List<Deal_Modeling_PDF__c> lstDealModeling = new List<Deal_Modeling_PDF__c>{new Deal_Modeling_PDF__c(Booking_Price__c = 1000),
                                                                                    new Deal_Modeling_PDF__c(Booking_Price__c = 1000),
                                                                                    new Deal_Modeling_PDF__c(Booking_Price__c = 1000)
                                                                                    };
        insert lstDealModeling;
        Test.startTest();
        Database.executebatch( new BatchToDeleteDealModelPDF(), 200);
        Test.stopTest(); 
	}
	private static testMethod void test2() {
        Test.startTest(); 
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test DeletePDF Check', sch, new ScheduledBatchToDeleteDealModelPDF()); 
        Test.stopTest(); 
	}

}