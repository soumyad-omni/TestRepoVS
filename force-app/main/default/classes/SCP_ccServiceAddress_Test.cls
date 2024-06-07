@istest
public class SCP_ccServiceAddress_Test {
    
    @istest
    Public static void SCP_ccServiceAddress_Test(){
        Map<String, Object> inputData = new Map<String, Object>();
        inputData.put(ccrz.ccService.OBJECTFIELDS,'str');
        SCP_ccServiceAddress serviceAddrss = new SCP_ccServiceAddress();
        serviceAddrss.getFieldsMap(inputData);
    }

}