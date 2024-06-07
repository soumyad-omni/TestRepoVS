/* *******************************************************
 * Author: Pavan Kumar
 * Dated: April 27, 2021
 * Description: 
 * a) This batch is used to add Product Media Images from the Shopping Cart Product Content Library, below are the salient features of the batch
 * - If product has already got image and this is again added to the library the old product media image will be replaced with the new product media image record.
 * - Always ensure that the library is clean, so delete all files form the library before you start doing new image upload.
 * - Use this query to perform deletion of files from the library()
     List<ContentDocument> docs = new List<ContentDocument>();    
     for(ContentVersion cv : [Select Id,ContentDocumentId From ContentVersion Where FirstPublishLocationId = 'REPLACEWITHTHELIBRARYIDOFTHEENVIRONMENT']){
     	docs.add(new ContentDocument(Id = cv.ContentDocumentId));    
     }
     delete docs;
 * Next step is to download the images to local folder on computer from the box folder.
 * Next step is to open CMD and provide the folder path and execute the below command to prepare a CSV file with all the files present in the folder.
 * - C:\Users\Pavank\Documents\B2B\B2B Images - Apr 29>dir /B > ImageUploadApr29.csv
 * IMPORTANT NOTE(CAUTION): This batch should only be executed with a scope size of 1, since we are working with files, if the file size is in MBs, we run into heap size issues.
 * So, if any error has occured in between of the batch, it will partially upload the images and will increase the work for you to identify the files that are upload to avoid any duplicay.
 * Alternate Images is an exception to the process where we can not uniquely determine if the altrnate image was uploaded or not. As a work around we are using batch size as 1
 * so there will be only one image per chunck and we are able to manage upto 5 alternate images by doing this process.
 * Test Class: ShoppingCartImageUploadBatch2Test
 * *******************************************************/
