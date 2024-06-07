@isTest(seeAllData=false)
global class Account_mock implements HttpCalloutMock {
    
    public string isMockresponse;
    
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        
            res.setHeader('Content-Type','application/json');
            res.setBody('{"kna1List" : {"KUNNR" : "","KTOKD" : "","SORTL" : "amir","BRSCH" : "0007","ZZMASTERAGRE" : "","ZROLE" : "","NURL" : "","ZZ_ID" : "0012g000009VCI8AAO","ZZFLD000004" : "","LOEVM" : "","KUKLA" : "01","SPRAS" : "E"},"addressList" : {"NAME" : "amir","NAME_2" : "","NAME_3" : "","NAME_4" : "","STR_SUPPL1" : "","COUNTRY" : "US","LANGU" : "E","REGION" : "","CITY" : "","POSTL_COD1" : "","TRANSPZONE" : "","SORT1" : "amir","TEL1_NUMBR" : "","FAX_NUMBER" : "","PO_BOX" : "","E_MAIL" : "","STREET" : "", "STREET_NUMBER" : ""},"knvvList" : [{"VKORG" : "OM01","VTWEG" : "01","KDGRP" : "","KONDA" : "","PLTYP" : "PP","INCO1" : "","INCO2" : "","VSBED" : "01","WAERS" : "USD","ZTERM" : "ZT30","VKBUR" : "OMNE","KVGR5" : "","ZPRICING_DATE" : "","KALKS" : "1","SPART" : "00","BZIRK" : "","PERNR" : ""}],"knviList" : [{"TAXKD" : "1"}],"knvpList" : [{"KUNNR" : "","VKORG" : "OM01","VTWEG" : "01","SPART" : "","PARVW" : "ZM","PERNR" : "","KZ" : "I"}]}');
            res.setStatusCode(200);
       
        return res;
    }
}