public class ProductDisplayURLPopulateClass {
    public void setDisplayURLForProducts() {
        List<ContentWorkspaceDoc> scopeDocIdList = [SELECT ContentDocumentId, ContentDocument.Latestpublishedversion.Field_Image_URL__c, ContentDocument.Latestpublishedversion.Title FROM ContentWorkspaceDoc WHERE ContentWorkspace.Name = 'Products'];
        system.debug('scopeDocIdList'+scopeDocIdList);    
        set<string> productCodeSet = new set<string>();
        map<string,string> productCodeImageLinkMap = new map<string,string>();
        list<Product2> productsToUpdate = new list<Product2>();
        for(ContentWorkspaceDoc workSpaceDoc : scopeDocIdList){
            productCodeImageLinkMap.put(workSpaceDoc.ContentDocument.Latestpublishedversion.Title, workSpaceDoc.ContentDocument.Latestpublishedversion.Field_Image_URL__c);
        }
        system.debug('productCodeImageLinkMap debug'+productCodeImageLinkMap.keyset());
        for(Product2 product : [SELECT Id, DisplayUrl, ProductCode FROM Product2 WHERE ProductCode = :productCodeImageLinkMap.keyset()]){
            if(productCodeImageLinkMap.containskey(product.ProductCode) && product.DisplayUrl != productCodeImageLinkMap.get(product.ProductCode)){
                product.DisplayUrl = productCodeImageLinkMap.get(product.ProductCode);
                productsToUpdate.add(product);
            }
        }
        system.debug('productsToUpdate--'+productsToUpdate.size());
        if(!productsToUpdate.isEmpty()){
            if(!Test.isRunningTest()) {
                update productsToUpdate;
            }
        }
    }
}