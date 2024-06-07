global class OmnicellProductDetailController{
    public user cuser{get;set;}
    public string HideCuserAccess{get;set;}
    public string ShowCuserAccess{get;set;}
    public string shipTo{get;set;}//IBA-4129
    public string billTo{get;set;}//IBA-4129
    public static List<DrugCode__c> allDrugList {get;set;}
    public List<wrapCartItems> itemsList {get; set;}
    public list<string> monthName {get; set;}
    global Transient String currentCartItems{get;set;}
    public OmnicellProductDetailController(){
        shipTo = '';//IBA-4129
        billTo = '';//IBA-4129
        List<ccrz__E_ContactAddr__c>  contactAddressList = new List<ccrz__E_ContactAddr__c> ();
        itemsList = new List<wrapCartItems>();
        HideCuserAccess = 'none';
        ShowCuserAccess = 'none';
        cuser=new User();
        cuser=[Select Id,Name,Email,Read_Only_User__c from User where Id=:userinfo.getuserId()];
        system.debug('++++++'+cuser.Read_Only_User__c);
        List<AsyncApexJob> allDrugLoadJobs = [SELECT Id,Status,CreatedBy.Name FROM AsyncApexJob Where CreatedById =:UserInfo.getUserId() AND 
                                              Status IN ('Holding','Preparing','Processing','Queued') AND 
                                              ApexClass.Name = 'DrugCodeBulkUploadQueueable']; //IBA-3841 - Sourav
        if(cuser.Read_Only_User__c || allDrugLoadJobs.size()>0){ //IBA-3841 - Sourav
            HideCuserAccess = 'block';
            ShowCuserAccess = 'none';
        }
        else{
            HideCuserAccess = 'none';
            ShowCuserAccess = 'block';
        }
        allDrugList = new List<DrugCode__c>();
    }
    
    
    @RemoteAction @ReadOnly
    global static ccrz.cc_RemoteActionResult getAttributes(ccrz.cc_RemoteActionContext ctx){
        
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        String accID = ccrz.cc_CallContext.effAccountId;
        AggregateResult[] argPurchAlloc = [Select Machine_Name__c mch,Sum(Recalibrations_Purchased__c) prch From Machine__c Where Account_CSN__c =:accID Group By Machine_Name__c];
        Map<String,Decimal> argPurchAllocMap = new Map<String,Decimal>();
        for(Integer i=0;i<argPurchAlloc.size();i++){
            String mc = (String)argPurchAlloc[i].get('mch');
            Decimal prc = (Decimal)argPurchAlloc[i].get('prch');
            argPurchAllocMap.put((String)argPurchAlloc[i].get('mch'),(Decimal)argPurchAlloc[i].get('prch'));
        }
        Map<String,String> pageParamMap = ccrz.cc_CallContext.currPageParameters;
        System.debug('****'+pageParamMap.get('sku'));
        
        
        List<Machine__c> machineTypeMap2 = [Select Id,Machine_Name__c,Machine_Type_Mapping__c,Agreement_sign_date__c,
                                            Recalibration_Allotment__c,Recalibrations_Purchased__c,New_Calibration_Allotment__c,Purchased__c
                                            From Machine__c Where Account_CSN__c =:accID];
        List<String> machineListOnlyNames = new List<String>();
        String ProductId = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c = :pageParamMap.get('sku') Limit 1].Id;
        String attributePrice = getAttPrice(accID,pageParamMap.get('sku'));
        if(attributePrice != Null){
            Map<String, Object> attributeJson = (Map<String, Object>) JSON.deserializeUntyped(attributePrice);
            Map<String, Object> machineJson = (Map<String, Object>) attributeJson.get('aL');
            Map<String,Object> typeaLJson = (Map<String, Object>)machineJson.get('MACHINE^Default');
            Set<string> machineList = new Set<string>(machineJson.keyset());
            
            Map<String,Map<String,Object>> attributeData = new Map<String,Map<String,Object>>();
            Map<String,Decimal> allotment = new Map<String,Decimal>();
            Map<String,Decimal> purchased = new Map<String,Decimal>();
            
            Map<String,Decimal> newcaliballotment = new Map<String,Decimal>();
            Map<String,Decimal> newcalibpurchased = new Map<String,Decimal>();
            
            for(Machine__c machine : machineTypeMap2){
                machineListOnlyNames.add(machine.Machine_Name__c);
                purchased.put(machine.Machine_Name__c,argPurchAllocMap.get(machine.Machine_Name__c));
                allotment.put(machine.Machine_Name__c,machine.Recalibration_Allotment__c);
                newcaliballotment.put(machine.Machine_Name__c, machine.New_Calibration_Allotment__c);
                newcalibpurchased.put(machine.Machine_Name__c, machine.Purchased__c);
                Map<String,Object> type = new Map<String,Object>();
                String machineStyle = checkMachineStyle(machine.Machine_Type_Mapping__c);
                if(attributeData.get(machine.Machine_Name__c)!= null)
                { 
                    type = attributeData.get(machine.Machine_Name__c);
                    attributeData.put(machine.Machine_Name__c,typeGenerator(type,machineStyle,typeaLJson,pageParamMap.get('sku')));//IBA-4223 Sourav
                }
                else{
                    attributeData.put(machine.Machine_Name__c,typeGenerator2(type,machineStyle,typeaLJson,machine.Machine_Type_Mapping__c,pageParamMap.get('sku')));//IBA-4223 Sourav
                }
                
            }
            System.debug('***'+attributeData);
            outputMap.put('machineNamesOnly',machineListOnlyNames);
            outputMap.put('customattributeData',attributeData);
            outputMap.put('calibrationAllotted',allotment);
            outputMap.put('calibrationPurchased',purchased);
            outputMap.put('newcalibrationAllotted',newcaliballotment);
            outputMap.put('newcalibrationPurchased',newcalibpurchased);
        }
        try{
            String parentNDCId = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'].Id;
            
            List<DrugCode__c> drgList = [Select Generic_Drug_Name__c,Brand_Name__c,Manufacturer_Name__c,DrugCodes__c,Drug_Strength__c From DrugCode__c  Where DrugCodes__c != ''  Limit 30000];
            
            ccRemoteActionResult.success = true; 
            allDrugList = drgList;
            System.debug('***'+drgList.size());
            outputMap.put('optionListNew',drgList); 
        }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        List<String> drugForm = new List<String>();
        List<String> drugUnit = new List<String>();
        Schema.DescribeFieldResult objFieldDescribeUnit = DrugCode__c.Dose_Unit__c.getDescribe();
        List<Schema.PicklistEntry> unitPickListValues = objFieldDescribeUnit.getPickListValues();
        for (Schema.PicklistEntry objPickList : unitPickListValues) {
            drugUnit.add(objPickList.getValue());
        }
        outputMap.put('drugUnits',drugUnit); 
        Schema.DescribeFieldResult objFieldDescribeForm = DrugCode__c.Drug_Forms__c.getDescribe();
        List<Schema.PicklistEntry> formPickListValues = objFieldDescribeForm.getPickListValues();
        for (Schema.PicklistEntry objPickList : formPickListValues) {
            drugForm.add(objPickList.getValue());
        }
        outputMap.put('drugForms',drugForm); 
        ccRemoteActionResult.success = true;
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static Map<String,Object> typeGenerator(Map<String,Object> typeExisting, String newType,Map<String,Object> typeaLJson, String sku){
        String typeFlag = 'Canister';
        if(sku == 'NEW-CALIB'){//IBA-4223 Sourav Start
            typeFlag= newType;
        }
        else{
            if(newType != 'Canister'){
                typeFlag = 'Cassette';
            }
        }								//IBA-4223 Sourav End
        
        Map<String, Object> TypeJson = (Map<String, Object>) typeaLJson.get('aL');
        Set<string> typeList = new Set<string>(TypeJson.keyset());
        for(String type : typeList){
            if(sku == 'NEW-CALIB'){//IBA-4223 Sourav Start
                String attType = OmnicellProductDetailController.removeString(type);
                if(attType == typeFlag || (typeFlag == 'Cassette' && (attType == 'BASE' || attType == 'CB' ))){ 
                    Map<String,Object> ndcaLJson = (Map<String, Object>) TypeJson.get(type);
                    Map<String, Object> ndcJson = (Map<String, Object>) ndcaLJson.get('aL');
                    Map<String, Object> priceJson = (Map<String, Object>) ndcJson.get('NDC^DEFAULT');
                    if(priceJson != Null){
                        String price = '$'+priceJson.get('pr');
                        if(attType == 'CB'){		
                            typeExisting.put('BRAKE',price);
                        }
                        else{
                            typeExisting.put(attType,price); 
                        }								   
                    }
                }
            }																	//IBA-4223 Sourav - End
            else{
                if(OmnicellProductDetailController.removeString(type) == typeFlag){
                    Map<String,Object> ndcaLJson = (Map<String, Object>) TypeJson.get(type);
                    Map<String, Object> ndcJson = (Map<String, Object>) ndcaLJson.get('aL');
                    Map<String, Object> priceJson = (Map<String, Object>) ndcJson.get('NDC^DEFAULT');
                    if(priceJson != Null){
                        String price = '$'+priceJson.get('pr');
                        typeExisting.put(newType,price);
                    }
                }
            }
        }
        return typeExisting;
    }
    
    public static Map<String,Object> typeGenerator2(Map<String,Object> typeExisting, String newType,Map<String,Object> typeaLJson,String machine, String sku){
        String typeFlag = 'Canister';
        if(sku == 'NEW-CALIB'){//IBA-4223 Sourav Start
            typeFlag= newType;
        }
        else{
            if(newType != 'Canister'){
                typeFlag = 'Cassette';
            }
        }								//IBA-4223 Sourav End
        Map<String, Object> TypeJson = (Map<String, Object>) typeaLJson.get('aL');
        Set<string> typeList = new Set<string>(TypeJson.keyset());
        for(String type : typeList){
            if(sku == 'NEW-CALIB'){//IBA-4223 Sourav Start
                String attType = OmnicellProductDetailController.removeString(type);
                if(attType == typeFlag || (typeFlag == 'Cassette' && (attType == 'BASE' || attType == 'CB' ))){ 
                    Map<String,Object> ndcaLJson = (Map<String, Object>) TypeJson.get(type);
                    Map<String, Object> ndcJson = (Map<String, Object>) ndcaLJson.get('aL');
                    Map<String, Object> priceJson = (Map<String, Object>) ndcJson.get('NDC^DEFAULT');
                    if(priceJson != Null){
                        String price = '$'+priceJson.get('pr');
                        System.debug(machine);
                        if(attType == 'CB'){		
                            typeExisting.put('BRAKE',price);
                        }
                        else{
                            typeExisting.put(attType,price); 
                        }								  
                    }
                }
            }						//IBA-4223 Sourav - End					 
            else{
                if(OmnicellProductDetailController.removeString(type) == typeFlag){
                    Map<String,Object> ndcaLJson = (Map<String, Object>) TypeJson.get(type);
                    Map<String, Object> ndcJson = (Map<String, Object>) ndcaLJson.get('aL');
                    Map<String, Object> priceJson = (Map<String, Object>) ndcJson.get('NDC^DEFAULT');
                    if(priceJson != Null){
                        String price = '$'+priceJson.get('pr');//+'.00';
                        if(machine != 'Pacmed' && machine != 'OD400' && machine != 'VBM'){
                            typeExisting.put('BASE',price);
                            typeExisting.put('BRAKE',price);
                        }
                        else{
                            typeExisting.put(newType,price);
                        }
                    }
                }
            }
        }
        return typeExisting;
    }
    
    public static String removeString(String updateString){
        String s1 = updateString.substring(updateString.indexOf('^')+1);
        s1.trim();
        return s1;
    }
    
    public static Map<String,Decimal> typeAlltmentPurchase(Map<String,Decimal> esitingType, String type,Decimal alltPurchascount){
        esitingType.put(type, alltPurchascount);
        return esitingType;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult upsertCartItem(ccrz.cc_RemoteActionContext ctx,String prodattributeData){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false; 
        Map<String,object> outputMap= new Map<String,Object>();
        Map<String,object> attributeDataMap = (Map<String, Object>)JSON.deserializeUntyped(prodattributeData);
        System.debug('***'+attributeDataMap);
        Boolean drugCheck = drugCheckInSystem((String)attributeDataMap.get('drugCode'));
        String prodSKU = '';
        if(drugCheck){
            String currCartEncryptedId = ccrz.cc_CallContext.currCartId;
            String accID = ccrz.cc_CallContext.effAccountId;
            attributeDataMap.put('currEffacc',accID);
            String currCartId = [Select Id From ccrz__E_Cart__c Where ccrz__EncryptedId__c = :currCartEncryptedId Limit 1].Id;
            prodSKU = (String)attributeDataMap.get('SKU');
            List<ccrz__E_CartItem__c> cartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,ccrz__Product__r.ccrz__SKU__c
                                                      From ccrz__E_CartItem__c Where ccrz__Cart__c =:currCartId AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = :prodSKU];
            
            if(cartItemList.size() >0){
                //create minor items
                String status = createMinorCartItem(prodSKU,cartItemList[0],attributeDataMap);
                if(status == 'success'){
                    outputMap.put('status','successfull');
                }
                else{
                    outputMap.put('status','failed');
                }
            }
            else{
                //create major item and then create minor items
                String majorId = createMajorCartItem(currCartId,attributeDataMap);
                if(majorId != 'failed'){
                    List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,ccrz__Product__r.ccrz__SKU__c
                                                                 From ccrz__E_CartItem__c Where ccrz__Cart__c =:currCartId 
                                                                 AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = :prodSKU];
                    String status = createMinorCartItem(prodSKU,newcartItemList[0],attributeDataMap);
                    if(status == 'success'){
                        outputMap.put('status','successfull');
                    }
                    else{
                        outputMap.put('status','failed');
                    }
                }
                
            }
        }
        else{
            outputMap.put('status','failed');
        }
        System.debug(prodSKU);
        ccRemoteActionResult.success = true;
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static String createMajorCartItem(String currCartId,Map<String,object> attributeDataMap){
        try{
            ccrz__E_CartItem__c majorItem = new ccrz__E_CartItem__c(ccrz__Cart__c = currCartId,ccrz__cartItemType__c = 'Major',
                                                                    ccrz__ProductType__c = 'Product',ccrz__UnitOfMeasure__c='EA',ccrz__StoreID__c='OmnicellB2BStore',
                                                                    ccrz__PricingType__c='attrGroup');
            majorItem.ccrz__RequestDate__c = System.today();
            majorItem.ccrz__Price__c = 0;
            majorItem.ccrz__Quantity__c = 1;
            majorItem.ccrz__SubAmount__c = majorItem.ccrz__Quantity__c*majorItem.ccrz__Price__c;
            majorItem.ccrz__OriginalQuantity__c = majorItem.ccrz__Quantity__c;
            majorItem.ccrz__OriginalItemPrice__c = majorItem.ccrz__Price__c;
            majorItem.ccrz__Product__c = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c = :(String)attributeDataMap.get('SKU') Limit 1].Id;
            insert majorItem;
            return majorItem.Id;
        }
        catch(Exception e){
            System.debug(e);
            return 'failed';
        }
    }
    
    public static String createMinorCartItem(String sku, ccrz__E_CartItem__c majorcartItem,Map<String,object> attributeDataMap){
        String machine = (String)attributeDataMap.get('machine');
        String type = (String)attributeDataMap.get('type');
        String typeFlag = 'Canister';
        if(sku == 'NEW-CALIB'){ //IBA-4223 Sourav Start
            if(type == 'BRAKE'){
                typeFlag = 'CB';
            }
            else{
                typeFlag = type;
            }
        }
        else{
            if(type != 'Canister'){
                typeFlag = 'Cassette';
            }
        }								//IBA-4223 Sourav End
        System.debug('***'+type+'***'+sku);
        
        String drugCode = (String)attributeDataMap.get('drugCode');
        
        DrugCode__c ndc = [Select Id From DrugCode__c Where DrugCodes__c =:drugCode Limit 1];
        DrugCode__c drCode = [Select Id,Brand_Name__c,Generic_Drug_Name__c,Manufacturer_Name__c,Drug_Strength__c From DrugCode__c Where DrugCodes__c =:drugCode limit 1];
        String primaryAttrName = 'Default';
        String tertiaryAttrName = 'Default';
        String machineParentattrId = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'].Id;
        String typeParentattrId = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'TYPE'].Id;
        String drgCodeParentattrId = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'].Id;
        String primaryAttrId = [Select Id From ccrz__E_Attribute__c Where ccrz__ParentAttribute__c = :machineParentattrId AND Name = :primaryAttrName Limit 1].Id;
        String seconAttrId = [Select Id From ccrz__E_Attribute__c Where ccrz__ParentAttribute__c = :typeParentattrId AND Name = :typeFlag Limit 1].Id;
        String tertiaryAttrId = [Select Id From ccrz__E_Attribute__c Where ccrz__ParentAttribute__c = :drgCodeParentattrId AND Name = :tertiaryAttrName Limit 1].Id;
        String prodId = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c = :sku Limit 1].Id;
        System.debug(machine+'**'+type+'***'+drugCode+'**'+primaryAttrId+'**'+seconAttrId+'***'+tertiaryAttrId+'***'+prodId+'***'+majorcartItem.ccrz__Cart__r.ccrz__EffectiveAccountID__c);
        Decimal diffQty=0;
        
        List<Machine__c> machineTypeMap2 = [Select Id,Machine_Name__c,Machine_Type_Mapping__c,Agreement_sign_date__c,Recalibration_Allotment__c,
                                            Recalibrations_Purchased__c,New_Calibration_Allotment__c,Purchased__c
                                            From Machine__c Where Machine_Name__c =:machine AND Account_CSN__c =:majorcartItem.ccrz__Cart__r.ccrz__EffectiveAccountID__c];
        
        List<ccrz__E_CartItem__c> existingCartItem = [Select Id,ccrz__Price__c,ccrz__Quantity__c,Machines__c,ccrz__PrimaryAttr__c,ccrz__SecondaryAttr__c,ccrz__TertiaryAttr__c,
                                                      Machine_Type__c,ccrz__ExtSKU__c,ccrz__Product__c,ccrz__SelectedAttr__c,DrugCodes__c,ccrz__SubAmount__c,DrugCodes__r.DrugCodes__c 
                                                      From ccrz__E_CartItem__c Where ccrz__PrimaryAttr__c =:primaryAttrId AND
                                                      ccrz__SecondaryAttr__c =:seconAttrId AND ccrz__TertiaryAttr__c=:tertiaryAttrId AND ccrz__Product__c =:prodId AND
                                                      Machines__r.Machine_Name__c =:machine AND DrugCodes__r.DrugCodes__c =:drugCode AND Machine_Type__c =:type AND
                                                      ccrz__Cart__c =:majorcartItem.ccrz__Cart__c AND ccrz__ParentCartItem__c=:majorcartItem.Id];
        AggregateResult[] argPurchAlloc = [Select Machine_Name__c mch,Sum(Recalibrations_Purchased__c) prch From Machine__c Where 
                                           Account_CSN__c =:majorcartItem.ccrz__Cart__r.ccrz__EffectiveAccountID__c Group By Machine_Name__c];
        Map<String,Decimal> argPurchAllocMap = new Map<String,Decimal>();
        for(Integer i=0;i<argPurchAlloc.size();i++){
            String mc = (String)argPurchAlloc[i].get('mch');
            Decimal prc = (Decimal)argPurchAlloc[i].get('prch');
            argPurchAllocMap.put((String)argPurchAlloc[i].get('mch'),(Decimal)argPurchAlloc[i].get('prch'));
        }
        
        
        AggregateResult[] machineExtCartQtyMap = [Select Machines__c cmachine,Sum(ccrz__Quantity__c) cQty From ccrz__E_CartItem__c Where
                                                  ccrz__Cart__c =:majorcartItem.ccrz__Cart__c AND Machines__r.Machine_Name__c=:machine Group By Machines__c];
        Decimal cartExistingQty;
        if(machineExtCartQtyMap.size()>0){
            cartExistingQty = (Decimal)machineExtCartQtyMap[0].get('cQty');
        }
        else{
            cartExistingQty = 0;
        }
        try{
            if(existingCartItem.size()>0){
                System.debug('***'+existingCartItem.size());
                Decimal newQty = (Decimal)Integer.valueof(attributeDataMap.get('quantity'));
                if(sku == 'RECALIB'){
                    diffQty = ( argPurchAllocMap.get(machine)+cartExistingQty) - machineTypeMap2[0].Recalibration_Allotment__c;
                    System.debug('***'+diffQty);
                    System.debug('***'+existingCartItem.size());
                    if(existingCartItem.size()==1){
                        if(typeFlag == 'Canister'){
                            if(diffQty == 0){
                                createExtraItems(existingCartItem[0],majorcartItem,newQty);
                            }
                            if(diffQty<0){
                                if(newQty+diffQty <= 0){
                                    existingCartItem[0].ccrz__Quantity__c = existingCartItem[0].ccrz__Quantity__c + newQty;
                                    existingCartItem[0].ccrz__Price__c = 0;
                                    existingCartItem[0].ccrz__SubAmount__c = 0;
                                    update existingCartItem;
                                }
                                
                                if(newQty+diffQty >0){
                                    existingCartItem[0].ccrz__Quantity__c = existingCartItem[0].ccrz__Quantity__c + newQty;
                                    existingCartItem[0].ccrz__Price__c = 0;
                                    existingCartItem[0].ccrz__SubAmount__c = 0;
                                    update existingCartItem;
                                    createExtraItems(existingCartItem[0],majorcartItem,newQty+diffQty);
                                }
                            }
                            if(diffQty>0){
                                if(existingCartItem[0].ccrz__Price__c != 0){
                                    existingCartItem[0].ccrz__Quantity__c = existingCartItem[0].ccrz__Quantity__c + newQty;
                                    existingCartItem[0].ccrz__SubAmount__c = existingCartItem[0].ccrz__Price__c * existingCartItem[0].ccrz__Quantity__c;
                                    update existingCartItem;
                                }
                                else{
                                    createExtraItems(existingCartItem[0],majorcartItem,newQty);
                                }
                                
                            }
                        }
                        else{
                            Date startDate = Date.today();
                            Integer noOfDays = machineTypeMap2[0].Agreement_sign_date__c.daysBetween( startDate );
                            System.debug('***'+noOfDays);
                            existingCartItem[0].ccrz__Quantity__c = existingCartItem[0].ccrz__Quantity__c + Integer.valueof(attributeDataMap.get('quantity'));
                            if(noOfDays>90){
                                existingCartItem[0].ccrz__SubAmount__c = existingCartItem[0].ccrz__Quantity__c*existingCartItem[0].ccrz__Price__c;
                            }
                            else{
                                existingCartItem[0].ccrz__SubAmount__c =  0;
                            }
                            update existingCartItem;
                        }
                    }
                    else if(existingCartItem.size() == 2){
                        for(ccrz__E_CartItem__c crtitem : existingCartItem){
                            if(crtitem.ccrz__Price__c != 0  && crtitem.ccrz__SubAmount__c !=0){
                                crtitem.ccrz__Quantity__c = crtitem.ccrz__Quantity__c + newQty;
                                crtitem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice((String)attributeDataMap.get('currEffacc'),sku,crtitem);
                                crtitem.ccrz__SubAmount__c = crtitem.ccrz__Price__c*crtitem.ccrz__Quantity__c;
                                update crtitem;
                            }
                        }
                    }
                }
                else if(sku=='NEW-CALIB'){
                    diffQty = (machineTypeMap2[0].Purchased__c+cartExistingQty) - machineTypeMap2[0].New_Calibration_Allotment__c;
                    System.debug('***'+diffQty);
                    if(existingCartItem.size()==1){
                        if(diffQty == 0){
                            createExtraItems(existingCartItem[0],majorcartItem,newQty);
                        }
                        if(diffQty<0){
                            if(newQty+diffQty <= 0){
                                existingCartItem[0].ccrz__Quantity__c = existingCartItem[0].ccrz__Quantity__c + newQty;
                                existingCartItem[0].ccrz__Price__c = 0;
                                existingCartItem[0].ccrz__SubAmount__c = 0;
                                update existingCartItem;
                            }
                            
                            if(newQty+diffQty >0){
                                existingCartItem[0].ccrz__Quantity__c = existingCartItem[0].ccrz__Quantity__c + newQty;
                                existingCartItem[0].ccrz__Price__c = 0;
                                existingCartItem[0].ccrz__SubAmount__c = 0;
                                update existingCartItem;
                                createExtraItems(existingCartItem[0],majorcartItem,newQty+diffQty);
                            }
                        }
                        if(diffQty>0){
                            if(existingCartItem[0].ccrz__Price__c != 0){
                                existingCartItem[0].ccrz__Quantity__c = existingCartItem[0].ccrz__Quantity__c + newQty;
                                existingCartItem[0].ccrz__SubAmount__c = existingCartItem[0].ccrz__Price__c * existingCartItem[0].ccrz__Quantity__c;
                                update existingCartItem;
                            }
                            else{
                                createExtraItems(existingCartItem[0],majorcartItem,newQty);
                            }
                            
                        }
                    }
                    else if(existingCartItem.size() == 2){
                        for(ccrz__E_CartItem__c crtitem : existingCartItem){
                            if(crtitem.ccrz__Price__c != 0  && crtitem.ccrz__SubAmount__c !=0){
                                crtitem.ccrz__Quantity__c = crtitem.ccrz__Quantity__c + newQty;
                                crtitem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice((String)attributeDataMap.get('currEffacc'),sku,crtitem);
                                crtitem.ccrz__SubAmount__c = crtitem.ccrz__Price__c*crtitem.ccrz__Quantity__c;
                                update crtitem;
                            }
                        }
                    }
                }
                else if(sku=='REPAIR'){
                    //Add repair logic if needed 
                    existingCartItem[0].ccrz__Price__c = 0;
                    existingCartItem[0].ccrz__SubAmount__c = existingCartItem[0].ccrz__Quantity__c*existingCartItem[0].ccrz__Price__c;
                    existingCartItem[0].ccrz__OriginalQuantity__c = existingCartItem[0].ccrz__Quantity__c;
                    existingCartItem[0].ccrz__OriginalItemPrice__c = existingCartItem[0].ccrz__Price__c;
                    update existingCartItem;
                }
                
            }
            else{
                ccrz__E_CartItem__c newItem = new ccrz__E_CartItem__c(ccrz__Cart__c = majorcartItem.ccrz__Cart__c,ccrz__ParentCartItem__c=majorcartItem.Id,
                                                                      ccrz__cartItemType__c = 'Minor',ccrz__ProductType__c = 'Product',ccrz__UnitOfMeasure__c='EA',ccrz__StoreID__c='OmnicellB2BStore',
                                                                      ccrz__PricingType__c='auto');
                newItem.ccrz__ExtSKU__c = sku+'-';
                newItem.ccrz__RequestDate__c = System.today();
                
                newItem.ccrz__Product__c = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c = :sku Limit 1].Id;
                newItem.ccrz__PrimaryAttr__c =   primaryAttrId;
                newItem.ccrz__SecondaryAttr__c = seconAttrId;
                newItem.ccrz__TertiaryAttr__c =  tertiaryAttrId;
                newItem.ccrz__SelectedAttr__c = '{"'+primaryAttrId+'","'+seconAttrId+'","'+tertiaryAttrId+'"}';
                newItem.DrugCodes__c = ndc.Id;
                newItem.Machines__c = machineTypeMap2[0].Id;
                newItem.Machine_Type__c = type;
                newItem.ccrz__Quantity__c = Integer.valueof(attributeDataMap.get('quantity'));
                if(sku == 'RECALIB'){
                    System.debug(newItem.ccrz__Quantity__c+'***'+argPurchAllocMap.get(machine)+'***'+cartExistingQty);
                    diffQty = (newItem.ccrz__Quantity__c + argPurchAllocMap.get(machine) +cartExistingQty ) - machineTypeMap2[0].Recalibration_Allotment__c;
                    if(typeFlag == 'Canister'){
                        if(diffQty <= 0){
                            newItem.ccrz__Price__c = 0;
                            newItem.ccrz__SubAmount__c = 0;
                            newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                            newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                            insert newItem;
                        }
                        if(diffQty>0){
                            Decimal paidQty;
                            Decimal freeQty;
                            if(diffQty - newItem.ccrz__Quantity__c >=0){
                                paidQty = newItem.ccrz__Quantity__c;
                                newItem.ccrz__Quantity__c = paidQty;
                                newItem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice((String)attributeDataMap.get('currEffacc'),sku,newItem);
                                newItem.ccrz__SubAmount__c = newItem.ccrz__Price__c*newItem.ccrz__Quantity__c;
                                newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                                newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                                insert newItem;
                            }
                            if(diffQty - newItem.ccrz__Quantity__c < 0){
                                System.debug('***'+diffQty+'***'+newItem.ccrz__Quantity__c);
                                
                                freeQty = newItem.ccrz__Quantity__c - diffQty;
                                paidQty = newItem.ccrz__Quantity__c-freeQty;
                                newItem.ccrz__Quantity__c = freeQty;
                                newItem.ccrz__Price__c = 0;
                                newItem.ccrz__SubAmount__c = 0;
                                newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                                newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                                ccrz__E_CartItem__c paidItem = new ccrz__E_CartItem__c(ccrz__Cart__c = majorcartItem.ccrz__Cart__c,ccrz__ParentCartItem__c=majorcartItem.Id,
                                                                                       ccrz__cartItemType__c = 'Minor',ccrz__ProductType__c = 'Product',ccrz__UnitOfMeasure__c='EA',ccrz__StoreID__c='OmnicellB2BStore',
                                                                                       ccrz__PricingType__c='auto');
                                paidItem.ccrz__ExtSKU__c = sku+'-';
                                paidItem.ccrz__RequestDate__c = System.today();
                                
                                paidItem.ccrz__Product__c = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c = :sku Limit 1].Id;
                                paidItem.ccrz__PrimaryAttr__c =   primaryAttrId;
                                paidItem.ccrz__SecondaryAttr__c = seconAttrId;
                                paidItem.ccrz__TertiaryAttr__c =  tertiaryAttrId;
                                paidItem.ccrz__SelectedAttr__c = '{"'+primaryAttrId+'","'+seconAttrId+'","'+tertiaryAttrId+'"}';
                                paidItem.Machine_Type__c = type;
                                paidItem.ccrz__Quantity__c = paidQty;
                                paidItem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice((String)attributeDataMap.get('currEffacc'),sku,paidItem);
                                paidItem.ccrz__SubAmount__c = paidItem.ccrz__Price__c*paidItem.ccrz__Quantity__c;
                                paidItem.ccrz__OriginalQuantity__c = paidItem.ccrz__Quantity__c;
                                paidItem.ccrz__OriginalItemPrice__c = paidItem.ccrz__Price__c;
                                paidItem.DrugCodes__c = ndc.Id;
                                paidItem.Machines__c = machineTypeMap2[0].Id;
                                System.debug('***'+newItem.Id);
                                insert newItem;
                                System.debug('***'+paidItem.Id);
                                insert paidItem;
                            }
                        }
                    }
                    else{
                        Date startDate = Date.today();
                        Integer noOfDays = machineTypeMap2[0].Agreement_sign_date__c.daysBetween( startDate );
                        System.debug('***'+noOfDays);
                        if(noOfDays>90){
                            newItem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice((String)attributeDataMap.get('currEffacc'),sku,newItem);
                            newItem.ccrz__SubAmount__c = newItem.ccrz__Quantity__c*newItem.ccrz__Price__c;
                        }
                        else{
                            newItem.ccrz__Price__c = 0;
                            newItem.ccrz__SubAmount__c =  0;
                        } 
                        newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                        newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                        System.debug('***'+noOfDays);
                        insert newItem;
                    }
                    
                }
                else if(sku=='NEW-CALIB'){
                    diffQty = (newItem.ccrz__Quantity__c + machineTypeMap2[0].Purchased__c +cartExistingQty ) - machineTypeMap2[0].New_Calibration_Allotment__c;
                    System.debug(diffQty+'***'+newItem.ccrz__Quantity__c);
                    if(diffQty > 0){
                        Decimal paidQty;
                        Decimal freeQty;
                        freeQty = machineTypeMap2[0].New_Calibration_Allotment__c - (machineTypeMap2[0].Purchased__c +cartExistingQty);
                        if(freeQty>0){
                            if(newItem.ccrz__Quantity__c <= freeQty){
                                newItem.ccrz__Price__c = 0;
                                newItem.ccrz__SubAmount__c = 0;
                                newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                                newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                                insert newItem;
                            }
                            else{
                                paidQty = newItem.ccrz__Quantity__c - freeQty;
                                newItem.ccrz__Quantity__c = freeQty;
                                newItem.ccrz__Price__c = 0;
                                newItem.ccrz__SubAmount__c = 0;
                                newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                                newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                                insert newItem;
                                
                                ccrz__E_CartItem__c paidItem = new ccrz__E_CartItem__c(ccrz__Cart__c = majorcartItem.ccrz__Cart__c,ccrz__ParentCartItem__c=majorcartItem.Id,
                                                                                       ccrz__cartItemType__c = 'Minor',ccrz__ProductType__c = 'Product',ccrz__UnitOfMeasure__c='EA',ccrz__StoreID__c='OmnicellB2BStore',
                                                                                       ccrz__PricingType__c='auto');
                                paidItem.ccrz__ExtSKU__c = sku+'-';
                                paidItem.ccrz__RequestDate__c = System.today();
                                paidItem.ccrz__Product__c = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c = :sku Limit 1].Id;
                                paidItem.ccrz__PrimaryAttr__c =   primaryAttrId;
                                paidItem.ccrz__SecondaryAttr__c = seconAttrId;
                                paidItem.ccrz__TertiaryAttr__c =  tertiaryAttrId;
                                paidItem.ccrz__SelectedAttr__c = '{"'+primaryAttrId+'","'+seconAttrId+'","'+tertiaryAttrId+'"}';
                                paidItem.Machine_Type__c = type;
                                paidItem.DrugCodes__c = ndc.Id;
                                paidItem.Machines__c = machineTypeMap2[0].Id;
                                
                                
                                paidItem.ccrz__Quantity__c = paidQty;
                                paidItem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice((String)attributeDataMap.get('currEffacc'),sku,paidItem);
                                paidItem.ccrz__SubAmount__c = paidItem.ccrz__Price__c*paidItem.ccrz__Quantity__c;
                                paidItem.ccrz__OriginalQuantity__c = paidItem.ccrz__Quantity__c;
                                paidItem.ccrz__OriginalItemPrice__c = paidItem.ccrz__Price__c;
                                insert paidItem;
                                
                                System.debug('***'+newItem.Id);
                                System.debug('***'+paidItem.Id); 
                            }
                        }
                        else{
                            newItem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice((String)attributeDataMap.get('currEffacc'),sku,newItem);
                            newItem.ccrz__SubAmount__c = newItem.ccrz__Quantity__c*newItem.ccrz__Price__c;
                            newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                            newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                            insert newItem;
                        }
                    }
                    else{
                        newItem.ccrz__Price__c = 0;
                        newItem.ccrz__SubAmount__c = 0;
                        newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                        newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                        insert newItem;
                    }
                }
                else if(sku=='REPAIR'){
                    newItem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice((String)attributeDataMap.get('currEffacc'),sku,newItem);
                    newItem.ccrz__SubAmount__c = newItem.ccrz__Quantity__c*newItem.ccrz__Price__c;
                    newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                    newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                    insert newItem;
                }
            }
            return 'success';
        }    
        catch(Exception e){
            System.debug(e);
            return 'failed';
        }
        
        
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getCartCount(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        
        outputMap.put('cartCount',10);
        ccRemoteActionResult.success = true;
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static String getAttPrice(String currEffAcc, String sku){
        String accGroupId = [Select ccrz__E_AccountGroup__c From Account Where Id =:currEffAcc Limit 1].ccrz__E_AccountGroup__c;
        List<ccrz__E_AccountGroupPriceList__c> accGrpPriceListItems = [Select Id,ccrz__Pricelist__c,ccrz__Sequence__c From ccrz__E_AccountGroupPriceList__c 
                                                                       Where ccrz__AccountGroup__c =:accGroupId Order by ccrz__Sequence__c ASC];
        List<String> priceListIds = new List<String>();
        List<ccrz__E_PriceListItem__c> pricelistItems = new List<ccrz__E_PriceListItem__c>();
        for(ccrz__E_AccountGroupPriceList__c accGPI :accGrpPriceListItems){
            pricelistItems = [Select Id,ccrz__AttributePricing__c From ccrz__E_PriceListItem__c Where ccrz__Product__r.ccrz__SKU__c =:sku 
                              AND ccrz__Pricelist__c =:accGPI.ccrz__Pricelist__c AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY];
            if(pricelistItems.size()>0){
                break;
            }
        }
        
        if(pricelistItems.size() == 0)
            pricelistItems = [Select Id,ccrz__AttributePricing__c From ccrz__E_PriceListItem__c Where ccrz__Product__r.ccrz__SKU__c =:sku 
                              AND ccrz__Pricelist__r.ccrz__PricelistId__c = 'LIST PRICE' AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY];
        return pricelistItems[0].ccrz__AttributePricing__c;
    }
    public static String checkMachineStyle(String machine){
        String type='';
        if(machine == 'Pacmed'){
            type = 'Canister';
        }
        else if(machine == 'VBM'){
            type = 'VBM';
        }
        else if(machine == 'OD400'){
            type = 'RFID';
        }
        else{
            type = 'Cassette';
        }
        return type;
    }
    
    public static String createExtraItems(ccrz__E_CartItem__c existingCartItem,ccrz__E_CartItem__c majorcartItem,Decimal extraQty){ 
        String status = 'failed';
        List<ccrz__E_CartItem__c> existingCartItemcheck = [Select Id,ccrz__Price__c,ccrz__Quantity__c,ccrz__PrimaryAttr__c,ccrz__SecondaryAttr__c,ccrz__TertiaryAttr__c,
                                                           Machine_Type__c,Machines__c,
                                                           ccrz__ExtSKU__c,ccrz__Product__c,ccrz__SelectedAttr__c,DrugCodes__c,ccrz__SubAmount__c 
                                                           From ccrz__E_CartItem__c Where ccrz__PrimaryAttr__c =:existingCartItem.ccrz__PrimaryAttr__c AND
                                                           ccrz__SecondaryAttr__c =:existingCartItem.ccrz__SecondaryAttr__c AND ccrz__TertiaryAttr__c=:existingCartItem.ccrz__TertiaryAttr__c
                                                           AND ccrz__Product__c =:existingCartItem.ccrz__Product__c AND
                                                           Machines__c =:existingCartItem.Machines__c AND DrugCodes__r.DrugCodes__c =:existingCartItem.DrugCodes__r.DrugCodes__c
                                                           AND Machine_Type__c =:existingCartItem.Machine_Type__c AND
                                                           ccrz__Cart__c =:majorcartItem.ccrz__Cart__c AND ccrz__ParentCartItem__c=:majorcartItem.Id
                                                           AND ccrz__Price__c > 0 AND ccrz__SubAmount__c>0 Limit 1];
        
        String drcCode = existingCartItem.DrugCodes__r.DrugCodes__c;
        DrugCode__c drCode = [Select Id,Brand_Name__c,Generic_Drug_Name__c,Manufacturer_Name__c,Drug_Strength__c From DrugCode__c Where DrugCodes__c =:drcCode limit 1];
        
        if(existingCartItemcheck.size()>0){
            existingCartItemcheck[0].ccrz__Quantity__c = existingCartItemcheck[0].ccrz__Quantity__c+extraQty;
            existingCartItemcheck[0].ccrz__SubAmount__c = existingCartItemcheck[0].ccrz__Price__c * existingCartItemcheck[0].ccrz__Quantity__c;
            try{
                update existingCartItemcheck;
                status = 'success';
            }
            catch(Exception e){
                System.debug(e);
            }
            
        }
        else{
            
            ccrz__E_CartItem__c newItem = new ccrz__E_CartItem__c(ccrz__Cart__c = majorcartItem.ccrz__Cart__c,ccrz__ParentCartItem__c=majorcartItem.Id,
                                                                  ccrz__cartItemType__c = 'Minor',ccrz__ProductType__c = 'Product',ccrz__UnitOfMeasure__c='EA',ccrz__StoreID__c='OmnicellB2BStore',
                                                                  ccrz__PricingType__c='auto');
            newItem.ccrz__ExtSKU__c = existingCartItem.ccrz__ExtSKU__c;
            newItem.ccrz__RequestDate__c = System.today();
            
            newItem.ccrz__Product__c = existingCartItem.ccrz__Product__c;
            newItem.ccrz__PrimaryAttr__c =   existingCartItem.ccrz__PrimaryAttr__c;
            newItem.ccrz__SecondaryAttr__c = existingCartItem.ccrz__SecondaryAttr__c;
            newItem.ccrz__TertiaryAttr__c =  existingCartItem.ccrz__TertiaryAttr__c;
            newItem.ccrz__SelectedAttr__c = existingCartItem.ccrz__SelectedAttr__c;
            newItem.DrugCodes__c = existingCartItem.DrugCodes__c;
            newItem.Machines__c = existingCartItem.Machines__c;
            newItem.Machine_Type__c = existingCartItem.Machine_Type__c;
            newItem.ccrz__Quantity__c = extraQty;
            newItem.ccrz__Price__c = SCP_LogicCartPrice.getAttributePrice(majorcartItem.ccrz__Cart__r.ccrz__EffectiveAccountID__c,majorcartItem.ccrz__Product__r.ccrz__SKU__c ,newItem);
            newItem.ccrz__SubAmount__c = newItem.ccrz__Price__c * newItem.ccrz__Quantity__c;
            newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
            newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
            
            
            try{
                insert newItem;
                status = 'success';
            }
            catch(Exception e){
                System.debug(e);
            }
        }
        
        return status;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult insertDrug(ccrz.cc_RemoteActionContext ctx,String drugData){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        Map<String,object> drugDataMap = (Map<String, Object>)JSON.deserializeUntyped(drugData);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        String parentNDCId = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'].Id;
        Decimal sequence = [Select Id,ccrz__Sequence__c From ccrz__E_Attribute__c Where ccrz__ParentAttribute__c = :parentNDCId 
                            Order by ccrz__Sequence__c DESC limit 1].ccrz__Sequence__c;
        String ndcParentAttrId = [Select Id From ccrz__E_Attribute__c Where Id = :parentNDCId Limit 1].Id;
        ccrz__E_Attribute__c drugccAttr = new ccrz__E_Attribute__c();
        DrugCode__c newDrug = new DrugCode__c();
        newDrug.Drug_Type__c = 'UPC';
        newDrug.Generic_Drug_Name__c = (string)drugDataMap.get('name');
        newDrug.DrugCodes__c = (string)drugDataMap.get('number');
        newDrug.Manufacturer_Name__c = (string)drugDataMap.get('manufacturer');
        newDrug.Brand_Name__c = (string)drugDataMap.get('drugBrand');
        System.debug('***'+(string)drugDataMap.get('drugBrand'));
        newDrug.Dose_Unit__c = (string)drugDataMap.get('unit');
        System.debug('***'+(string)drugDataMap.get('width1'));
        if((string)drugDataMap.get('width1')!= null && (string)drugDataMap.get('width1')!= '')
            newDrug.Width1__c = decimal.valueOf((string)drugDataMap.get('width1'));
        
        if((string)drugDataMap.get('thickness1')!= null && (string)drugDataMap.get('thickness1')!= '')
            newDrug.Thickness1__c = decimal.valueOf((string)drugDataMap.get('thickness1'));
        
        if((string)drugDataMap.get('width2')!= null && (string)drugDataMap.get('width2')!= '')
            newDrug.Width2__c = decimal.valueOf((string)drugDataMap.get('width2'));
        
        if((string)drugDataMap.get('length')!= null && (string)drugDataMap.get('length')!= '')
            newDrug.Length__c = decimal.valueOf((string)drugDataMap.get('length'));
        
        if((string)drugDataMap.get('thickness2')!= null && (string)drugDataMap.get('thickness2')!= '')
            newDrug.Thickness1__c = decimal.valueOf((string)drugDataMap.get('thickness2'));
        
        newDrug.Drug_Strength__c = (string)drugDataMap.get('strength');//IBA-2932
        
        try{
            System.debug(Date.Today()+'***'+Date.Today().addDays(90));
            System.debug(newDrug);
            insert newDrug;
            
            outputMap.put('drugCodeGenName',drugDataMap.get('name'));
            outputMap.put('drugCode',drugDataMap.get('number'));
            outputMap.put('drugCodeBName',drugDataMap.get('drugBrand'));
            outputMap.put('drugCodeMName',drugDataMap.get('manufacturer'));
            outputMap.put('drugCodeStrength',drugDataMap.get('strength'));
            ccRemoteActionResult.success = true;
        }
        catch(Exception e){
            ccRemoteActionResult.success = false;
            System.debug(e);
        }
        
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult deleteCartItem(ccrz.cc_RemoteActionContext ctx,String prodattributeData){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        Map<String,object> attributeDataMap = (Map<String, Object>)JSON.deserializeUntyped(prodattributeData);
        System.debug('***'+attributeDataMap);
        String currCartEncryptedId = ccrz.cc_CallContext.currCartId;
        String accID = ccrz.cc_CallContext.effAccountId;
        attributeDataMap.put('currEffacc',accID);
        String currCartId = [Select Id From ccrz__E_Cart__c Where ccrz__EncryptedId__c = :currCartEncryptedId Limit 1].Id;
        String prodSKU = (String)attributeDataMap.get('SKU');
        List<ccrz__E_CartItem__c> majorcartItem = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,ccrz__Product__r.ccrz__SKU__c
                                                   From ccrz__E_CartItem__c Where ccrz__Cart__c =:currCartId AND ccrz__cartItemType__c = 'Major' 
                                                   AND ccrz__Product__r.ccrz__SKU__c = :prodSKU];
        if(majorcartItem.size() == 1){
            String machine = (String)attributeDataMap.get('machine');
            String type = (String)attributeDataMap.get('type');
            System.debug('***'+attributeDataMap.get('drugCode'));
            String drugCode = (String)attributeDataMap.get('drugCode');
            Integer qty;
            if(getType(attributeDataMap.get('quantity')) == 'Integer')
                qty = Integer.valueOf(attributeDataMap.get('quantity'));
            else
                qty = Integer.valueOf((String)attributeDataMap.get('quantity'));
            Decimal quantityDec = Decimal.valueOf(qty);
            String prodId = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c = :prodSKU Limit 1].Id;
            List<ccrz__E_CartItem__c> existingCartItem = [Select Id,ccrz__Price__c,ccrz__Quantity__c,Machines__c,ccrz__PrimaryAttr__c,ccrz__SecondaryAttr__c,
                                                          ccrz__TertiaryAttr__c,Machine_Type__c,ccrz__ExtSKU__c,ccrz__Product__c,ccrz__SelectedAttr__c,DrugCodes__c,
                                                          ccrz__SubAmount__c,ccrz__OriginalQuantity__c From ccrz__E_CartItem__c Where ccrz__Product__c =:prodId AND
                                                          Machines__r.Machine_Name__c =:machine AND DrugCodes__r.DrugCodes__c =:drugCode AND Machine_Type__c =:type AND
                                                          ccrz__Cart__c = :majorcartItem[0].ccrz__Cart__c AND ccrz__ParentCartItem__c = :majorcartItem[0].Id];
            
            System.debug('***'+existingCartItem.size());
            if(existingCartItem.size() == 1){
                if(existingCartItem[0].ccrz__Quantity__c + quantityDec > 0){
                    existingCartItem[0].ccrz__Quantity__c = existingCartItem[0].ccrz__Quantity__c + quantityDec;
                    existingCartItem[0].ccrz__SubAmount__c = existingCartItem[0].ccrz__Quantity__c * existingCartItem[0].ccrz__Price__c;
                    existingCartItem[0].ccrz__OriginalQuantity__c = existingCartItem[0].ccrz__Quantity__c;
                    try{
                        update existingCartItem;
                        if(existingCartItem[0].ccrz__SubAmount__c == 0)
                            ccRemoteActionResult.success = discountOtherItem(prodId,machine,type,drugCode,majorcartItem[0],qty);
                        else
                            ccRemoteActionResult.success = true;
                    }
                    catch(Exception e){
                        System.debug('***'+e);
                        ccRemoteActionResult.success = false;
                    }
                }
                else if(existingCartItem[0].ccrz__Quantity__c + quantityDec <= 0){
                    try{
                        delete existingCartItem;
                        ccRemoteActionResult.success = true;
                    }
                    catch(Exception e){
                        System.debug('***'+e);
                        ccRemoteActionResult.success = false;
                    }
                }
            }
            else if(existingCartItem.size() == 2){
                ccrz__E_CartItem__c freeItem = new ccrz__E_CartItem__c();
                if(existingCartItem[0].ccrz__SubAmount__c == 0){
                    freeItem = existingCartItem[0];
                }
                if(existingCartItem[1].ccrz__SubAmount__c == 0){
                    freeItem = existingCartItem[1];
                }
                if(existingCartItem[0].ccrz__Quantity__c + existingCartItem[1].ccrz__Quantity__c + quantityDec == 0){
                    delete existingCartItem;
                }
                else if(existingCartItem[0].ccrz__Quantity__c + existingCartItem[1].ccrz__Quantity__c + quantityDec < 0){
                    delete existingCartItem;
                    ccRemoteActionResult.success = discountOtherItem(prodId,machine,type,drugCode,majorcartItem[0],Integer.valueOf(existingCartItem[0].ccrz__Quantity__c+existingCartItem[1].ccrz__Quantity__c+quantityDec));
                }
                else{
                    for(ccrz__E_CartItem__c crt :existingCartItem){
                        if(crt.ccrz__SubAmount__c != 0){
                            if(crt.ccrz__Quantity__c + quantityDec > 0){
                                crt.ccrz__Quantity__c = crt.ccrz__Quantity__c + quantityDec;
                                crt.ccrz__SubAmount__c = crt.ccrz__Quantity__c * crt.ccrz__Price__c;
                                crt.ccrz__OriginalQuantity__c = crt.ccrz__Quantity__c;
                                try{
                                    update crt;
                                    ccRemoteActionResult.success = true;
                                }
                                catch(Exception e){
                                    System.debug('***'+e);
                                    ccRemoteActionResult.success = false;
                                }
                            }
                            else if(crt.ccrz__Quantity__c + quantityDec == 0){
                                try{
                                    delete crt;
                                    ccRemoteActionResult.success = true;
                                }
                                catch(Exception e){
                                    System.debug('***'+e);
                                    ccRemoteActionResult.success = false;
                                }
                            }
                            else if(crt.ccrz__Quantity__c + quantityDec < 0){
                                try{
                                    delete crt;
                                    freeItem.ccrz__Quantity__c = freeItem.ccrz__Quantity__c + crt.ccrz__Quantity__c + quantityDec;
                                    freeItem.ccrz__SubAmount__c = freeItem.ccrz__Quantity__c * freeItem.ccrz__Price__c;
                                    freeItem.ccrz__OriginalQuantity__c = freeItem.ccrz__Quantity__c;
                                    update freeItem;
                                    if(freeItem.ccrz__Quantity__c + crt.ccrz__Quantity__c + quantityDec >0){
                                        
                                    }
                                    System.debug('***'+(crt.ccrz__Quantity__c + quantityDec));
                                    
                                }
                                catch(Exception e){
                                    System.debug('***'+e);
                                    ccRemoteActionResult.success = false;
                                }
                            }
                        }
                    }
                }
                System.debug('***two Items');
            }
        }
        else if(majorcartItem.size() > 1){
            System.debug('***');
            ccRemoteActionResult.success = false;
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    global static Boolean discountOtherItem(String prodId,String machine,String type,String drugCode,ccrz__E_CartItem__c mjorCart,Integer extraQty){
        
        List<ccrz__E_CartItem__c> existingCartItem = [Select Id,ccrz__Price__c,ccrz__Quantity__c,Machines__c,ccrz__PrimaryAttr__c,ccrz__SecondaryAttr__c,
                                                      ccrz__TertiaryAttr__c,Machine_Type__c,ccrz__ExtSKU__c,ccrz__Product__c,ccrz__SelectedAttr__c,DrugCodes__c,
                                                      ccrz__SubAmount__c,ccrz__OriginalQuantity__c
                                                      From ccrz__E_CartItem__c Where ccrz__Product__c =:prodId AND
                                                      Machines__r.Machine_Name__c =:machine AND DrugCodes__r.DrugCodes__c != :drugCode AND ccrz__Price__c != 0 AND
                                                      ccrz__Cart__c = :mjorCart.ccrz__Cart__c AND ccrz__ParentCartItem__c = :mjorCart.Id 
                                                      Order By ccrz__SubAmount__c Desc];
        for(ccrz__E_CartItem__c ct :existingCartItem){
            System.debug('Test'+ct.ccrz__Quantity__c); 
            if(extraQty != 0){
                if(ct.ccrz__Quantity__c + extraQty == 0){
                    ct.ccrz__Price__c = 0;
                    ct.ccrz__SubAmount__c = ct.ccrz__Quantity__c * ct.ccrz__Price__c;
                    ct.ccrz__OriginalQuantity__c = ct.ccrz__Quantity__c;
                    try{
                        update ct;
                        extraQty = 0;
                        break;
                    }
                    catch(Exception e){
                        System.debug(e);
                        break;
                    }
                }
                else if(ct.ccrz__Quantity__c + extraQty < 0){
                    ct.ccrz__Price__c = 0;
                    ct.ccrz__SubAmount__c = ct.ccrz__Quantity__c * ct.ccrz__Price__c;
                    ct.ccrz__OriginalQuantity__c = ct.ccrz__Quantity__c;
                    try{
                        update ct;
                        extraQty = (Integer)ct.ccrz__Quantity__c + extraQty;
                        break;
                    }
                    catch(Exception e){
                        System.debug(e);
                        break;
                    }
                }
                else if(ct.ccrz__Quantity__c + extraQty > 0){
                    ct.ccrz__Quantity__c = ct.ccrz__Quantity__c + extraQty;
                    ct.ccrz__SubAmount__c = ct.ccrz__Quantity__c * ct.ccrz__Price__c;
                    ct.ccrz__OriginalQuantity__c = ct.ccrz__Quantity__c;
                    
                    ccrz__E_CartItem__c newItem = new ccrz__E_CartItem__c(ccrz__Cart__c = mjorCart.ccrz__Cart__c,ccrz__ParentCartItem__c=mjorCart.Id,
                                                                          ccrz__cartItemType__c = 'Minor',ccrz__ProductType__c = 'Product',ccrz__UnitOfMeasure__c='EA',ccrz__StoreID__c='OmnicellB2BStore',
                                                                          ccrz__PricingType__c='auto');
                    newItem.ccrz__ExtSKU__c = ct.ccrz__ExtSKU__c;
                    newItem.ccrz__RequestDate__c = System.today();
                    
                    newItem.ccrz__Product__c = ct.ccrz__Product__c;
                    newItem.ccrz__PrimaryAttr__c =   ct.ccrz__PrimaryAttr__c;
                    newItem.ccrz__SecondaryAttr__c = ct.ccrz__SecondaryAttr__c;
                    newItem.ccrz__TertiaryAttr__c =  ct.ccrz__TertiaryAttr__c;
                    newItem.ccrz__SelectedAttr__c = ct.ccrz__SelectedAttr__c;
                    newItem.DrugCodes__c = ct.DrugCodes__c;
                    newItem.Machines__c = ct.Machines__c ;
                    newItem.Machine_Type__c = ct.Machine_Type__c ;
                    newItem.ccrz__Quantity__c = extraQty*(-1);
                    newItem.ccrz__Price__c = 0;
                    newItem.ccrz__SubAmount__c = newItem.ccrz__Quantity__c * newItem.ccrz__Price__c;
                    newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                    newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                    try{
                        insert newItem;
                        extraQty = 0;
                    }
                    catch(Exception e){}
                    
                    
                }
            }
        }
        try{
            update existingCartItem;
        }
        catch(Exception e){
            System.debug('***');
        }
        return true;
    } 
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult bulkUpload(ccrz.cc_RemoteActionContext ctx,String bulkCartData){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();        
        List<Object> bulkCartDatalist = (List<Object>)JSON.deserializeUntyped(bulkCartData); //IBA-3841 - Sourav- Start
        List<Map<String,Object>> cartitemcsvList = new List<Map<String,Object>>();
        for(Object obj:bulkCartDatalist){
            Map<String,Object> objMap = (Map<String,Object>)obj;
            objMap.put('currEffacc',ccrz.cc_CallContext.effAccountId);            
            cartitemcsvList.add(objMap);
        }
        System.debug(cartitemcsvList);
        String currCartEncryptedId = ccrz.cc_CallContext.currCartId;
        String accID = ccrz.cc_CallContext.effAccountId;
        List<ccrz__E_Cart__c> currCart = [Select Id From ccrz__E_Cart__c Where ccrz__EncryptedId__c = :currCartEncryptedId Limit 1];
        if(currCart.size()>0){
            system.enqueueJob(new DrugCodeBulkUploadQueueable(cartitemcsvList,currCart[0].Id));
            outputMap.put('status','successful');
            ccRemoteActionResult.success = true;
        }
        else{
            outputMap.put('status','failed');
            ccRemoteActionResult.success = false;
        }//IBA-3841 - Sourav- End
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult reCheck(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        String currCartEncryptedId = ccrz.cc_CallContext.currCartId;
        ccrz__E_Cart__c cart = [Select Id,ccrz__EffectiveAccountID__c,Order_attempt__c,ccrz__ShipTo__c,ccrz__BillTo__c,SAP_Shipping_Customer_Number__c,
                                SAP_Billing_Customer_Number__c
                                From ccrz__E_Cart__c Where ccrz__EncryptedId__c =:currCartEncryptedId][0];//IBA-4266
        try{
            Boolean processBillToShipTo = false;//IBA-4266-Start
            if(cart.Order_attempt__c == false){
                processBillToShipTo = true;
            }                                   //IBA-4266-End
            ccRemoteActionResult.success = SCP_reCheckCanisterCassetteItemsPrice.reCheckBillability(cart,processBillToShipTo); //IBA-4266
        }
        catch(Exception e){
            System.debug(e);
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static string getType(Object o) {
        if(o==null) return '';              // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        if(o instanceof String)             return 'String';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }
    
    public static Boolean drugCheckInSystem(String drugCode){
        List<DrugCode__c> existingDrug = [Select Id,DrugCodes__c From DrugCode__c Where DrugCodes__c = :drugCode];
        if(existingDrug.size()>0){
            return true;
        }
        else{
            return false;
        }
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult bulkdrugCodeCheck(ccrz.cc_RemoteActionContext ctx,String bulkdrugData){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        Set<String> drugCodes = new Set<String>();
        Set<String> test = new Set<String>();
        List<Object> bulkDrugDataMap = (List<Object>)JSON.deserializeUntyped(bulkdrugData);
        for(Object obj:bulkDrugDataMap){
            drugCodes.add((String)obj);
        }
        List<DrugCode__c> systemDrug = [Select Id,DrugCodes__c From DrugCode__c Where DrugCodes__c IN :drugCodes];
        System.debug('***'+drugCodes.size());
        System.debug('***'+systemDrug.size());
        for(DrugCode__c dg:systemDrug){
            test.add(dg.DrugCodes__c);
        }
        for(String st:drugCodes){
            if(!test.contains(st)){
                System.debug('***'+st);
            }
        }
        if(drugCodes.size() == systemDrug.size()){
            outputMap.put('NDC_Check','All NDC are available');
        }
        else{
            outputMap.put('NDC_Check','All NDC are not available');
        }
        ccRemoteActionResult.success = true;
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public class wrapCartItems {
        public String sku{get; set;}
        public decimal qty{get; set;}
        public String descr{get; set;}
        public String prodT{get; set;}
        public String prodS{get; set;}
        public String uom{get; set;}
        public String oDate{get; set;}
        public String lstO{get; set;}
        public decimal m1{get; set;}
        public decimal m2{get; set;}
        public decimal m3{get; set;}
        public decimal m4{get; set;}
        public decimal m5{get; set;}
        public decimal m6{get; set;}
        public decimal uPrice{get; set;}
        public Map<String, Object> pricingTier{get; set;}
        public decimal subTamt{get; set;}
        
        public wrapCartItems(String a,decimal b,String c,String pt,String ps,String f,decimal up,Map<String, Object> tier,decimal subT, string od,string e,decimal g,decimal h,decimal i,decimal j,decimal k,decimal l) {
            sku  = a;
            qty = b;
            descr= c;
            prodT = pt;
            prodS = ps;
            
            uom= f;
            uPrice = up;
            pricingTier = tier;
            subTamt = subT;
            //order details
            oDate = od;
            lstO = e;
            m1= g;
            m2 = h;
            m3 = i;
            m4 = j;
            m5 = k;
            m6 = l;
            
        }
    }
    
    public class relatonshipWrap{//IBA-4129
        public String accountName;
        public String accountCSN;
        public String accountAddress;
        public String relationship;
        public Boolean defaultFlag;//IBA-4266
        public relatonshipWrap(String accountName, String accountCSN, String accountAddress, String relationship, Boolean defaultFlag){//IBA-4266
            this.accountName = accountName;
            this.accountCSN = accountCSN;
            this.accountAddress = accountAddress;
            this.relationship = relationship;
            this.defaultFlag = defaultFlag;
        }
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getProductList(ccrz.cc_RemoteActionContext ctx){
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        String cartId = ccrz.cc_CallContext.currCartId; 
        String effAccount = ccrz.cc_CallContext.effAccountId; 
        // remove for IBA-4469
        
        Account currAcc = [Select Name,BillingStreet,BillingCity,Transportation_Zone_Country__c,BillingPostalCode,BillingCountry,BillingState,
                           SAP_Customer_Number__c,BillingStateCode,PO_BOX__c,Address_Zip_code__c from Account Where Id =:effAccount];
        //IBA-4280 Start
        List<ccrz__E_Product__c> allActiveProducts= [Select ccrz__SKU__c From ccrz__E_Product__c Where ccrz__ProductStatus__c = 'Released' 
                                                     AND ccrz__ProductIndexStatus__c = 'Current'];
        Set<String> allActiveProductskus = new Set<String>();
        for(ccrz__E_Product__c pd:allActiveProducts){
            allActiveProductskus.add(pd.ccrz__SKU__c);
        }
        //IBA-4280 - End
        //IBA-4129 -Start
        List<Relationship__c> allrelationships =[Select Id,Relationship__c ,Secondary_Account__r.Name,Secondary_Account__r.SAP_Customer_Number__c,
                                                 Secondary_Account__r.Address_Zip_code__c,Default_Partner_Flag__c,Secondary_Account__c
                                                 from Relationship__c//IBA-4266 
                                                 where Primary_Account__c =:effAccount AND 
                                                 Primary_Account__r.IsDeleted__c = False 
                                                 AND Primary_Account__r.Validation_Status__c = 'Validated' 
                                                 AND Secondary_Account__r.IsDeleted__c = False AND 
                                                 Secondary_Account__r.Validation_Status__c = 'Validated'];
        List<relatonshipWrap> allRelationshipswrap = new List<relatonshipWrap>();
        List<relatonshipWrap> ccAddresswrap = new List<relatonshipWrap>();
        
        Map<String,String> secondRelTypeAccDefaultMap = new Map<String,String>();//IBA-4266        
        
        allRelationshipswrap.add(new relatonshipWrap(currAcc.Name,currAcc.SAP_Customer_Number__c,currAcc.Address_Zip_code__c,
                                                     'ALL',false));//IBA-4266
        for(Relationship__c rel:allrelationships){
            if(rel.Relationship__c == 'WE' || rel.Relationship__c == 'RE'){
                if(rel.Default_Partner_Flag__c == true){//IBA-4266
                    secondRelTypeAccDefaultMap.put(rel.Relationship__c,rel.Secondary_Account__c);
                }
                allRelationshipswrap.add(new relatonshipWrap(rel.Secondary_Account__r.Name,rel.Secondary_Account__r.SAP_Customer_Number__c,
                                                             rel.Secondary_Account__r.Address_Zip_code__c,rel.Relationship__c,rel.Default_Partner_Flag__c));//IBA-4266
            }
        } //IBA-4129 - End
        
        Map<Id,Account> defaultRelAccount = new Map<Id,Account>([Select Name,BillingStreet,BillingCity,Transportation_Zone_Country__c,
                                                                 BillingPostalCode,BillingCountry,BillingState,SAP_Customer_Number__c,
                                                                 BillingStateCode,PO_BOX__c,Address_Zip_code__c 
                                                                 from Account Where Id IN :secondRelTypeAccDefaultMap.values()]); //IIBA-4266
        try{
            ccrz__E_Cart__c cartObj= [select Id,ccrz__Contact__c, ccrz__TotalAmount__c,ccrz__Note__c,SAP_Shipping_Customer_Number__c,
                                      Order_attempt__c,ccrz__ShipTo__c,ccrz__ShipTo__r.SAP_Customer_Number__c,SAP_Billing_Customer_Number__c,ccrz__BillTo__c, 
                                      ccrz__BillTo__r.SAP_Customer_Number__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
            
            map<id,ccrz__E_Order__c> ordList = new map<id,ccrz__E_Order__c>([SELECT Id FROM ccrz__E_Order__c WHERE ccrz__Account__c =: effAccount 
                                                                             AND CreatedDate = LAST_N_MONTHS:12]);
            //IBA-4129 - Start
            Map<String,String> accAddrMap= new Map<String,String>();
            List<String> ccAddr = new List<String>();
            
            if(cartObj.SAP_Shipping_Customer_Number__c != null && cartObj.SAP_Shipping_Customer_Number__c != ''){
                ccAddr.add(cartObj.SAP_Shipping_Customer_Number__c);
            }
            if(cartObj.SAP_Billing_Customer_Number__c != null && cartObj.SAP_Billing_Customer_Number__c != ''){
                ccAddr.add(cartObj.SAP_Billing_Customer_Number__c);
            }
            
            List<Account> ccAddress = [Select Name,SAP_Customer_Number__c,Address_Zip_code__c From Account Where SAP_Customer_Number__c IN :ccAddr];
            
            for(Account ccAcc:ccAddress){ 
                if(ccAcc.SAP_Customer_Number__c ==  cartObj.SAP_Shipping_Customer_Number__c){
                    accAddrMap.put('shipTo',ccAcc.SAP_Customer_Number__c+','+ccAcc.Name+','+ccAcc.Address_Zip_code__c);
                }
                if(ccAcc.SAP_Customer_Number__c ==  cartObj.SAP_Billing_Customer_Number__c){
                    accAddrMap.put('billTo',ccAcc.SAP_Customer_Number__c+','+ccAcc.Name+','+ccAcc.Address_Zip_code__c);
                }                
            }
            if(cartObj.ccrz__BillTo__c == null || cartObj.ccrz__BillTo__r.SAP_Customer_Number__c == '' || cartObj.ccrz__BillTo__r.SAP_Customer_Number__c == null){
                System.debug('No Bill To...');
                if(secondRelTypeAccDefaultMap.get('RE') != null){//IBA-4266 - Start
                    Account billto = defaultRelAccount.get(secondRelTypeAccDefaultMap.get('RE'));
                    createRelationshiponCart(cartObj,billto,'billTo');
                    accAddrMap.put('billTo',billto.SAP_Customer_Number__c+','+billto.Name+','+billto.Address_Zip_code__c);
                }
                else{
                    createRelationshiponCart(cartObj,currAcc,'billTo');
                    accAddrMap.put('billTo',currAcc.SAP_Customer_Number__c+','+currAcc.Name+','+currAcc.Address_Zip_code__c);
                }                                               //IBA-4266 - End
            }
            if(cartObj.ccrz__ShipTo__c == null || cartObj.ccrz__ShipTo__r.SAP_Customer_Number__c == '' || cartObj.ccrz__ShipTo__r.SAP_Customer_Number__c == null){
                System.debug('No Ship To...');
                if(secondRelTypeAccDefaultMap.get('WE') != null){//IBA-4266 - Start
                    Account shipto = defaultRelAccount.get(secondRelTypeAccDefaultMap.get('WE'));
                    createRelationshiponCart(cartObj,shipto,'shipTo');
                    accAddrMap.put('shipTo',shipto.SAP_Customer_Number__c+','+shipto.Name+','+shipto.Address_Zip_code__c);
                }
                else{
                    createRelationshiponCart(cartObj,currAcc,'shipTo');
                    accAddrMap.put('shipTo',currAcc.SAP_Customer_Number__c+','+currAcc.Name+','+currAcc.Address_Zip_code__c);
                }                                                //IBA-4266 - End
            }
            //IBA-4129 - End
            id prdT = [select id from ccrz__E_Spec__c where ccrz__SpecID__c= 'PRODUCT_TYPE'].id;
            id prdS = [select id from ccrz__E_Spec__c where ccrz__SpecID__c= 'CUSTOM_STOCK'].id;                        
            
            //last order
            list<ccrz__E_OrderItem__c> itemL = [select Material__c, ccrz__Product_Name__c, ccrz__UnitOfMeasure__c,ccrz__Quantity__c,CreatedDate from ccrz__E_OrderItem__c
                                                where ccrz__Order__c =:ordList.keyset() and Material__c NOT IN ('NEW-CALIB', 'RECALIB', 'REPAIR') and ccrz__Product__r.ccrz__ProductStatus__c = 'Released' order by CreatedDate desc]; //IBA-4325
            map<string,ccrz__E_OrderItem__c> itemMap = new map<string,ccrz__E_OrderItem__c>();
            for(ccrz__E_OrderItem__c ordI:itemL){
                if(!itemMap.containskey(ordI.Material__c)){
                    itemMap.put(ordI.Material__c,ordI);                   
                }
                
            }
            
            //current cart
            list<ccrz__E_CartItem__c> citemL = [select Material__c, ccrz__Product__r.Name, ccrz__UnitOfMeasure__c,ccrz__Quantity__c,CreatedDate,ccrz__SubAmount__c,
                                                ccrz__Product__r.ccrz__ProductWeight__c from ccrz__E_CartItem__c
                                                where ccrz__Cart__c =:cartObj.id and Material__c NOT IN ('NEW-CALIB', 'RECALIB', 'REPAIR') and ccrz__Product__r.ccrz__ProductStatus__c = 'Released']; //IBA-4325
            map<string,ccrz__E_CartItem__c> citemMap = new map<string,ccrz__E_CartItem__c>();
            map<string,ccrz__E_CartItem__c> citemQMap = new map<string,ccrz__E_CartItem__c>();
            
            for(ccrz__E_CartItem__c crtI:citemL){
                // remove for IBA-4469
                if(itemMap.containskey(crtI.Material__c)){
                    citemQMap.put(crtI.Material__c,crtI);                   
                }else if(!citemMap.containskey(crtI.Material__c)){
                    citemMap.put(crtI.Material__c,crtI);                   
                }                
            }
            
            list<ccrz__E_OrderItem__c> itemLC = [select Material__c, ccrz__Product_Name__c, ccrz__UnitOfMeasure__c,ccrz__Quantity__c,CreatedDate from ccrz__E_OrderItem__c
                                                 where Material__c =:citemMap.keyset() and Material__c NOT IN ('NEW-CALIB', 'RECALIB', 'REPAIR') and ccrz__Product__r.ccrz__ProductStatus__c = 'Released' order by CreatedDate desc]; //IBA-4325
            map<string,ccrz__E_OrderItem__c> itemMapC = new map<string,ccrz__E_OrderItem__c>();
            for(ccrz__E_OrderItem__c ordI:itemLC){
                if(!itemMapC.containskey(ordI.Material__c)){
                    itemMapC.put(ordI.Material__c,ordI);                   
                }
                
            }
            
            //get price list
            account a = [select ccrz__E_AccountGroup__c from account where id=:effAccount limit 1];
            list<ccrz__E_AccountGroupPriceList__c> aGrPL = new list<ccrz__E_AccountGroupPriceList__c>();
            map<string,map<string,ccrz__E_PriceListItem__c>> pliMap = new map<string,map<string,ccrz__E_PriceListItem__c>>();
            list<string> iList = new list<string>();
            iList.addall(itemMap.keyset());
            iList.addall(citemMap.keyset());
            
            if(a.ccrz__E_AccountGroup__c != null){
                aGrPL = [SELECT ccrz__Pricelist__c,ccrz__Sequence__c FROM ccrz__E_AccountGroupPriceList__c 
                         WHERE ccrz__AccountGroup__c =: a.ccrz__E_AccountGroup__c order by ccrz__Sequence__c asc];
                
                Date dt = Date.today();
                
                list<ccrz__E_PriceListItem__c> pricL = [SELECT ccrz__AttributePricing__c,ccrz__EndDate__c,ccrz__MaxQty__c,ccrz__MinQty__c,ccrz__PricelistItemId__c,
                                                        ccrz__Pricelist__c,ccrz__Price__c,ccrz__PricingTiers__c,ccrz__Product__r.ccrz__SKU__c,ccrz__RecurringPrice__c,
                                                        ccrz__StartDate__c,ccrz__UnitOfMeasure__c,Id,Name,ccrz__ItemType__c FROM ccrz__E_PriceListItem__c 
                                                        where ccrz__Product__r.ccrz__SKU__c =:iList and ccrz__StartDate__c <=: dt and ccrz__EndDate__c >=: dt];
                
                
                for(ccrz__E_PriceListItem__c pli:pricL){
                    if(!pliMap.containskey(pli.ccrz__Product__r.ccrz__SKU__c)){
                        map<string,ccrz__E_PriceListItem__c> p = new map<string,ccrz__E_PriceListItem__c>();
                        p.put(pli.ccrz__Pricelist__c,pli);
                        pliMap.put(pli.ccrz__Product__r.ccrz__SKU__c,p);
                    }else{
                        map<string,ccrz__E_PriceListItem__c> p = pliMap.get(pli.ccrz__Product__r.ccrz__SKU__c);
                        p.put(pli.ccrz__Pricelist__c,pli);
                        pliMap.put(pli.ccrz__Product__r.ccrz__SKU__c,p);
                    }
                    
                }                
                
            }
            
            
            // last 12 month order
            
            AggregateResult[] agrOrderMont = [select ccrz__Product__r.ccrz__SKU__c sku, sum(ccrz__Quantity__c) tOrder,calendar_month(CreatedDate) mont 
                                              from ccrz__E_OrderItem__c where ccrz__Order__c =:ordList.keyset() and ccrz__Product__r.ccrz__SKU__c NOT IN ('NEW-CALIB', 'RECALIB', 'REPAIR') and ccrz__Product__r.ccrz__ProductStatus__c = 'Released' group by ccrz__Product__r.ccrz__SKU__c, 
                                              calendar_month(CreatedDate)  ]; //IBA-4325
            list<string> skuL = new list<string>();
            map<string,map<integer,decimal>> skuVSmonthVSqty = new map<string,map<integer,decimal>>();
            
            for(AggregateResult agg:agrOrderMont){
                string sku = (String)agg.get('sku');
                
                if(!skuVSmonthVSqty.containskey(sku)){
                    skuL.add(sku);
                    map<integer,decimal> monthVSqty = new map<integer,decimal>();
                    monthVSqty.put((integer)agg.get('mont'),(decimal)agg.get('tOrder'));
                    skuVSmonthVSqty.put(sku,monthVSqty);
                }else{
                    map<integer,decimal> monthVSqty = skuVSmonthVSqty.get(sku);
                    monthVSqty.put((integer)agg.get('mont'),(decimal)agg.get('tOrder'));
                    skuVSmonthVSqty.put(sku,monthVSqty);
                }
            }
            
            //order sort
            AggregateResult[] agrOrderTotal = [select ccrz__Product__r.ccrz__SKU__c sku, sum(ccrz__Quantity__c) tOrder 
                                               from ccrz__E_OrderItem__c where ccrz__Order__c =:ordList.keyset() and ccrz__Product__r.ccrz__SKU__c NOT IN ('NEW-CALIB', 'RECALIB', 'REPAIR') 
                                               and ccrz__Product__r.ccrz__ProductStatus__c = 'Released' group by ccrz__Product__r.ccrz__SKU__c ORDER BY SUM(ccrz__Quantity__c) desc]; //IBA-4325
            list<string> prodlistSorted = new list<string>();
            for(AggregateResult agg:agrOrderTotal){
                prodlistSorted.add((String)agg.get('sku'));
            }
            
            list<ccrz__E_Product__c> ProdDet = [select ccrz__SKU__c, Name, ccrz__UnitOfMeasure__c from ccrz__E_Product__c where ccrz__SKU__c =:prodlistSorted];
            map<string,ccrz__E_Product__c> ProdDetMap = new map<string,ccrz__E_Product__c>();
            for(ccrz__E_Product__c p:ProdDet){
                ProdDetMap.put(p.ccrz__SKU__c,p);
            }
            
            list<id> spec = new list<string>{prdT, prdS};
                list<ccrz__E_ProductSpec__c> pSpecL = [select ccrz__SpecValue__c,ccrz__Product__r.ccrz__SKU__c,ccrz__Spec__c from ccrz__E_ProductSpec__c where ccrz__Spec__c =: spec and ccrz__Product__r.ccrz__SKU__c =: iList];
            
            list<ccrz__E_Product__c> ProdDetC = [select ccrz__SKU__c, Name, ccrz__UnitOfMeasure__c from ccrz__E_Product__c where ccrz__SKU__c =:citemMap.keyset()];
            
            map<string,string> prodSpecMapPT = new map<string,string>();
            map<string,string> prodSpecMapST = new map<string,string>();
            for(ccrz__E_ProductSpec__c ps:pSpecL){
                if(ps.ccrz__Spec__c == prdT)
                    prodSpecMapPT.put(ps.ccrz__Product__r.ccrz__SKU__c,ps.ccrz__SpecValue__c);
                
                if(ps.ccrz__Spec__c == prdS)
                    prodSpecMapST.put(ps.ccrz__Product__r.ccrz__SKU__c,ps.ccrz__SpecValue__c);
            }
            
            List<wrapCartItems> itemsList = new List<wrapCartItems> ();
            Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'Jan',2 => 'Feb',3 => 'Mar',4 => 'Apr',5 => 'May',6 => 'Jun',7 => 'Jul',8 => 'Aug',9 => 'Sep',10 => 'Oct',11 => 'Nov',12 => 'Dec'};
                integer cm =Date.Today().month();
            integer yr1 = Date.Today().year();
            integer yr2=yr1-1;
            String cy1 = String.valueOf(yr1.format()).right(2);
            String cy2 = String.valueOf(yr2.format()).right(2);
            
            list<string> monthName =  new list<string> ();  
            boolean Mcal = true;
            
            //from order hist
            for(string pr:prodlistSorted){
                
                ccrz__E_Product__c p = ProdDetMap.get(pr);
                map<integer,decimal> monthVSqty = new map<integer,decimal>();
                monthVSqty = skuVSmonthVSqty.get(p.ccrz__SKU__c);
                integer m=0;
                
                decimal [] arrayOfProductsQ = new List<decimal>();
                
                for(integer i=cm-6;i<=cm-1;i++){
                    decimal curSkuQ=0;
                    if(i<=0){
                        m=i+12;                        
                        if(monthVSqty.containskey(m)){
                            curSkuQ=monthVSqty.get(m);
                        }                        
                        
                    }else{
                        m=i;
                        if(monthVSqty.containskey(m)){
                            curSkuQ=monthVSqty.get(m);
                        } 
                        
                    }
                    arrayOfProductsQ.add(curSkuQ);
                    
                }
                
                decimal price = 0;
                Map<String, Object> getTier = new Map<String, Object>();
                ccrz__E_PriceListItem__c pp = new ccrz__E_PriceListItem__c();
                if(aGrPL.size()>0){
                    
                    for(ccrz__E_AccountGroupPriceList__c ag:aGrPL){
                        if(pliMap.containskey(p.ccrz__SKU__c)){
                            map<string,ccrz__E_PriceListItem__c> pmap = pliMap.get(p.ccrz__SKU__c);
                            if(pmap.containskey(ag.ccrz__Pricelist__c)){
                                pp =pmap.get(ag.ccrz__Pricelist__c);
                                price = pp.ccrz__Price__c;
                                if(pp.ccrz__ItemType__c == 'tiered'){
                                    getTier =(Map<String, Object>) JSON.deserializeUntyped(pp.ccrz__PricingTiers__c);
                                    
                                }else{
                                    getTier = null;
                                }
                                break;
                            }
                        }
                    }
                }
                
                
                ccrz__E_OrderItem__c lstOrd = itemMap.get(p.ccrz__SKU__c);
                DateTime dt = lstOrd.CreatedDate ;
                string oDate = dt.format('dd-MMM-yy');
                string oldOrd = String.valueOf(lstOrd.ccrz__Quantity__c) +' - '+ lstOrd.ccrz__UnitOfMeasure__c;
                
                decimal qty = 0;
                decimal subT = 0;
                if(citemQMap.containskey(p.ccrz__SKU__c)){
                    ccrz__E_CartItem__c ci = citemQMap.get(p.ccrz__SKU__c);
                    qty = ci.ccrz__Quantity__c;
                    subT = ci.ccrz__SubAmount__c;
                    if(getTier != null){
                        price = getPrice(Integer.valueof(qty),pp);
                    }
                }
                
                itemsList.add(new wrapCartItems(String.valueof(p.ccrz__SKU__c),qty,String.valueof(p.Name),prodSpecMapPT.get(p.ccrz__SKU__c),prodSpecMapST.get(p.ccrz__SKU__c),
                                                String.valueof(p.ccrz__UnitOfMeasure__c),price,getTier,subT, oDate,oldOrd,arrayOfProductsQ[0],arrayOfProductsQ[1],arrayOfProductsQ[2],arrayOfProductsQ[3],
                                                arrayOfProductsQ[4],arrayOfProductsQ[5]));
                
            }
            
            //from cart
            for(ccrz__E_Product__c p:ProdDetC){
                
                
                integer i=0;
                integer m=0;
                
                decimal [] arrayOfProductsQ = new List<decimal>();
                for(i=cm-6;i<=cm-1;i++){                    
                    arrayOfProductsQ.add(0);                    
                }
                
                decimal price = 0;
                Map<String, Object> getTier = new Map<String, Object>();
                ccrz__E_PriceListItem__c pp = new ccrz__E_PriceListItem__c();
                if(aGrPL.size()>0){
                    
                    for(ccrz__E_AccountGroupPriceList__c ag:aGrPL){
                        if(pliMap.containskey(p.ccrz__SKU__c)){
                            map<string,ccrz__E_PriceListItem__c> pmap = pliMap.get(p.ccrz__SKU__c);
                            if(pmap.containskey(ag.ccrz__Pricelist__c)){
                                pp =pmap.get(ag.ccrz__Pricelist__c);
                                price = pp.ccrz__Price__c;
                                if(pp.ccrz__ItemType__c == 'tiered'){
                                    getTier =(Map<String, Object>) JSON.deserializeUntyped(pp.ccrz__PricingTiers__c);
                                    
                                }else{
                                    getTier = null;
                                }
                                break;
                            }
                        }
                    }
                }
                string oDate = '';
                string oldOrd = '';
                if(itemMapC.containskey(p.ccrz__SKU__c)){
                    ccrz__E_OrderItem__c lstOrd = itemMapC.get(p.ccrz__SKU__c);
                    DateTime dt = lstOrd.CreatedDate ;
                    oDate = dt.format('dd-MMM-yy');
                    oldOrd = String.valueOf(lstOrd.ccrz__Quantity__c) +' - '+ lstOrd.ccrz__UnitOfMeasure__c;
                    
                }
                
                decimal qty = 0;
                decimal subT = 0;
                if(citemMap.containskey(p.ccrz__SKU__c)){
                    ccrz__E_CartItem__c ci = citemMap.get(p.ccrz__SKU__c);
                    qty = ci.ccrz__Quantity__c;
                    subT = ci.ccrz__SubAmount__c;
                    if(getTier != null){
                        price = getPrice(Integer.valueof(qty),pp);
                    }
                }
                
                itemsList.add(new wrapCartItems(String.valueof(p.ccrz__SKU__c),qty,String.valueof(p.Name),prodSpecMapPT.get(p.ccrz__SKU__c),prodSpecMapST.get(p.ccrz__SKU__c),
                                                String.valueof(p.ccrz__UnitOfMeasure__c),price,getTier,subT,oDate, oldOrd,arrayOfProductsQ[0],arrayOfProductsQ[1],arrayOfProductsQ[2],arrayOfProductsQ[3],
                                                arrayOfProductsQ[4],arrayOfProductsQ[5]));
                
            }
            
            integer i = 0;
            integer m=0;
            for(i=cm-6;i<=cm-1;i++){
                if(i<=0){
                    m=i+12;                        
                    
                    if(monthMap.containskey(m)){
                        monthName.add(monthMap.get(m)+'-'+cy2);
                    }
                    
                }else{
                    m=i;
                    
                    if(monthMap.containskey(m)){
                        monthName.add(monthMap.get(m)+'-'+cy1);
                    }
                }                    
                
            }
            
            //IBA-4281-Start
            couponMessageWrap coupMessage = reCheckCartcouponValidityCheck(cartId);
            outputMap.put('couponValidityCheck',coupMessage.validity);
            outputMap.put('couponmessage',coupMessage.message);
            outputMap.put('coupon',coupMessage.coupon);
            //IBA-4281-End
            ccRemoteActionResult.success = true;
            outputMap.put('allRelationships',allRelationshipswrap);//IBA-4129
            outputMap.put('monthName',monthName);
            System.debug(itemsList.size());
            outputMap.put('itemsList',itemsList);
            outputMap.put('cartNote',cartObj.ccrz__Note__c);
            outputMap.put('allActiveProductskus',allActiveProductskus);//IBA-4280
            // remove for IBA-4469
            outputMap.put('allCCAddressMap',accAddrMap);//IBA-4129
        }
        catch(Exception e) {
            system.debug('e '+e.getMessage() +' '+e.getlinenumber());
            //outputMap.put('message',e);
            //ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        return ccRemoteActionResult ;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getProductDetails(ccrz.cc_RemoteActionContext ctx,String sku){ // IBA-4131 get the prodict details from the homepage
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        list<ccrz__E_Product__c> ProdDet = [select ccrz__SKU__c, Name, ccrz__UnitOfMeasure__c from ccrz__E_Product__c where ccrz__SKU__c =:sku AND ccrz__ProductStatus__c = 'Released'];
        if(ProdDet.size()>0){
            outputMap.put('prodExist','Yes');
            outputMap.put('prodUom',ProdDet[0].ccrz__UnitOfMeasure__c);
            outputMap.put('prodDesc',ProdDet[0].Name);
            id prdT = [select id from ccrz__E_Spec__c where ccrz__SpecID__c= 'PRODUCT_TYPE'].id;
            id prdS = [select id from ccrz__E_Spec__c where ccrz__SpecID__c= 'CUSTOM_STOCK'].id;
            list<id> spec = new list<string>{prdT, prdS};
                list<ccrz__E_ProductSpec__c> pSpecL = [select ccrz__SpecValue__c,ccrz__Product__r.ccrz__SKU__c,ccrz__Spec__c from ccrz__E_ProductSpec__c where ccrz__Spec__c =: spec and ccrz__Product__r.ccrz__SKU__c =: sku];
            
            for(ccrz__E_ProductSpec__c ps:pSpecL){
                if(ps.ccrz__Spec__c == prdT){
                    outputMap.put('itemtype',ps.ccrz__SpecValue__c); 
                }
                if(ps.ccrz__Spec__c == prdS){
                    outputMap.put('stocktype',ps.ccrz__SpecValue__c); 
                }
            }
            String accID = ccrz.cc_CallContext.effAccountId;
            ccrz__E_PriceListItem__c priceListItem = getProductPrice(accID,sku);
            Map<String, Object> priceTier = new Map<String, Object>();
            if(priceListItem.ccrz__ItemType__c == 'tiered'){
                priceTier = (Map<String, Object>) JSON.deserializeUntyped(priceListItem.ccrz__PricingTiers__c);
            }
            
            outputMap.put('prodPrice',priceListItem.ccrz__Price__c);
            outputMap.put('prodPriceType',priceListItem.ccrz__ItemType__c);
            outputMap.put('prodPriceTier',priceTier);
            outputMap.put('prodExist','Yes');
        }
        else{
            outputMap.put('prodExist','No');
        }
        
        ccRemoteActionResult.success = true;
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static ccrz__E_PriceListItem__c getProductPrice(String currEffAcc, String sku){//IBA-4130-4131 //get the correct pricelist item
        
        Decimal price;
        ccrz__E_PriceListItem__c priceListItem = new ccrz__E_PriceListItem__c();//IBA-4572
        Set<String> agPriceList = new Set<String>();
        Set<String> prodPriceListItem = new Set<String>();
        Map<String,ccrz__E_PriceListItem__c>  priceListItemPriceMap = new Map<String,ccrz__E_PriceListItem__c>();
        String matchPriceListId = '';
        String accGroupId = [Select ccrz__E_AccountGroup__c From Account Where Id =:currEffAcc Limit 1].ccrz__E_AccountGroup__c;
        List<ccrz__E_AccountGroupPriceList__c> accGrpPriceListItems = [Select Id,ccrz__Pricelist__c,ccrz__Sequence__c From ccrz__E_AccountGroupPriceList__c 
                                                                       Where ccrz__AccountGroup__c =:accGroupId AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY
                                                                       Order by ccrz__Sequence__c ASC];
        for(ccrz__E_AccountGroupPriceList__c ag:accGrpPriceListItems){
            agPriceList.add(ag.ccrz__Pricelist__c);
        }
        
        List<ccrz__E_PriceListItem__c> pricelistItems = [Select Id,ccrz__Pricelist__c,ccrz__Price__c,ccrz__ItemType__c,ccrz__PricingTiers__c From ccrz__E_PriceListItem__c Where ccrz__Product__r.ccrz__SKU__c =:sku 
                                                         AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY];
        for(ccrz__E_PriceListItem__c pI:pricelistItems){
            //prodPriceListItem.add(pI.ccrz__Pricelist__c);//IBA-4572
            priceListItemPriceMap.put(pI.ccrz__Pricelist__c,pI);
        }
        for(String st:agPriceList){
            //Boolean result = prodPriceListItem.contains('st');IBA-4572
            if(priceListItemPriceMap.containskey(st)){//IBA-4572
                priceListItem = priceListItemPriceMap.get(st);
                break;
            }
        }
        return priceListItem;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult homeUpserCarttItem(ccrz.cc_RemoteActionContext ctx,String prodDetails){//IBA-4130
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        Map<String,object> prodDataMap = (Map<String, Object>)JSON.deserializeUntyped(prodDetails);
        System.debug('ProdMap'+prodDataMap);
        String accID = ccrz.cc_CallContext.effAccountId;
        String currCartEncryptedId = ccrz.cc_CallContext.currCartId;
        //iba-4409
        ccrz__E_Cart__c cartObj= [select Id, ccrz__TotalAmount__c,ccrz__Note__c,ccrz__ValidationStatus__c, BetaPage__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :currCartEncryptedId  LIMIT 1];
        if(cartObj.BetaPage__c != true){
            cartObj.BetaPage__c = true;
            update cartObj;
        }
        String prodSKU = (String)prodDataMap.get('SKU');
        String prodQty = (String)prodDataMap.get('Qty');
        ccrz__E_Product__c curProd = [Select Id,ccrz__UnitOfMeasure__c,Minimum_Quantity__c From ccrz__E_Product__c Where ccrz__SKU__c = :prodSKU Limit 1];
        if(Integer.valueof(prodQty) >= curProd.Minimum_Quantity__c){
            List<ccrz__E_CartItem__c>  existingItem = [Select Id,ccrz__Quantity__c,ccrz__Price__c,ccrz__SubAmount__c,ccrz__OriginalQuantity__c,ccrz__Coupon__c,ccrz__Product__c
                                                       From ccrz__E_CartItem__c Where
                                                       ccrz__Product__c =:curProd.Id AND ccrz__cartItemType__c = 'Major' AND ccrz__Cart__r.ccrz__EncryptedId__c =:currCartEncryptedId Limit 1];
            ccrz__E_PriceListItem__c priceListItem = getProductPrice(accID,prodSKU);
            decimal subamount = 0;
            decimal pAmount = 0;
            try{
                if(existingItem.size()>0){
                    existingItem[0].ccrz__Price__c = getPrice(Integer.valueof(prodQty),priceListItem);
                    existingItem[0].ccrz__Quantity__c = Integer.valueof(prodQty);   
                    if(existingItem[0].ccrz__Coupon__c != null){
                        List<ccrz__E_Coupon__c>  currCoupon = [Select Id,ccrz__CouponName__c,ccrz__MaxUse__c,ccrz__MinQty__c, 
                                                               ccrz__Storefront__c,ccrz__TargetProduct__c,ccrz__TargetQty__c,ccrz__TotalUsed__c,ccrz__CouponCode__c From ccrz__E_Coupon__c 
                                                               Where id = :existingItem[0].ccrz__Coupon__c AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY AND 
                                                               ccrz__Enabled__c = True AND ccrz__Storefront__c = 'OmnicellB2BStore']; 
                        Boolean validityCheck = couponValidityCheck(currCoupon[0],existingItem[0]);
                        if(validityCheck){
                            existingItem[0].ccrz__SubAmount__c = 0;
                        }
                        else{
                            existingItem[0].ccrz__SubAmount__c = Integer.valueof(prodQty)*existingItem[0].ccrz__Price__c;
                        }
                    }
                    else{
                        existingItem[0].ccrz__SubAmount__c = Integer.valueof(prodQty)*existingItem[0].ccrz__Price__c;
                    }                    
                    pAmount = existingItem[0].ccrz__Price__c;                 
                    subamount = existingItem[0].ccrz__SubAmount__c;
                    existingItem[0].ccrz__OriginalQuantity__c = Integer.valueof(prodQty);
                    update existingItem;
                }
                else{
                    ccrz__E_CartItem__c newItem = new ccrz__E_CartItem__c(ccrz__cartItemType__c = 'Major',ccrz__ProductType__c = 'Product',ccrz__StoreID__c='OmnicellB2BStore',
                                                                          ccrz__PricingType__c='auto');
                    newItem.ccrz__Cart__c = [Select Id From ccrz__E_Cart__c Where ccrz__EncryptedId__c = :currCartEncryptedId Limit 1].Id;
                    newItem.ccrz__ExtSKU__c = prodSKU+'-';
                    newItem.ccrz__UnitOfMeasure__c = curProd.ccrz__UnitOfMeasure__c;
                    newItem.ccrz__RequestDate__c = System.today();
                    newItem.ccrz__Product__c = curProd.Id;
                    newItem.ccrz__Quantity__c = Integer.valueof(prodQty);
                    newItem.ccrz__Price__c = getPrice(Integer.valueof(prodQty),priceListItem);
                    pAmount = newItem.ccrz__Price__c;
                    newItem.ccrz__SubAmount__c = newItem.ccrz__Price__c*newItem.ccrz__Quantity__c;
                    subamount = newItem.ccrz__SubAmount__c;
                    newItem.ccrz__OriginalQuantity__c = newItem.ccrz__Quantity__c;
                    newItem.ccrz__OriginalItemPrice__c = newItem.ccrz__Price__c;
                    insert newItem;
                }
                ccrz__E_Cart__c updatedcartObj= [select Id,ccrz__Contact__c, ccrz__TotalAmount__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :currCartEncryptedId  LIMIT 1];
                System.debug('****'+updatedcartObj.ccrz__TotalAmount__c);
                outputMap.put('Total',updatedcartObj.ccrz__TotalAmount__c);
                outputMap.put('message','upsert successfull');
                outputMap.put('subAmount',subamount);
                if(priceListItem.ccrz__ItemType__c != 'tiered'){
                    pAmount = 0;
                }
                outputMap.put('pAmount',pAmount);
                ccRemoteActionResult.success = true;
            }
            catch(Exception e){
                System.debug('exception'+e);
                outputMap.put('message',e);
                ccRemoteActionResult.success = false;
            } 
        }
        else{
            outputMap.put('message','Quantity should be at least '+curProd.Minimum_Quantity__c);
            ccRemoteActionResult.success = false;
        }
        // remove for IBA-4469
        //IBA-4281-Start
        couponMessageWrap coupMessage = reCheckCartcouponValidityCheck(currCartEncryptedId);
        outputMap.put('couponValidityCheck',coupMessage.validity);
        outputMap.put('couponmessage',coupMessage.message);
        outputMap.put('coupon',coupMessage.coupon);
        //IBA-4281-End
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult homeDeleteCarttItem(ccrz.cc_RemoteActionContext ctx,String prodDetails){//IBA-4130
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        Map<String,object> prodDataMap = (Map<String, Object>)JSON.deserializeUntyped(prodDetails);
        System.debug('ProdMap'+prodDataMap);
        String accID = ccrz.cc_CallContext.effAccountId;
        String currCartEncryptedId = ccrz.cc_CallContext.currCartId;
        String prodSKU = (String)prodDataMap.get('SKU');
        String prodQty = (String)prodDataMap.get('Qty');
        ccrz__E_Product__c curProd = [Select Id,ccrz__UnitOfMeasure__c,Minimum_Quantity__c From ccrz__E_Product__c Where ccrz__SKU__c = :prodSKU Limit 1];
        List<ccrz__E_CartItem__c>  existingItem = [Select Id,ccrz__Quantity__c,ccrz__Price__c,ccrz__SubAmount__c,ccrz__OriginalQuantity__c,ccrz__Coupon__c From ccrz__E_CartItem__c 
                                                   Where ccrz__Product__c =:curProd.Id AND ccrz__cartItemType__c = 'Major' AND 
                                                   ccrz__Cart__r.ccrz__EncryptedId__c =:currCartEncryptedId Limit 1];
        
        try{
            if(existingItem.size()>0){
                if(existingItem[0].ccrz__Coupon__c != null){
                    deleteCartCoupon(currCartEncryptedId,existingItem[0].ccrz__Coupon__c);
                }
                delete existingItem;
            }
            //iba-4409
            ccrz__E_Cart__c cartObj= [select Id,ccrz__Contact__c, ccrz__TotalAmount__c, BetaPage__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :currCartEncryptedId  LIMIT 1];
            if(cartObj.BetaPage__c != true){
                cartObj.BetaPage__c = true;
                update cartObj;
            }
            System.debug('****'+cartObj.ccrz__TotalAmount__c);
            outputMap.put('Total',cartObj.ccrz__TotalAmount__c);
            outputMap.put('message','delete successfull');
            ccRemoteActionResult.success = true;
            //IBA-4281-Start
            couponMessageWrap coupMessage = reCheckCartcouponValidityCheck(currCartEncryptedId);
            System.debug('***'+coupMessage);
            outputMap.put('couponValidityCheck',coupMessage.validity);
            outputMap.put('couponmessage',coupMessage.message);
            outputMap.put('coupon',coupMessage.coupon);
            //IBA-4281-End
        }
        catch(Exception e){
            System.debug(e);
            ccrz__E_Cart__c cartObj= [select Id,ccrz__Contact__c, ccrz__TotalAmount__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :currCartEncryptedId  LIMIT 1];
            System.debug('****'+cartObj.ccrz__TotalAmount__c);
            outputMap.put('Total',cartObj.ccrz__TotalAmount__c);
            outputMap.put('message',e);
            ccRemoteActionResult.success = false;
        }
        // remove for IBA-4469
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult selectAccount(ccrz.cc_RemoteActionContext ctx,String acountCSN, String accountType){//IBA-4129
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        Map<String,object> outputMap= new Map<String,Object>();
        String cartId = ccrz.cc_CallContext.currCartId; 
        ccrz__E_ContactAddr__c accRel = new ccrz__E_ContactAddr__c();
        ccrz__E_ContactAddr__c billTo = new ccrz__E_ContactAddr__c();
        ccrz__E_Cart__c cartObj= [Select Id,New_Cart__c,ccrz__ShipTo__c,ccrz__BillTo__c,SAP_Shipping_Customer_Number__c,SAP_Billing_Customer_Number__c,
                                  Order_attempt__c From ccrz__E_Cart__c Where ccrz__EncryptedId__c= :cartId  LIMIT 1];
        
        Account acc = [select id, Name, BillingCity, BillingState, BillingPostalCode,Transportation_Zone_Country__c,BillingStreet,SAP_Customer_Number__c,
                       BillingCountry,BillingStateCode,PO_BOX__c from account where SAP_Customer_Number__c=:acountCSN];
        if(accountType == 'shipTo'){
            if(cartObj.ccrz__ShipTo__c!= null){
                accRel = [Select Id,ccrz__AddressFirstline__c,ccrz__AddressThirdline__c,ccrz__CountryISOCode__c,ccrz__City__c,ccrz__PostalCode__c,
                          ccrz__Country__c,ccrz__State__c,SAP_Customer_Number__c,Company_Name_2__c,ccrz__CompanyName__c 
                          From ccrz__E_ContactAddr__c Where Id=:cartObj.ccrz__ShipTo__c];   
            }
        }
        if(accountType == 'billTo'){
            if(cartObj.ccrz__BillTo__c!= null){
                accRel = [Select ccrz__AddressFirstline__c,ccrz__AddressThirdline__c,ccrz__CountryISOCode__c,ccrz__City__c,ccrz__PostalCode__c,
                          ccrz__Country__c,ccrz__State__c,SAP_Customer_Number__c,Company_Name_2__c,ccrz__CompanyName__c 
                          From ccrz__E_ContactAddr__c Where Id=:cartObj.ccrz__BillTo__c];
            }
        }
        accRel.ccrz__CompanyName__c = acc.Name;
        //shipTo.Company_Name_2__c = acc.
        accRel.AccountId__c = acc.Id;
        accRel.ccrz__AddressFirstline__c = acc.BillingStreet;
        accRel.ccrz__City__c = acc.BillingCity;
        accRel.ccrz__CountryISOCode__c = acc.Transportation_Zone_Country__c;
        accRel.ccrz__PostalCode__c = acc.BillingPostalCode;
        accRel.ccrz__Country__c = acc.BillingCountry;
        accRel.ccrz__State__c = acc.BillingState;
        accRel.SAP_Customer_Number__c = acc.SAP_Customer_Number__c;   
        accRel.ccrz__StateISOCode__c = acc.BillingStateCode;
        accRel.ccrz__AddressThirdline__c = acc.PO_BOX__c;
        try{
            upsert accRel;
            if(accountType == 'shipTo'){
                cartObj.SAP_Shipping_Customer_Number__c = acc.SAP_Customer_Number__c;
                cartObj.Order_attempt__c = true;
                cartObj.ccrz__ShipTo__c = accRel.id;
            }
            if(accountType == 'billTo'){
                cartObj.SAP_Billing_Customer_Number__c = acc.SAP_Customer_Number__c;
                cartObj.Order_attempt__c = true;
                cartObj.ccrz__BillTo__c = accRel.id;
            }
            update cartObj;
            outputMap.put('message','Account Updated');
            ccRemoteActionResult.success = true;
        }
        catch(Exception e){
            System.debug(e);
            outputMap.put('message','Account Update Failed');
            ccRemoteActionResult.success = false;
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult myCart(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId; 
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        ccrz__E_Cart__c cartObj= [select Id,ccrz__Contact__c, ccrz__TotalAmount__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
        outputMap.put('Total',cartObj.ccrz__TotalAmount__c);
        ccRemoteActionResult.success = true;
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static Decimal getPrice(Integer qty, ccrz__E_PriceListItem__c pti){ // IBA-4130-4131get price whether it is tiered or not
        Decimal price;
        if(pti.ccrz__ItemType__c == 'tiered'){
            Map<String, Object> ptiMap = (Map<String, Object>) JSON.deserializeUntyped(pti.ccrz__PricingTiers__c);
            List<Object> ptiTier = (List<Object>) ptiMap.get('tiers');
            for(Integer i=0;i<ptiTier.size();i++){
                if(i<ptiTier.size()-1){
                    Map<String,Object> minMap = (Map<String,Object>)ptiTier[i];
                    Map<String,Object> maxMap = (Map<String,Object>)ptiTier[i+1];
                    Decimal minQty = (Decimal)minMap.get('q');
                    Decimal maxQty = (Decimal)maxMap.get('q');
                    if(qty < maxQty && qty >= minQty){
                        price = (Decimal)minMap.get('p');
                        System.debug('Tiered price'+price);
                        break;
                    }
                }
                else{
                    Map<String,Object> priceMap = (Map<String,Object>)ptiTier[i];
                    price = (Decimal)priceMap.get('p');
                    System.debug('Tiered price'+price);
                }
            }
        }
        else{
            price = pti.ccrz__Price__c;
            System.debug('Normal price'+price);
        }
        
        return price;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult shipNotesCart(ccrz.cc_RemoteActionContext ctx,string shipNotes){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId; 
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        ccrz__E_Cart__c cartObj= [select Id, ccrz__TotalAmount__c,ccrz__Note__c,ccrz__ValidationStatus__c, BetaPage__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];//iba-4409
        cartObj.ccrz__Note__c = shipNotes;
        cartObj.ccrz__ValidationStatus__c = 'CartAuthUserValidated';
        cartObj.BetaPage__c = true;//iba-4409
        update cartObj;
        outputMap.put('message','Note update successfull');
        ccRemoteActionResult.success = true;
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static void createRelationshiponCart(ccrz__E_Cart__c cartObj, Account acc, String accountType){//IBA-4129
        //IBA-4266
        
        ccrz__E_ContactAddr__c accRel = new ccrz__E_ContactAddr__c();
        accRel.ccrz__CompanyName__c = acc.Name;
        accRel.AccountId__c = acc.Id;
        //shipTo.Company_Name_2__c = acc.
        accRel.ccrz__AddressFirstline__c = acc.BillingStreet;
        accRel.ccrz__City__c = acc.BillingCity;
        accRel.ccrz__CountryISOCode__c = acc.Transportation_Zone_Country__c;
        accRel.ccrz__PostalCode__c = acc.BillingPostalCode;
        accRel.ccrz__Country__c = acc.BillingCountry;
        accRel.ccrz__State__c = acc.BillingState;
        accRel.SAP_Customer_Number__c = acc.SAP_Customer_Number__c;   
        accRel.ccrz__StateISOCode__c = acc.BillingStateCode;
        accRel.ccrz__AddressThirdline__c = acc.PO_BOX__c;
        if(accountType == 'shipTo' && cartObj.ccrz__ShipTo__c!=null){
            accRel.id = cartObj.ccrz__ShipTo__c;
        }
        if(accountType == 'billTo' && cartObj.ccrz__BillTo__c!=null){
            accRel.id = cartObj.ccrz__BillTo__c;
        }
        upsert accRel;
        if(accountType == 'shipTo'){
            cartObj.SAP_Shipping_Customer_Number__c = acc.SAP_Customer_Number__c;
            cartObj.Order_attempt__c = true;
            cartObj.ccrz__ShipTo__c = accRel.id;
        }
        if(accountType == 'billTo'){
            cartObj.SAP_Billing_Customer_Number__c = acc.SAP_Customer_Number__c;
            cartObj.Order_attempt__c = true;
            cartObj.ccrz__BillTo__c = accRel.id;
        }
        update cartObj;
    }
    //remove for IBA-4469
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult couponApply(ccrz.cc_RemoteActionContext ctx,string couponCode){ //IBA-4281
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId; 
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        //Search coupon 
        List<ccrz__E_Coupon__c>  currCoupon = [Select Id,ccrz__CouponName__c,ccrz__StartDate__c,ccrz__EndDate__c,Free_Shipping_Applied__c,ccrz__MaxUse__c,ccrz__MinQty__c,
                                               ccrz__DiscountType__c,ccrz__DiscountAmount__c,ccrz__RuleType__c, 
                                               ccrz__Storefront__c,ccrz__TargetProduct__c,ccrz__TargetQty__c,ccrz__TotalUsed__c From ccrz__E_Coupon__c Where ccrz__CouponCode__c = :couponCode
                                               AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY and ccrz__Enabled__c = True and ccrz__Storefront__c = 'OmnicellB2BStore'];
        try{
            //check coupon exist or not
            if(currCoupon.size()>0){
                //iba-4409
                ccrz__E_Cart__c cartObj= [select Id, ccrz__TotalAmount__c,ccrz__Note__c,ccrz__ValidationStatus__c, BetaPage__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
                if(cartObj.BetaPage__c != true){
                    cartObj.BetaPage__c = true;
                    update cartObj;
                }
                
                List<ccrz__E_CartItem__c> allcurrCartItems = [Select Id,ccrz__Product__c,ccrz__Coupon__c,ccrz__Quantity__c,ccrz__SubAmount__c, Material__c,ccrz__PercentDiscount__c,
                                                              ccrz__Product__r.ccrz__SKU__c
                                                              From ccrz__E_CartItem__c 
                                                              Where ccrz__Cart__c =:cartObj.Id];
                
                List<String> allcurrCartProducts = new List<String>();
                for(ccrz__E_CartItem__c cartItem:allcurrCartItems){
                    allcurrCartProducts.add(cartItem.ccrz__Product__c);
                }
                if(currCoupon[0].ccrz__RuleType__c == 'General'){//IBA-4343
                    if(allcurrCartProducts.contains(currCoupon[0].ccrz__TargetProduct__c)) {
                        if(allcurrCartProducts.size()==1){ //check if only the discounted product is present in the Cart
                            Boolean valid = couponValidityCheck(currCoupon[0],allcurrCartItems[0]); //check coupon validity
                            if(valid){                                 
                                //create cart coupon and update cart Items
                                decimal discount = applyCouponToCartwithDiscount(currCoupon,cartObj,allcurrCartItems);//IBA-4343                                
                                outputMap.put('message','Coupon Applied: '+currCoupon[0].ccrz__CouponName__c);
                                outputMap.put('cItem',allcurrCartItems);
                                decimal total = cartObj.ccrz__TotalAmount__c - discount;//IBA-4343
                                outputMap.put('Total',discount);
                                ccRemoteActionResult.success = true;
                            }
                            else{
                                outputMap.put('message','Coupon Code is Invalid');
                                ccRemoteActionResult.success = false;
                            }
                        }
                        else{
                            outputMap.put('message','Products with discount coupon cannot be mixed with other products in the cart. Please either delete the products, where coupon is not applicable from the cart or remove the coupon. Checkout will be enabled after that.');
                            ccRemoteActionResult.success = false;
                        }
                    }
                    else{
                        outputMap.put('message','Coupon Code is not valid for the current SKU');
                        ccRemoteActionResult.success = false;
                    }
                }
                else{//IBA-4343   
                    if(currCoupon[0].ccrz__TotalUsed__c == null){//IBA-4470 Start
                        currCoupon[0].ccrz__TotalUsed__c = 0;
                    }
                    if(currCoupon[0].ccrz__MaxUse__c == null){
                        currCoupon[0].ccrz__MaxUse__c = 0;
                    }
                    if(currCoupon[0].ccrz__TotalUsed__c >= currCoupon[0].ccrz__MaxUse__c){
                        outputMap.put('message','Coupon usage limit has been reached');
                        ccRemoteActionResult.success = false;
                    }
                    else{                                                           //IBA-4470 End
                        decimal discount = applyCouponToCartwithDiscount(currCoupon,cartObj,allcurrCartItems);                             
                        outputMap.put('message','Coupon Applied: '+currCoupon[0].ccrz__CouponName__c);
                        outputMap.put('cItem',allcurrCartItems);
                        
                        outputMap.put('Total',discount);
                        ccRemoteActionResult.success = true;
                    }                                        
                }                
            }
            else{
                outputMap.put('message','Coupon Code does not Exist');
                ccRemoteActionResult.success = false;
            }
        }
        catch(Exception e){
            System.debug(e);
            outputMap.put('message',e);
            ccRemoteActionResult.success = false;
        }
        
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    } 
    
    public static Boolean couponValidityCheck(ccrz__E_Coupon__c coupon, ccrz__E_CartItem__c cartItm){ //IBA-4281
        Boolean validity = false;
        if(coupon.ccrz__TargetProduct__c == cartItm.ccrz__Product__c){
            if(coupon.ccrz__TotalUsed__c == null){
                coupon.ccrz__TotalUsed__c = 0;
            }
            if(coupon.ccrz__MinQty__c == null){
                coupon.ccrz__MinQty__c = 0;
            }
            
            if(coupon.ccrz__MaxUse__c > coupon.ccrz__TotalUsed__c && cartItm.ccrz__Quantity__c >= coupon.ccrz__MinQty__c && cartItm.ccrz__Quantity__c <= coupon.ccrz__TargetQty__c){
                validity = true;
            }
        }
        return validity;
    } 
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult removeCoupon(ccrz.cc_RemoteActionContext ctx,string couponCode){ //IBA-4281
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId; 
        String effAccount = ccrz.cc_CallContext.effAccountId;
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        //get the coupon
        List<ccrz__E_Coupon__c>  currCoupon = [Select Id From ccrz__E_Coupon__c Where ccrz__CouponCode__c = :couponCode];
        //get the current cart
        ccrz__E_Cart__c cartObj= [select Id, ccrz__TotalAmount__c,ccrz__Note__c,ccrz__ValidationStatus__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
        //get current cart item where coupon is applied
        List<ccrz__E_CartItem__c> allcurrCartItems = [Select Id,ccrz__Product__c,ccrz__Coupon__c,ccrz__SubAmount__c,Material__c,ccrz__Quantity__c,ccrz__PercentDiscount__c,
                                                      ccrz__Product__r.ccrz__SKU__c
                                                      From ccrz__E_CartItem__c Where ccrz__Cart__c =:cartObj.Id AND 
                                                      ccrz__Coupon__c=:currCoupon[0].Id];//IBA-4343
        //get cart coupon data
        List<ccrz__E_CartCoupon__c> cartCoup = [Select Id From ccrz__E_CartCoupon__c Where ccrz__Cart__c = :cartObj.Id AND ccrz__Coupon__c = :currCoupon[0].Id];
        try{
            if(cartCoup.size()>0){ //IBA-4343
                decimal sumCartItemTotal = cartObj.ccrz__TotalAmount__c;
                if(allcurrCartItems.size()>0)
                    sumCartItemTotal = 0;
                for(ccrz__E_CartItem__c cartitem:allcurrCartItems){
                    ccrz__E_PriceListItem__c priceListItem = getProductPrice(effAccount,cartitem.Material__c);
                    cartitem.ccrz__Price__c = getPrice(Integer.valueof(cartitem.ccrz__Quantity__c),priceListItem);
                    cartitem.ccrz__SubAmount__c = cartitem.ccrz__Price__c*cartitem.ccrz__Quantity__c;
                    cartitem.ccrz__Coupon__c = null;
                    sumCartItemTotal += cartitem.ccrz__SubAmount__c ;
                }
                
                delete cartCoup;
                
                update allcurrCartItems;
                outputMap.put('cItem',allcurrCartItems);//IBA-4343
                outputMap.put('message','Coupon remove successfull');
                
                outputMap.put('Total',sumCartItemTotal);//IBA-4343
                ccRemoteActionResult.success = true;
            }
        }
        catch(Exception e){
            System.debug(e);
            outputMap.put('message',e);
            ccRemoteActionResult.success = false;            
        }        
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static couponMessageWrap reCheckCartcouponValidityCheck(String currCartEncryptedId){//IBA-4281
        String validityCheckmsg = '';
        String validity = 'valid';
        String coupon = '';
        couponMessageWrap coupmsg = new couponMessageWrap(validityCheckmsg,validity,coupon);
        String mixError = 'Products with discount coupon cannot be mixed with other products in the cart. Please either delete the products, where coupon is not applicable from the cart or remove the coupon. Checkout will be enabled after that.';
        
        ccrz__E_Cart__c cartObj = [select Id from ccrz__E_Cart__c where ccrz__EncryptedId__c = :currCartEncryptedId  LIMIT 1];
        list<ccrz__E_CartItem__c> currAllCartItems = [select Material__c, ccrz__Product__c,ccrz__Coupon__c,ccrz__Quantity__c from ccrz__E_CartItem__c where ccrz__Cart__c =:cartObj.id];
        Set<String> couponId = new Set<String>();//IBA-4343
        for(ccrz__E_CartItem__c ct:currAllCartItems){
            if(ct.ccrz__Coupon__c != null){
                couponId.add(ct.ccrz__Coupon__c);
            }                
        }
        if(couponId.size()>1){
            coupmsg = new couponMessageWrap('Multiple coupons are applied.','error',coupon);
        }
        else if(couponId.size() == 1){//IBA-4343
            List<ccrz__E_Coupon__c>  currCoupon = [Select Id,ccrz__CouponName__c,ccrz__StartDate__c,ccrz__EndDate__c,Free_Shipping_Applied__c,ccrz__MaxUse__c,ccrz__MinQty__c, 
                                                   ccrz__Storefront__c,ccrz__TargetProduct__c,ccrz__TargetQty__c,ccrz__TotalUsed__c,ccrz__CouponCode__c,ccrz__RuleType__c
                                                   From ccrz__E_Coupon__c Where id IN :couponId
                                                   AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY and ccrz__Enabled__c = True and ccrz__Storefront__c = 'OmnicellB2BStore'];  
            coupon = currCoupon[0].ccrz__CouponCode__c;
            if(currCoupon[0].ccrz__RuleType__c == 'General'){//IBA-4343
                if(currAllCartItems.size()>1){
                    coupmsg = new couponMessageWrap(mixError,'error',coupon);
                }
                else{
                    Boolean validityCheck = couponValidityCheck(currCoupon[0],currAllCartItems[0]);
                    if(validityCheck){
                        coupmsg = new couponMessageWrap('Coupon Applied: '+currCoupon[0].ccrz__CouponName__c,'valid',coupon);
                    }
                    else{
                        coupmsg = new couponMessageWrap('Coupon code is invalid','error',coupon);
                    }
                }  
            }
            else if(currCoupon[0].ccrz__RuleType__c == 'CartTotal'){//IBA-4343 - Start
                if(currCoupon[0].ccrz__TotalUsed__c == null){
                    currCoupon[0].ccrz__TotalUsed__c = 0;
                } 
                
                if(currCoupon[0].ccrz__MaxUse__c > currCoupon[0].ccrz__TotalUsed__c){
                    coupmsg = new couponMessageWrap('Coupon Applied: '+currCoupon[0].ccrz__CouponName__c,'valid',coupon);
                }
                else{
                    coupmsg = new couponMessageWrap('Coupon code is invalid','error',coupon);
                }
            }
        }
        else{
            List<ccrz__E_CartCoupon__c> allCurrCartCoupon = [Select Id,ccrz__Coupon__c From ccrz__E_CartCoupon__c Where ccrz__Cart__r.ccrz__EncryptedId__c =:currCartEncryptedId];
            Set<String> cartcouponIds = new Set<String>();
            for(ccrz__E_CartCoupon__c cartCoup :allCurrCartCoupon){
                cartcouponIds.Add(cartCoup.ccrz__Coupon__c);
            }
            if(cartcouponIds.size()>1){
                coupmsg = new couponMessageWrap('Multiple coupons are applied.','error',coupon);
            }
            else if(cartcouponIds.size() == 1){
                List<ccrz__E_Coupon__c>  currCoupon = [Select Id,ccrz__CouponName__c,ccrz__StartDate__c,ccrz__EndDate__c,Free_Shipping_Applied__c,ccrz__MaxUse__c,ccrz__MinQty__c, 
                                                       ccrz__Storefront__c,ccrz__TargetProduct__c,ccrz__TargetQty__c,ccrz__TotalUsed__c,ccrz__CouponCode__c,ccrz__RuleType__c
                                                       From ccrz__E_Coupon__c Where id IN :cartcouponIds
                                                       AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY and ccrz__Enabled__c = True and ccrz__Storefront__c = 'OmnicellB2BStore']; 
                coupon = currCoupon[0].ccrz__CouponCode__c;    
                if(currCoupon[0].ccrz__TotalUsed__c == null){
                    currCoupon[0].ccrz__TotalUsed__c = 0;
                }                
                if(currCoupon[0].ccrz__MaxUse__c > currCoupon[0].ccrz__TotalUsed__c){
                    coupmsg = new couponMessageWrap('Coupon Applied: '+currCoupon[0].ccrz__CouponName__c,'valid',coupon);
                }
                else{
                    coupmsg = new couponMessageWrap('Coupon usage limit has been reached','error',coupon);//IBA-4470
                }                
            }
        }//IBA-4343 - End
        
        return coupmsg;        
    }
    
    public class couponMessageWrap{//IBA-4281
        public String message;
        public String validity;
        public String coupon;
        public couponMessageWrap(String message, String validity, String coupon){
            this.message = message;
            this.validity = validity;
            this.coupon = coupon;
        }
    }
    
    public static void deleteCartCoupon(String encrypCartId, String couponId){
        List<ccrz__E_CartCoupon__c> allCurrCartCoupon = [Select Id From ccrz__E_CartCoupon__c Where ccrz__Cart__r.ccrz__EncryptedId__c =:encrypCartId AND ccrz__Coupon__c =:couponId];
        if(allCurrCartCoupon.size()>0){
            delete allCurrCartCoupon;
        }
    }
    
    public static decimal applyCouponToCartwithDiscount(List<ccrz__E_Coupon__c> coupon, ccrz__E_Cart__c currentCart, List<ccrz__E_CartItem__c> cartItems){ //IBA-4343
        decimal discount = 0;
        ccrz__E_CartCoupon__c cartcoup = new ccrz__E_CartCoupon__c();    
        cartcoup.ccrz__Cart__c = currentCart.Id;
        cartcoup.ccrz__Coupon__c = coupon[0].Id;
        insert cartcoup;
        decimal disc = 0;
        if(coupon[0].ccrz__DiscountType__c == 'Percentage' && coupon[0].ccrz__RuleType__c != 'Shipping'){
            disc = coupon[0].ccrz__DiscountAmount__c;
            disc = disc/100;
        }
        if(coupon[0].ccrz__RuleType__c != 'Shipping'){
            for(ccrz__E_CartItem__c cartItem:cartItems){
                decimal d = (cartItem.ccrz__SubAmount__c * disc);
                cartItem.ccrz__SubAmount__c = cartItem.ccrz__SubAmount__c - d;
                cartItem.ccrz__Coupon__c = coupon[0].Id;
                cartitem.ccrz__PercentDiscount__c = coupon[0].ccrz__DiscountAmount__c;
            }
            update cartItems; 
        }
        discount = currentCart.ccrz__TotalAmount__c - (currentCart.ccrz__TotalAmount__c*disc);
        return discount;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult payerDetails(ccrz.cc_RemoteActionContext ctx){//iba-4378
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId; 
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        String effAccount = ccrz.cc_CallContext.effAccountId; 
        
        //Account currAcc = [Select SAP_Customer_Number__c from Account Where Id =:effAccount];
        
        ccrz__E_Cart__c cartObj= [select Id,ccrz__Contact__c, ccrz__TotalAmount__c, SAP_SOLD_TO__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
        
        
        SCP_OrderSimulate_Res_Parser  responseParserObj = new SCP_OrderSimulate().SendOrderInfoToSAP(String.valueOf(cartObj.id),True);
        SCP_OrderSimulate_Res_Parser.Row rowObj = responseParserObj.row;
        String payer = rowObj.EV_PAYER;
        system.debug('payer '+payer);
        if(payer != '' && payer != null){
            account acc = [Select SAP_Customer_Number__c, name, BillingStreet, BillingCity, BillingState , BillingPostalCode 
                           From account Where SAP_Account_ID__c=:payer LIMIT 1];
            ccRemoteActionResult.success = true;
            outputMap.put('pDetails',acc);
            outputMap.put('pName',acc.name);
            
        }else{
            outputMap.put('message','No Payer Received');
            ccRemoteActionResult.success = false;
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    // Start IBA-5327
    @RemoteAction
    global static ccrz.cc_RemoteActionResult prodMinQty(ccrz.cc_RemoteActionContext ctx,String sku){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId;
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
		sku = sku.trim();
        List<ccrz__E_CartItem__c> cartItems = [Select id, ccrz__Cart__c, ccrz__Product__r.ccrz__SKU__c,ccrz__Quantity__c
                                                      From ccrz__E_CartItem__c Where  ccrz__cartItemType__c = 'Major' AND ccrz__Cart__r.ccrz__EncryptedId__c =:cartId AND ccrz__Product__r.ccrz__SKU__c = :sku];

        ccrz__E_Product__c prodObj= [Select Id, ccrz__SKU__c, Minimum_Quantity__c from ccrz__E_Product__c where ccrz__SKU__c = :sku LIMIT 1];
        
        if(prodObj != null){
            ccRemoteActionResult.success = true;
            outputMap.put('prodDetails',prodObj);
           	outputMap.put('cartDetails',cartItems);
        }else{
            outputMap.put('message','No Product Found for SKU: '+sku);
            ccRemoteActionResult.success = false;
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    // End IBA-5327
}