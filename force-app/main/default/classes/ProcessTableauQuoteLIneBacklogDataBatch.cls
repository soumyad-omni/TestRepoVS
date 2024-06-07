global class ProcessTableauQuoteLIneBacklogDataBatch  implements Database.Batchable<SObject>{
    global Database.queryLocator start(Database.BatchableContext bc){
        string qlbquery = '';
        Date today= date.today();
        Date oneDayAgo =today.addDays(-1);
        String threeMonthsLater = String.valueOf(oneDayAgo.addMonths(3));
        if(! Test.isRunningTest()){
            qlbquery='select id, WBS_Code__c from Quote_Line_Backlog__c  where WBS_Code__c != null and Valid_From__c <=today and Valid_To__c >= '+threeMonthsLater+' ORDER BY WBS_Code__c, SAP_Order_Number__c, SAP_order_line_item_number__c desc';            
        }
        else
        {
            qlbquery='select id, WBS_Code__c from Quote_Line_Backlog__c  where WBS_Code__c != null and Higher_Level_Item__c = 0 limit 2';
        }
        System.debug('qlbquery:'+qlbquery);
        return database.getQueryLocator(qlbquery);
    }
    global void execute (Database.BatchableContext BC, List<Quote_Line_Backlog__c> backlogBatchData){
        Date today= date.today();
        Date oneDayAgo =today.addDays(-1);
        Date threeMonthsLater = oneDayAgo.addMonths(3);
 
        Set<String> wbsCodes = new Set<String>();
        Set<String> checkExistingWBS = new Set<String>();
        Set<String> newWBS = new Set<String>();                
        List<Quote_Line_Backlog__c> qlbList = new List<Quote_Line_Backlog__c>();
        Map<String,Quote_Line_Backlog__c> qlDataWithWBSCode = new Map<String,Quote_Line_Backlog__c>();
        List<Backlog_Inflow_Outflow_Tableau__c> backlogTableauRecsToCreate = new List<Backlog_Inflow_Outflow_Tableau__c>();
        
        for(Quote_Line_Backlog__c qlData:backlogBatchData){
            wbsCodes.add(qlData.WBS_Code__c);
        }        

        
        for(Backlog_Inflow_Outflow_Tableau__c obj : [SELECT id, WBS_Code__c  FROM Backlog_Inflow_Outflow_Tableau__c WHERE WBS_Code__c IN :wbsCodes])
        {
            checkExistingWBS.add(obj.WBS_Code__c);
        }
        
        for(String wbs : wbsCodes)
        {
            if(!checkExistingWBS.contains(wbs))
            {
                newWBS.add(wbs);
            }
        }
        
        wbsCodes.clear();
        
        qlbList = [SELECT id,Serial_No__c,Fcst_Live_Date__c,Customer_Number__c,Actual_Cost__c,Assignment__c,Booking_Including_Rebate__c,Changed_Date__c,
                   Copied_From_Quote_Lines__c,Cost__c,Customer_Name__c,Deferred_Product_Revenue__c,Delivery_Date__c,Delivery_DateTime__c,Delivery_Time__c,
                   Derived_Portfolio_Segment__c,expected_booking__c,Live_Quarter__c,GL_Account__c,GL_Description__c,Higher_Level_Item__c,Install_Date__c,
                   Install_Time__c,Installation_Status__c,Is_One_Time_Process__c,Is_Processed__c,Labor_Cost__c,Live_Date__c,Margin__c,Margin_with_Markup_cost__c,
                   Opportunity__c,Opportunity_Forecast_Category__c,Opportunity_Forecast_Category_Order__c,Order_Type__c,Overhead_Cost__c,Portfolio_Segment__c,
                   Product__c, Product_Description__c,Product_Name__c,Quantity__c,Quote__c,Quote_Line__c,Name,RLD_Date__c,RLD_Quarter__c,Run_Trigger__c,SAP_Line_Number__c,
                   SAP_order_line_item_number__c,SAP_Order_Number__c,SAPProductType__c,SAP_Quote_Number__c,Simplified_Segment__c,Status__c,Sub_Category__c,
                   Total_Cost__c,Total_cost_with_Markup__c,Total_cost_without_Markup__c,Unit_of_Measure__c,Valid_From__c,Valid_To__c,VBELN__c,POSNR__c,UEPOS__c,
                   MATNR__c,MAKTX__c,Sales_Unit__c,Product_Cost__c,Reporting_Cost__c,ZCategory__c,LFsta__c,GBSTA__c,J_Status__c,DEF_Category__c,Sold_To__c,
                   Sold_To_Name__c,FCStatus__c,Plant_Site__c,Plant_Description__c,MSCategory__c,New_Region__c,Reason_For_Rejection__c,Rejection_Description__c,
                   Planned_Revn__c,Install_Revn__c,Business_Seg__c,Bus_Line__c,Product_Seg__c,Product_Line__c,Product_Family__c,Product_Type__c,Product_Class__c,
                   Product_Brand__c,SF_Product_Type__c,Revenue_Group__c,Install_Probability__c,SO_Date__c,Par_Location__c,Last_Billing_Doc__c,Last_Billing_Doc_Date__c,
                   Last_PGI_Doc__c,Last_PGI_Doc_Date__c,Customer_Type__c,MTLGROUP1__c,MTL_Group1_Description__c,MTLGROUP2__c,MTL_Group2_Description__c,ITEM_DEL_STATUS__c,
                   Planned_Cost__c,WBS_Code__c,WBS_Element_Description__c,WBS_Status__c,WBS_Status_Description__c, Planned_Revenue_Booked__c, MTL_Type__c , Booking_Date__c, Booking_Quarter__c   
                   FROM Quote_Line_Backlog__c  
                   WHERE WBS_Code__c IN :newWBS
                   AND Valid_From__c <= TODAY 
                   AND Valid_To__c >:threeMonthsLater
                   ORDER BY WBS_Code__c, SAP_Order_Number__c, SAP_order_line_item_number__c 
                   DESC];
        
        
        
        
        for(Quote_Line_Backlog__c qlData:qlbList){
            wbsCodes.add(qlData.WBS_Code__c);
            qlDataWithWBSCode.put(qlData.WBS_Code__c, qlData);
        }
        List<AggregateResult> results = [Select WBS_Code__c,sum(expected_booking__c) expectedBooking,sum(Total_Cost__c) TotalCost,sum(Booking_Including_Rebate__c) TotalRebate ,
                                         sum(Actually_Revenue_Booked__c) revenueBooked, SUM(Total_cost_without_Markup__c) totalCostWithOutMarkUp, SUM(Actual_Cost__c) actualCost   
                                         from Quote_Line_Backlog__c 
                                         where Valid_From__c <=today and Valid_To__c >: threeMonthsLater and WBS_Code__c in :wbsCodes  group by WBS_Code__c];
        
        for(AggregateResult aggr:results){
            String wbsCode = (String)aggr.get('WBS_Code__c');
            if(!checkExistingWBS.contains(wbsCode))
            {
                Decimal expBooking = (Decimal) aggr.get('expectedBooking');
                Decimal TotalCost = (Decimal) aggr.get('TotalCost');
                Decimal TotalRebate = (Decimal) aggr.get('TotalRebate');
                Decimal revenueBooked = (Decimal) aggr.get('revenueBooked');
                Decimal totalCostWithOutMarkUp = (Decimal) aggr.get('totalCostWithOutMarkUp');
                Decimal actualCost = (Decimal) aggr.get('actualCost');
                Decimal rebateExpBooking = expBooking+TotalRebate;                
                Quote_Line_Backlog__c ql = qlDataWithWBSCode.get(wbsCode);                
                Backlog_Inflow_Outflow_Tableau__c baclLogInflowOutflow = new Backlog_Inflow_Outflow_Tableau__c();
                baclLogInflowOutflow.Sum_Of_Rebate_And_Expected_Booking__c = rebateExpBooking;
                baclLogInflowOutflow.Actual_Cost_c__c = ql.Actual_Cost__c;
                baclLogInflowOutflow.Actually_Revenue_Booked__c = revenueBooked;
                baclLogInflowOutflow.Assignment__c=ql.Assignment__c;
                baclLogInflowOutflow.Forecast_Live_Quarter__c = ql.Live_Quarter__c;
                baclLogInflowOutflow.Fcst_Live_Date__c = ql.Fcst_Live_Date__c;
                baclLogInflowOutflow.Booking_Including_Rebate__c=ql.Booking_Including_Rebate__c;
                baclLogInflowOutflow.Changed_Date__c=ql.Changed_Date__c;
                baclLogInflowOutflow.Copied_From_Quote_Lines__c=ql.Copied_From_Quote_Lines__c;
                baclLogInflowOutflow.Cost__c=ql.Cost__c;
                baclLogInflowOutflow.Customer_Name__c=ql.Customer_Name__c;
                baclLogInflowOutflow.Customer_Number__c=ql.Customer_Number__c;
                baclLogInflowOutflow.Deferred_Product_Revenue__c=ql.Deferred_Product_Revenue__c;
                baclLogInflowOutflow.Delivery_Date__c=ql.Delivery_Date__c;
                baclLogInflowOutflow.Delivery_DateTime__c=ql.Delivery_DateTime__c;
                baclLogInflowOutflow.Delivery_Time__c=ql.Delivery_Time__c;
                baclLogInflowOutflow.Derived_Portfolio_Segment__c=ql.Derived_Portfolio_Segment__c;
                baclLogInflowOutflow.expected_booking__c=expBooking;
                baclLogInflowOutflow.GL_Account__c=ql.GL_Account__c;
                baclLogInflowOutflow.Higher_Level_Item__c=ql.Higher_Level_Item__c;
                baclLogInflowOutflow.Install_Date__c=ql.Install_Date__c;
                baclLogInflowOutflow.Install_Time__c=ql.Install_Time__c;
                baclLogInflowOutflow.Installation_Status__c=ql.Installation_Status__c;
                baclLogInflowOutflow.Is_Processed__c=ql.Is_Processed__c;
                baclLogInflowOutflow.Is_One_Time_Process__c=ql.Is_One_Time_Process__c;
                baclLogInflowOutflow.Labor_Cost__c=ql.Labor_Cost__c;
                baclLogInflowOutflow.Live_Date__c=ql.Live_Date__c;
                baclLogInflowOutflow.Margin__c=ql.Margin__c;
                baclLogInflowOutflow.Margin_with_Markup_cost__c=ql.Margin_with_Markup_cost__c;
                baclLogInflowOutflow.Opportunity__c=ql.Opportunity__c;
                baclLogInflowOutflow.Opportunity_Forecast_Category__c=ql.Opportunity_Forecast_Category__c;
                baclLogInflowOutflow.Opportunity_Forecast_Category_Order__c=ql.Opportunity_Forecast_Category_Order__c;
                baclLogInflowOutflow.Order_Type__c=ql.Order_Type__c;
                baclLogInflowOutflow.Overhead_Cost__c=ql.Overhead_Cost__c;
                baclLogInflowOutflow.Portfolio_Segment__c=ql.Portfolio_Segment__c;
                baclLogInflowOutflow.Product__c=ql.Product__c;
                baclLogInflowOutflow.Product_Description__c=ql.Product_Description__c;
                baclLogInflowOutflow.Product_Name__c=ql.Product_Name__c;
                baclLogInflowOutflow.Quantity__c=ql.Quantity__c;
                baclLogInflowOutflow.Quote__c=ql.Quote__c;
                baclLogInflowOutflow.Quote_Line__c=ql.Quote_Line__c;
                baclLogInflowOutflow.RLD_Date__c=ql.RLD_Date__c;
                baclLogInflowOutflow.RLD_Quarter__c=ql.RLD_Quarter__c;
                baclLogInflowOutflow.Run_Trigger__c=ql.Run_Trigger__c;
                baclLogInflowOutflow.SAP_Line_Number__c=ql.SAP_Line_Number__c;
                baclLogInflowOutflow.SAP_order_line_item_number__c=ql.SAP_order_line_item_number__c;
                baclLogInflowOutflow.SAP_Order_Number__c=ql.SAP_Order_Number__c;
                baclLogInflowOutflow.SAP_Product_Type__c=ql.SAPProductType__c;
                baclLogInflowOutflow.Simplified_Segment__c=ql.Simplified_Segment__c;
                baclLogInflowOutflow.SAP_Quote_Number__c=ql.SAP_Quote_Number__c;
                baclLogInflowOutflow.Status__c=ql.Status__c;
                baclLogInflowOutflow.Sub_Category__c=ql.Sub_Category__c;
                baclLogInflowOutflow.Total_Cost__c=totalCost;
                baclLogInflowOutflow.Total_cost_with_Markup__c=ql.Total_cost_with_Markup__c;
                baclLogInflowOutflow.Total_cost_without_Markup__c=ql.Total_cost_without_Markup__c;
                baclLogInflowOutflow.Unit_of_Measure__c=ql.Unit_of_Measure__c;
                baclLogInflowOutflow.Valid_From__c=ql.Valid_From__c;
                baclLogInflowOutflow.Valid_To__c=ql.Valid_To__c;
                baclLogInflowOutflow.VBELN__c=ql.VBELN__c;
                baclLogInflowOutflow.POSNR__c=ql.POSNR__c;
                baclLogInflowOutflow.UEPOS__c=ql.UEPOS__c;
                baclLogInflowOutflow.MATNR__c=ql.MATNR__c;
                baclLogInflowOutflow.MAKTX__c=ql.MAKTX__c;
                baclLogInflowOutflow.Sales_Unit__c=ql.Sales_Unit__c;
                baclLogInflowOutflow.Product_Cost__c=ql.Product_Cost__c;
                baclLogInflowOutflow.Reporting_Cost__c=ql.Reporting_Cost__c;
                baclLogInflowOutflow.ZCategory__c=ql.ZCategory__c;
                baclLogInflowOutflow.LFsta__c=ql.LFsta__c;
                baclLogInflowOutflow.GBSTA__c=ql.GBSTA__c;
                baclLogInflowOutflow.J_Status__c=ql.J_Status__c;
                baclLogInflowOutflow.DEF_Category__c=ql.DEF_Category__c;
                baclLogInflowOutflow.Sold_To__c=ql.Sold_To__c;
                baclLogInflowOutflow.Sold_To_Name__c=ql.Sold_To_Name__c;
                baclLogInflowOutflow.FCStatus__c=ql.FCStatus__c;
                baclLogInflowOutflow.Plant__c=ql.Plant_Site__c;
                baclLogInflowOutflow.Plant_Description__c=ql.Plant_Description__c;
                baclLogInflowOutflow.MS_Catergory__c=ql.MSCategory__c;
                baclLogInflowOutflow.New_Region__c=ql.New_Region__c;
                baclLogInflowOutflow.Reason_For_Rejection__c=ql.Reason_For_Rejection__c;
                baclLogInflowOutflow.Rejection_Description__c=ql.Rejection_Description__c;
                baclLogInflowOutflow.Planned_Revn__c=ql.Planned_Revn__c;
                baclLogInflowOutflow.Install_Revn__c=ql.Install_Revn__c;
                baclLogInflowOutflow.Business_Seg__c=ql.Business_Seg__c;
                baclLogInflowOutflow.Bus_Line__c=ql.Bus_Line__c;
                baclLogInflowOutflow.Product_Seg__c=ql.Product_Seg__c;
                baclLogInflowOutflow.Product_Line__c=ql.Product_Line__c;
                baclLogInflowOutflow.Product_Family__c=ql.Product_Family__c;
                baclLogInflowOutflow.Product_Type__c=ql.Product_Type__c;
                baclLogInflowOutflow.Product_Class__c=ql.Product_Class__c;
                baclLogInflowOutflow.Product_Brand__c=ql.Product_Brand__c;
                baclLogInflowOutflow.SF_Product_Type__c=ql.SF_Product_Type__c;
                baclLogInflowOutflow.Revenue_Group__c=ql.Revenue_Group__c;
                baclLogInflowOutflow.Install_Probability__c=ql.Install_Probability__c;
                baclLogInflowOutflow.Serial_No__c=ql.Serial_No__c;
                baclLogInflowOutflow.SO_Date__c=ql.SO_Date__c;
                baclLogInflowOutflow.Par_Location__c=ql.Par_Location__c;
                baclLogInflowOutflow.Last_Billing_Doc__c=ql.Last_Billing_Doc__c;
                baclLogInflowOutflow.Last_Billing_Doc_Date__c=ql.Last_Billing_Doc_Date__c;
                baclLogInflowOutflow.Last_PGI_Doc__c=ql.Last_PGI_Doc__c;
                baclLogInflowOutflow.Last_PGI_Doc_Date__c=ql.Last_PGI_Doc_Date__c;
                baclLogInflowOutflow.Customer_Type__c=ql.Customer_Type__c;
                baclLogInflowOutflow.MTLGROUP1__c=ql.MTLGROUP1__c;
                baclLogInflowOutflow.MTL_Group1_Description__c=ql.MTL_Group1_Description__c;
                baclLogInflowOutflow.MTLGROUP2__c=ql.MTLGROUP2__c;
                baclLogInflowOutflow.MTL_Group2_Description__c=ql.MTL_Group2_Description__c;
                baclLogInflowOutflow.ITEM_DEL_STATUS__c=ql.ITEM_DEL_STATUS__c;
                baclLogInflowOutflow.Planned_Cost__c=ql.Planned_Cost__c;
                baclLogInflowOutflow.WBS_Code__c=ql.WBS_Code__c;
                baclLogInflowOutflow.WBS_Element_Description__c=ql.WBS_Element_Description__c;
                baclLogInflowOutflow.WBS_Status__c=ql.WBS_Status__c;
                baclLogInflowOutflow.WBS_Status_Description__c=ql.WBS_Status_Description__c;
                baclLogInflowOutflow.Is_Quote_Line_Backlog_Data__c= true;
                baclLogInflowOutflow.Quote_Line_Backlog__c = ql.id;
                baclLogInflowOutflow.Planned_Revenue_Booked__c = ql.Planned_Revenue_Booked__c;
                baclLogInflowOutflow.Planned_Cost__c = totalCostWithOutMarkUp;
                baclLogInflowOutflow.Actual_Cost_c__c = actualCost;   
                baclLogInflowOutflow.Booking_Date_N__c	  = ql.Booking_Date__c;
                baclLogInflowOutflow.Booking_Quarter_N__c  = ql.Booking_Quarter__c;
                baclLogInflowOutflow.MTL_Type__c = ql.MTL_Type__c ; 
                backlogTableauRecsToCreate.add(baclLogInflowOutflow);
            }
        }
        if(!backlogTableauRecsToCreate.isEmpty()){
            insert backlogTableauRecsToCreate;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }

}