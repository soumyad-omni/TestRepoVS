public class has_omnicell_essential_controller {

   @AuraEnabled
   public static list<string> isrendered(string key, string obj){
       
       list<string> return_val = new list<string>();
       /*boolean isOmni_essen = false;
       boolean skipOmni_essen = false; //IBA-1527
       string sobj = obj;
       id qid;
       
       if(sobj == 'Quote'){
           qid = key;
       }else{
           list<Quote_Approval__c> qap_list = new list<Quote_Approval__c>();
           qap_list = [select id,Quote__c from Quote_Approval__c WHERE Id=:key];
           qid = qap_list[0].Quote__c;
       }
       
       List<quote_line__c> qlinesOmni = [select id,product__r.DW_Product_Line__c,Higher_Level_Item__c,Product_Code__c from quote_line__c where quote__c=:qid and (product__r.DW_Product_Line__c = 'Omnicell Essentials' or Pricing_Reference_Model__r.DW_Product_Line__c in ('Omnicell Essentials'))]; 
       List<quote_line__c> qlinesAll = [select id,product__r.DW_Product_Line__c from quote_line__c where quote__c=:qid and product__r.DW_Product_Line__c != 'Freight']; 
       List<quote_line__c> qlinesOCE_LIC = [select id From Quote_Line__c Where Quote__c = :qid AND Product_Code__c = 'OCE-LIC-001' AND Higher_Level_Item__c != 0];//Added for IBA-1527 Start
       if(qlinesOmni.size() == qlinesOCE_LIC.size()){
           skipOmni_essen = true;
       }//Added for IBA-1527 END
       integer Omni_size = qlinesOmni.size();
       integer All_size = qlinesAll.size();
       System.debug('Omni_size::::' +Omni_size);
       System.debug('All_size::::::' +All_size);
       System.debug('skipOmni_essen::::::' +skipOmni_essen);
       if(Omni_size > 0){
           if(Omni_size != All_size && skipOmni_essen == false){//Added flag for IBA-1527
               isOmni_essen = true;
           }
   	   }
       
       list<quote> qt = [select id, isOmnicellEssential__c,Order_Type__c from quote where id =: qid]; //IBA-3639
       
       if(isOmni_essen == true && qt[0].Order_Type__c != 'ZQRS'){ //IBA-3639
           return_val.add('true');
           if(qt[0].isOmnicellEssential__c == false){
           qt[0].isOmnicellEssential__c =true;
           QuoteTriggerHandler.TriggerDisabled = true;
           update qt;
           }
       }else{
           return_val.add('false');
           if(qt[0].isOmnicellEssential__c == true){
           qt[0].isOmnicellEssential__c =false;
           QuoteTriggerHandler.TriggerDisabled = true;
           update qt;
           }
       }       
       
       list<Omnicell_essential_error__c> errList = [select name, Error__c from Omnicell_essential_error__c limit 1];
       string err = errList[0].Error__c;
       return_val.add(err);
       system.debug(return_val);*/
       
       return return_val;
   }
    
    
}