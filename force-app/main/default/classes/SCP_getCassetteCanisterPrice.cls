public class SCP_getCassetteCanisterPrice {
    
    public static Map<String,Decimal> getPrice(String effectiveAccId){
        Map<String,Decimal> priceMap = new Map<String,Decimal>();
        List<String> products = new List<String>{'RECALIB','NEW-CALIB'};
            for(String st:products){
                String attributePrice = OmnicellProductDetailController.getAttPrice(effectiveAccId,st);
                
                if(attributePrice != null){
                    if(st == 'NEW-CALIB'){ //IBA-4223 Sourav Start
                        Map<String, Object> attributeJson = (Map<String, Object>) JSON.deserializeUntyped(attributePrice);
                        Map<String, Object> machineJson = (Map<String, Object>) attributeJson.get('aL');
                        Set<string> machineList = new Set<string>(machineJson.keyset()); 
                        Map<String,Object> typeaLJson = (Map<String, Object>)machineJson.get('MACHINE^Default');
                        Map<String, Object> TypeJson = (Map<String, Object>) typeaLJson.get('aL');
                        Set<string> typeList = new Set<string>(TypeJson.keyset());
                        for(String type : typeList){
                            String attType = OmnicellProductDetailController.removeString(type);
                            Map<String,Object> ndcaLJson = (Map<String, Object>) TypeJson.get(type);
                            Map<String, Object> ndcJson = (Map<String, Object>) ndcaLJson.get('aL');
                            Map<String, Object> priceJson = (Map<String, Object>) ndcJson.get('NDC^DEFAULT');
                            if(priceJson != Null){
                                if(attType == 'CB'){
                                    priceMap.put(st+'BRAKE', Integer.valueof(priceJson.get('pr')));
                                    //priceMap.put(st+attType, Integer.valueof(priceJson.get('pr')));
                                }
                                else{
                                    priceMap.put(st+attType, Integer.valueof(priceJson.get('pr')));
                                }
                            }
                        }
                    }							//IBA-4223 Sourav End
                    else{
                        Map<String, Object> attributeJson = (Map<String, Object>) JSON.deserializeUntyped(attributePrice);
                        Map<String, Object> machineJson = (Map<String, Object>) attributeJson.get('aL');
                        Set<string> machineList = new Set<string>(machineJson.keyset());
                        
                        Map<String,Object> attributeData = new Map<String,Object>();
                        String expectedmachine = 'MACHINE^Default';
                        List<String> machineTypes = new List<String>{'Canister','CASSETTE'};
                            for(String expectedtype:machineTypes){
                                System.debug('***'+machineJson);
                                Map<String,Object> typeaLJson = (Map<String, Object>)machineJson.get(expectedmachine);
                                System.debug('***'+typeaLJson);
                                
                                Decimal price = (Decimal)SCP_LogicCartPrice.getAttPrice(typeaLJson,expectedtype);
                                System.debug('***'+st+expectedtype+String.valueOf(price));
                                priceMap.put(st+expectedtype, price);
                            }
                    }
                    
                }
            }
        
        return priceMap;
    }
}