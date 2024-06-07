public class AccountCreditWrapperClass {
    @AuraEnabled public cls_ISM_BAPI_CR_ACC_GETDETAILResponse ISM_BAPI_CR_ACC_GETDETAILResponse;
    public class cls_ISM_BAPI_CR_ACC_GETDETAILResponse {
        @AuraEnabled public cls_PS_CREDIT_ACCOUNT_DETAIL_ALL PS_CREDIT_ACCOUNT_DETAIL_ALL;
        @AuraEnabled public cls_RETURNS RETURNS;
    }
    public class cls_PS_CREDIT_ACCOUNT_DETAIL_ALL {
        @AuraEnabled public String CRED_LIMIT;  //0.0000
        @AuraEnabled public String RCVBL_VALS;  //0.0000
        @AuraEnabled public String CRED_LIAB;   //0.0000
        @AuraEnabled public String NXT_REVIEW;  //
        @AuraEnabled public String SECURED_ITEMS;   //0.0000
        @AuraEnabled public String AGING_IN_DAYS;   //00
        @AuraEnabled public String AGING_IN_HOURS;  //00
        @AuraEnabled public String ORDER_VALS;  //0.00
        @AuraEnabled public String TOTAL_LIABILITIES;   //0.00
        @AuraEnabled public String RISK_CATEG;
		@AuraEnabled public String BLOCKED; 	
    }
    public class cls_RETURNS {
        @AuraEnabled public String TYPE;    //E
        @AuraEnabled public String ID;  //F4
        @AuraEnabled public String NUMBERS;  //711
        @AuraEnabled public String MESSAGE; //Credit limit not maintained for account 80126971 area OM00
        @AuraEnabled public String LOG_MSG_NO;  //000000
        @AuraEnabled public String MESSAGE_V1;  //80126971
        @AuraEnabled public String MESSAGE_V2;  //OM00
    }
    public static AccountCreditWrapperClass parse(String json){
        return (AccountCreditWrapperClass) System.JSON.deserialize(json, AccountCreditWrapperClass.class);
    }
}