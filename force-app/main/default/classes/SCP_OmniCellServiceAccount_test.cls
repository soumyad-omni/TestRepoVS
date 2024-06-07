@istest
public class SCP_OmniCellServiceAccount_test {
	@istest
    public static void getFieldsMap_test(){
    	Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        Test.startTest();
        	SCP_OmniCellServiceAccount serviceAccountObj = new SCP_OmniCellServiceAccount();
        	serviceAccountObj.getFieldsMap(inputdata);
        	serviceAccountObj.getSubQueryMap(inputdata);
        Test.stopTest();    
    }
}