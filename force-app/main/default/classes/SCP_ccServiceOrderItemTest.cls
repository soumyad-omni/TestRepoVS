@isTest
public class SCP_ccServiceOrderItemTest {
		@istest
        public static void getFieldsMap_test(){
          Map<String, Object> inputdata = new Map<String, Object>();
            inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
            Test.startTest();
              SCP_ccServiceOrderItem serviceCartItemObj = new SCP_ccServiceOrderItem();
              serviceCartItemObj.getFieldsMap(inputdata);
            Test.stopTest();    
        }
}