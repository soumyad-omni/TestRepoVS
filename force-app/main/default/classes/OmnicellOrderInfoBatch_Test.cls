@isTest
public with sharing class OmnicellOrderInfoBatch_Test {
    static testMethod void updateCCOrderItems() {
        
          ccrz__E_Product__c productObj = new ccrz__E_Product__c(ccrz__SKU__c='1123');
        insert productObj;
        
        list<ccrz__E_Category__c> lstCategory = new list<ccrz__E_Category__c>();
        ccrz__E_Category__c Category_v1 = new ccrz__E_Category__c(Name ='All Products',
                                                              ccrz__CategoryID__c = '2220');
        insert Category_v1;
        //lstCategory.add(Category_v1);
        ccrz__E_Category__c Category_v2 = new ccrz__E_Category__c(Name ='test Category',
                                                              ccrz__CategoryID__c = '2221',
                                                              ccrz__ParentCategory__c = Category_v1.Id);
            //lstCategory.add(Category_v2);
        
        insert Category_v2;
        
        ccrz__E_ProductCategory__c ccPrdCat = new ccrz__E_ProductCategory__c();
        ccPrdCat.ccrz__Product__c = productObj.Id;
        ccPrdCat.ccrz__Category__c = Category_v2.Id;
        //ccPrdCat.Name = 'Centra;';
        insert ccPrdCat;
        
      /* Insert Custom Setting */       
         CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        setting.Print_Compare_End_Point__c = 'https://printcastirondev.omnicell.com';
        setting.ContactInsertEndpoint__c = 'test';
        insert setting;
        
        /* Insert Account */
         Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
        /* Insert Contact */
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
         
        
		  ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
		 system.debug('contAdd : ' + contAdd);
        
		 ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        cart.ccrz__EffectiveAccountID__c = acc.id;
        insert cart;
        
        cart.ccrz__EncryptedId__c=cart.Id;
        update cart;
        
         
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        insert order;
        
		ccrz__E_OrderItem__c oitem = new ccrz__E_OrderItem__c(ccrz__Quantity__c=1,ccrz__UnitOfMeasure__c='a',
                                                              ccrz__Order__c=order.Id,ccrz__Price__c=12,
                                                              ccrz__SubAmount__c=123,ccrz__Product__c = productObj.Id);
        insert oitem;
        



        /*List<ccrz__E_OrderItem__c> orderItemToUpdate = new List<ccrz__E_OrderItem__c>();
        //orderItemToUpdate.CategCategory_ID__c = ccPrdCat.Category_ID__c;
        //orderItemToUpdate.Name = ccPrdCat.Name = 'Central';
        insert orderItemToUpdate;*/

        Test.startTest();
        /*OmnicellOrderInfoBatch batchToUpdate = new OmnicellOrderInfoBatch();
        DataBase.executeBatch(batchToUpdate);*/
        
        /*OmnicellOrderInfoBatch_Sch schOmnicellOrderInfoBatch = new OmnicellOrderInfoBatch_Sch();
          DataBase.executeBatch(schOmnicellOrderInfoBatch); */
        OmnicellOrderInfoBatch_Sch testsche = new OmnicellOrderInfoBatch_Sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
        ccrz__E_OrderItem__c[] orderItems = [SELECT Id, Name,ccrz__SubAmount__c FROM ccrz__E_OrderItem__c];
        system.debug('orderItems : ' + orderItems);
        system.assertEquals(orderItems[0].ccrz__SubAmount__c,123 );
        
        //System.assert(orderItems[0].Category_ID__c, '');
        //System.assert(orderItems[0].Name, '');
        
    }
}