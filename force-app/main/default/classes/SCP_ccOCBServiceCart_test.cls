@istest
public class SCP_ccOCBServiceCart_test {

    @istest
    public static void getFieldsMap_test(){
    	Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        Test.startTest();
        	SCP_ccOCBServiceCart serviceCartObj = new SCP_ccOCBServiceCart();
        	serviceCartObj.getFieldsMap(inputdata);
        Test.stopTest();    
    }
}