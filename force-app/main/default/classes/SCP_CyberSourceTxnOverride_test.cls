@istest
public class SCP_CyberSourceTxnOverride_test {

    @istest
    public static void CyberSourceTxn_test(){
      Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        Test.startTest();
          SCP_CyberSourceTxnOverride CyberTxnObj = new SCP_CyberSourceTxnOverride();
          CyberTxnObj.process(inputdata);
          CyberTxnObj.preProcess(inputdata);
          CyberTxnObj.postProcess(inputdata);
        Test.stopTest();    
    }
}