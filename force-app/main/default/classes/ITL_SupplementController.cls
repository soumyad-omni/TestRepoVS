public with sharing class ITL_SupplementController {
    
    @AuraEnabled
    public static Boolean isSmallPartDiscounted(String quoteId, String recordTypeId)
    {
        Boolean retVal = false;
      /*  if(recordTypeId == 'Small Parts')
        {
            
            Quote quoteRec = null;
            List<Quote> lstQuote = [SELECT Id,Master_Agreement__c, Opportunity.Pre_Approved_Parts__c,Order_Type__c,subscription_Months__c,
                                           Conga_one_time_Impl_Fee__c,GPO_preapproved__c,IDN_Preapproved__c,Discounting__c,Pre_Approvedpart__c,
                                           Lease_To_Own_Perc__c ,SAP_Expected_Bookings__c ,Conga_Total_Shipping_and_Handling__c
                                    FROM Quote WHERE Id =:quoteId];
            if(lstQuote.size() > 0) quoteRec = lstQuote[0];
            if(quoteRec!= null && quoteRec.Opportunity.Pre_Approved_Parts__c == TRUE &&
               quoteRec.Master_Agreement__c <> null && 
               String.valueOf(quoteRec.Order_Type__c) <> 'ZQRL' && String.valueOf(quoteRec.Order_Type__c) <> 'ZQLI' && 
               String.valueOf(quoteRec.Order_Type__c) <> 'ZQR3' && String.valueOf(quoteRec.Order_Type__c) <> 'ZQL3' && 
               quoteRec.GPO_preapproved__c == TRUE && quoteRec.IDN_Preapproved__c == TRUE &&
               quoteRec.Discounting__c == FALSE  && quoteRec.Pre_Approvedpart__c == TRUE &&
               (quoteRec.Lease_To_Own_Perc__c == 0 || String.valueOf(quoteRec.Lease_To_Own_Perc__c) == '') && quoteRec.SAP_Expected_Bookings__c <= 50000   	
            )
            {
                retVal = true;
            }
        }*/
        return retVal;        
    }
    
    
    @AuraEnabled
    public static Id saveQuoteApproval(Quote_Approval__c quoteApp, String quoteId, String recordTypeId, boolean isSaveSubmitClick){
          Quote_Approval__c qa = new Quote_Approval__c(
        	Comment__c = quoteApp.Comment__c,
            Discounting__c = quoteApp.Discounting__c,
            Only_Pricing_Changes_Made__c = quoteApp.Only_Pricing_Changes_Made__c,
            Discounting_Instruction__c = quoteApp.Discounting_Instruction__c,
            Quote__c = quoteId,
            RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get(recordTypeId).getRecordTypeId()
        );
        insert qa;
        return qa.Id;        
    }
    
	@AuraEnabled
    public static void saveQuoteApp(Quote_Approval__c quoteApp, String quoteId, String recordTypeId, boolean isSaveSubmitClick,String ids){
        list<Quote_Line__c> quoteLines = [SELECT Portfolio_Segment__c,Quote__c,DW_Product_Line__c,Product__r.Product_Type__c,Higher_Level_Item__c, Add_to_cart__c,Product__r.ProductCode,External_Config__c FROM Quote_Line__c WHERE Quote__c=:quoteId];
	//IBA-1265 - Quote Approval for Standard Configuration 
        Boolean madeToStockFlag = true;	//If  all products are of Product type as Std Config or option then marked as TRUE
        Boolean acuDoseOnXT = true;	//if any of the Product of Quote line is AcuDose on XT then marked as TRUE
        Boolean isAdvServAppReq = false;
        Map<String, Advance_Service_Portfolio_Segments__mdt> mapEd = Advance_Service_Portfolio_Segments__mdt.getAll();
        system.debug('Advance_Service_Portfolio_Segments****' +mapEd);
        Set<String> prtfolioSegment = new Set<String>();
        for(String var: mapEd.keySet()){
            prtfolioSegment.add(mapEd.get(var).MasterLabel);
        }
        
        Quote qute;
        if(quoteId != null){
            qute = [Select Id, Order_Type__c, Opportunity.OpportunityGroup__c from Quote where Id =: quoteId][0];
        }
        
        for(Quote_Line__c qline : quoteLines){
	     if(qline.Product__r.Product_Type__c != 'Std Config Omnicell Install' && qline.Product__r.Product_Type__c != 'Option' && (qline.Higher_Level_Item__c == null || qline.Higher_Level_Item__c == 0) && qline.Product__r.ProductCode != 'FREIGHT'  ){
			madeToStockFlag = false;
               }
         //IBA-1767
		 if( qline.Product__r.Product_Type__c == 'Option' && qline.External_Config__c==true){
			  madeToStockFlag = false;
			  } //IBA-1767 
	     if(qline.DW_Product_Line__c == 'AcuDose on XT'){
			acuDoseOnXT = false;
	       }
            System.debug('madeToStockFlag: '+madeToStockFlag);
            System.debug('acuDoseOnXT: '+acuDoseOnXT);
            System.debug('prtfolioSegment: '+prtfolioSegment);
             System.debug('prtfolioSegment: '+qline.DW_Product_Line__c);
         if((recordTypeId.contains('Budgetary') || recordTypeId.contains('Supplement')) 
            && recordTypeId != 'International ADC/VBM Supplement' &&(prtfolioSegment.contains(qline.DW_Product_Line__c))){
                    isAdvServAppReq = true;
           }
            //IBA-2502 STARTS
         else if((recordTypeId.contains('Budgetary') || recordTypeId.contains('Supplement')) 
                 && recordTypeId != 'International ADC/VBM Supplement' &&(qline.Portfolio_Segment__c == 'Core Machine'||qline.Portfolio_Segment__c == 'SingleDose Automation')&& qute.Order_Type__c == 'ZQRS'){
                       isAdvServAppReq = true;
                 }
           //IBA-2502 ENDS
        }
		
        
        
       
        Quote_Approval__c qa = new Quote_Approval__c(
            Made_to_Stock__c = madeToStockFlag,         //IBA-1265 - Quote Approval for Standard Configuration 
            AcuDose_on_XT_Check__c = acuDoseOnXT, 	//IBA-1265 - Quote Approval for Standard Configuration 
            Comment__c = quoteApp.Comment__c,
            Discounting__c = quoteApp.Discounting__c,
            Only_Pricing_Changes_Made__c = quoteApp.Only_Pricing_Changes_Made__c,
            Discounting_Instruction__c = quoteApp.Discounting_Instruction__c,
            Quote__c = quoteId,
            RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get(recordTypeId).getRecordTypeId(), 
            Advance_Service_Approval_Required__c = isAdvServAppReq
        );
        insert qa;
        System.debug(qa);
        System.debug('***'+isAdvServAppReq);
        
        System.debug('***'+ids);//Added by Sourav IBA-1297 Start
        if(ids!=null){
                List<String> fileidList = ids.split(',');//(List<string>) JSON.deserialize(ids, List<string>.class);
                Set<string> idonly = new Set<string>(fileidList);
                if(idonly.size()>0){
                    idonly.remove('undefined'); //remove 'undefined'
                }
                fileidList = new list<string>(idonly);
                List<ContentDocumentLink> allfiles = new List<ContentDocumentLink>();
                if(fileidList.size()>0){
                    for(String qt: fileidList){
                            ContentDocumentLink  obj = new ContentDocumentLink ();
                            obj.ContentDocumentId  = qt;
                            obj.LinkedEntityId  = qa.id;
                            allfiles.add(obj);
                             
                    }
                }
                try{
                    //ContentDocLinkTriggerHandler.TriggerDisabled = true;
                    insert allfiles;
                }
                catch(DmlException e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                }//Added by Sourav IBA-1297 End
        }
        if(isSaveSubmitClick == true){
            submitForApprovalRequest(qa.id);
        }   
        
    }
    
    @AuraEnabled
    public static Integer saveChunk(Quote_Approval__c quoteApp, String quoteApprovalId, String recordTypeId, boolean isSaveSubmitClick,
                               String fileName, String base64Data, String contentType,Integer index,Integer filesCount) 
    {   
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = quoteApprovalId; 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType; 
        insert oAttachment;
 
       if(isSaveSubmitClick == true && (index+1 == filesCount)){
         submitForApprovalRequest(quoteApprovalId);
       } 
        return index;
    }
    
       
    private static void submitForApprovalRequest(id quoteAppId){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setObjectId(quoteAppId);
		Approval.ProcessResult result = Approval.process(req1);
	}
	
    @AuraEnabled 
    public static Map<String, String> getTagPicklist(){//IBA-6018
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = ContentVersion.Tag__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

    @AuraEnabled
    public static void processRecords(List<ContentVersion> records) {//IBA-6018
        
        System.debug('Received Records: ' + records);
        update records;
    }
}