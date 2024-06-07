global class QuotePrintProcess_Batch_0_Of_initialize implements Database.Batchable<SObject>{
    Private Id qId;
    Private Boolean partrue;
    private Boolean pardettrue;
    private Boolean isGenericDrawer = false;
    private Boolean isProductsUnbundled = false;
    private Boolean zerodollar = false;
        
    public QuotePrintProcess_Batch_0_Of_initialize(Id quoteid,Boolean partrue,Boolean pardettrue, Boolean paramIsGenericDrawer, Boolean isProductsUnbundled,boolean zerodollar){
        qId = quoteid;
        this.partrue = partrue;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
        this.zerodollar = zerodollar;
    }
    global Database.queryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select id, Name from Quote where id =:qId');
    }
    global void execute (Database.BatchableContext BC, List<Quote> Quote){
        List<Quote_Line__c> qli = [select id,discount_percent__c,generic_drawer_product__c,print_discounted_items__c,Service_Months_Free_Discount__c,
                                   quantity__c,Contract_List_Price__c,Discount_Amount__c,Amount_discount_to_zero__c,free_month_applied__c,Conga_Product1__c,
                                   Conga_Higher_Product__c,higher_diff_item__c,Conga_Generic_Drawer_Grouped__c,Product_code__c,Pricing_Reference_Model__r.Name,
                                   Conga_has_base__c,material_type__c,Part_of_a_Bundle__c,Conga_Base_Product__c,Conga_Quantity__c,
                                   conga_Renewal_grouped_product__c,conga_Product__c,sap_line_Number__c,From_Quote_Print__c,Conga_part_of_bundle_check__c,
                                   Higher_Level_Item__c,conga_higher_level_item__c,Conga_Grouped_Product__c,pricing_reference_model__c,
                                   Conga_Higher_Product_1__c,Conga_zero_dollar_byPar__c,Total_Monthly_Product_by_Location__c 
                                   From Quote_Line__c where Quote__c =:qId];
        
        Map<String,Quote_Line__c> qliprd = new Map<String,Quote_Line__c>();
        Map<String,Quote_Line__c> qliprdcts = new Map<String,Quote_Line__c>();
        Map<String,Quote_Line__c> qlihigherprdcts = new Map<String,Quote_Line__c>();
        Map<Decimal,String> qliservmap = new Map<Decimal,String>();
        Map<Decimal,String> qlihigherrenewal = new Map<Decimal,String>(); 
        
        Map<Decimal,String> linemap= new Map<Decimal,String>(); 
        Map<String,Quote_Line__c> linemap1= new Map<String,Quote_Line__c>(); 
        List<String> prdname = new List<String>(); 
        for(Quote_Line__c ql : qli){
            
            if(ql.discount_percent__c == -100 && ql.Part_of_a_Bundle__c == false && ql.generic_drawer_product__c == Null 
               
              ) {
                  if(prdname.contains(ql.Conga_Product1__c)) {
                      ql.print_discounted_items__c =  false;
                  }else {
                      ql.print_discounted_items__c =  true; 
                      prdname.add(ql.Conga_Product1__c);
                  }
              }           
            if(ql.quantity__c > 0 && ql.Contract_List_Price__c > 0){
                decimal totalcont = ql.quantity__c * ql.Contract_List_Price__c * (-1) ;
                if(ql.Discount_Amount__c != null || ql.Discount_Amount__c != 0){
                    if(totalcont == ql.Discount_Amount__c){
                        ql.Amount_discount_to_zero__c = true;
                    }
                }
            }
            
            String congaprd;
            if(ql.Pricing_Reference_Model__c == null)
                congaprd = ql.Product_code__c;
            else
                congaprd = ql.Pricing_Reference_Model__r.Name;
            
            linemap.put(ql.SAP_Line_Number__c,congaprd);
            linemap1.put(congaprd+String.valueOf(ql.Higher_Level_Item__c),ql);
            
            if(ql.material_type__c == 'PRODUCT'){
                
                qliprd.put(congaprd,ql);
                String prdwithhigheritem = congaprd+String.valueOf(ql.higher_level_item__c);
                qliprdcts.put(prdwithhigheritem,ql);
                
                qlihigherprdcts.put(String.valueOf(ql.SAP_Line_Number__c),ql);
            }
            
            qliservmap.put(ql.SAP_Line_Number__c,congaprd);
            qlihigherrenewal.put(ql.SAP_Line_Number__c,ql.Product_Code__c);
        }
        FromPrint__c setting;
        Id profileId = userinfo.getProfileId();
        setting = FromPrint__c.getInstance(profileId);
        if (setting.fromprint__c == false) {
            setting.fromprint__c = true;
            try{
                upsert setting;
            }catch(Exception e){
                System.debug('error : '+e.getmessage());
            }
        }
        
        for(Quote_Line__c q : qli){
            String congaprd;
            if(q.Pricing_Reference_Model__c == null)
                congaprd = q.Product_code__c;
            else
                congaprd = q.Pricing_Reference_Model__r.Name;
            if(q.material_type__c == 'SERVICE' && q.pricing_reference_model__c == null){
                String servcode = congaprd.replace('-SV','');
                if(qliprd.get(servcode) != null){
                    q.conga_has_base__c = true;
                }   
            }
            
            
            if(q.material_type__c == 'SERVICE'){
                q.Conga_Higher_Product__c = '';
                String prcdeserv = qliservmap.get(q.higher_level_item__c);
                String ren = qlihigherrenewal.get(q.higher_level_item__c);
                String servcodecheck = congaprd.replace('-SV','');
                if(prcdeserv != servcodecheck){
                    q.higher_diff_item__c = true;
                    
                }
                else{
                    q.higher_diff_item__c = false;
                }
                
                if(qliprd.get(prcdeserv) != null){
                    Quote_Line__c ql1 = qliprd.get(prcdeserv);
                    if(ren != 'RENEWAL'){
                        if(ql1.higher_level_item__c == 0)
                            q.Conga_Higher_Product__c = prcdeserv;
                        else
                            q.Conga_Higher_Product__c = servcodecheck;
                    }
                    Quote_Line__c ql2 = qliprdcts.get(servcodecheck+String.valueOf(q.higher_level_item__c));
                    if(ql2 != null){
                        if(ql2.Higher_Level_Item__c == q.Higher_Level_Item__c){
                            q.Conga_Higher_Product__c = servcodecheck;
                        }
                    }
                }
            }
            
            String prodcode = '';
            q.Conga_Base_Product__c = false;
            if(q.Higher_Level_Item__c != 0)
                q.conga_higher_level_item__c = String.valueof(q.Higher_Level_Item__c);
            else{
                q.conga_higher_level_item__c = String.valueof(q.sap_line_Number__c);
            }
            q.free_month_applied__c = false;
            q.Conga_Generic_Drawer_Grouped__c = false;
            q.Generic_Drawer_Product__c = null;
            q.Conga_Grouped_Product__c = false;
            q.Conga_part_of_bundle_check__c = false;
            q.conga_Renewal_grouped_product__c = false;
            q.Conga_Quantity__c = 0;
            q.Conga_part_of_bundle_true__c = false;
            q.Conga_Extended_Price_Materials__c =0;
            q.Conga_Extended_Services__c = 0;
            q.Conga_Zero_Dollar__C  = false;
            q.Conga_zero_dollar_byPar__c = false;
            q.Conga_Extended_price_Detbypar__c = 0; 
            q.Conga_Extended_Service_Detbypar__c = 0;
            q.Conga_Unit_Price__c = 0;
            q.Total_Monthly_Product_by_Location__c = 0;
            
            if(congaprd != null){
                prodcode = congaprd;
                if((prodcode.contains('-SV') || prodcode.contains('-sv')) && q.material_type__c == 'SERVICE'){
                    prodcode = prodcode.replace('-SV', '');
                    prodcode = prodcode.replace('-sv', '');
                    if(q.Service_Months_Free_Discount__c != null && q.Service_Months_Free_Discount__c != 0){
                        
                        if(qlihigherprdcts.get(String.valueOf(q.higher_level_item__c)) != null){
                            Quote_line__c qhigher = qlihigherprdcts.get(String.valueOf(q.higher_level_item__c));
                            qhigher.free_month_applied__c = true;
                        }
                    }
                    
                }
                
            }
            q.conga_Product__c = prodcode;
            q.From_Quote_Print__c = true;
            if(q.material_type__c == 'SERVICE') {
                String servcodecheck1 = congaprd.replace('-SV','');
                String parentProductName = linemap.get(q.higher_level_item__c);
                Quote_Line__C quoteLRecord = linemap1.get(servcodecheck1+String.valueOf(q.higher_level_item__c));
                if(quoteLRecord != Null && quoteLRecord.Part_of_a_Bundle__c == false) {
                    q.Conga_Higher_Product_1__c = servcodecheck1;
                }else {
                    q.Conga_Higher_Product_1__c = parentProductName;
                }
            }
        }
        QuoteLineTriggerHandler.triggerdisabled = true;
        update qli;
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            
            if(partrue || pardettrue){ 
                QuotePrintProcess_Batch_0_Of_6 b = new QuotePrintProcess_Batch_0_Of_6(qId,partrue,pardettrue,isGenericDrawer,isProductsUnbundled,zerodollar);
                database.executeBatch(b);
            }
            else{
                QuotePrintProcess_Batch_1_Of_6 b = new QuotePrintProcess_Batch_1_Of_6(qId,partrue,pardettrue,isGenericDrawer,isProductsUnbundled,zerodollar);
                database.executeBatch(b);
            }
        }
        else{
            List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c where quote__c=:qId];
            if(qpsList.size()>0){
                qpsList[0].Generic_Drawer__c = false;
                qpsList[0].products_unbundled__c = false;
                qpsList[0].summary_by_product__c = false;
                qpsList[0].summary_by_par__c = false;
                qpsList[0].Detail_by_par__c = false;
                qpsList[0].print_status__c = 'FAILED';
                update qpsList[0];
            }
        }
    }
}