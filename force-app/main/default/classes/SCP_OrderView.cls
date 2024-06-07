global class SCP_OrderView{

    public string attachmentid {get; set;} // SCP-769
    global List<ccrz__E_OrderShipment__c> orderShippmentList{get;set;}
    global String orderShippmentListJSON{get;set;}
    global boolean isParentOrder{get;set;}
    public String invPdfLink {get; set;} // IBA-4972
    global SCP_OrderView(){
        String encryptedId  = ApexPages.currentPage().getParameters().get('o');
        orderShippmentListJSON = '';
        isParentOrder = false;
        ccrz__E_Order__c ord = [Select Id,ccrz__CCSubscription__c,SAP_Order_Number__c from ccrz__E_Order__c where ccrz__EncryptedId__c =: encryptedId];
        if(ord!=null && ord.ccrz__CCSubscription__c==null)
                isParentOrder = true;
        orderShippmentList = [Select Id,ccrz__Carrier__c,ccrz__DeliveryDate__c,ccrz__Order__c,ccrz__OrderShipmentId__c,ccrz__ShipmentDate__c,ccrz__ShippingMethod__c,ccrz__TrackingNo__c,Tracking_URL__c from ccrz__E_OrderShipment__c where ccrz__Order__r.ccrz__EncryptedId__c =:encryptedId ];
        if(!orderShippmentList.isEmpty()){
            orderShippmentListJSON = JSON.serialize(orderShippmentList);
            
         }
        // SCP-769 start
        list<Attachment> attachments = [SELECT Id, Body, name FROM Attachment WHERE parentId =: ord.id];
        list<Attachment> noattachments = [SELECT Id, Body, name FROM Attachment limit 1];
        if(attachments.size() > 0){
            attachmentid=attachments[0].id;
        }else{
            attachmentid=noattachments[0].id;
        }
		
        // SCP-769 end
        
        // Start of IBA-4972 changes
        List<ccrz__E_Invoice__c> invList = new List<ccrz__E_Invoice__c>();
        Set<String> invSet = new Set<String>();
        Set<String> cdIdSet = new Set<String>();
		List<ContentVersion> cdv = new List<ContentVersion>();
        invPdfLink = '';
        integer k = 1;
       	invList = [Select id, SAP_Order_Number__c From ccrz__E_Invoice__c WHERE SAP_Order_Number__c = :ord.SAP_Order_Number__c];

        if(invList.size()>0){
            for(ccrz__E_Invoice__c invId : invList){
                invSet.add(invId.Id);
            }
        	List<ContentDocumentLink> cdl = [SELECT ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId IN :invSet];
            for(ContentDocumentLink cd : cdl){
                cdIdSet.add(cd.ContentDocumentId);
            }
            if(cdIdSet.size()>0){
            	cdv = [SELECT id,Image_URL__c,ContentDocumentId from ContentVersion WHERE ContentDocumentId IN :cdIdSet];
            }
            if(cdv.size()>0){
                invPdfLink='<div style="display: inline-block;">';
                for(ContentVersion cdUrl : cdv){
                    invPdfLink+= '<a href="' + cdUrl.Image_URL__c + '" target=_blank style="font-size: small;">INV'+ k +' </a> ';
                    invPdfLink+= '<a href="/sfc/servlet.shepherd/document/download/'+cdUrl.ContentDocumentId +'" target=_blank>&#8595; </a> ';
                    k++;
                }
                invPdfLink+='</div>';
            }
        }	// End of IBA-4972 changes
    }

}