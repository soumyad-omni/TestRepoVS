public with sharing class SCP_SoapBuilder {
    public static String buildEnvelope(String templateName, Map<String, String> data) {
    	if (data == null) {
    		return '';
    	}

    	String template = [ Select developername ,text__c from SCP_Metadata__mdt LIMIT 1 ].DEVELOPERNAME;
    	for (String key : data.keySet()) {
    		String value =  data.get(key);
    		template = template.replace(key, value);
    	}
    	return template;
    } 
}