public class DealCalculator_FieldPopulation {
    
    public static String populateFieldValue(Quote qt){
        string fieldValues = '{"output":{"ZCRMFM_MARGIN_OVERCAST":{"DISCOUNTABLE_ONLY":86040.00,"DISC_ON_DISC_ONLY":57360.00,"DISC_ON_NON_DISC":0.00,"DISC_VAL_TO_CUST":86040.00,"EV_MONTHLY_CHARGE":0.00,"NON_DISCOUNTABLE":4800.00,"NON_DISC_VAL_TO_CUST":4800.00,"REBATE":0.00,"SERV_DISC":0.00},"ES_GSA_CALC":{"ORDER_PRICE":90840.00,"GSA_PRICE":91272.42,"DIFF_PRICE":-432.42,"RESULT":"GSA Test Failed"},"ES_MARGIN_HDR":{"ORDER_NUM":"'+ qt.Quote_Number__c +'","ORDER_TYPE":"ZQR","DESCRIPTION":"' + qt.Name + '","SOLD_TO_PARTY":"' + qt.Account_CSN__c + '","EMP_RESP":"Marcus Dolman","LEASE_TERM":"000","FREE_LEASE":"000","SERVICE_TERM":"012","FREE_SERVICE":"000","STATUS":"Booked","BOOKING_DATE":"0000-00-00","NET_VALUE":95918.96,"TAX_AMOUNT":0.00,"GROSS_AMOUNT":95918.96,"PRICING_DATE":"2017-02-28","SERVICE_LEVEL":"PP","CURRENCY_x":"USD","MARGIN_PRODUCT":74.15,"MARGIN_SERVICE":100.00,"CONT_LPRICE_EXT":148200.00,"DISCOUNT_EXT":57360.00,"MARGIN_EXT":65676.20,"VAL_CUST_EXT":90840.00,"COST_EXT":18022.63,"USA_LPRICE_EXT":148200.00,"LABOR_EXT":1231.78,"BILLING_EXT":22892.80,"BOOKING_EXT":88569.00,"COMMISSION_EXT":88569.00,"OVERHEAD_EXT":3638.39,"SERVICE_COST":0.00,"SERVICE_BOOKING":1728.00,"ORDER_TYPE_DESC":"Quote-Purchase","SERVICE_PRICE_DESC":"Advantage Plan","SERVICE_VAL_CUST":1728.00,"SUBSCRIPTION_TERM":"000","DISCOUNT_BASE":0.00},"ET_MARGIN_DETAILS":[{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000200","PRODUCT_CATEGORY":"MAT_FERT","PRODUCT_ID":"MED-FRM-102","PRODUCT_NAME":"XT MED 2-CELL CABINET","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZHW","PROD_TYPE":"ZFR","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Frame","QUANTITY":1.000,"ITEM_CATEGORY":"ZAGC","ITEM_CATEGORY_DESC":"Quote - Config","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":16542.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":11028.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":16542.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":16542.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":16542.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":5307.98,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":1231.78,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":27570.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":27570.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":16542.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000201","HIGHER_ITEM_NO":"200","PRODUCT_CATEGORY":"MAT_HALB","PRODUCT_ID":"MED-PCB-001","PRODUCT_NAME":"XT CONSOLE- BIOID, MED LBL a. RCPT PRNTR","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZHW","PROD_TYPE":"ZOT","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Other","QUANTITY":1.000,"ITEM_CATEGORY":"ZQHE","ITEM_CATEGORY_DESC":"Quote BOM Expl(Stat)","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":3165.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":2110.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":3165.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":3165.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":3165.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":2246.22,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":5275.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":5275.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":3165.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000202","HIGHER_ITEM_NO":"200","PRODUCT_CATEGORY":"MAT_HALB","PRODUCT_ID":"MED-DRW-006","PRODUCT_NAME":"XT MED 27-BIN METAL LOCKING LID DRW","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZHW","PROD_TYPE":"ZOT","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Other","QUANTITY":8.000,"ITEM_CATEGORY":"ZQHE","ITEM_CATEGORY_DESC":"Quote BOM Expl(Stat)","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":24480.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":16320.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":24480.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":24480.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":24480.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":3661.22,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":40800.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":40800.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":24480.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000203","HIGHER_ITEM_NO":"200","PRODUCT_CATEGORY":"MAT_HALB","PRODUCT_ID":"MED-DRW-005","PRODUCT_NAME":"XT MED 18-BIN METAL LOCKING LID DRW","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZHW","PROD_TYPE":"ZOT","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Other","QUANTITY":4.000,"ITEM_CATEGORY":"ZQHE","ITEM_CATEGORY_DESC":"Quote BOM Expl(Stat)","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":12240.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":8160.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":12240.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":12240.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":12240.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":1531.70,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":20400.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":20400.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":12240.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000204","HIGHER_ITEM_NO":"200","PRODUCT_CATEGORY":"MAT_HALB","PRODUCT_ID":"MED-DRW-004","PRODUCT_NAME":"XT MED 10-BIN METAL LOCKING LID DRW","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZHW","PROD_TYPE":"ZOT","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Other","QUANTITY":4.000,"ITEM_CATEGORY":"ZQHE","ITEM_CATEGORY_DESC":"Quote BOM Expl(Stat)","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":12240.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":8160.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":12240.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":12240.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":12240.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":1365.67,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":20400.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":20400.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":12240.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000205","HIGHER_ITEM_NO":"200","PRODUCT_CATEGORY":"MAT_NLAG","PRODUCT_ID":"MED-LIC-004","PRODUCT_NAME":"SW LICENSE- PROFILE OPTION","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZSW","PROD_TYPE":"ZLK","PROD_CLASS_DESC":"Software","PROD_TYPE_DESC":"License Key","QUANTITY":1.000,"ITEM_CATEGORY":"ZQHE","ITEM_CATEGORY_DESC":"Quote BOM Expl(Stat)","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":3300.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":2200.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":3300.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":3300.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":3300.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":0.00,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":5500.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":5500.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":3300.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000206","HIGHER_ITEM_NO":"200","PRODUCT_CATEGORY":"MAT_NLAG","PRODUCT_ID":"MED-LIC-005","PRODUCT_NAME":"SW LICENSE- SCHEDULED MEDS","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZSW","PROD_TYPE":"ZLK","PROD_CLASS_DESC":"Software","PROD_TYPE_DESC":"License Key","QUANTITY":1.000,"ITEM_CATEGORY":"ZQHE","ITEM_CATEGORY_DESC":"Quote BOM Expl(Stat)","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":1320.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":880.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":1320.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":1320.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":1320.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":0.00,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":2200.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":2200.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":1320.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000209","HIGHER_ITEM_NO":"200","PRODUCT_CATEGORY":"MAT_HALB","PRODUCT_ID":"MED-SCN-001","PRODUCT_NAME":"XT SCANNER, WIRED 1,2,3 CELL","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZHW","PROD_TYPE":"ZSC","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Scanner","QUANTITY":1.000,"ITEM_CATEGORY":"ZQHE","ITEM_CATEGORY_DESC":"Quote BOM Expl(Stat)","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":1383.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":922.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":1383.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":1383.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":1383.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":264.85,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":2305.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":2305.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":1383.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000210","HIGHER_ITEM_NO":"200","PRODUCT_CATEGORY":"MAT_HALB","PRODUCT_ID":"MED-DRW-011","PRODUCT_NAME":"15-BIN DBL DEEP METAL LOCKING DRW","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZHW","PROD_TYPE":"ZOT","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Other","QUANTITY":2.000,"ITEM_CATEGORY":"ZQHE","ITEM_CATEGORY_DESC":"Quote BOM Expl(Stat)","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":6120.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":4080.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":6120.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":6120.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":6120.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":856.49,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":10200.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":10200.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":6120.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000400","PRODUCT_CATEGORY":"MAT_ZLAG","PRODUCT_ID":"MSA-SUB-006","PRODUCT_NAME":"PREMIUM WIN10 PACKAGE","PROD_FAMILY":"SRD","PROD_LINE":" MSA","PROD_CLASS":"ZSW","PROD_TYPE":"SUB","PROD_CLASS_DESC":"Software","PROD_TYPE_DESC":"Subscription","QUANTITY":1.000,"ITEM_CATEGORY":"ZQB2","ITEM_CATEGORY_DESC":"Subscription Others","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":4800.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":0.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":4800.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":4800.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":4800.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":1155.00,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":4800.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":4800.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":3388.59,"MARGIN_PERC":"    70.60","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response","NON_DISCOUNTABLE":"X"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000000800","PRODUCT_CATEGORY":"MAT_ZMKT","PRODUCT_ID":"SRD-OPT-012","PRODUCT_NAME":"XT FLEXLOCK WITH 50 FT CABLE,INSTALLED","PROD_FAMILY":"SRD","PROD_LINE":" MSA","PROD_CLASS":"ZHW","PROD_TYPE":"ZOP","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Option","QUANTITY":1.000,"ITEM_CATEGORY":"ZQHP","ITEM_CATEGORY_DESC":"Q Standalo Item-MKT","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":2370.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":1580.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":2370.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":2370.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":2370.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":358.97,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":3950.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":3950.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":2370.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000001000","PRODUCT_CATEGORY":"MAT_ZMKT","PRODUCT_ID":"SUP-OTH-002","PRODUCT_NAME":"XT PULLOUT SHELF","PROD_FAMILY":"SRD","PROD_LINE":" MSA","PROD_CLASS":"ZHW","PROD_TYPE":"ZOP","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Option","QUANTITY":2.000,"ITEM_CATEGORY":"ZQHP","ITEM_CATEGORY_DESC":"Q Standalo Item-MKT","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":900.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":600.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":900.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":900.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":900.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":574.06,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":1500.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":1500.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":900.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"},{"QUOTE_ID":"0005552617","QUOTE_TYPE":"ZQR","QUOTE_TYPE_DESC":"Quote - Purchase","QUOTE_DESC":"Rapid Response Cabinet","SOLD_TO_ID":"478807","SOLD_TO_NAME":"St Josephs Healthcare Hamilton","EMP_RESP_NAME":"Marcus Dolman","QUOTE_STATUS":"Booked","PO_NUMBER":"468826","VALID_FROM":"2022-02-07","VALID_TO":"2022-05-08","PAYER_ID":"80110472","PAYER_NAME":"St. Josephs Healthcare Hamilt","CREATED_BY":"CASTIRON","SHIP_TO_ID":"478807","SHIP_TO_NAME":"St Josephs Healthcare Hamilton","BILL_TO_ID":"80110472","BILL_TO_NAME":"St. Josephs Healthcare Hamilt","REQ_DEL_DATE":"2027-12-31","SALES_OFFICE":"Sales - Int","DIST_CHANNEL":"01","ITEM_NO":"0000001200","PRODUCT_CATEGORY":"MAT_ZMKT","PRODUCT_ID":"MED-OPT-017","PRODUCT_NAME":"XT EXTERNAL RETURN BIN,WIRELESS,ALACARTE","PROD_FAMILY":"MED","PROD_LINE":" MDA","PROD_CLASS":"ZHW","PROD_TYPE":"ZOP","PROD_CLASS_DESC":"Hardware","PROD_TYPE_DESC":"Option","QUANTITY":1.000,"ITEM_CATEGORY":"ZQHP","ITEM_CATEGORY_DESC":"Q Standalo Item-MKT","BOOKING_DATE":"2022-02-28","VALUE_TO_CUSTOMER":1980.00,"VALUE_TO_CUSTOMER_EXT":0.00,"VALUE_CURRENCY":"USD","REBATE_COMPETITOR_BUYOUT":0.00,"PARTY_INT_RATE_3RD":0.00,"PARTY_DEAL_SPREAD_3RD":0.00,"NETVALUE":0.00,"NETVALUE_EXT":0.00,"DISCOUNT":1320.00,"DISCOUNT_EXT":0.00,"BILL_VAL_CUST":1980.00,"BILL_VAL_CUST_EXT":0.00,"BILLING_URRENCY":"USD","BOOK_VAL_OMNICELL":1980.00,"BOOK_VAL_OMNICELL_EXT":0.00,"BOOKING_CURRENCY":"USD","COMM_VAL_OMNICELL":1980.00,"COMM_VAL_OMNICELL_EXT":0.00,"COMM_CURRENCY":"USD","COST_TO_OMNICELL":700.47,"COST_TO_OMNICELL_EXT":0.00,"LABOR_OMNICELL":0.00,"LABOR_OMNICELL_EXT":0.00,"USA_LIST_PRICE":3300.00,"USA_LIST_CURRENCY":"USD","CONTRACT_LIST_PRICE":3300.00,"CONTRACT_LPRICE_EXT":0.00,"CONTRACT_LIST_CURRENCY":"USD","MARGIN":1980.00,"MARGIN_PERC":"   100.00","SERVICE_COST":0.00,"KPI_01_AMT":0.00,"KPI_02_AMT":0.00,"KPI_03_AMT":0.00,"KPI_04_AMT":0.00,"KPI_05_AMT":0.00,"KPI_06_AMT":0.00,"KPI_07_AMT":0.00,"KPI_08_AMT":0.00,"KPI_09_AMT":0.00,"KPI_10_AMT":0.00,"LINKED_ORDER_ID":"10434731","OVERHEAD":0.00,"PO_NUMBER_SHIP":"Rapid Response"}],"IS_MARGIN_GSA":[{"QUOTE_ID":"5552617","CALC_GSA":"X","CALC_MARGIN":"X"}]}}';
            return fieldValues;
    } 
    
