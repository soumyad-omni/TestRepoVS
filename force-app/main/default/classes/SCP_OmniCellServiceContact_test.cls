@istest
public class SCP_OmniCellServiceContact_test {

    @istest
    public static void getFieldsMap_test(){
    	Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        Test.startTest();
        	SCP_OmniCellServiceContact serviceContactObj = new SCP_OmniCellServiceContact();
        	serviceContactObj.getFieldsMap(inputdata);
        Test.stopTest();    
    }
}