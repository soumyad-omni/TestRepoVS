global class QuotePrintProcess_Batch_9_Of_9 implements Database.Batchable<SObject>{
    Private Id qId;
    private Boolean isGenericDrawer = false;
    public QuotePrintProcess_Batch_9_Of_9(Id quoteid, Boolean boolCongaGenericDrawer){
        qId = quoteid;
        isGenericDrawer = boolCongaGenericDrawer;
    }
    global Database.queryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select id, Name from Quote where id =:qId');
    }
    
    global void execute (Database.BatchableContext BC, List<Quote> Quote){
    system.debug ( 'PRINT');
        if(!isGenericDrawer)
        {
           return;        
        }
       
        updateRenewalItems(qId);
        updateNonRenewalItems(qId);

    }
    
    global void finish(Database.BatchableContext BC){
    
        List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c where quote__c=:qId];
        if(qpsList.size()>0){
            qpsList[0].print_status__c = 'FINISHED';
            update qpsList[0];
        }
        else{
            Quote_Print_Status__c qps = new Quote_Print_Status__c();
            qps.quote__c = qId;
            qps.print_status__c = 'FINISHED';
            insert qps;
        }
        FromPrint__c setting;
        Id profileId = userinfo.getProfileId();
        setting = FromPrint__c.getInstance(profileId);
        if (setting.fromprint__c == true) {
            setting.fromprint__c = false;
            upsert setting;
        }
    } 
    
    public DrawerDataModel  getDDM(Quote_Line__c ql)
    {
          DrawerDataModel ddm = new DrawerDataModel();
          ddm.quantity =  ql.QUANTITY__C;
          ddm.unitPrice =  ql.Conga_Unit_Price__c;
          ddm.extendedPrice  =  ql.Conga_Extended_Price_Materials__c;
          ddm.unitService =  ql.Conga_Unit_Services__c;
          ddm.extendedService =   ql.Conga_Extended_Services__c;
          return ddm;
    }
    
    public void updateNonRenewalItems(Id qId)
    {
         Set<ID> productIDs= new Set<ID>();
         Set<String> productNames = new Set<String>();
         Set<String> renewalProductNames = new Set<String>();
         List<Quote_Line__c>qlList = [SELECT id,Conga_Unit_Services__c,Conga_Extended_Services__c,Conga_Quantity_Update__c,Conga_Unit_Price__c,
                                    conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
                                    Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
                                    USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,conga_solution_includes__c,
                                    Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,Conga_Unit_Services_Material_Type__c,
                                    Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,sap_line_number__c,conga_higher_level_item__c,
                                    Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,
                                    Conga_Quantity__c,par_location__c,Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c , Product__r.Name, 
                                    Conga_Renewal_Extended_Services__c, Conga_Renewal_Unit_Services__c,conga_Renewal_grouped_product__c
                                 FROM Quote_Line__c 
                                 WHERE Quote__c =:qId and conga_product__c != null 
                                          and Line_Status__c != :Label.Conga_Quote_Line_Status 
                                          and (NOT Conga_Product1__c like 'Fr%') and (NOT Conga_Product1__c like '%SV')
                                          and (Conga_Grouped_Product__c=true or Conga_Generic_Drawer_Grouped__c = false)
                                          and Conga_Renewal_Grouped_Product__c = false and (NOT Product__r.name like '%RENEWAL%')//added renewal condition for SF-BUG-569 renewal generic drawer issue on 27 FEB by SRAVAN
                                          FOR UPDATE];
        
        Map<String,ID> productNameMap = new Map<String,ID>();
        Map<String,Generic_Material_Product__c> genProdMap = new Map<String,Generic_Material_Product__c>();
        
        Map<String,DrawerDataModel> drawerDataModelMap = new Map<String,DrawerDataModel>();
               
        List<Generic_Material_Product__c> genMatProducts = [Select Id, MatEntered__c,Material__c,Description__c 
                                                                 FROM Generic_Material_Product__c ];
                                                           
        for(Generic_Material_Product__c gp:genMatProducts){
            genProdMap.put(gp.MatEntered__c, gp);
        } 
        
        for(Quote_Line__c ql:qlList){
        
            ql.Conga_Generic_Drawer_Grouped__c = false;
            ql.Generic_Drawer_Product__c = null;            
            if(ql.Conga_Product1__c !=null && genProdMap.containsKey(ql.Conga_Product1__c)){
                  ql.Generic_Drawer_Product__c =  genProdMap.get(ql.Conga_Product1__c).Material__c;
                  ql.Generic_Drawer_Description__c = genProdMap.get(ql.Conga_Product1__c).Description__c;
                 
                if(!productNames.contains(ql.Generic_Drawer_Product__c))
                {                
                  DrawerDataModel ddm = new DrawerDataModel();
                  ddm.quantity =  ql.QUANTITY__C;
                  ddm.unitPrice =  ql.Conga_Unit_Price__c;
                  ddm.extendedPrice  =  ql.Conga_Extended_Price_Materials__c;
                  ddm.unitService =  ql.Conga_Unit_Services__c;
                  ddm.extendedService =   ql.Conga_Extended_Services__c;
                  drawerDataModelMap.put(ql.Generic_Drawer_Product__c, ddm);
                  
                  productNames.add(ql.Generic_Drawer_Product__c);
                  ql.Conga_Generic_Drawer_Grouped__c = true;            
                }
                else if(drawerDataModelMap.containsKey(ql.Generic_Drawer_Product__c))
                {
                  DrawerDataModel ddm = drawerDataModelMap.get(ql.Generic_Drawer_Product__c);
                  ddm.quantity =  ddm.quantity + ql.QUANTITY__C;
                  ddm.unitPrice =  ql.Conga_Unit_Price__c;
                  //ddm.extendedPrice = ddm.extendedPrice + ql.Conga_Extended_Price_Materials__c;
                  if(ql.Conga_Unit_Services__c != null)
                  ddm.unitService = ddm.unitService +  ql.Conga_Unit_Services__c;
                  if(ql.Conga_Extended_Services__c != null)
                  ddm.extendedService = ddm.extendedService +  ql.Conga_Extended_Services__c;
                  drawerDataModelMap.put(ql.Generic_Drawer_Product__c, ddm);
                  
                }
               

            }
       } 
       
        for(Quote_Line__c ql:qlList){           
             if(ql.Conga_Generic_Drawer_Grouped__c)
             {
                  DrawerDataModel ddm;
                  if(drawerDataModelMap.containsKey(ql.Generic_Drawer_Product__c))
                  {
                      ddm = drawerDataModelMap.get(ql.Generic_Drawer_Product__c);
                  }                  
                  ql.CONGA_QUANTITY__C = ddm.quantity;
                  ql.Conga_Unit_Price__c = ddm.unitPrice;
                  if(ddm.quantity == 0 || ddm.quantity == null || ddm.unitPrice == null || ddm.unitPrice == 0)
                  {
                     ql.Conga_Extended_Price_Materials__c = 0;                  
                  }
                  else
                  {
                    ql.Conga_Extended_Price_Materials__c = ddm.unitPrice * ddm.quantity;
                  }
                  
                  ql.Conga_Unit_Services__c = ddm.unitService;
                  ql.Conga_Extended_Services__c = ddm.extendedService;
             }
        }
        try{
            QuoteLineTriggerHandler.fromprint = true;
            update qlList;
            //return 'updated';
        }catch(Exception e){
            //return e.getMessage();
        }
        
    }
    
    
    public void updateRenewalItems(Id qId)
    {
         Set<ID> productIDs= new Set<ID>();
         Set<String> productNames = new Set<String>();
         Set<String> renewalProductNames = new Set<String>();
         List<Quote_Line__c>qlList = [SELECT id,Conga_Unit_Services__c,Conga_Extended_Services__c,Conga_Quantity_Update__c,Conga_Unit_Price__c,
                                    conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
                                    Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
                                    USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,conga_solution_includes__c,
                                    Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,Conga_Unit_Services_Material_Type__c,
                                    Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,sap_line_number__c,conga_higher_level_item__c,
                                    Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,
                                    Conga_Quantity__c,par_location__c,Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c , Product__r.Name, 
                                    Conga_Renewal_Extended_Services__c, Conga_Renewal_Unit_Services__c,conga_Renewal_grouped_product__c
                                 FROM Quote_Line__c 
                                 WHERE Quote__c =:qId and conga_product__c != null 
                                          and Line_Status__c != :Label.Conga_Quote_Line_Status 
                                          and (NOT Conga_Product1__c like 'Fr%') and (NOT Conga_Product1__c like '%SV')
                                          and (Conga_Renewal_Grouped_Product__c=true or Is_Lease_Buyout__c = true) 
                                          FOR UPDATE];
        
        Map<String,ID> productNameMap = new Map<String,ID>();
        Map<String,Generic_Material_Product__c> genProdMap = new Map<String,Generic_Material_Product__c>();
        
        Map<String,DrawerDataModel> drawerDataModelMap = new Map<String,DrawerDataModel>();
               
        List<Generic_Material_Product__c> genMatProducts = [Select Id, MatEntered__c,Material__c,Description__c 
                                                                 FROM Generic_Material_Product__c ];
                                                           
        for(Generic_Material_Product__c gp:genMatProducts){
            genProdMap.put(gp.MatEntered__c, gp);
        } 
        
        for(Quote_Line__c ql:qlList){
        
            ql.Conga_Generic_Drawer_Grouped__c = false;
            ql.Generic_Drawer_Product__c = null;            
            if(ql.Conga_Product1__c !=null && genProdMap.containsKey(ql.Conga_Product1__c)){
                  ql.Generic_Drawer_Product__c =  genProdMap.get(ql.Conga_Product1__c).Material__c;
                  ql.Generic_Drawer_Description__c = genProdMap.get(ql.Conga_Product1__c).Description__c;
                 
                if(!productNames.contains(ql.Generic_Drawer_Product__c))
                { 
                  DrawerDataModel ddm = new DrawerDataModel();
                  ddm.quantity =  ql.Conga_QUANTITY__C; //Replaced quantity with conga_quantity for SF-BUG-569 renewal generic drawer issue on 27 FEB by SRAVAN
                  ddm.unitPrice =  ql.Conga_Unit_Price__c;
                  ddm.extendedPrice  =  ql.Conga_Extended_Price_Materials__c;
                  ddm.unitService =  ql.Conga_Unit_Services__c;
                  ddm.extendedService =   ql.Conga_Extended_Services__c;
                  drawerDataModelMap.put(ql.Generic_Drawer_Product__c, ddm);
                  
                  productNames.add(ql.Generic_Drawer_Product__c);
                  ql.Conga_Generic_Drawer_Grouped__c = true;            
                }
                else if(drawerDataModelMap.containsKey(ql.Generic_Drawer_Product__c))
                {
                  DrawerDataModel ddm = drawerDataModelMap.get(ql.Generic_Drawer_Product__c);
                  ddm.quantity =  ddm.quantity + ql.Conga_QUANTITY__C; //Replaced quantity with conga_quantity for SF-BUG-569 renewal generic drawer issue on 27 FEB by SRAVAN
                  ddm.unitPrice =  ql.Conga_Unit_Price__c;
                  //ddm.extendedPrice = ddm.extendedPrice + ql.Conga_Extended_Price_Materials__c;
                  if(ql.Conga_Unit_Services__c != null)
                  ddm.unitService = ddm.unitService +  ql.Conga_Unit_Services__c;
                  if(ql.Conga_Extended_Services__c != null)
                  ddm.extendedService = ddm.extendedService +  ql.Conga_Extended_Services__c;
                  drawerDataModelMap.put(ql.Generic_Drawer_Product__c, ddm);
                  
                }

            }
       } 
       
        for(Quote_Line__c ql:qlList){           
             if(ql.Conga_Generic_Drawer_Grouped__c)
             {
                  DrawerDataModel ddm;
                  if(drawerDataModelMap.containsKey(ql.Generic_Drawer_Product__c))
                  {
                      ddm = drawerDataModelMap.get(ql.Generic_Drawer_Product__c);
                  }                  
                  ql.CONGA_QUANTITY__C = ddm.quantity;
                  ql.Conga_Unit_Price__c = ddm.unitPrice;
                  if(ddm.quantity == 0 || ddm.quantity == null || ddm.unitPrice == null || ddm.unitPrice == 0)
                  {
                     ql.Conga_Extended_Price_Materials__c = 0;                  
                  }
                  else
                  {
                    ql.Conga_Extended_Price_Materials__c = ddm.unitPrice * ddm.quantity;
                  }
                  
                  ql.Conga_Unit_Services__c = ddm.unitService;
                  ql.Conga_Extended_Services__c = ddm.extendedService;
             }
        }
        try{
            QuoteLineTriggerHandler.fromprint = true;
            update qlList;
            //return 'updated';
        }catch(Exception e){
            //return e.getMessage();
        }
        
    }
}