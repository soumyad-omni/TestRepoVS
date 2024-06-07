public class Quoteline_compare {
    //This method is to compare the quote line items from SAP to SFDC
    public class comparewrapper{
        @AuraEnabled public list<subcomparewrapper> lstsubcompare{get;set;}
        @AuraEnabled public string message{get;set;}
        @AuraEnabled public boolean isFieldmatch{get;set;}
        
        
        public comparewrapper(list<subcomparewrapper> lstsubcompare, string message, boolean isFieldmatch ){
            this.lstsubcompare = lstsubcompare;
            this.message=message;
            this.isFieldmatch = isFieldmatch;
        }
    }
    
    public class subcomparewrapper{
        @AuraEnabled public string Source{get;set;}
        @AuraEnabled public string Product{get;set;}
        @AuraEnabled public string Qty{get;set;}
        @AuraEnabled public string Contract_List_Price{get;set;}
        @AuraEnabled public string Unit_Price{get;set;}
        @AuraEnabled public string Extended_Price{get;set;}
        @AuraEnabled public string Unit_Services{get;set;}
        @AuraEnabled public string Extended_Services{get;set;}
        @AuraEnabled public string isRenewal{get;set;}
        
        public subcomparewrapper(string Source, string Product, string Qty, string Contract_List_Price, string Unit_Price, string Extended_Price, string Unit_Services, String Extended_Services, string isRenewal){
            this.Source =Source;
            this.Product = Product;
            this.Qty=Qty;
            this.Contract_List_Price=Contract_List_Price;
            this.Unit_Price=Unit_Price;
            this.Extended_Price=Extended_Price;
            this.Unit_Services=Unit_Services;
            this.Extended_Services=Extended_Services;
            this.isRenewal=isRenewal;
        }
    }
    
    
    
    @AuraEnabled
    Public static comparewrapper compareQuoteLine(String recordID){
        List<subcomparewrapper> subcompwrap = new List<subcomparewrapper>();
        try{
        Quote quot = [select id, name, Quote_Number__c from Quote where ID =:recordID];
       Quote_Print_Status__c quoteprintStatus= [Select Id, Name, Revision_Number__c,Quote__r.Quote_Revision__c, Generic_Drawer__c, Quote__c,print_status__c from Quote_Print_Status__c where Quote__c =: recordID];
        string quotenumber = quot.Quote_Number__c;
      boolean genericDrawer = quoteprintStatus.Generic_Drawer__c;
        system.debug('**************'+genericDrawer);
        Map<String, Object> jsondata = new Map<String, Object> {'Quote_Number__c' => quotenumber, 'Generic_Drawer__c'=>genericDrawer};
            String jsonstrinsert = JSON.serialize(jsondata);
        //soumyad start sf-bug-765
        //final string comp_creds = 'Compare Creds';
        //Compare_Integration_Creds__c compCreds = Compare_Integration_Creds__c.getInstance(comp_creds);
        final string comp_creds1 = 'CastIronIntegration';
        //CastIronIntegration__c cstint = CastIronIntegration__c.getInstance(comp_creds1);
        String EndPoint1;
            
        //String EndPoint1 = compCreds.Endpoint__c;
        list<CastIronIntegration__c> cstint = [select compare_button_endpoint__c, compare_button_timeout__c from CastIronIntegration__c limit 1];
        for(CastIronIntegration__c c:cstint){
           endPoint1 = c.compare_button_endpoint__c;
            
        }
        Integer timeout = 120000;
        //soumyad end sf-bug-765
        Http h2= new Http();
        HttpRequest req2= new HttpRequest();
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept','application/json');
        system.debug('sending json for creating quote line: ' + jsonstrinsert); 
        req2.setBody(jsonstrinsert);
        req2.setMethod('POST');
        req2.setEndpoint(EndPoint1);
        req2.setTimeout(timeout); 
        HttpResponse res2=h2.send(req2);
        System.debug(res2+'###123createresp');
        system.debug('res2.getBody()..'+res2.getBody());
        
        
        String message = '';
        
        Map<String, Object> level1 = (Map<String, Object>)JSON.deserializeUntyped(res2.getBody());
        for(String s : level1.keyset()){
            System.debug('level 1 : '+s+' : '+level1.get(s));
        }
        Map<Integer, Map<String, Object>> myMaps = new Map<Integer, Map<String, Object>>();
        List<Object> level2list = (List<Object>) level1.get('Quote_Line__c');
        string Itemcount = (string)level1.get('Item_Count');
        if(Itemcount == null){
            Itemcount = '0';
        }
        //system.debug('Total no of records in SAP: '+level2list.size());
        Integer sapQuoteLinecount = 0;
        if(level2list != null){ //added by sravan on 23 AUG
        	sapQuoteLinecount = level2list.size();
        	for(Integer i=0;i<level2list.size();i++){
            	myMaps.put(i, (Map<String, Object>)level2list[i]);
            	system.debug('myMaps: '+myMaps);
        	}
        }
        // IBA-5789 start
        List<Zero_Dollar_Product__c> zdProd = [SELECT Name FROM Zero_Dollar_Product__c];
        Set<string> zeroDProd = new Set<string>();
        for(Zero_Dollar_Product__c zdp : zdProd){
            zeroDProd.add(zdp.Name);
        }
        // IBA-5789 end
        Boolean  isRevision = false;
        Map<Id, Quote_Print_Status__c> qpsmap = new Map<Id, Quote_Print_Status__c>([Select Id, Name, Revision_Number__c,Quote__r.Quote_Revision__c,  Quote__c from Quote_Print_Status__c where Quote__c =: recordID]);
        // soumyad start sf-bug-765
        
        //Map<Id, Quote_Line__c> qline = new Map<Id, Quote_Line__c>([SELECT QT_Print_Flag__c, Is_Lease_buyout__c, IFRenewalProduct__c, QT_Print_Exchange_Rate__c, Contract_List_Price__c, QT_CONGA1_USA_LIST_PRICE__c,QT_USA_LIST_PRICE__c,QT_CONGA_LIST_PRICE__c,QT_Conga_List_Price1__c,QT_CONGA_UNIT_PRICE__c,QT_CONGA_EXTENDED_PRICE_MATERIALS__c,QT_Conga_Unit_Services__c,QT_Conga_Extended_Services__c,Higher_Level_Item__c,USA_List_Price__c,Cong_Extended_Price_Material_type__c,Conga2_USA_List_Price__c,Conga_List_Price1__c,Conga_Solution_Includes__c,Conga_part_of_bundle_true__c,Conga_Unit_Services_Material_Type__c,Conga_Unit_Service_by_location__c,Conga_Unit_Price_by_Location__c,Total_Monthly_Product_by_Location__c,Total_Monthly_Support_Services_by_Locati__c,Par_Location_Monthly_Total__c, Quote__r.Conga_Grand_Total_Monthly__c,Quote__r.Conga_Total_Monthly_Product__c,Quote__r.Conga_Total_Monthly_Support_Services__c,Conga_Total_Product_by_Par_Monthly__c,Conga_Total_Service_by_Par_Monthly__c, Conga_Par_Location_Total__c, Conga_Extended_Price_Materials__c,Conga_Product_Description__c,Conga1_USA_List_Price__c,Conga_List_Price__c ,Conga_Unit_Price__c ,Conga_Extended_Services__c ,Conga_Unit_Services__c ,Conga_Total_Price__c ,Conga_Product1__c, Quote__r.Conga_Order_Type__c,Conga_Grouped_Product__c,conga_quantity__c,Conga_Picture_URL__c,Extended_Services__c,Conga_Total_Product_by_Location__c,Conga_Total_Shipping_and_Handling__c, Conga_Total_Support_Services_by_Location__c , Quote__r.ExpirationDate,Conga_USA_Price_List__c,Quote__r.Status,Product__r.Description, Quote__r.Supplement1__c,Product__r.Family, Product__r.Id, Product__r.Name, Product__r.ProductCode, Quote__r.Id, Customer_Price__c, Discount_Amount__c, Extended_Price__c, Generic_Drawer__c, Line_Item_Description__c, List_Price__c, Name, Part_of_a_Bundle__c, Par_Location__c,Picture_URL__c, Pricing_Reference_Model__c, Product__c, Product_Code__c, Product_Cost__c, Product_Line_for_this_Service__c, Quantity__c, Quote__c, Quote_Line_Item_Type__c, Sales_Text__c, SAP_Line_Number__c, Serial_Number__c, Quote__r.From__c,Total_Cost__c,Conga_Renewal_Extended_Services__c,Conga_Renewal_Unit_Services__c FROM Quote_Line__c WHERE Quote__r.Id =: recordID and ( Customer_Price__c > 0 OR Usa_List_price__c > 0 OR Conga_Extended_Services__c >0 OR Conga_Renewal_Extended_Services__c > 0 OR Product__r.DW_Product_Class__c = 'Training') and ((Conga_Grouped_Product__c=true and Generic_Drawer_Product__c = null) OR (Conga_Renewal_Grouped_Product__c=true and Generic_Drawer_Product__c = null) OR Conga_Generic_Drawer_Grouped__c = true or ( Is_Lease_Buyout__c = true and conga_quantity__c > 0 and Generic_Drawer_Product__c = null) or Product__r.DW_Product_Class__c = 'Training' ) and Conga_Product1__c != null and (NOT Conga_Product1__c like 'Fr%') and (NOT Conga_Product1__c like '%SV') and Is_Conga_Exclude_Product__c = false order by CONGA_PRODUCT1__c asc]);
        
        // Debasis start IBA-4172
          /* Map<Id, Quote_Line__c> qline = new Map<Id, Quote_Line__c>([SELECT QT_Print_Flag__c, Is_Lease_buyout__c, IFRenewalProduct__c, QT_Print_Exchange_Rate__c, Contract_List_Price__c, QT_CONGA1_USA_LIST_PRICE__c,QT_USA_LIST_PRICE__c,QT_CONGA_LIST_PRICE__c,QT_Conga_List_Price1__c,QT_CONGA_UNIT_PRICE__c,QT_CONGA_EXTENDED_PRICE_MATERIALS__c,QT_Conga_Unit_Services__c,QT_Conga_Extended_Services__c,Higher_Level_Item__c,USA_List_Price__c,Cong_Extended_Price_Material_type__c,Conga2_USA_List_Price__c,Conga_List_Price1__c,Conga_Solution_Includes__c,Conga_part_of_bundle_true__c,Conga_Unit_Services_Material_Type__c,Conga_Unit_Service_by_location__c,Conga_Unit_Price_by_Location__c,Total_Monthly_Product_by_Location__c,Total_Monthly_Support_Services_by_Locati__c,Par_Location_Monthly_Total__c, Quote__r.Conga_Grand_Total_Monthly__c,Quote__r.Conga_Total_Monthly_Product__c,Quote__r.Conga_Total_Monthly_Support_Services__c,Conga_Total_Product_by_Par_Monthly__c,Conga_Total_Service_by_Par_Monthly__c, Conga_Par_Location_Total__c, Conga_Extended_Price_Materials__c,Conga_Product_Description__c,Conga1_USA_List_Price__c,Conga_List_Price__c ,Conga_Unit_Price__c ,Conga_Extended_Services__c ,Conga_Unit_Services__c ,Conga_Total_Price__c ,Conga_Product1__c, Quote__r.Conga_Order_Type__c,Conga_Grouped_Product__c,conga_quantity__c,Conga_Picture_URL__c,Extended_Services__c,Conga_Total_Product_by_Location__c,Conga_Total_Shipping_and_Handling__c, Conga_Total_Support_Services_by_Location__c , Quote__r.ExpirationDate,Conga_USA_Price_List__c,Quote__r.Status,Product__r.Description, Quote__r.Supplement1__c,Product__r.Family, Product__r.Id, Product__r.Name, Product__r.ProductCode, Quote__r.Id, Customer_Price__c, Discount_Amount__c, Extended_Price__c, Generic_Drawer__c, Line_Item_Description__c, List_Price__c, Name, Part_of_a_Bundle__c, Par_Location__c,Picture_URL__c, Pricing_Reference_Model__c, Product__c, Product_Code__c, Product_Cost__c, Product_Line_for_this_Service__c, Quantity__c, Quote__c, Quote_Line_Item_Type__c, Sales_Text__c, SAP_Line_Number__c, Serial_Number__c, Quote__r.From__c,Total_Cost__c,Conga_Renewal_Extended_Services__c,Conga_Renewal_Unit_Services__c FROM Quote_Line__c WHERE Quote__r.Id =: recordID AND ( customer_price__c > 0 OR usa_list_price__c > 0 OR conga_extended_services__c > 0 OR conga_renewal_extended_services__c > 0 OR product__r.dw_product_class__c = 'Training' OR ( conga_grouped_product__c = true AND free_month_applied__c = true ) OR zero_header__c = true OR ( discount_percent__c = -100 AND conga_quantity__c > 0 AND contract_list_price__c > 0 AND Pricing_Reference_Model__r.Name != null AND generic_drawer_product__c = NULL AND print_discounted_items__c = true ))
									AND ( ( conga_grouped_product__c = true AND generic_drawer_product__c = NULL ) OR ( conga_renewal_grouped_product__c = true AND generic_drawer_product__c = NULL ) OR conga_generic_drawer_grouped__c = true OR ( is_lease_buyout__c = true AND conga_quantity__c > 0 AND generic_drawer_product__c = NULL ) OR product__r.dw_product_class__c = 'Training' OR zero_header__c = true OR ( discount_percent__c = -100 AND conga_quantity__c > 0 AND contract_list_price__c > 0 AND Pricing_Reference_Model__r.Name != null AND generic_drawer_product__c = NULL AND print_discounted_items__c = true) OR ( discount_percent__c = -100 AND higher_level_item__c = 0 AND generic_drawer_product__c = NULL AND print_discounted_items__c = true ) OR ( discount_amount__c < 0 AND contract_list_price__c > 0 AND higher_level_item__c = 0 AND amount_discount_to_zero__c = true ) )
 									AND conga_product1__c != NULL AND ( NOT conga_product1__c LIKE 'Fr%' ) AND ( NOT conga_product1__c LIKE '%SV' ) AND is_conga_exclude_product__c = false ORDER BY conga_product1__c ASC]);
		*/
      Map<Id, Quote_Line__c> qline = new Map<Id, Quote_Line__c>([SELECT QT_Print_Flag__c, Is_Lease_buyout__c, IFRenewalProduct__c, QT_Print_Exchange_Rate__c, Contract_List_Price__c, QT_CONGA1_USA_LIST_PRICE__c, 
			QT_USA_LIST_PRICE__c,QT_CONGA_LIST_PRICE__c,QT_Conga_List_Price1__c,QT_CONGA_UNIT_PRICE__c,QT_CONGA_EXTENDED_PRICE_MATERIALS__c,QT_Conga_Unit_Services__c,
			QT_Conga_Extended_Services__c,Higher_Level_Item__c,USA_List_Price__c,Cong_Extended_Price_Material_type__c,Conga2_USA_List_Price__c,Conga_List_Price1__c,
			Conga_Solution_Includes__c,Conga_part_of_bundle_true__c,Conga_Unit_Services_Material_Type__c,Conga_Unit_Service_by_location__c,Conga_Unit_Price_by_Location__c,
			Total_Monthly_Product_by_Location__c,Total_Monthly_Support_Services_by_Locati__c,Par_Location_Monthly_Total__c, Quote__r.Conga_Grand_Total_Monthly__c, 
			Quote__r.Conga_Total_Monthly_Product__c,Quote__r.Conga_Total_Monthly_Support_Services__c,Conga_Total_Product_by_Par_Monthly__c,
			Conga_Total_Service_by_Par_Monthly__c, Conga_Par_Location_Total__c, Conga_Extended_Price_Materials__c, Conga_Product_Description__c, Conga1_USA_List_Price__c, 
			Conga_List_Price__c, Conga_Unit_Price__c, Conga_Extended_Services__c, Conga_Unit_Services__c ,Conga_Total_Price__c, Conga_Product1__c, Quote__r.Conga_Order_Type__c, 
			Conga_Grouped_Product__c,conga_quantity__c,Conga_Picture_URL__c,Extended_Services__c,Conga_Total_Product_by_Location__c,Conga_Total_Shipping_and_Handling__c, 
			Conga_Total_Support_Services_by_Location__c , Quote__r.ExpirationDate,Conga_USA_Price_List__c,Quote__r.Status,Product__r.Description, Quote__r.Supplement1__c, 
			Product__r.Family, Product__r.Id, Product__r.Name, Product__r.ProductCode, Quote__r.Id, Customer_Price__c, Discount_Amount__c, Extended_Price__c, Generic_Drawer__c, 
			Line_Item_Description__c, List_Price__c, Name, Part_of_a_Bundle__c, Par_Location__c,Picture_URL__c, Pricing_Reference_Model__c, Product__c, Product_Code__c, 
			Product_Cost__c, Product_Line_for_this_Service__c, Quantity__c, Quote__c, Quote_Line_Item_Type__c, Sales_Text__c, SAP_Line_Number__c, Serial_Number__c, Quote__r.From__c,Total_Cost__c,Conga_Renewal_Extended_Services__c,Conga_Renewal_Unit_Services__c 
		FROM Quote_Line__c 
		WHERE quote__r.id =: recordID
		AND ( product_code__c Like 'OCE%' OR customer_price__c > 0 OR usa_list_price__c > 0 OR conga_extended_services__c > 0 OR conga_renewal_extended_services__c > 0
			OR ( contract_list_price__c > 0 AND customer_price__c = 0 AND part_of_a_bundle__c = false )
			OR ( conga_grouped_product__c = true AND free_month_applied__c = true )
			OR (zero_header__c = true AND conga_grouped_product__c = true))
		AND ( (product_code__c Like 'OCE%' AND Higher_level_item__c = 0 ) OR ( conga_grouped_product__c = true AND generic_drawer_product__c = NULL )
			OR ( conga_renewal_grouped_product__c = true AND generic_drawer_product__c = NULL ) OR conga_generic_drawer_grouped__c = true
			OR ( is_lease_buyout__c = true AND conga_quantity__c > 0 AND generic_drawer_product__c = NULL ) OR zero_header__c = true
			OR ( discount_percent__c = -100 AND generic_drawer_product__c = NULL AND part_of_a_bundle__c = false AND print_discounted_items__c = true )
			OR ( contract_list_price__c > 0 AND customer_price__c = 0 AND part_of_a_bundle__c = false AND generic_drawer_product__c = NULL AND print_discounted_items__c = true )
			OR ( discount_amount__c < 0 AND contract_list_price__c > 0 AND higher_level_item__c = 0 AND amount_discount_to_zero__c = true ) )
		AND conga_product1__c != NULL AND ( NOT conga_product1__c LIKE 'Fr%' ) AND ( NOT conga_product1__c LIKE '%SV' ) 
		AND is_conga_exclude_product__c = false AND Line_Status__c !='E0006' AND (NOT product_code__c IN :zeroDProd ) // IBA-5789
		ORDER BY conga_product1__c ASC]);
        // Debasis end IBA-4172
        // soumyad end sf-bug-765
        system.debug('Total number of records in SFDC: '+qline.size());
        double sfdcQuotelinecount = qline.size();
        System.debug('qline.values()'+qline.values());
        string sfdcjson = JSON.serialize(qline.values());
        for(sObject obj: qline.values()){
            Map<String, Object> sfdcjsondeserilise = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj)); 
            system.debug('sfdcjson: '+sfdcjsondeserilise);
            system.debug('sfdcjsondeserilised: '+sfdcjsondeserilise.get('Conga_Quantity__c'));
            
        }
        Map<Id, Quote> quotemap = new Map<Id, Quote>([select id, name, Quote_Number__c,Quote_Revision__c  from Quote where ID =:recordID]);
            // soumyad start IBA-1631
            if(quoteprintStatus.print_status__c == 'REPRINT'){
                message = 'Please Print again and compare.';
                return new comparewrapper(subcompwrap, message,false);
            }else {
        	// soumyad end IBA-1631
        		for(Quote qu: quotemap.values()){
            for(Quote_Print_Status__c qps: qpsmap.values()){
                System.debug('Print status values: '+qpsmap.values());
                System.debug('qps.Revision_Number__c: '+qps.Revision_Number__c);
                System.debug('level1.values: '+level1.keyset());
                system.debug('qu.Quote_Revision__c'+qu.Quote_Revision__c);
                
                if(qps.Revision_Number__c == level1.get('Quote_Revision__c')){
                    
                    system.debug('SFDC Quote line count: '+double.valueOf(sfdcQuotelinecount));
                    system.debug('SAP Quote line count: '+double.valueOf(Itemcount));
                    
                    if(double.valueOf(sfdcQuotelinecount)==double.valueOf(Itemcount)){
                       isRevision = true;
                    system.debug('isRevision'+isRevision); 
                        system.debug('Itemcount'+double.valueOf(Itemcount));
                        system.debug('sfdcQuotelinecount'+sfdcQuotelinecount);
                    }
                    else if(sfdcQuotelinecount!=double.valueOf(Itemcount)){
                        return new comparewrapper(subcompwrap, 'Number of Quote line items are not matching.',false);
                    }
                   
                }
                else if(qu.Quote_Revision__c ==level1.get('Quote_Revision__c')){
                    system.debug('Print again and compare');
                    message = 'Print again and compare';
                    return new comparewrapper(subcompwrap, message,false);
                }
                else{
                    system.debug('Quote revision number is out of sync, please sync the Quote and then print and compare.');
                    message = 'Quote revision number is out of sync, please sync the Quote and then print and compare.';
                    return new comparewrapper(subcompwrap, message,false);
                }
            }
            System.debug('isRevision: '+isRevision);
            if(isRevision){
                for(Quote_Line__c ql: qline.values()){
                    System.debug('qline.values()'+qline.values());
                    system.debug('ql.Conga_Product1__c: '+ql.Conga_Product1__c);
                    system.debug('No Difference!!');
                    for(Integer i: myMaps.keyset())
                    {
                        Map<string, object> maps = new Map<String,Object>();
                        maps = myMaps.get(i);
                        If(maps.containsKey('conga_Product1_c')){
                            String sapproduct = (string)maps.get('conga_Product1_c');
                            string sfproduct = ql.Conga_Product1__c;
                            
                            if( (sfproduct == sapproduct && (maps.get('If_Renewal_Buyout') == null) && (ql.Is_Lease_buyout__c ==false && ql.IFRenewalProduct__c==false)) ||
                              ((sfproduct == sapproduct && (maps.get('If_Renewal_Buyout') != null) && (ql.Is_Lease_buyout__c || ql.IFRenewalProduct__c) ) ) ){
                                system.debug('SAP conga_Product1_c: '+maps.get('conga_Product1_c'));
                                system.debug(' SFDC conga_Product1_c: '+ql.Conga_Product1__c);
                                
                                string saplpc = (string)maps.get('Conga_List_Price__c');
                                double conga_list_price;
                                //system.debug(' SFDC Conga_List_Price__c: '+ql.Conga_List_Price__c);
                                if (saplpc == null ){saplpc='0.0';}
                                
                                if(ql.Conga_part_of_bundle_true__c){
                                    conga_list_price = ql.Conga_List_Price__c;
                                    system.debug('conga_list_price 1: '+conga_list_price);
                                }else{
                                    conga_list_price = ql.CONGA_LIST_PRICE1__c;
                                    system.debug('conga_list_price 2: '+conga_list_price);
                                }
                                
                                if (ql.Conga_List_Price__c == null){ql.Conga_List_Price__c = 0.0; }
                                if(ql.Contract_List_Price__c==null){ql.Contract_List_Price__c=0.0;}
                                
                                string sapupc = (string)maps.get('Conga_Unit_Price__c');
                                if (sapupc == null ){sapupc='0.0';}
                                if (ql.Conga_Unit_Price__c == null){ql.Conga_Unit_Price__c = 0.0;}
                                
                                string sapcem = (string)maps.get('Conga_Extended_Price_Materials__c');
                                if (sapcem == null ){sapcem='0.0';}
                                if (ql.Conga_Extended_Price_Materials__c  == null){ql.Conga_Extended_Price_Materials__c  = 0.0; }
                                
                                
                                string sapusc = (string)maps.get('Conga_Unit_Services__c');
                                double conga_unit_service;
                                Decimal conga_extended_service;				// Debasis IBA-4172
                                Decimal conga_ext_service_toRound = 0.0;	// Debasis IBA-4172
                                
                                if (sapusc == null ){sapusc='0.0';}
                                if(ql.Conga_Unit_Services__c == null){ql.Conga_Unit_Services__c = 0.0;}
                                if(ql.Conga_Renewal_Unit_Services__c==null){ql.Conga_Renewal_Unit_Services__c=0.0;}
                                
                                if(ql.Product_Code__c =='RENEWAL'){
                                    conga_unit_service = ql.Conga_Renewal_Unit_Services__c;
                                    
                                }
                                else 
                                    if(ql.Conga_Quantity__c>0)
                                {
                                    conga_unit_service = ql.Conga_Unit_Services__c/ql.Conga_Quantity__c;
                                    
                                }
                                string sapext = (string)maps.get('Conga_Extended_Services__c');
                                if (sapext == null ){sapext='0.0';}
                                if(ql.Conga_Extended_Services__c  == null){ql.Conga_Extended_Services__c  = 0.0;}
                                if(ql.Conga_Renewal_Extended_Services__c  == null){ql.Conga_Renewal_Extended_Services__c  = 0.0;}
                                
                                If(ql.Product_Code__c !='RENEWAL' && ql.Conga_Extended_Services__c>0){
                                    conga_extended_service= ql.Conga_Extended_Services__c;
                                }else {
                                    conga_extended_service= ql.Conga_Renewal_Extended_Services__c;
                                }
                                conga_ext_service_toRound = conga_extended_service.setScale(2, RoundingMode.HALF_UP);	// Debasis IBA-4172
                                
                                
                                string saprew = (string)maps.get('If_Renewal_Buyout');
                                if(saprew==null){saprew='';}
                                String isRenewal='';
                                if(ql.Is_Lease_buyout__c || ql.IFRenewalProduct__c){
                                    isRenewal = 'X';
                                }
                                
                                if(Integer.valueOf(ql.Conga_Quantity__c)!= Integer.valueOf(maps.get('Conga_Quantity__c')) || 
                                   double.valueOf(conga_list_price)!= double.valueOf(saplpc) || 
                                   double.valueOf(ql.Conga_Unit_Price__c)!= double.valueOf(sapupc) || 
                                   double.valueOf(ql.Conga_Extended_Price_Materials__c)!= double.valueOf(sapcem) ||	
                                   double.valueOf(conga_unit_service)!= double.valueOf(sapusc) || 
                                   double.valueOf(conga_ext_service_toRound)!= double.valueOf(sapext) ||	// Debasis IBA-4172
                                   string.valueOf(isRenewal) != string.valueOf(saprew)){
                                       
                                       system.debug('SFDC QTy: '+Integer.valueOf(ql.Conga_Quantity__c));
                                       system.debug('SAP QTy: '+Integer.valueOf(maps.get('Conga_Quantity__c')));
                                       
                                       system.debug('SFDC List price: '+double.valueOf(conga_list_price));
                                       system.debug('SAP list price: '+double.valueOf(saplpc));   
                                       
                                       system.debug('SFDC Unit price: '+double.valueOf(ql.Conga_Unit_Price__c));
                                       system.debug('SAP Unit price: '+double.valueOf(sapupc));
                                       
                                       system.debug('SFDC Extended price material: '+double.valueOf(ql.Conga_Extended_Price_Materials__c));
                                       system.debug('SAP Extended price material: '+double.valueOf(sapcem));
                                       
                                       system.debug('SFDC Unit service: '+double.valueOf(conga_unit_service));
                                       system.debug('SAP Unit service: '+double.valueOf(sapusc));
                                       
                                       system.debug('SFDC Extended service: '+string.valueOf(double.valueOf(conga_ext_service_toRound)));
                                       system.debug('SAP Extended service: '+double.valueOf(sapext));
                                       
                                       system.debug('SFDC Renewal: '+string.valueOf(isRenewal));
                                       system.debug('SAP Renewal: '+string.valueOf(maps.get('If_Renewal_Buyout')));
                                       
                                       subcompwrap.add(new subcomparewrapper('SFDC',sfproduct, String.valueOf(ql.Conga_Quantity__c),
                                                                             String.valueOf(conga_list_price), String.valueOf(ql.Conga_Unit_Price__c), 
                                                                             String.valueOf(ql.Conga_Extended_Price_Materials__c),String.valueOf(conga_unit_service), 
                                                                             string.valueOf(double.valueOf(conga_extended_service)), string.valueOf(isRenewal)));
                                       
                                       subcompwrap.add(new subcomparewrapper('SAP',sapproduct, string.valueOf(Integer.valueOf(maps.get('Conga_Quantity__c'))),
                                                                             string.valueOf(double.valueOf(saplpc)), string.valueOf(double.valueOf(sapupc)), 
                                                                             string.valueOf(double.valueOf(sapcem)),string.valueOf(double.valueOf(sapusc)),string.valueOf(double.valueOf(sapext)),string.valueOf(maps.get('If_Renewal_Buyout')) ));
                                   }
                                
                            } 
                            
                        }
                    }
                    
                }
            }
        }
        	}
        comparewrapper compwrap;
        if(subcompwrap.isEmpty() && isRevision == true){
            if(double.valueOf(Itemcount)== double.valueOf(sfdcQuotelinecount)){
                compwrap = new comparewrapper(subcompwrap, 'Quotes are Identical!',false);
            }
        }else{
            compwrap = new comparewrapper(subcompwrap, message,true); 
        }
        return compwrap;
    }
        catch(Exception e){
            system.debug('Exception '+e.getLineNumber());
            system.debug('Exception '+e.getMessage());
        return new comparewrapper(subcompwrap, 'Please Print before compare!',false);
    }
    }
    
}