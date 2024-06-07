public class ApplixAssetSummaryController {
    private static final List<String> applixAssetsList  = new List<String>{'AcuDose-Rx®','Admin-Rx','Anesthesia-Rx','Automation Decision Support','CarePoint-Connect™',
                                                                           'Connect-RN™','Connect-Rx','Fulfill-Rx(SM)','Horizon MedComm-Rx™','Horizon Meds Manager', 'i.v Solutions','i.v. STATION', 
                                                                           'i.v. STATION ONCO','i.v.STATION Workflow','IntelliShelf Supply™', 'IntelliShelf-Rx™', 'MedCarousel®', 'MedShelf-Rx',
                                                                           'NarcStation™', 'Packaging Solutions', 'Performance Center', 'PROmanager-Rx™', 'ROBOT-Rx®', 'ServiceKit', 'TempSys CheckPoint'
                                                                           };
                                                                                
    private static final Map<String,String> applixAssetsMap  = new Map<String,String>{'AcuDose-Rx®'=>'AcuDose-Rx®',
                                                                                      'Admin-Rx'=>'Admin-Rx',
                                                                                      'Anesthesia-Rx'=>'Anesthesia-Rx',
                                                                                      'Automation Decision Support'=>'Automation Decision Support',
                                                                                      'CarePoint-Connect™'=>'CarePoint-Connect™',
                                                                                      'Connect-RN™'=>'Connect-RN™',
                                                                                      'Connect-Rx'=>'Connect-Rx',
                                                                                      'Fulfill-Rx(SM)'=>'Fulfill-Rx(SM)',
                                                                                      'Horizon MedComm-Rx™'=>'Horizon MedComm-Rx™',
                                                                                      'Horizon Meds Manager'=>'Horizon Meds Manager',
                                                                                      'i.v Solutions'=>'i.v Solutions',
                                                                                      'i.v. STATION'=>'i.v. STATION',
                                                                                      'i.v. STATION ONCO'=>'i.v. STATION ONCO',
                                                                                      'i.v.STATION Workflow'=>'i.v.STATION Workflow',
                                                                                      'IntelliShelf Supply™'=>'IntelliShelf Supply™',
                                                                                      'IntelliShelf-Rx™'=>'IntelliShelf-Rx™',
                                                                                      'MedCarousel®'=>'MedCarousel®',
                                                                                      'MedShelf-Rx'=>'MedShelf-Rx',
                                                                                      'NarcStation™'=>'NarcStation™',
                                                                                      'Packaging Solutions'=>'Packaging Solutions',
                                                                                      'Performance Center'=>'Performance Center',
                                                                                      'PROmanager-Rx™'=>'PROmanager-Rx™',
                                                                                      'ROBOT-Rx®'=>'ROBOT-Rx®',
                                                                                      'ServiceKit'=>'ServiceKit',
                                                                                      'TempSys CheckPoint'=>'TempSys CheckPoint' }; 
                                                                                      
    


    public class ApplixAssetSummary{
        @AuraEnabled public String category;
        @AuraEnabled public Integer count;
        public ApplixAssetSummary(String category, Integer count){
            this.category = category;
            this.count = count;
        }
    }
    
    @AuraEnabled public static List<ApplixAssetSummary> getApplixAssetSummarys(String accountId){
        Map<String, Integer> mapAppixAsset = new Map<String, Integer>();
        List<ApplixAssetSummary> lstApplixAssetSummary = new List<ApplixAssetSummary>();
        for(AggregateResult ar : [SELECT Category__c category, COUNT(asset_id__c) totalAsset FROM Applix_Assets__c WHERE Account__c =: accountId GROUP BY category__c]){
            mapAppixAsset.put(String.valueOf(ar.get('category')), Integer.valueOf(ar.get('totalAsset')));
            //lstApplixAssetSummary.add(new ApplixAssetSummary(String.valueOf(ar.get('category')), Integer.valueOf(ar.get('totalAsset'))));
        }
        
        for(String category : applixAssetsList){
            lstApplixAssetSummary.add(new ApplixAssetSummary(category, mapAppixAsset.containsKey(category) ? mapAppixAsset.get(category) : 0));
        }
        return lstApplixAssetSummary;
    }

}