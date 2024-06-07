/**
 * @File Name          : QuotePrintProcess_Batch_1_Of_6.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 07-24-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    30/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class QuotePrintProcess_Batch_1_Of_6 implements Database.Batchable<SObject>{
    Private Id qId;
    Private Boolean partrue;
    private Boolean pardettrue;
    private Boolean isGenericDrawer = false;
    private Boolean isProductsUnbundled = false;//Added by Sravan for SF-BUG-528
    private Boolean zerodollar = false;
    public QuotePrintProcess_Batch_1_Of_6(Id quoteid){
        qId = quoteid;
    }
    public QuotePrintProcess_Batch_1_Of_6(Id quoteid,Boolean partrue,Boolean pardettrue){
        qId = quoteid;
        this.partrue = partrue;
        this.pardettrue = pardettrue;
    }
    public QuotePrintProcess_Batch_1_Of_6(Id quoteid,Boolean partrue,Boolean pardettrue, Boolean paramIsGenericDrawer){
        qId = quoteid;
        this.partrue = partrue;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
    }
    //Added by Sravan for SF-BUG-528 START
    public QuotePrintProcess_Batch_1_Of_6(Id quoteid,Boolean partrue,Boolean pardettrue, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled){
        qId = quoteid;
        this.partrue = partrue;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
    }
    //Added by Sravan for SF-BUG-528 END
    //below constructor added for SF-BUG-725 by sravan
    public QuotePrintProcess_Batch_1_Of_6(Id quoteid,Boolean partrue,Boolean pardettrue, Boolean paramIsGenericDrawer, Boolean isProductsUnbundled,boolean zerodollar){
        qId = quoteid;
        this.partrue = partrue;
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
        
        List<Quote_Line__c> qli = [select id,conga_higher_product__c,quote__r.service_duration__c,quote__r.Free_Month_Service__c,From_Quote_Print__c,Conga_Sales_Text_Long__c,conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
                                   Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
                                   USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,
                                   conga_solution_includes__c,Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,
                                   Conga_Unit_Services_Material_Type__c,Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,
                                   sap_line_number__c,conga_higher_level_item__c,Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c, Quote__r.SAP_Sales_Org__r.Sales_Org__c, CurrencyIsoCode, Total_Customer_Price__c, product__r.DW_Product_Type__c,  //IBA-3867 (4626) /*IBA-4731 Change AC: New change to the Query*/
                                   conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,Conga_Quantity__c,par_location__c,
                                   Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c,Product__r.name,Product__r.Product_Type__c,
                                   Contract_List_Price_Recalculate__c,Customer_Price_Recalculate__c,USA_List_Price_Recalculate__c,Skip_rollup_text__c,zero_header__c
                                   From Quote_Line__c where Quote__c =:qId and (conga_product1__c =: Label.ProductUnbundled_NAC_LIC_003 or customer_price__c > 0 or usa_list_price__c >=0 or zero_header__c =true 
                                                                                OR (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null)))
                                   and Line_Status__c != :Label.Conga_Quote_Line_Status 
                                   FOR UPDATE]; //soumyad added new fields and added flag omni one change 964 & 965
        /*//Adding as part of duplicate id fix - 12 NOV by SRAVAN START
List<Quote_Line__c> qli = new List<Quote_Line__c>();
for(Quote_line__c ql : qlist){
qli.add(ql);
}
qli.sort();
//Adding as part of duplicate id fix - 12 NOV by SRAVAN END*/
        List<Quote_Line__c> linestoupdate = new List<Quote_Line__c>();
        Map<Decimal,Quote_Line__c> linemapq1= new Map<Decimal,Quote_Line__c>();
        Map<String,List<Quote_Line__c>> linemapq2= new Map<String,List<Quote_Line__c>>();
        Map<String,List<Quote_Line__c>> linemapq3= new Map<String,List<Quote_Line__c>>();
        Map<String,List<Quote_Line__c>> linemapq4= new Map<String,List<Quote_Line__c>>();
        Map<String,Decimal> qtyMap= new Map<String,Decimal>(); //IBA-1606
        Map<String,List<Quote_Line__c>> linemapq5= new Map<String,List<Quote_Line__c>>();//Added by sravan on 13 FEB for products unbundled issue
        for(Quote_Line__c q : qli){
            linemapq1.put(q.SAP_Line_Number__c,q);
            //Added by Sravan for quote print optimisation START
            if(linemapq2.containsKey(q.conga_product__c)){
                List<Quote_Line__c> proList=linemapq2.get(q.conga_product__c);
                proList.add(q);
                linemapq2.put(q.conga_product__c, proList);
            }
            else{
                linemapq2.put(q.conga_product__c, new List<Quote_Line__c>{q});
            }
           /* if(linemapq3.containsKey(q.par_location__c)){
                List<Quote_Line__c> proList=linemapq3.get(q.par_location__c);
                proList.add(q);
                linemapq3.put(q.par_location__c, proList);
            }
            else{
                linemapq3.put(q.par_location__c, new List<Quote_Line__c>{q});
            }*/
            if(isProductsUnbundled){
                if(q.Material_Type__c == 'SERVICE'){
                    if(linemapq4.containsKey(q.conga_product__c)){
                        List<Quote_Line__c> proList=linemapq4.get(q.conga_product__c);
                        proList.add(q);
                        linemapq4.put(q.conga_product__c, proList);
                    }
                    else{
                        linemapq4.put(q.conga_product__c, new List<Quote_Line__c>{q});
                    }
                    //IBA-1606 START
                    if(qtyMap.containsKey(q.conga_product__c)){
                        Decimal qty = qtyMap.get(q.conga_product__c);
                        qty = qty + q.Quantity__c;
                        qtyMap.put(q.conga_product__c, qty);
                    }
                    else{
                        qtyMap.put(q.conga_product__c, q.Quantity__c);
                    }
                    //IBA-1606 END
                }
                //Added by sravan on 13 FEB for Products unbundled issue START
                if(q.Material_Type__c == 'SERVICE'){
                    if(linemapq5.containsKey(q.conga_higher_product__c)){
                        List<Quote_Line__c> proList=linemapq5.get(q.conga_higher_product__c);
                        proList.add(q);
                        linemapq5.put(q.conga_higher_product__c, proList);
                    }
                    else{
                        linemapq5.put(q.conga_higher_product__c, new List<Quote_Line__c>{q});
                    }
                }
                //Added by sravan on 13 FEB for Products unbundled issue END
            }
            //Added by Sravan for quote print optimisation END
        }
        /*if(partrue || pardettrue){
            AggregateResult[] ql = [select sum(Conga_Extended_price_summbypar__c)total,sum(Conga_Extended_Service_summbypar__c) exssumbypar,sum(Conga_Unit_Services_Material_Type__c)totalserv,sum(Conga_Unit_Price_by_Par__c) extmat,sum(Conga_unit_services_by_par__c) extserv,par_location__c par
                                    from Quote_Line__c 
                                    where Quote__c =:qId 
                                    and Line_Status__c != :Label.Conga_Quote_Line_Status
                                    group by par_location__c];    
            Integer qlsize = ql.size();
            for(Integer i=0;i<qlsize;i++){
                String parloc;
                parloc = (String)ql[i].get('par');
                System.debug('par location : '+parloc);
                List<Quote_Line__c> qlList = linemapq3.get(parloc);
                //System.debug('qlist size : '+qlList.size());
                if(qlList != null && !qlList.isempty()){
                    for(Quote_Line__c q : qlList){
                        //System.debug('product : '+q.conga_product1__c);
                        if(q.Par_Location__c == ql[i].get('par')){
                            
                            Decimal totalprdbyloc; 
                            if((Decimal)ql[i].get('total') != null)
                                totalprdbyloc = (Decimal)ql[i].get('total');
                            else
                                totalprdbyloc = 0;
                            q.Conga_Total_Product_by_Location__c = totalprdbyloc;
                            q.Conga_Par_Location_Total__c = totalprdbyloc+(Decimal)ql[i].get('totalserv');
                            //SF-BUG-810 fix by Rajat (now considering the "free month service" to calculate the "total monthly service")
                            if((Decimal)ql[i].get('exssumbypar') != null){
                                if(q.quote__r.service_duration__c != null) {
                                    if(q.quote__r.Free_Month_Service__c != null && q.quote__r.Free_Month_Service__c != 0) {
                                        q.Conga_Total_Support_Services_by_Location__c = (Decimal)ql[i].get('exssumbypar') * (q.quote__r.service_duration__c - q.quote__r.Free_Month_Service__c);
                                    }else {
                                        q.Conga_Total_Support_Services_by_Location__c = (Decimal)ql[i].get('exssumbypar') * q.quote__r.service_duration__c;
                                    }
                                }     
                                else
                                    q.Conga_Total_Support_Services_by_Location__c = (Decimal)ql[i].get('exssumbypar');
                            }else{
                                q.Conga_Total_Support_Services_by_Location__c = 0;
                            }
                            q.Total_Monthly_Support_Services_by_Locati__c = (Decimal)ql[i].get('extserv');
                            q.Par_Location_Monthly_Total__c = (Decimal)ql[i].get('extmat')+(Decimal)ql[i].get('extserv');
                            system.debug('totalprd by loc : '+q.Conga_Total_Product_by_Location__c+' : '+totalprdbyloc);
                            if(!linestoupdate.contains(q))
                                linestoupdate.add(q);
                        }
                    }
                }
            }
            AggregateResult[] ql1 = [select sum(Conga_Extended_price_summbypar__c)totalz,sum(Conga_Unit_Services_Material_Type__c)totalserv,sum(Conga_Unit_Price_by_Par__c) extmat,sum(Conga_unit_services_by_par__c) extserv,par_location__c par
                                     from Quote_Line__c 
                                     where Quote__c =:qId
                                     and Conga_Product1__c != null 
                                     and (NOT Conga_Product1__c like 'Fr%')  
                                     and (NOT Conga_Product1__c like '%SV')
                                     //and (NOT Conga_Product1__c like '%RENEWAL%') 
                                     and part_of_a_bundle__c  = FALSE
                                     and Line_Status__c != :Label.Conga_Quote_Line_Status
                                     group by par_location__c];   
            Integer qlsize1 = ql1.size();
            for(Integer i=0;i<qlsize1;i++){
                String parloc;
                parloc = (String)ql1[i].get('par');
                List<Quote_Line__c> qlList = linemapq3.get(parloc);//Added by Sravan for quote print optimisation
                if(qlList != null && !qlList.isempty()){
                    for(Quote_Line__c q : qlList){
                        if(q.Par_Location__c == ql1[i].get('par')){
                            q.Total_Monthly_Product_by_Location__c = (Decimal)ql1[i].get('totalz');
                            if(!linestoupdate.contains(q))
                                linestoupdate.add(q);
                        }    
                    }
                }
            }
        }*/
        AggregateResult[] quantity1 = [select conga_higher_level_item__c hli,sum(Quantity__c) qty,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price_Recalculate__c) lst,Sum(Customer_Price_Recalculate__c) cst,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,sum(USA_List_Price_Recalculate__c) usa, sum(Intl_Cong_Extended_Price_Material_type__c) intlepst /* IBA-4780 AC: Updated query */
                                       from Quote_Line__c 
                                       where Quote__c =:qId and Part_of_a_Bundle__c = TRUE and Line_Status__c != :Label.Conga_Quote_Line_Status
                                       and (NOT Product__r.name like '%LEASE BUYOUT%')  
                                       and (NOT Product__r.name like '%RENEWAL%')
                                       group by conga_higher_level_item__c]; //soumyad changed sf-bug 964 & 965
        //Added by Sravan for SF-BUG-528 START
        AggregateResult[] quantity2;
        AggregateResult[] quantityub;
        if(!isProductsUnbundled){
            quantity2 = [select Conga_product__c prdc,sum(Quantity__c) qty,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price_Recalculate__c) lst,Sum(Customer_Price_Recalculate__c) cst,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,sum(USA_List_Price_Recalculate__c) usa
                         from Quote_Line__c 
                         where Quote__c =:qId and Part_of_a_Bundle__c = FALSE and conga_product__c != null 
                         and material_type__c = 'PRODUCT' and Line_Status__c != :Label.Conga_Quote_Line_Status
                         and (NOT Product__r.name like '%LEASE BUYOUT%')
                         and (NOT Product__r.name like '%RENEWAL%')
                         AND ((Product__r.DW_Product_Type__c = 'Subscription' AND customer_price__c = 0.00 AND Contract_List_Price__c = 0.00) OR (customer_price__c > 0 OR Contract_List_Price__c > 0))
                         group by Conga_product__c]; //soumyad changed query sf-bug 964 & 965 /*IBA-4731 Query Updated AC*/
        }else{
            quantityub = [select Conga_product__c prdc,sum(Quantity__c) qty,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price_Recalculate__c) lst,Sum(Customer_Price_Recalculate__c) cst,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,sum(USA_List_Price_Recalculate__c) usa
                          from Quote_Line__c 
                          where Quote__c =:qId and conga_product__c != null and Line_Status__c != :Label.Conga_Quote_Line_Status
                          and (NOT Product__r.name like '%LEASE BUYOUT%')
                          and (NOT Product__r.name like '%RENEWAL%')
                          and (customer_price__c>0 OR (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null))
                              or (customer_price__c = 0 and material_type__c = 'PRODUCT'))//Added or conditions by sravan for products unbundled on feb 17
                          group by Conga_product__c]; //soumyad changed query sf-bug 964 & 965 //Removed  "OR (material_type__c = 'SERVICE')" for IBA-2283
        }	
        //Added by Sravan for SF-BUG-528 END
        /////////////////soumyad sf-bug-631 chagned field in the query for totalz calculation
        AggregateResult[] ql1 = [select sum(Conga_Extended_price_summbypar__c)totalz,sum(Conga_Unit_Services_Material_Type__c)totalserv,sum(Conga_Unit_Price_by_Par__c) extmat,sum(Conga_unit_services_by_par__c) extserv,par_location__c par
                                 from Quote_Line__c 
                                 where Quote__c =:qId
                                 and Conga_Product1__c != null 
                                 and (NOT Conga_Product1__c like 'Fr%')  
                                 and (NOT Conga_Product1__c like '%SV')
                                 and (NOT Conga_Product1__c like '%RENEWAL%') 
                                 and part_of_a_bundle__c  = FALSE
                                 and Line_Status__c != :Label.Conga_Quote_Line_Status
                                 group by par_location__c]; 
        Integer qlsize1 = ql1.size();
        ////////////////////////
        //soumyad start 1071
        Map<decimal,list<quote_line__c>> linemapq = new Map<decimal,list<quote_line__c>>();
        
        for(quote_line__c s : qli)
        {
            
            if(linemapq.containsKey(s.Higher_Level_Item__c)){
                List<quote_line__c> proList=linemapq.get(s.Higher_Level_Item__c);
                proList.add(s);
                linemapq.put(s.Higher_Level_Item__c, proList);
            }
            else{
                linemapq.put(s.Higher_Level_Item__c, new List<quote_line__c>{s});
            }
        }                
        
        Map<String,Decimal> mapaggtotal = new Map<String,Decimal>();
        for(AggregateResult aggResult : ql1)
        {
            mapaggtotal.put((String)aggResult.get('par'), (Decimal)aggResult.get('totalz'));
        }
        //soumyad end 1071
        
        if(!isProductsUnbundled){//Added by Sravan for SF-BUG-528 this piece of block will not execute when user selects Display Products unbundled option
            for(Integer i=0;i<quantity1.size();i++){
                Boolean groupedcheck = false;
                Integer sapnum = Integer.valueof(quantity1[i].get('hli'));
                String prddesc = '';
                list<quote_line__c> qqli = linemapq.get(sapnum); //soumyad 1071
                if(qqli != null){
                for(Quote_Line__c q : qqli){ //soumyad 1071 change var name
                    system.debug('****1	'+q.CONGA_PRODUCT1__c);
                    q.Conga_Generic_Drawer_Grouped__c = false;
                    if(q.Higher_Level_Item__c == sapnum){
                        if(q.Part_of_a_Bundle__c == true && q.Skip_rollup_text__c == false) // soumyad changed logic to skip the solutions included sf-bug 964 & 965
                            prddesc = prddesc+'*'+q.Conga_Product_Description__c+'\n';
                    }
                }
                }
                if(linemapq1.get(sapnum)!= null && sapnum != null){
                    Quote_Line__c q = linemapq1.get(sapnum);//Added by Sravan for quote print optimisation
                    system.debug('****1	new'+q.CONGA_PRODUCT1__c);
                    q.conga_grouped_product__c = false;
                    system.debug('****solutions b'+q.conga_solution_includes__c);
                    if(q.sap_line_number__c == sapnum){
                        if(prddesc != '' && prddesc != null && q.Skip_rollup_text__c == false){ // soumyad changed logic to skip the solutions included sf-bug 964 & 965
                            q.conga_solution_includes__c = '*'+q.Conga_Product_Description__c+'\n'+prddesc;
                        }
                        else
                            q.conga_solution_includes__c='';
                        system.debug('****solutions a'+q.conga_solution_includes__c);
                        q.Conga_part_of_bundle_true__c = true;
                        q.conga_grouped_product__c = true;
                        q.Conga_part_of_bundle_check__c = true;
                        q.Conga_Quantity_Update__c = true;
                        if((Decimal)quantity1[i].get('lst') != null && q.Contract_List_Price__c!= null)
                            q.Conga_List_Price__c = (Decimal)quantity1[i].get('lst') + q.Contract_List_Price__c;
                        else if((Decimal)quantity1[i].get('lst') != null && q.Contract_List_Price__c == null && q.zero_header__c == true){ // soumyad sf-bug- 964 & 965 added else if
                            q.Contract_List_Price__c=0;
                            q.Conga_List_Price__c = (Decimal)quantity1[i].get('lst') + q.Contract_List_Price__c;
                        }else
                            q.Conga_List_Price__c = 0;
                        if((Decimal)quantity1[i].get('cst') != null)
                            q.Conga_Unit_Price__c = (Decimal)quantity1[i].get('cst');
                        else
                            q.Conga_Unit_Price__c = 0;
                        if((Decimal)quantity1[i].get('extp') != null)
                            q.Conga_Total_Price__c = (Decimal)quantity1[i].get('extp');
                        else
                            q.Conga_Total_Price__c = 0;
                        if((Decimal)quantity1[i].get('cusmt') != null)
                            q.Conga_Unit_Services__c = (Decimal)quantity1[i].get('cusmt');
                        else
                            q.Conga_Unit_Services__c = 0;
                        if((Decimal)quantity1[i].get('exts') != null)
                            q.Conga_Extended_Services__c = (Decimal)quantity1[i].get('exts');
                        else
                            q.Conga_Extended_Services__c = 0;
                        if((Decimal)quantity1[i].get('usa') != null && q.USA_List_Price__c != null)
                            q.Conga1_USA_List_Price__c = (Decimal)quantity1[i].get('usa') + q.USA_List_Price__c;
                        else if(q.zero_header__c == true &&(Decimal)quantity1[i].get('usa') != null && q.USA_List_Price__c == null){ // soumyad sf-bug- 964 & 965 added else if
                            q.USA_List_Price__c = 0;
                            q.Conga1_USA_List_Price__c = (Decimal)quantity1[i].get('usa') + q.USA_List_Price__c;
                        }else
                            q.Conga1_USA_List_Price__c = 0;
                     	//IBA-3867(4626) Changes Abhrajitc
                        if(q.CurrencyIsoCode == 'GBP' && q.Quote__r.SAP_Sales_Org__r.Sales_Org__c == 'OM31'){
                            //q.Conga_Extended_Price_Materials__c= (Decimal)quantity1[i].get('cst'); /*IBA-4780 AC: Commented out this line*/
                            q.Conga_Extended_Price_Materials__c= (Decimal)quantity1[i].get('intlepst'); /*IBA-4780 AC: Change*/
                        }else if((Decimal)quantity1[i].get('epst') != null && q.CurrencyIsoCode != 'GBP' && q.Quote__r.SAP_Sales_Org__r.Sales_Org__c != 'OM31'){
                            q.Conga_Extended_Price_Materials__c= (Decimal)quantity1[i].get('epst');
                            System.debug('@developer-->'+q.Conga_Extended_Price_Materials__c);
                        }else
                            q.Conga_Extended_Price_Materials__c= 0;
                        //IBA-3867(4626) Changes Abhrajitc
                        if(q.Conga_Quantity__c!=null){
                            q.Conga_Quantity__c = q.Conga_Quantity__c+q.Quantity__c;
                        }
                        else 
                        {
                            q.Conga_Quantity__c = q.Quantity__c;
                        }
                        if(q.Customer_Price__c != null && q.Part_of_a_Bundle__c == false) //Added part of a  bundle condition by sravan for SF-BUG-539
                            q.Conga_Unit_Price__c = q.Conga_Unit_Price__c+q.Customer_Price__c;
                        if(q.Extended_Price__c != null && q.Part_of_a_Bundle__c == false) //Added part of a  bundle condition by sravan for SF-BUG-539
                            q.Conga_Total_Price__c = q.Conga_Total_Price__c+q.Extended_Price__c;
                        if(q.Conga_Unit_Services_Material_Type__c != null && q.Part_of_a_Bundle__c == false) //Added part of a  bundle condition by sravan for SF-BUG-539
                            q.Conga_Unit_Services__c = q.Conga_Unit_Services__c+q.Conga_Unit_Services_Material_Type__c;
                        //if(q.Extended_Services__c != null && q.Part_of_a_Bundle__c == false)
                        if(q.Cong_Extended_Price_Material_type__c != null && q.Part_of_a_Bundle__c == false) //Added part of a  bundle condition by sravan for SF-BUG-539
                            q.Conga_Extended_Price_Materials__c = q.Conga_Extended_Price_Materials__c+q.Cong_Extended_Price_Material_type__c;
                        // soumyad sf-bug-631 start
                        if(partrue || pardettrue){
                            // soumyad sf-bug-1071 start
                                Decimal ql11 = mapaggtotal.get(q.par_location__c);
                                if(ql11 != null){
                                    q.Total_Monthly_Product_by_Location__c = ql11;  
                                }
                            // soumyad sf-bug-1071 end
                        }
                        // soumyad sf-bug-631 end
                        if(!linestoupdate.contains(q))
                            linestoupdate.add(q);
                    }
                }
                system.debug('****after 1	'+linestoupdate);
            }
            for(Integer i=0;i<quantity2.size();i++){
                String prcode;
                prcode = (String)quantity2[i].get('prdc');
                List<Quote_Line__c> qlList = linemapq2.get(prcode);//Added by Sravan for quote print optimisation
                Boolean groupedcheck = false;
                if(qlList != null && !qlList.isempty()){
                    for(Quote_Line__c q : qlList){
                        system.debug('****2	'+q.CONGA_PRODUCT1__c);
                        if (q.Customer_Price__c > 0 || (q.Product__r.DW_Product_Type__c != null && q.Product__r.DW_Product_Type__c.contains('Subscription') && q.Product__r.Name.contains('INT'))){//Added by sravan for quantity fix oct 31 /*IBA-4731 Change AC*/
                            if (q.Resend_to_SAP__c) {
                                q.Resend_to_SAP__c=false;
                            }
                            if(q.Product__r.Product_Type__c == 'Std Config Omnicell Install')		
                            {		
                                q.Conga1_USA_List_Price__c = q.USA_List_Price__c;		
                            }
                            if(q.Product__r.Name == 'RENEWAL')		
                            {		
                                continue;		
                            }
                            boolean serviceprd = false;
                            if(q.conga_product1__c != null){
                                if (((q.Conga_Product1__c.contains('-sv') || q.Conga_Product1__c.contains('-SV')) && q.material_type__c == 'SERVICE') || (q.Customer_Price__c == 0 && !(q.Product__r.DW_Product_Type__c != null && q.Product__r.DW_Product_Type__c.contains('Subscription') && q.Product__r.Name.contains('INT')))){  /*IBA-4731 Change AC*/
                                    serviceprd = true;
                                }
                            }
                            if(q.Conga_Product1__c == prcode && q.part_of_a_bundle__c == false){
                                if(groupedcheck == false ){
                                    if(serviceprd == false){
                                        q.conga_grouped_product__c = true;
                                        groupedcheck = true;
                                    }
                                    else{
                                        q.conga_grouped_product__c = false;
                                        serviceprd = false;
                                    }
                                }
                                else{
                                    q.conga_grouped_product__c = false;
                                }
                                if(q.Conga_part_of_bundle_check__c == false)
                                    q.Conga_List_Price__c = (Decimal)quantity2[i].get('lst');
                                if(q.Conga_part_of_bundle_check__c == false)
                                    q.Conga_Unit_Price__c = q.Customer_Price__c;
                                if(q.Conga_part_of_bundle_check__c == false)
                                    q.Conga_Total_Price__c = (Decimal)quantity2[i].get('extp');
                                q.Conga_Unit_Services__c = (Decimal)quantity2[i].get('cusmt');
                                if(q.higher_level_item__c == 0 || isProductsUnbundled)
                                    q.Conga_Extended_Services__c = (Decimal)quantity2[i].get('exts');
                                if(q.Conga_part_of_bundle_check__c == false){
                                    q.Conga1_USA_List_Price__c = q.USA_List_Price__c;
                                }
                                if(q.Conga_part_of_bundle_check__c == FALSE){
                                    if(q.CurrencyIsoCode == 'GBP' && q.Quote__r.SAP_Sales_Org__r.Sales_Org__c == 'OM31'){ //IBA-3867(4626) Changes Abhrajitc
                                        q.Conga_Extended_Price_Materials__c = (q.Customer_Price__c * (Decimal)quantity2[i].get('qty')); //IBA-3867 (4626) Adding customer price to capture the extended price here
                                    }else{
                                        q.Conga_Extended_Price_Materials__c= (Decimal)quantity2[i].get('epst');
                                    }
                                    System.debug('@developer-->'+q.Conga_Extended_Price_Materials__c);
                                }
                                //soumyad start 964 & 965
                                /*if(q.zero_header__c == true){
                                if(q.Conga_Quantity__c!=null){
                                    q.Conga_Quantity__c = q.Conga_Quantity__c+q.Quantity__c;
                                }
                                else 
                                {
                                    q.Conga_Quantity__c = q.Quantity__c;
                                }
                                }*/
                                //soumyad end 964 & 965
                                
                                // soumyad sf-bug-631 start
                                if(partrue || pardettrue){
                                    // soumyad sf-bug-1071 start
                                    Decimal ql11 = mapaggtotal.get(q.par_location__c);
                                    if(ql11 != null){
                                        q.Total_Monthly_Product_by_Location__c = ql11;  
                                    }
                                    // soumyad sf-bug-1071 end
                                }
                                // soumyad sf-bug-631 end
                                if(!linestoupdate.contains(q))
                                    linestoupdate.add(q);
                            }    
                        }//Added by sravan for quantity fix oct 31
                    }
                }
            }
        }//Added by Sravan for SF-BUG-528 END
        //Added by Sravan for SF-BUG-528 START
        else{
            for(Integer i=0;i<quantityub.size();i++){
                String prcode;
                prcode = (String)quantityub[i].get('prdc');
                List<Quote_Line__c> qlList = linemapq2.get(prcode);//Added by Sravan for quote print optimisation
                List<Quote_line__c> servcount = linemapq4.get(prcode);
                Decimal countQty = qtyMap.get(prcode); //IBA-1606
                List<Quote_line__c> servcounthigher = linemapq5.get(prcode);
                Boolean groupedcheck = false;
                if(qlList != null && !qlList.isempty()){
                    for(Quote_Line__c q : qlList){
                        if (q.Resend_to_SAP__c) {
                            q.Resend_to_SAP__c=false;
                        }
                        if(q.Product__r.Product_Type__c == 'Std Config Omnicell Install')			
                        {		
                            q.Conga1_USA_List_Price__c = q.USA_List_Price__c;		
                        }
                        if(q.Product__r.Name == 'RENEWAL')		
                        {		
                            continue;		
                        }
                        boolean serviceprd = false;
                        if(q.conga_product1__c != null){
                            if(q.Conga_Product1__c.contains('-sv')||q.Conga_Product1__c.contains('-SV') && q.material_type__c=='SERVICE')
                                serviceprd = true;
                        }
                        if(q.Conga_Product1__c == prcode){
                            if(groupedcheck == false ){
                                if(serviceprd == false){
                                    if(q.customer_price__c != 0 || servcounthigher != null){//Added by sravan on 13 FEB for products unbundled issue
                                    q.conga_grouped_product__c = true;
                                    groupedcheck = true;
                                    }
                                }
                                else{
                                    q.conga_grouped_product__c = false;
                                    serviceprd = false;
                                }
                            }
                            else{
                                q.conga_grouped_product__c = false;
                            }
                            //IBA-1606 START
                          //  if(q.Part_of_a_Bundle__c == true){
                            if(servcount != null) {
                               // q.Conga_Quantity__c = (Decimal)quantityub[i].get('qty') - servcount.size();
                               	q.Conga_Quantity__c = (Decimal)quantityub[i].get('qty') - countQty;
                            }  
                            else {
                                q.Conga_Quantity__c = (Decimal)quantityub[i].get('qty');
                            } 
                            // }
                            //IBA-1606 END
                            q.Conga_List_Price__c = (Decimal)quantityub[i].get('lst');
                            q.Conga_Unit_Price__c = q.Customer_Price__c;
                            q.Conga_Total_Price__c = (Decimal)quantityub[i].get('extp');
                            //Added by sravan on 13 FEB for products unbundled issue START
                            if(servcounthigher != null){
                                Decimal servamt = 0;
                                for(Quote_Line__c qlserv : servcounthigher){
                                    servamt = servamt+qlserv.Extended_Services__c;
                                }
                            	q.Conga_Extended_Services__c= servamt;
                                q.Conga_Unit_Services__c= servamt;
                            }
                            else{
                                q.Conga_Extended_Services__c= (Decimal)quantityub[i].get('cusmt');
                                q.Conga_Unit_Services__c = (Decimal)quantityub[i].get('cusmt');
                            }
                            //q.Conga_Unit_Services__c = (Decimal)quantityub[i].get('cusmt');
                            //q.Conga_Extended_Services__c = (Decimal)quantityub[i].get('cusmt');
                            //Added by sravan on 13 FEB for products unbundled issue END
                            q.Conga1_USA_List_Price__c = q.USA_List_Price__c;
                            if(servcount != null){
                                Decimal servamt = 0;
                                for(Quote_Line__c qlserv : servcount){
                                    servamt = servamt+qlserv.Cong_Extended_Price_Material_type__c;
                                }
                            	q.Conga_Extended_Price_Materials__c= (Decimal)quantityub[i].get('epst') - servamt;
                            }
                            else
                                q.Conga_Extended_Price_Materials__c= (Decimal)quantityub[i].get('epst');
                            // soumyad sf-bug-631 start
                            if(partrue || pardettrue){
                                // soumyad sf-bug-1071 start
                                Decimal ql11 = mapaggtotal.get(q.par_location__c);
                                if(ql11 != null){
                                    q.Total_Monthly_Product_by_Location__c = ql11;  
                                }
                                // soumyad sf-bug-1071 end
                            }
                            // soumyad sf-bug-631 end
                            if(!linestoupdate.contains(q))
                                linestoupdate.add(q);
                        }    
                    } 
                }
            }
        }//Added by Sravan for SF-BUG-528 END
        
        
        
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        Map<Id,Quote_Line__c> linesmaptoupdate = new Map<Id,Quote_Line__c>();
        for(Quote_Line__c qlitem : linestoupdate){
            system.debug('conga total product by loc : '+qlitem.Conga_Total_Product_by_Location__c);
            linesmaptoupdate.put(qlitem.id,qlitem);
        }
        //update linestoupdate;
        system.debug('********	'+linesmaptoupdate);
        QuoteLineTriggerHandler.fromprint = true;
        update linesmaptoupdate.values();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END  
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            //Added zerodollar for SF-BUG-725
            QuotePrintProcess_Batch_2_Of_6 b = new QuotePrintProcess_Batch_2_Of_6(qId,pardettrue,isGenericDrawer,isProductsUnbundled,zerodollar);//Added isProductsUnbundled by Sravan for SF-BUG-528 START
            database.executeBatch(b);
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