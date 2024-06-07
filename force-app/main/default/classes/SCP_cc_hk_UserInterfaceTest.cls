@isTest
public class SCP_cc_hk_UserInterfaceTest {
    
    	
    	@isTest
        public static void test1(){
            
            Map<String, Object> inputdata = new Map<String, Object>();
            String st = '<script type="text/javascript" src="/resource/1645790849000/ccrz__CC_Javascript_Framework/js/cc3-min.js"></script>';
            inputdata.put('HeadContent',st);
           // Test.startTest();
           
            	SCP_cc_hk_UserInterface sr = new SCP_cc_hk_UserInterface();
            System.debug('****1');
            	Map<String,Object> returndata = sr.headContent(inputdata);
            System.debug('****2');
            	System.debug('****'+returndata);
           // Test.stopTest();
        }
    
    	@isTest
        public static void test2(){
            
            Map<String, Object> inputdata = new Map<String, Object>();
            String st = '<script type="text/javascript" src="/resource/1645790849000/js/cc3-min.js"></script>';
            inputdata.put('HeadContent',st);
           // Test.startTest();
           
            	SCP_cc_hk_UserInterface sr = new SCP_cc_hk_UserInterface();
            System.debug('****1');
            	Map<String,Object> returndata = sr.headContent(inputdata);
            System.debug('****2');
            	System.debug('****'+returndata);
           // Test.stopTest();
        }

}