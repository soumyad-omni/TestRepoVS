trigger QuoteLineAverageTrigger on Quote_Line_Average__c (before insert)
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            for(Quote_Line_Average__c qla : trigger.new)
            {
                qla.Average_Cost_custom__c = qla.Average_Cost__c;
                qla.Average_Selling_Price_custom__c = qla.Average_Selling_Price__c;
                qla.Power_of_One_custom__c = 1;
                qla.RLD_Quarter_custom__c = qla.RLD_Quarter__c;
                qla.Order_Type_custom__c = qla.Order_Type__c;
                qla.SAP_Order_Number_custom__c = qla.SAP_Order_Number__c;
                qla.Portfolio_Segment_custom__c = qla.Portfolio_Segment__c;
                qla.Product_Description_custom__c = qla.Product_Description__c;
            }
        }
    }
}