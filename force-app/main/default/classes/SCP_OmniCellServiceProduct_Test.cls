@istest
public class SCP_OmniCellServiceProduct_Test {

    @istest
    public static void getFieldsMap_Test(){
        Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        Test.startTest();
        	SCP_OmniCellServiceProduct serviceProductObj = new SCP_OmniCellServiceProduct();
        	serviceProductObj.getFieldsMap(inputdata);
        Test.stopTest();
    }
}