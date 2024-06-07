/**
 * @File Name          : DealCalculator_AppConnect.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 8/5/2020, 10:28:47 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    8/5/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class DealCalculator_AppConnect {
/* 
 
*/
    public class DealCalculator_AppConnectException extends Exception {}
    
    global DealCalculator_AppConnect() {
        this.ZCRMFM_MARGIN_OVERCAST = new DealCalculator_AppConnect.ZCRMFM_MARGIN_OVERCAST();
        this.ES_GSA_CALC = new DealCalculator_AppConnect.ES_GSA_CALC();
        this.ES_MARGIN_HDR = new DealCalculator_AppConnect.ES_MARGIN_HDR();
        this.ET_MARGIN_DETAILS = new list<DealCalculator_AppConnect.ET_MARGIN_DETAILS>();
        this.IS_MARGIN_GSA = new list<DealCalculator_AppConnect.IS_MARGIN_GSA>();
        this.ES_MARGIN_HDR1 = new DealCalculator_AppConnect.ES_MARGIN_HDR(); // soumyad sf-bug-1018
    }

    public class ZCRMFM_MARGIN_OVERCAST {
        @AuraEnabled public Decimal DISCOUNTABLE_ONLY { get; set; }
        @AuraEnabled public Decimal DISC_ON_DISC_ONLY { get; set; }
        @AuraEnabled public Decimal DISC_ON_NON_DISC { get; set; }
        @AuraEnabled public Decimal DISC_VAL_TO_CUST { get; set; }
        @AuraEnabled public Decimal NON_DISCOUNTABLE { get; set; }
        @AuraEnabled public Decimal NON_DISC_VAL_TO_CUST { get; set; }
        @AuraEnabled public Decimal REBATE { get; set; }
        @AuraEnabled public Decimal SERV_DISC { get; set; }
        @AuraEnabled public Decimal EV_MONTHLY_CHARGE { get; set; } //soumyad sf-bug-1018

        public ZCRMFM_MARGIN_OVERCAST() {}

        public ZCRMFM_MARGIN_OVERCAST(Decimal pDISCOUNTABLE_ONLY, Decimal pDISC_ON_DISC_ONLY, Decimal pDISC_ON_NON_DISC, Decimal pDISC_VAL_TO_CUST, Decimal pNON_DISCOUNTABLE, Decimal pNON_DISC_VAL_TO_CUST, Decimal pREBATE, Decimal pSERV_DISC, Decimal monthly) { //soumyad sf-bug-1018
            this.DISCOUNTABLE_ONLY = pDISCOUNTABLE_ONLY;
            this.DISC_ON_DISC_ONLY = pDISC_ON_DISC_ONLY;
            this.DISC_ON_NON_DISC = pDISC_ON_NON_DISC;
            this.DISC_VAL_TO_CUST = pDISC_VAL_TO_CUST;
            this.NON_DISCOUNTABLE = pNON_DISCOUNTABLE;
            this.NON_DISC_VAL_TO_CUST = pNON_DISC_VAL_TO_CUST;
            this.REBATE = pREBATE;
            this.SERV_DISC = pSERV_DISC;
            this.EV_MONTHLY_CHARGE = monthly; //soumyad sf-bug-1018
        }
    }

    public class ES_GSA_CALC {
        @AuraEnabled public Decimal ORDER_PRICE { get; set; }
        @AuraEnabled public Decimal GSA_PRICE { get; set; }
        @AuraEnabled public Decimal DIFF_PRICE { get; set; }
        @AuraEnabled public String RESULT { get; set; }

        public ES_GSA_CALC() {}

        public ES_GSA_CALC(Decimal pORDER_PRICE, Decimal pGSA_PRICE, Decimal pDIFF_PRICE, String pRESULT) {
            this.ORDER_PRICE = pORDER_PRICE;
            this.GSA_PRICE = pGSA_PRICE;
            this.DIFF_PRICE = pDIFF_PRICE;
            this.RESULT = pRESULT;
        }
    }

    public class ES_MARGIN_HDR {
        @AuraEnabled public String ORDER_NUM { get; set; }
        @AuraEnabled public String ORDER_TYPE { get; set; }
        @AuraEnabled public String DESCRIPTION { get; set; }
        @AuraEnabled public String SOLD_TO_PARTY { get; set; }
        @AuraEnabled public String EMP_RESP { get; set; }
        @AuraEnabled public String LEASE_TERM { get; set; }
        @AuraEnabled public String FREE_LEASE { get; set; }
        @AuraEnabled public String SERVICE_TERM { get; set; }
        @AuraEnabled public String FREE_SERVICE { get; set; }
        @AuraEnabled public String STATUS { get; set; }
        @AuraEnabled public Date BOOKING_DATE { get; set; }
        @AuraEnabled public Decimal NET_VALUE { get; set; }
        @AuraEnabled public Decimal TAX_AMOUNT { get; set; }
        @AuraEnabled public Decimal GROSS_AMOUNT { get; set; }
        @AuraEnabled public Date PRICING_DATE { get; set; }
        @AuraEnabled public String PRICE_LIST { get; set; }
        @AuraEnabled public String SERVICE_LEVEL { get; set; }
        @AuraEnabled public String CURRENCY_x { get; set; }
        @AuraEnabled public Decimal MARGIN_PRODUCT { get; set; }
        @AuraEnabled public Decimal MARGIN_SERVICE { get; set; }
        @AuraEnabled public Decimal CONT_LPRICE_EXT { get; set; }
        @AuraEnabled public Decimal DISCOUNT_EXT { get; set; }
        @AuraEnabled public Decimal MARGIN_EXT { get; set; }
        @AuraEnabled public Decimal VAL_CUST_EXT { get; set; }
        @AuraEnabled public Decimal COST_EXT { get; set; }
        @AuraEnabled public Decimal USA_LPRICE_EXT { get; set; }
        @AuraEnabled public Decimal LABOR_EXT { get; set; }
        @AuraEnabled public Decimal BILLING_EXT { get; set; }
        @AuraEnabled public Decimal BOOKING_EXT { get; set; }
        @AuraEnabled public Decimal COMMISSION_EXT { get; set; }
        @AuraEnabled public Decimal OVERHEAD_EXT { get; set; }
        @AuraEnabled public Decimal SERVICE_COST { get; set; }
        @AuraEnabled public Decimal SERVICE_BOOKING { get; set; }
        @AuraEnabled public String ORDER_TYPE_DESC { get; set; }
        @AuraEnabled public String IDN_PRICE_DESC { get; set; }
        @AuraEnabled public String GPO_PRICE_DESC { get; set; }
        @AuraEnabled public String IDN_PRICE_LIST { get; set; }
        @AuraEnabled public String SERVICE_PRICE_DESC { get; set; }
        @AuraEnabled public Decimal SERVICE_VAL_CUST { get; set; }
        @AuraEnabled public String SUBSCRIPTION_TERM { get; set; }
        @AuraEnabled public Decimal DISCOUNT_BASE { get; set; }
        

        public ES_MARGIN_HDR() {}

        public ES_MARGIN_HDR(String pORDER_NUM, String pORDER_TYPE, String pDESCRIPTION, String pSOLD_TO_PARTY, String pEMP_RESP, String pLEASE_TERM, String pFREE_LEASE, String pSERVICE_TERM, String pFREE_SERVICE, String pSTATUS, Date pBOOKING_DATE, Decimal pNET_VALUE, Decimal pTAX_AMOUNT, Decimal pGROSS_AMOUNT, Date pPRICING_DATE, String pPRICE_LIST, String pSERVICE_LEVEL, String pCURRENCY_x, Decimal pMARGIN_PRODUCT, Decimal pMARGIN_SERVICE, Decimal pCONT_LPRICE_EXT, Decimal pDISCOUNT_EXT, Decimal pMARGIN_EXT, Decimal pVAL_CUST_EXT, Decimal pCOST_EXT, Decimal pUSA_LPRICE_EXT, Decimal pLABOR_EXT, Decimal pBILLING_EXT, Decimal pBOOKING_EXT, Decimal pCOMMISSION_EXT, Decimal pOVERHEAD_EXT, Decimal pSERVICE_COST) {
            this.ORDER_NUM = pORDER_NUM;
            this.ORDER_TYPE = pORDER_TYPE;
            this.DESCRIPTION = pDESCRIPTION;
            this.SOLD_TO_PARTY = pSOLD_TO_PARTY;
            this.EMP_RESP = pEMP_RESP;
            this.LEASE_TERM = pLEASE_TERM;
            this.FREE_LEASE = pFREE_LEASE;
            this.SERVICE_TERM = pSERVICE_TERM;
            this.FREE_SERVICE = pFREE_SERVICE;
            this.STATUS = pSTATUS;
            this.BOOKING_DATE = pBOOKING_DATE;
            this.NET_VALUE = pNET_VALUE;
            this.TAX_AMOUNT = pTAX_AMOUNT;
            this.GROSS_AMOUNT = pGROSS_AMOUNT;
            this.PRICING_DATE = pPRICING_DATE;
            this.PRICE_LIST = pPRICE_LIST;
            this.SERVICE_LEVEL = pSERVICE_LEVEL;
            this.CURRENCY_x = pCURRENCY_x;
            this.MARGIN_PRODUCT = pMARGIN_PRODUCT;
            this.MARGIN_SERVICE = pMARGIN_SERVICE;
            this.CONT_LPRICE_EXT = pCONT_LPRICE_EXT;
            this.DISCOUNT_EXT = pDISCOUNT_EXT;
            this.MARGIN_EXT = pMARGIN_EXT;
            this.VAL_CUST_EXT = pVAL_CUST_EXT;
            this.COST_EXT = pCOST_EXT;
            this.USA_LPRICE_EXT = pUSA_LPRICE_EXT;
            this.LABOR_EXT = pLABOR_EXT;
            this.BILLING_EXT = pBILLING_EXT;
            this.BOOKING_EXT = pBOOKING_EXT;
            this.COMMISSION_EXT = pCOMMISSION_EXT;
            this.OVERHEAD_EXT = pOVERHEAD_EXT;
            this.SERVICE_COST = pSERVICE_COST;
        }
    }

    public class ET_MARGIN_DETAILS {
        @AuraEnabled public String QUOTE_ID { get; set; }
        @AuraEnabled public String QUOTE_TYPE { get; set; }
        @AuraEnabled public String QUOTE_TYPE_DESC { get; set; }
        @AuraEnabled public String QUOTE_DESC { get; set; }
        @AuraEnabled public String SOLD_TO_ID { get; set; }
        @AuraEnabled public String SOLD_TO_NAME { get; set; }
        @AuraEnabled public String EMP_RESP_NAME { get; set; }
        @AuraEnabled public String QUOTE_STATUS { get; set; }
        @AuraEnabled public String PO_NUMBER { get; set; }
        @AuraEnabled public Date VALID_FROM { get; set; }
        @AuraEnabled public Date VALID_TO { get; set; }
        @AuraEnabled public String CONTACT_NAME { get; set; }
        @AuraEnabled public String PAYER_ID { get; set; }
        @AuraEnabled public String PAYER_NAME { get; set; }
        @AuraEnabled public String CREATED_BY { get; set; }
        @AuraEnabled public String SHIP_TO_ID { get; set; }
        @AuraEnabled public String SHIP_TO_NAME { get; set; }
        @AuraEnabled public String BILL_TO_ID { get; set; }
        @AuraEnabled public String BILL_TO_NAME { get; set; }
        @AuraEnabled public Date REQ_DEL_DATE { get; set; }
        @AuraEnabled public String SALES_OFFICE { get; set; }
        @AuraEnabled public String DIST_CHANNEL { get; set; }
        @AuraEnabled public String TERRITORY_ID { get; set; }
        @AuraEnabled public String ITEM_NO { get; set; }
        @AuraEnabled public String HIGHER_ITEM_NO { get; set; }
        @AuraEnabled public String PRODUCT_CATEGORY { get; set; }
        @AuraEnabled public String PRODUCT_ID { get; set; }
        @AuraEnabled public String PRODUCT_NAME { get; set; }
        @AuraEnabled public String PROD_FAMILY { get; set; }
        @AuraEnabled public String PROD_LINE { get; set; }
        @AuraEnabled public String PROD_CLASS { get; set; }
        @AuraEnabled public String PROD_TYPE { get; set; }
        @AuraEnabled public String PROD_CLASS_DESC { get; set; }
        @AuraEnabled public String PROD_TYPE_DESC { get; set; }
        @AuraEnabled public Decimal QUANTITY { get; set; }
        @AuraEnabled public String ITEM_CATEGORY { get; set; }
        @AuraEnabled public String ITEM_CATEGORY_DESC { get; set; }
        @AuraEnabled public Date BOOKING_DATE { get; set; }
        @AuraEnabled public Decimal VALUE_TO_CUSTOMER { get; set; }
        @AuraEnabled public Decimal VALUE_TO_CUSTOMER_EXT { get; set; }
        @AuraEnabled public String VALUE_CURRENCY { get; set; }
        @AuraEnabled public Decimal REBATE_COMPETITOR_BUYOUT { get; set; }
        @AuraEnabled public Decimal PARTY_INT_RATE_3RD { get; set; }
        @AuraEnabled public Decimal PARTY_DEAL_SPREAD_3RD { get; set; }
        @AuraEnabled public Decimal NETVALUE { get; set; }
        @AuraEnabled public Decimal NETVALUE_EXT { get; set; }
        @AuraEnabled public String NETVALUE_CURRENCY { get; set; }
        @AuraEnabled public Decimal DISCOUNT { get; set; }
        @AuraEnabled public Decimal DISCOUNT_EXT { get; set; }
        @AuraEnabled public Decimal BILL_VAL_CUST { get; set; }
        @AuraEnabled public Decimal BILL_VAL_CUST_EXT { get; set; }
        @AuraEnabled public String BILLING_URRENCY { get; set; }
        @AuraEnabled public Decimal BOOK_VAL_OMNICELL { get; set; }
        @AuraEnabled public Decimal BOOK_VAL_OMNICELL_EXT { get; set; }
        @AuraEnabled public String BOOKING_CURRENCY { get; set; }
        @AuraEnabled public Decimal COMM_VAL_OMNICELL { get; set; }
        @AuraEnabled public Decimal COMM_VAL_OMNICELL_EXT { get; set; }
        @AuraEnabled public String COMM_CURRENCY { get; set; }
        @AuraEnabled public Decimal COST_TO_OMNICELL { get; set; }
        @AuraEnabled public Decimal COST_TO_OMNICELL_EXT { get; set; }
        @AuraEnabled public String COST_CURRENCY { get; set; }
        @AuraEnabled public Decimal LABOR_OMNICELL { get; set; }
        @AuraEnabled public Decimal LABOR_OMNICELL_EXT { get; set; }
        @AuraEnabled public Decimal USA_LIST_PRICE { get; set; }
        @AuraEnabled public String USA_LIST_CURRENCY { get; set; }
        @AuraEnabled public Decimal CONTRACT_LIST_PRICE { get; set; }
        @AuraEnabled public Decimal CONTRACT_LPRICE_EXT { get; set; }
        @AuraEnabled public String CONTRACT_LIST_CURRENCY { get; set; }
        @AuraEnabled public Decimal MARGIN { get; set; }
        @AuraEnabled public String MARGIN_PERC { get; set; }
        @AuraEnabled public Decimal SERVICE_COST { get; set; }
        @AuraEnabled public Decimal KPI_01_AMT { get; set; }
        @AuraEnabled public String KPI_01_CURR { get; set; }
        @AuraEnabled public Decimal KPI_02_AMT { get; set; }
        @AuraEnabled public String KPI_02_CURR { get; set; }
        @AuraEnabled public Decimal KPI_03_AMT { get; set; }
        @AuraEnabled public String KPI_03_CURR { get; set; }
        @AuraEnabled public Decimal KPI_04_AMT { get; set; }
        @AuraEnabled public String KPI_04_CURR { get; set; }
        @AuraEnabled public Decimal KPI_05_AMT { get; set; }
        @AuraEnabled public String KPI_05_CURR { get; set; }
        @AuraEnabled public Decimal KPI_06_AMT { get; set; }
        @AuraEnabled public String KPI_06_CURR { get; set; }
        @AuraEnabled public Decimal KPI_07_AMT { get; set; }
        @AuraEnabled public String KPI_07_CURR { get; set; }
        @AuraEnabled public Decimal KPI_08_AMT { get; set; }
        @AuraEnabled public String KPI_08_CURR { get; set; }
        @AuraEnabled public Decimal KPI_09_AMT { get; set; }
        @AuraEnabled public String KPI_09_CURR { get; set; }
        @AuraEnabled public Decimal KPI_10_AMT { get; set; }
        @AuraEnabled public String KPI_10_CURR { get; set; }
        @AuraEnabled public String LINKED_OPP_ID { get; set; }
        @AuraEnabled public String LINKED_ORDER_ID { get; set; }
        @AuraEnabled public Decimal OVERHEAD { get; set; }
        @AuraEnabled public String PO_NUMBER_SHIP { get; set; }
        @AuraEnabled public String NON_DISCOUNTABLE { get; set; }

        public ET_MARGIN_DETAILS() {}

        public ET_MARGIN_DETAILS(String pQUOTE_ID, String pQUOTE_TYPE, String pQUOTE_TYPE_DESC, String pQUOTE_DESC, String pSOLD_TO_ID, String pSOLD_TO_NAME, String pEMP_RESP_NAME, String pQUOTE_STATUS, String pPO_NUMBER, Date pVALID_FROM, Date pVALID_TO, String pCONTACT_NAME, String pPAYER_ID, String pPAYER_NAME, String pCREATED_BY, String pSHIP_TO_ID, String pSHIP_TO_NAME, String pBILL_TO_ID, String pBILL_TO_NAME, Date pREQ_DEL_DATE, String pSALES_OFFICE, String pDIST_CHANNEL, String pTERRITORY_ID, String pITEM_NO, String pHIGHER_ITEM_NO, String pPRODUCT_CATEGORY, String pPRODUCT_ID, String pPRODUCT_NAME, String pPROD_FAMILY, String pPROD_LINE, String pPROD_CLASS, String pPROD_TYPE) {
            this.QUOTE_ID = pQUOTE_ID;
            this.QUOTE_TYPE = pQUOTE_TYPE;
            this.QUOTE_TYPE_DESC = pQUOTE_TYPE_DESC;
            this.QUOTE_DESC = pQUOTE_DESC;
            this.SOLD_TO_ID = pSOLD_TO_ID;
            this.SOLD_TO_NAME = pSOLD_TO_NAME;
            this.EMP_RESP_NAME = pEMP_RESP_NAME;
            this.QUOTE_STATUS = pQUOTE_STATUS;
            this.PO_NUMBER = pPO_NUMBER;
            this.VALID_FROM = pVALID_FROM;
            this.VALID_TO = pVALID_TO;
            this.CONTACT_NAME = pCONTACT_NAME;
            this.PAYER_ID = pPAYER_ID;
            this.PAYER_NAME = pPAYER_NAME;
            this.CREATED_BY = pCREATED_BY;
            this.SHIP_TO_ID = pSHIP_TO_ID;
            this.SHIP_TO_NAME = pSHIP_TO_NAME;
            this.BILL_TO_ID = pBILL_TO_ID;
            this.BILL_TO_NAME = pBILL_TO_NAME;
            this.REQ_DEL_DATE = pREQ_DEL_DATE;
            this.SALES_OFFICE = pSALES_OFFICE;
            this.DIST_CHANNEL = pDIST_CHANNEL;
            this.TERRITORY_ID = pTERRITORY_ID;
            this.ITEM_NO = pITEM_NO;
            this.HIGHER_ITEM_NO = pHIGHER_ITEM_NO;
            this.PRODUCT_CATEGORY = pPRODUCT_CATEGORY;
            this.PRODUCT_ID = pPRODUCT_ID;
            this.PRODUCT_NAME = pPRODUCT_NAME;
            this.PROD_FAMILY = pPROD_FAMILY;
            this.PROD_LINE = pPROD_LINE;
            this.PROD_CLASS = pPROD_CLASS;
            this.PROD_TYPE = pPROD_TYPE;
        }
    }

    public class IS_MARGIN_GSA {
        @AuraEnabled public String QUOTE_ID { get; set; }
        @AuraEnabled public String PROCESS_TYPE { get; set; }
        @AuraEnabled public String CALC_GSA { get; set; }
        @AuraEnabled public String CALC_MARGIN { get; set; }
        @AuraEnabled public String CALC_DISC { get; set; }

        public IS_MARGIN_GSA() {}

        public IS_MARGIN_GSA(String pQUOTE_ID, String pPROCESS_TYPE, String pCALC_GSA, String pCALC_MARGIN, String pCALC_DISC) {
            this.QUOTE_ID = pQUOTE_ID;
            this.PROCESS_TYPE = pPROCESS_TYPE;
            this.CALC_GSA = pCALC_GSA;
            this.CALC_MARGIN = pCALC_MARGIN;
            this.CALC_DISC = pCALC_DISC;
        }
    }
    // soumyad sf-bug-1018 start
    public class ES_MARGIN_HDR1 {
        
        @AuraEnabled public Decimal DISCOUNT_BASE { get; set; }
        

        public ES_MARGIN_HDR1() {}

        public ES_MARGIN_HDR1(decimal based) {
                        
            this.DISCOUNT_BASE = based;
        }
    }
    // soumyad sf-bug-1018 end

    @AuraEnabled public DealCalculator_AppConnect.ZCRMFM_MARGIN_OVERCAST ZCRMFM_MARGIN_OVERCAST { get; set; }
    @AuraEnabled public DealCalculator_AppConnect.ES_GSA_CALC ES_GSA_CALC { get; set; }
    @AuraEnabled public DealCalculator_AppConnect.ES_MARGIN_HDR ES_MARGIN_HDR { get; set; }
    @AuraEnabled public list<DealCalculator_AppConnect.ET_MARGIN_DETAILS> ET_MARGIN_DETAILS { get; set; }
    @AuraEnabled public list<DealCalculator_AppConnect.IS_MARGIN_GSA> IS_MARGIN_GSA { get; set; }
    @AuraEnabled public DealCalculator_AppConnect.ES_MARGIN_HDR ES_MARGIN_HDR1 { get; set; } // soumyad sf-bug-1018

    public string inputSetName { get; set; }

    

    public string getBackendMessage() {
        return this.backendMessage;
    }

    global string serialize() {
        if (dynamicBody != null) {
            return JSON.serialize(dynamicBody, true);
        }
        return JSON.serialize(this, true);
    }
    
    public static DealCalculator_AppConnect deserialize(string responsedata) {
        /*if (overcast.Globals.IsOCF) {
            DealCalculator_AppConnect obj = new DealCalculator_AppConnect();
            obj.loadAsyncResponse(responsedata);
            return obj;
        }*/
        map<string, string> m = getOutputData(responsedata);
        string outputData = m.get('output');
        string backendMessage = m.get('backendMessage');
        if (outputData == null) {
            return new DealCalculator_AppConnect();
        }
        if(outputData.contains('0000-00-00')){
            outputData = outputData.replace('0000-00-00','2020-03-03');
        }
        DealCalculator_AppConnect obj = (DealCalculator_AppConnect)JSON.deserialize(outputData, DealCalculator_AppConnect.class);
        obj.outputData = outputData;
        obj.backendMessage = backendMessage;

        return obj;
    }

    private static map<string, string> getOutputData(string responseData) {
        if (string.isblank(responsedata)) {
            throw new DealCalculator_AppConnectException('Response null for DealCalculator_AppConnect request.');
        }

        map<string, string> m = new map<string, string>();

        JSONParser jresponse = JSON.createParser(responsedata);
        jresponse.nextValue();

        boolean hasOutput = false;
        while (jresponse.nextValue() != JSONToken.END_OBJECT && jresponse.getCurrentToken() != null) {
            if (jresponse.getCurrentName() == 'output') {
                jresponse.skipChildren();
                hasOutput = true;
                continue;
            }
            if (jresponse.getCurrentName() == 'backendMessage') {
                m.put('backendMessage', (string)jresponse.readValueAs(string.class));
                continue;
            }
            if (jresponse.getCurrentName() == 'error') {
                string[] errors = (string[])jresponse.readValueAs(list<string>.class);
                throw new DealCalculator_AppConnectException(string.join(errors, ';'));
            }
        }
        if (!hasOutput) {
            throw new DealCalculator_AppConnectException('Malformed response for DealCalculator_AppConnect request.');
        }
        integer start = responsedata.indexOf(':') + 1;
        integer lastIndex = m.get('backendMessage') == null
            ? responsedata.length() - 2
            : responsedata.lastIndexOf('backendMessage');
        integer finish = responsedata.lastIndexOf('}', lastIndex) + 1;
        m.put('output', responseData.substring(start, finish));
        return m;
    }


    public transient string testResponse;
    private transient string outputData;
    private transient string backendMessage;

    //private transient map<string, overcast.TypeInfo> metadata;//Commented by Sourav for Overcast uninstall
    private transient map<string, object> dynamicBody;

    global string getTopTypeName() {
        return 'ZCRMFM_MARGIN_OVERCAST';
    }

    global void set(string typeName, object records) {
        if (typeName == '@testResponse') {
            dynamicBody = (map<string, object>)records;
            return;
        }
        if (dynamicBody == null) {
            dynamicBody = new map<string, object>();
        }
        
        dynamicBody.put(typeName, records);
    }
    
    global object get(string typeName) {
        if (dynamicBody == null && outputData != null) {
            dynamicBody = (map<string, object>)JSON.deserializeUntyped(outputData);
        }
        if (dynamicBody == null) { 
            return null;
        }
        return dynamicBody.get(typeName);
    }

}