    public static DealCalculator_AppConnect prepareFieldValue(Quote qt){
        
        List<Quote_Line__c> qtLineList = [Select Id, Name,SAP_NPV__c,Total_Cost2__c, List_Price__c, USA_List_Price__c, Contract_List_Price__c, 
                                          Customer_Price__c, Quantity__c,Product_Code__c, Material_Type__c, Total_Customer_Price__c,  Product__c, 
                                          Product__r.SAP_Product_Type__c,SAP_Line_Number__c,SAP_Expected_Bookings__c, Total_Cost__c, 
                                          Discount_Percent__c, Margin_Percentage__c, Product__r.External_ID__c, Conga_Product_Description__c, 
                                          Conga_Discount_Price__c, Portfolio_Segment__c, Higher_Level_Item__c, Discount_Percent_Amount__c, 
                                          Discount_Amount__c, Pricing_Reference_Model__c, Pricing_Reference_Model__r.Name, Product_Cost__c, 
                                          Pricing_Reference_Model__r.External_ID__c,Product__r.DW_Product_Line__c,
                                          USA_List_Price_Recalculate__c,Product__r.DW_Product_Type__c, Contract_List_Price_Recalculate__c,SAP_Line_Expected_Booking__c,
                                          Product__r.name from Quote_Line__c  where  Quote__c =: qt.Id and Line_Status__c != 'E0006' 
                                          and (NOT Product__r.name like '%LEASE BUYOUT%') ]; //IBA-4873
        
        DealCalculator_AppConnect response = new DealCalculator_AppConnect();
        DealCalculator_AppConnect.ES_MARGIN_HDR esMargin = prepareES_MARGIN_HDR(qt,qtLineList);
        response.ES_MARGIN_HDR = esMargin;
        DealCalculator_AppConnect.ZCRMFM_MARGIN_OVERCAST zcrmfmMarginOvercast = prepareZCRMFM_MARGIN_OVERCAST(qt,qtLineList);
        response.ZCRMFM_MARGIN_OVERCAST = zcrmfmMarginOvercast;
        DealCalculator_AppConnect.ES_GSA_CALC esGsaCalc = prepareES_GSA_CALC(qt,qtLineList);
        response.ES_GSA_CALC = esGsaCalc;
        
        response.ET_MARGIN_DETAILS = prepareET_MARGIN_DETAILS(qt,qtLineList);
        return response;
    }
    
