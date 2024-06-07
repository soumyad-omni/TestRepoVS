/*** 
Modification Logs:

DeveloperName     UserStory#    Date(MM/DD/YYYY)
    
Sanjana K.R       SCP-92        03/09/2021

***/

global class SCP_OrderConfirmationController{

    @RemoteAction
    global static Map<String,String> getSapInformation(String orderId){
          Map<String,String> outputMap = new Map<String,String>();
          List<ccrz__E_Order__c> ordertoWrapList=[SELECT id,Name,SAP_Order_Number__c,Integration_Status__c ,PO_Number__c  FROM ccrz__E_Order__c WHERE id=:orderId ];
          if(String.isNotBlank(ordertoWrapList[0].SAP_Order_Number__c) || String.isNotBlank(ordertoWrapList[0].Integration_Status__c )){
               if(String.isNotBlank(ordertoWrapList[0].SAP_Order_Number__c)){
                   outputMap.put('evSalesOrder',ordertoWrapList[0].SAP_Order_Number__c );  
               }else{
                  outputMap.put('evSalesOrder',ordertoWrapList[0].Name);  
               }
               return outputMap;      
          }
          SCP_OrderSimulate_Res_Parser.Row rowObj,rowObjTest;
        SCP_OrderSimulate_Res_Parser.Row rowObjtemp;  
            SCP_OrderSimulate_Res_Parser.Row rowObjstr; 
          SCP_OrderSimulate_Res_Parser responseParserObj = new SCP_OrderSimulate_Res_Parser();
          SCP_OrderSubmitAPI ordSub = new SCP_OrderSubmitAPI();
        
                  String evSalesOrderOrigSAP = NULL ;
        
          if(!test.isRunningTest()){
               responseParserObj =  ordSub.sendOrderInformationToSAP(orderId);

               system.debug('## shiping responseParserObj --'+ responseParserObj ); 
              
              rowObj = responseParserObj.row;
              
               if(rowObj != null)
              evSalesOrderOrigSAP = rowObj.EV_SALES_ORDER ; 
             
              system.debug('## evSalesOrderOrigSAP   --'+ evSalesOrderOrigSAP );   
                 // rowobj = null; 
                  
                  if(rowObj == null)   {
                      
                       rowObjTest = new SCP_OrderSimulate_Res_Parser.Row();
               // rowObjTest.EV_SALES_ORDER = 'sales';
               //rowObjTest.EX_CR_BLOCK = 'block'; 
              // rowObjTest.EX_EXCEPTION = 'exception';
              // rowObjTest.EV_SALES_ORDER =  rowObj.EV_SALES_ORDER!=null ? rowObj.EV_SALES_ORDER : ; 
                  rowObjTest.EV_SALES_ORDER =  ordertoWrapList[0].Name ; 
               rowObj = rowObjTest;    
                      
                  }
                   
                  system.debug('## shiping responseParserObj row --'+ rowObj );  
              
           }else{
                String varExpBlock;
        String varExpBlockSalesOrder;
        String varExcept;
        String varExceptOrd;
                String varExpBlo;
        String varExpBlockSalesOrd;
        String varExce;
        String varExceptOr; 
          
        
               rowObjTest = new SCP_OrderSimulate_Res_Parser.Row();
               rowObjTest.EV_SALES_ORDER = 'sales';
               rowObjTest.EX_CR_BLOCK = 'block';
               rowObjTest.EX_EXCEPTION = 'exception';
               rowObj = rowObjTest;               
           }
           String evSalesOrder = rowObj.EV_SALES_ORDER!=null ? rowObj.EV_SALES_ORDER : ordertoWrapList[0].Name;
           String exCRBlock = rowObj.EX_CR_BLOCK;
           String exException = rowObj.EX_EXCEPTION;
          
           outputMap.put('evSalesOrder',evSalesOrder);           
           outputMap.put('exCRBlock',exCRBlock);
           outputMap.put('exException',exException);
           
           List<ccrz__E_TransactionPayment__c> transPay = [select id,ccrz__AccountType__c,ccrz__AccountNumber__c from ccrz__E_TransactionPayment__c where ccrz__CCOrder__c =: ordertoWrapList LIMIT 1];
           if(!ordertoWrapList.isEmpty()){ 
               ccrz__E_Order__c orderObj = ordertoWrapList[0];
               
                orderObj.SAP_Order_Number__c  = rowObj.EV_SALES_ORDER ;
               
              if(evSalesOrderOrigSAP!=null )  
                   orderObj.Integration_Status__c = 'Submitted'; 
               else
                   orderObj.Integration_Status__c = 'Error'; 
               
               //SCP-92 Start
               if(!transPay.isEmpty() && transPay[0].ccrz__AccountType__c == 'po'){
                   orderObj.PO_Number__c = transPay[0].ccrz__AccountNumber__c ;
               }//SCP-92 End
               
              //  orderObj.SAP_Order_Number__c  = '8888' ;
                system.debug('## orderObj--'+orderObj); 
               update orderObj;
           }


system.debug('## outputMap--'+outputMap); 
        return outputMap;
   }
   @RemoteAction
    global static Map<String,String> getOrderItemsInformation(String orderId){
          Map<String,String> outputMap = new Map<String,String>();
        Map<String,String> outputMapTemp = new Map<String,String>();
        Map<String,String> outputMapStr = new Map<String,String>();
          for(ccrz__E_OrderItem__c orderItemObj : [SELECT id,ccrz__AvailabilityMessage__c FROM ccrz__E_OrderItem__c where ccrz__Order__c=:orderId]){
              outputMap.put(orderItemObj.id,orderItemObj.ccrz__AvailabilityMessage__c );
          }
        return outputMap;
   }


}