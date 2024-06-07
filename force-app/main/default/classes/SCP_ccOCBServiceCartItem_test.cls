@istest
public class SCP_ccOCBServiceCartItem_test {

    @istest
    public static void getFieldsMap_test(){
      Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        Test.startTest();
          SCP_ccOCBServiceCartItem serviceCartItemObj = new SCP_ccOCBServiceCartItem();
          serviceCartItemObj.getFieldsMap(inputdata);
        Test.stopTest();    
    }
}