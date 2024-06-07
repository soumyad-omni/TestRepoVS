/***********************************************************************************************************
Name:  SCP_OrderSimulate_Parser
Copyright © 2019
============================================================================================================
============================================================================================================
Purpose: 
This class can be called to parse response body recieved from mulesoft order simulate web service

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION       AUTHOR                      DATE                   Description
1.0        Karthik Raj Golakaram        01/27/2021             INITIAL DEVELOPMENT
*************************************************************************************************************/
public class SCP_OrderSimulate_Res_Parser {

    public class ET_ITEMLIST {
        public String ITM_NUMBER;
        public String MATERIAL;
        public String CAS_NOT_SETUP; // Added for Canister and Cassette project
        public String REQ_QTY;
        public String AVL_QTY;
        public String AVL_DATE;
        public String ABS_DISCOUNT;
        public String PERC_DISCOUNT;
    }

    public Row row;

    public class Row {
        public String TAX_AMOUNT_HD;
        public String STATUS_CODE;
        public String EX_EXCEPTION;
        public String EV_SALES_ORDER;
        public String ET_MESSAGES;
        public String EX_CR_BLOCK;
        public String IV_ORDER_DISCOUNT;
        public List<ET_FREIGHT_OPTIONLIST> ET_FREIGHT_OPTIONLIST;
        public List<ET_ITEMLIST> ET_ITEMLIST;
        public List<ET_ITEM_DELIVERY_DATES> ET_ITEM_DELIVERY_DATES;//IBA-3736
        public string EV_PAYER;//IBA-4378
    }

    public class ET_FREIGHT_OPTIONLIST {
        public String SHIP_DESC;
        public String FREIGHT_VAL;
        public String REQ_DATE;
        public String SHIP_COND;
        public string TOTAL_TAX;
    }
    
    public class ET_ITEM_DELIVERY_DATES {//IBA-3736
        public String ITM_NUMBER;
        public String MATERIAL;
        public String DELIVERY_DATE;
        public String VSBED;
    }
    
    public class ET_DelMap{//IBA-3736
        public String keyId;
        public String deldate;
        public String item_sku;
    }
    public class ShipMethodMap{//IBA-3736
        public String ship_desc;
        public String ship_code;
    }

    
    public static SCP_OrderSimulate_Res_Parser parse(String json) {
        return (SCP_OrderSimulate_Res_Parser) System.JSON.deserialize(json, SCP_OrderSimulate_Res_Parser.class);
    }
}