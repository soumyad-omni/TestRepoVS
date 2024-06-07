@isTest
global class SCP_OrderSubmitAPIMock_Test implements HttpCalloutMock {
    
    global Integer responseNumber;
    global String ET_Item_number;
    global SCP_OrderSubmitAPIMock_Test(Integer resNumber){
        this.responseNumber = resNumber;
    }
    global SCP_OrderSubmitAPIMock_Test(Integer resNumber,String et_itm_number){
        this.responseNumber = resNumber;
        this.ET_Item_number = et_itm_number;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"example":"test"}');
        //res.setBody('{"row": {"TAX_AMOUNT_HD": "","EX_EXCEPTION": "","ET_MESSAGES": "","EX_CR_BLOCK":"","ET_FREIGHT_OPTIONLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}} ');
        if(responseNumber == 1){
            system.debug('**************1');
        	res.setBody('{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "X","EX_CR_BLOCK":"test","ET_MESSAGES": "test","X": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09" ,"AVL_DATE": "2099-01-01"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","AVL_DATE": "2099-01-01"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07","AVL_DATE": "2099-01-01"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22","AVL_DATE": "2099-01-01"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88","AVL_DATE": "2099-01-01"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2","AVL_DATE": "2099-01-01"}]}}');    
        }
        else if(responseNumber == 2){
            system.debug('**************2');
            res.setBody('{"reply":{"ccCaptureReply.reconciliationID": "1234"}}');    
        }
        else if(responseNumber == 3){
            system.debug('**************3');
        	res.setBody('{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "","ET_MESSAGES": "test","EX_CR_BLOCK": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09","AVL_DATE": "2099-01-01"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","AVL_DATE": "2099-01-01"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07","AVL_DATE": "2099-01-01"}],"ET_ITEMLIST": [{"ITM_NUMBER": "'+ET_Item_number+'","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22","ABS_DISCOUNT":"50","PERC_DISCOUNT":"0.5","AVL_DATE": "2099-01-01"}]}}'); 
        }
        else if(responseNumber == 4){
            system.debug('**************4');
        	res.setBody('{"row": {"EV_SALES_ORDER": "","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "X","ET_MESSAGES": "test","EX_CR_BLOCK": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09","AVL_DATE": "2099-01-01"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","AVL_DATE": "2099-01-01"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07","AVL_DATE": "2099-01-01"}],"ET_ITEMLIST": []}}'); 
        }
        else if(responseNumber == 5){
            system.debug('**************5');
        	res.setBody('{"row": {"EV_SALES_ORDER": "","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "XD","ET_MESSAGES": "test","EX_CR_BLOCK": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09","AVL_DATE": "2099-01-01"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","AVL_DATE": "2099-01-01"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07","AVL_DATE": "2099-01-01"}],"ET_ITEMLIST": []}}'); 
        }
        else if(responseNumber == 6){
            system.debug('**************5');
        	res.setBody('{"row": {null}}'); 
        }
        else{
            system.debug('**************0');
        	res.setBody('{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "","ET_MESSAGES": "test","EX_CR_BLOCK": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09","AVL_DATE": "2099-01-01"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07" ,"AVL_DATE": "2099-01-01"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07" ,"AVL_DATE": "2099-01-01"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22","AVL_DATE": "2099-01-01"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88" ,"AVL_DATE": "2099-01-01"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2" ,"AVL_DATE": "2099-01-01"}]}}'); 
        }
             
        res.setStatusCode(200);
        return res;
    }

}