    public static DealCalculator_AppConnect.ES_MARGIN_HDR prepareES_MARGIN_HDR(Quote qt, List<Quote_Line__c> qtLineList){
        
        /* DealCalculator_AppConnect.ES_MARGIN_HDR esMarginHDR = new DealCalculator_AppConnect.ES_MARGIN_HDR(qt.Quote_Number__c,  'pORDER_TYPE', qt.Name, qt.Account_CSN__c, 'pEMP_RESP',  'pLEASE_TERM', 'pFREE_LEASE', 'pSERVICE_TERM', 'pFREE_SERVICE', 'pSTATUS', Date.valueOf('2022-02-28'),  15,  14, 13, Date.valueOf('2022-02-28'),  'pPRICE_LIST',  'pSERVICE_LEVEL',  qt.Currency__c,  12,  11, 10 ,  9,  8, 7 ,  6, 5 ,  4,  3, 2, 0, 1, 20); */
        DealCalculator_AppConnect.ES_MARGIN_HDR esMarginHDR = new DealCalculator_AppConnect.ES_MARGIN_HDR();
        esMarginHDR.ORDER_NUM = qt.Quote_Number__c; /*Transaction No - getting value from SAP Quote Number */
        esMarginHDR.ORDER_TYPE = getPicklistVal('Quote','Order_Type__c',qt.Order_Type__c);
        esMarginHDR.DESCRIPTION = qt.Name;
        esMarginHDR.SOLD_TO_PARTY = qt.Account_CSN__c;/*Business Partner - Account CSN under Quote information section Of Quote header*/
        esMarginHDR.EMP_RESP = qt.Opportunity.Owner.Name;
        esMarginHDR.LEASE_TERM = constructTermValue(qt.Lease_Duration__c);
        esMarginHDR.FREE_LEASE = constructTermValue(qt.Free_Month_for_Lease__c);
        esMarginHDR.SERVICE_TERM = constructTermValue(qt.Service_Duration__c);
        esMarginHDR.FREE_SERVICE = constructTermValue(qt.Free_Month_Service__c);
        esMarginHDR.STATUS = getPicklistVal('Quote','Status',qt.Status);
        esMarginHDR.BOOKING_DATE = Date.valueOf('2022-02-18');
        esMarginHDR.NET_VALUE = 10;
        esMarginHDR.TAX_AMOUNT = 20;
        esMarginHDR.GROSS_AMOUNT = 30;
        esMarginHDR.PRICING_DATE = qt.Pricing_Reference_Date__c;/*Pricing Date - Pricing ref date from Quote header*/
        esMarginHDR.PRICE_LIST = 'pPRICE_LIST';
        esMarginHDR.SERVICE_LEVEL = 'pSERVICE_LEVEL';
        esMarginHDR.CURRENCY_x = qt.Currency__c;
        esMarginHDR.MARGIN_SERVICE = 50;
        esMarginHDR.CONT_LPRICE_EXT = getListPrice(qt, qtLineList,'Contract_List_Price__c');
        if(qt.Conga_Quote_Line_Discount__c != null) {
            esMarginHDR.DISCOUNT_EXT = qt.Conga_Quote_Line_Discount__c;
        } else {
            esMarginHDR.DISCOUNT_EXT = 0;
        }         
        esMarginHDR.VAL_CUST_EXT = getListPrice(qt, qtLineList,'Customer_Price__c');
        if(qt.Material_Cost__c != null) {
            esMarginHDR.COST_EXT = qt.Material_Cost__c;
        } else {
            esMarginHDR.COST_EXT = 0;
        }        
        esMarginHDR.USA_LPRICE_EXT = getListPrice(qt, qtLineList,'List_Price__c');
        if(qt.Labor_Cost__c != null) {
            esMarginHDR.LABOR_EXT = qt.Labor_Cost__c;    
        } else {
            esMarginHDR.LABOR_EXT = 0;
        }        
        esMarginHDR.BILLING_EXT = 130;
        if(qt.SAP_NPV__c != null){
            esMarginHDR.BOOKING_EXT = qt.SAP_NPV__c;
        } else {
            esMarginHDR.BOOKING_EXT = 0;
        }        
        esMarginHDR.COMMISSION_EXT = getCommissionVal(qt,qtLineList);
        if(qt.Overhead_Cost__c != null) {
            esMarginHDR.OVERHEAD_EXT = qt.Overhead_Cost__c;
        } else {
            esMarginHDR.OVERHEAD_EXT = 0;
        }        
        esMarginHDR.SERVICE_COST = getServiceCost(qtLineList);
        esMarginHDR.MARGIN_EXT = esMarginHDR.BOOKING_EXT - (esMarginHDR.COST_EXT + esMarginHDR.LABOR_EXT + esMarginHDR.OVERHEAD_EXT);
        esMarginHDR.ORDER_TYPE_DESC = getPicklistVal('Quote','Order_Type__c',qt.Order_Type__c);
        esMarginHDR.GPO_PRICE_DESC = getPicklistVal('Quote','GPO_Price_Lists__c',qt.GPO_Price_Lists__c);
        esMarginHDR.IDN_PRICE_DESC = getPicklistVal('Quote','IDN_Price_List__c',qt.IDN_Price_List__c);
        esMarginHDR.SERVICE_PRICE_DESC = getPicklistVal('Quote','Service_Level__c',qt.Service_Level__c);
        esMarginHDR.DISCOUNT_BASE = getDiscountVal(qt,qtLineList,true);
        esMarginHDR.SERVICE_BOOKING = getServiceBooking(qt,qtLineList);
        esMarginHDR.MARGIN_SERVICE = getMarginService(esMarginHDR.SERVICE_BOOKING,esMarginHDR.SERVICE_COST);
        return esMarginHDR;
    }
    
    public static DealCalculator_AppConnect.ZCRMFM_MARGIN_OVERCAST prepareZCRMFM_MARGIN_OVERCAST(Quote qt, List<Quote_Line__c> qtLineList){
        DealCalculator_AppConnect.ZCRMFM_MARGIN_OVERCAST marginOvercast = new DealCalculator_AppConnect.ZCRMFM_MARGIN_OVERCAST();
        marginOvercast.NON_DISCOUNTABLE = getDiscountVal(qt,qtLineList,false);
        marginOvercast.DISCOUNTABLE_ONLY = getDiscountVal(qt,qtLineList,true);
        marginOvercast.EV_MONTHLY_CHARGE = getMonthlyVal(qt,qtLineList);
        marginOvercast.SERV_DISC = getServiceDiscount(qtLineList);
        marginOvercast.DISC_ON_DISC_ONLY = 0;
        return marginOvercast;
    }
    
    public static DealCalculator_AppConnect.ES_GSA_CALC prepareES_GSA_CALC(Quote qt, List<Quote_Line__c> qtLineList){
        
        DealCalculator_AppConnect.ES_GSA_CALC gsaCalc = new DealCalculator_AppConnect.ES_GSA_CALC();
        if(qt.Order_Net_Price__c != null){
            gsaCalc.ORDER_PRICE = qt.Order_Net_Price__c;
        } 
        if(qt.GSA_Net_Price__c != null){
            gsaCalc.GSA_PRICE = qt.GSA_Net_Price__c;
        }
        if(qt.GSA_Price_Difference__c != null){
            gsaCalc.DIFF_PRICE = qt.GSA_Price_Difference__c;
        }
        if(qt.GSA_Result1__c != null){
            gsaCalc.RESULT = qt.GSA_Result1__c;
        }
        return gsaCalc;
    }
    
