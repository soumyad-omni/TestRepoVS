/**
 * @File Name          : QuotePrintProcess_Batch_2_Of_6.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 07-24-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class QuotePrintProcess_Batch_2_Of_6 implements Database.Batchable<SObject>{
    Private Id qId;
    private Boolean pardettrue;
    private Boolean isGenericDrawer = false;
    private Boolean isProductsUnbundled = false;//Added by Sravan for SF-BUG-528
    private Boolean zerodollar = false;//Added for SF-BUG-725
    public QuotePrintProcess_Batch_2_Of_6(Id quoteid){
        qId = quoteid;
    }
    public QuotePrintProcess_Batch_2_Of_6(Id quoteid,Boolean pardettrue, Boolean paramIsGenericDrawer){
        qId = quoteid;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
    }
    //Added by Sravan for SF-BUG-528 START
    public QuotePrintProcess_Batch_2_Of_6(Id quoteid,Boolean pardettrue, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled){
        qId = quoteid;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
    }
    //Added by Sravan for SF-BUG-528 END
    //below constructor added for SF-BUG-725 by sravan
    public QuotePrintProcess_Batch_2_Of_6(Id quoteid,Boolean pardettrue, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled,Boolean zerodollar){
        qId = quoteid;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
        this.zerodollar = zerodollar;
    }
    global Database.queryLocator start(Database.BatchableContext bc){
        String name = 'Checking this night again for big quote';
        return Database.getQueryLocator('Select id, Name from Quote where id =:qId');
    }
    global void execute (Database.BatchableContext BC, List<Quote> Quote){
        Id qId = quote[0].id;
        List<Quote_Line__c> qli = [select id,Conga_Unit_Services__c,From_Quote_Print__c,Conga_Sales_Text_Long__c,conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
                                   Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
                                   USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c, Currency_Symbol__c, CurrencyIsoCode, Quote__r.SAP_Sales_Org__r.Sales_Org__c, Conga_Intl_Extended_Services__c,  //IBA-3867(4626) Abhrajitc
                                   conga_solution_includes__c,Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,
                                   Conga_Unit_Services_Material_Type__c,Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,
                                   sap_line_number__c,conga_higher_level_item__c,Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,
                                   conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,Conga_Quantity__c,par_location__c,  
                                   Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c,Product__r.name, Product__r.DW_Product_Class__c,
                                   Pricing_Reference_Model__c,discount_percent__c
                                   From Quote_Line__c where Quote__c =:qId and material_type__c='PRODUCT'
                                   and (NOT Product__r.name like '%LEASE BUYOUT%')
                                   and (NOT Product__r.name like '%RENEWAL%')
                                   and Line_Status__c != :Label.Conga_Quote_Line_Status FOR UPDATE];
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        /*List<Quote_Line__c> qli = new List<Quote_Line__c>();
        for(Quote_line__c ql : qlist){
            qli.add(ql);
        }
        qli.sort();*/
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END
        Map<Decimal,Quote_Line__c> linemap= new Map<Decimal,Quote_Line__c>();
        List<Quote_Line__c> linestoupdate = new List<Quote_Line__c>();
        Map<String,List<Quote_Line__c>> linemapq2= new Map<String,List<Quote_Line__c>>();
        Map<String,List<Quote_Line__c>> linemapq3= new Map<String,List<Quote_Line__c>>();
        for(Quote_Line__c q : qli){
            if(q.product__r.name == 'RENEWAL')
                linemap.put(q.SAP_Line_Number__c,q);
            //Added by Sravan for quote print optimisation START
            //IBA-1544 updated condition --- Added q.product_code__c.contains('OCE') as part of IBA-4151
            if( q.product_code__c.contains('OCE') || q.Customer_Price__c!=0 || q.Higher_Level_Item__c == 0 ||( q.discount_percent__c == -100 && q.part_of_a_bundle__c == false)
               && q.Material_Type__c != 'SERVICE'){
            if(linemapq2.containsKey(q.conga_product__c)){
                List<Quote_Line__c> proList=linemapq2.get(q.conga_product__c);
                proList.add(q);
                linemapq2.put(q.conga_product__c, proList);
            }
            else{
                linemapq2.put(q.conga_product__c, new List<Quote_Line__c>{q});
            }
            }
            ////Added by sravan for quantity fix oct 31 START
            /*if(q.Customer_Price__c==0 || q.Higher_Level_Item__c != 0){
            if(linemapq3.containsKey(q.conga_product__c)){
                List<Quote_Line__c> proList=linemapq3.get(q.conga_product__c);
                proList.add(q);
                linemapq3.put(q.conga_product__c, proList);
            }
            else{
                linemapq3.put(q.conga_product__c, new List<Quote_Line__c>{q});
            }
            }*/
            //Added by Sravan for quote print optimisation END
        }
        //IBA-1522 Query update
        AggregateResult[] quantityserv = [select Conga_Higher_Product__c prdc,Conga_Higher_Product_1__c prdc1,sum(Quantity__c) qty,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst,Sum(Customer_Price__c) cst,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,sum(USA_List_Price__c) usa, sum(Intl_Extended_Services__c) extsint
                                          from Quote_Line__c 
                                          where Quote__c =:qId and Part_of_a_Bundle__c = FALSE and conga_product__c != null
                                          and material_type__c = 'SERVICE'
                                          and Line_Status__c != :Label.Conga_Quote_Line_Status
                                          and (NOT Product__r.name like '%LEASE BUYOUT%')
                                          and (NOT Product__r.name like '%RENEWAL%') and Line_Status__c != 'E0003'
                                          and (NOT Higher_level_item__c in :linemap.keySet())
                                          and Conga_Higher_Product__c!= null
                                          group by Conga_Higher_Product__c,Conga_Higher_Product_1__c];//added Conga_Higher_Product__c in filter and at the top of the query by sravan for SF-BUG-678
        AggregateResult[] quantity3 = [select Pricing_Reference_Model__r.Name prdc1,Product__r.ProductCode prdc, sum(Quantity__c) qty,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst,Sum(Customer_Price__c) cst,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,sum(USA_List_Price__c) usa
                                       from Quote_Line__c 
                                       where Quote__c =:qId 
                                       and Part_of_a_Bundle__c = false 
                                       and conga_product__c != null
                                       and Line_Status__c != :Label.Conga_Quote_Line_Status
                                       and (NOT Product__r.name like '%LEASE BUYOUT%')
                                       and (NOT Product__r.name like '%RENEWAL%')
                                       and (product_code__c Like 'OCE%' OR customer_price__c > 0 or higher_level_item__c =0
                                            OR (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null))
                                       //     OR added product_code__c Like 'OCE%' as part of IBA-4151
                                       //( discount_percent__c = -100 AND Pricing_Reference_Model__c != null and Quantity__c!=null and Quantity__c > 0)
                                           )//Added by sravan for quantity fix oct 31
                                       group by Pricing_Reference_Model__r.Name ,Product__r.ProductCode]; //soumyad 964-965 changed name to productcode
        if(!isProductsUnbundled){//Added by Sravan for SF-BUG-528 this piece of block will not execute when user selects Display Products unbundled option 
        for(Integer i=0;i<quantityserv.size();i++){
            String prcode;  
            prcode = (String)quantityserv[i].get('prdc');
           // String higherlevelitem = (String)quantityserv[i].get('chli');
            
            Boolean groupedcheck = false;
            List<Quote_Line__c> qlList = linemapq2.get(prcode);//Added by Sravan for quote print optimisation
            if(qlList != null && !qlList.isempty()){
                for(Quote_Line__c q : qlList){
                    boolean serviceprd = false;
                    String prcode2 = q.conga_product1__c;
                    if(prcode2 != null && ((prcode2.contains('-sv')||prcode2.contains('-SV')) && q.Material_Type__c == 'SERVICE')){
                            serviceprd = true;
                    }
                    if(q.Conga_Product1__c == prcode){
                        if(q.Customer_Price__c==0 && q.Higher_Level_Item__c == 0){//Added by sravan for quantity fix oct 31
                            if(groupedcheck == false ){
                                if(serviceprd == false){
     								                             
                                    q.conga_grouped_product__c = true;
                                    groupedcheck = true;
                                    System.debug('For Conga Product:::' +q.CONGA_PRODUCT1__c+ 'Conga Grouped Product is:::'+q.Conga_Grouped_Product__c);
                                    System.debug(LoggingLevel.INFO,'grouped : '+q.conga_grouped_product__c);
                                }
                                else{
                                    q.conga_grouped_product__c = false;
                                    serviceprd = false;
                                    System.debug('For Conga Product:::' +q.CONGA_PRODUCT1__c+ 'Conga Grouped Product is:::'+q.Conga_Grouped_Product__c);
                                }
                            }
                            else{
                                q.conga_grouped_product__c = false;
                                System.debug('For Conga Product:::' +q.CONGA_PRODUCT1__c+ 'Conga Grouped Product is:::'+q.Conga_Grouped_Product__c);
                            }
                        }
                        if(q.Higher_Level_Item__c == 0 || q.Part_of_a_Bundle__c == false){    
                           // if(q.conga_higher_level_item__c == higherlevelitem)//added by sravan for SF-BUG-678
                            	q.Conga_Unit_Services__c = (Decimal)quantityserv[i].get('cusmt');
                        }
                        if(q.Higher_Level_Item__c == 0 || q.Part_of_a_Bundle__c == false){
                          //  if(q.conga_higher_level_item__c == higherlevelitem)//added by sravan for SF-BUG-678
                            if(q.CurrencyIsoCode == 'GBP' && q.Quote__r.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && (quantityserv[i].get('extsint') != null)){ //IBA-3867(4626) Change
                                q.Conga_Intl_Extended_Services__c = (Decimal)quantityserv[i].get('extsint');
                            } //IBA-3867(4626) Change
                            q.Conga_Extended_Services__c = (Decimal)quantityserv[i].get('cusmt') ; 
                        }
                        q.Conga_part_of_bundle_check__c = true;
                        if(!linestoupdate.contains(q))//added by sravan for SF-BUG-678
                        	linestoupdate.add(q);
                    }    
                } 
            }
        }
        }//Added by Sravan for SF-BUG-528 this piece of block will not execute when user selects Display Products unbundled option
        for(Integer i=0;i<quantity3.size();i++){
            //system.debug('@@4151--here');
            String prcode;
            string prcode1 = (String)quantity3[i].get('prdc');
            string prcode2 = (String)quantity3[i].get('prdc1'); 
            if(prcode2!=null)
                prcode=prcode2;
            else
                prcode=prcode1;
            Boolean groupedcheck = false;
            List<Quote_Line__c> qlList = linemapq2.get(prcode);//Added by Sravan for quote print optimisation
            System.debug('linemap 2 : '+ linemapq2.get(prcode));
            if(qlList != null && !qlList.isempty()){
                for(Quote_Line__c q : qlList){
                    System.debug('product name : '+q.conga_product1__c+' price : '+q.Customer_Price__c+ 'conga Qty: '+q.Conga_Quantity__c );
                    if (q.Resend_to_SAP__c) {
                        q.Resend_to_SAP__c=false;
                    }
                  /*  if(q.Product__r.DW_Product_Class__c == 'Training' && q.Conga_Quantity__c == null){
                        q.Conga_Quantity__c = q.Quantity__c;
                    }*/
                    boolean serviceprd = false;
                    if(q.Conga_Product1__c.contains('-sv')||q.Conga_Product1__c.contains('-SV') && q.Material_Type__c == 'SERVICE')
                        serviceprd = true;
                    if(q.Conga_Product1__c.contains(prcode) && serviceprd == false && q.conga_product1__c == prcode){
                        Decimal quanfinal = 0;//Added by sravan for quantity fix oct 31
                        if(q.Conga_part_of_bundle_true__c == false){
                            //System.debug('quant prod : '+q.Conga_Quantity__c + ' '+prcode+' '+(Decimal)quantity3[i].get('qty'));
                            quanfinal = q.Conga_Quantity__c+(Decimal)quantity3[i].get('qty');//Added by sravan for quantity fix oct 31
                        }
                        else
                            quanfinal = (Decimal)quantity3[i].get('qty');//Added by sravan for quantity fix oct 31
                        //IBA-1606 START
                        if(isProductsUnbundled) {
                            quanfinal = q.Conga_Quantity__c;
                        }
                        //IBA-1606 END
                        System.debug('product : '+q.conga_product1__c+'quantity : '+quanfinal+'customer price : '+q.customer_price__c);
                        //Added by sravan for quantity fix oct 31 START
                        /*if(linemapq3.get(q.conga_product1__c) != null){
                          System.debug('qlquan : '+linemapq3.get(q.conga_product1__c));
                            for(Quote_Line__c qlquan : linemapq3.get(q.conga_product1__c)){
                                System.debug('Product : '+qlquan.Conga_Product1__c+'qlquan : '+qlquan.Quantity__c+' : '+quanfinal);
                                quanfinal = quanfinal-qlquan.Quantity__c;
                            }
                        }*/
                        q.Conga_Quantity__c = quanfinal;
                        ////Added by sravan for quantity fix oct 31 END
                        if(!linestoupdate.contains(q))
                            linestoupdate.add(q);
                    }    
                }   
            }
        }  
        QuoteLineTriggerHandler.fromprint = true;
        QuoteLineTriggerHandler.fromquoteprint = true;
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        Map<Id,Quote_Line__c> linesmaptoupdate = new Map<Id,Quote_Line__c>();
        for(Quote_Line__c qlitem : linestoupdate){
            linesmaptoupdate.put(qlitem.id,qlitem);
        }
        //update linestoupdate;
        update linesmaptoupdate.values();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END
    }
    
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            //Added by Sravan for SF-BUG-528 START
            //if(!isProductsUnbundled){
            	QuotePrintProcess_Batch_3_Of_6 b = new QuotePrintProcess_Batch_3_Of_6(qId,pardettrue,isGenericDrawer,isProductsUnbundled,zerodollar);
                database.executeBatch(b);
            /*}else{
                QuotePrintProcess_Batch_5_Of_6 b = new QuotePrintProcess_Batch_5_Of_6(qId,isGenericDrawer,isProductsUnbundled,zerodollar);
                database.executeBatch(b);
            }*///commented productsunbundled for SF-BUG-724
            //Added by Sravan for SF-BUG-528 END
            
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