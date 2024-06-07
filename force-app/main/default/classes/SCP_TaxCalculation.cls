global with sharing class SCP_TaxCalculation extends ccrz.cc_hk_TaxCalculation {
 
    
    global override Decimal getTaxAmount(Map<String, Object> inputData) {
        String ccCartId ='';
        Decimal taxAmount = 0;
        try{
            ccCartId = (String) inputData.get(ccrz.cc_hk_TaxCalculation.PARAM_CARTID);
            
            //Added changes for Story :SCP-521 -Karthik
            List<ccrz__E_Cart__c> cartInProcessList=[SELECT id,ccrz__ShipMethod__c FROM ccrz__E_Cart__c WHERE id=:ccCartId ];
            System.debug('Printing the cart Shipping details'+cartInProcessList[0].ccrz__ShipMethod__c);
            //End changes for Story :SCP-521 -Karthik
            
            SCP_OrderSimulate_Res_Parser  responseParserObj = new SCP_OrderSimulate().SendOrderInfoToSAP(ccCartId,false); //iba-4378
            
            system.debug('###c-- '+responseParserObj);
            
            SCP_OrderSimulate_Res_Parser.Row rowObj = responseParserObj.row;
            
            system.debug('### rowObj-- '+rowObj);
             system.debug('### rowObjrowObj.TAX_AMOUNT_HD-- '+rowObj.TAX_AMOUNT_HD);
            
            ccrz.ccLog.log(System.LoggingLevel.DEBUG,'rowObj',rowObj);
             ccrz.ccLog.log(System.LoggingLevel.DEBUG,'taxAmount',rowObj.TAX_AMOUNT_HD);
            
           /* if(String.isBlank(rowObj.TAX_AMOUNT_HD ) || rowObj.TAX_AMOUNT_HD == NULL)
                taxAmount = null;
            else
               taxAmount = Decimal.valueOf(rowObj.TAX_AMOUNT_HD);
           system.debug('## tax smt--'+ taxAmount);*/
           
           //Added changes for Story :SCP-521 -Karthik
           Map<String,String> shippingMethodToTaxMap = new Map<String,String>();
           if(!responseParserObj.row.ET_FREIGHT_OPTIONLIST.isEmpty()){
               for(Integer i=0;i<responseParserObj.row.ET_FREIGHT_OPTIONLIST.size();i++){
                  if(String.isNotEmpty(responseParserObj.row.ET_FREIGHT_OPTIONLIST.get(i).SHIP_DESC)&&!shippingMethodToTaxMap.containsKey(responseParserObj.row.ET_FREIGHT_OPTIONLIST.get(i).SHIP_DESC)){
                      shippingMethodToTaxMap.put('SHIP - '+responseParserObj.row.ET_FREIGHT_OPTIONLIST.get(i).SHIP_DESC,responseParserObj.row.ET_FREIGHT_OPTIONLIST.get(i).TOTAL_TAX);
                  } 
               }
           }
           
           System.debug('Printing different Tax options from Order Simulate'+shippingMethodToTaxMap);
           ccrz.ccLog.log(System.LoggingLevel.DEBUG,'Printing different Tax options from Order Simulate',shippingMethodToTaxMap);
           if(!shippingMethodToTaxMap.isEmpty()){
               ccrz.ccLog.log(System.LoggingLevel.DEBUG,'Printing Tax amount to Set'+Decimal.valueOf(shippingMethodToTaxMap.get(cartInProcessList[0].ccrz__ShipMethod__c)));
               taxAmount=Decimal.valueOf(shippingMethodToTaxMap.get(cartInProcessList[0].ccrz__ShipMethod__c));
           }
           
           //End changes for Story :SCP-521 -Karthik
        }
        catch(Exception e){
           
        }
        return taxAmount;
    
    }
    
}