    public static List<DealCalculator_AppConnect.ET_MARGIN_DETAILS> prepareET_MARGIN_DETAILS(Quote qt, List<Quote_Line__c> qtLineList) {
        
        //IBA-4873 Sourav Start
        Map<String,Decimal> productTotalCostMap = new Map<String,Decimal>();
        Map<String,Decimal> productTotalQtyMap = new Map<String,Decimal>();
        Map<String,Decimal> productTotalDiscMap = new Map<String,Decimal>();
        Map<String,Decimal> productUSAListPriceMap = new Map<String,Decimal>();
        Map<String,Decimal> productContractListPriceMap = new Map<String,Decimal>();
        Map<String,Decimal> productBookingValueMap = new Map<String,Decimal>();
        for(Quote_Line__c qtLine:qtLineList){
            if(qtLine.Pricing_Reference_Model__c != null){                
                if(qtLine.Total_Cost2__c != null){
                    if(productTotalCostMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c) != null){
                        Decimal totalCost = productTotalCostMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c);
                        totalCost += qtLine.Total_Cost2__c;
                        productTotalCostMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,totalCost);
                    }
                    else{
                        productTotalCostMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,qtLine.Total_Cost2__c);
                    }
                }
                if(productTotalQtyMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c) != null){
                    Decimal totalQty = productTotalQtyMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c);
                    totalQty += qtLine.Quantity__c;
                    productTotalQtyMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,totalQty);
                }
                else{
                    productTotalQtyMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,qtLine.Quantity__c);
                }
                if(qtLine.Conga_Discount_Price__c != null){
                    if(productTotalDiscMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c) != null){
                        Decimal discount = productTotalDiscMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c);
                        discount += qtLine.Conga_Discount_Price__c;
                        productTotalDiscMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,discount);
                    }
                    else{
                        productTotalDiscMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,qtLine.Conga_Discount_Price__c);
                    }
                }
                if(qtLine.USA_List_Price__c != null){
                    if(productUSAListPriceMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c) != null){
                        Decimal usaListPrice = productUSAListPriceMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c);
                        usaListPrice += (qtLine.USA_List_Price__c * qtLine.Quantity__c);
                        productUSAListPriceMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,usaListPrice);
                    }
                    else {
                        productUSAListPriceMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,(qtLine.USA_List_Price__c * qtLine.Quantity__c));
                    }
                }
                if(qtLine.Contract_List_Price__c != null){
                    if(productContractListPriceMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c) != null){
                        Decimal contractListPrice = productContractListPriceMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c);
                        contractListPrice += (qtLine.Contract_List_Price__c * qtLine.Quantity__c);
                        productContractListPriceMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,contractListPrice);
                    }
                    else {
                        productContractListPriceMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,qtLine.Contract_List_Price__c * qtLine.Quantity__c);
                    }
                }
                if(productBookingValueMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c) != null){
                    Decimal totalOmnicellBookValue = getOmnicellBookingAmount(qt,qtLine) + productBookingValueMap.get(qtLine.Pricing_Reference_Model__r.External_ID__c);
                    productBookingValueMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,totalOmnicellBookValue);
                }
                else {
                    productBookingValueMap.put(qtLine.Pricing_Reference_Model__r.External_ID__c,getOmnicellBookingAmount(qt,qtLine));
                }
            }
            else{
                
                if(qtLine.Total_Cost2__c != null){
                    if(productTotalCostMap.get(qtLine.Product__r.External_ID__c) != null){
                        Decimal totalCost = productTotalCostMap.get(qtLine.Product__r.External_ID__c);
                        totalCost += qtLine.Total_Cost2__c;
                        productTotalCostMap.put(qtLine.Product__r.External_ID__c,totalCost);
                    }
                    else {
                        productTotalCostMap.put(qtLine.Product__r.External_ID__c,qtLine.Total_Cost2__c);
                    }
                }
                if(productTotalQtyMap.get(qtLine.Product__r.External_ID__c) != null){
                    Decimal totalQty = productTotalQtyMap.get(qtLine.Product__r.External_ID__c);
                    totalQty += qtLine.Quantity__c;
                    productTotalQtyMap.put(qtLine.Product__r.External_ID__c,totalQty);
                }
                else {
                    productTotalQtyMap.put(qtLine.Product__r.External_ID__c,qtLine.Quantity__c);
                }
                if(qtLine.Conga_Discount_Price__c != null){
                    if(productTotalDiscMap.get(qtLine.Product__r.External_ID__c) != null){
                        Decimal discount = productTotalDiscMap.get(qtLine.Product__r.External_ID__c);
                        discount += qtLine.Conga_Discount_Price__c;
                        productTotalDiscMap.put(qtLine.Product__r.External_ID__c,discount);
                    }
                    else {
                        productTotalDiscMap.put(qtLine.Product__r.External_ID__c,qtLine.Conga_Discount_Price__c);
                    }
                }
                if(qtLine.USA_List_Price__c != null){
                    if(productUSAListPriceMap.get(qtLine.Product__r.External_ID__c) != null){
                        Decimal usaListPrice = productUSAListPriceMap.get(qtLine.Product__r.External_ID__c);
                        usaListPrice += (qtLine.USA_List_Price__c * qtLine.Quantity__c);
                        productUSAListPriceMap.put(qtLine.Product__r.External_ID__c,usaListPrice);
                    }
                    else {
                        productUSAListPriceMap.put(qtLine.Product__r.External_ID__c,(qtLine.USA_List_Price__c * qtLine.Quantity__c));
                    }
                }  
                if(qtLine.Contract_List_Price__c != null){
                    if(productContractListPriceMap.get(qtLine.Product__r.External_ID__c) != null){
                        Decimal contractListPrice = productContractListPriceMap.get(qtLine.Product__r.External_ID__c);
                        contractListPrice += (qtLine.Contract_List_Price__c * qtLine.Quantity__c);
                        productContractListPriceMap.put(qtLine.Product__r.External_ID__c,contractListPrice);
                    }
                    else {
                        productContractListPriceMap.put(qtLine.Product__r.External_ID__c,qtLine.Contract_List_Price__c * qtLine.Quantity__c);
                    }
                }
                if(productBookingValueMap.get(qtLine.Product__r.External_ID__c) != null){
                    Decimal totalOmnicellBookValue = getOmnicellBookingAmount(qt,qtLine) + productBookingValueMap.get(qtLine.Product__r.External_ID__c);
                    productBookingValueMap.put(qtLine.Product__r.External_ID__c,totalOmnicellBookValue);   
                }
                else {                        
                    productBookingValueMap.put(qtLine.Product__r.External_ID__c,getOmnicellBookingAmount(qt,qtLine));
                }               
            }                
        }
        //IBA-4873 Sourav End
        //getting product cat info to include child items in the list
        Set<Id> prodIds = new Set<Id>();
        Map<decimal,string> ProdMap = new Map<decimal,string>();
        Map<String,list<decimal>> itemMap = new Map<String,list<decimal>>();
        String salesOrg;        
        for(Quote_Line__c qtln : qtLineList){
            string pr = '';
            if(qtLn.Higher_Level_Item__c == 0){
                if(qtln.Pricing_Reference_Model__c != null){
                    pr = qtln.Pricing_Reference_Model__c;
                }else{
                    pr = qtln.Product__c;
                }
                prodIds.add(pr);
            }
            if(!itemMap.containskey(pr)){
                list<decimal> item = new list<decimal>();
                item.add(qtln.SAP_Line_Number__c);
                itemMap.put(pr,item);
            }else{
                list<decimal> item = itemMap.get(pr);
                item.add(qtln.SAP_Line_Number__c);
                itemMap.put(pr,item);
            }
        }
        
        if(qt.Sales_Org__c != null){
            salesOrg = qt.Sales_Org__c;
        } else {
            salesOrg = 'OM01';
        }
        
        for(Product_Sales_Org__c org : [Select Id,Item_Category_Group__c,Product__c from Product_Sales_Org__c where Product__c in : prodIds and Sales_Org__c =: salesOrg]){
            if(org.Item_Category_Group__c != 'ZMKT'){
                
                list<decimal> item = itemMap.get(org.Product__c);
                for(decimal i:item){
                    ProdMap.put(i,org.Item_Category_Group__c);
                }
            }
        }
        
        List<DealCalculator_AppConnect.ET_MARGIN_DETAILS> etMarginList = new List<DealCalculator_AppConnect.ET_MARGIN_DETAILS>();
        for(Quote_Line__c qtLn: qtLineList){
            Boolean sapExpBookFlag = false;//IBA-4873 Sourav
            DealCalculator_AppConnect.ET_MARGIN_DETAILS marginDetails = new DealCalculator_AppConnect.ET_MARGIN_DETAILS();
            
            if(qtLn.Product__r.External_ID__c != null && qtLn.Product__r.External_ID__c != 'FREIGHT' && qtLn.Material_Type__c != 'SERVICE' && qtLn.Higher_Level_Item__c != null && (qtLn.Higher_Level_Item__c == 0 || (qtLn.Higher_Level_Item__c != 0 && qtLn.Pricing_Reference_Model__c != null) || ProdMap.containskey(qtLn.Higher_Level_Item__c))){ 
                marginDetails.QUOTE_ID = qt.Quote_Number__c;
                marginDetails.QUOTE_TYPE = qt.Order_Type__c;
                marginDetails.QUOTE_TYPE_DESC = getPicklistVal('Quote','Order_Type__c',qt.Order_Type__c);
                marginDetails.QUOTE_DESC =  qt.Name;
                marginDetails.SOLD_TO_ID = '478807';
                marginDetails.SOLD_TO_NAME = 'St Josephs Healthcare Hamilton';
                marginDetails.EMP_RESP_NAME = 'Marcus Dolman';
                marginDetails.QUOTE_STATUS = 'Booked';
                marginDetails.PO_NUMBER = '468826';
                marginDetails.VALID_FROM = Date.valueOf('2022-02-07');
                marginDetails.VALID_TO = Date.valueOf('2022-05-08');
                marginDetails.CONTACT_NAME = 'pCONTACT_NAME';
                marginDetails.PAYER_ID = '80110472';
                marginDetails.PAYER_NAME = 'St. Josephs Healthcare Hamilt';
                marginDetails.CREATED_BY = 'CASTIRON';
                marginDetails.SHIP_TO_ID = '478807';
                marginDetails.SHIP_TO_NAME = 'St Josephs Healthcare Hamilton';
                marginDetails.BILL_TO_ID = '80110472';
                marginDetails.BILL_TO_NAME = 'St. Josephs Healthcare Hamilt';
                marginDetails.REQ_DEL_DATE = Date.valueOf('2027-12-31');
                marginDetails.SALES_OFFICE = 'Sales - Int';
                marginDetails.DIST_CHANNEL = '01';
                marginDetails.TERRITORY_ID = 'pTERRITORY_ID';
                marginDetails.ITEM_NO = '0000000200';
                marginDetails.HIGHER_ITEM_NO = 'pHIGHER_ITEM_NO';
                marginDetails.PRODUCT_CATEGORY = 'MAT_FERT';
                if((qtLn.Higher_Level_Item__c != null && qtLn.Higher_Level_Item__c == 0) || ProdMap.containskey(qtLn.Higher_Level_Item__c)) {
                    if(qtLn.Pricing_Reference_Model__c != null){
                        marginDetails.PRODUCT_ID = qtLn.Pricing_Reference_Model__r.Name;
                    }else{
                        marginDetails.PRODUCT_ID = qtLn.Product__r.External_ID__c;
                    }
                    
                } else if (qtLn.Higher_Level_Item__c != null && qtLn.Higher_Level_Item__c != 0 && qtLn.Pricing_Reference_Model__c != null) {
                    marginDetails.PRODUCT_ID = qtLn.Pricing_Reference_Model__r.Name;    
                }
                
                if(qtLn.Conga_Product_Description__c != null){
                    marginDetails.PRODUCT_NAME = qtLn.Conga_Product_Description__c;
                }
                marginDetails.PROD_FAMILY = 'MED';
                marginDetails.PROD_LINE = 'MDA';
                marginDetails.PROD_CLASS = 'ZHW';
                marginDetails.PROD_TYPE = 'ZFR';
                marginDetails.PROD_CLASS_DESC = 'Hardware';
                marginDetails.PROD_TYPE_DESC = 'Frame';
                if(qtLn.Quantity__c != null){
                    marginDetails.QUANTITY = qtLn.Quantity__c;
                } else {
                    marginDetails.QUANTITY = 0;
                }
                marginDetails.ITEM_CATEGORY = 'ZAGC';
                marginDetails.ITEM_CATEGORY_DESC = 'Quote - Config';
                marginDetails.BOOKING_DATE = Date.valueOf('2022-02-28'); 
                
                if(productTotalCostMap.get(marginDetails.PRODUCT_ID) != null){// IBA-4873  Sourav
                    marginDetails.COST_TO_OMNICELL = productTotalCostMap.get(marginDetails.PRODUCT_ID);
                } else {
                    marginDetails.COST_TO_OMNICELL = 0;    
                }
                marginDetails.VALUE_TO_CUSTOMER=16542.00;
                marginDetails.VALUE_TO_CUSTOMER_EXT=0.00;
                marginDetails.VALUE_CURRENCY='USD';
                marginDetails.REBATE_COMPETITOR_BUYOUT=0.00;
                marginDetails.PARTY_INT_RATE_3RD=0.00;
                marginDetails.PARTY_DEAL_SPREAD_3RD=0.00;
                marginDetails.NETVALUE=0.00;
                marginDetails.NETVALUE_EXT=0.00;
                if(productTotalDiscMap.get(marginDetails.PRODUCT_ID) != null){// IBA-4873  Sourav
                    marginDetails.DISCOUNT = productTotalDiscMap.get(marginDetails.PRODUCT_ID);
                } else {
                    marginDetails.DISCOUNT = 0;    
                }
                marginDetails.DISCOUNT_EXT=0.00;
                marginDetails.BILL_VAL_CUST=16542.00;
                marginDetails.BILL_VAL_CUST_EXT=0.00;
                marginDetails.BILLING_URRENCY='USD';                
                
                marginDetails.BOOK_VAL_OMNICELL_EXT=0.00;
                marginDetails.BOOKING_CURRENCY='USD';
                marginDetails.COMM_VAL_OMNICELL=16542.00;
                marginDetails.COMM_VAL_OMNICELL_EXT=0.00;
                marginDetails.COMM_CURRENCY='USD';
                
                marginDetails.COST_TO_OMNICELL_EXT=0.00;
                marginDetails.LABOR_OMNICELL=1231.78;
                marginDetails.LABOR_OMNICELL_EXT=0.00;
                if(productUSAListPriceMap.get(marginDetails.PRODUCT_ID) != null){ // IBA-4873  Sourav
                    marginDetails.USA_LIST_PRICE = productUSAListPriceMap.get(marginDetails.PRODUCT_ID);
                } else {
                    marginDetails.USA_LIST_PRICE = 0;    
                }
                marginDetails.USA_LIST_CURRENCY='USD';
                if(productContractListPriceMap.get(marginDetails.PRODUCT_ID) != null){
                    marginDetails.CONTRACT_LIST_PRICE = productContractListPriceMap.get(marginDetails.PRODUCT_ID);
                } else {
                    marginDetails.CONTRACT_LIST_PRICE = 0;
                }
                
                marginDetails.CONTRACT_LPRICE_EXT=0.00;
                marginDetails.CONTRACT_LIST_CURRENCY='USD';
                marginDetails.MARGIN=16542.00;
                
                system.debug(qtln.SAP_Line_Number__c+' test'+marginDetails.BOOK_VAL_OMNICELL+' '+marginDetails.COST_TO_OMNICELL);
                if(productBookingValueMap.get(marginDetails.PRODUCT_ID) != null && productBookingValueMap.get(marginDetails.PRODUCT_ID) != 0){//IBA-4873 Sourav start
                    Decimal bookingValue = productBookingValueMap.get(marginDetails.PRODUCT_ID);
                    marginDetails.BOOK_VAL_OMNICELL = bookingValue;
                    system.debug(qtln.SAP_Line_Number__c+' '+(((bookingValue -marginDetails.COST_TO_OMNICELL)/bookingValue)*100));
                    marginDetails.MARGIN_PERC = String.valueOf(((bookingValue -marginDetails.COST_TO_OMNICELL)/bookingValue)*100);
                }else{
                    marginDetails.MARGIN_PERC = '0';
                    marginDetails.BOOK_VAL_OMNICELL = 0;
                }                                                           //IBA-4873 Sourav End
                
                
                marginDetails.SERVICE_COST=0.00;
                marginDetails.KPI_01_AMT=0.00;
                marginDetails.KPI_02_AMT=0.00;
                marginDetails.KPI_03_AMT=0.00;
                marginDetails.KPI_04_AMT=0.00;
                marginDetails.KPI_05_AMT=0.00;
                marginDetails.KPI_06_AMT=0.00;
                marginDetails.KPI_07_AMT=0.00;
                marginDetails.KPI_08_AMT=0.00;
                marginDetails.KPI_09_AMT=0.00;
                marginDetails.KPI_10_AMT=0.00;
                marginDetails.LINKED_ORDER_ID='10434731';
                marginDetails.OVERHEAD=0.00;
                marginDetails.PO_NUMBER_SHIP='Rapid Response';
                marginDetails.NON_DISCOUNTABLE = getNonDiscountable(qt,qtLn);
                
                etMarginList.add(marginDetails);
                system.debug(qtLn);
            }
            
        }
        return etMarginList;
    }
    
    public static String getPicklistVal(String objectName, String fieldName, String pickListAPI){
        String pickListVal = '';
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickVal : ple){
            if(pickListAPI != null && pickVal.getValue().equals(pickListAPI)){
                pickListVal = pickVal.getLabel();    
            }
        }  
        return pickListVal;
    }
    
    public static Decimal getListPrice(Quote qt, List<Quote_Line__c> qtLineList, String priceType){
        Set<Id> prodIds = new Set<Id>();
        Map<String,String> ProdMap = new Map<String,String>();
        String salesOrg;
        //IBA-4873 Sourav Start
        List<Quote_Line__c> leaseBuyoutLine = [Select Quantity__c,Contract_List_Price__c,Customer_Price__c,USA_List_Price__c,List_Price__c,Product_Code__c From Quote_Line__c WHERE
                                               Quote__c =:qt.Id AND Product__r.name like '%LEASE BUYOUT%'];
        Map<String,Decimal> customerValLeaseMap = new Map<String,Decimal>();
        for(Quote_Line__c qtLine:leaseBuyoutLine){
            if(qtLine.Customer_Price__c != null){
                if(customerValLeaseMap.get(qtLine.Product_Code__c) != null){
                    customerValLeaseMap.put(qtLine.Product_Code__c, customerValLeaseMap.get(qtLine.Product_Code__c)+(qtLine.Customer_Price__c * qtLine.Quantity__c));
                }
                else{
                    customerValLeaseMap.put(qtLine.Product_Code__c, qtLine.Customer_Price__c * qtLine.Quantity__c);
                }
            }
        }
        //IBA-4873 Sourav End
        for(Quote_Line__c qtln : qtLineList){
            if(qtln.Pricing_Reference_Model__c != null){
                prodIds.add(qtln.Pricing_Reference_Model__c);
            }else{
                prodIds.add(qtln.Product__c);
            }
            
        }
        if(qt.Sales_Org__c != null){
            salesOrg = qt.Sales_Org__c;
        } else {
            salesOrg = 'OM01';
        }
        for(Product_Sales_Org__c org : [Select Id,Material_Group_2__c,Product__c from Product_Sales_Org__c where Product__c in : prodIds and Sales_Org__c =: salesOrg]){
            if(org.Material_Group_2__c == 'SUB'){
                ProdMap.put(org.Product__c,org.Material_Group_2__c);	    
            }
        } 
        
        Decimal listPrice = 0;
        //IBA-4873 Sourav Start
        for(String prdCode: customerValLeaseMap.keySet()){
            if(priceType == 'Customer_Price__c' && (qt.Order_Type__c == 'ZQLI' || qt.Order_Type__c == 'ZQL3')){
                if(qt.Lease_Duration__c != null && qt.Lease_Duration__c != 0){
                    listPrice += customerValLeaseMap.get(prdCode) * qt.Lease_Duration__c;
                }
                else{
                    listPrice += customerValLeaseMap.get(prdCode);
                }
            }
        }
        //IBA-4873 Sourav End
        for(Quote_Line__c qtLn: qtLineList){
            if(qtLn.Product__r.name != 'FREIGHT'){
                if (qt.Order_Type__c != null && qt.Order_Type__c != 'ZQRS' && qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'PRODUCT'  && !ProdMap.containskey(qtLn.Product__c) && qtLn.List_Price__c!= null && qtLn.Quantity__c != null && priceType == 'List_Price__c') {
                    if((qt.Order_Type__c == 'ZQLI')){ //IBA-4873 Sourav start
                        if(qtLn.USA_List_Price__c != null){
                            listPrice +=  (qtLn.USA_List_Price__c * qtLn.Quantity__c);
                        }
                    }
                    else{
                        listPrice +=  (qtLn.List_Price__c * qtLn.Quantity__c);
                    }				      //IBA-4873 Sourav End
                } else if (qt.Order_Type__c != null && qt.Order_Type__c != 'ZQRS' && qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'PRODUCT' && ProdMap.containskey(qtLn.Product__c) && qtLn.List_Price__c!= null && qtLn.Quantity__c != null && priceType == 'List_Price__c') {
                    if((qt.Order_Type__c == 'ZQRL' || qt.Order_Type__c == 'ZQLI' || qt.Order_Type__c == 'ZQR3' || qt.Order_Type__c == 'ZQL3') && qtLn.List_Price__c > 0){
                        listPrice +=  (math.abs(qtLn.Discount_Percent_Amount__c) + math.abs(qtLn.Discount_Amount__c) + qtLn.Total_Customer_Price__c);
                    }else{
                        listPrice +=  qtLn.Total_Customer_Price__c;
                    }
                } else if (qt.Order_Type__c != null && qt.Order_Type__c == 'ZQRS' &&  qt.subscription_Months__c != null && qt.subscription_Months__c != 0 && !ProdMap.containskey(qtLn.Product__c) && qtLn.USA_List_Price__c!= null && qtLn.Quantity__c != null && priceType == 'List_Price__c') {
                    if(qtLn.Product__r.DW_Product_Line__c != 'Professional Services'){ //IBA-4873 Sourav Start
                        listPrice +=  (qtLn.USA_List_Price__c * qtLn.Quantity__c * qt.subscription_Months__c);
                    }
                    else{
                        listPrice +=  (qtLn.USA_List_Price__c * qtLn.Quantity__c);
                    }                                                                //IBA-4873 Sourav End
                } else if (qt.Order_Type__c != null && qt.Order_Type__c == 'ZQRS' &&  qt.subscription_Months__c != null && qt.subscription_Months__c != 0 &&  ProdMap.containskey(qtLn.Product__c) && qtLn.USA_List_Price__c!= null && qtLn.Quantity__c != null && priceType == 'List_Price__c') {
                    listPrice +=  (math.abs(qtLn.Discount_Percent_Amount__c) + math.abs(qtLn.Discount_Amount__c) + qtLn.Total_Customer_Price__c);
                } else if (qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'PRODUCT' && !ProdMap.containskey(qtLn.Product__c) && qtLn.Contract_List_Price__c!= null && qtLn.Quantity__c != null && priceType == 'Contract_List_Price__c' && qt.Order_Type__c != null && qt.Order_Type__c != 'ZQRS') {
                    if((qt.Order_Type__c == 'ZQRL' || qt.Order_Type__c == 'ZQLI' || qt.Order_Type__c == 'ZQR3' || qt.Order_Type__c == 'ZQL3') && qt.Lease_Duration__c != null && qt.Lease_Duration__c != 0){
                        listPrice +=  (qtLn.Contract_List_Price__c * qtLn.Quantity__c * qt.Lease_Duration__c);
                    } else {
                        listPrice +=  (qtLn.Contract_List_Price__c * qtLn.Quantity__c);
                    }     
                } else if (qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'PRODUCT'  && ProdMap.containskey(qtLn.Product__c) && qtLn.Contract_List_Price__c!= null && qtLn.Quantity__c != null && priceType == 'Contract_List_Price__c' && qt.Order_Type__c != null && qt.Order_Type__c != 'ZQRS') {
                    listPrice +=  (math.abs(qtLn.Discount_Percent_Amount__c) + math.abs(qtLn.Discount_Amount__c) + qtLn.Total_Customer_Price__c);
                } else if (qt.Order_Type__c != null && qt.Order_Type__c == 'ZQRS' &&  qt.subscription_Months__c != null && qt.subscription_Months__c != 0  && !ProdMap.containskey(qtLn.Product__c) && qtLn.Contract_List_Price__c!= null && qtLn.Quantity__c != null && priceType == 'Contract_List_Price__c') {
                    if(qtLn.Product__r.DW_Product_Line__c != 'Professional Services'){ //IBA-4873 Sourav Start
                        listPrice +=  (qtLn.Contract_List_Price__c * qtLn.Quantity__c * qt.subscription_Months__c);
                    }
                    else{
                        listPrice +=  (qtLn.Contract_List_Price__c * qtLn.Quantity__c);
                    }                                                               //IBA-4873 Sourav End
                } else if (qt.Order_Type__c != null && qt.Order_Type__c == 'ZQRS' &&  qt.subscription_Months__c != null && qt.subscription_Months__c != 0  && !ProdMap.containskey(qtLn.Product__c) && qtLn.Contract_List_Price__c!= null && qtLn.Quantity__c != null && priceType == 'Contract_List_Price__c') {
                    listPrice +=  (math.abs(qtLn.Discount_Percent_Amount__c) + math.abs(qtLn.Discount_Amount__c) + qtLn.Total_Customer_Price__c);
                } else if (qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'PRODUCT'  && !ProdMap.containskey(qtLn.Product__c) && qtLn.Customer_Price__c!= null && qtLn.Quantity__c != null && priceType == 'Customer_Price__c'  && qt.Order_Type__c != 'ZQRS') {
                    if((qt.Order_Type__c == 'ZQRL' || qt.Order_Type__c == 'ZQLI' || qt.Order_Type__c == 'ZQR3' || qt.Order_Type__c == 'ZQL3') && qt.Lease_Duration__c != null && qt.Lease_Duration__c != 0){
                        listPrice +=  (qtLn.Customer_Price__c * qtLn.Quantity__c * qt.Lease_Duration__c);
                    } else {
                        listPrice +=  (qtLn.Customer_Price__c * qtLn.Quantity__c);
                    }                    
                } else if (qt.Order_Type__c != null && qt.Order_Type__c == 'ZQRS' &&  qt.subscription_Months__c != null && qt.subscription_Months__c != 0  && !ProdMap.containskey(qtLn.Product__c) && qtLn.Customer_Price__c!= null && qtLn.Quantity__c != null && priceType == 'Customer_Price__c'){
                    if(qtLn.Product__r.DW_Product_Line__c != 'Professional Services'){ //IBA-4873 Sourav Start
                        listPrice +=  (qtLn.Customer_Price__c * qtLn.Quantity__c * qt.subscription_Months__c);
                    }
                    else{
                        listPrice +=  (qtLn.Customer_Price__c * qtLn.Quantity__c);
                    }                                                                 //IBA-4873 Sourav End
                } else if (ProdMap.containskey(qtLn.Product__c) && qtLn.Total_Customer_Price__c != null){
                    listPrice += qtLn.Total_Customer_Price__c;   
                }
            }
        }
        return listPrice;
    }
    
    public static Decimal getCommissionVal(Quote qt, List<Quote_Line__c> qtLineList){
        Decimal commissionVal = 0;
        for(Quote_Line__c qtLn: qtLineList){
            if(qt.Order_Type__c != null && qt.Order_Type__c == 'ZQRS' && qtLn.SAP_Expected_Bookings__c != null){
                commissionVal += qtLn.SAP_Expected_Bookings__c;   
            } else if (qtLn.SAP_Expected_Bookings__c != null && qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'PRODUCT'){
                commissionVal += qtLn.SAP_Expected_Bookings__c; 
            }           
        }
        if(qt.Rebate_Amount__c != null){
            commissionVal = commissionVal - qt.Rebate_Amount__c;
        }
        return commissionVal;
    }
    
    public static Decimal getDiscountVal(Quote qt, List<Quote_Line__c> qtLineList, Boolean isDiscount){
        Set<Id> prodIds = new Set<Id>();
        Map<String,Boolean> discountProdMap = new Map<String,Boolean>();
        Map<String,Boolean> nonDiscountProdMap = new Map<String,Boolean>();
        Decimal disbBookingVal = 0; 
        String salesOrg;
        for(Quote_Line__c qtln : qtLineList){
            if(qtln.Pricing_Reference_Model__c != null){
                prodIds.add(qtln.Pricing_Reference_Model__c);
            }else{
                prodIds.add(qtln.Product__c);
            }
            
        }
        if(qt.Sales_Org__c != null){
            salesOrg = qt.Sales_Org__c;
        } else {
            salesOrg = 'OM01';
        }
        for(Product_Sales_Org__c org : [Select Id,Discountable_Part__c,Product__c from Product_Sales_Org__c where Product__c in : prodIds and Sales_Org__c =: salesOrg]){
            if(org.Discountable_Part__c){
                discountProdMap.put(org.Product__c,org.Discountable_Part__c);	    
            } else {
                nonDiscountProdMap.put(org.Product__c,org.Discountable_Part__c);
            }
        } 
        if(qt.Order_Type__c == 'ZQRL' || qt.Order_Type__c == 'ZQLI' || qt.Order_Type__c == 'ZQR3' || qt.Order_Type__c == 'ZQL3'){
            for(Quote_Line__c qtLns : qtLineList){  
                if(qtLns.Pricing_Reference_Model__c != null){
                    if(qtLns.Product__r.name != 'FREIGHT' && qtLns.Material_Type__c != 'SERVICE'){
                        if(discountProdMap.containsKey(qtLns.Pricing_Reference_Model__c) && qtLns.SAP_NPV__c!= null && isDiscount == true){        
                            disbBookingVal += qtLns.SAP_NPV__c * qtLns.Quantity__c;   
                        } else if (!discountProdMap.containsKey(qtLns.Pricing_Reference_Model__c) && qtLns.SAP_NPV__c!= null && isDiscount == false){
                            system.debug('disc: '+qtLns.Pricing_Reference_Model__r.name+' '+qtLns.SAP_NPV__c);
                            disbBookingVal += qtLns.SAP_NPV__c * qtLns.Quantity__c;    
                        }
                    }
                }else{
                    if(qtLns.Product__r.name != 'FREIGHT' && qtLns.Material_Type__c != 'SERVICE'){
                        if(discountProdMap.containsKey(qtLns.Product__c) && qtLns.SAP_NPV__c!= null && isDiscount == true){        
                            disbBookingVal += qtLns.SAP_NPV__c * qtLns.Quantity__c;   
                        } else if (!discountProdMap.containsKey(qtLns.Product__c) && qtLns.SAP_NPV__c!= null && isDiscount == false){
                            system.debug('disc: '+qtLns.Product__r.name+' '+qtLns.SAP_NPV__c);
                            disbBookingVal += qtLns.SAP_NPV__c * qtLns.Quantity__c;    
                        }
                    }
                }
                
            }
        }else{
            for(Quote_Line__c qtLns : qtLineList){     
                if(qtLns.Pricing_Reference_Model__c != null){
                    if(qtLns.Product__r.name != 'FREIGHT' && qtLns.Material_Type__c != 'SERVICE'){
                        if(discountProdMap.containsKey(qtLns.Pricing_Reference_Model__c) && qtLns.SAP_Expected_Bookings__c != null && isDiscount == true){        
                            disbBookingVal += qtLns.SAP_Expected_Bookings__c;   
                        } else if (!discountProdMap.containsKey(qtLns.Pricing_Reference_Model__c) && qtLns.SAP_Expected_Bookings__c!= null && isDiscount == false){
                            disbBookingVal += qtLns.SAP_Expected_Bookings__c;    
                        }
                    }
                }else{
                    if(qtLns.Product__r.name != 'FREIGHT' && qtLns.Material_Type__c != 'SERVICE'){
                        if(discountProdMap.containsKey(qtLns.Product__c) && qtLns.SAP_Expected_Bookings__c != null && isDiscount == true){        
                            disbBookingVal += qtLns.SAP_Expected_Bookings__c;   
                        } else if (!discountProdMap.containsKey(qtLns.Product__c) && qtLns.SAP_Expected_Bookings__c!= null && isDiscount == false){
                            disbBookingVal += qtLns.SAP_Expected_Bookings__c;    
                        }
                    }
                }
                
            }
        }
        
        return disbBookingVal;
    }
    
    public static String getNonDiscountable(Quote qt, Quote_Line__c qtLn){
        String nonDiscountable = ''; 
        String salesOrg;
        if(qt.Sales_Org__c != null){
            salesOrg = qt.Sales_Org__c;
        } else {
            salesOrg = 'OM01';
        }
        string pr = '';
        if(qtLn.Pricing_Reference_Model__c != null){
            pr = qtLn.Pricing_Reference_Model__c;
        }else{
            pr = qtln.Product__c;
        }
        Product_Sales_Org__c prdSalesOrg = [Select Id,Discountable_Part__c,Product__c from Product_Sales_Org__c where Product__c =: pr and Sales_Org__c =: salesOrg];
        if(!prdSalesOrg.Discountable_Part__c){
            nonDiscountable = 'X';	    
        } 
        return nonDiscountable;
    }
    
    public static Decimal getMonthlyVal(Quote qt,List<Quote_Line__c> qtLineList){
        Decimal monthly = 0;
        if(qt.Order_Type__c != 'ZQRS'){
            if(qt.Conga_one_time_Impl_Fee__c!= null && qt.Resident_Operator_Solution_Fee__c!= null && qt.subscription_Months__c != null && qt.subscription_Months__c > 0){
                monthly = (getListPrice(qt, qtLineList,'Customer_Price__c') - qt.Conga_one_time_Impl_Fee__c - qt.Resident_Operator_Solution_Fee__c)/qt.subscription_Months__c;
            }
            if(qt.Resident_Operator_Solution_Fee__c!= null && qt.Resident_Operator_Solution_Fee__c!= 0 && qt.Resident_Operator_Duration__c != null && qt.Resident_Operator_Duration__c > 0){
                monthly = monthly + (qt.Resident_Operator_Solution_Fee__c/qt.Resident_Operator_Duration__c);
            }
        }else{//IBA-2174
            if(qt.Conga_one_time_Impl_Fee__c!= null && qt.Resident_Operator_Solution_Fee__c!= null && qt.subscription_Months__c != null && qt.subscription_Months__c > 0){
                monthly = (getListPrice(qt, qtLineList,'Customer_Price__c') - qt.Conga_one_time_Impl_Fee__c)/qt.subscription_Months__c; //IBA-4873 Sourav
            }
        }
        
        return monthly;
    }
    
    public static Decimal getServiceBooking(Quote qt,List<Quote_Line__c> qtLineList){
        Decimal serviceBooking = 0;
        String salesOrg;
        Set<Id> prodIds = new Set<Id>();
        Map<String,string> ProdMap = new Map<String,string>();
        
        for(Quote_Line__c qtln : qtLineList){
            prodIds.add(qtln.Product__c); 
        }
        if(qt.Sales_Org__c != null){
            salesOrg = qt.Sales_Org__c;
        } else {
            salesOrg = 'OM01';
        }
        
        for(Product_Sales_Org__c org : [Select Id,Item_Category_Group__c,Product__c from Product_Sales_Org__c where Product__c in : prodIds and Sales_Org__c =: salesOrg]){
            ProdMap.put(org.Product__c,org.Item_Category_Group__c);
        } 
        
        if(qt.Order_Type__c == 'ZQRL' || qt.Order_Type__c == 'ZQLI' || qt.Order_Type__c == 'ZQR3' || qt.Order_Type__c == 'ZQL3'){
            for(Quote_Line__c qtLn: qtLineList){
                string serv = ProdMap.get(qtLn.Product__c);
                if((serv == 'LEIS' || serv == 'ZDIN') && qt.Order_Type__c == 'ZQL3'){ //IBA-4873 Sourav start
                    serviceBooking += (qtLn.SAP_NPV__c * qtLn.Quantity__c);
                }
                else if(serv == 'LEIS' || serv == 'ZDIN'){  
                    serviceBooking += qtLn.SAP_NPV__c;
                }					//IBA-4873 Sourav End
            }
        }else{
            for(Quote_Line__c qtLn: qtLineList){
                if(qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'SERVICE' &&qtLn.SAP_Expected_Bookings__c != null){
                    serviceBooking += qtLn.SAP_Expected_Bookings__c;
                }
            }
        }
        
        return serviceBooking;    
    }
    
    public static Decimal getServiceDiscount(List<Quote_Line__c> qtLineList){
        Decimal serviceDisc = 0;
        Integer count = 0;
        for(Quote_Line__c qtLn: qtLineList){
            if(qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'SERVICE' && qtLn.Discount_Percent__c != null && qtLn.Discount_Percent__c != 0){
                serviceDisc += qtLn.Discount_Percent__c;
                count += 1; 
            }
        }
        if(count > 0){
            serviceDisc = serviceDisc/count;
        }
        return serviceDisc;
    }
    
    public static Decimal getMarginService(decimal servB, decimal servC){
        Decimal marginService = 0;
        if(servB > 0){
            marginService = ((servB-servC)/servB)*100;
        }
        
        return marginService;
    }
    
    public static Decimal getServiceCost(List<Quote_Line__c> qtLineList){
        Decimal serviceCost = 0;
        for(Quote_Line__c qtLn: qtLineList){
            if(qtLn.Material_Type__c != null && qtLn.Material_Type__c == 'SERVICE' &&qtLn.Total_Cost__c != null && qtLn.Total_Cost__c != 0){
                serviceCost += qtLn.Total_Cost__c;
            }
        }
        return serviceCost;    
    }
    
    public static String constructTermValue(Decimal val){
        String constructedVal;
        if(val > 0 && val < 10){
            constructedVal = '00'+String.valueOf(Integer.valueOf(val));
        } else if (val >= 10 && val < 100){
            constructedVal = '0'+String.valueOf(Integer.valueOf(val));
        }  else if(val >= 100 && val < 1000) {
            constructedVal = String.valueOf(Integer.valueOf(val));    
        }  else {
            constructedVal = '000';
        }
        return constructedVal;
    }
    
    public static Decimal getOmnicellBookingAmount(Quote qt, Quote_Line__c qtLn){ //IBA-4873 Sourav
        if(qt.Order_Type__c == 'ZQRL' || qt.Order_Type__c == 'ZQLI' || qt.Order_Type__c == 'ZQR3' 
           || qt.Order_Type__c == 'ZQL3' || qt.Order_Type__c == 'ZQR' || qt.Order_Type__c == 'ZQD'){ //IBA-4873 Sourav Start
               if(qtLn.Product__r.DW_Product_Type__c == 'Subscription' && (qt.Order_Type__c == 'ZQR' || qt.Order_Type__c == 'ZQD')){
                   if(qtLn.Total_Customer_Price__c != null){
                       return qtLn.Total_Customer_Price__c;
                   } else {
                       return 0;   
                   }
               }
               else{
                   if(qtLn.SAP_NPV__c != null){
                       return qtLn.SAP_NPV__c*qtLn.Quantity__c;
                   } else {
                       return 0;   
                   }
               }
           }else{
               
               if(qtLn.SAP_Expected_Bookings__c != null){
                   return qtLn.SAP_Expected_Bookings__c;
               } else {
                   return 0;   
               }
           }
    }
    
}