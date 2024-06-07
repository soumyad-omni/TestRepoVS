@isTest(seeAllData=true)
public class CleanForecastCategoryBatchTest {
	public testmethod static void cleanForecastCategory(){
        test.startTest();
        List<Quote> quotes = [Select id,OpportunityId from Quote where OpportunityId!= null and Primary_Quote__c =true  and Opportunity.Pipeline_Category__c ='Booked' limit 2];
        id oppId= quotes[0].OpportunityId;
        id oppId1= quotes[1].OpportunityId;
        Forecast_Dimension__c fc = new Forecast_Dimension__c();
        fc.Opportunity_Name__c = 'Test Opp';
        fc.Primary_Quote_ID__c = quotes[0].id;
        fc.Primary_Quote_SAP_Number__c = 5531288;
        fc.Opportunity_ID__c = oppId;
        fc.Opportunity_Forecast_Category__c = 'Booked';
        datetime myDate = datetime.newInstance(2022, 2, 17);
		datetime newDate = mydate.addDays(2);
        fc.Opportunity_Change_Datetime__c = newDate;
		fc.Opportunity_Created_Date__c = myDate;
		insert fc;
        Forecast_Dimension__c fc1 = new Forecast_Dimension__c();
        fc1.Opportunity_Name__c = 'Test Opp';
        fc1.Primary_Quote_ID__c = quotes[1].id;
        fc1.Primary_Quote_SAP_Number__c = 5531288;
        fc1.Opportunity_ID__c = oppId1;
        fc1.Opportunity_Forecast_Category__c = 'Upside';
        datetime myDate1 = datetime.newInstance(2022, 2, 17);
		datetime newDate1 = mydate.addDays(2);
        fc1.Opportunity_Change_Datetime__c = newDate1;
		fc1.Opportunity_Created_Date__c = myDate1;
		insert fc1;
        Forecast_Dimension__c fc2 = new Forecast_Dimension__c();
        fc2.Opportunity_Name__c = 'Test Opp';
        fc2.Primary_Quote_ID__c = quotes[1].id;
        fc2.Primary_Quote_SAP_Number__c = 5531288;
        fc2.Opportunity_ID__c = oppId1;
        fc2.Opportunity_Forecast_Category__c = 'Booked';
        datetime myDate2 = datetime.newInstance(2022, 2, 17);
		datetime newDate2 = mydate.addDays(2);
        fc1.Opportunity_Change_Datetime__c = newDate2;
		fc1.Opportunity_Created_Date__c = myDate2;
		insert fc2;
		CleanForecastCategoryBatch aplb = new CleanForecastCategoryBatch();
        Id batchId = Database.executeBatch(aplb, 500);
        test.stopTest();
    }
}