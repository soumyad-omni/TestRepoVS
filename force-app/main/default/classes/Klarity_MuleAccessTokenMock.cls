@isTest(seeAllData=false)
global class Klarity_MuleAccessTokenMock implements HttpCalloutMock {
    
    public string isMockresponse;
    
    
    global HttpResponse respond(HttpRequest req){
        	HttpResponse res = new HttpResponse();
        	res.setHeader('Content-Type','application/json');
        	res.setBody('{"kna1List" : {"KUNNR" : "123456762745","KTOKD" : "ZCSN","SORTL" : "t17571788","BRSCH" : "0007","ZZMASTERAGRE" : "","ZROLE" : "ZCSN","NURL" : "","ZZ_ID" : "0012g000009VD2xAAG","ZZFLD000004" : "","LOEVM" : "","KUKLA" : "01","SPRAS" : "E"},"addressList" : {"NAME" : "t17571788","NAME_2" : "","NAME_3" : "","NAME_4" : "","STR_SUPPL1" : "","COUNTRY" : "US","LANGU" : "E","REGION" : "CA","CITY" : "San Jose","POSTL_COD1" : "95128","TRANSPZONE" : "IN00000001","SORT1" : "t17571788","TEL1_NUMBR" : "","FAX_NUMBER" : "","PO_BOX" : "","E_MAIL" : "","STREET" : "South Bascom Avenue", "STREET_NUMBER" : "200"},"knvvList" : [{"VKORG" : "AU01","VTWEG" : "01","KDGRP" : "","KONDA" : "","PLTYP" : "PP","INCO1" : "DAP","INCO2" : "Test","VSBED" : "01","WAERS" : "USD","ZTERM" : "MD10","VKBUR" : "AU03","KVGR5" : "","ZPRICING_DATE" : "","KALKS" : "1","SPART" : "00","BZIRK" : "US0007","PERNR" : ""}],"knviList" : [{"TAXKD" : "1"}],"knvpList" : [{"KUNNR" : "","VKORG" : "AU01","VTWEG" : "01","SPART" : "","PARVW" : "ZM","PERNR" : "","KZ" : "I"}]}');
            res.setStatusCode(200);
       
        return res;
    }
}