global class ShoppingCartImageUploadBatch2 implements Database.Batchable<sObject>{
    Set<String> ccProductSkuSet = new Set<String>();
    Map<String,ContentVersion> titleToContentVersionMap = new Map<String,ContentVersion>();
    Set<String> productMediaSet = new Set<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {     
        String query = '';
        Id workspaceId = [Select Id From ContentWorkSpace Where Name = 'Shopping Cart Products'][0].Id;
        query = 'Select Id,Title,ContentUrl,VersionData,PathOnClient,ContentDocumentId From ContentVersion Where ContentDocument.ParentId = :workspaceId';
        
        if(Test.isRunningTest()){
            Set<String> testImagesSet = new Set<String>{'300-07_PI','300-07_PSI','300-07_PT','200-34_A_1','200-34_A_2'};
                query = 'Select Id,Title,ContentUrl,VersionData,PathOnClient,ContentDocumentId From ContentVersion Where ContentDocument.ParentId = :workspaceId AND Title IN :testImagesSet';
        }   
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ContentVersion> scope){
        
        Set<String> pmattachNameSet = new Set<String>();
        
        for(ContentVersion cv : scope) {
            if(cv.Title.contains('_')){
                ccProductSkuSet.add(cv.Title.substring(0,cv.Title.indexOf('_')));
                
                titleToContentVersionMap.put(cv.Title,cv);
            }
            
            // shall be used to delete alternate image product media record
            if(cv.Title.contains('_A_')){
                pmattachNameSet.add(cv.Title);
            }
        }
        
        Map<String,List<ccrz__E_ProductMedia__c>> pmMap = new Map<String,List<ccrz__E_ProductMedia__c>>();
        
        // get all product media record record based on the products that are part of batch scope
        for(ccrz__E_ProductMedia__c pm : [Select Id,
                                          Name,
                                          ccrz__MediaType__c,
                                          ccrz__Product__c,
                                          ccrz__Product__r.ccrz__SKU__c 
                                          From ccrz__E_ProductMedia__c 
                                          Where ccrz__Product__r.ccrz__SKU__c IN : ccProductSkuSet])
        {
            if(pmMap.containsKey(pm.ccrz__Product__r.ccrz__SKU__c+pm.ccrz__MediaType__c)){                
                pmMap.get(pm.ccrz__Product__r.ccrz__SKU__c+pm.ccrz__MediaType__c).add(pm);
            }else{
                pmMap.put(pm.ccrz__Product__r.ccrz__SKU__c+pm.ccrz__MediaType__c,new List<ccrz__E_ProductMedia__c>{pm});            	
            }      
            productMediaSet.add(pm.ccrz__Product__r.ccrz__SKU__c+pm.ccrz__MediaType__c);
        }
        
        List<ccrz__E_ProductMedia__c> pMediaList = new List<ccrz__E_ProductMedia__c>();
        Map<Id,ccrz__E_Product__c> productMap = new Map<Id,ccrz__E_Product__c>();
        List<ccrz__E_ProductMedia__c> deleteMediaFiles = new List<ccrz__E_ProductMedia__c>();
        
        for(ccrz__E_Product__c ccp : [Select Id,Name,ccrz__SKU__c From ccrz__E_Product__c Where ccrz__SKU__c IN :ccProductSkuSet]) {
            
            productMap.put(ccp.Id,ccp);
            
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_PI')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Product Image',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
                
                if(productMediaSet.contains(ccp.ccrz__SKU__c+'Product Image')){
                    deleteMediaFiles.addAll(pmMap.get(ccp.ccrz__SKU__c+'Product Image'));
                }                
            }
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_PSI')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Product Search Image',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
                
                if(productMediaSet.contains(ccp.ccrz__SKU__c+'Product Search Image')){
                    deleteMediaFiles.addAll(pmMap.get(ccp.ccrz__SKU__c+'Product Search Image'));
                }
            }
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_PT')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Product Image Thumbnail',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
                
                if(productMediaSet.contains(ccp.ccrz__SKU__c+'Product Image Thumbnail')){
                    deleteMediaFiles.addAll(pmMap.get(ccp.ccrz__SKU__c+'Product Image Thumbnail'));
                }
            }
            
            // loop to add all available alternate images in the library
            // exit if no images are found
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_A_1')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Alternate Images',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
            }
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_A_2')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Alternate Images',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
            }
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_A_3')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Alternate Images',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
            }
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_A_4')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Alternate Images',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
            }
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_A_5')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Alternate Images',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
            }
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_A_6')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Alternate Images',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
            }
            if(titleToContentVersionMap.containsKey(ccp.ccrz__SKU__c+'_A_7')){
                pMediaList.add(new ccrz__E_ProductMedia__c(ccrz__MediaType__c = 'Alternate Images',ccrz__ProductMediaSource__c = 'Attachment',ccrz__Product__c = ccp.Id));
            }
        }
        
        if(!pMediaList.isEmpty()) insert pMediaList; 
        
        // remove alternate image record and replace with the new image in the library
        if(!pmattachNameSet.isEmpty()){
            for(Attachment at : [Select Id,ParentId,Name From Attachment Where Name IN :pmattachNameSet]){
                deleteMediaFiles.add(new ccrz__E_ProductMedia__c(Id = at.ParentId));
            }
        }
        
        if(!deleteMediaFiles.isEmpty()) delete deleteMediaFiles;
        
        List<Attachment> attachments = new List<Attachment>();
        
        String attName = '';
        for(ccrz__E_ProductMedia__c pm : pMediaList){
            
            if(pm.ccrz__MediaType__c == 'Product Image'){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_PI').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_PI').VersionData,ParentId = pm.Id));
            }
            
            if(pm.ccrz__MediaType__c == 'Product Search Image'){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_PSI').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_PSI').VersionData,ParentId = pm.Id));
            }
            
            if(pm.ccrz__MediaType__c == 'Product Image Thumbnail'){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_PT').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_PT').VersionData,ParentId = pm.Id));
            }
            
            // loop to add all available alternate images in the library
            // exit if no images are found
            if(pm.ccrz__MediaType__c == 'Alternate Images' && titleToContentVersionMap.containsKey(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_1')){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_1').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_1').VersionData,ParentId = pm.Id));
            }
            if(pm.ccrz__MediaType__c == 'Alternate Images' && titleToContentVersionMap.containsKey(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_2')){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_2').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_2').VersionData,ParentId = pm.Id));
            }
            if(pm.ccrz__MediaType__c == 'Alternate Images' && titleToContentVersionMap.containsKey(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_3')){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_3').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_3').VersionData,ParentId = pm.Id));
            }
            if(pm.ccrz__MediaType__c == 'Alternate Images' && titleToContentVersionMap.containsKey(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_4')){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_4').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_4').VersionData,ParentId = pm.Id));
            }
            if(pm.ccrz__MediaType__c == 'Alternate Images' && titleToContentVersionMap.containsKey(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_5')){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_5').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_5').VersionData,ParentId = pm.Id));
            }
            if(pm.ccrz__MediaType__c == 'Alternate Images' && titleToContentVersionMap.containsKey(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_6')){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_6').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_6').VersionData,ParentId = pm.Id));
            }
            if(pm.ccrz__MediaType__c == 'Alternate Images' && titleToContentVersionMap.containsKey(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_7')){
                attName = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_7').Title;
                attachments.add(new Attachment(Name = attName,Body = titleToContentVersionMap.get(productMap.get(pm.ccrz__Product__c).ccrz__SKU__c+'_A_7').VersionData,ParentId = pm.Id));
            }
        }
        
        if(!attachments.isEmpty()) insert attachments;         
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}