global class OCB_MyOrdersComponentController {
    
    // added as part of SCP -787 
    public user cuser{get;set;}
    public string HideCuserAccess{get;set;}
    public string ShowCuserAccess{get;set;}  
    
    global OCB_MyOrdersComponentController(){
        // added as part of SCP -787 
        HideCuserAccess = 'none';
        ShowCuserAccess = 'none';
        cuser=new User();
        cuser=[Select Id,Name,Email,Read_Only_User__c from User where Id=:userinfo.getuserId()];
        system.debug('++++++'+cuser.Read_Only_User__c);
        if(cuser.Read_Only_User__c){
            HideCuserAccess = 'block';
            ShowCuserAccess = 'none';
        }else{
            HideCuserAccess = 'none';
            ShowCuserAccess = 'block';
        }
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getAllOrder(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;
        Map<String,object> outputMap= new Map<String,Object>();
        try{
            String accountId = '';
            accountId = ccrz.cc_CallContext.effAccountId;
            String topParentId = '';
            List<Account> efftiveacc = [Select Pardot_Top_Level_Parent_Id__c From Account Where id = :accountId];
            if(efftiveacc.size()>0){
                topParentId = efftiveacc[0].Pardot_Top_Level_Parent_Id__c;
            }
            List<Account> accAll = [Select id From Account Where Pardot_Top_Level_Parent_Id__c=: topParentId];
            Set<String> primAccSet = new Set<String>();
            for(Account ac : accAll){
                primAccSet.add(ac.id);
            }
            
            List<ccrz__E_Order__c> orderList = [Select id, Name,SAP_Order_Number__c,PO_Number__c,ccrz__OrderDate__c,ccrz__TotalAmount__c,ccrz__OrderStatus__c,ccrz__EncryptedId__c,ccrz__BuyerFirstName__c,ccrz__BuyerLastName__c,Account_CSN__c,ccrz__Account__r.Name From ccrz__E_Order__c                                           Where ccrz__EffectiveAccountID__c IN :primAccSet Order By ccrz__OrderDate__c DESC];
            ccRemoteActionResult.success = true; 
            outputMap.put('orderList',orderList); 
            
            //Start of IBA-4972 changes
            Set<String> ordSet = new Set<String>();
            List<wrapMyInvoices> invsList = new List<wrapMyInvoices>();
            Map<String,List<String>> ordUrlMap = new Map<String,List<String>>();
            Map<String, String> invDocId = new Map<String, String>();
            Map<String, String> invIdOrdMap = new Map<String, String>();
            List<String> invPdfUrl = new List<String>();
            List<String> invIdSet = new List<String>();
            Set<String> invSliceSet = new Set<String>();
            Set<String> cdIdSet = new Set<String>();
            Map<String, String> invUrl = new Map<String, String>();
            List<ContentVersion> cdv = new List<ContentVersion>();
            integer i = 1;
            
            for(ccrz__E_Order__c ord : orderList){
                ordSet.add(ord.SAP_Order_Number__c);
            }
            
            List<ccrz__E_Invoice__c> invList = [Select id, SAP_Order_Number__c From ccrz__E_Invoice__c WHERE SAP_Order_Number__c IN :ordSet order by SAP_Order_Number__c];
            for(ccrz__E_Invoice__c inv : invList){
                invIdSet.add(inv.id);
                invIdOrdMap.put(inv.id, inv.SAP_Order_Number__c);
            }
            for(string inv:invIdSet){
                invSliceSet.add(inv);
                if(Math.Mod(i, 2000) == 0){
                    List<ContentDocumentLink> cdl = [SELECT LinkedEntityId, ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId IN :invSliceSet];
                    for(ContentDocumentLink cdLinkId : cdl){
                        invDocId.put(cdLinkId.LinkedEntityId, cdLinkId.ContentDocumentId);
                        cdIdSet.add(cdLinkId.ContentDocumentId);
                    }
                    if(cdIdSet.size()>0){
                        cdv = [SELECT Title, Image_URL__c from ContentVersion WHERE ContentDocumentId IN :cdIdSet];
                    }
                    system.debug(cdv.size());
                    for(ContentVersion cdUrl : cdv){
                        invUrl.put(cdUrl.Title, cdUrl.Image_URL__c);
                    }
                    invSliceSet.clear();
                    cdIdSet.clear();
                }else if(invIdSet.size() == i){
                    List<ContentDocumentLink> cdl = [SELECT LinkedEntityId, ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId IN :invSliceSet];
                    for(ContentDocumentLink cdLinkId : cdl){
                        invDocId.put(cdLinkId.LinkedEntityId, cdLinkId.ContentDocumentId);
                        cdIdSet.add(cdLinkId.ContentDocumentId);
                    }
                    if(cdIdSet.size()>0){
                        cdv = [SELECT Title, Image_URL__c from ContentVersion WHERE ContentDocumentId IN :cdIdSet];
                    }
                    for(ContentVersion cdUrl : cdv){
                        invUrl.put(cdUrl.Title, cdUrl.Image_URL__c);
                    }
                }
                i++;
            }
            String pdfUrl ='';
            Map<String,List<String>> ordDocIdMap = new Map<String,List<String>>();
            for(String invId: invIdOrdMap.keySet()){
                if(invUrl.containskey(invId)){
                    pdfUrl = invUrl.get(invId);
                }else{
                    pdfUrl ='';
                }
               if(String.isNotBlank(pdfUrl)){
                    if(!ordUrlMap.containskey(invIdOrdMap.get(invId))){
                        ordUrlMap.put(invIdOrdMap.get(invId), new List<String>{pdfUrl});
                    }else{
                        ordUrlMap.get(invIdOrdMap.get(invId)).add(pdfUrl);
                    }
                   if(!ordDocIdMap.containskey(invIdOrdMap.get(invId))){
                        ordDocIdMap.put(invIdOrdMap.get(invId), new List<String>{invDocId.get(invId)});
                    }else{
                        ordDocIdMap.get(invIdOrdMap.get(invId)).add(invDocId.get(invId));
                    }
                }

            }
            for(String ord: ordUrlMap.keySet()){
                invsList.add(new wrapMyInvoices(ord, ordUrlMap.get(ord), ordDocIdMap.get(ord)));
            }
            
            outputMap.put('invoicePdfUrl',invsList);
        }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
   
    public class wrapMyInvoices {
        public String ordNum{get; set;}
        public List<String> invUrls{get; set;}
        public List<String> docId{get; set;}
        
        public wrapMyInvoices(String ordNum, List<String> invUrls, List<String> docId) {
            this.ordNum  = ordNum;
            this.invUrls = invUrls;
            this.docId = docId;
        }
    }
    //End of IBA-4972 changes
}