/**
 * @File Name          : MarketingProductTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 22/1/2020, 5:23:53 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/1/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class MarketingProductTriggerHandlerTest {

    public static testmethod void marketingProductTriggerTest(){
        AccountCreateController.isFirstRun= false;
        test.startTest();
        Marketing_Product__c mp = TestDataFactory.createTestMarketProduct();    
        mp.Expected_Bookings__c = 20;
        update mp;
        delete mp;
        undelete mp;
    	test.stopTest();
    }

    //Anil 6/24/2019 added test class to check for SF-BUG-311
    public static testmethod void checkForExpectedBookingsAndTotalUnits() {
        //create few accounts
        //AccountCreateController.isFirstRun= false;
        test.startTest();
        List<Account> accounts = TestDataFactory.createAccounts(5);
        insert accounts;

        //create a Target Initiative
        Target_Initiative__c ti = TestDataFactory.createTestTargetInitiative();
        
        //add those accounts into the Target_Initiative_Account__c
        List<Target_Initiative_Account__c> tiaList= new List<Target_Initiative_Account__c>();
        for (Account a:accounts) {
            Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
            tia.Account__c = a.Id;
            tia.Target_Initiative__c = ti.Id;
            tiaList.add(tia);
        }
        insert tiaList;

        //create a few marketing products for those accounts
        for (Target_Initiative_Account__c tia:tiaList) {
            List<Marketing_Product__c> marketingProducts = new List<Marketing_Product__c>();
            for (Integer i=0;i<5;i++) {
                Marketing_Product__c mp = new Marketing_Product__c();
                mp.Target_Initiative_Account__c = tia.Id;
              mp.Expected_Bookings__c = 1000+i;
                mp.Units__c = 2;
                mp.Target_Initiative__c=ti.id;
                marketingProducts.add(mp);
            }
            insert marketingProducts;
        }

        test.stopTest();
    }

    public static testmethod void checkForExpectedBookingsTotalUnitsNegativeTest() {
        //create few accounts
        test.startTest();
        List<Account> accounts = TestDataFactory.createAccounts(10);
        insert accounts;

        //create a Target Initiative
        Target_Initiative__c ti = TestDataFactory.createTestTargetInitiative();

        //add those accounts into the Target_Initiative_Account__c
        List<Target_Initiative_Account__c> tiaList= new List<Target_Initiative_Account__c>();
        for (Integer i=0;i<5;i++) {
            Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
            tia.Account__c = accounts[i].Id;
            tia.Target_Initiative__c = ti.Id;
            tiaList.add(tia);
        }
        insert tiaList;

        
        //create a second Target Initiative
        Target_Initiative__c tiTwo = TestDataFactory.createTestTargetInitiative();
        
        List<Target_Initiative_Account__c> tiaListTwo= new List<Target_Initiative_Account__c>();
        for (Integer i=5;i<10;i++) {
            Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
            tia.Account__c = accounts[i].Id;
            tia.Target_Initiative__c = tiTwo.Id;
            tiaListTwo.add(tia);
        }
        insert tiaListTwo;
        
        //create a few marketing products for those accounts
        List<Marketing_Product__c> marketingProducts = new List<Marketing_Product__c>();
        for (Target_Initiative_Account__c tia:tiaList) {
            for (Integer i=0;i<5;i++) {
                Marketing_Product__c mp = new Marketing_Product__c();
                mp.Target_Initiative_Account__c = tia.Id;
                mp.Expected_Bookings__c = 1000+i;
                mp.Units__c = 2;
                mp.Target_Initiative__c=ti.id;
                marketingProducts.add(mp);
            }
        }

        for (Target_Initiative_Account__c tia:tiaListTwo) {
            for (Integer i=0;i<5;i++) {
                Marketing_Product__c mp = new Marketing_Product__c();
                mp.Target_Initiative_Account__c = tia.Id;
                mp.Expected_Bookings__c = 1000+i;
                mp.Units__c = 2;
                mp.Target_Initiative__c=tiTwo.id;
                marketingProducts.add(mp);
            }
        }

        insert marketingProducts;

        test.stopTest();
    }
}