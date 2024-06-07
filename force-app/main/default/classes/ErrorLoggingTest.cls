@isTest
public class ErrorLoggingTest {
    public testmethod static void errorlog(){
        Test.startTest();
        try{
            integer i=1/0;
        }
        Catch(Exception e){
        	ErrorLogging.Log(e,'TestIntegrationClass','Integration');
        }
        ErrorLogging.IntegrationLog('This is test integration error','TestIntegrationClass','Integration');
        Test.stopTest();
    } 
}