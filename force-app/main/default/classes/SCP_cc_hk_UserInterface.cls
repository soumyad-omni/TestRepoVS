global virtual with sharing class SCP_cc_hk_UserInterface extends ccrz.cc_hk_UserInterface.v004 {
    global SCP_cc_hk_UserInterface(){
        
    }
    global virtual override Map<String,Object> headContent(Map<String,Object> inpData) {
        if(!Test.isRunningTest()){
            inpData = super.headContent(inpData);
        }
        System.debug('JavScript_SRV'+inpData.get(HEAD_CONTENT));
        
        String text = (String)inpData.get(HEAD_CONTENT);
        List<String> parts = text.split('\n');
        String headString = '';
        for(String st:parts){
            if(st.contains('ccrz__CC_Javascript_Framework')){
                 st = st.replace('ccrz__CC_Javascript_Framework', 'SCP_CC_Javascript_Framework');
                 headString =  headString+st+'\n';  
            }
            else{
                headString = headString+st+'\n';
            }
        }
        System.debug('---'+headString);
        
        inpData.put(HEAD_CONTENT,headString);
        System.debug('JavScript_SRV'+inpData.get('HeadContent'));
        return inpData;
    }
    
}