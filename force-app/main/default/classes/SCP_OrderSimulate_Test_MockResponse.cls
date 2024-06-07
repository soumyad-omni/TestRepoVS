@isTest
global class SCP_OrderSimulate_Test_MockResponse implements HttpCalloutMock {
    global Integer responseNumber = 0;
    
    global SCP_OrderSimulate_Test_MockResponse(Integer resNumber){
        responseNumber = resNumber;
    }
   
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"example":"test"}');
        if(responseNumber==1){
            res.setBody('{"row": {"TAX_AMOUNT_HD": "","EX_EXCEPTION": "X","ET_MESSAGES": "","EX_CR_BLOCK":"","ET_FREIGHT_OPTIONLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}} ');
        }
        else if(responseNumber==2){
            res.setBody('{"row": {"Status_Code":"404","TAX_AMOUNT_HD": "","EX_EXCEPTION": "X","ET_MESSAGES": "","EX_CR_BLOCK":"","ET_FREIGHT_OPTIONLIST": [],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}} ');
        }
        else if(responseNumber==3){
            res.setBody('{"row": {"TAX_AMOUNT_HD": "","EX_EXCEPTION": "","ET_MESSAGES": "","EX_CR_BLOCK":"","ET_FREIGHT_OPTIONLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","TOTAL_TAX":"10"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}} ');
        }
        else if(responseNumber==5){
            res.setBody('{"row": {"TAX_AMOUNT_HD": "","EX_EXCEPTION": "D","ET_MESSAGES": "","EX_CR_BLOCK":"","ET_FREIGHT_OPTIONLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","TOTAL_TAX":"10"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}} ');
        }
        else if(responseNumber==6){
            res.setBody('{"row": {"TAX_AMOUNT_HD": "","EX_EXCEPTION": "X","ET_MESSAGES": "","EX_CR_BLOCK":"","ET_FREIGHT_OPTIONLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","TOTAL_TAX":"10"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}} ');
        }
        else if(responseNumber==7){
            res.setBody('{"row":{"EV_PAYER":"500300"}}');
        }
        else if(responseNumber==8){
            res.setBody('{"row":{"EV_PAYER":" "}}');
        }
        else{
            res.setBody('{"row": {"TAX_AMOUNT_HD": "","EX_EXCEPTION": "X","ET_MESSAGES": "","EX_CR_BLOCK":"","ET_FREIGHT_OPTIONLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","TOTAL_TAX":"10"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}} ');
        }
        res.setStatusCode(200);
        return res;
    }
        

}