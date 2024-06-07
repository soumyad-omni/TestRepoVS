@istest
public class SCP_SoapBuilder_Test {
    
    @istest 
    public static void SCP_SoapBuilder_Test_method(){
        Map<String, String> data = new Map<String, String>();
         Test.startTest();
         try{
        SCP_SoapBuilder.buildEnvelope('test',data);
        data.put('test','abc');
        SCP_SoapBuilder.buildEnvelope('test',data);
        }
        catch(exception e){}
        Test.stopTest();
    }
}