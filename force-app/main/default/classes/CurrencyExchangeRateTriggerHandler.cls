/**
* @File Name          : CurrencyExchangeRateTriggerHandler.cls
* @Description        : 
* @Author             : Abhrajitc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 17/08/2023, 7:38:20 pm
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    17/08/2023   Abhrajitc     			Initial Version
**/
public class CurrencyExchangeRateTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = [Select Name, isDisabled__c From Trigger_Configuration__c Where Name ='CurrencyExchangeRateTrigger'];
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        List<Currency_Exchange_Rate__c> newCurrencyExchangeRates = (List<Currency_Exchange_Rate__c>) newItems;
        Set<String> currencyIsoCodes = new Set<String>();
        for (Currency_Exchange_Rate__c newRate : newCurrencyExchangeRates) {
            currencyIsoCodes.add(newRate.CurrencyIsoCode);
        }
        List<Currency_Exchange_Rate__c> existingRecords = [SELECT Id, CurrencyIsoCode, Status__c
                                                           FROM Currency_Exchange_Rate__c
                                                           WHERE CurrencyIsoCode IN :currencyIsoCodes
                                                           AND Status__c = 'Active'];
        Map<String, Boolean> duplicateMap = new Map<String, Boolean>();
        for (Currency_Exchange_Rate__c existingRecord : existingRecords) {
            duplicateMap.put(existingRecord.CurrencyIsoCode, true);
        }
        for (Currency_Exchange_Rate__c newRate : newCurrencyExchangeRates) {
            if (duplicateMap.containsKey(newRate.CurrencyIsoCode)) {
                newRate.addError('A record with the same Currency and Status set to Active already exists.');
            }
        }
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
    }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        
    }
}