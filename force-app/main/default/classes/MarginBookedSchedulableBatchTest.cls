@isTest(seeAllData=true)
public class MarginBookedSchedulableBatchTest {
	public testmethod static void committedBatchTest(){
        Test.startTest();
        List<Quote> quotes = [Select id,OpportunityId from Quote where OpportunityId!= null and Primary_Quote__c =true limit 1];
        id oppId= quotes[0].OpportunityId;
        Forecast_Dimension__c fc = new Forecast_Dimension__c();
        fc.Opportunity_Name__c = 'Test Opp';
        fc.Primary_Quote_ID__c = quotes[0].id;
        fc.Primary_Quote_SAP_Number__c = 5531288;
        fc.Opportunity_ID__c = oppId;
        fc.Opportunity_Forecast_Category__c = 'Booked';
        fc.Is_Manually_Added__c = true;
        datetime myDate = datetime.newInstance(2022, 2, 17);
		datetime newDate = mydate.addDays(2);
        fc.Opportunity_Change_Datetime__c = newDate;
		fc.Opportunity_Created_Date__c = myDate;
		insert fc;
        List<Forecast_Dimension__c> fcList = new List<Forecast_Dimension__c>();
        fcList.add(fc);
        CleanForecastCategoryBatch dataClean1 = new CleanForecastCategoryBatch();
        dataClean1.processForecastCategoryData(fcList);
        COGS_Dimension__c cm = new COGS_Dimension__c();
        cm.COGS_Primary_Quote_SAP_Number__c=  5552539;
        cm.COGS_Primary_Quote_Labor_Cost__c= 100;
        cm.COGS_Primary_Quote_Material_Cost__c=  100;
        cm.COGS_Primary_Quote_Overhead_Cost__c=  100;
        cm.COGS_Primary_Quote_Margin__c=  100;
        cm.COGS_Primary_Quote_Expected_Booking__c=  200070;
        cm.COGS_Primary_Quote_Change_Datetime__c= newDate;
        cm.Primary_Quote_ID__c= quotes[0].id;
        cm.Primary_Opportunity_Id__c= oppId;
       	MarginBookedSchedulableBatch aplb = new MarginBookedSchedulableBatch();
        Id batchId = Database.executeBatch(aplb, 100);
        Test.stopTest();
    } 
}