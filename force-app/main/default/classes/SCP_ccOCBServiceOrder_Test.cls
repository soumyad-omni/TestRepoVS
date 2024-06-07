@istest
public class SCP_ccOCBServiceOrder_Test {
	
    @istest
    public static void getFieldsMap_Test(){
        Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        Test.startTest();
        	SCP_ccOCBServiceOrder serviceOrderObj = new SCP_ccOCBServiceOrder();
        	serviceOrderObj.getFieldsMap(inputdata);
        Test.stopTest();
    }
}