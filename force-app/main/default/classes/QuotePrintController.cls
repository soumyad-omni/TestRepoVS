/**
* @File Name          : QuotePrintController.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 11-12-2020
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    31/12/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class QuotePrintController {
    public static boolean isQuoteUpdateFrom_QuotePrintController = false;
    
    
    public static boolean prof = false; // soumyad 964
    public static boolean cma_flag = false; // IBA-4072
    //Added by Jay under IBN-1596 -- Start
    public static Map<String, String> cannedLangMAP = new  Map<String, String>();
    
    static{
        if(cannedLangMAP != null){
            for(Canned_Language__c var: [Select Name, Canned_Language_Detail__c from Canned_Language__c where /*Name like '%MDA-LIC-011' OR */ Name like '%MDA-LIC-006']){
                cannedLangMAP.put(var.Name, var.Canned_Language_Detail__c.replaceAll('<[^>]+>',' '));
            }
        }
    }  //Commented out 'Name like '%MDA-LIC-011' OR' for IBA-2596
    //Added by Jay under IBN-1596 -- End
    /* Following Function added for UAT BUG 259 & 261 */
    @AuraEnabled
    public static Boolean checkPrintCurrency(Id quoteId){
        Quote q =  [select id,Print_Currency__c ,Quote_Currency__c from Quote where id=:quoteId];
        if ((q.Print_Currency__c != null) && (q.Print_Currency__c != q.Quote_Currency__c)  ){
            return true;
        }
        else 
        {
            return false;
        }
    }
    
    /* Following Function added for UAT BUG 259 & 261 */
    @AuraEnabled
    public static Boolean setPrintFlag(Id quoteId){
        Quote q =  [select id,Mul_Cur_Print__c, Print_Currency__c ,Quote_Currency__c from Quote where id=:quoteId];
        if ((q.Print_Currency__c != null) && (q.Print_Currency__c != q.Quote_Currency__c)  ){
            q.Mul_Cur_Print__c = true;
            update q;
            return true;
        }
        else 
        {
            q.Mul_Cur_Print__c = false;
            update q;
            return false;
        }
    }
    
    /* Following Function added for SF-BUG-287 */
    @AuraEnabled
    public static String chkCannedLanguage(Id quoteId,String[] selectedCannedLan){ 
        //.debug('Entering my funct');    
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
        String deal = dealdesk.Profile_Name__c;
        
        List<User> useradmins = [select id from User where profile.name=:sysadmin OR profile.name=:busadmin OR profile.name=:deal];
        List<Id> useridsadmins = new List<Id>();
        for(User u: useradmins){
            useridsadmins.add(u.id);
        }
        
        //system.debug('Entering my funct after user'); 
        List<Conga_Quote_Print__c> qp = [select id,select_Canned_Language__c,SelectedCannedLanguageNames__c from Conga_Quote_Print__c where ownerid=:useridsadmins and Quote_Record_Id__c=:quoteId order by createddate desc limit 1];
        
        Boolean pastequal = true;
        
        if(qp.size()>0){   
            if(qp[0].SelectedCannedLanguageNames__c != null){   
                List<String> pastcann = qp[0].SelectedCannedLanguageNames__c.split(',');
                if(pastcann.size() == selectedCannedLan.size()){  
                    for(Integer i=0;i<selectedCannedLan.size();i++){
                        if(qp[0].SelectedCannedLanguageNames__c.contains(selectedCannedLan[i])){
                            pastequal = true;    //true when current matches with past
                        }
                        else{
                            pastequal = false;   
                            break;
                        }
                    }
                }
                else if(pastcann.size() <> selectedCannedLan.size()){
                    pastequal = false;                              
                }
            }
        }
        
        if (pastequal == true )
            return 'TRUE';
        else 
            return 'FALSE';    
    }
    
    @AuraEnabled
    public static String updateQuote(String quoteId,String[] selectedCannedLan, String[] selectedExhibits,String[] selectedSections,
                                     String layout,String language,String template,String output,boolean usalist,boolean zerodollars,boolean genericdrawers,
                                     boolean productsunbundled,boolean serviceonly,Integer noofpictures,String editedterms,String[] selcannedPrev, Boolean isdraft,String agreementType, 
                                     boolean isEditButtonClicked){
                                         
                                         Schema.DescribeFieldResult F = Quote.IDN_Price_List__c.getDescribe();
                                         List<Schema.PicklistEntry> P = F.getPicklistValues();
                                         
                                         Schema.DescribeFieldResult F3 = Quote.GPO_Price_Lists__c.getDescribe();
                                         List<Schema.PicklistEntry> P3 = F3.getPicklistValues();
                                         Schema.DescribeFieldResult F1 = Quote.Service_Level__c.getDescribe();
                                         List<Schema.PicklistEntry> P1 = F1.getPicklistValues();
                                         Schema.DescribeFieldResult F2 = Quote.Terms_of_payment__c.getDescribe();
                                         List<Schema.PicklistEntry> P2 = F2.getPicklistValues();
                                         // during 07/09 deployment removed RenewalItemCount__c from the query
                                         Quote quote =  [select id,OpportunityId,Service_Escalator_percentage__c,Annual_Bill_Date__c,Conga_Total_Shipping_and_Handling__c,status,Culture_Code__c,
                                                         Renewal_Revenue__c,Order_Type__c,Conga_Supplement__c,EOL_Date__c,Fee_Increase__c,GPO_Price_Lists__c,IDN_Price_List__c, CurrencyIsoCode, SAP_Sales_Org__r.Sales_Org__c, //IBA-3867(4625) Adding Currency code and Sales org in the query
                                                         Service_Level__c,Terms_of_payment__c,Conga_Loggedin_User__c,Name,Master_Agreement__c,print_layout__c,Conga_section_Values__c,
                                                         Print_Sections__c,Select_Canned_Language__c,omnicell_url__c,aesynt_url__c,conga_canned_language__c, Small_Parts_pre_approved__c, Milestone_Invoice_Term__c, Opportunity_Record_Type__c, CONGA_Is_US_Opportunity_Type__c //IBA-4749 change AC                            
                                                         from Quote where id=:quoteId]; //added OpportunityId,Small_Parts_pre_approved__c to the query soumyad sf-bug-905 //IBA-3872 Abhrajitc **Added Milestone_Invoice_Term__c in the Query**
                                         
                                         // soumyad 965 start
                                         List<Quote_Line__c> quoteLines = [SELECT Id,
                                                                           Quote__r.Supplement_or_budgetary__c,
                                                                           Quote__c,
                                                                           Quote__r.Order_Type__c,                   //IBA-4603
                                                                           Product__c,
                                                                           Product_Code__c,
                                                                           Product__r.DW_Product_Line__c,
                                                                           Product__r.Business_Line__c,
                                                                           Product__r.DW_Product_Segment__c,
                                                                           Product__r.Portfolio_Segment__c,
                                                                           Product__r.DW_Product_Type__c,
                                                                           Product__r.DW_Product_Class__c,
                                                                           Product__r.DW_Product_Family__c,
                                                                           Product__r.SAP_Product_Type__c, //IBA-2867
                                                                           Quote_Line_Item_Type__c, 
                                                                           Product__r.Name, // Added by Jay under IBN-1596
                                                                           Line_Expected_Booking__c, //added as part of IBA-4347
                                                                           Line_Status__c // added as part of IBA-5747 SH
                                                                           FROM Quote_Line__c 
                                                                           WHERE Quote__c =:quoteId];
                                         Boolean prof = false;
                                         Boolean IVXOnly = false;
                                         Boolean maPass = false;//IBA-2290
                                         Boolean isIVCS = false;//IBA-2867
                                         Boolean IVXSOW = false; // IBA-1893 
                                         Boolean XR2Only = false;
                                         // Boolean oc_prod_flag = false; //IBA-1527 Start // commented out for IBA-3614 
                                         Boolean sku_prod_flag = false; //IBA-3614
                                         Boolean replacement_products_flag = false; //IBA-1789 Added by Prithan
                                         Boolean win7_flag = false; //IBA-2596 Added by Prithan
                                         Boolean suppFlag = false;
                                         Boolean pocQAP = false;//IBA-3681 
                                         Boolean oc_sku_prod_flag = false; //IBA-4020
                                         Boolean installation_sku_flag = false; //IBA-4072
                                         Boolean cad_sku_flag = false; //IBA-4072
                                         //Boolean Non_GA_prod_XTE_flag = false;//IBA-4639 //Commenting out for IBA-4961 Saptarsha Panthi
                                         Boolean FTK_study_skus_flag=false;//IBA-4603
                                         Boolean DeInstallation_flag=false;//IBA-3889 (Saptarsha)
                                         Boolean supplyX = false; //IBA-5821

                                         Boolean MedChill_flag=false;//IBA-5879 Saptarsha Panthi
                                         Boolean DataStation_flag = false;//IBA-5880 SH
                                         //IBA-1789 Start
                                         Set<String> rp_prod = new Set<String>();
                                         List<Replacement_Products__c> replace_prod = [Select Product_Name__c From Replacement_Products__c];
                                         for(Replacement_Products__c rp: replace_prod ){
                                             rp_prod.add(rp.Product_Name__c);
                                         }//IBA-1789 End
                                         //IBA-2596 Start
                                         Set<String> win_prod = new Set<String>();
                                         List<Win7_Support_Products__c> win7_prod = [Select Product_Name__c From Win7_Support_Products__c];
                                         for(Win7_Support_Products__c win: win7_prod){
                                             win_prod.add(win.Product_Name__c);
                                         }//IBA-2596 Ends
                                         //IBA-3614 Start
                                         Set<String> sk_prod = new Set<String>();
                                         List<SKU_based_automations__c> sku_prod = [Select Product_Name__c From SKU_based_automations__c];
                                         for(SKU_based_automations__c s: sku_prod){
                                             sk_prod.add(s.Product_Name__c);
                                         }//IBA-3614 Ends
                                         
                                         //IBA-4020 Start
                                         Set<String> oc_sk_prod = new Set<String>();
                                         List<OC_SKU_based_automation__c> oc_sku_prod = [Select Product_Name__c From OC_SKU_based_automation__c];
                                         for(OC_SKU_based_automation__c s: oc_sku_prod){
                                             oc_sk_prod.add(s.Product_Name__c);
                                         }//IBA-4020 Ends
                                         
                                         //IBA-4072 Starts
                                         Set<String> inst_sk_prod = new Set<String>();
                                         List<Installation_plan_SKU__c> inst_sku_prod = [Select Product_Name__c From Installation_plan_SKU__c];
                                         for(Installation_plan_SKU__c s: inst_sku_prod){
                                             inst_sk_prod.add(s.Product_Name__c);
                                         }
                                         
                                         Set<String> cad_sk_prod = new Set<String>();
                                         List<CAD_Provision_SKU__c> cad_sku_prod = [Select Product_Name__c From CAD_Provision_SKU__c];
                                         for(CAD_Provision_SKU__c s: cad_sku_prod){
                                             cad_sk_prod.add(s.Product_Name__c);
                                         }
                                         //IBA-4072 Ends
                                         /*//IBA-4639 Start
Set<String> Non_GA_prod_XTE = new Set<String>();
List<Non_GA_product_XTE__c> cust_prod_XTE = [Select Product_Name__c From Non_GA_product_XTE__c];
for(Non_GA_product_XTE__c prod_XTE: cust_prod_XTE){
Non_GA_prod_XTE.add(prod_XTE.Product_Name__c);
}
//IBA-4639 End*/ //Commenting out for IBA-4961 Saptarsha Panthi
                                         //IBA-4603 Start
                                         Set<String> FTK_study_skus = new Set<String>();
                                         List<Formulary_Tool_Kit_Studies_IV_skus__c> cust_prod_FTK = [Select Product_Name__c From Formulary_Tool_Kit_Studies_IV_skus__c];
                                         for(Formulary_Tool_Kit_Studies_IV_skus__c prod_FTK: cust_prod_FTK){
                                             FTK_study_skus.add(prod_FTK.Product_Name__c);
                                         }
                                         //IBA-4603 End
                                         //IBA-3889 Start (Saptarsha)
                                         Set<String> DeInstallation_skus = new Set<String>();
                                         List<De_Installation__c> cust_prod_DeInstallation = [Select Product_Name__c From De_Installation__c];
                                         for(De_Installation__c prod_DeInstallation: cust_prod_DeInstallation){
                                             DeInstallation_skus.add(prod_DeInstallation.Product_Name__c);
                                         }
                                         //IBA-3889 End (Saptarsha)
                                         
                                         //IBA-4347 Starts
                                         Set<String> POC_SKU = new Set<String>();
                                         List<Point_Of_Care_SKU__c> pocsku = Point_Of_Care_SKU__c.getall().values();
                                         for(Point_Of_Care_SKU__c s: pocsku){
                                             POC_SKU.add(s.Product_Name__c);
                                         }
                                         
                                         Set<String> POC_PS_SKU = new Set<String>();
                                         List<Non_Point_Of_Care_SKU__c> pocpssku = Non_Point_Of_Care_SKU__c.getall().values();
                                         for(Non_Point_Of_Care_SKU__c s: pocpssku){
                                             POC_PS_SKU.add(s.Product_Name__c);
                                         }
                                         //IBA-4347 Ends
                                         
                                         //IBA-5880 Starts SH
                                         Set<String> DS_SKU = new Set<String>(); //DS is DataStation
                                         List<Datastation_Product__c> dssku = Datastation_Product__c.getall().values();
                                         for(Datastation_Product__c s: dssku){
                                             DS_SKU.add(s.Product_Name__c);
                                         }
                                         //IBA-5880 ends SH
                                         
                                         //IBA-4819 Starts
                                         Set<String> ServerScale_SKU = new Set<String>();
                                         List<ServerScale_SKU__c> ssSKU = ServerScale_SKU__c.getall().values();
                                         for(ServerScale_SKU__c s: ssSKU){
                                             ServerScale_SKU.add(s.Product_Name__c);
                                         }
                                         //IBA-4819 Ends
                                         
                                         for(Quote_Line__c ql : quoteLines){
                                             System.debug('Product Line'+ql.Product__r.DW_Product_Line__c);
                                             System.debug('Product Segment'+ql.Product__r.DW_Product_Segment__c);
                                             if(rp_prod.contains(ql.Product_Code__c)){//Added by Prithan IBA-1789
                                                 replacement_products_flag = true;
                                             }
                                             if(win_prod.contains(ql.Product_Code__c)){//Added by Prithan IBA-2596
                                                 win7_flag = true;
                                             }
                                             if(ql.Product__c != null){ 
                                                 // professional services check
                                                 if(ql.Product__r.DW_Product_Line__c == 'Professional Services'){
                                                     prof = true;
                                                 }
                                                 // check to validate if there is XR2 product XR2 portfolio segment updated to Central Pharmacy Dispensing Service
                                                 if(ql.Product__r.Portfolio_Segment__c == 'Central Pharmacy Dispensing Service'){//updated by Abhrajitc IBA-1652
                                                     XR2Only = true;
                                                 }
                                                 // check to validate if there is IVX product IV Portfolio segment updated to IV Legacy
                                                 if(ql.Product__r.Portfolio_Segment__c == 'IV Legacy' ||ql.Product__r.Portfolio_Segment__c == 'IV Compounding Service'){//updated by Abhrajitc IBA-1652// updated by Pritha IBA-1893
                                                     IVXOnly = true;
                                                 }
                                                 //check to validate if there is IVX product updated to IVX Workflow
                                                 if(ql.Product__r.Portfolio_Segment__c == 'IVX Workflow'){//updated by Pritha IBA-1893
                                                     IVXSOW = true;
                                                 }
                                                 if(ql.Product__r.Portfolio_Segment__c == 'SingleDose Automation'){//updated by Pritha IBA-2290
                                                     maPass = true;
                                                 }
                                                 if(ql.Product__r.Portfolio_Segment__c == 'Core Machine'){//updated by Pritha IBA-2290
                                                     maPass = true;
                                                 }
                                                 if((ql.Product__r.Portfolio_Segment__c == 'Cloud Hosted OmniCenter' && ql.Product__r.DW_Product_Line__c == 'OmniCenter' &&  sk_prod.contains(ql.Product_Code__c))||
                                                    (ql.Product__r.Portfolio_Segment__c == 'Inventory Optimization Service and Platform' && ql.Product__r.DW_Product_Line__c == 'Omnicell One' &&  sk_prod.contains(ql.Product_Code__c))|| //IBA-4331
                                                    (ql.Product__r.Portfolio_Segment__c == 'Inventory Optimization Service and Platform' && ql.Product__r.DW_Product_Line__c == 'Omnicell Essentials' &&  sk_prod.contains(ql.Product_Code__c))|| //IBA-4331
                                                    (ql.Product__r.Portfolio_Segment__c == 'IVX Workflow' && ql.Product__r.DW_Product_Line__c == 'IVX Cloud' &&  sk_prod.contains(ql.Product_Code__c)))
                                                 {
                                                     sku_prod_flag = true;
                                                 }
                                                 //IBA-2867
                                                 if((ql.Product__r.SAP_Product_Type__c == 'Robot' || ql.Product__r.SAP_Product_Type__c == 'Labor') && ql.Product__r.Portfolio_Segment__c == 'IV Compounding Service' && (ql.Product__r.DW_Product_Family__c == 'Service' || ql.Product__r.DW_Product_Family__c ==  'Prof Services') && ql.Product__r.Business_Line__c == 'IV Product Solutions'){isIVCS = True;}
                                                 if(ql.Product__r.Portfolio_Segment__c == 'Inventory Optimization Service and Platform' && oc_sk_prod.contains(ql.Product_Code__c) && ql.Line_Status__c != Label.Conga_Quote_Line_Status){oc_sku_prod_flag = true;} // IBA-4020, added && q.Line_Status__c != Label.Conga_Quote_Line_Status as part of IBA-5747 SH
                                                 
                                                 if(inst_sk_prod.contains(ql.Product_Code__c)){installation_sku_flag = true;
                                                                                              } //IBA-4072
                                                 
                                                 if(cad_sk_prod.contains(ql.Product_Code__c)){cad_sku_flag = true;} //IBA-4072
                                                 /* if(Non_GA_prod_XTE.contains(ql.Product_Code__c)){//IBA-4639 Start
Non_GA_prod_XTE_flag=true;  
}//IBA-4639 End*/ //Commenting out for IBA-4961 Saptarsha Panthi
                                                 if(FTK_study_skus.contains(ql.Product_Code__c) && ql.Quote__r.Order_Type__c!='ZQRS'){//IBA-4603 Start
                                                     FTK_study_skus_flag=true;  
                                                 }//IBA-4603 End    
                                                 if(DeInstallation_skus.contains(ql.Product_Code__c)&& ql.Quote__r.Order_Type__c!='ZQRS'){//IBA-3889 Start (Saptarsha)
                                                     DeInstallation_flag = true;  
                                                 }//IBA-3889 End (Saptarsha)

                                                 if(ql.Product__r.Portfolio_Segment__c == 'SupplyXpert'){   //IBA-5821
                                                     supplyX = true;
                                                 }

                                                 //IBA-5879 Start Saptarsha Panthi
                                                 if(ql.Product__r.Portfolio_Segment__c == 'Medchill'){
                                                     MedChill_flag = true;
                                                 }
                                                 //IBA-5879 End Saptarsha Panthi
                                                 if(DS_SKU.contains(ql.Product_Code__c)){DataStation_flag = true;} //IBA-5880 SH
                                             }
                                         }
                                         // soumyad 965 end
                                         
                                         String base_template='';
                                         Conga_Quote_Print__c qp = new Conga_Quote_Print__c();
                                         qp.isIVCS__c = isIVCS; //IBA-2867
                                         
                                         qp.Point_of_care_services_fees__c = 0.00; //IBA-4347
                                         qp.Professional_services_fees__c = 0.00; //IBA-4347
                                         
                                         if(quote.IDN_Price_List__c != null){
                                             for(Schema.PicklistEntry pe : p){
                                                 
                                                 if(pe.getValue() == quote.IDN_Price_List__c){
                                                     qp.IDN_Price_List__c = pe.getLabel();
                                                     //options.add(new selectOption(so.Sales_Org__c, pe.getLabel() ));
                                                 }
                                             } 
                                         }else if(quote.IDN_Price_List__c == null && quote.GPO_Price_Lists__c != null){
                                             for(Schema.PicklistEntry pe : p3){
                                                 if(pe.getValue() == quote.GPO_Price_Lists__c){
                                                     qp.IDN_Price_List__c = pe.getLabel();
                                                     //options.add(new selectOption(so.Sales_Org__c, pe.getLabel() ));
                                                 }
                                             }
                                         }else{
                                             if(quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31'){//iba-4686
                                                 qp.IDN_Price_List__c = 'UK List';
                                             }else{
                                                 qp.IDN_Price_List__c = 'USA Price List';
                                             }
                                             
                                         }
                                         for(Schema.PicklistEntry pe1 : p1){
                                             if(pe1.getValue() == quote.Service_Level__c){
                                                 qp.Service_Level__c = pe1.getLabel();
                                                 //options.add(new selectOption(so.Sales_Org__c, pe.getLabel() ));
                                             }
                                         } 
                                         for(Schema.PicklistEntry pe2 : p2){
                                             if(pe2.getValue() == quote.Terms_of_payment__c){
                                                 qp.Terms_of_payment__c = pe2.getLabel();
                                                 //options.add(new selectOption(so.Sales_Org__c, pe.getLabel() ));
                                             }
                                         }
                                         //Added by JAY CR-18666 
                                         String recordType = '';
                                         List<Quote_Approval__c> qa = [select id,recordtypeid,status__c from quote_approval__c where quote__c = :quoteId order by createddate desc limit 1];
                                         //.debug('QA : '+qa);
                                         String recordtypeQA = '';
                                         String status = '';
                                         if(qa.size()>0){
                                             recordtypeQA = Schema.getGlobalDescribe().get('Quote_Approval__c').getDescribe().getRecordTypeInfosById().get(qa[0].RecordTypeId).getName();
                                             status = qa[0].status__c;
                                         }
                                         // start 1440
                                         User adminOrDealDeskUser = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
                                         Boolean IsAdminOrDealDeskUser = false;
                                         if(adminOrDealDeskUser.profile.Name == 'Deal Desk & Legal' || adminOrDealDeskUser.profile.Name == 'System Administrator'  || adminOrDealDeskUser.profile.Name == 'IT Administrator') //Added IT Admin as part of IBA-3443
                                         {
                                             IsAdminOrDealDeskUser = true; 
                                         }
                                         // ends 1440
                                         //Ends CR-18666
                                         String baseTempName = '';
                                         String quotePrintTemplateSettingName;
                                         if(template == 'Summary by Product' && ((zerodollars == false && usalist == false && productsunbundled == false && genericdrawers == false && serviceonly == false)||(quote.Order_Type__c == 'ZQRS'))){
                                             // added by tribhuvan for xr2 project line 153 to 163 , do not move to production  
                                             if(quote.Order_Type__c == 'ZQRS') {
                                                 //modified by Pavan Kumar October 10, 2020
                                                 // if(XR2Only){
                                                 baseTempName= 'Summary by Product OmnicellService';
                                                 //  }
                                                 
                                                 //added by Pavan Kumar
                                                 if(IVXOnly){ //updated by Abhrajitc IBA-1652
                                                     baseTempName= 'Summary by IVX Product OmnicellService';
                                                 }
                                                 
                                                 if(IVXSOW){  //updated by Pritha IBA-1893
                                                     baseTempName= 'Summary By Omnicell IVX Products';
                                                 }
                                                 
                                                 if(maPass){  //updated by Pritha IBA-2290
                                                     baseTempName ='Pass Budgetary';
                                                 }
                                                 
                                                 //added by Pavan Kumar
                                                 if(XR2Only && IVXOnly){
                                                     baseTempName = 'Summary by Product OmnicellService';
                                                     quotePrintTemplateSettingName = 'Summary by IVX Product OmnicellService';
                                                 }
                                                 if(IVXOnly && IVXSOW){
                                                     baseTempName = 'Summary by IVX Product OmnicellService';
                                                 }
                                             }else if(quote.CurrencyIsoCode == 'GBP' && quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31') {// IBA-3867 (4626) Start
                                                 baseTempName = 'Summary By Product International';
                                                 System.Debug('Developer--> summary by Product International Template is chosen'); //IBA-3867 (4626) change ends
                                             }else{
                                                 baseTempName ='Summary by Product';
                                             }
                                             
                                             //Added by JAY CR-18666 added condition for 1440 too
                                             if(quote.Order_Type__c == 'ZQRS' && (recordtypeQA == 'NAA Supplement Quote' || recordtypeQA.contains('International ADC/VBM') || recordtypeQA == 'MA Supplement Quote')
                                                && (quote.status == 'E0009' || quote.status == 'E0013' || quote.status == 'E0014' || quote.status == 'E0019' || IsAdminOrDealDeskUser))
                                             {
                                                 // when quote has only XR2 products
                                                 //modified by Pavan Kumar October 10, 2020
                                                 // if(XR2Only){
                                                 if(prof == true){
                                                     if(agreementType == 'Statement of Work')
                                                         baseTempName ='Omnicell as Service SOW Prof';
                                                     else
                                                         baseTempName ='Omnicell as Service Supplement Prof';
                                                 }else{
                                                     if(agreementType == 'Statement of Work')
                                                         baseTempName ='Omnicell as Service SOW';
                                                     else
                                                         baseTempName ='Omnicell as Service Supplement';
                                                 }
                                                 // }
                                                 
                                                 // when quote has only IVX products
                                                 if(IVXOnly){ // Updated by Abhrajitc IBA-1652
                                                     if(prof == true){
                                                         if(agreementType == 'Statement of Work'){ 
                                                             baseTempName ='IVX as Service SOW Prof';
                                                         }else{
                                                             baseTempName ='APSA - Default';
                                                             quotePrintTemplateSettingName = 'IVX as Service Supplement Prof';
                                                         }
                                                     }else{
                                                         if(agreementType == 'Statement of Work'){ 
                                                             baseTempName ='IVX as Service SOW';
                                                         }else{
                                                             baseTempName ='APSA - Default';
                                                             quotePrintTemplateSettingName = 'IVX as Service Supplement';
                                                         }
                                                     }
                                                 }
                                                 
                                                 // when quote has both IVX and XR2 products
                                                 if(IVXOnly && XR2Only){
                                                     if(prof == true){
                                                         if(agreementType == 'Statement of Work'){
                                                             baseTempName ='Omnicell XR2 as Service SOW Prof';
                                                             quotePrintTemplateSettingName = 'IVX as Service SOW';
                                                         }else{
                                                             baseTempName ='APSA - Default';
                                                             quotePrintTemplateSettingName = 'XR2 and IVX as Service Supplement Prof';
                                                         }
                                                     }else{
                                                         if(agreementType == 'Statement of Work'){
                                                             baseTempName ='Omnicell XR2 as Service SOW';
                                                             quotePrintTemplateSettingName = 'IVX as Service SOW';
                                                         }else{
                                                             baseTempName ='APSA - Default';
                                                             quotePrintTemplateSettingName = 'XR2 and IVX as Service Supplement';
                                                         }
                                                     }
                                                 }
                                                 if(maPass){ //updated by Pritha IBA-2290
                                                     if(agreementType == 'Statement of Work'){
                                                         baseTempName ='Pass SOW';
                                                     }
                                                 }
                                                 If(IVXSOW){ //updated by Pritha IBA-1893
                                                     if(agreementType == 'Statement of Work'){ 
                                                         baseTempName ='Summary By Omnicell IVX Workflow';
                                                     }else{
                                                         baseTempName ='APSA - Default';  //As part of IBA-4020 changed from 'IVX Workflow APSA' to 'APSA - Default'
                                                     }
                                                 }
                                                 if(IVXOnly && IVXSOW){ //updated by Pritha IBA-1893
                                                     if(prof == true){
                                                         if(agreementType == 'Statement of Work'){
                                                             baseTempName ='IVX as Service SOW Prof';
                                                         }else{
                                                             baseTempName ='APSA - Default';
                                                             quotePrintTemplateSettingName = 'IVX as Service Supplement Prof';
                                                         }
                                                     }else{
                                                         if(agreementType == 'Statement of Work'){ 
                                                             baseTempName ='IVX as Service SOW';
                                                         }else{
                                                             baseTempName ='APSA - Default';
                                                             quotePrintTemplateSettingName = 'IVX as Service Supplement';
                                                         }
                                                     }
                                                 }
                                             }
                                             // END - Modified by Pavan, Dated: September 11, 2020 
                                             system.debug(baseTempName + '  BASE');
                                             system.debug(quotePrintTemplateSettingName + ' quotePrintTemplateSettingName');                                             
                                             
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = :baseTempName];
                                             base_template = base_template+bt.template_id__c;
                                             
                                             /* Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'Summary by Product'];
base_template = base_template+bt.template_id__c;*/
                                         }
                                         else if(template == 'Pictures Only'){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'Pictures Only'];
                                             base_template = base_template+bt.template_id__c;
                                             
                                         }
                                         else if(template != 'Pictures Only' && template != 'Summary by Product' && quote.Order_Type__c == 'ZQRS'){//IBA-3242-Start
                                             if(template == 'CPDS –Central Pharmacy Dispensing Services'){
                                                 baseTempName ='Summary by Product OmnicellService';
                                                 
                                                 if((recordtypeQA == 'NAA Supplement Quote' || recordtypeQA.contains('International ADC/VBM') ||
                                                     recordtypeQA == 'MA Supplement Quote') && 
                                                    (quote.status == 'E0009' || quote.status == 'E0013' || quote.status == 'E0014' 
                                                     || quote.status == 'E0019' || IsAdminOrDealDeskUser)){//IBA-3777
                                                         if(IVXOnly){
                                                             if(prof == True){
                                                                 if(agreementType == 'Statement of Work'){
                                                                     baseTempName ='Omnicell as Service SOW Prof'; // changed from 'Omnicell XR2 as Service SOW Prof' to Omnicell as Service SOW Prof IBA-4020
                                                                     quotePrintTemplateSettingName = 'IVX as Service SOW';
                                                                     System.debug('CPDS+IVXOnly+Prof+SOW');

                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                                     baseTempName ='Omnicell as Service SOW Services Only';
                                                                     quotePrintTemplateSettingName = 'IVX as Service SOW';
                                                                 }
                                                                 else if(agreementType == 'Autonomous Pharmacy Solutions Agreement'){
                                                                     baseTempName ='APSA - Default'; 
                                                                     quotePrintTemplateSettingName = 'XR2 and IVX as Service Supplement Prof';
                                                                     System.debug('CPDS+IVXOnly+Prof+APSA');
                                                                 }
                                                                 else if(agreementType == 'Advanced Service Agreement Services'){ // IBA-4020 services only
                                                                     baseTempName ='Omnicell as Service Supplement Prof';                                                                             
                                                                     quotePrintTemplateSettingName = 'CPDS as service SOW Service only';
                                                                 }
                                                                 else if(agreementType == 'Statement of Work for CMA MA'){ // IBA-4201
                                                                     baseTempName ='CPDS SOW for CMA prof';
                                                                     cma_flag = true; //IBA-4072
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201 services only
                                                                     baseTempName ='CPDS SOW Services Only for CMA no prof';
                                                                     cma_flag = true; //IBA-4072
                                                                 }
                                                             }
                                                             else{
                                                                 if(agreementType == 'Statement of Work'){
                                                                     baseTempName ='Omnicell XR2 as Service SOW'; 
                                                                     quotePrintTemplateSettingName = 'IVX as Service SOW';
                                                                     System.debug('CPDS+IVXOnly+WithoutProf+SOW');
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                                     baseTempName ='Omnicell as Service SOW Services Only';
                                                                 }
                                                                 else if(agreementType == 'Autonomous Pharmacy Solutions Agreement'){ 
                                                                     baseTempName ='APSA - Default'; 
                                                                     quotePrintTemplateSettingName = 'XR2 and IVX as Service Supplement';
                                                                     System.debug('CPDS+IVXOnly+WithoutProf+APSA');
                                                                 }

                                                                 else if(agreementType == 'Advanced Service Agreement Services'){ // IBA-4020 services only
                                                                     baseTempName = 'APSA - Default';
                                                                     quotePrintTemplateSettingName = 'Omnicell as Service SOW Services Only';
                                                                 }
                                                                 else if(agreementType == 'Statement of Work for CMA MA'){ // IBA-4201
                                                                     baseTempName ='CPDS SOW for CMA no prof';
                                                                     cma_flag = true; //IBA-4072
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201 services only
                                                                     baseTempName ='CPDS SOW Services Only for CMA no prof';
                                                                     cma_flag = true; //IBA-4072
                                                                 }
                                                             }
                                                         }
                                                         else{
                                                             if(prof == True){
                                                                 if(agreementType == 'Statement of Work'){ 
                                                                     baseTempName ='Omnicell as Service SOW Prof'; 
                                                                     System.debug('CPDS+WithoutIVXOnly+Prof+SOW');
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                                     baseTempName ='Omnicell as Service SOW Services Only';
                                                                 }
                                                                 else if(agreementType == 'Autonomous Pharmacy Solutions Agreement'){ 
                                                                     baseTempName ='Omnicell as Service Supplement Prof'; 
                                                                     quotePrintTemplateSettingName = 'CPDS as service SOW';
                                                                     System.debug('CPDS+WithoutIVXOnly+Prof+APSA');
                                                                 }
                                                                 else if(agreementType == 'Advanced Service Agreement Services'){ // IBA-4020 services only\
                                                                     //system.debug('@shh: here');
                                                                     baseTempName ='Omnicell as Service Supplement Prof';                                                                             
                                                                     quotePrintTemplateSettingName = 'CPDS as service SOW Service only';
                                                                 }
                                                                 else if(agreementType == 'Statement of Work for CMA MA'){ // IBA-4201
                                                                     baseTempName ='CPDS SOW for CMA prof';
                                                                     cma_flag = true; //IBA-4072
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201 services only
                                                                     baseTempName ='CPDS SOW Services Only for CMA no prof';
                                                                     cma_flag = true; //IBA-4072
                                                                 }
                                                             }
                                                             else{
                                                                 if(agreementType == 'Statement of Work'){ 
                                                                     baseTempName ='Omnicell as Service SOW'; 
                                                                     System.debug('CPDS+WithoutIVXOnly+WithoutProf+SOW');
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                                     baseTempName ='Omnicell as Service SOW Services Only';
                                                                 }
                                                                 else if(agreementType == 'Autonomous Pharmacy Solutions Agreement'){ 
                                                                     baseTempName ='Omnicell as Service Supplement'; 
                                                                     quotePrintTemplateSettingName = 'CPDS as service SOW';
                                                                     //System.debug('4020 APSA + SOW');
                                                                 }
                                                                 else if(agreementType == 'Advanced Service Agreement Services'){ // IBA-4020 services only
                                                                     baseTempName ='Omnicell as Service Supplement';
                                                                     quotePrintTemplateSettingName = 'CPDS as service SOW Service only';
                                                                     //System.debug('4020 APSA + SOW service only');
                                                                 }
                                                                 else if(agreementType == 'Statement of Work for CMA MA'){ // IBA-4201

                                                                     baseTempName ='CPDS SOW for CMA no prof';
                                                                     cma_flag = true; //IBA-4072
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201 services only
                                                                     baseTempName ='CPDS SOW Services Only for CMA no prof';
                                                                     cma_flag = true; //IBA-4072
                                                                 }
                                                             }
                                                         }
                                                     }
                                             }
                                             else if(template == 'IVCS-IV Compounding Services'){
                                                 baseTempName= 'Summary by IVX Product OmnicellService';
                                                 
                                                 if((recordtypeQA == 'NAA Supplement Quote' || recordtypeQA.contains('International ADC/VBM') ||
                                                     recordtypeQA == 'MA Supplement Quote') && 
                                                    (quote.status == 'E0009' || quote.status == 'E0013' || quote.status == 'E0014' 
                                                     || quote.status == 'E0019' || IsAdminOrDealDeskUser)){//IBA-3777
                                                         if(XR2Only){
                                                             if(prof == True){
                                                                 if(agreementType == 'Statement of Work'){
                                                                     baseTempName ='Omnicell as Service SOW Prof'; // changed from 'Omnicell XR2 as Service SOW Prof' to Omnicell as Service SOW Prof IBA-4020
                                                                     quotePrintTemplateSettingName = 'IVX as Service SOW';
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                                     baseTempName ='Omnicell as Service SOW Services Only'; 
                                                                     quotePrintTemplateSettingName ='IVX as Service SOW';
                                                                 }
                                                                 else if(agreementType == 'Autonomous Pharmacy Solutions Agreement'){
                                                                     baseTempName ='APSA - Default'; 
                                                                     quotePrintTemplateSettingName = 'XR2 and IVX as Service Supplement Prof';
                                                                 }
                                                                 else if(agreementType == 'Advanced Service Agreement Services'){ // IBA-4020 services only
                                                                     baseTempName ='APSA - Default';
                                                                     quotePrintTemplateSettingName ='XR2 and IVX as Service Supplement Prof';
                                                                 }
                                                                 else if(agreementType == 'Statement of Work for CMA MA' || agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201
                                                                     baseTempName ='IVCS SOW for CMA prof';
                                                                 }
                                                             }
                                                             else{
                                                                 if(agreementType == 'Statement of Work'){ 
                                                                     baseTempName ='Omnicell XR2 as Service SOW'; 
                                                                     quotePrintTemplateSettingName = 'IVX as Service SOW';
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                                     baseTempName ='Omnicell XR2 as Service SOW'; 
                                                                     quotePrintTemplateSettingName ='IVX as Service SOW';
                                                                 }
                                                                 else if(agreementType == 'Autonomous Pharmacy Solutions Agreement'){
                                                                     baseTempName ='APSA - Default'; 
                                                                     quotePrintTemplateSettingName = 'XR2 and IVX as Service Supplement';
                                                                 }
                                                                 else if(agreementType == 'Advanced Service Agreement Services'){ // IBA-4020 services only
                                                                     baseTempName ='APSA - Default';
                                                                     quotePrintTemplateSettingName ='XR2 and IVX as Service Supplement';
                                                                 }
                                                                 else if(agreementType == 'Statement of Work for CMA MA' || agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201
                                                                     baseTempName ='IVCS SOW for CMA no prof';
                                                                 }
                                                             }
                                                         }
                                                         else{
                                                             if(prof == true){
                                                                 if(agreementType == 'Statement of Work'){ 
                                                                     baseTempName ='IVX as Service SOW Prof'; 
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                                     baseTempName ='IVX as Service SOW Prof';                                                                             
                                                                 }
                                                                 else if(agreementType == 'Autonomous Pharmacy Solutions Agreement'){ 
                                                                     baseTempName ='APSA - Default'; 
                                                                     quotePrintTemplateSettingName = 'IVX as Service Supplement Prof';
                                                                 }else if(agreementType == 'Advanced Service Agreement Services'){ // IBA-4020 services only
                                                                     baseTempName ='APSA - Default'; 
                                                                     quotePrintTemplateSettingName = 'IVX as Service Supplement Prof';
                                                                 }
                                                                 else if(agreementType == 'Statement of Work for CMA MA' || agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201
                                                                     baseTempName ='IVCS SOW for CMA prof';
                                                                 }
                                                             }
                                                             else{
                                                                 if(agreementType == 'Statement of Work'){ 
                                                                     baseTempName ='IVX as Service SOW'; 
                                                                 }
                                                                 else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                                     baseTempName ='IVX as Service SOW';
                                                                 }
                                                                 else if(agreementType == 'Autonomous Pharmacy Solutions Agreement'){ 
                                                                     baseTempName ='APSA - Default'; 
                                                                     quotePrintTemplateSettingName = 'IVX as Service Supplement';
                                                                 }else if(agreementType == 'Advanced Service Agreement Services'){ // IBA-4020 services only
                                                                     baseTempName ='APSA - Default'; 
                                                                     quotePrintTemplateSettingName = 'IVX as Service SOW'; // replaced 'IVX as Service Supplement' with 'IVX as Service SOW' as part of IBA-4020
                                                                 }

                                                                 else if(agreementType == 'Statement of Work for CMA MA' || agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201
                                                                     baseTempName ='IVCS SOW for CMA no prof';
                                                                 }
                                                             }
                                                         }
                                                     }
                                             }
                                             else if(template == 'IVX Workflow'){
                                                 baseTempName ='Summary By Omnicell IVX Products';
                                                 
                                                 if((recordtypeQA == 'NAA Supplement Quote' || recordtypeQA.contains('International ADC/VBM') ||
                                                     recordtypeQA == 'MA Supplement Quote') && 
                                                    (quote.status == 'E0009' || quote.status == 'E0013' || quote.status == 'E0014' 
                                                     || quote.status == 'E0019' || IsAdminOrDealDeskUser)){//IBA-3777
                                                         if(agreementType == 'Statement of Work'){ 
                                                             baseTempName ='Summary By Omnicell IVX Workflow';
                                                         }
                                                         else if(agreementType == 'Statement of Work Services'){ // IBA-4020 services only
                                                             baseTempName ='Summary By Omnicell IVX Workflow';
                                                         }
                                                         else if(agreementType == 'Statement of Work for CMA MA' || agreementType == 'Statement of Work Services Only for CMA MA'){ // IBA-4201
                                                             baseTempName ='IVX Workflow SOW for CMA';
                                                         }else{
                                                             baseTempName ='APSA - Default'; //As part of IBA-4020 changed from 'IVX Workflow APSA' to 'APSA - Default'
                                                         }
                                                         // }
                                                     }
                                             }
                                             else if(template == 'PASS –Packaging and Service Subscription'){
                                                 baseTempName ='Pass Budgetary';
                                                 if((recordtypeQA == 'NAA Supplement Quote' || recordtypeQA.contains('International ADC/VBM') ||
                                                     recordtypeQA == 'MA Supplement Quote') && 
                                                    (quote.status == 'E0009' || quote.status == 'E0013' || quote.status == 'E0014' 
                                                     || quote.status == 'E0019' || IsAdminOrDealDeskUser)){//IBA-3777
                                                         if(agreementType == 'Statement of Work'){
                                                             baseTempName ='Pass SOW'; 
                                                         }
                                                     }
                                             }
                                             else if(template == 'CarePlus'){//IBA-3681 Replaced Point of Care Service to CarePlus as part of IBA 5977 SH
                                                 baseTempName ='Point of Care Service Budgetary Quote'; 
                                                 if((recordtypeQA == 'NAA Supplement Quote' || recordtypeQA.contains('International ADC/VBM') ||
                                                     recordtypeQA == 'MA Supplement Quote') && 
                                                    (quote.status == 'E0009' || quote.status == 'E0013' || quote.status == 'E0014' 
                                                     || quote.status == 'E0019' || IsAdminOrDealDeskUser)){//IBA-3777
                                                         //baseTempName ='Point of Care Services Supplement'; 
                                                         pocQAP = true;
                                                         baseTempName ='POCS Supplement without Signature';
                                                         quotePrintTemplateSettingName = 'Point of Care Services Supplement Sig';
                                                     }
                                             }
                                             else if(template == 'ServerScale Subscription'){//IBA-4819 
                                                 baseTempName ='ServerScale Subscription Quote'; 
                                             }
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name =:baseTempName];
                                             base_template = base_template+bt.template_id__c;
                                         } //IBA-3242-End
                                         // soumyad sf-bug-806 start
                                         
                                         if(template == 'Summary by Product' && zerodollars == true && usalist == false && productsunbundled == false && genericdrawers == false && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'Summary by Product with Zero Dollars' limit 1];
                                             base_template = bt.template_id__c+',';
                                         }
                                         if(template == 'Summary by Product' && zerodollars == false && usalist == true && productsunbundled == false && genericdrawers == false && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'Display Usa Price List' limit 1];
                                             base_template = bt.template_id__c+',';
                                         }
                                         if(template == 'Summary by Product' && zerodollars == false && usalist == false && productsunbundled == true && genericdrawers == false && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'Summary by Product' limit 1];
                                             base_template = bt.template_id__c+',';
                                         }
                                         /*IBA-4792 Change AC:*/
                                         if (template == 'Summary by Product' && zerodollars == false && usalist == false && productsunbundled == false && genericdrawers == true && serviceonly == false) {
                                             if (quote.CurrencyIsoCode == 'GBP' && quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31') { // IBA-3867(4626) change
                                                 Conga_Base_Template__c bt = [select name, template_id__c from Conga_Base_Template__c where Name = 'Generic Drawers International' limit 1];
                                                 base_template = bt.template_id__c;
                                             } else { // IBA-3867 (4626) changes end
                                                 Conga_Base_Template__c bt = [select name, template_id__c from Conga_Base_Template__c where Name = 'Generic Drawers' limit 1];
                                                 base_template = bt.template_id__c;
                                             }
                                         }
                                         /*IBA-4792 Change AC*/
                                         if(template == 'Summary by Product' && zerodollars == false && usalist == false && productsunbundled == false && genericdrawers == false && serviceonly == true){
                                             Conga_Print_Section_Ids__c secId = [select Print_Section_Id__c from Conga_Print_Section_Ids__c where Name = 'Summary Service Only' limit 1];
                                             base_template = secId.Print_Section_Id__c;
                                         }
                                         ///////////////////////////////////////////// combination ///////////////////////////////////////////////////////
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == true && zerodollars == false && productsunbundled == false && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'usa + qlicustom + generic' limit 1];
                                             base_template = bt.template_id__c;
                                         }//1
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == false && zerodollars == true && productsunbundled == false && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'general + qzero + generic' limit 1];
                                             base_template = bt.template_id__c;
                                         }//2
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == false && zerodollars == false && productsunbundled == true && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'Generic Drawers' limit 1];
                                             base_template = bt.template_id__c;
                                         }//3
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == false && zerodollars == false && productsunbundled == false && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'service + qserv + generic'];
                                             base_template = bt.template_id__c;
                                         }//4
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == true && zerodollars == true && productsunbundled == false && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'usa + qzero + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//5
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == true && zerodollars == false && productsunbundled == true && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'Display Usa Price List'];
                                             base_template = bt.template_id__c;
                                         }//6
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == true && zerodollars == false && productsunbundled == false && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'u+s + qserv + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//7
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == false && zerodollars == true && productsunbundled == true && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'general + qzero + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//8
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == false && zerodollars == true && productsunbundled == false && serviceonly == true){
                                             Conga_Print_Section_Ids__c secId = [select Print_Section_Id__c from Conga_Print_Section_Ids__c where Name = 'Summary Service Only'];
                                             base_template = secId.Print_Section_Id__c;
                                         }//9
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == false && zerodollars == false && productsunbundled == true && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'service + qserv + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//10
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == true && zerodollars == true && productsunbundled == false && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'usa + qzero + generic'];
                                             base_template = bt.template_id__c;
                                         }//11
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == true && zerodollars == false && productsunbundled == true && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'usa + qlicustom + generic'];
                                             base_template = bt.template_id__c;
                                         }//12
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == true && zerodollars == false && productsunbundled == false && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'u+s + qserv + generic'];
                                             base_template = bt.template_id__c;
                                         }//13
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == false && zerodollars == true && productsunbundled == true && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'general + qzero + generic'];
                                             base_template = bt.template_id__c;
                                         }//14
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == false && zerodollars == true && productsunbundled == false && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'service + qserv + generic'];
                                             base_template = bt.template_id__c;
                                         }//15
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == false && zerodollars == false && productsunbundled == true && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'service + qserv + generic'];
                                             base_template = bt.template_id__c;
                                         }//16
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == true && zerodollars == true && productsunbundled == true && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'usa + qzero + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//17
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == true && zerodollars == true && productsunbundled == false && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'u+s + qserv + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//18
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == true && zerodollars == false && productsunbundled == true && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'u+s + qserv + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//19
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == false && zerodollars == true && productsunbundled == true && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'service + qserv + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//20
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == true && zerodollars == true && productsunbundled == true && serviceonly == false){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'usa + qzero + generic'];
                                             base_template = bt.template_id__c;
                                         }//21
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == true && zerodollars == true && productsunbundled == false && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'u+s + qserv + generic'];
                                             base_template = bt.template_id__c;
                                         }//22
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == true && zerodollars == false && productsunbundled == true && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'u+s + qserv + generic'];
                                             base_template = bt.template_id__c;
                                         }//23
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == false && zerodollars == true && productsunbundled == true && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'service + qserv + generic'];
                                             base_template = bt.template_id__c;
                                         }//24
                                         if(template == 'Summary by Product' && genericdrawers == false && usalist == true && zerodollars == true && productsunbundled == true && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'u+s + qserv + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//25
                                         if(template == 'Summary by Product' && genericdrawers == true && usalist == true && zerodollars == true && productsunbundled == true && serviceonly == true){
                                             Conga_Base_Template__c bt = [select name,template_id__c from Conga_Base_Template__c where Name = 'u+s + qserv + nongeneric'];
                                             base_template = bt.template_id__c;
                                         }//26
                                         //.debug('base_template '+base_template);
                                         // soumyad sf-bug-806 end
                                         
                                         qp.Print_Base_Template__c = base_template;
                                         qp.user_name__c = UserInfo.getUserName();                               
                                         qp.Quote_Record_ID__c = quoteId;
                                         qp.Print_Output_Format__c = output;
                                         qp.Print_Language__c = language;
                                         //qp.Print_Base_Template__c = template;
                                         qp.Display_USA_List_Price__c = usalist;
                                         qp.Display_Zero_Dollar_Item__c = zerodollars;                               
                                         qp.Display_Generic_Drawers__c = genericdrawers;  
                                         qp.Display_Products_Unbundled__c = productsunbundled;
                                         qp.Number_of_pictures_per_page__c = noofpictures;
                                         qp.Conga_Total_Shipping_and_Handling__c = quote.Conga_Total_Shipping_and_Handling__c;
                                         qp.CurrencyIsoCode = quote.CurrencyIsoCode; /*IBA-4792 Change AC*/
                                         Long myDateTime = System.now().getTime();                                      
                                         qp.Name = quote.Name+myDateTime;  
                                         if(layout == 'Omnicell' || layout == 'Change Order Omnicell'){
                                             Conga_Logo__c logo = [select Logo_Url__c from Conga_Logo__c where Name = 'Omnicell'];
                                             qp.Logo_Url__c = logo.Logo_Url__c;
                                             //quote.Change_Order__c = '';
                                             //quote.aesynt_url__c = '';
                                         }
                                         if(layout == 'Aesynt' || layout == 'Change Order Aesynt'){
                                             Conga_Logo__c logo = [select Logo_Url__c from Conga_Logo__c where Name = 'Aesynt'];
                                             qp.Logo_Url__c = logo.Logo_Url__c;
                                             
                                             //quote.omnicell_url__c = '';
                                         }
                                         if(layout == 'Omnicell' || layout == 'Aesynt' ){
                                             qp.Change_Order__c = '';
                                         }
                                         if(layout == 'Change Order Omnicell' || layout == 'Change Order Aesynt'){
                                             qp.Change_Order__c = 'Change Order';
                                         }
                                         qp.Print_Layout__c = layout;
                                         String cannedLanguage = '';
                                         String canned2='';
                                         String exhibits2='';
                                         String sections2='';
                                         String terms = '';
                                         String ids = '';
                                         String secids = '';
                                         Integer i = 0;
                                         Integer j = 0;
                                         Integer k = 0;
                                         String exhibits='';
                                         String exhibitNames = ''; 
                                         String sections='';
                                         if(template != 'Pictures Only' && template != 'Summary by Product' && quote.Order_Type__c == 'ZQRS'){//IBA-3681
                                             QuotePrintControllerSetting__mdt[] qpcsettingArr  = [Select Id,MasterLabel,SectionIds__c From QuotePrintControllerSetting__mdt where MasterLabel = :quotePrintTemplateSettingName];
                                             if(qpcsettingArr != null && qpcsettingArr.Size() > 0) {
                                                 secids = qpcsettingArr[0].SectionIds__c;
                                             }
                                         }
                                         else{
                                             // START - Modified by Pavan, Dated: September 23, 2020 
                                             if(IVXOnly){
                                                 QuotePrintControllerSetting__mdt[] qpcsettingArr  = [Select Id,MasterLabel,SectionIds__c From QuotePrintControllerSetting__mdt where MasterLabel = :quotePrintTemplateSettingName];
                                                 if(qpcsettingArr != null && qpcsettingArr.Size() > 0) secids = qpcsettingArr[0].SectionIds__c;
                                             }else if(IVXOnly && XR2Only){
                                                 QuotePrintControllerSetting__mdt[] qpcsettingArr  = [Select Id,MasterLabel,SectionIds__c From QuotePrintControllerSetting__mdt where MasterLabel = :quotePrintTemplateSettingName];
                                                 if(qpcsettingArr != null && qpcsettingArr.Size() > 0) secids = qpcsettingArr[0].SectionIds__c;
                                             } // IBA-1893 start
                                             else if(IVXSOW && IVXOnly){
                                                 QuotePrintControllerSetting__mdt[] qpcsettingArr  = [Select Id,MasterLabel,SectionIds__c From QuotePrintControllerSetting__mdt where MasterLabel = :quotePrintTemplateSettingName];
                                                 if(qpcsettingArr != null && qpcsettingArr.Size() > 0) secids = qpcsettingArr[0].SectionIds__c;
                                             }
                                             // IBA-1893 End
                                             // END - Modified by Pavan, Dated: September 23, 2020
                                         }
                                         System.debug('QuotePrintControllerSetting ==>'+secids);
                                         
                                         //Print Sections 
                                         for(String sec : selectedSections){
                                             
                                             if(k<selectedSections.size()-1){
                                                 sections = sections + sec + ';';
                                                 sections2 = sections2+sec+',';
                                                 if(sec == 'Summary Product Only'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Summary Product Only']; /*IBA-4711: Incorporating additional UK field into the query*/
                                                     //secids = secids+secId.Print_Section_Id__c+',';
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     else if(Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP') /*IBA-4711 changes AC*/
                                                         secids = secids+secId.Print_Section_UK__c+','; /*IBA-4711 changes AC*/
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                                 if(sec == 'Summary Service Only'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Summary Service Only']; /*IBA-4711: Incorporating additional UK field into the query*/
                                                     /*IBA-4711 changes AC*/
                                                     if(Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP') 
                                                         secids = secids+secId.Print_Section_UK__c+',';
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                     /*IBA-4711 changes AC*/
                                                     /*if(usalist == true)
secids = secids+secId.Print_Section_Id_USA__c+',';
else
secids = secids+secId.Print_Section_Id__c+',';*/
                                                 }
                                                 if(sec == 'Summary by Par Location'){
                                                     //System.debug('Section : '+sec);
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Summary_by_Par_Location']; /*IBA-4715: Incorporating additional UK field into the query*/
                                                     // System.debug('Sec : '+ secId.Print_Section_Id__c);
                                                     //secids = secids+secId.Print_Section_Id__c+',';
                                                     
                                                     if(usalist == true) {
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     } else if (Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP') { /*AC - IBA-4715: Initiating changes*/
                                                         secids = secids + secId.Print_Section_UK__c + ',';
                                                     } /*AC - IBA-4715 Changes complete*/  else {
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                     }
                                                 }
                                                 if(sec == 'Detail by Par Location' && quote.Renewal_Revenue__c > 0){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c 
                                                                                         from Conga_Print_Section_Ids__c where Name = 'Detail by Par Location-Renewal']; 
                                                     // secids = secids+secId.Print_Section_Id__c+',';
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                                 else if (sec == 'Detail by Par Location'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Detail by Par Location']; /*IBA-4715  AC Changes*/
                                                     // secids = secids+secId.Print_Section_Id__c+',';
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     else if(Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP') /*IBA-4715  AC Changes*/
                                                         secids = secids+secId.Print_Section_UK__c+','; /*IBA-4715  AC Changes*/
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                                 if(sec.contains('Print Config')){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c from Conga_Print_Section_Ids__c where Name = 'Print Config Pictures']; 
                                                     secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                                 if(sec == 'Detail by Par Location with pictures'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c from Conga_Print_Section_Ids__c where Name = 'Detail by Par Location with pictures']; 
                                                     //secids = secids+secId.Print_Section_Id__c+',';
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                                 if(sec == 'Summary by Par Location with pictures'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Summary by Par Location with pictures']; /*IBA-4711: Incorporating additional UK field into the query*/
                                                     //secids = secids+secId.Print_Section_Id__c+',';
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     else if(Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP') /*IBA-4711  AC Changes*/
                                                         secids = secids+secId.Print_Section_UK__c+','; /*IBA-4711  AC Changes*/
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                                 if(sec == 'Detail by Par Location with pictures and signoff'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c from Conga_Print_Section_Ids__c where Name = 'Detail by Par Location with signoff']; 
                                                     secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                             }   
                                             else{
                                                 // System.debug('Section : '+sec);
                                                 if(sec == 'Summary Product Only'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Summary Product Only']; /*IBA-4711: Incorporating additional UK field into the query*/
                                                     //secids = secids+secId.Print_Section_Id__c;
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c;
                                                     else if(Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP') /*IBA-4711 changes AC*/
                                                         secids = secids+secId.Print_Section_UK__c+','; /*IBA-4711 changes AC*/
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c;
                                                 }
                                                 if(sec == 'Summary Service Only'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Summary Service Only'];  /*IBA-4711: Incorporating additional UK field into the query*/
                                                     /*IBA-4711 changes AC*/
                                                     if(Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP')
                                                         secids = secids+secId.Print_Section_UK__c+',';
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c;
                                                     /*IBA-4711 changes AC*/
                                                 }
                                                 if(sec == 'Summary by Par Location'){
                                                     // System.debug('Section : '+sec);
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Summary_by_Par_Location']; /*IBA-4715: Incorporating additional UK field into the query*/
                                                     //secids = secids+secId.Print_Section_Id__c;
                                                     if(usalist == true) {
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     } else if (Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP') { /*AC - IBA-4715: Initiating changes*/
                                                         secids = secids + secId.Print_Section_UK__c + ',';
                                                     } /*AC - IBA-4715 Changes complete*/  else {
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                     }
                                                 }
                                                 if(sec == 'Detail by Par Location' && quote.Renewal_Revenue__c > 0){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c 
                                                                                         from Conga_Print_Section_Ids__c where Name = 'Detail by Par Location-Renewal']; 
                                                     // secids = secids+secId.Print_Section_Id__c+',';
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                                 else if (sec == 'Detail by Par Location'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Detail by Par Location'];  /*AC - IBA-4715: changes*/
                                                     // secids = secids+secId.Print_Section_Id__c+',';
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c+',';
                                                     else if(Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP')  /*AC - IBA-4715: changes*/
                                                         secids = secids+secId.Print_Section_UK__c+','; /*AC - IBA-4715: changes*/
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c+',';
                                                 }
                                                 if(sec.contains('Print Config')){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c from Conga_Print_Section_Ids__c where Name = 'Print Config Pictures']; 
                                                     secids = secids+secId.Print_Section_Id__c;
                                                     
                                                     /*if(usalist == true)
secids = secids+secId.Print_Section_Id_USA__c;
else
secids = secids+secId.Print_Section_Id__c;*/
                                                 }
                                                 if(sec == 'Detail by Par Location with pictures'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c from Conga_Print_Section_Ids__c where Name = 'Detail by Par Location with pictures']; 
                                                     //secids = secids+secId.Print_Section_Id__c;
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c;
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c;
                                                 }
                                                 if(sec == 'Summary by Par Location with pictures'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id_USA__c,Print_Section_Id__c, Print_Section_UK__c from Conga_Print_Section_Ids__c where Name = 'Summary by Par Location with pictures']; /*IBA-4711: Incorporating additional UK field into the query*/
                                                     //secids = secids+secId.Print_Section_Id__c;
                                                     
                                                     if(usalist == true)
                                                         secids = secids+secId.Print_Section_Id_USA__c;
                                                     else if(Quote.SAP_Sales_Org__r.Sales_Org__c == 'OM31' && Quote.CurrencyIsoCode == 'GBP') /*IBA-4711 changes AC*/
                                                         secids = secids+secId.Print_Section_UK__c;
                                                     else
                                                         secids = secids+secId.Print_Section_Id__c;
                                                 }
                                                 if(sec == 'Detail by Par Location with pictures and signoff'){
                                                     Conga_Print_Section_Ids__c secId = [select Print_Section_Id__c from Conga_Print_Section_Ids__c where Name = 'Detail by Par Location with signoff']; 
                                                     secids = secids+secId.Print_Section_Id__c;
                                                 }
                                                 sections = sections+sec;
                                                 sections2 = sections2+sec;   
                                             }
                                             k=k+1;
                                         }
                                         // System.debug('Sections : '+sections);
                                         //  System.debug('secIds : '+secids);
                                         /********************************************************
Print Exhibits version 1
*********************************************************/
                                         //   for(String ex : selectedExhibits){
                                         /*if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'IVX';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'CRx';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'PSOG';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'EMM';
if(j==4)
qp.Conga_Exhibit_Sequence_4__c = 'ServiceNow';*/
                                         /*  if(j<selectedExhibits.size()-1){
System.debug('j : '+j);
exhibits = exhibits+ex+';';
exhibits2 = exhibits2+ex+',';
if(ex.contains('IVX')){
Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'IVX'];
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'IVX';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'IVX';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'IVX';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'IVX';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'IVX';

ids = ids+exIVX.Conga_Template_Id__c+',';
//ids = ids + 'a1K1k000000O6SO,';
exhibitNames = exhibitNames + 'IVX,';
}
if(ex.contains('CRx')){

Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'CRx Upgrade']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'CRx';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'CRx';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'CRx';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'CRx';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'CRx';
ids = ids+exIVX.Conga_Template_Id__c+',';
//ids = ids + 'a1K1k000000O6SY,';
exhibitNames = exhibitNames + 'CRx Upgrade,';
}
if(ex.contains('PSOG')){

Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'Performance Center (PSOG only)']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'PSOG';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'PSOG';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'PSOG';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'PSOG';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'PSOG';
ids = ids+exIVX.Conga_Template_Id__c+',';
//ids = ids + 'a1K1k000000O6ST,';
exhibitNames = exhibitNames + 'Performance Center (PSOG only),';
}
if(ex.contains('EMM')){

Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'Performance Center (w. EMM)']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'EMM';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'EMM';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'EMM';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'EMM';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'EMM';
ids = ids+exIVX.Conga_Template_Id__c+',';
exhibitNames = exhibitNames+'Performance Center (w. EMM),';
//ids = ids + 'a1K1k000000NWvb,';
}
if(ex.contains('ServiceNow')){


Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'ServiceNow']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'ServiceNow';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'ServiceNow';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'ServiceNow';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'ServiceNow';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'ServiceNow';
ids = ids+exIVX.Conga_Template_Id__c+',';
//ids = ids + 'a1K1k000000O6Sd,';
exhibitNames = exhibitNames+'ServiceNow,';
}
}
else{
exhibits2 = exhibits2+ex;
exhibits = exhibits+ex;
System.debug('j : '+j);
if(ex.contains('IVX')){

Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'IVX']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'IVX';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'IVX';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'IVX';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'IVX';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'IVX';
ids = ids+exIVX.Conga_Template_Id__c;
//ids = ids + 'a1K1k000000O6SO,';
exhibitNames = exhibitNames + 'IVX';
}
if(ex.contains('CRx')){
Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'CRx Upgrade']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'CRx';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'CRx';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'CRx';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'CRx';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'CRx';
ids = ids+exIVX.Conga_Template_Id__c;
exhibitNames = exhibitNames + 'CRx Upgrade';
//ids = ids + 'a1K1k000000O6SY,';
}
if(ex.contains('PSOG')){

Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'Performance Center (PSOG only)']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'PSOG';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'PSOG';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'PSOG';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'PSOG';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'PSOG';
ids = ids+exIVX.Conga_Template_Id__c;
exhibitNames = exhibitNames + 'Performance Center (PSOG only)';
//ids = ids + 'a1K1k000000O6ST,';
}
if(ex.contains('EMM')){
Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'Performance Center (w. EMM)']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'EMM';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'EMM';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'EMM';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'EMM';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'EMM';
ids = ids+exIVX.Conga_Template_Id__c;
exhibitNames = exhibitNames+'Performance Center (w. EMM)';
//ids = ids + 'a1K1k000000NWvb,';
}
if(ex.contains('ServiceNow')){
Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'ServiceNow']; 
if(j==0)
qp.Conga_Exhibit_Sequence_1__c = 'ServiceNow';
if(j==1)
qp.Conga_Exhibit_Sequence_2__c = 'ServiceNow';
if(j==2)
qp.Conga_Exhibit_Sequence_3__c = 'ServiceNow';
if(j==3)
qp.Conga_Exhibit_Sequence_4__c = 'ServiceNow';
if(j==4)
qp.Conga_Exhibit_Sequence_5__c = 'ServiceNow';
ids = ids+exIVX.Conga_Template_Id__c;
exhibitNames = exhibitNames+'ServiceNow';
//ids = ids + 'a1K1k000000O6Sd,';
}
}
j = j+1;
}*/
                                         
                                         /******************************************
Exhibits version : 2 
*******************************************/
                                         Integer exhib = 1;
                                         Integer govtIV = 0;  //SF-BUG-894
                                         String exhibitsnew = '';
                                         List<Exhibits__c> exrec = [select Name,Exhibit_Detail__c from Exhibits__c];
                                         for(String ex : selectedExhibits){
                                             for(Exhibits__c e : exrec){
                                                 if(e.Name == ex){
                                                     if(exhib == 1){
                                                         String replaceExhibitnum = e.Exhibit_Detail__c.replace('SEQUENCE',String.valueof(exhib));
                                                         replaceExhibitnum = replaceExhibitnum.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                                                         //sf-bug-260 soumyad start
                                                         Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                             6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
                                                                 if(quote.Annual_Bill_Date__c!= null){
                                                                     Date d = quote.Annual_Bill_Date__c;
                                                                     String dt = monthNameMap.get(d.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date',dt+' '+String.valueof(d.day()));
                                                                     Date d1 = quote.Annual_Bill_Date__c.adddays(-1);
                                                                     String dt1 = monthNameMap.get(d1.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less',dt1+' '+String.valueof(d1.day()));
                                                                 }else {
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date','------');
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less','------');
                                                                 }
                                                         // soumyad end
                                                         qp.Conga_Exhibit_Detail__c = replaceExhibitnum;
                                                         qp.Conga_Exhibit_Check1__c=true;
                                                         //SF-BUG-894
                                                         if(ex == 'Govt IV') {
                                                             govtIV = exhib;
                                                         }
                                                     }
                                                     if(exhib == 2){
                                                         //System.debug('');
                                                         String replaceExhibitnum = e.Exhibit_Detail__c.replace('SEQUENCE',String.valueof(exhib));
                                                         replaceExhibitnum = replaceExhibitnum.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                                                         //sf-bug-260 soumyad start
                                                         Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                             6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
                                                                 if(quote.Annual_Bill_Date__c!= null){
                                                                     Date d = quote.Annual_Bill_Date__c;
                                                                     String dt = monthNameMap.get(d.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date',dt+' '+String.valueof(d.day()));
                                                                     Date d1 = quote.Annual_Bill_Date__c.adddays(-1);
                                                                     String dt1 = monthNameMap.get(d1.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less',dt1+' '+String.valueof(d1.day()));
                                                                 }else {
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date','------');
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less','------');
                                                                 }
                                                         // soumyad end
                                                         qp.Conga_Exhibit_Detail1__c = replaceExhibitnum;
                                                         qp.Conga_Exhibit_Check2__c=true;
                                                         //SF-BUG-894
                                                         if(ex == 'Govt IV') {
                                                             govtIV = exhib;
                                                         }
                                                     }
                                                     if(exhib == 3){
                                                         String replaceExhibitnum = e.Exhibit_Detail__c.replace('SEQUENCE',String.valueof(exhib));
                                                         replaceExhibitnum = replaceExhibitnum.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                                                         //sf-bug-260 soumyad start
                                                         Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                             6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
                                                                 if(quote.Annual_Bill_Date__c!= null){
                                                                     Date d = quote.Annual_Bill_Date__c;
                                                                     String dt = monthNameMap.get(d.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date',dt+' '+String.valueof(d.day()));
                                                                     Date d1 = quote.Annual_Bill_Date__c.adddays(-1);
                                                                     String dt1 = monthNameMap.get(d1.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less',dt1+' '+String.valueof(d1.day()));
                                                                 }else {
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date','------');
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less','------');
                                                                 }
                                                         // soumyad end
                                                         qp.Conga_Exhibit_Detail2__c = replaceExhibitnum;
                                                         qp.Conga_Exhibit_Check3__c=true;
                                                         //SF-BUG-894
                                                         if(ex == 'Govt IV') {
                                                             govtIV = exhib;
                                                         }
                                                     }
                                                     if(exhib == 4){
                                                         String replaceExhibitnum = e.Exhibit_Detail__c.replace('SEQUENCE',String.valueof(exhib));
                                                         replaceExhibitnum = replaceExhibitnum.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                                                         //sf-bug-260 soumyad start
                                                         Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                             6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
                                                                 if(quote.Annual_Bill_Date__c!= null){
                                                                     Date d = quote.Annual_Bill_Date__c;
                                                                     String dt = monthNameMap.get(d.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date',dt+' '+String.valueof(d.day()));
                                                                     Date d1 = quote.Annual_Bill_Date__c.adddays(-1);
                                                                     String dt1 = monthNameMap.get(d1.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less',dt1+' '+String.valueof(d1.day()));
                                                                 }else {
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date','------');
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less','------');
                                                                 }
                                                         // soumyad end
                                                         qp.Conga_Exhibit_Detail3__c = replaceExhibitnum;
                                                         qp.Conga_Exhibit_Check4__c=true;
                                                         //SF-BUG-894
                                                         if(ex == 'Govt IV') {
                                                             govtIV = exhib;
                                                         }
                                                     }
                                                     if(exhib == 5){
                                                         String replaceExhibitnum = e.Exhibit_Detail__c.replace('SEQUENCE',String.valueof(exhib));
                                                         replaceExhibitnum = replaceExhibitnum.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                                                         //sf-bug-260 soumyad start
                                                         Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                             6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
                                                                 if(quote.Annual_Bill_Date__c!= null){
                                                                     Date d = quote.Annual_Bill_Date__c;
                                                                     String dt = monthNameMap.get(d.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date',dt+' '+String.valueof(d.day()));
                                                                     Date d1 = quote.Annual_Bill_Date__c.adddays(-1);
                                                                     String dt1 = monthNameMap.get(d1.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less',dt1+' '+String.valueof(d1.day()));
                                                                 }else {
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date','------');
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less','------');
                                                                 }
                                                         // soumyad end
                                                         qp.Conga_Exhibit_Detail4__c = replaceExhibitnum;
                                                         qp.Conga_Exhibit_Check5__c=true;
                                                         //SF-BUG-894
                                                         if(ex == 'Govt IV') {
                                                             govtIV = exhib;
                                                         }
                                                     }
                                                     //sf-bug-260 soumyad start
                                                     if(exhib == 6){
                                                         String replaceExhibitnum = e.Exhibit_Detail__c.replace('SEQUENCE',String.valueof(exhib));
                                                         replaceExhibitnum = replaceExhibitnum.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                                                         Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                             6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
                                                                 if(quote.Annual_Bill_Date__c!= null){
                                                                     Date d = quote.Annual_Bill_Date__c;
                                                                     String dt = monthNameMap.get(d.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date',dt+' '+String.valueof(d.day()));
                                                                     Date d1 = quote.Annual_Bill_Date__c.adddays(-1);
                                                                     String dt1 = monthNameMap.get(d1.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less',dt1+' '+String.valueof(d1.day()));
                                                                 }else {
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date','------');
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less','------');
                                                                 }
                                                         qp.Conga_Exhibit_Detail5__c = replaceExhibitnum;
                                                         qp.Conga_Exhibit_Check6__c=true;
                                                         //SF-BUG-894
                                                         if(ex == 'Govt IV') {
                                                             govtIV = exhib;
                                                         }
                                                     }
                                                     // soumyad end
                                                     //soumyad start omnicell one 964
                                                     if(exhib == 7){
                                                         String replaceExhibitnum = e.Exhibit_Detail__c.replace('SEQUENCE',String.valueof(exhib));
                                                         replaceExhibitnum = replaceExhibitnum.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                                                         Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                             6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
                                                                 if(quote.Annual_Bill_Date__c!= null){
                                                                     Date d = quote.Annual_Bill_Date__c;
                                                                     String dt = monthNameMap.get(d.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date',dt+' '+String.valueof(d.day()));
                                                                     Date d1 = quote.Annual_Bill_Date__c.adddays(-1);
                                                                     String dt1 = monthNameMap.get(d1.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less',dt1+' '+String.valueof(d1.day()));
                                                                 }else {
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date','------');
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less','------');
                                                                 }
                                                         qp.Conga_Exhibit_Detail6__c = replaceExhibitnum;
                                                         qp.Conga_Exhibit_Check7__c=true;
                                                         //SF-BUG-894
                                                         if(ex == 'Govt IV') {
                                                             govtIV = exhib;
                                                         }
                                                         
                                                         //    System.debug('Selected exhibits omnii one: ');
                                                     }
                                                     if(exhib == 8){
                                                         String replaceExhibitnum = e.Exhibit_Detail__c.replace('SEQUENCE',String.valueof(exhib));
                                                         replaceExhibitnum = replaceExhibitnum.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                                                         Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                             6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October', 11=>'November', 12=>'December'};
                                                                 if(quote.Annual_Bill_Date__c!= null){
                                                                     Date d = quote.Annual_Bill_Date__c;
                                                                     String dt = monthNameMap.get(d.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date',dt+' '+String.valueof(d.day()));
                                                                     Date d1 = quote.Annual_Bill_Date__c.adddays(-1);
                                                                     String dt1 = monthNameMap.get(d1.month());
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less',dt1+' '+String.valueof(d1.day()));
                                                                 }else {
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_Date','------');
                                                                     replaceExhibitnum = replaceExhibitnum.replace('Annual_Bill_less','------');
                                                                 }
                                                         qp.Conga_Exhibit_Detail7__c = replaceExhibitnum;
                                                         qp.Conga_Exhibit_Check8__c=true;
                                                         //SF-BUG-894
                                                         if(ex == 'Govt IV') {
                                                             govtIV = exhib;
                                                         }
                                                         
                                                         //    System.debug('Selected exhibits omnii one: ');
                                                     }
                                                     // soumyad end omnicell one 964
                                                 }
                                             }
                                             
                                             exhib = exhib+1;
                                         }
                                         // System.debug('Selected exhibits : '+selectedExhibits);
                                         if(selectedExhibits.size()>0 && selectedExhibits[0] != ''){
                                             //   System.debug('Inside selected exhibits');
                                             Conga_Exhibit_IDs__c exIVX = [select Conga_Template_Id__c from Conga_Exhibit_IDs__c where Name = 'ServiceNow'];
                                             ids = ids+exIVX.Conga_Template_Id__c;
                                             // qp.Conga_Exhibit_Detail__c = exhibitsnew;
                                         }
                                         Integer serviceNownum = 0;
                                         Integer crxnum = 0;
                                         //  Integer oc_cloud = 0;//IBA-1527
                                         Integer ivx = 0;/*Added by sravan for Canned lan fixes*/
                                         Integer simp = 0;/*Added by sravan for Canned lan fixes*/
                                         Integer perf = 0;/*Added by sravan for Canned lan fixes*/
                                         Integer loopvar = 1;
                                         for(String ex : selectedExhibits){
                                             if(ex == 'CRx Upgrade')
                                                 crxnum = loopvar;
                                             if(ex == 'ServiceNow')
                                                 serviceNownum = loopvar;
                                             /*Added by sravan for Canned lan fixes START*/
                                             if(ex == 'IVX')
                                                 ivx = loopvar;
                                             if(ex == 'Simplifi 797')
                                                 simp = loopvar;
                                             if(ex == 'Performance Center (PSOG only)')
                                                 perf = loopvar;
                                             /*    if(ex == 'Cloud-Based Services')//Added by Sourav IBA-1527
oc_cloud = loopvar;*/
                                             /*Added by sravan for Canned lan fixes END*/
                                             loopvar = loopvar+1;
                                         }
                                         if(selectedExhibits.size()>0){
                                             //qp.Check_Select_Canned_Language__c = true;
                                             String exh='';
                                             for(Integer loopvar1=0;loopvar1<selectedExhibits.size();loopvar1++){
                                                 if(loopvar1 != selectedExhibits.size()-1)
                                                     exh = exh+selectedExhibits[loopvar1]+',';
                                                 else
                                                     exh = exh+selectedExhibits[loopvar1];
                                                 
                                                 
                                             }
                                             qp.selectedExhibitNames__c = exh;
                                             //  System.debug('Past Exhibits'+qp.selectedExhibitNames__c);
                                         }
                                         
                                         
                                         
                                         
                                         
                                         //    System.debug('Exhibits :'+exhibits);
                                         //     System.debug('Inside Update Quote');
                                         //  System.debug('slectedCannedLan : '+selectedCannedLan);
                                         
                                         List<Canned_Language__c> clan = new List<Canned_Language__c>();
                                         if(layout == 'Omnicell' || layout == 'Change Order Omnicell'){
                                             clan = [select id,name,Canned_Language_Detail__c from Canned_Language__c where Omnicell_or_Aesynt__c= 'Omnicell' order by Canned_language_sequence__c asc ];
                                         }
                                         else{
                                             clan = [select id,name,Canned_Language_Detail__c from Canned_Language__c where Omnicell_or_Aesynt__c= 'Aesynt' order by Canned_language_sequence__c asc];
                                         }
                                         if(selectedCannedLan.size()>0){
                                             qp.Check_Select_Canned_Language__c = true;
                                             String pastcannLan='';
                                             for(Integer loopvar1=0;loopvar1<selectedCannedLan.size();loopvar1++){
                                                 if(loopvar1 != selectedCannedLan.size()-1)
                                                     pastcannLan = pastcannLan+selectedCannedLan[loopvar1]+',';
                                                 else
                                                     pastcannLan = pastcannLan+selectedCannedLan[loopvar1];
                                                 
                                                 
                                             }
                                             qp.SelectedCannedLanguageNames__c = pastcannLan;
                                             //   System.debug('Past Canned Lan'+qp.SelectedCannedLanguageNames__c);
                                         }
                                         //Canned Language
                                         Integer ik =1;
                                         Boolean conrx = false;
                                         Boolean Omni_essen = false; // soumyad SF-Bug-1148
                                         /*Added by sravan for Canned lan fixes START*/
                                         boolean ivprd = false;
                                         boolean simplifi = false;
                                         boolean perfcentr = false;
                                         Boolean win10 = false; //SF-BUG-934
                                         
                                         //Remove for IBA-4189
                                         Boolean mithunsignprcsup = false; //IBA-3872
                                         Boolean miDeliveryPercent = false; //IBA-4749 AC
                                         Boolean mithunsignbonagg = false; //IBA-3872
                                         Boolean mitFourtyPsSig = false; //IBA-3872
                                         Boolean mitfourtyOrder = false; //IBA-3872
                                         Boolean mitfourtyDel = false;//IBA-3872
                                         
                                         Boolean mitHundredDownPay = false; //IBA-3872
                                         list<Small_Parts_Addl_product__c> smp = [select DW_prod__c,SAP_prod__c,DW_prod_type__c from Small_Parts_Addl_product__c]; //soumyad sf-bug-905
                                         
                                         boolean sflag = false; //soumyad sf-bug-905
                                         //soumyad start 905
                                         Map<String,list<Small_Parts_Addl_product__c>> linemapq3 = new Map<String,list<Small_Parts_Addl_product__c>>();
                                         
                                         for(Small_Parts_Addl_product__c s : smp)
                                         {
                                             
                                             if(linemapq3.containsKey(s.SAP_prod__c)){
                                                 List<Small_Parts_Addl_product__c> proList=linemapq3.get(s.SAP_prod__c);
                                                 proList.add(s);
                                                 linemapq3.put(s.SAP_prod__c, proList);
                                             }
                                             else{
                                                 linemapq3.put(s.SAP_prod__c, new List<Small_Parts_Addl_product__c>{s});
                                             }
                                             system.debug(linemapq3);
                                         }
                                         //soumyad start 905
                                         
                                         /*Added by sravan for Canned lan fixes START*/
                                         List<quote_line__c> qlines = [select id,product__c,Product_Code__c,Higher_Level_Item__c,product__r.portfolio_segment__c,product__r.DW_Product_Line__c,product__r.Business_Line__c,product__r.SAP_Product_Type__c,product__r.DW_Product_Type__c from quote_line__c where quote__c=:quoteId]; //soumyad sf-bug-905 change query, added new field for IBA-1527
                                         List<Win_10_Canned_Language_Product__c> win = [Select Product_Name__c From Win_10_Canned_Language_Product__c];  ////SF-BUG-934 by Sourav
                                         for(Quote_Line__c q:qlines){
                                             //Modified for SF-BUG-1069
                                             if(q.product__r.DW_Product_Line__c != Null){
                                                 if(q.product__r.DW_Product_Line__c == 'Connect-Rx' && q.Higher_Level_Item__c == 0){//Added logic for parent item for IBA-1527
                                                     conrx = true;
                                                 }
                                                 //     System.debug('conrx : '+conrx);
                                                 /*Added by sravan for Canned lan fixes START*/
                                                 String dwprdline = q.product__r.DW_Product_Line__c;
                                                 if(q.product__r.portfolio_segment__c != null){
                                                     String portfolio = q.product__r.portfolio_segment__c;    
                                                     //if(dwprdline.contains('i.v')){
                                                     if(portfolio.contains('IV') && q.product__r.DW_Product_Line__c != 'Simplifi 797'){
                                                         ivprd = true;
                                                     }
                                                 }
                                                 if(q.product__r.DW_Product_Line__c == 'Simplifi 797' && q.product__r.portfolio_segment__c == 'IV Legacy' || q.product__r.DW_Product_Line__c == 'Simplifi 797' && q.product__r.portfolio_segment__c == 'IVX Workflow' || q.product__r.DW_Product_Line__c == 'Simplifi 797' && q.product__r.portfolio_segment__c == 'IV Compounding Service'){//Updated by Abhrajitc IBA-1652
                                                     simplifi = true;
                                                 }
                                                 //Remove for IBA-4189
                                                 //soumyad SF-Bug-1148 start
                                                 if(q.product__r.DW_Product_Line__c == 'Omnicell Essentials' && q.Higher_Level_Item__c == 0){//Added logic for parent item for IBA-1527
                                                     Omni_essen = true;
                                                 }
                                                 //soumyad SF-Bug-1148 end
                                             }
                                             for(Win_10_Canned_Language_Product__c w :win) //SF-BUG-934 start by Sourav
                                             {
                                                 if(q.Product_Code__c == w.Product_Name__c) 
                                                 {
                                                     win10 = true;
                                                 } 
                                             }                               //SF-BUG-934 End by Sourav
                                             /*if(q.product__r.DW_Product_Line__c == 'Performance Center'){
perfcentr = true;
}*///Commented as 727 is not required
                                             /*Added by sravan for Canned lan fixes END*/
                                             //soumyad sf-bug-905 start
                                             if(sflag==false){
                                                 list<Small_Parts_Addl_product__c> smp1 = linemapq3.get(q.product__r.SAP_Product_Type__c);
                                                 if(smp1 != null){
                                                     for(Small_Parts_Addl_product__c s : smp1){
                                                         
                                                         if(s.DW_prod__c == Null){
                                                             
                                                             
                                                             if(s.DW_prod_type__c == Null){                                                
                                                                 if(s.SAP_prod__c == q.product__r.SAP_Product_Type__c){
                                                                     sflag = true;
                                                                 }
                                                             }else if(s.SAP_prod__c == q.product__r.SAP_Product_Type__c){
                                                                 if(s.DW_prod_type__c == q.product__r.DW_Product_Type__c){
                                                                     sflag = true;
                                                                 }
                                                             }
                                                         }else if(s.DW_prod__c == q.product__r.DW_Product_Line__c){
                                                             if(s.SAP_prod__c == q.product__r.SAP_Product_Type__c){
                                                                 if(s.DW_prod_type__c == q.product__r.DW_Product_Type__c){
                                                                     sflag = true;
                                                                 }
                                                             }
                                                         }
                                                     }
                                                 }
                                             }
                                             //soumyad sf-bug-905 end
                                         }
                                         //IBA-3872 Abhrajitc Starts
                                         if(quote.Milestone_Invoice_Term__c != null){
                                             if(quote.Milestone_Invoice_Term__c == '22'){
                                                 mithunsignprcsup = true;
                                             }
                                             if(quote.Milestone_Invoice_Term__c == '23'){
                                                 mitFourtyPsSig = true;
                                             }
                                             if(quote.Milestone_Invoice_Term__c == '24'){
                                                 mithunsignbonagg = true;
                                             }
                                             if(quote.Milestone_Invoice_Term__c == '25'){
                                                 mitfourtyOrder = true;
                                             }
                                             if(quote.Milestone_Invoice_Term__c == '26'){
                                                 mitfourtyDel = true;
                                             }
                                             
                                             if(quote.Milestone_Invoice_Term__c == '14' &&!quote.CONGA_Is_US_Opportunity_Type__c){  /*IBA-4749 Change AC*/
                                                 
                                                 mitHundredDownPay = true;
                                             }
                                             /*IBA-4749 Change AC*/
                                             if(quote.Milestone_Invoice_Term__c == '21' && !quote.CONGA_Is_US_Opportunity_Type__c){
                                                 miDeliveryPercent = true;
                                             }
                                             /*IBA-4749 Change AC*/
                                         }//IBA-3872 Abhrajitc Ends
                                         // System.debug('Layout : '+layout);
                                         
                                         //Canned Language
                                         boolean ins = false; // soumyad sf-bug-905
                                         for(Canned_Language__c c: clan){
                                             //  System.debug('Clan : '+clan);
                                             qp.Check_Select_Canned_Language__c = true;
                                             if(layout == 'Omnicell' || layout == 'Change Order Omnicell'){
                                                 //       System.debug('Inside Mandatory canned lan : '+c.Name);
                                                 
                                                 //if(c.Name == 'Support Services PO (Omnicell)'){
                                                 if(c.Name == 'Non-GA Waiver' && quote.Order_Type__c != 'ZQRS'){ //IBA-4072
                                                     //        System.debug('Inside Support Services');
                                                     //terms=terms+'1'+'. '+c.Canned_Language_Detail__c+'<br/>';//Commented for SF-BUG-1008 by Sourav and added next two line
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 
                                                 //Remove for IBA-4189
                                                 
                                                 //if(c.Name == 'Omnicell has made no commitment'){
                                                 /* if(c.Name == 'SS: PO at Sign.'){
terms = terms+'2'+'. '+c.Canned_Language_Detail__c+'<br/>';
}
//if(c.Name == 'Support Services Delay (Omnicell)'){
if(c.Name == 'SS: Cust. Delay'){
terms = terms+'3'+'. '+c.Canned_Language_Detail__c+'<br/>';
}*/ //Commented by Sourav for SF-Bug-1035
                                                 /*Added by sravan for Canned lan fixes START*/
                                                 if(c.Name == Label.Simplifi_797){
                                                     if(simplifi == true){
                                                         //terms = terms+'2'+'. '+c.Canned_Language_Detail__c+'<br/>';//Commented for SF-BUG-1008 by Sourav and added next two line
                                                         terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                         ik = ik+1;
                                                     }
                                                 }
                                                 if(c.Name == Label.IV_Products){
                                                     if(ivprd == true && simplifi == true){
                                                         //terms = terms+'3'+'. '+c.Canned_Language_Detail__c+'<br/>';//Commented for SF-BUG-1008 by Sourav and added next two line
                                                         terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                         ik = ik+1;
                                                     }
                                                     else if(ivprd == true){
                                                         //terms = terms+'2'+'. '+c.Canned_Language_Detail__c+'<br/>';//Commented for SF-BUG-1008 by Sourav and added next two line
                                                         terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                         ik = ik+1;
                                                     }
                                                     
                                                 }
                                                 /*if(c.Name == Label.Performance_Center){
if(perfcentr == true){
if(ivprd == true && simplifi == true)
terms = terms +'6'+'. '+c.Canned_Language_Detail__c+'<br/>';
else
terms = terms +'5'+'. '+c.Canned_Language_Detail__c+'<br/>';
}
}
if(ivprd == true && simplifi == true && perfcentr == true){
ik = 7;
}*///commented as 727 is not required
                                                 //else //commented as 727 is not required
                                                 /*
if(ivprd == true && simplifi == true ){
//ik = 6;//commented as 727 is not required
ik = 4;//SF-BUG-1035
}
else if(ivprd == true || simplifi == true){
//ik = 5;//commented as 727 is not required
ik = 3;//SF-BUG-1035
}
else{
ik = 2;

}*///commented out for New-1035
                                                 
                                                 /*Added by sravan for Canned lan fixes END*/
                                                 // soumyad start sf-bug-753
                                                 if(c.Name == 'CRx Upg.' && conrx == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;    
                                                 }
                                                 //     System.debug('a terms' +terms);
                                                 // soumyad start sf-bug-753
                                                 // soumyad start sf-bug-905
                                                 if(c.Name == 'Small Parts' && quote.Small_Parts_pre_approved__c == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;    
                                                     //       System.debug('sml terms' +ik+' '+c.Name);
                                                 }
                                                 //     System.debug('sml adl terms' +ik);
                                                 if(c.Name == 'Small Parts Addl' && quote.Small_Parts_pre_approved__c == true && sflag == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;    
                                                     //       System.debug('sml adl terms' +ik+' '+c.Name);
                                                 }
                                                 
                                                 // soumyad end sf-bug-905
                                                 //       System.debug('Win10 terms' +terms);   //SF-BUG-934 start added by Sourav
                                                 if(c.Name == 'Win 10 language' && win10 == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;    
                                                 }
                                                 /*//IBA-4639 Start
if(c.Name=='Non-GA product - XTE'&& Non_GA_prod_XTE_flag==true){
terms = terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
ik = ik+1;  
}
//IBA-4639 End */ //Commenting out for IBA-4961 Saptarsha Panthi
                                                 
                                                 //IBA-4603 Start
                                                 if(c.Name=='Formulary Tool Kit Studies IV'&& FTK_study_skus_flag == true){
                                                     terms = terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;  
                                                 }
                                                 //IBA-4603 End
                                                 //IBA-3889 Start (Saptarsha)
                                                 if(c.Name=='De-Installation New'&& DeInstallation_flag == true){
                                                     terms = terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;  
                                                 }
                                                 //IBA-3889 End (Saptarsha)
                                                 //IBA-5879 Start Saptarsha Panthi
                                                 if(c.Name=='Pre-GA Product'&& MedChill_flag == true){
                                                     terms = terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;  
                                                 }
                                                 //IBA-5879 End Saptarsha Panthi
                                             /*    if(c.Name == 'Cloud-Based Services' && oc_prod_flag == true){//Added by Sourav IBA-1527
                                                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                        ik = ik+1;    

                                                 }
                                                 //IBA-5879 End Saptarsha Panthi
                                                 /*    if(c.Name == 'Cloud-Based Services' && oc_prod_flag == true){//Added by Sourav IBA-1527
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
ik = ik+1;    
}
if(c.Name == 'Cloud-Hosted OmniCenter' && oc_prod_flag == true){//Added by Sourav IBA-1527
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
ik = ik+1;    
} */ // commented out for IBA-3614 
                                                 if(c.Name == 'Repl. Product' && replacement_products_flag == true){//Added by Prithan IBA-1789
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     System.debug('***'+terms);
                                                     ik = ik+1;    
                                                 }if(c.Name == 'SS: Ext. Win 7 Support' && win7_flag == true){//Added by Prithan IBA-2596
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     System.debug('***'+terms);
                                                     ik = ik+1;    
                                                 }// IBA-3614 starts 
                                                 if(c.Name == 'Software Licensing' && sku_prod_flag == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     System.debug('***'+terms);
                                                     ik = ik+1;    
                                                 }
                                                 if(c.Name == 'PT: Software Subscription' && sku_prod_flag == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     System.debug('***'+terms);
                                                     ik = ik+1;    
                                                 }
                                                 // IBA-3614 ends 
                                                 
                                                 // IBA-4020 ends
                                                 if(c.Name == 'Software Licensing OC' && oc_sku_prod_flag == true  && quote.Order_Type__c != 'ZQRS'){ //IBA-4072
                                                     //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     terms=terms+ik+'. ';
                                                     if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                                         terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>'; 
                                                     else 
                                                         terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                                     //System.debug(' **IKSL '+ ik+' ***SH'+terms);
                                                     ik = ik+1;    
                                                 }
                                                 if(c.Name == 'PT: Software Subscription OC' && oc_sku_prod_flag == true  && quote.Order_Type__c != 'ZQRS'){ //IBA-4072
                                                     //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     terms=terms+ik+'. ';
                                                     if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                                         terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                                     else 
                                                         terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                                     //System.debug(' **IKSS '+ ik+' ***'+terms);
                                                     ik = ik+1;    
                                                 }
                                                 // IBA-4020 ends
                                                 
                                                 // IBA-4072 starts
                                                 if(cma_flag == false && quote.Order_Type__c == 'ZQRS'){
                                                     if(c.Name == 'ASA Installation Plan Approval' && installation_sku_flag == true && quote.Order_Type__c == 'ZQRS'){
                                                         //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                         //terms=terms+ik+'. ';
                                                         if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                                             terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                                         else 
                                                             terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                                         System.debug(' **IF ASA ');
                                                         System.debug(' **IKSLIf '+ ik+' ***SH'+terms);
                                                         ik = ik+1;    
                                                     }
                                                 }else{
                                                     if(quote.Order_Type__c != 'ZQRS'){
                                                         if(c.Name == 'CMA Installation Plan Approval' && installation_sku_flag == true ){
                                                             //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                             terms=terms+ik+'. ';
                                                             if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                                                 terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                                             else 
                                                                 terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                                             System.debug(' **cma_flag CMA '+ cma_flag+' *** '+ ' terms: '+ terms);
                                                             System.debug(' **IKSSElsePurchaseQuote '+ ik+' ***'+terms);
                                                             ik = ik+1;    
                                                         }
                                                     }else{                                                         
                                                         if(c.Name == 'CMA Installation Plan Approval' && installation_sku_flag == true ){
                                                             //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                             //terms=terms+ik+'. ';
                                                             if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                                                 terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                                             else 
                                                                 terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                                             //System.debug(' **cma_flag CMA '+ cma_flag+' *** '+ ' terms: '+ terms);
                                                             //System.debug(' **IKSSElse '+ ik+' ***'+terms);
                                                             ik = ik+1;    
                                                         }
                                                     }
                                                 }                                                 
                                                 
                                                 //System.debug(' **Out of if else cma_flag '+ cma_flag+' *** '+ ' terms: '+ terms);                                                 
                                                 if(c.Name == 'CAD Provision' && cad_sku_flag == true && quote.Order_Type__c != 'ZQRS' && installation_sku_flag != true){
                                                     //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     terms=terms+ik+'. ';
                                                     if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                                         terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                                     else 
                                                         terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                                     //System.debug(' **IKSS '+ ik+' ***'+terms);
                                                     ik = ik+1;    
                                                 }
                                                 // IBA-4072 ends
                                                 
                                                 //        System.debug('a terms' +terms);    //SF-BUG-934 end
                                                 
                                                 //soumyad SF-Bug-1148 start
                                                 System.debug('canned lang ' +c.Name+ ' Omni_essen  '+Omni_essen);
                                                 if(c.Name == 'Omnicell essentials' && Omni_essen == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;    
                                                     System.debug('omni essen ' +c.Canned_Language_Detail__c);
                                                 }
                                                 //soumyad SF-Bug-1148 end
                                                 //IBA-3872 Abhrajitc Starts
                                                 if(c.Name == 'MI: 100% signing Supplement' && mithunsignprcsup == true){
                                                     terms=terms+ik+'.'+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 if(c.Name == 'MI: 40% PS Signature & 60% Bonding Agreement' && mitFourtyPsSig == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 if(c.Name == 'MI: 100% signed Bonding Agreement' && mithunsignbonagg == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 if(c.Name == 'MI: 40% Order 40% Delivery & 20% Acceptance' && mitfourtyOrder == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 if(c.Name == 'MI: 40% Order 40% Pre Delivery & 20% Accept' && mitfourtyDel == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 if(c.Name == 'MI: 100% on Down Payment' && mitHundredDownPay == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 } //IBA-3872 Abhrajitc Ends
                                                 /*IBA-4749 Change AC*/
                                                 if(c.Name == 'MI: 100% on Delivery' && miDeliveryPercent == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 /*IBA-4749 Change AC*/
                                                 //IBA-5821 Start
                                                 if((c.Name=='Subscription- On Premise' || c.Name=='Pre-GA Product' || c.Name=='Disbursed Support Services for Delivered Products') && supplyX == true){
                                                     terms=terms+ik+'. ';
                                                     if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                                         terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                                     else 
                                                         terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 //IBA-5821 End
                                                 
                                                 //IBA-5880 Starts SH
                                                 if(c.Name == 'DataStation Standalone Software' && DataStation_flag == true){
                                                     terms=terms+ik+'. ';
                                                     if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                                         terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                                     else 
                                                         terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 //IBA-5880 Ends SH
                                             }
                                             
                                             if(layout == 'Aesynt' || layout == 'Change Order Aesynt'){
                                                 //             System.debug('Inside Mandatory canned lan Aesynt: ');
                                                 if(c.Name == 'Definitions')
                                                     terms=terms+'1'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                 //if(c.Name == 'Aesynt has made no commitment')
                                                 if(c.Name == 'Non-GA Waiver (A)')    
                                                     terms=terms+'2'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                 //if(c.Name == 'Support Services PO (Aesynt)')
                                                 if(c.Name == 'SS: PO at Sign. (A)')
                                                     terms=terms+'3'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                 //if(c.Name == 'Support Services Delay (Aesynt)')
                                                 if(c.Name == 'SS: Cust. Delay (A)')
                                                     terms=terms+'4'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                 /*Added by sravan for Canned lan fixes START*/
                                                 if(c.Name == Label.Simplifi_797){
                                                     if(simplifi == true){
                                                         terms = terms+'5'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     }
                                                 }
                                                 if(c.Name == Label.IV_Products){
                                                     if(ivprd == true && simplifi == true){
                                                         terms = terms+'6'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     }
                                                     else{
                                                         terms = terms+'5'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     }
                                                     
                                                 }
                                                 if(c.Name == Label.Performance_Center){
                                                     if(perfcentr == true){
                                                         if(ivprd == true && simplifi == true)
                                                             terms = terms +'7'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                         else
                                                             terms = terms +'6'+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     }
                                                 }
                                                 if(ivprd == true && simplifi == true && perfcentr == true){
                                                     ik = 8;
                                                 }
                                                 else if(ivprd == true && simplifi == true ){
                                                     ik = 7;
                                                 }
                                                 else
                                                     ik = 6;
                                                 /*Added by sravan for Canned lan fixes END*/
                                                 if(c.Name == 'SS: ServiceNow' && quote.Service_Level__c == 'AN'){
                                                     //             System.debug('Inside servicenow');
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;
                                                 }
                                                 if(c.Name == 'CRx Upg.' && conrx == true){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ik = ik+1;    
                                                 }
                                             }
                                         }
                                         
                                         
                                         Integer rebateCreditIndex = 1;
                                         String rebateCreditTerms = '';
                                         qp.Select_Credit_Rebate_Language__c = '';
                                         for(String s: selectedCannedLan){
                                             
                                             for(Canned_Language__c c: clan){
                                                 
                                                 if(c.Name == s && (s == 'Credit Approval' || s == 'Rebate Letter (SOW)' || s == 'Rebate Letter (SUP)'))
                                                 {
                                                     qp.Check_Rebate_Credit_Language__c = true;
                                                     rebateCreditTerms = rebateCreditTerms+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+rebateCreditIndex+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     qp.Select_Credit_Rebate_Language__c = rebateCreditTerms;
                                                     rebateCreditIndex = rebateCreditIndex + 1;
                                                 }
                                                 // for(ik=0;ik<jk;ik++){
                                                 //          System.debug('ik : '+ik);
                                                 if(c.Name == s){
                                                     terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     //                  System.debug('Cann detail ; '+c.Canned_Language_Detail__c);
                                                     
                                                     /*if(ik == 1){
System.debug('Inside Ik');

if(s.contains('Development Product(Omnicell)')){   
System.debug('Inside If replace check');
String replaced;
if(quote.Conga_Supplement__c != null)
replaced = c.canned_language_detail__c.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
else
replaced = c.Canned_Language_Detail__c;


terms=ik+'. '+terms+replaced+'<br/>';  
System.debug('terms: '+terms);
}
else if(s.contains('ServiceNow')){
String replaced = c.Canned_Language_Detail__c.replace('Exhibit No.',String.valueof(serviceNownum));
terms=ik+'. '+terms+replaced+'<br/>';
}else if(s.contains('Connect-RX Upgrade')){
String replaced = c.Canned_Language_Detail__c.replace('Exhibit No.',String.valueof(crxnum));
terms=ik+'. '+terms+replaced+'<br/>';
}else if(s.contains('Classic Hardware EOL â€“Lease')){
if(quote.EOL_Date__c != null){
String dtmmddyy = quote.EOL_Date__c.format('MM/dd/yyyy');
String replaced = c.Canned_Language_Detail__c.replace('EOL Date',String.valueof(dtmmddyy)); 
terms=ik+'. '+terms+replaced+'<br/>';
}
else{
String replaced = c.Canned_Language_Detail__c.replace('EOL Date','');
terms=ik+'. '+terms+replaced+'<br/>';    
}
}else if(s.contains('Fee Increase')){
String replaced;
if(quote.Fee_Increase__c != null)
replaced = c.Canned_Language_Detail__c.replace('Fee Increase:',String.valueof(quote.Fee_Increase__c));
else
replaced = c.Canned_Language_Detail__c;


terms=ik+'. '+terms+replaced+'<br/>';
}else if(s.contains('Omnicell Capital Program')){
String replaced;
if(quote.Master_Agreement__c != null)
replaced = c.Canned_Language_Detail__c.replace('QUOTE_MASTER_AGREEMENT',quote.Master_Agreement__c);
else
replaced = c.Canned_Language_Detail__c;

terms=ik+'. '+terms+replaced+'<br/>';
}else{
terms = ik+'. '+terms+c.Canned_Language_Detail__c+'<br/>';
System.debug('Inside else replace check');
}
}*/
                                                     //else{
                                                     
                                                     /*  if(s.contains('Development Product(Aesynt)') || s.contains('Development Product(Omnicell)')){    
System.debug('Inside If replace check');
String replaced;
if(quote.Conga_Supplement__c != null)
replaced = c.canned_language_detail__c.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
else
replaced = c.Canned_Language_Detail__c;


terms=terms+ik+'. '+replaced+'<br/>';  
System.debug('Terms : '+terms);
}
else if(s.contains('ServiceNow')){
String replaced = c.Canned_Language_Detail__c.replace('Exhibit No.',String.valueof(serviceNownum));
terms=terms+ik+'. '+replaced+'<br/>';
}else if(s.contains('Connect-RX Upgrade')){
String replaced = c.Canned_Language_Detail__c.replace('Exhibit No.',String.valueof(crxnum));
terms=terms+ik+'. '+replaced+'<br/>';
}else if(s.contains('Classic Hardware EOL â€“Lease')){
if(quote.EOL_Date__c != null){
String dtmmddyy = quote.EOL_Date__c.format('MM/dd/yyyy');
String replaced = c.Canned_Language_Detail__c.replace('EOL Date',String.valueof(dtmmddyy));
terms=terms+ik+'. '+replaced+'<br/>';
}
else{
String replaced = c.Canned_Language_Detail__c.replace('EOL Date','');
terms=terms+ik+'. '+replaced+'<br/>'; 
}
}else if(s.contains('Fee Increase')){
String replaced;
if(quote.Fee_Increase__c != null)
replaced = c.Canned_Language_Detail__c.replace('Fee Increase:',String.valueof(quote.Fee_Increase__c));
else
replaced = c.Canned_Language_Detail__c;


terms=terms+ik+'. '+replaced+'<br/>';
}else if(s.contains('Omnicell Capital Program')){
System.debug('Inside Omnicell Capital program');
String replaced;
if(quote.Master_Agreement__c != null)
replaced = c.Canned_Language_Detail__c.replace('QUOTE_MASTER_AGREEMENT',quote.Master_Agreement__c);
else
replaced = c.Canned_Language_Detail__c;
//terms=ik+'. '+terms+replaced+'<br/>'; 
terms=terms+ik+'. '+replaced+'<br/>'; 
}else
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';

// }
//ik++;
//break;*/
                                                 }
                                                 //jk++;
                                             }
                                             // }
                                             ik= ik+1;
                                             //cannedLanguage = cannedLanguage + s+';';
                                             //canned2 = canned2+s+', ';
                                             
                                             
                                             
                                             /*else{
if(s.contains('Generally')){
terms = terms + 'Omnicell has made no commitment with regard to any functionality not generally available to the commercial marketplace as of the Pricing Supplement Effective Date or on the availability of any future version of the Licensed Software or purchased/leased Delivered Product. ';
// terms =terms+'<br>';
}
if(s.contains('Aesynt')){
terms = terms + 'Schedule D-3 of the Master Agreement listed above shall govern the Support Services for the Delivered Products listed herein.';
//terms =terms+'<br>';
}
if(s.contains('Cap')){
terms= terms + 'Omnicell Capital Program . This Pricing Supplement is also subject to, and incorporates by reference, all of the terms and conditions as set forth within Customerâ€™s Conditional Sales Agreement No.'+quote.Master_Agreement__c+  ' (the â€˜CSAâ€™).  Where terms and conditions of the CSA may conflict with the terms of the above referenced Master Agreement, the terms and conditions of the CSA shall control for purposes of this Pricing Supplement only.';    
}
if(s.contains('Replacement')){
terms = terms + 'Replacement Products. Omnicell shall de-install, remove and dispose of the Delivered Products being replaced (collectively, the â€˜Prior Productsâ€™) by the Delivered Products purchased herein (collectively, the â€˜Replacement Productsâ€™). Customer represents (a) that it owns title to the Prior Products free and clear of all liens and other encumbrances, and (b) that it has the authority to engage Omnicell to complete the de-installation of the Prior Products. Prior to the de-installation of the Prior Products, Customer shall (a) ensure that the Prior Products are free and clear of any drugs (including controlled substances), devices or other medical products dispensed or otherwise stored by Customer in such Prior Products, and (b) remove all patient information (including, without limitation, all protected health information) on all computer hardware contained in the Prior Products pursuant to Customerâ€™s procedures. By signing this Pricing Supplement, Customer hereby certifies to Omnicell that it has completed its obligations under this Section. Upon completion of the de-installation of the Prior Products, title to the Prior Products shall transfer from Customer to Omnicell. Support Services provided for the Prior Products will terminate upon the Acceptance of the Replacement Products.';

}
canned2 = canned2+s;
cannedLanguage = cannedLanguage + s;
}*/
                                             
                                         }
                                         
                                         //     System.debug('Selected Canned LAn Size : '+selectedCannedLan+' : '+selectedCannedLan.size());
                                         /* for(Canned_Language__c c: clan){
qp.Check_Select_Canned_Language__c = true;
if(layout == 'Omnicell' || layout == 'Change Order Omnicell'){
if(c.Name == 'Schedule D-3'){
if(selectedCannedLan.size()>1)
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
else
terms=terms+'1'+'. '+c.Canned_Language_Detail__c+'<br/>';
ik=ik+1;
}

if(c.Name == 'Omnicell has made no commitment'){
if(selectedCannedLan.size()>1)
terms = terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
else
terms = terms+'2'+'. '+c.Canned_Language_Detail__c+'<br/>';

ik=ik+1;
}


}
if(c.Name == 'Aesynt has made no commitment' && (layout == 'Aesynt' || layout == 'Change Order Aesynt')){
if(selectedCannedLan.size()>1)
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
else
terms=terms+'1'+'. '+c.Canned_Language_Detail__c+'<br/>';

}
}*/
                                         //           System.debug('Canned Lan : '+terms);
                                         
                                         //quote.Select_Canned_Language__c = cannedLanguage;
                                         //qp.Print_Section__c = sections2;
                                         //qp.Print_Exhibits__c = exhibits2;
                                         //ccl.canned_language__c = terms;
                                         // qp.Select_Canned_Language__c = canned2;
                                         //quote.Conga_Canned_Values__c= terms;
                                         //quote.Print_Sections__c = sections;
                                         //quote.Print_Exhibits__c = exhibits;
                                         qp.Section_Ids__c = secids;
                                         qp.Exhibit_Ids__c = ids;
                                         Boolean edittermstrue = false;
                                         //        System.debug('Quote Print : edited terms : '+editedterms);
                                         if(isEditButtonClicked == false)
                                             qp.Select_Canned_Language__c = terms;    
                                         else{
                                             edittermstrue = true;
                                             /*  if(editedterms.contains('QUOTE_CONGA_SUPPLEMENT')){
if(quote.Conga_Supplement__c != null)
editedterms = editedterms.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
else
editedterms = editedterms.replace('QUOTE_CONGA_SUPPLEMENT','');

}
if(editedterms.contains('EOL Date')){
if(quote.EOL_Date__c != null){
String dtmmddyy = quote.EOL_Date__c.format('MM/dd/yyyy');
editedterms = editedterms.replace('EOL Date',String.valueof(dtmmddyy));
}
else
editedterms = editedterms.replace('EOL Date','');

} 
if(editedterms.contains('Fee Increase:')){
if(quote.Fee_Increase__c != null)
editedterms = editedterms.replace('Fee Increase:',String.valueof(quote.Fee_Increase__c));
else
editedterms = editedterms.replace('Fee Increase:','');

} 
if(editedterms.contains('QUOTE_MASTER_AGREEMENT')){
if(quote.Master_Agreement__c != null)
editedterms = editedterms.replace('QUOTE_MASTER_AGREEMENT',quote.Master_Agreement__c);
else
editedterms = editedterms.replace('QUOTE_MASTER_AGREEMENT','');

}*/
                                             qp.Select_Canned_Language__c = editedterms;
                                             
                                         }   
                                         Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
                                         String sysadmin = sys.Profile_Name__c;
                                         Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
                                         String busadmin = bus.Profile_Name__c;
                                         Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
                                         String deal = dealdesk.Profile_Name__c;
                                         Conga_Print_Output__c Bookingprf = [select profile_Name__c from Conga_Print_Output__c where name = 'Booking Team'];
                                         String booking = Bookingprf.Profile_Name__c;
                                         Conga_Print_Output__c InternationalSalesOpsprf = [select profile_Name__c from Conga_Print_Output__c where name = 'International Sales Ops'];
                                         String internationalSalesOps = InternationalSalesOpsprf.Profile_Name__c;
                                         Conga_Print_Output__c Consultantprf = [select profile_Name__c from Conga_Print_Output__c where name = 'Consultant'];
                                         String consultant = Consultantprf.Profile_Name__c;
                                         Conga_Print_Output__c ItAdmin = [select profile_Name__c from Conga_Print_Output__c where name = 'IT Administrator']; //IBA-3443
                                         String ItAd = ItAdmin.Profile_Name__c; //IBA-3443
                                         
                                         List<User> useradmins = [select id from User where profile.name=:sysadmin OR profile.name=:busadmin OR profile.name=:deal];
                                         List<Id> useridsadmins = new List<Id>();
                                         for(User u: useradmins){
                                             useridsadmins.add(u.id);
                                         }
                                         //SF-BUG-1053
                                         List<Conga_Quote_Print__c> qList = [select id,Select_Canned_Language__c,Check_Select_Canned_Language__c,SelectedCannedLanguageNames__c from Conga_Quote_Print__c where Quote_Record_Id__c=:quoteId and ownerid=:useridsadmins order by createddate desc limit 2];   //Change limit to 2 for 1095                                   
                                         Conga_Quote_Print__c q;
                                         if(qList.size()>0){
                                             q = qList[0];
                                             //Conga_Quote_Print__c q =  [select id,Select_Canned_Language__c from Conga_Quote_Print__c where Quote_Record_Id__c=:quoteId and ownerid=:useridsadmins order by createddate desc limit 1];
                                             
                                             if(!getUser()){
                                                 qp.Select_Canned_Language__c = q.Select_Canned_Language__c;
                                             }
                                             
                                             String prevcann = '';
                                             String prescann = '';
                                             for(String s : selcannedPrev){
                                                 prevcann = prevcann+s;
                                             }
                                             for(String s : selectedCannedLan){
                                                 prescann = prescann+s;
                                             }
                                             if(prevcann == prescann && edittermstrue == false){
                                                 //qp.Select_Canned_Language__c = q.Select_Canned_Language__c;
                                             }
                                         }
                                         /*if(selcannedPrev.size() == selectedCannedLan.size() && edittermstrue == false){
qp.Select_Canned_Language__c = q.Select_Canned_Language__c;
}*/
                                         //        System.debug('Terms final edit : '+qp.Select_Canned_Language__c);
                                         User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
                                         //         System.debug('User Profile : '+u.profile.name);
                                         //        system.debug('!isdraft'+isdraft); 
                                         //Quote c = [select id,status from Quote where id=:conId];
                                         //        System.debug('Status : '+quote.Status);
                                         //      added "&&u.profile.name != ItAd" as part of IBA-3443 in if as well as else if 
                                         if(output == 'Microsoft Word' && (quote.Conga_Loggedin_User__c != busadmin && u.profile.name != sysadmin && u.profile.name != deal &&u.profile.name != booking &&u.profile.name != internationalSalesOps &&u.profile.name != consultant &&u.profile.name != ItAd)){
                                             return 'Error';    
                                         }
                                         
                                         else if(!isdraft && (quote.status != 'E0009' && quote.status != 'E0007' && quote.status != 'E0018' && quote.status != 'E0013') && (quote.Conga_Loggedin_User__c != busadmin && u.profile.name != sysadmin && u.profile.name != deal &&u.profile.name != booking &&u.profile.name != internationalSalesOps &&u.profile.name != consultant &&u.profile.name != ItAd)){
                                             //           System.debug('Inside status check if');
                                             return 'NotApproved';
                                         }
                                         
                                         else{
                                             //            System.debug('Quote Print Record Check : '+qp);
                                             Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                 6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
                                                 11=>'November', 12=>'December'};
                                                     //                 System.debug('Quote Print Record Check : '+qp);
                                                     //        System.debug('select canned lan : '+qp.Select_Canned_Language__c);
                                                     String rep = qp.Select_Canned_Language__c;
                                             if(rep.contains('QUOTE_CONGA_SUPPLEMENT')){
                                                 /*if(quote.Conga_Supplement__c != null)
rep = rep.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
else*/
                                                 rep = rep.replace('QUOTE_CONGA_SUPPLEMENT','_______');
                                             }
                                             if(rep.contains('QUOTE_MASTER_AGREEMENT')){
                                                 if(quote.Master_Agreement__c != null)
                                                     rep = editedterms.replace('QUOTE_MASTER_AGREEMENT',quote.Master_Agreement__c);
                                                 else
                                                     rep = editedterms.replace('QUOTE_MASTER_AGREEMENT','');
                                                 
                                             }            
                                             if(rep.contains('SERVICENOW Exhibit No.'))
                                                 rep = rep.replace('SERVICENOW Exhibit No.', String.valueof(serviceNownum));
                                             if(rep.contains('Exhibit No.')){
                                                 rep = rep.replace('Exhibit No.',String.valueof(crxnum));
                                             }
                                             /*Added by sravan for Canned lan fixes START*/
                                             if(rep.contains('IVXnum')){
                                                 if(govtIV > 0) {
                                                     rep = rep.replace('IVXnum',String.valueof(govtIV));
                                                 }else {
                                                     rep = rep.replace('IVXnum',String.valueof(ivx));
                                                 }
                                             }
                                             if(rep.contains('simpnum')){
                                                 rep = rep.replace('simpnum',String.valueof(simp));
                                             }
                                             if(rep.contains('perfexhibit')){
                                                 rep = rep.replace('perfexhibit',String.valueof(perf));
                                             }
                                             /*Added by sravan for Canned lan fixes END*/
                                             if(rep.contains('1 DAY LESS THAN BELOW')){
                                                 if(quote.Annual_Bill_Date__c!= null){
                                                     Date dayless = quote.Annual_Bill_Date__c-1;
                                                     String month = monthNameMap.get(dayless.month());
                                                     rep = rep.replace('1 DAY LESS THAN BELOW', month+' '+String.valueof(dayless.day()));
                                                 }
                                                 else
                                                     rep = rep.replace('1 DAY LESS THAN BELOW','_______');
                                             }
                                             if(rep.contains('ANNUAL BILL DATE')){
                                                 if(quote.Annual_Bill_Date__c!= null){
                                                     Date dayless = quote.Annual_Bill_Date__c;
                                                     String month = monthNameMap.get(dayless.month());
                                                     rep = rep.replace('ANNUAL BILL DATE', month+' '+String.valueof(dayless.day()));
                                                 }
                                                 else
                                                     rep = rep.replace('ANNUAL BILL DATE','_______');
                                             }
                                             if(rep.contains('SERVICE ESCALATOR %')){
                                                 if(quote.Service_Escalator_percentage__c!= null)
                                                     rep = rep.replace('SERVICE ESCALATOR %', String.valueof((Integer)quote.Service_Escalator_percentage__c));
                                                 else
                                                     rep = rep.replace('SERVICE ESCALATOR %','_______');
                                             }
                                             if(rep.contains('EOL Date')){
                                                 if(quote.EOL_Date__c!= null)
                                                     rep = rep.replace('EOL Date', String.valueof(quote.EOL_Date__c));
                                                 else
                                                     rep = rep.replace('EOL Date','________');
                                             }
                                             /* if(rep.contains('XXXXXXXX')){//Added by Sourav IBA-1527
rep = rep.replace('XXXXXXXX',String.valueof(oc_cloud));
}*/
                                             //SF-BUG-1053 Start                                           
                                             Boolean pastequal = false;
                                             List<String> pastcann = new List<String>();//SF-Bug-1095
                                             List<String> pastcannold = new List<String>();//SF-Bug-1095
                                             if(qList.size()>0){
                                                 if(qList[0].SelectedCannedLanguageNames__c != null){
                                                     pastcann = qList[0].SelectedCannedLanguageNames__c.split(',');//SF-Bug-1095
                                                     
                                                     if(pastcann.size() == selectedCannedLan.size()){
                                                         for(Integer ii=0;ii<selectedCannedLan.size();ii++){
                                                             if(qList[0].SelectedCannedLanguageNames__c.contains(selectedCannedLan[ii]))
                                                                 pastequal = true;
                                                             else{
                                                                 pastequal = false;
                                                                 break;
                                                             }
                                                         }
                                                     }
                                                 }
                                             }
                                             
                                             if(qList.size()>1){//Added by Sourav for SF-Bug-1095 Start
                                                 if(qList[1].SelectedCannedLanguageNames__c != null){
                                                     pastcannold = qList[1].SelectedCannedLanguageNames__c.split(',');//1095
                                                 }
                                                 
                                             }
                                             Integer countSC = pastcann.size();//1095
                                             Boolean termflag = false; // soumyad IBA-1416
                                             Integer iSC;
                                             Integer ikNew;
                                             String termNew = '';
                                             String termx='';
                                             System.debug('***'+qList.size());
                                             List<String> newSelet = new List<String>();
                                             if(pastcann.size()<= selectedCannedLan.size() && pastequal == false && qList.size()>0)
                                             {
                                                 for(iSC=countSC ; iSC<selectedCannedLan.size();iSC=iSC+1)
                                                 {
                                                     
                                                     newSelet.add(selectedCannedLan[iSC]);
                                                 }
                                                 termx = termx+qList[0].Select_Canned_Language__c;
                                                 ikNew = ik-selectedCannedLan.size()+countSC;
                                                 // soumyad IBA-1416 start
                                                 /*if((termx != null || termx != '') && (rep != null || rep != '')){
if(termx != rep){
termx = rep;
termflag = true;
qp.Select_Canned_Language__c = termx; // soumyad IBA-1416
}
}*/ //commented by Sourav IBA-1548
                                                 // soumyad IBA-1416 end
                                                 
                                             }
                                             else
                                             {
                                                 
                                                 if(pastcannold.size()<= selectedCannedLan.size() && pastequal == false && qList.size()>1){
                                                     termx = termx+qList[1].Select_Canned_Language__c;
                                                     ikNew = ik-selectedCannedLan.size()+pastcannold.size();
                                                     qList[0].SelectedCannedLanguageNames__c = qList[1].SelectedCannedLanguageNames__c;
                                                     qList[0].Select_Canned_Language__c = qList[1].Select_Canned_Language__c;
                                                     for(iSC=pastcannold.size() ; iSC<selectedCannedLan.size();iSC=iSC+1)
                                                     {
                                                         newSelet.add(selectedCannedLan[iSC]);
                                                         ik = ik+1;
                                                     }
                                                     
                                                     // soumyad IBA-1416 start
                                                     /*if((termx != null || termx != '') && (rep != null || rep != '')){
if(termx != rep){
termx = rep;
termflag = true;
qp.Select_Canned_Language__c = termx;
}
}*/ //commented by Sourav IBA-1548
                                                     // soumyad IBA-1416 end
                                                 }
                                                 else{
                                                     termx = rep;
                                                     /*qp.Select_Canned_Language__c = termx; // soumyad IBA-1416
termflag = true;*/ // soumyad IBA-1416 //commented by Sourav IBA-1548
                                                 }
                                             }
                                             
                                             List<Canned_Language__c> selectNew = [Select Name,Canned_Language_Detail__c From Canned_Language__c Where Omnicell_or_Aesynt__c = 'Omnicell' AND Name IN :newSelet];
                                             if(selectNew.size()>0){
                                                 for(Canned_Language__c c : selectNew){
                                                     termNew = termNew+ikNew+'. '+c.Canned_Language_Detail__c+'<br/>';
                                                     ikNew = ikNew+1;
                                                 }
                                             }
                                             if((selectedExhibits.size()>0 && selectedExhibits[0] != '') || (selectedExhibits.size() == 0)){ //Added by Sourav IBA-1548
                                                 termflag = true;
                                             }
                                             //Added by Sourav for SF-Bug-1095 End
                                             if(isEditButtonClicked == false && qList.size() > 0 && pastequal == true) {
                                                 // soumyad IBA-1416 start
                                                 if(termflag == false){ 
                                                     qp.Select_Canned_Language__c = qList[0].Select_Canned_Language__c;
                                                 }else{
                                                     qp.Select_Canned_Language__c = rep;
                                                 }
                                                 // soumyad IBA-1416 end
                                             }
                                             else if(isEditButtonClicked == false && qList.size() > 0 && pastequal == false){//Added by Sourav for SF-Bug-1095
                                                 if(termflag == false){ // soumyad IBA-1416
                                                     qp.Select_Canned_Language__c = termx+termNew;
                                                 } // soumyad IBA-1416
                                                 else{ //Added by Sourav IBA-1548
                                                     qp.Select_Canned_Language__c = rep;
                                                 }
                                             }
                                             else {                                                 
                                                 qp.Select_Canned_Language__c = rep;                                                
                                             }
                                             //SF-BUG-1053 END
                                             
                                             //Added by Jay under IBN-1596 -- Start
                                             // String MDALIC011Lang = cannedLangMAP.get('Win 7 MDA-LIC-011'); //Commented out for IBA-2596
                                             String MDALIC006Lang = cannedLangMAP.get('Win 7 MDA-LIC-006');
                                             List<String> qpSelectedCannedLangList = new List<String>();
                                             qpSelectedCannedLangList = qp.Select_Canned_Language__c.split('<br>');
                                             for(Quote_Line__c quoteLine: quoteLines){
                                                 if(quoteLine.Product__r.Name == 'MDA-LIC-006' && !qp.Select_Canned_Language__c.contains(MDALIC006Lang)){
                                                     qpSelectedCannedLangList.add(MDALIC006Lang);
                                                     qp.Select_Canned_Language__c += qpSelectedCannedLangList.size() + '.' + MDALIC006Lang + '<br>';
                                                 }/* else if(quoteLine.Product__r.Name == 'MDA-LIC-011' && !qp.Select_Canned_Language__c.contains(MDALIC011Lang)){
qpSelectedCannedLangList.add(MDALIC011Lang);
qp.Select_Canned_Language__c += qpSelectedCannedLangList.size() + '.' + MDALIC011Lang + '<br>';
}*/  //Commented out for IBA-2596
                                                 //IBA-3780 start
                                                 if(quoteLine.Product__r.Name == 'OCE-LIC-001' || quoteLine.Product__r.Name == 'MED-SFW-004'
                                                    ||quoteLine.Product__r.Name == 'MED-SFW-005'|| quoteLine.Product__r.Name == 'MED-SFW-006'){
                                                        qp.Software_Term_POC__c = true;    
                                                    }
                                                 if(quoteLine.Product__r.Name == 'MED-SVC-001' || quoteLine.Product__r.Name == 'MED-SVC-002'
                                                    ||quoteLine.Product__r.Name == 'MED-SVC-003'){
                                                        qp.Professional_Term_POC__c = true;    
                                                    }
                                                 if(quoteLine.Product__r.Name == 'SRD-SVC-001' || quoteLine.Product__r.Name == 'SRD-SVC-002'
                                                    ||quoteLine.Product__r.Name == 'SRD-SVC-003'){
                                                        qp.Enterprise_Term_POC__c = true;   
                                                    }
                                                 if(quoteLine.Product__r.Name == 'MED-SFW-004' || quoteLine.Product__r.Name == 'MED-SFW-005'
                                                    || quoteLine.Product__r.Name == 'MED-SFW-006' || quoteLine.Product__r.Name == 'MED-SVC-004' 
                                                    || quoteLine.Product__r.Name == 'MED-SVC-005' || quoteLine.Product__r.Name == 'MED-SVC-006' 
                                                    || qp.Enterprise_Term_POC__c == true){
                                                        qp.Solution_Term_POC__c = true;    
                                                    } //IBA-3780 end
                                                 
                                                 //IBA-4347 starts
                                                 if(template == 'CarePlus'){ // Replaced Point of Care Service to CarePlus as part of IBA 5977 SH
                                                     if(POC_SKU.contains(quoteLine.Product_Code__c)){
                                                         qp.Point_of_care_services_fees__c += quoteLine.Line_Expected_Booking__c;
                                                     }
                                                     if(POC_PS_SKU.contains(quoteLine.Product_Code__c)){
                                                         qp.Professional_services_fees__c += quoteLine.Line_Expected_Booking__c;
                                                     }                                                     
                                                 }
                                                 //IBA-4347 ends
                                                 
                                                 //IBA-4819 Starts
                                                 if(template == 'ServerScale Subscription'){
                                                     if(ServerScale_SKU.contains(quoteLine.Product_Code__c)){
                                                         qp.Point_of_care_services_fees__c += quoteLine.Line_Expected_Booking__c;
                                                     }
                                                 }
                                                 //IBA-4819 ends 
                                             }
                                             //Added by Jay under IBN-1596 -- End
                                             insert qp; 
                                             if(qList.size()>1){//Added by Sourav for SF-Bug-1095
                                                 if(pastcann.size()== selectedCannedLan.size()){
                                                     qList[0].SelectedCannedLanguageNames__c = qList[1].SelectedCannedLanguageNames__c;
                                                     qList[0].Select_Canned_Language__c = qList[1].Select_Canned_Language__c;
                                                 }
                                             }
                                             if(qList.size()>0){//Added by Sourav for SF-Bug-1095
                                                 update qList;
                                             }
                                             //System.debug('Quote before Update : '+quote);
                                             //UPDATE quote;
                                             //insert ccl;
                                             // QuotePrintController.updateQuoteLine(quote.id,qp.id);
                                             
                                             //System.debug('Quote after Update : '+quote);
                                             return qp.Name;
                                         }
                                     }
    
    @AuraEnabled
    public static String deleteQuotePrintRecord(String qpName,Id quoteId){
        String url = '';
        String output='';
        Quote quote = [select Order_Type__c,Conga_url1__c,Conga_url2__c,Culture_Code__c,Print_Currency__c,Alternate_Culture_Code__c,
                       Conga_url3__c,QuoteNumber,Quote_Revision__c,Conga_Session_Id__c,status,Opportunity.RecordType.Name 
                       from Quote where id=:quoteId]; //IBA-4868 Sourav
        Conga_Quote_Print__c qp = [SELECT Print_Base_Template__c,Print_Layout__c,Print_Output_Format__c,Section_Ids__c,Exhibit_Ids__c 
                                   FROM Conga_Quote_Print__c  where Name =:qpName ];
        String sectionIds='';
        String exhibitids = '';    
        if(qp.Print_Output_Format__c == 'PDF'){
            output=output+'&DefaultPDF=1&AWD=0';
        }    
        else
            output= output+'&DefaultPDF=0&AWD=1';
        
        if(qp.Section_Ids__c != null){
            sectionIds = sectionIds+qp.Section_Ids__c;
        }
        if(qp.Exhibit_Ids__c != null){
            exhibitids = exhibitids+qp.Exhibit_Ids__c;
        }
        //Signature page will print only when Supplement Quote Approval is approved for SF-BUG-635 by Rajat
        List<Quote_Approval__c> qa = [select id,recordtypeid,status__c from quote_approval__c where quote__c = :quoteId order by createddate desc limit 1];
        String recordtype = '';
        String status = '';
        if(qa.size()>0){
            recordtype = Schema.getGlobalDescribe().get('Quote_Approval__c').getDescribe().getRecordTypeInfosById().get(qa[0].RecordTypeId).getName();
            status = qa[0].status__c;
        }
        //IBA-4868 Sourav Start
        Set<String> profilesforSign = new Set<String>();
        List<Conga_Signature_Print_Profiles__c> allowprofileforCongaSig = Conga_Signature_Print_Profiles__c.getall().values();
        for(Conga_Signature_Print_Profiles__c prof:allowprofileforCongaSig){
            profilesforSign.add(prof.Name);
        }
        String profileName = '';
        Id profileId = UserInfo.getProfileId();
        profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        //IBA-4868 Sourav End
        if((recordtype == 'NAA Supplement Quote' || recordtype.contains('International ADC/VBM') || recordtype == 'MA Supplement Quote') && 
           (status == 'Approved'|| status == 'Waiting Approval') && (quote.Order_Type__c != 'ZQRS') && 
           (profilesforSign.contains(profileName) || quote.Opportunity.RecordType.Name == 'International Opportunity')){ //IBA-4868 Sourav
            List<Conga_Signature_Template__c> sigtempid = [select templateid__c from Conga_Signature_Template__c where Name='Quote Signature Template' limit 1];
            
            /*Above line commented and replced by following If added for May Scope UAT 259 & 261 Change Dg*/
            if(quote.Print_Currency__c != null) { 
                url = url+quote.conga_url1__c+quote.conga_url2__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Alternate_Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+sigtempid[0].templateid__c+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c;        
            }
            else {
                url = url+quote.conga_url1__c+quote.conga_url2__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+sigtempid[0].templateid__c+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c;        
            }
        }
        else{
            /*Above line commented and replced by following If added for May Scope UAT 259 & 261 Change Dg*/
            if(quote.Print_Currency__c != null) { 
                url = url+quote.conga_url1__c+quote.conga_url2__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Alternate_Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c;
            }
            else{
                url = url+quote.conga_url1__c+quote.conga_url2__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c;
                
            }
        }
        return url;
    }
    @AuraEnabled
    public static String quotedraftprint(String qpName,Id quoteId){
        String url = '';
        String output='';
        // Below query updated for CR-18666 added order type field in query
        Quote quote = [select Order_Type__c, Conga_url1__c,Culture_Code__c,Alternate_Culture_Code__c,Print_Currency__c,Conga_url2__c,
                       Conga_url3__c,Conga_url4__c,QuoteNumber,Quote_Revision__c,Conga_Session_Id__c,status,Opportunity.RecordType.Name 
                       from Quote where id=:quoteId];//IBA-4868 Sourav
        Conga_Quote_Print__c qp = [SELECT Print_Base_Template__c,Print_Layout__c,Print_Output_Format__c,Section_Ids__c,Exhibit_Ids__c FROM Conga_Quote_Print__c  where Name =:qpName ];
        String sectionIds='';
        String exhibitids = '';    
        if(qp.Print_Output_Format__c == 'PDF'){
            output=output+'&DefaultPDF=1&AWD=0';
        }    
        else
            output= output+'&DefaultPDF=0&AWD=1';
        
        if(qp.Section_Ids__c != null){
            sectionIds = sectionIds+qp.Section_Ids__c;
        }
        if(qp.Exhibit_Ids__c != null){
            exhibitids = exhibitids+qp.Exhibit_Ids__c;
        }
        //Signature page will print only when Supplement Quote Approval is approved for SF-BUG-635 by Rajat
        List<Quote_Approval__c> qa = [select id,recordtypeid,status__c from quote_approval__c where quote__c = :quoteId order by createddate desc limit 1];
        String recordtype = '';
        String status = '';
        if(qa.size()>0){
            recordtype = Schema.getGlobalDescribe().get('Quote_Approval__c').getDescribe().getRecordTypeInfosById().get(qa[0].RecordTypeId).getName();
            status = qa[0].status__c;
        }
        //IBA-4868 Sourav Start
        Set<String> profilesforSign = new Set<String>();
        List<Conga_Signature_Print_Profiles__c> allowprofileforCongaSig = Conga_Signature_Print_Profiles__c.getall().values();
        for(Conga_Signature_Print_Profiles__c prof:allowprofileforCongaSig){
            profilesforSign.add(prof.Name);
        }
        String profileName = '';
        Id profileId = UserInfo.getProfileId();
        profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        //IBA-4868 Sourav End
         // Below condition updated for CR-18666 added order type check. SIgnature should not print for omnicell as service order type
        if((recordtype == 'NAA Supplement Quote' || recordtype.contains('International ADC/VBM') || recordtype == 'MA Supplement Quote') && 
           (status == 'Approved' ||status == 'Waiting Approval') && (quote.Order_Type__c != 'ZQRS') && 
           (profilesforSign.contains(profileName) || quote.Opportunity.RecordType.Name =='International Opportunity')){ //IBA-4868 Sourav
            List<Conga_Signature_Template__c> sigtempid = [select templateid__c from Conga_Signature_Template__c where Name='Quote Signature Template' limit 1];
            /*Following If added for May Scope UAT 259 & 261 Change Dg*/
            if(quote.Print_Currency__c != null) { 
                url = url+quote.conga_url1__c+quote.Conga_url4__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Alternate_Culture_Code__c +'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+sigtempid[0].templateid__c+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c;        
            }
            else {
                url = url+quote.conga_url1__c+quote.Conga_url4__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+sigtempid[0].templateid__c+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c;        
            }
        }
        else{
            /*Following If added for May Scope UAT 259 & 261 Change Dg*/
            if(quote.Print_Currency__c != null) {
                url = url+quote.conga_url1__c+quote.Conga_url4__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Alternate_Culture_Code__c +'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c;
            }
            else{
                url = url+quote.conga_url1__c+quote.Conga_url4__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c;
            }
        }
        url = url+'&DV0=DRAFT';
        return url;
    }
    
    
    @AuraEnabled
    public static String sendQuotePrintRecord(String qpName,Id quoteId){
        String url = '';
        String output='';
        //below query updated for CR-18666
        Quote quote = [select Order_Type__c,Conga_Opportunity_Owner_Email__c,Conga_url1__c,Culture_Code__c,Print_Currency__c,
                       Alternate_Culture_Code__c,Conga_url2__c,Conga_url3__c,QuoteNumber,Quote_Revision__c,Conga_Session_Id__c,status,
                       Opportunity.RecordType.Name from Quote where id=:quoteId];//IBA-4868 Sourav
        Conga_Quote_Print__c qp = [SELECT Print_Base_Template__c,Print_Layout__c,Print_Output_Format__c,Section_Ids__c,Exhibit_Ids__c FROM Conga_Quote_Print__c  where Name =:qpName ];
        List<Conga_Email_Template_Contract__c> emailList = [select id,Name,Email_Template_Id__c from Conga_Email_Template_Contract__c where Name='Quote Email Template' limit 1];
        
        String sectionIds='';
        String exhibitids = '';    
        if(qp.Print_Output_Format__c == 'PDF'){
            output=output+'&DefaultPDF=1&AWD=0';
        }    
        else{
            output= output+'&DefaultPDF=0&AWD=1';
        }
        
        if(qp.Section_Ids__c != null){
            sectionIds = sectionIds+qp.Section_Ids__c;
        }
        if(qp.Exhibit_Ids__c != null){
            exhibitids = exhibitids+qp.Exhibit_Ids__c;
        }
        //Signature page will print only when Supplement Quote Approval is approved for SF-BUG-635 by Rajat
        List<Quote_Approval__c> qa = [select id,recordtypeid,status__c from quote_approval__c where quote__c = :quoteId order by createddate desc limit 1];
        String recordtype = '';
        String status = '';
        if(qa.size()>0){
            recordtype = Schema.getGlobalDescribe().get('Quote_Approval__c').getDescribe().getRecordTypeInfosById().get(qa[0].RecordTypeId).getName();
            status = qa[0].status__c;
        }
        //IBA-4868 Sourav Start
        Set<String> profilesforSign = new Set<String>();
        List<Conga_Signature_Print_Profiles__c> allowprofileforCongaSig = Conga_Signature_Print_Profiles__c.getall().values();
        for(Conga_Signature_Print_Profiles__c prof:allowprofileforCongaSig){
            profilesforSign.add(prof.Name);
        }
        String profileName = '';
        Id profileId = UserInfo.getProfileId();
        profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        //IBA-4868 Sourav End
        //condition updated for CR-18666 
        if((recordtype == 'NAA Supplement Quote' || recordtype.contains('International ADC/VBM') || recordtype == 'MA Supplement Quote') && 
           (status == 'Approved'|| status == 'Waiting Approval')  && (quote.Order_Type__c != 'ZQRS') && 
           (profilesforSign.contains(profileName) || quote.Opportunity.RecordType.Name =='International Opportunity')){ //IBA-4868 Sourav
            List<Conga_Signature_Template__c> sigtempid = [select templateid__c from Conga_Signature_Template__c where Name='Quote Signature Template' limit 1];
            /*Following If added for May Scope UAT 259 & 261 Change Dg*/
            if(quote.Print_Currency__c != null) {
                url = url+quote.conga_url1__c+quote.conga_url2__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Alternate_Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+sigtempid[0].templateid__c+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c+'&EmailToId=+&emailadditionalto='+quote.Conga_Opportunity_Owner_Email__c+'&EmailTemplateId='+emailList[0].Email_Template_Id__c+'&QMode=SendEmail';        
            }
            else {
                url = url+quote.conga_url1__c+quote.conga_url2__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+sigtempid[0].templateid__c+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c+'&EmailToId=+&emailadditionalto='+quote.Conga_Opportunity_Owner_Email__c+'&EmailTemplateId='+emailList[0].Email_Template_Id__c+'&QMode=SendEmail';        
            }
        }
        else{
            ///*Following If added for May Scope UAT 259 & 261 Change Dg*/
            if(quote.Print_Currency__c != null) {
                url = url+quote.conga_url1__c+quote.conga_url2__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Alternate_Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c+'&EmailToId=+&emailadditionalto='+quote.Conga_Opportunity_Owner_Email__c+'&EmailTemplateId='+emailList[0].Email_Template_Id__c+'&QMode=SendEmail';        
            }
            else{
                url = url+quote.conga_url1__c+quote.conga_url2__c+'&DS7=1&AWD=1&CurrencyCulture='+quote.Culture_Code__c+'&templateid='+qp.Print_Base_Template__c+','+sectionIds+','+exhibitids+'&SC1=SalesforceFile&DataTagEnable=1'+sectionIds+output+'&FP0=2'+quote.conga_url3__c+'&EmailToId=+&emailadditionalto='+quote.Conga_Opportunity_Owner_Email__c+'&EmailTemplateId='+emailList[0].Email_Template_Id__c+'&QMode=SendEmail';
            }
        }
        return url;
    }
    
    
    @AuraEnabled 
    public static boolean getUser(){
        User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
        // System.debug('User Profile : '+u.profile.name);
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
        String deal = dealdesk.Profile_Name__c;
        Conga_Print_Output__c Bookingprf = [select profile_Name__c from Conga_Print_Output__c where name = 'Booking Team'];
        String booking = Bookingprf.Profile_Name__c;
        Conga_Print_Output__c ITprf = [select profile_Name__c from Conga_Print_Output__c where name = 'IT Administrator'];//IBA-3638
        String itAdmin = ITprf.Profile_Name__c;//IBA-3638
        //Conga_Print_Output__c Consultantprf = [select profile_Name__c from Conga_Print_Output__c where name = 'Consultant'];
        //String consultant = Consultantprf.Profile_Name__c;
        //if(quote.Conga_Loggedin_User__c != busadmin && u.profile.name != sysadmin && u.profile.name != deal){
        // return 'Error';    
        //}
        if(u.profile.name == sysadmin || u.profile.name == busadmin || u.profile.name == deal ||u.profile.name == booking ||u.profile.name == itAdmin){//IBA-3638
            return true;
        }
        return false;
    }
    
    @AuraEnabled 
    public static void updateQuoteLine(Id qtId){ /*HEREANIL
List<Quote_Line__c> qline = [select id,From_Quote_Print__c from Quote_Line__c where Quote__c = :qtId];
try{
if(qline.size()>0){
qline[0].From_Quote_Print__c = true;
update qline[0];

}
}catch(Exception e){

}HEREANIL*/
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @AuraEnabled
    public static List<String> getPrintOptions(){
        
        //List<String> pickListValuesList= new List<String>();
        //Schema.DescribeFieldResult fieldResult = Quote.Print_Sections__c.getDescribe();
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //for( Schema.PicklistEntry pickListVal : ple){
        //  pickListValuesList.add(pickListVal.getLabel());
        //}     
        //
        String ObjectApi_name='Quote';
        String Field_name='Print_Sections__c';
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }        
        
        
        return lstPickvals;  
    } 
    
    @AuraEnabled
    public static String getCannedLanguage(Id quoteId,String layout,String[] selectedCannedLan,Boolean resettrue){
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
        String deal = dealdesk.Profile_Name__c;
        List<User> useradmins = [select id from User where profile.name=:sysadmin OR profile.name=:busadmin OR profile.name=:deal];
        List<Id> useridsadmins = new List<Id>();
        for(User u: useradmins){
            useridsadmins.add(u.id);
        }
        List<Conga_Quote_Print__c> qp = [select id,select_Canned_Language__c,SelectedCannedLanguageNames__c from Conga_Quote_Print__c where ownerid=:useridsadmins and Quote_Record_Id__c=:quoteId order by createddate desc limit 1];
        Boolean pastequal = false;
        if(qp.size()>0){
            //System.debug('Past Selected : '+pastselected.size());
            //System.debug('Past Selected : '+pastselected.size());
            // System.debug('ResetTrue : '+resettrue);
            if(qp[0].SelectedCannedLanguageNames__c != null){
                List<String> pastcann = qp[0].SelectedCannedLanguageNames__c.split(',');
                if(pastcann.size() == selectedCannedLan.size()){
                    for(Integer i=0;i<selectedCannedLan.size();i++){
                        if(qp[0].SelectedCannedLanguageNames__c.contains(selectedCannedLan[i]))
                            pastequal = true;
                        else{
                            pastequal = false;
                            break;
                        }
                    }
                }
            }
        }
        if(pastequal == true && qp.size()>0 && resettrue == false){
            //  System.debug('size : '+selectedCannedLan.size());
            return qp[0].Select_Canned_Language__c;
        }
        else{
            //  System.debug('Inside getCannedLanguage : '+selectedCannedLan);
            
            //Integer ik = 1;
            String terms='';
            List<Canned_Language__c> clan = new List<Canned_Language__c>();
            if(layout == 'Omnicell'  || layout == 'Change Order Omnicell'){
                clan = [select id,name,Canned_Language_Detail__c from Canned_Language__c where Omnicell_or_Aesynt__c= 'Omnicell' order by Canned_language_sequence__c asc];
            }
            else{
                clan = [select id,name,Canned_Language_Detail__c from Canned_Language__c where Omnicell_or_Aesynt__c= 'Aesynt' order by Canned_language_sequence__c asc];
            }
            Integer ik=1;//Added by Sourav SF-BUG-1008
            
            Quote quote = [select Service_Level__c,EOL_Date__c, Milestone_Invoice_Term__c, Opportunity_Record_Type__c, CONGA_Is_US_Opportunity_Type__c, Order_Type__c from Quote where id=:quoteId]; //IBA-3872 Abhrajitc **Added Milestone Invoice Term field to Query** IBA-4072 **Added Order_Type__c field to Query** **IBA-4749 Change AC
            
            Boolean conrx = false;
            //Remove for IBA-4189
            boolean ivprd = false;
            boolean simplifi = false;
            boolean perfcentr = false;
            Boolean win10 = false; //SF-BUG-934
            // Boolean oc_cloud_flag = false; //IBA-1527 // commented out for IBA-3614 
            Boolean replacement_products_flag = false; //IBA-1789
            Boolean sku_prod_flag = false; //IBA-3614
            Boolean win7_flag = false; //IBA-2596
            Boolean Omni_essen = false; // soumyad SF-Bug-1148
            Boolean mithunsignprcsup = false; //IBA-3872
            Boolean mithunsignbonagg = false; //IBA-3872
            Boolean mitFourtyPsSig = false; //IBA-3872
            Boolean mitfourtyOrder = false; //IBA-3872
            Boolean mitfourtyDel = false; //IBA-3872
            Boolean mitHundredDownPay = false; //IBA-3872
            Boolean miDeliveryPercent = false; //IBA-4749 AC
            Boolean oc_sku_prod_flag = false; //IBA-4020
            Boolean installation_sku_flag = false; //IBA-4072
            Boolean cad_sku_flag = false; //IBA-4072
            //Boolean Non_GA_prod_XTE_flag = false;//IBA-4639  //Commenting out for IBA-4961 Saptarsha Panthi
            Boolean FTK_study_skus_flag = false;//IBA-4603
            Boolean DeInstallation_flag=false;//IBA-3889 (Saptarsha)
            Boolean supplyXcl=false; //IBA-5821

            Boolean MedChill_flag=false;//IBA-5879 Saptarsha Panthi
            Boolean DataStation_flag = false;//IBA-5880 SH
            
            List<quote_line__c> qlines = [select id,product__c, quote__r.Order_Type__c, Higher_Level_Item__c,Product_Code__c,product__r.portfolio_segment__c,product__r.DW_Product_Line__c,product__r.Business_Line__c,product__r.SAP_Product_Type__c,product__r.DW_Product_Type__c, Line_Status__c from quote_line__c where quote__c=:quoteId]; //Added new fields in SOQL for IBA-1527, added Line_Status__c as part of IBA-5747 SH
            List<Win_10_Canned_Language_Product__c> win = [Select Product_Name__c From Win_10_Canned_Language_Product__c];  ////SF-BUG-934 by Sourav
            /*  List<OC_Cloud_Product__c> oc_cloud_prod = [Select Product_Name__c From OC_Cloud_Product__c];  //IBA-1527 by Sourav Start
Set<String> oc_prod = new Set<String>();
for(OC_Cloud_Product__c oc: oc_cloud_prod){
oc_prod.add(oc.Product_Name__c);
}//IBA-1527 End */ // commented out for IBA-3614 
            //IBA-1789 start
            Set<String> r_prod = new Set<String>();
            List<Replacement_Products__c> replacement_product = [Select Product_Name__c From Replacement_Products__c];
            for(Replacement_Products__c rp: replacement_product){
                r_prod.add(rp.Product_Name__c);
            }//IBA-1789 End
            //IBA-2596 start
            Set<String> win_prod = new Set<String>();
            List<Win7_Support_Products__c> win_product = [Select Product_Name__c From Win7_Support_Products__c];
            for(Win7_Support_Products__c wn: win_product){
                win_prod.add(wn.Product_Name__c);
            }//IBA-2596 End 
            //IBA-3614 start
            Set<String> sku_prod = new Set<String>();
            List<SKU_based_automations__c> sku_product = [Select Product_Name__c From SKU_based_automations__c];
            for(SKU_based_automations__c s: sku_product){
                sku_prod.add(s.Product_Name__c);
            }//IBA-3614 End
            
            //IBA-4020 Start
            Set<String> oc_sk_prod = new Set<String>();
            List<OC_SKU_based_automation__c> oc_sku_prod = [Select Product_Name__c From OC_SKU_based_automation__c];
            for(OC_SKU_based_automation__c s: oc_sku_prod){
                oc_sk_prod.add(s.Product_Name__c);
            }
            //IBA-4020 Ends
            
            //IBA-4072 Starts
            Set<String> inst_sk_prod = new Set<String>();
            List<Installation_plan_SKU__c> inst_sku_prod = [Select Product_Name__c From Installation_plan_SKU__c];
            for(Installation_plan_SKU__c s: inst_sku_prod){ //IBA-4788
                inst_sk_prod.add(s.Product_Name__c);
            }
            
            Set<String> cad_sk_prod = new Set<String>();
            List<CAD_Provision_SKU__c> cad_sku_prod = [Select Product_Name__c From CAD_Provision_SKU__c];
            for(CAD_Provision_SKU__c s: cad_sku_prod){
                cad_sk_prod.add(s.Product_Name__c);
            }
            //IBA-4072 Ends
            /* //IBA-4639 Start
Set<String> Non_GA_prod_XTE = new Set<String>();
List<Non_GA_product_XTE__c> cust_prod_XTE = [Select Product_Name__c From Non_GA_product_XTE__c];
for(Non_GA_product_XTE__c prod_XTE: cust_prod_XTE){
Non_GA_prod_XTE.add(prod_XTE.Product_Name__c);
}
//IBA-4639 End */  //Commenting out for IBA-4961 Saptarsha Panthi
            
            //IBA-4603 Start
            Set<String> FTK_study_skus = new Set<String>();
            List<Formulary_Tool_Kit_Studies_IV_skus__c> cust_prod_FTK = [Select Product_Name__c From Formulary_Tool_Kit_Studies_IV_skus__c];
            for(Formulary_Tool_Kit_Studies_IV_skus__c prod_FTK: cust_prod_FTK){
                FTK_study_skus.add(prod_FTK.Product_Name__c);
            }
            //IBA-4603 End
            //IBA-3889 Start (Saptarsha)
            Set<String> DeInstallation_skus = new Set<String>();
            List<De_Installation__c> cust_prod_DeInstallation = [Select Product_Name__c From De_Installation__c];
            for(De_Installation__c prod_DeInstallation: cust_prod_DeInstallation){
                DeInstallation_skus.add(prod_DeInstallation.Product_Name__c);
            }
            //IBA-3889 End (Saptarsha)
            
            //IBA-5880 Starts SH
            Set<String> DS_SKU = new Set<String>(); //DS is DataStation
            List<Datastation_Product__c> dssku = Datastation_Product__c.getall().values();
            for(Datastation_Product__c s: dssku){
                DS_SKU.add(s.Product_Name__c);
            }
            //IBA-5880 ends SH
            
            for(Quote_Line__c q:qlines){
                /*     if(oc_prod.contains(q.Product_Code__c)){//Added by Sourav IBA-1527
oc_cloud_flag = true;
} */ // commented out for IBA-3614 
                //Modified for SF-BUG-1069
                if(FTK_study_skus.contains(q.Product_Code__c) && q.Quote__r.Order_Type__c!='ZQRS'){//IBA-4603 Start
                    FTK_study_skus_flag = true;
                    //System.debug('IBA-4603:'+FTK_study_skus_flag);
                }//IBA-4603 End
                if(DeInstallation_skus.contains(q.Product_Code__c)&& q.Quote__r.Order_Type__c!='ZQRS'){//IBA-3889 Start (Saptarsha)
                    DeInstallation_flag = true;  
                }//IBA-3889 End (Saptarsha)
                //IBA-5879 Start Saptarsha Panthi
                if(q.Product__r.Portfolio_Segment__c == 'Medchill'){
                    MedChill_flag = true;
                }
                //IBA-5879 End Saptarsha Panthi
                if(r_prod.contains(q.Product_Code__c)){//Added by Prithan IBA-1789
                    replacement_products_flag = true;
                }
                if(win_prod.contains(q.Product_Code__c)){//Added by Prithan IBA-2596
                    win7_flag = true;
                }
                
                if(q.product__r.DW_Product_Line__c != Null){
                    if(q.product__r.DW_Product_Line__c == 'Connect-Rx' && q.Higher_Level_Item__c == 0){//Added logic for parent item for IBA-1527
                        conrx = true;
                    }
                    //Remove for IBA-4189
                    //IBA-3614 start
                    if((q.Product__r.Portfolio_Segment__c == 'Cloud Hosted OmniCenter' && q.Product__r.DW_Product_Line__c == 'OmniCenter' &&  sku_prod.contains(q.Product_Code__c))||
                       (q.Product__r.Portfolio_Segment__c == 'Inventory Optimization Service and Platform' && q.Product__r.DW_Product_Line__c == 'Omnicell One' && sku_prod.contains(q.Product_Code__c))||  //IBA-4331
                       (q.Product__r.Portfolio_Segment__c == 'Inventory Optimization Service and Platform' && q.Product__r.DW_Product_Line__c == 'Omnicell Essentials' &&  sku_prod.contains(q.Product_Code__c))||  //IBA-4331
                       (q.Product__r.Portfolio_Segment__c == 'IVX Workflow' && q.Product__r.DW_Product_Line__c == 'IVX Cloud' &&  sku_prod.contains(q.Product_Code__c)))
                    {
                        sku_prod_flag = true;
                    }
                    //IBA-3614 ends
                    
                    if(q.Product__r.Portfolio_Segment__c == 'Inventory Optimization Service and Platform' && oc_sk_prod.contains(q.Product_Code__c) && q.Line_Status__c != Label.Conga_Quote_Line_Status){oc_sku_prod_flag = true;} // IBA-4020, added && q.Line_Status__c != Label.Conga_Quote_Line_Status as part of IBA-5747 SH
                    
                    if(inst_sk_prod.contains(q.Product_Code__c)){
                        installation_sku_flag = true;
                        System.debug(' **Edit_installation_sku_flag: '+ q.Product_Code__c);
                    } //IBA-4072
                    
                    if(cad_sk_prod.contains(q.Product_Code__c)){cad_sku_flag = true;} //IBA-4072
                    
                    /*if(Non_GA_prod_XTE.contains(q.Product_Code__c)){//IBA-4639 Start
Non_GA_prod_XTE_flag=true;  
}//IBA-4639 End */ //Commenting out for IBA-4961 Saptarsha Panthi
                    
                    
                    
                    //soumyad SF-Bug-1148 start
                    if(q.product__r.DW_Product_Line__c == 'Omnicell Essentials' && q.Higher_Level_Item__c == 0){//Added logic for parent item for IBA-1527
                        Omni_essen = true;
                    }
                    //soumyad SF-Bug-1148 end                        
                    /*Added by sravan for Canned lan fixes START*/
                    String dwprdline = q.product__r.DW_Product_Line__c;
                    if(q.product__r.portfolio_segment__c != null){
                        String portfolio = q.product__r.portfolio_segment__c;
                        //if(dwprdline.contains('i.v')){
                        if(portfolio.contains('IV') && q.product__r.DW_Product_Line__c != 'Simplifi 797'){
                            ivprd = true;
                        }
                    }
                    if(q.product__r.DW_Product_Line__c == 'Simplifi 797' && q.product__r.portfolio_segment__c == 'IV Legacy' || q.product__r.DW_Product_Line__c == 'Simplifi 797' && q.product__r.portfolio_segment__c == 'IVX Workflow' || q.product__r.DW_Product_Line__c == 'Simplifi 797' && q.product__r.portfolio_segment__c == 'IV Compounding Service'){ //Updated by Abhrajitc IBA-1652
                        simplifi = true;
                    }
                }
                for(Win_10_Canned_Language_Product__c w :win)//SF-BUG-934 start by Sourav
                {
                    if(q.Product_Code__c == w.Product_Name__c)  
                    {
                        win10 = true;
                    } 
                }                                   //SF-BUG-934 End by Sourav
                /*if(q.product__r.DW_Product_Line__c == 'Performance Center'){
perfcentr = true;
}*///commented as 727 is not required
                /*Added by sravan for Canned lan fixes END*/
                if(DS_SKU.contains(q.Product_Code__c)){DataStation_flag = true;} //IBA-5880 SH
            }
            
            //IBA-3872 Abhrajitc Starts
            if(quote.Milestone_Invoice_Term__c != null){
                if(quote.Milestone_Invoice_Term__c == '22'){
                    mithunsignprcsup = true;
                }
                if(quote.Milestone_Invoice_Term__c == '23'){
                    mitFourtyPsSig = true;
                }
                if(quote.Milestone_Invoice_Term__c == '24'){
                    mithunsignbonagg = true;
                }
                if(quote.Milestone_Invoice_Term__c == '25'){
                    mitfourtyOrder = true;
                }
                if(quote.Milestone_Invoice_Term__c == '26'){
                    mitfourtyDel = true;
                }
                
                if(quote.Milestone_Invoice_Term__c == '14' && !quote.CONGA_Is_US_Opportunity_Type__c){ /*IBA-4749 change AC*/
                    mitHundredDownPay = true;
                }
                /*IBA-4749 change AC*/
                if(quote.Milestone_Invoice_Term__c == '21' && !quote.CONGA_Is_US_Opportunity_Type__c){
                    miDeliveryPercent = true;
                }
            } /*IBA-4749 change AC*/
            //IBA-3872 Abhrajitc Ends
            
            
            //Canned Language
            for(Canned_Language__c c: clan){
                //qp.Check_Select_Canned_Language__c = true;
                if(layout == 'Omnicell' || layout == 'Change Order Omnicell'){
                    if(c.Name == 'Non-GA Waiver'  && quote.Order_Type__c != 'ZQRS'){ //IBA-4072
                        // System.debug('Inside Support Services');
                        //terms=terms+'1'+'. '+c.Canned_Language_Detail__c+'<br/>';//Commented for SF-BUG-1008 by Sourav and added next two line
                        System.debug('!@#Non-GA Waiver--3001');
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                    } 
                    
                    //soumyad SF-Bug-1148 start
                    System.debug('canned lang ' +c.Name+ '  Omni_essen  '+Omni_essen);
                    if(c.Name == 'Omnicell essentials' && Omni_essen == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;    
                        System.debug('omni essen ' +c.Canned_Language_Detail__c);
                    }
                    //soumyad SF-Bug-1148 end
                    
                    //if(c.Name == 'Omnicell has made no commitment'){
                    /*if(c.Name == 'SS: PO at Sign.'){
terms = terms+'2'+'. '+c.Canned_Language_Detail__c+'<br/>';
}
//if(c.Name == 'Support Services Delay (Omnicell)'){
if(c.Name == 'SS: Cust. Delay'){
terms = terms+'3'+'. '+c.Canned_Language_Detail__c+'<br/>';
}*/ //Commented by Sourav for SF-BUG-1035
                    if(c.Name == Label.Simplifi_797){
                        if(simplifi == true){
                            //terms = terms+'2'+'.'+c.Canned_Language_Detail__c+'<br/>';//Commented for SF-BUG-1008 by Sourav and added next two line
                            terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                            ik = ik+1;
                        }
                    }
                    /*Added by sravan for Canned lan fixes START*/
                    if(c.Name == Label.IV_Products){
                        if(ivprd == true && simplifi == true){
                            //terms = terms+'3'+'. '+c.Canned_Language_Detail__c+'<br/>';//Commented for SF-BUG-1008 by Sourav and added next two line
                            terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                            ik = ik+1;
                        }
                        else if(ivprd == true){
                            //terms = terms+'2'+'. '+c.Canned_Language_Detail__c+'<br/>';//Commented for SF-BUG-1008 by Sourav and added next two line
                            terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                            ik = ik+1;
                        }
                        
                    }
                    //  System.debug('ivprd = '+ivprd+' simplifi = '+simplifi+' perf centr = '+perfcentr);
                    /*if(c.Name == Label.Performance_Center){
System.debug('inside perf center');
if(perfcentr == true){
if(ivprd == true && simplifi == true)
terms = terms +'6'+'. '+c.Canned_Language_Detail__c+'<br/>';
else
terms = terms +'5'+'. '+c.Canned_Language_Detail__c+'<br/>';
}
}
if(ivprd == true && simplifi == true && perfcentr == true){
ik = 7;
}
//else//commented as 727 is not required 
if(ivprd == true && simplifi == true ){
//ik = 6;//commented as 727 is not required
ik = 4;//SF-BUG-1035
}
else if(ivprd == true || simplifi == true){
//ik = 5;//commented as 727 is not required
ik = 3;//SF-BUG-1035
}*///Commented by Sourav for SF-BUG-1008-New
                    /*else{
ik = 4;
}*/ //commented by Sourav for SF-BUG-1008
                    /*Added by sravan for Canned lan fixes END*/
                    //soumyad start sf-bug-753
                    if(c.Name == 'CRx Upg.' && conrx == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;    
                    }
                    //soumyad end sf-bug-753
                    //Remove for IBA-4189
                    //  System.debug('Win10 terms' +terms);   //SF-BUG-934 start added by Sourav
                    if(c.Name == 'Win 10 language' && win10 == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;    
                    }
                    
                    
                    /*    if(c.Name == 'Cloud-Based Services' && oc_cloud_flag == true){//Added by Sourav IBA-1527
System.debug('***'+terms);
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
ik = ik+1;    
}
if(c.Name == 'Cloud-Hosted OmniCenter' && oc_cloud_flag == true){//Added by Sourav IBA-1527
System.debug('***'+terms);
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
ik = ik+1;    
} */ // commented out for IBA-3614 
                    if(c.Name == 'Repl. Product' && replacement_products_flag == true){//Added by Prithan IBA-1789
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        System.debug('***'+terms);
                        ik = ik+1;    
                    }
                    if(c.Name == 'SS: Ext. Win 7 Support' && win7_flag == true){//Added by Prithan IBA-2596
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        System.debug('***'+terms);
                        ik = ik+1;    
                    } 
                    /* //IBA-4639 Start
if(c.Name=='Non-GA product - XTE'&& Non_GA_prod_XTE_flag==true){
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
ik = ik+1;  
}
//IBA-4639 End */  //Commenting out for IBA-4961 Saptarsha Panthi
                    
                    //IBA-4603 Start
                    if(c.Name=='Formulary Tool Kit Studies IV'&& FTK_study_skus_flag==true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;  
                    }
                    //IBA-4603 End
                    //IBA-3889 Start (Saptarsha)
                    if(c.Name=='De-Installation New'&& DeInstallation_flag == true){
                        terms = terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;  
                    }
                    //IBA-3889 End (Saptarsha)
                    //IBA-5879 Start Saptarsha Panthi
                    if(c.Name=='Pre-GA Product'&& MedChill_flag == true){
                        terms = terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;  
                    }
                    //IBA-5879 End Saptarsha Panthi
                    
                    //Added for IBA-3614 starts
                    if(c.Name == 'Software Licensing' && sku_prod_flag == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        System.debug('***'+terms);
                        ik = ik+1;    
                    } 
                    if(c.Name == 'PT: Software Subscription' && sku_prod_flag == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        System.debug('***'+terms);
                        ik = ik+1;    
                    }
                    
                    // IBA-4020 ends
                    if(c.Name == 'Software Licensing OC' && oc_sku_prod_flag == true && quote.Order_Type__c != 'ZQRS'){ //IBA-4072
                        //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        terms=terms+ik+'. ';
                        if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                            terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>'; 
                        else 
                            terms = terms + c.Canned_Language_Detail__c+'<br/>';
                        System.debug('***SH'+terms+' **IK '+ ik);
                        ik = ik+1;    
                    }
                    if(c.Name == 'PT: Software Subscription OC' && oc_sku_prod_flag == true && quote.Order_Type__c != 'ZQRS'){ //IBA-4072
                        //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        terms=terms+ik+'. ';
                        if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                            terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                        else 
                            terms = terms + c.Canned_Language_Detail__c+'<br/>';
                        System.debug('***'+terms);
                        ik = ik+1;    
                    }
                    // IBA-4020 ends
                    
                    // IBA-4072 starts
                    if(cma_flag == false && quote.Order_Type__c == 'ZQRS'){
                        System.debug('##if_cma_flag: getCannedLanguage: ' + cma_flag);
                        if(c.Name == 'ASA Installation Plan Approval' && installation_sku_flag == true  && quote.Order_Type__c == 'ZQRS'){
                            //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                            //terms=terms+ik+'. ';
                            if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                            else 
                                terms = terms + c.Canned_Language_Detail__c+'<br/>';
                            //System.debug(' **IKSS '+ ik+' ***'+terms);
                            ik = ik+1;    
                        }
                        
                        
                    }else{
                        System.debug(' ##ElsePurchase_cma_flag: getCannedLanguage: ' + cma_flag);
                        if(quote.Order_Type__c != 'ZQRS'){
                            if(c.Name == 'CMA Installation Plan Approval' && installation_sku_flag == true ){
                                //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                terms=terms+ik+'. ';
                                if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                    terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                else 
                                    terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                System.debug(' **Editcma_flag CMA '+ cma_flag+' *** '+ ' terms: '+ terms);
                                System.debug(' **EditIKSSElse '+ ik+' ***'+terms);
                                ik = ik+1;    
                            }
                        }else{                                                         
                            if(c.Name == 'CMA Installation Plan Approval' && installation_sku_flag == true ){
                                //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                                //terms=terms+ik+'. ';
                                if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                                    terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                                else 
                                    terms = terms + c.Canned_Language_Detail__c+'<br/>';
                                //System.debug(' **cma_flag CMA '+ cma_flag+' *** '+ ' terms: '+ terms);
                                //System.debug(' **IKSSElse '+ ik+' ***'+terms);
                                ik = ik+1;    
                            }
                        }
                    }
                    
                    if(c.Name == 'CAD Provision' && cad_sku_flag == true && quote.Order_Type__c != 'ZQRS' && installation_sku_flag != true){
                        //terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        terms=terms+ik+'. ';
                        if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                            terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                        else 
                            terms = terms + c.Canned_Language_Detail__c+'<br/>';
                        //System.debug(' **IKSS '+ ik+' ***'+terms);
                        ik = ik+1;    
                    }
                    // IBA-4072 ends
                    
                    //IBA-3872 Abhrajitc Starts
                    if(c.Name == 'MI: 100% signing Supplement' && mithunsignprcsup == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                        System.debug('@developer-->e'+terms);
                    }
                    if(c.Name == 'MI: 40% PS Signature & 60% Bonding Agreement' && mitFourtyPsSig == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                        System.debug('@developer-->e'+terms);
                    }
                    if(c.Name == 'MI: 100% signed Bonding Agreement' &&  mithunsignbonagg == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                        System.debug('@developer-->e'+terms);
                    }
                    if(c.Name == 'MI: 40% Order 40% Delivery & 20% Acceptance' && mitfourtyOrder == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                        System.debug('@developer-->e'+terms);
                    }
                    if(c.Name == 'MI: 40% Order 40% Pre Delivery & 20% Accept' && mitfourtyDel == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                        System.debug('@developer-->e'+terms);
                    }
                    if(c.Name == 'MI: 100% on Down Payment' && mitHundredDownPay == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                        System.debug('@developer-->e'+terms);
                    } //IBA-3872 Abhrajitc Ends
                    
                    /*IBA-4749 Changes AC*/
                    if(c.Name == 'MI: 100% on Delivery' && miDeliveryPercent == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                    }
                    /*IBA-4749 Changes AC*/
                    //IBA-5821 Start
                    if((c.Name=='Subscription- On Premise' || c.Name=='Pre-GA Product' || c.Name=='Disbursed Support Services for Delivered Products') && supplyXcl == true){
                        terms=terms+ik+'. ';
                        if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
                            terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
                        else 
                            terms = terms + c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                    }
                    //IIBA-5821 End
                    // System.debug('a terms' +terms);           //SF-BUG-934 end
                }
                
                if(layout == 'Aesynt' || layout == 'Change Order Aesynt'){
                    if(c.Name == 'Definitions')
                        terms=terms+'1'+'. '+c.Canned_Language_Detail__c+'<br/>';
                    //if(c.Name == 'Aesynt has made no commitment')
                    if(c.Name == 'Non-GA Waiver (A)')    
                        terms=terms+'2'+'. '+c.Canned_Language_Detail__c+'<br/>';
                    //if(c.Name == 'Support Services PO (Aesynt)')
                    if(c.Name == 'SS: PO at Sign. (A)')
                        terms=terms+'3'+'. '+c.Canned_Language_Detail__c+'<br/>';
                    //if(c.Name == 'Support Services Delay (Aesynt)')
                    if(c.Name == 'SS: Cust. Delay (A)')
                        terms=terms+'4'+'. '+c.Canned_Language_Detail__c+'<br/>';
                    /*Added by sravan for Canned lan fixes START*/
                    if(c.Name == Label.Simplifi_797){
                        if(simplifi == true){
                            terms = terms+'5'+'. '+c.Canned_Language_Detail__c+'<br/>';
                        }
                    }
                    if(c.Name == Label.IV_Products){
                        if(ivprd == true && simplifi == true){
                            terms = terms+'6'+'. '+c.Canned_Language_Detail__c+'<br/>';
                        }
                        else if(ivprd == true){
                            terms = terms+'5'+'. '+c.Canned_Language_Detail__c+'<br/>';
                        }
                        
                    }
                    // System.debug('ivprd = '+ivprd+' simplifi = '+simplifi+' perf centr = '+perfcentr);
                    if(c.Name == Label.Performance_Center){
                        // System.debug('inside perf center Aesynt');
                        if(perfcentr == true){
                            if(ivprd == true && simplifi == true)
                                terms = terms +'7'+'. '+c.Canned_Language_Detail__c+'<br/>';
                            else
                                terms = terms +'6'+'. '+c.Canned_Language_Detail__c+'<br/>';
                        }
                    }
                    if(ivprd == true && simplifi == true && perfcentr == true){
                        ik = 8;
                    }
                    else if(ivprd == true && simplifi == true ){
                        ik = 7;
                    }
                    else
                        ik = 6;/*Added by sravan for Canned lan fixes END*/
                    if(c.Name == 'SS: ServiceNow' && quote.Service_Level__c == 'AN'){
                        //  System.debug('Inside servicenow');
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;
                    }
                    if(c.Name == 'CRx Upg.' && conrx == true){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        ik = ik+1;    
                    }
                    
                    //IBA-5880 Starts SH
                    if(c.Name == 'DataStation Standalone Software' && DataStation_flag == true){
                    	     terms=terms+ik+'. ';
		             if(c.Canned_Language_Detail__c.startsWith('<p>') && c.Canned_Language_Detail__c.endsWith('</p>')) 
		                 terms = terms + c.Canned_Language_Detail__c.substring(3, (c.Canned_Language_Detail__c.length()-4))+'<br/>';  
		             else 
		                 terms = terms + c.Canned_Language_Detail__c+'<br/>';
		             ik = ik+1;
                    }
                    //IBA-5880 Ends SH
                }
            }
            
            
            //List<Canned_Language__c> clan = [select id,name,Canned_Language_Detail__c from Canned_Language__c];
            for(String s: selectedCannedLan){
                
                
                
                //if(i<selectedCannedLan.size()-1){
                // Integer jk=clan.size();
                // Integer ik;
                // if(s.contains('Buyout Products')){
                for(Canned_Language__c c: clan){
                    // for(ik=0;ik<jk;ik++){
                    //    System.debug('ik : '+ik);
                    if(c.Name == s){
                        /*if(ik == 1){
System.debug('Inside Ik');

if(s.contains('Development Product(Omnicell)')){   
System.debug('Inside If replace check');
// String replaced = c.canned_language_detail__c.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));

terms=ik+'. '+terms+c.canned_language_detail__c+'<br/>';  
System.debug('terms: '+terms);
}
else if(s.contains('ServiceNow')){
// String replaced = c.Canned_Language_Detail__c.replace('Exhibit No.',String.valueof(serviceNownum));
terms=ik+'. '+terms+c.canned_language_detail__c+'<br/>';
}else if(s.contains('Connect-RX Upgrade')){
// String replaced = c.Canned_Language_Detail__c.replace('Exhibit No.',String.valueof(crxnum));
terms=ik+'. '+terms+c.canned_language_detail__c+'<br/>';
}else if(s.contains('Classic Hardware EOL â€“Lease')){
if(quote.EOL_Date__c != null){
// String dtmmddyy = quote.EOL_Date__c.format('MM/dd/yyyy');
// String replaced = c.Canned_Language_Detail__c.replace('EOL Date',String.valueof(dtmmddyy)); 
terms=ik+'. '+terms+c.canned_language_detail__c+'<br/>';
}
else{
//  String replaced = c.Canned_Language_Detail__c.replace('EOL Date','');
terms=ik+'. '+terms+c.canned_language_detail__c+'<br/>';    
}
}else if(s.contains('Fee Increase')){
//  String replaced = c.Canned_Language_Detail__c.replace('Fee Increase:',String.valueof(quote.Fee_Increase__c));
terms=ik+'. '+terms+c.canned_language_detail__c+'<br/>';
}else if(s.contains('Omnicell Capital Program')){
// String replaced = c.Canned_Language_Detail__c.replace('QUOTE_MASTER_AGREEMENT',quote.Master_Agreement__c);
terms=ik+'. '+terms+c.canned_language_detail__c+'<br/>';
}else{
terms = ik+'. '+terms+c.Canned_Language_Detail__c+'<br/>';
System.debug('Inside else replace check');
}
}*/
                        //else{
                        
                        if(s.contains('Development Product(Aesynt)') || s.contains('Development Product(Omnicell)')){    
                            // System.debug('Inside If replace check');
                            // String replaced = c.canned_language_detail__c.replace('QUOTE_CONGA_SUPPLEMENT',String.valueof(quote.Conga_Supplement__c));
                            
                            terms=terms+ik+'. '+c.canned_language_detail__c+'<br/>';  
                            //  System.debug('Terms : '+terms);
                        }
                        else if(s.contains('ServiceNow')){
                            //String replaced = c.Canned_Language_Detail__c.replace('Exhibit No.',String.valueof(serviceNownum));
                            terms=terms+ik+'. '+c.canned_language_detail__c+'<br/>';
                        }else if(s.contains('Connect-RX Upgrade')){
                            //String replaced = c.Canned_Language_Detail__c.replace('Exhibit No.',String.valueof(crxnum));
                            terms=terms+ik+'. '+c.canned_language_detail__c+'<br/>';
                        }else if(s.contains('Classic Hardware EOL â€“Lease')){
                            if(quote.EOL_Date__c != null){
                                //  String dtmmddyy = quote.EOL_Date__c.format('MM/dd/yyyy');
                                //  String replaced = c.Canned_Language_Detail__c.replace('EOL Date',String.valueof(dtmmddyy));
                                terms=terms+ik+'. '+c.canned_language_detail__c+'<br/>';
                            }
                            else{
                                // String replaced = c.Canned_Language_Detail__c.replace('EOL Date','');
                                terms=terms+ik+'. '+c.canned_language_detail__c+'<br/>'; 
                            }
                        }else if(s.contains('Fee Increase')){
                            // String replaced = c.Canned_Language_Detail__c.replace('Fee Increase:',String.valueof(quote.Fee_Increase__c));
                            terms=terms+ik+'. '+c.canned_language_detail__c+'<br/>';
                        }else if(s.contains('Omnicell Capital Program')){
                            //   System.debug('Inside Omnicell Capital program');
                            //  String replaced = c.Canned_Language_Detail__c.replace('QUOTE_MASTER_AGREEMENT',quote.Master_Agreement__c);
                            //terms=ik+'. '+terms+replaced+'<br/>'; 
                            terms=terms+ik+'. '+c.canned_language_detail__c+'<br/>'; 
                        }else
                            terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                        
                        // }
                        //ik++;
                        //break;
                    }
                    //jk++;
                }
                // }
                ik= ik+1;
                //cannedLanguage = cannedLanguage + s+';';
                //canned2 = canned2+s+', ';
                
                
                
                /*else{
if(s.contains('Generally')){
terms = terms + 'Omnicell has made no commitment with regard to any functionality not generally available to the commercial marketplace as of the Pricing Supplement Effective Date or on the availability of any future version of the Licensed Software or purchased/leased Delivered Product. ';
// terms =terms+'<br>';
}
if(s.contains('Aesynt')){
terms = terms + 'Schedule D-3 of the Master Agreement listed above shall govern the Support Services for the Delivered Products listed herein.';
//terms =terms+'<br>';
}
if(s.contains('Cap')){
terms= terms + 'Omnicell Capital Program . This Pricing Supplement is also subject to, and incorporates by reference, all of the terms and conditions as set forth within Customerâ€™s Conditional Sales Agreement No.'+quote.Master_Agreement__c+  ' (the â€˜CSAâ€™).  Where terms and conditions of the CSA may conflict with the terms of the above referenced Master Agreement, the terms and conditions of the CSA shall control for purposes of this Pricing Supplement only.';    
}
if(s.contains('Replacement')){
terms = terms + 'Replacement Products. Omnicell shall de-install, remove and dispose of the Delivered Products being replaced (collectively, the â€˜Prior Productsâ€™) by the Delivered Products purchased herein (collectively, the â€˜Replacement Productsâ€™). Customer represents (a) that it owns title to the Prior Products free and clear of all liens and other encumbrances, and (b) that it has the authority to engage Omnicell to complete the de-installation of the Prior Products. Prior to the de-installation of the Prior Products, Customer shall (a) ensure that the Prior Products are free and clear of any drugs (including controlled substances), devices or other medical products dispensed or otherwise stored by Customer in such Prior Products, and (b) remove all patient information (including, without limitation, all protected health information) on all computer hardware contained in the Prior Products pursuant to Customerâ€™s procedures. By signing this Pricing Supplement, Customer hereby certifies to Omnicell that it has completed its obligations under this Section. Upon completion of the de-installation of the Prior Products, title to the Prior Products shall transfer from Customer to Omnicell. Support Services provided for the Prior Products will terminate upon the Acceptance of the Replacement Products.';

}
canned2 = canned2+s;
cannedLanguage = cannedLanguage + s;
}*/
                
            }
            /*for(Canned_Language__c c: clan){
//qp.Check_Select_Canned_Language__c = true;
if(layout == 'Omnicell' || layout == 'Change Order Omnicell'){
if(c.Name == 'Omnicell has made no commitment'){
terms = terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>'; 
ik=ik+1;
}

if(c.Name == 'Schedule D-3'){
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
ik=ik+1;
}
}
if(c.Name == 'Aesynt has made no commitment' && (layout == 'Aesynt' || layout == 'Change Order Aesynt')){
terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
}
}*/
            //  System.debug('Terms : '+terms);
            
            //Added by Jay for IBN-1596 -- Start
            //  String MDALIC011Lang = cannedLangMAP.get('Win 7 MDA-LIC-011');  //Commented out for IBA-2596
            String MDALIC006Lang = cannedLangMAP.get('Win 7 MDA-LIC-006');
            ik = ik - 1;
            List<Quote_Line__c> quoteLineList = [Select Id, Product__c, Product__r.Name from Quote_Line__c where Quote__c = :quoteId];
            
            if(quoteLineList != null && quoteLineList.size() > 0){
                for(Quote_Line__c var: quoteLineList){
                    /*   if(var.Product__r.Name == 'MDA-LIC-011'){
terms += ik + '. ' + MDALIC011Lang + '<br/>';  //Commented out for IBA-2596
ik++;
}else */ if(var.Product__r.Name == 'MDA-LIC-006'){
    terms += ik + '. ' + MDALIC006Lang + '<br/>';
    ik++;
}
                }
            }
            //Added by Jay for IBN-1596 -- End
            return terms;
            
        }
    }
    @AuraEnabled
    public static List<String> getQuote(Id conId){
        Quote c = [select id,status from Quote where id=:conId];
        List<Quote_Approval__c> qa = [select id,recordtypeid from quote_approval__c where quote__c = :conId order by createddate desc limit 1];
        // System.debug('QA : '+qa);
        String recordtype = '';
        if(qa.size()>0)
            recordtype = Schema.getGlobalDescribe().get('Quote_Approval__c').getDescribe().getRecordTypeInfosById().get(qa[0].RecordTypeId).getName();
        //List<Conga_Email_Template_Contract__c> emailList = [select id,Name,Email_Template_Id__c from Conga_Email_Template_Contract__c where Name='QuoteSignatureTemplate' limit 1];
        //List<Conga_Contract_GPO_Check__c> templateid =  [select id, name ,Template_Id__c  from Conga_Contract_GPO_Check__c]; 
        //if(c.Status__c == 'Approved')
        List<String> cList = new List<String>();
        
        //cList.add(c.Status);
        if(!getUser()){
            if(c.status == 'E0021' || c.status == 'E0009' || c.status == 'E0013')
                cList.add('Approved');
            else
                cList.add('NotApproved');
        }
        else{
            cList.add('Approved');
        }
        return cList;
        /*  if(recordtype != 'NAA Supplement Quote'){
cList.add('NotSupplementQuote');
}
else if(qa.size()<=0){
cList.add('No Quote Approval Found');
}
return cList;



//else
//return 'Not_Approved';*/
    }
    
    @AuraEnabled 
    Public static List<String> CannedLanguagesOmnicell(){
        List<Canned_Language__c> cl = [select name from Canned_Language__c where Omnicell_or_Aesynt__c= 'Omnicell'  order by name];
        List<String> clan = new List<String>();
        for(Canned_Language__c c: cl){
            //if(c.Name != 'Omnicell has made no commitment' && c.Name != 'Support Services PO (Omnicell)' && c.Name != 'Support Services Delay (Omnicell)')
            if(c.Name != 'Non-GA Waiver' && c.Name != 'SS: Cust. Delay' && c.Name != 'SS: PO at Sign.' && c.Name != Label.IV_Products && c.Name != Label.Simplifi_797
              && c.Name != 'Disbursed Support Services for Delivered Products' && c.Name != 'DataStation Standalone Software') //IBA-5821, added Datastation Part as part of IBA-5880 SH
                clan.add(c.Name);
        }
        return clan;
    }
    @AuraEnabled 
    Public static List<String> CannedLanguagesAesynt(){
        List<Canned_Language__c> cl = [select name from Canned_Language__c where Omnicell_or_Aesynt__c= 'Aesynt'  order by name];
        List<String> clan = new List<String>();
        for(Canned_Language__c c: cl){
            if(c.Name != 'Non-GA Waiver (A)' && c.Name != 'Definitions' && c.Name != 'SS: Cust. Delay (A)' && c.Name != 'SS: PO at Sign. (A)' && c.Name != 'CRx Upg.' && c.Name != Label.IV_Products && c.Name != Label.Simplifi_797)
                clan.add(c.Name);
        }
        return clan;
    }
    @AuraEnabled
    public static List<String> selectedCannedLan(Id quoteId){
        List<Conga_Quote_Print__c> qp = new List<Conga_Quote_Print__c>();
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
        String deal = dealdesk.Profile_Name__c;
        
        List<User> useradmins = [select id from User where profile.name=:sysadmin OR profile.name=:busadmin OR profile.name=:deal];
        List<Id> useridsadmins = new List<Id>();
        for(User u: useradmins){
            useridsadmins.add(u.id);
        }
        if(getUser())
            qp = [select id,SelectedCannedLanguageNames__c from Conga_Quote_Print__c where ownerid=:useridsadmins and Quote_Record_Id__c=:quoteId order by createddate desc limit 1];
        else
            qp = [select id,SelectedCannedLanguageNames__c from Conga_Quote_Print__c where Quote_Record_Id__c=:quoteId order by createddate desc limit 1];   
        List<String> pastcann = new List<String>();
        if(qp.size()>0 && qp[0].SelectedCannedLanguageNames__c != null)
            pastcann = qp[0].SelectedCannedLanguageNames__c.split(',');
        else
            pastcann.add('');
        return pastcann;
    }
    @AuraEnabled
    public static String selectedPrintLayout(Id quoteId){
        List<Conga_Quote_Print__c> qp = new List<Conga_Quote_Print__c>();
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
        String deal = dealdesk.Profile_Name__c;
        
        List<User> useradmins = [select id from User where profile.name=:sysadmin OR profile.name=:busadmin OR profile.name=:deal];
        List<Id> useridsadmins = new List<Id>();
        for(User u: useradmins){
            useridsadmins.add(u.id);
        }
        // System.debug('GetUser : '+getUser());
        if(getUser())
            qp = [select id,Print_Layout__c from Conga_Quote_Print__c where ownerid=:useridsadmins and Quote_Record_Id__c=:quoteId order by createddate desc limit 1];
        else
            qp = [select id,Print_Layout__c from Conga_Quote_Print__c where Quote_Record_Id__c=:quoteId order by createddate desc limit 1];
        //System.debug('Print Layout : '+qp[0].Print_Layout__c);
        if(qp.size()>0 && qp[0].Print_Layout__c != null)
            return qp[0].Print_Layout__c;
        else
            return null;
    }
    @AuraEnabled
    public static List<String> selectedexhibits(Id quoteId){
        Conga_Quote_Print__c qp;
        List<Conga_Quote_Print__c> qpList = new List<Conga_Quote_Print__c>();
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
        String deal = dealdesk.Profile_Name__c;
        
        List<User> useradmins = [select id from User where profile.name=:sysadmin OR profile.name=:busadmin OR profile.name=:deal];
        List<Id> useridsadmins = new List<Id>();
        for(User u: useradmins){
            useridsadmins.add(u.id);
        }
        if(getUser()){
            //   qp = [select id,selectedExhibitNames__c from Conga_Quote_Print__c where ownerid=:useridsadmins and Quote_Record_Id__c=:quoteId order by createddate desc limit 1];
            qpList = [select id,selectedExhibitNames__c from Conga_Quote_Print__c where ownerid=:useridsadmins and Quote_Record_Id__c=:quoteId order by createddate desc limit 1];        
        }
        else
            qpList = [select id,selectedExhibitNames__c from Conga_Quote_Print__c where Quote_Record_Id__c=:quoteId order by createddate desc limit 1];   
        List<String> pastcann = new List<String>();
        if(qpList.size()>0 && qpList[0].selectedExhibitNames__c != null)
            pastcann = qpList[0].selectedExhibitNames__c.split(',');
        else
            pastcann.add('');
        return pastcann;
        
    }
    
    @AuraEnabled
    public static String compare(String recordID){
        //  System.debug('recordId : '+recordID);
        Quote_Print_Compare__c qpc = Quote_Print_Compare__c.getInstance('Do Revision Check');
        if(qpc.turn_off_revision_check__c == false){
            //Quoteline_compare.comparewrapper cmw = Quoteline_compare.compareQuoteLine(recordID);
            QuotePrintCompare.comparewrapper cmw = QuotePrintCompare.compareQuoteLine(recordID);
            //  System.debug('cmw : '+cmw);
            // System.debug('cmw message : '+cmw.message);
            /*List<Quote> quotelist = [Select ID, Quote_Revision__c, Display_Generic_Drawers__c from Quote where ID=:recordID];
List<Quote_Print_Status__c> qprintst = [select id,quote__c,Revision_Number__c,print_status__c from Quote_Print_Status__c where quote__c=:recordID];
boolean executed = false;
if(qprintst.size()>0){
if(qprintst[0].revision_number__c == quotelist[0].quote_revision__c)
executed = true;
}*/
            if(cmw.message == 'Quotes are Identical!'){
                /*if(executed == true)*/
                return 'Identical';
                /*else
return 'notexecuted';*/
            }
            else
                return cmw.message;
        }
        else{
            /*List<Quote> quotelist = [Select ID, Quote_Revision__c, Display_Generic_Drawers__c from Quote where ID=:recordID];
List<Quote_Print_Status__c> qprintst = [select id,quote__c,Revision_Number__c,print_status__c from Quote_Print_Status__c where quote__c=:recordID];
boolean executed = false;
if(qprintst.size()>0){
if(qprintst[0].revision_number__c == quotelist[0].quote_revision__c)
executed = true;
}
if(executed == true)
return 'Identical';
else
return 'notexecuted';*/
            return 'turnoffrevisioncheck';
        }
    }
    
    //Added zero dollar for SF-BUG-725
    @AuraEnabled
    public static void updateparlocvalues(Id qId,String[] selectedsec,String template,Boolean isPrintGenericDrawer,Boolean isProductsUnbundled,Boolean zerodollars){//Added new parameter for products unbundled SF-BUG-528
        /*if(isPrintGenericDrawer)
initializePrint(qId);*/
        // System.debug('inside parlocvalues');
        boolean detbyparloctrue = false;
        boolean summbyparloctrue = false;
        boolean summarybyproduct = true;
        for(String s : selectedsec){
            if(s.contains('Detail by Par Location')){
                detbyparloctrue = true;
            }
            if(s.contains('Summary by Par Location')){
                summbyparloctrue = true;
            }
        }
        List<Quote> quotelist = [Select ID, Quote_Revision__c, Display_Generic_Drawers__c from Quote where ID=:qId];
        // soumyad start 964 & 965
        //if(prof == true){
        list<Quote_Line__c> ql = [select id, CONGA_PRODUCT1__c, Higher_Level_Item__c,SAP_Line_Number__c, Quantity__c, Contract_List_Price__c, Contract_List_Price_Recalculate__c,Customer_Price__c,Customer_Price_Recalculate__c, USA_List_Price__c, USA_List_Price_Recalculate__c from Quote_Line__c where Quote__c =: qId];
        List<Quote_Line__c> qlup = new List<Quote_Line__c> ();
        Map<decimal, Quote_Line__c> qtmap = new Map<decimal, Quote_Line__c>();
        
        for(Quote_Line__c ql1 : ql){
            qtmap.put(ql1.SAP_Line_Number__c,ql1);          
        }
        for(Quote_Line__c ql2 : ql){
            Quote_Line__c ql1 = qtmap.get(ql2.Higher_Level_Item__c);
            if(ql1!= null && ql1.SAP_Line_Number__c == ql2.Higher_Level_Item__c){
                if(ql2.Contract_List_Price__c != null){
                    ql2.Contract_List_Price_Recalculate__c = ((ql2.Quantity__c/ql1.Quantity__c)*ql2.Contract_List_Price__c);

                }
                if(ql2.Customer_Price__c != null){
                    ql2.Customer_Price_Recalculate__c = ((ql2.Quantity__c/ql1.Quantity__c)*ql2.Customer_Price__c);
                }
              
                if(ql2.USA_List_Price__c != null){
                    ql2.USA_List_Price_Recalculate__c = ((ql2.Quantity__c/ql1.Quantity__c)*ql2.USA_List_Price__c);
                }
                qlup.add(ql2);
            }
        }
        system.debug('******* qlup '+qlup);
        QuoteLineTriggerHandler.triggerdisabled = true;//IBA-5959
        update qlup;
        //}
        // soumyad end 964 & 965
        /* List<Quote_Print_Status__c> qprintst = [select id,summary_by_product__c,products_unbundled__c,Generic_Drawer__c,quote__c,summary_by_par__c,detail_by_par__c,Revision_Number__c,print_status__c from Quote_Print_Status__c where quote__c=:qId];
//Added products_unbundled__c in the above query for SF-BUG-528 by sravan 
boolean executed = false;
boolean summaryexecuted = false;
boolean detailexecuted = false;
boolean genericdrawers = false;
if(qprintst.size()>0){

if(qprintst[0].revision_number__c == quotelist[0].quote_revision__c){
if((qprintst[0].summary_by_par__c == true || qprintst[0].detail_by_par__c == true) && (summbyparloctrue == true || detbyparloctrue == true)){
if(qprintst[0].Generic_Drawer__c == false)
summaryexecuted = true;
}
if(qprintst[0].Generic_Drawer__c == false && qprintst[0].products_unbundled__c == false && qprintst[0].summary_by_product__c == true)//updated if condition to include product unbundled condition for SF-BUG-528 by sravan
executed = true;

//if(qprintst[0].Generic_Drawer__c == true || ((qprintst[0].summary_by_par__c == true || qprintst[0].detail_by_par__c == true) && summaryexecuted == false))
//initializePrint(qId);
}
else{
qprintst[0].summary_by_par__c = false;
qprintst[0].detail_by_par__c = false;
qprintst[0].summary_by_product__c = false;
qprintst[0].Generic_Drawer__c = false;
qprintst[0].products_unbundled__c = false;//new field for products unbundled on quote print status object for SF-BUG-528
update qprintst[0];
}
}*/
        
        //if(template != 'Pictures only'){
        /*if(summbyparloctrue == true || detbyparloctrue == true){*/
        //if(summaryexecuted == false || isPrintGenericDrawer == true || isProductsUnbundled == true){//Added isProductsUnbundled to execute batches whenever products unbundled is selected SF-BUG-528    
        
        
        boolean batchstart = false;
        List<Quote_Print_Status__c> qpsList = [select id,Generic_Drawer__c,quote__c,summary_by_par__c,Detail_by_par__c,summary_by_product__c,products_unbundled__c,print_status__c,Zero_Dollar__c from Quote_Print_Status__c where quote__c=:qId order by lastmodifieddate desc]; //soumyad IBA-1632 add new field
        //System.debug('batch Status : '+qpsList[0].print_status__c);
        for(Quote qu:quotelist){
            if(qpsList.size()>0 && qpsList[0].print_status__c == 'PROCESSING'){
                batchstart = true;
                
            }
            
            if(batchstart == false){
                if(qpsList.size()>0){
                    //soumyad IBA-1632 start
                    if(zerodollars){
                        qpsList[0].Zero_Dollar__c = true; 
                    }
                    else{
                        qpsList[0].Zero_Dollar__c = false;
                    }
                    //soumyad IBA-1632 end
                    if(isPrintGenericDrawer){
                        qpsList[0].Generic_Drawer__c = true; 
                    }
                    else{
                        qpsList[0].Generic_Drawer__c = false;
                    }
                    //Added/updated by Sravan for SF-BUG-528 START
                    if(isProductsUnbundled){
                        qpsList[0].products_unbundled__c = true;
                    }
                    else{
                        qpsList[0].products_unbundled__c = false;
                    }   
                    if(summbyparloctrue && !isProductsUnbundled){
                        qpsList[0].summary_by_par__c = true;
                    }
                    else{
                        qpsList[0].summary_by_par__c = false;
                    }
                    if(detbyparloctrue && !isProductsUnbundled){
                        qpsList[0].Detail_by_par__c = true;
                    }
                    else{
                        qpsList[0].Detail_by_par__c = false;
                    }
                    if(!isProductsUnbundled)
                        qpsList[0].summary_by_product__c = true;
                    else
                        qpsList[0].summary_by_product__c = false;
                    //Added/updated by Sravan for SF-BUG-528 END
                    qpsList[0].print_status__c = 'PROCESSING';
                    qpsList[0].Revision_Number__c = qu.Quote_Revision__c;
                    update qpsList[0];
                }
                else{
                    Quote_Print_Status__c qps = new Quote_Print_Status__c();
                    //soumyad IBA-1632 start
                    if(zerodollars){
                        qps.Zero_Dollar__c = true; 
                    }
                    else{
                        qps.Zero_Dollar__c = false;
                    }
                    //soumyad IBA-1632 end
                    if(isPrintGenericDrawer){
                        qps.Generic_Drawer__c = true;
                    }
                    else{
                        qps.Generic_Drawer__c = false;
                    }
                    //Added/updated by Sravan for SF-BUG-528 START
                    if(isProductsUnbundled){
                        qps.products_unbundled__c = true;
                    }
                    else{
                        qps.products_unbundled__c = false;
                    }
                    if(summbyparloctrue && !isProductsUnbundled){
                        qps.summary_by_par__c = true;
                    }
                    else{
                        qps.summary_by_par__c = false;
                    }
                    if(detbyparloctrue && !isProductsUnbundled){
                        qps.Detail_by_par__c = true;
                    }
                    else{
                        qps.Detail_by_par__c = false;
                    }
                    if(!isProductsUnbundled)
                        qps.summary_by_product__c = true;
                    else
                        qps.summary_by_product__c = false;
                    //Added/updated by Sravan for SF-BUG-528 END
                    qps.quote__c = qId;
                    qps.print_status__c = 'PROCESSING';
                    qps.Revision_Number__c = qu.Quote_Revision__c;
                    insert qps;
                }
                //initializePrint(qId);
                //QuotePrintProcess_Batch_0_Of_6 b = new QuotePrintProcess_Batch_0_Of_6(qId,true,true,isPrintGenericDrawer,isProductsUnbundled);//Added isProductsUnbundled parameter for SF-BUG-528
                //database.executeBatch(b);
            }
            //QuotePrintProcess_Batch_1_Of_6 b = new QuotePrintProcess_Batch_1_Of_6(qId);
            //database.executeBatch(b);
            //QUOTE PRINT PHASE 2 - iF AN OF THE PAR LOCATION RELATED SECTIONS WERE SELECTED 0_OF_6 BATCH WILL BE CALLED ELSE 1_OF_6
            //IBA-5959
            QuotePrintProcess_Batch_0_Of_initialize b = new QuotePrintProcess_Batch_0_Of_initialize(qId,summbyparloctrue,detbyparloctrue,isPrintGenericDrawer,isProductsUnbundled,zerodollars);
            database.executeBatch(b);
            
        }
        //}
        /*else{
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
}*/
        //}
        /*else if(executed == false || isPrintGenericDrawer == true || isProductsUnbundled == true){//Added isProductsUnbundled condition for SF-BUG-528
boolean batchstart = false;
List<Quote_Print_Status__c> qpsList = [select quote__c,products_unbundled__c,print_status__c from Quote_Print_Status__c where quote__c=:qId order by lastmodifieddate desc];
//System.debug('batch Status : '+qpsList[0].print_status__c);
for(Quote qu:quotelist){
if(qpsList.size()>0 && qpsList[0].print_status__c == 'PROCESSING'){
batchstart = true;

}

if(batchstart == false){
if(qpsList.size()>0){
if(isPrintGenericDrawer){
qpsList[0].Generic_Drawer__c = true; 
}
else{
qpsList[0].Generic_Drawer__c = false;
}
//Added/updated by Sravan for SF-BUG-528 START
if(isProductsUnbundled){
qpsList[0].products_unbundled__c = true;
}
else{
qpsList[0].products_unbundled__c = false;
}
if(!isProductsUnbundled)    
qpsList[0].summary_by_product__c = true;
else
qpsList[0].summary_by_product__c = false;
//Added/updated by Sravan for SF-BUG-528 END
qpsList[0].print_status__c = 'PROCESSING';
qpsList[0].Revision_Number__c = qu.Quote_Revision__c;
update qpsList[0];
}
else{
Quote_Print_Status__c qps = new Quote_Print_Status__c();
if(isPrintGenericDrawer){
qps.Generic_Drawer__c = true;
}
else{
qps.Generic_Drawer__c = false;
} 
//Added/updated by Sravan for SF-BUG-528 START
if(isProductsUnbundled){
qps.products_unbundled__c = true;
}
else{
qps.products_unbundled__c = false;
}
qps.quote__c = qId;
if(!isProductsUnbundled)
qps.summary_by_product__c = true;
else
qps.summary_by_product__c = false;
//Added/updated by Sravan for SF-BUG-528 END
qps.print_status__c = 'PROCESSING';
qps.Revision_Number__c = qu.Quote_Revision__c;
insert qps;
}
initializePrint(qId);
QuotePrintProcess_Batch_1_Of_6 b = new QuotePrintProcess_Batch_1_Of_6(qId,false,false,isPrintGenericDrawer,isProductsUnbundled);//Added isProductsUnbundled parameter for SF-BUG-528
database.executeBatch(b);
}
}
}*/
        /*else{
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
}*/
    }
    
    
    @AuraEnabled
    public static void callBatch(Id qId, Boolean isPrintGenericDrawer){
        QuotePrintProcess_Batch_0_Of_6 b = new QuotePrintProcess_Batch_0_Of_6(qId,true,true,isPrintGenericDrawer);
        database.executeBatch(b);
    }
    
    @AuraEnabled
    public static string checkBatch(Id qId){
        List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c
                                               where quote__c=:qId order by lastmodifieddate desc];
        List<Quote> quotelist = [Select ID, Quote_Revision__c, Display_Generic_Drawers__c from Quote where ID=:qId];
        if(qpsList.size()>0){
            if(qpsList[0].print_status__c == 'FINISHED')
            {               
                qpsList[0].Revision_Number__c = quoteList[0].Quote_Revision__c;
                update qpsList[0];
                return 'finished';   
            }                
            else if(qpsList[0].print_status__c == 'FAILED')
            {
                return 'failed'; 
            }
            else
                return 'notdone';
        }
        else{
            return 'batchnotstarted';
        }
    }
    
    @AuraEnabled
    public static void initializePrint(Id qId){
        
        List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c where quote__c=:qId order by lastmodifieddate desc limit 1]; //soumyad IBA-1631 added field
        //soumyad IBA-1631 start
        if(qpsList.size()>0){
            qpsList[0].print_status__c = 'REPRINT'; 
            update qpsList[0]; 
        }
        //soumyad IBA-1631 end      
    }
    
    @AuraEnabled
    public static void resetQuoteLineGrouping(Id qId){
        // System.debug('@@qId :'+qId);
        List<Quote_Line__c> qli = [select id,material_type__c,Part_of_a_Bundle__c,Conga_Base_Product__c,Conga_Quantity__c,conga_Renewal_grouped_product__c,conga_Product__c,sap_line_Number__c,From_Quote_Print__c,Conga_Product1__c,Conga_part_of_bundle_check__c,Higher_Level_Item__c,conga_higher_level_item__c,Conga_Grouped_Product__c,pricing_reference_model__c From Quote_Line__c where Quote__c =:qId 
                                   //and customer_price__c != 0 and customer_price__c != null
                                   //and Line_Status__c != :Label.Conga_Quote_Line_Status
                                   FOR UPDATE];
        
        FromPrint__c setting;
        Id profileId = userinfo.getProfileId();
        setting = FromPrint__c.getInstance(profileId);
        if (setting.fromprint__c == false) {
            setting.fromprint__c = true;
            upsert setting;
        }
        for(Quote_Line__c q : qli){
            
            
            //q.Conga_Base_Product__c = false;
            String prodcode = '';
            q.Conga_Base_Product__c = false;
            if(q.Higher_Level_Item__c != 0)
                q.conga_higher_level_item__c = String.valueof(q.Higher_Level_Item__c);
            else{
                q.conga_higher_level_item__c = String.valueof(q.sap_line_Number__c);
            }
            q.Conga_Generic_Drawer_Grouped__c = false;
            q.Generic_Drawer_Product__c = null;
            q.Conga_Grouped_Product__c = false;
            q.Conga_part_of_bundle_check__c = false;
            q.conga_Renewal_grouped_product__c = false;
            q.Conga_Quantity__c = 0;
            q.Conga_part_of_bundle_true__c = false;
            q.Conga_Extended_Price_Materials__c =0;
            q.Conga_Extended_Services__c = 0;
            
            if(q.Conga_Product1__c != null){
                prodcode = q.Conga_Product1__c;
                if((prodcode.contains('-SV') || prodcode.contains('-sv')) && q.material_type__c == 'SERVICE'){
                    prodcode = prodcode.replace('-SV', '');
                    prodcode = prodcode.replace('-sv', '');
                }
                
            }
            q.conga_Product__c = prodcode;
            q.From_Quote_Print__c = true;
        }
        isQuoteUpdateFrom_QuotePrintController = true;
        update qli;
        
    }
    
    //Added this method by JAY CR-18666
    @AuraEnabled
    public static Boolean isNotOmnicellServiceOrderType(String recordID){
        Boolean retVal = true;
        
        List<HidePrintOptions__c> mcs = HidePrintOptions__c.getall().values();
        List<String> orderTypeList = new List<String>();
        
        for (HidePrintOptions__c printOption : mcs) {
            if(printOption.HidePrint__c)
            {
                orderTypeList.add(printOption.Name);
            }
        }
        List<Quote> quotelist = [Select ID, Order_Type__c from Quote where ID=:recordID and Order_Type__c =:orderTypeList];
        if(quoteList.size() > 0)
        {
            retVal = false;
        }
        return retVal;
    }
    //IBA-3867(4625) Starts Abhrajitc
    @AuraEnabled
    public static Boolean getSAPSalesOrgAndCurrency(String recordID) {
        Boolean isSalesOrgInt = false;
        List<Quote> quotelist = [SELECT Id, SAP_Sales_Org__r.Sales_Org__c FROM Quote WHERE ID = :recordID];
        if (!quotelist.isEmpty()) {
            Quote quote = quotelist[0];
            String salesOrg = quote.SAP_Sales_Org__r.Sales_Org__c;
            if (salesOrg == 'OM31') {
                isSalesOrgInt = true;
            }
        }
        return isSalesOrgInt;
    }
    //IBA-3867(4625) Ends Abhrajitc
    //IBA-2290 Starts
    @AuraEnabled
    public static Boolean ismaPassSupplementApproval(String quoteId){
        Boolean maPass = false;
        List<Quote_Line__c> quoteLines = [SELECT Id, Product__r.Portfolio_Segment__c, Product__r.Name FROM Quote_Line__c WHERE Quote__c =:quoteId];// IBA-2290
        for(Quote_Line__c ql : quoteLines){
            if(ql.Product__r.Portfolio_Segment__c == 'SingleDose Automation' || ql.Product__r.Portfolio_Segment__c == 'Core Machine'){
                maPass = true;
            }
        } 
        return maPass;
    } //IBA-2290 Ends
    
    
    //Added this method by JAY CR-18666
    @AuraEnabled
    public static Boolean isSupplementApproval(String quoteId){
        Boolean retVal = false;
        String recordtypeQA = '';
        String status = '';
        Quote quote = null;
        List<Quote> quoteList = [select id,status from Quote where id=:quoteId and Order_Type__c = 'ZQRS'];
        if(quoteList.size() > 0)
        {
            quote = quoteList[0];
            //start 1440
            User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
            if(u.profile.Name == 'Deal Desk & Legal' || u.profile.Name == 'System Administrator' || u.profile.Name == 'IT Administrator') // added IT Admin as part of IBA-3443
            {
                retVal = true; 
            }
            //end 1440
        }
        else
        {            
            return retVal;
        }
        
        List<Quote_Approval__c> qa = [select id,recordtypeid,status__c 
                                      from quote_approval__c where quote__c = :quoteId                                       
                                      order by createddate desc limit 1];                                       
        
        if(qa.size()>0){
            recordtypeQA = Schema.getGlobalDescribe().get('Quote_Approval__c').getDescribe().getRecordTypeInfosById().get(qa[0].RecordTypeId).getName();
            status = qa[0].status__c;
        }
        if(!(recordtypeQA == 'NAA Supplement Quote' || recordtypeQA.contains('International ADC/VBM') || recordtypeQA == 'MA Supplement Quote'))
        { retVal = false;}
        
        //Added by JAY CR-18666
        if((recordtypeQA == 'NAA Supplement Quote' || recordtypeQA.contains('International ADC/VBM') || recordtypeQA == 'MA Supplement Quote')
           && (quote.status == 'E0009' || quote.status == 'E0013' || quote.status == 'E0014' || quote.status == 'E0019')){
               
               retVal = true;
               
           }
        
        return retVal;
    }
    @AuraEnabled
    public static String saveCannedLan(String terms,Id quoteId,String[] prevselectedCannedLan,String[] newselectedCannedLan,String layout,Boolean editcanlansel){
        if(editcanlansel){
            String[] newcanlan = new List<String>();
            for(String s : newselectedCannedLan){
                boolean prev = false;
                for(String ss : prevselectedCannedLan){
                    if(ss == s)
                        prev = true;
                }
                // System.debug('s : '+s+' prev : '+prev);
                if(prev == false)
                    newcanlan.add(s);
            }
            List<Canned_Language__c> clan = new List<Canned_Language__c>();
            Integer ik;
            /*Added by sravan for Canned lan fixes START*/
            boolean ivprd = false;
            boolean simplifi = false;
            boolean perfcentr = false;
            
            List<quote_line__c> qlines = [select id,product__r.DW_Product_Line__c,product__r.Business_Line__c from quote_line__c where quote__c=:quoteId];
            for(Quote_Line__c q:qlines){
                if(q.product__r.Business_Line__c != 'Simplifi 797'){
                    ivprd = true;
                }
                if(q.product__r.Business_Line__c == 'Simplifi 797'){
                    simplifi = true;
                }
                if(q.product__r.DW_Product_Line__c == 'Performance Center'){
                    perfcentr = true;
                }
                /*Added by sravan for Canned lan fixes END*/
            }
            
            if(layout == 'Omnicell'  || layout == 'Change Order Omnicell'){
                clan = [select id,name,Canned_Language_Detail__c from Canned_Language__c where Omnicell_or_Aesynt__c= 'Omnicell' order by Canned_language_sequence__c asc];
                if(ivprd && simplifi && perfcentr)
                    ik = prevselectedCannedLan.size()+1;
                else if(ivprd && simplifi)
                    ik = prevselectedCannedLan.size()+1;
                else
                    ik = prevselectedCannedLan.size()+1;
            }
            else{
                clan = [select id,name,Canned_Language_Detail__c from Canned_Language__c where Omnicell_or_Aesynt__c= 'Aesynt' order by Canned_language_sequence__c asc];
                if(ivprd && simplifi && perfcentr)
                    ik = prevselectedCannedLan.size()+8;
                else if(ivprd && simplifi)
                    ik = prevselectedCannedLan.size()+7;
                else
                    ik = prevselectedCannedLan.size()+6;
            }
            Quote quote = [select Service_Level__c,EOL_Date__c from Quote where id=:quoteId];
            for(String s: newcanlan){
                for(Canned_Language__c c: clan){
                    if(c.Name == s){
                        terms=terms+ik+'. '+c.Canned_Language_Detail__c+'<br/>';
                    }
                }
                ik= ik+1;
                
            }
            return terms;
        }
        else
            return '';
    }
    
    // soumyad IBA-1632 start
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
        
        
        
    }
    
    
    
    @AuraEnabled
    Public static comparewrapper compareQuoteLine(String recordID){
        list<turn_off_print_check__c> pchk = [select disabled__c from turn_off_print_check__c where Name = 'Compare Check'];
        List<subcomparewrapper> subcompwrap = new List<subcomparewrapper>();
        Quote quot = [select id, name, Quote_Number__c, Order_Type__c, Currency__c from Quote where ID =:recordID];
        comparewrapper compwrap;
        system.debug('*** '+pchk[0].disabled__c+' '+quot.Currency__c);
        if(pchk[0].disabled__c == false && quot.Currency__c == 'USD'){
            
            try{
                
                
                if(quot.Order_Type__c != 'ZQRS'){
                    Quote_Print_Status__c quoteprintStatus= [Select Id, Name, Revision_Number__c,Quote__r.Quote_Revision__c, Generic_Drawer__c, Quote__c,products_unbundled__c,print_status__c,Zero_Dollar__c from Quote_Print_Status__c where Quote__c =: recordID];
                    string quotenumber = quot.Quote_Number__c;
                    boolean genericDrawer = quoteprintStatus.Generic_Drawer__c;
                    Map<String, Object> jsondata = new Map<String, Object> {'Quote_Number__c' => quotenumber, 'Generic_Drawer__c'=>genericDrawer};
                        String jsonstrinsert = JSON.serialize(jsondata);
                    final string comp_creds1 = 'CastIronIntegration';
                    String EndPoint1;
                    
                    //String EndPoint1 = compCreds.Endpoint__c;
                    list<CastIronIntegration__c> cstint = [select compare_button_endpoint__c, compare_button_timeout__c from CastIronIntegration__c limit 1];
                    for(CastIronIntegration__c c:cstint){
                        endPoint1 = c.compare_button_endpoint__c;
                        
                    }
                    Integer timeout = 120000;
                    
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
                    
                    Map<Integer, Map<String, Object>> myMaps = new Map<Integer, Map<String, Object>>();
                    List<Object> level2list = (List<Object>) level1.get('Quote_Line__c');
                    string Itemcount = (string)level1.get('Item_Count');
                    if(Itemcount == null){
                        Itemcount = '0';
                    }
                    
                    Integer sapQuoteLinecount = 0;
                    if(level2list != null){ 
                        sapQuoteLinecount = level2list.size();
                        for(Integer i=0;i<level2list.size();i++){
                            myMaps.put(i, (Map<String, Object>)level2list[i]);
                        }
                    }
                    Boolean  isRevision = false;
                    Map<Id, Quote_Print_Status__c> qpsmap = new Map<Id, Quote_Print_Status__c>([Select Id, Name, Revision_Number__c,Quote__r.Quote_Revision__c,  Quote__c from Quote_Print_Status__c where Quote__c =: recordID]);
                    Map<Id, Quote_Line__c> qline = new Map<Id, Quote_Line__c>([SELECT QT_Print_Flag__c, Is_Lease_buyout__c, IFRenewalProduct__c, QT_Print_Exchange_Rate__c, Contract_List_Price__c, QT_CONGA1_USA_LIST_PRICE__c,QT_USA_LIST_PRICE__c,QT_CONGA_LIST_PRICE__c,QT_Conga_List_Price1__c,QT_CONGA_UNIT_PRICE__c,QT_CONGA_EXTENDED_PRICE_MATERIALS__c,QT_Conga_Unit_Services__c,QT_Conga_Extended_Services__c,Higher_Level_Item__c,USA_List_Price__c,Cong_Extended_Price_Material_type__c,Conga2_USA_List_Price__c,Conga_List_Price1__c,Conga_Solution_Includes__c,Conga_part_of_bundle_true__c,Conga_Unit_Services_Material_Type__c,Conga_Unit_Service_by_location__c,Conga_Unit_Price_by_Location__c,Total_Monthly_Product_by_Location__c,Total_Monthly_Support_Services_by_Locati__c,Par_Location_Monthly_Total__c, Quote__r.Conga_Grand_Total_Monthly__c,Quote__r.Conga_Total_Monthly_Product__c,Quote__r.Conga_Total_Monthly_Support_Services__c,Conga_Total_Product_by_Par_Monthly__c,Conga_Total_Service_by_Par_Monthly__c, Conga_Par_Location_Total__c, Conga_Extended_Price_Materials__c,Conga_Product_Description__c,Conga1_USA_List_Price__c,Conga_List_Price__c ,Conga_Unit_Price__c ,Conga_Extended_Services__c ,Conga_Unit_Services__c ,Conga_Total_Price__c ,Conga_Product1__c, Quote__r.Conga_Order_Type__c,Conga_Grouped_Product__c,conga_quantity__c,Conga_Picture_URL__c,Extended_Services__c,Conga_Total_Product_by_Location__c,Conga_Total_Shipping_and_Handling__c, Conga_Total_Support_Services_by_Location__c , Quote__r.ExpirationDate,Conga_USA_Price_List__c,Quote__r.Status,Product__r.Description, Quote__r.Supplement1__c,Product__r.Family, Product__r.Id, Product__r.Name, Product__r.ProductCode, Quote__r.Id, Customer_Price__c, Discount_Amount__c, Extended_Price__c, Generic_Drawer__c, Line_Item_Description__c, List_Price__c, Name, Part_of_a_Bundle__c, Par_Location__c,Picture_URL__c, Pricing_Reference_Model__c, Product__c, Product_Code__c, Product_Cost__c, Product_Line_for_this_Service__c, Quantity__c, Quote__c, Quote_Line_Item_Type__c, Sales_Text__c, SAP_Line_Number__c, Serial_Number__c, Quote__r.From__c,Total_Cost__c,Conga_Renewal_Extended_Services__c,Conga_Renewal_Unit_Services__c FROM Quote_Line__c WHERE Quote__r.Id =: recordID AND ( customer_price__c > 0 OR usa_list_price__c > 0 OR conga_extended_services__c > 0 OR conga_renewal_extended_services__c > 0 OR product__r.dw_product_class__c = 'Training' OR ( conga_grouped_product__c = true AND free_month_applied__c = true ) OR zero_header__c = true OR ( discount_percent__c = -100 AND conga_quantity__c > 0 AND contract_list_price__c > 0 AND Pricing_Reference_Model__r.Name != null AND generic_drawer_product__c = NULL AND print_discounted_items__c = true ))
                                                                               AND ( ( conga_grouped_product__c = true AND generic_drawer_product__c = NULL ) OR ( conga_renewal_grouped_product__c = true AND generic_drawer_product__c = NULL ) OR conga_generic_drawer_grouped__c = true OR ( is_lease_buyout__c = true AND conga_quantity__c > 0 AND generic_drawer_product__c = NULL ) OR product__r.dw_product_class__c = 'Training' OR zero_header__c = true OR ( discount_percent__c = -100 AND conga_quantity__c > 0 AND contract_list_price__c > 0 AND Pricing_Reference_Model__r.Name != null AND generic_drawer_product__c = NULL AND print_discounted_items__c = true) OR ( discount_percent__c = -100 AND higher_level_item__c = 0 AND generic_drawer_product__c = NULL AND print_discounted_items__c = true ) OR ( discount_amount__c < 0 AND contract_list_price__c > 0 AND higher_level_item__c = 0 AND amount_discount_to_zero__c = true ) )
                                                                               AND conga_product1__c != NULL AND ( NOT conga_product1__c LIKE 'Fr%' ) AND ( NOT conga_product1__c LIKE '%SV' ) AND is_conga_exclude_product__c = false ORDER BY conga_product1__c ASC]);
                    
                    
                    double sfdcQuotelinecount = qline.size();
                    string sfdcjson = JSON.serialize(qline.values());
                    for(sObject obj: qline.values()){
                        Map<String, Object> sfdcjsondeserilise = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj)); 
                        
                    }
                    Map<Id, Quote> quotemap = new Map<Id, Quote>([select id, name, Quote_Number__c,Quote_Revision__c  from Quote where ID =:recordID]);
                    boolean compresult = false;
                    for(Quote qu: quotemap.values()){
                        for(Quote_Print_Status__c qps: qpsmap.values()){
                            
                            if(qps.Revision_Number__c == level1.get('Quote_Revision__c')){
                                
                                
                                if(double.valueOf(sfdcQuotelinecount)==double.valueOf(Itemcount)){
                                    isRevision = true;
                                }
                                else if(sfdcQuotelinecount!=double.valueOf(Itemcount)){
                                    compresult = true;
                                }
                                
                            }
                            else if(qu.Quote_Revision__c ==level1.get('Quote_Revision__c')){
                                compresult = true;
                            }
                            else{
                                compresult = true;
                            }
                        }
                        
                        if(isRevision){
                            for(Quote_Line__c ql: qline.values()){
                                
                                for(Integer i: myMaps.keyset())
                                {
                                    Map<string, object> maps = new Map<String,Object>();
                                    maps = myMaps.get(i);
                                    If(maps.containsKey('conga_Product1_c')){
                                        String sapproduct = (string)maps.get('conga_Product1_c');
                                        string sfproduct = ql.Conga_Product1__c;
                                        
                                        if( (sfproduct == sapproduct && (maps.get('If_Renewal_Buyout') == null) && (ql.Is_Lease_buyout__c ==false && ql.IFRenewalProduct__c==false)) ||
                                           ((sfproduct == sapproduct && (maps.get('If_Renewal_Buyout') != null) && (ql.Is_Lease_buyout__c || ql.IFRenewalProduct__c) ) ) ){
                                               
                                               string saplpc = (string)maps.get('Conga_List_Price__c');
                                               double conga_list_price;
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
                                               double conga_extended_service;
                                               
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
                                                  double.valueOf(conga_extended_service)!= double.valueOf(sapext) ||
                                                  string.valueOf(isRenewal) != string.valueOf(saprew)){
                                                      
                                                      compresult = true;
                                                  }
                                               
                                           } 
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    
                    if(quoteprintStatus.Generic_Drawer__c == true && quoteprintStatus.products_unbundled__c == false &&
                       quoteprintStatus.Zero_Dollar__c == false)  
                        //|| (quoteprintStatus.Generic_Drawer__c == false && quoteprintStatus.products_unbundled__c == false && quoteprintStatus.Zero_Dollar__c == false))
                        //Pabitra -IBA-1736 : commented the above as USA_List and other options except generic drawer entering this block which is not supposed to happen, part of IBA-1632
                    {
                        if(compresult == false && isRevision == true){
                            if(double.valueOf(Itemcount)== double.valueOf(sfdcQuotelinecount)){
                                compwrap = new comparewrapper(subcompwrap, 'Identical',false);  
                            }
                        }else{
                            compwrap = new comparewrapper(subcompwrap, 'Different',true); 
                        }
                    }else{
                        compwrap = new comparewrapper(subcompwrap, 'NA',false); 
                    }
                }else{
                    compwrap = new comparewrapper(subcompwrap, 'NA',false);
                }
                return compwrap;
            }
            catch(Exception e){
                
                return new comparewrapper(subcompwrap, 'NA',false);
            }
        }else {
            compwrap = new comparewrapper(subcompwrap, 'NA',false);
            return compwrap;
        }
    }
    // soumyad IBA-1632 end
}