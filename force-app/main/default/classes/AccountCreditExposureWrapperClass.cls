Public class AccountCreditExposureWrapperClass {
    @AuraEnabled Public ZISM_BAPI_CR_ACC_GETDETAIL ZISM_BAPI_CR_ACC_GETDETAIL;
    Public static AccountCreditExposureWrapperClass parse(String json){
        return (AccountCreditExposureWrapperClass) System.JSON.deserialize(json, AccountCreditExposureWrapperClass.class);
    }
    
    Public class EV_CREDIT_OVERVIEW
    {
        @AuraEnabled Public String BOOKED_NOT_PAID;
        
        @AuraEnabled Public String CMWAE;
        
        @AuraEnabled Public String NOTES;
    }
    
    Public class PS_CREDIT_ACCOUNT_DETAIL_ALL
    {
        @AuraEnabled Public String CRED_LIMIT;
        
        @AuraEnabled Public String CRED_ACCNT;
        
        @AuraEnabled Public String RCVBL_VALS;
        
        @AuraEnabled Public String CRED_LIAB;
        
        @AuraEnabled Public String CURRENCIES;
        
        @AuraEnabled Public String RISK_CATEG;
        
        @AuraEnabled Public String BLOCKED;
        
        @AuraEnabled Public String NXT_REVIEW;
        
        @AuraEnabled Public String SECURED_ITEMS;
        
        @AuraEnabled Public String DATA_TOO_OLD;
        
        @AuraEnabled Public String DATA_NOT_FOUND;
        
        @AuraEnabled Public String AGING_IN_DAYS;
        
        @AuraEnabled Public String AGING_IN_HOURS;
        
        @AuraEnabled Public String ORDER_VALS;
        
        @AuraEnabled Public String TOTAL_LIABILITIES;
        
    }
    
    Public class RETURNS
    {
        @AuraEnabled Public String TYPE;
        
        @AuraEnabled Public String ID;
        
        @AuraEnabled Public String NUMBERS;
        
        @AuraEnabled Public String MESSAGE;
        
        @AuraEnabled Public String LOG_NO;
        
        @AuraEnabled Public String LOG_MSG_NO;
        
        @AuraEnabled Public String MESSAGE_V1;
        
        @AuraEnabled Public String MESSAGE_V2;
        
        @AuraEnabled Public String MESSAGE_V3;
        
        @AuraEnabled Public String MESSAGE_V4;
    }
    Public class Imports
    {
        @AuraEnabled Public String PV_ALLOWED_AGING_IN_DAYS;
        
        @AuraEnabled Public String PV_ALLOWED_AGING_IN_HOURS;
        
        @AuraEnabled Public String PV_CREDIT_CONTROL_AREA;
        
        @AuraEnabled Public String PV_CUSTOMER;
        
    }
    Public class Exports
    {
        @AuraEnabled Public EV_CREDIT_OVERVIEW EV_CREDIT_OVERVIEW;
        
        @AuraEnabled Public PS_CREDIT_ACCOUNT_DETAIL_ALL PS_CREDIT_ACCOUNT_DETAIL_ALL;
        
        @AuraEnabled Public RETURNS RETURNS;
    }
    
    Public class Row
    {
        @AuraEnabled Public String VBELN;
        
        @AuraEnabled Public String BOOKED_NOT_PAID;
        
        @AuraEnabled Public String QUOTE_NUMBERS;
        
        @AuraEnabled Public String CMWAE;
        
        @AuraEnabled Public String NETWR;
        
        @AuraEnabled Public String AMOUNT_INVOICED;
        
        @AuraEnabled Public String AMOUNT_NOT_PAID;
        
    }
    
    
    Public class ET_OPEN_LIABILITIES
    {
        @AuraEnabled Public List<Row> row;
        
    }
    Public class Tables
    {
        @AuraEnabled Public ET_OPEN_LIABILITIES ET_OPEN_LIABILITIES;
    }
    
    Public class ZISM_BAPI_CR_ACC_GETDETAIL
    {
        @AuraEnabled Public Imports imports;
        
        @AuraEnabled Public Exports exports;
        
        @AuraEnabled Public Tables tables;
    }
}