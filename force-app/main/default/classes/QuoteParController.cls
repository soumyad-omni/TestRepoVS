/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-04-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class QuoteParController 
{
    @AuraEnabled
    public static list<QuoteParMap__c> createQuotePar(list<QuoteParMap__c> newQuotePars, Id quoteId)
    {
        if(!newQuotePars.isEmpty())
        {
            Map<string,QuoteParMap__c> parMap = new Map<string,QuoteParMap__c>();
            for(QuoteParMap__c qp : newQuotePars)
            {
                if(parMap.containsKey(qp.Par__c))
                {
                    throw new AuraHandledException('Duplicate Par.');
                }
                parMap.put(qp.Par__c, qp);
            }
            list<QuoteParMap__c> duplicatePars = new list<QuoteParMap__c>([SELECT Par__c FROM QuoteParMap__c WHERE Quote__c=:quoteId AND Par__c = :parMap.keyset()]);
            if(duplicatePars != null && duplicatePars.size()>0)
            {
                throw new AuraHandledException('Duplicate Par already exist.');
            }
            try{
                upsert newQuotePars;
            }catch(DMLException ex){
                throw new AuraHandledException(ex.getDmlMessage(0));
            }
        }
        return getQuotePar(quoteId, null);
    }
    @AuraEnabled
    public static list<QuoteParMap__c> getQuotePar(Id quoteId, string isOnload)
    {
        list<QuoteParMap__c> QuoteParMapList = [SELECT Id,Name,Par__c,Quote__c,Quote__r.Quote_Number__c FROM QuoteParMap__c WHERE Quote__c = :quoteId ORDER BY Order__c];
        if( isOnload=='Yes' && (QuoteParMapList == null || QuoteParMapList.size()==0))
        {
            list<Quote_Line__c> quoteLines = [SELECT Par_Location__c FROM Quote_Line__c WHERE Quote__c=:quoteId AND Par_Location__c !=null];
            list<QuoteParMap__c> newQuoteParList = new list<QuoteParMap__c>();
            if(quoteLines != null && quoteLines.size()>0)
            {
                set<string> uniquePars = new set<string>();
                for(Quote_Line__c ql : quoteLines)
                {
                    if(!uniquePars.contains(ql.Par_Location__c))
                    {
                        newQuoteParList.add(new QuoteParMap__c(Quote__c=quoteId,Par__c=ql.Par_Location__c));
                    }
                    uniquePars.add(ql.Par_Location__c);
                }
            }
            else
            {
                for(Quote_Par_Default__mdt defaultMap : [SELECT Id, Label, DeveloperName, Order__c FROM Quote_Par_Default__mdt])
                {
                    newQuoteParList.add(new QuoteParMap__c(Quote__c=quoteId,Par__c=defaultMap.Label, Order__c=defaultMap.Order__c));
                }
            }
            insert newQuoteParList;
        }
        return [SELECT Id,Name,Par__c,Quote__c,Quote__r.Quote_Number__c FROM QuoteParMap__c WHERE Quote__c = :quoteId ORDER BY Order__c];
    }
    @AuraEnabled
    public static list<QuoteParMap__c> renameQuotePar(QuoteParMap__c renameQuoteParMap, Id quoteId)
    {
        list<QuoteParMap__c> otherPars = [SELECT Id,Par__c FROM QuoteParMap__c WHERE Quote__c = :quoteId 
                                          AND Id != :renameQuoteParMap.Id AND Par__c = :renameQuoteParMap.Par__c];
        if(otherPars != null && otherPars.size()>0)
        {
            throw new AuraHandledException('Duplicate Par exist.');
        }
        String parLocation = [SELECT Par__c FROM QuoteParMap__c WHERE Id = :renameQuoteParMap.Id][0].Par__c;
        list<Quote_Line__c> quoteLinesToUpdate = [SELECT Id,Par_Location__c FROM Quote_Line__c WHERE Par_Location__c=:parLocation AND Quote__c=:quoteId];
		for(Quote_Line__c ql : quoteLinesToUpdate)
        {
            ql.Par_Location__c = renameQuoteParMap.Par__c;
        }
        try
        {
            update quoteLinesToUpdate;
            update renameQuoteParMap;
        }catch(DMLException ex){
            throw new AuraHandledException(ex.getDmlMessage(0));
        }        
        return [SELECT Id,Name,Par__c,Quote__c FROM QuoteParMap__c WHERE Quote__c = :quoteId ORDER BY Order__c];
    }
    @AuraEnabled
    public static list<QuoteParMap__c> deleteQuotePar(QuoteParMap__c deleteQuoteParMap, Id quoteId)
    {
        list<Quote_Line__c> allQuoteLinesForDelete = [SELECT Id,Par_Location__c,Add_to_cart__c,Cart_Item_to_Delete__c,Interim_flag__c,Higher_Level_Item__c,SAP_Line_Number__c FROM Quote_Line__c WHERE Par_Location__c=:deleteQuoteParMap.Par__c AND Quote__c=:quoteId ORDER BY Add_to_cart__c DESC];
        list<Quote_Line__c> allQuoteLinesFromCart = new list<Quote_Line__c>();
        list<Quote_Line__c> allQuoteLinesNotFromCart = new list<Quote_Line__c>();
        set<decimal> highLines = new set<decimal>();
        for(Quote_Line__c ql : allQuoteLinesForDelete)
        {
            if(ql.Add_to_cart__c == true)
            {
                highLines.add(ql.SAP_Line_Number__c);
                ql.Cart_Item_to_Delete__c = true;
                ql.Interim_flag__c = true;
                allQuoteLinesFromCart.add(ql);
            }else if(highLines.contains(ql.Higher_Level_Item__c)){
                //skip SAP Quote lines
                continue;
            }else{
                allQuoteLinesNotFromCart.add(ql);
            }
        }
        if(allQuoteLinesNotFromCart != null && allQuoteLinesNotFromCart.size()>0)
        {
            system.debug('allQuoteLinesNotFromCart---size--'+allQuoteLinesNotFromCart.size());
            throw new AuraHandledException('Cannot delete the Par as Quote lines present not from Cart.');
        }
        try{
            if(allQuoteLinesFromCart != null && allQuoteLinesFromCart.size()>0)
            {
                update allQuoteLinesFromCart;
            }
            delete deleteQuoteParMap;
        }catch(DMLException ex){
            throw new AuraHandledException(ex.getDmlMessage(0));
        }        
        return [SELECT Id,Name,Par__c,Quote__c FROM QuoteParMap__c WHERE Quote__c = :quoteId ORDER BY Order__c];
    }
    //Below method is used to send quote lines to SAP
    @AuraEnabled
    public static Boolean saveInterimOff(Id quoteId)  //IBA-1664 Changed return type from void to Boolean
    {
        Boolean shwErrorMsg = false; // IBA-1664
        Boolean NAC_User = false;    // IBA-1664
        boolean flag = false;		 // IBA-1664
        Boolean NAC_Prod = false;    // IBA-1664
        Integer count = 0;			 // IBA-1664
        
        list<Quote_Line__c> interimQuoteLines = [SELECT Id,Interim_flag__c,Cart_Item_to_Delete__c,Product_code__c FROM Quote_Line__c WHERE Quote__c=:quoteId AND Interim_flag__c = true];
        list<Quote_Line__c> deleteQuoteLines = new list<Quote_Line__c>();
        
        /*IBA-1664 Starts*/
        List<User> listOfGroupUser = [select id from user where id in
                                             (select userorgroupid from groupmember where group.name =: 'Non-acute XT Select')];
        
        Id profileId = userinfo.getProfileId();
		String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        
        For(User gm: listOfGroupUser){
            if(gm.Id == UserInfo.getUserId() || profileName == 'System Administrator' || profileName == 'Business Administrator'){
                system.debug('##Inside_If-Statement_NAC_USER_OR_BA_SA_: ====' + gm.Id);
                NAC_User = true;
                break;
            }else{
                system.debug('##Inside_If-Statement_NON_NAC_USER: ====' + gm.Id);
            }
        }
        system.debug('##Interimcount: '+ interimQuoteLines.size());
        
        List<Non_acute_XT_Select_cabinets__c> NonAcuteCabinets = Non_acute_XT_Select_cabinets__c.getall().values();        
        for(Quote_line__c ql: interimQuoteLines){
            for(Non_acute_XT_Select_cabinets__c NAC : NonAcuteCabinets){
            	if(ql.Product_Code__c == NAC.Name){
                    NAC_Prod = true;
                    //System.debug('##If__Statement__CustomSettings:-----'+ ql.Product_Code__c + ' ----------- ' + NAC.Name);
                }
        	}
            
            if(NAC_Prod == true && NAC_User == true){
                system.debug('$$#Error: Product and user matched from the group!!');
                flag = true;
            }else if(NAC_Prod == True && NAC_User == false){
                system.debug('$$#Error: User other than NAC!!');
            }else{
                count++;
            }
        }
        if(count == interimQuoteLines.size()){
            flag = true;
            count = 0;
        }
        /*IBA-1664 Ends*/
        
        for(Quote_Line__c ql : interimQuoteLines)
        {
            ql.Interim_flag__c = false;
            if(ql.Cart_Item_to_Delete__c){
                deleteQuoteLines.add(ql);
            }
        }
        try{
            if(interimQuoteLines != null && interimQuoteLines.size()>0)
            {
                if(flag == true){
                    QuoteLineTriggerHandler.updatefromAddProduct = true; //IBA-1845 added flag
                	update interimQuoteLines;
                }else{														
                	system.debug('&&$$Error!! Not NAC_User..');     //IBA-1664
                	shwErrorMsg = true;								//IBA-1664
            	}
            }
            if(deleteQuoteLines != null && deleteQuoteLines.size()>0)
            {
                //delete deleteQuoteLines;
            }
        }catch(DMLException ex){
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        system.debug('##Shwerrormsg: '+shwErrorMsg);
        return shwErrorMsg;  //IBA-1664
    }
    
}