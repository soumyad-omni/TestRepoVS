public class AccountCreditController {
    
    @AuraEnabled
    public static Account getAccountDetails(String recId)
    {
        return [SELECT id, name FROM account WHERE id = :recId];
    }
    
    @AuraEnabled public static AccountCreditControllerWrapper showAccountCreditDetails(String AccId) 
    {
        AccountCreditExposureWrapperClass j = new AccountCreditExposureWrapperClass();
        AccountCreditControllerWrapper response = new AccountCreditControllerWrapper();
        System.debug('Inside AccountCreditController........' +AccId);
        Account acc = [Select id,SAP_Account_ID__c from Account where Id =:AccId];
        String accountNumber = acc.SAP_Account_ID__c;
        String creditControlArea = 'OM00';
        Decimal primaryLiabilitiesAndBookedNotPaid = 0;
        try
        {
            String responseString = '';
            String errormsg = '';
            Map<String, Object> jsondata1 = new Map<String, Object>{'PV_CUSTOMER' => accountNumber,'PV_CREDIT_CONTROL_AREA' => creditControlArea};
            Map <String, Object> jsondata = new Map<String, Object>{'ISM_BAPI_CR_ACC_GETDETAIL' =>  jsondata1};
            String jsonstring = JSON.serialize(jsondata);
            System.debug('rj........' +jsonstring);
            SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_Credit_Check');
            String endpoint =   connectionDetails.SCP_End_Point__c;
            String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem(); 
            system.debug('accessToken-- '+accessToken);
            if(accessToken != null )
            {
                Http h= new Http();
                HttpRequest req= new HttpRequest();
                req.setHeader('Authorization', 'Bearer '+accessToken);
                req.setHeader('Content-Type','application/json');
                req.setHeader('accept','application/json');
                req.setBody(jsonstring);
                req.setMethod(connectionDetails.SCP_Method_Type__c);
                req.setEndpoint(endpoint);
                req.setTimeout((Integer)connectionDetails.SCP_Timeout__c);
                HttpResponse res=h.send(req);
                system.debug('res.getBody()-->'+res.getBody());
                responseString = res.getBody();
                responseString = responseString.replace('ISM_BAPI_CR_ACC_GETDETAIL.Response', 'ISM_BAPI_CR_ACC_GETDETAILResponse');
                responseString = responseString.replace('RETURN', 'RETURNS');
                responseString = responseString.replace('NUMBER', 'NUMBERS');
                responseString = responseString.replace('export', 'exports');
                responseString = responseString.replace('import', 'imports');
                responseString = responseString.replace('CURRENCY', 'CURRENCIES');
                System.debug('responseString...' +responseString);
                if(res.getStatusCode() == 201)
                {
                    system.debug('b.......');
                    j = AccountCreditExposureWrapperClass.parse(responseString);
                    system.debug('a........' +j);
                    List<AccountCreditExposureWrapperClass.Row> rows =j.ZISM_BAPI_CR_ACC_GETDETAIL.tables.ET_OPEN_LIABILITIES.row;
                    System.debug('Rows:'+rows);
                    List<AccountCreditControllerWrapper.BookedNotPaid> bookedNotPaidList = new List<AccountCreditControllerWrapper.BookedNotPaid>();
                    Set<String> SAPQuoteIds = new Set<String>();
                    if(rows != null && !rows.isEmpty())
                    {
                        for(AccountCreditExposureWrapperClass.Row rowData :rows)
                        {
                            System.debug('Each Row'+rowData);
                            System.debug('Quote Number'+rowData.QUOTE_NUMBERS);
                            if(rowData.QUOTE_NUMBERS != '' && rowData.QUOTE_NUMBERS != null && rowData.QUOTE_NUMBERS != 'null')
                                SAPQuoteIds.add(rowData.QUOTE_NUMBERS);
                        }
                        
                    }
                    System.debug('Quotes Set:'+SAPQuoteIds);
                    List<Quote> quotes;
                    Decimal totalBookedNotInvoiced = 0, totalInvoicedNotPaid = 0;
                    if(!SAPQuoteIds.isEmpty())
                    {
                        quotes = [Select id,Quote_Number__c,SAP_Quote_Number_Truncated__c,Name,OpportunityId,Opportunity.Opportunity_Number__c,Opportunity.Name,Opportunity.Expected_Bookings_Real__c,Opportunity.Credit_Approval_Date__c,AccountId,Account.Name,Credit_Approved_For_Lookup__c,Credit_Approved_For_Lookup__r.name from Quote where Quote_Number__c in :SAPQuoteIds];
                        Map<String, Quote> quoteData = new Map<String, Quote>();
                        for(Quote q:quotes)
                        {
                            quoteData.put(q.Quote_Number__c,q);
                        }
                        
                        for(AccountCreditExposureWrapperClass.Row rowData :rows)
                        {
                            AccountCreditControllerWrapper.BookedNotPaid BookedNotPaid = new AccountCreditControllerWrapper.BookedNotPaid();

                            if( quoteData.get(rowData.QUOTE_NUMBERS) != null)
                            {
                                BookedNotPaid.oppNumber = quoteData.get(rowData.QUOTE_NUMBERS).Opportunity.Opportunity_Number__c;
                                BookedNotPaid.oppId = quoteData.get(rowData.QUOTE_NUMBERS).OpportunityId;
                                BookedNotPaid.oppName = quoteData.get(rowData.QUOTE_NUMBERS).Opportunity.Name;
                                BookedNotPaid.quoteName = quoteData.get(rowData.QUOTE_NUMBERS).Name;
                                BookedNotPaid.quoteNumber = quoteData.get(rowData.QUOTE_NUMBERS).SAP_Quote_Number_Truncated__c;
                                BookedNotPaid.quoteId = quoteData.get(rowData.QUOTE_NUMBERS).Id;
                                BookedNotPaid.customerName = quoteData.get(rowData.QUOTE_NUMBERS).account.Name;
                                BookedNotPaid.accountId = quoteData.get(rowData.QUOTE_NUMBERS).accountId;
                                BookedNotPaid.oppExpectedBookings = quoteData.get(rowData.QUOTE_NUMBERS).Opportunity.Expected_Bookings_Real__c;
                                BookedNotPaid.creditApprovedDate = quoteData.get(rowData.QUOTE_NUMBERS).Opportunity.Credit_Approval_Date__c;
                            }
                            BookedNotPaid.SoNumber = rowData.VBELN;
                            BookedNotPaid.amoutOutsandingAsLiability = Decimal.valueOf(rowData.BOOKED_NOT_PAID);
                            BookedNotPaid.amountBooked = Decimal.valueOf(rowData.NETWR);
                            BookedNotPaid.amountInvoiced = Decimal.valueOf(rowData.AMOUNT_INVOICED);
                            BookedNotPaid.invoicedNotPaid = Decimal.valueOf(rowData.AMOUNT_NOT_PAID);
                            BookedNotPaid.amountPaid = BookedNotPaid.amountBooked - BookedNotPaid.amoutOutsandingAsLiability;
                            bookedNotPaidList.add(BookedNotPaid);
                            
                            totalBookedNotInvoiced += BookedNotPaid.amountBooked == null ? 0 : BookedNotPaid.amountBooked;
                            totalInvoicedNotPaid += BookedNotPaid.invoicedNotPaid == null ? 0 : BookedNotPaid.invoicedNotPaid;
                        }
                    }
                    
                    Decimal primaryLiabilities = Decimal.valueOf(j.ZISM_BAPI_CR_ACC_GETDETAIL.exports.PS_CREDIT_ACCOUNT_DETAIL_ALL.TOTAL_LIABILITIES);
                    System.debug('Comments:'+j.ZISM_BAPI_CR_ACC_GETDETAIL.exports.EV_CREDIT_OVERVIEW.NOTES);
                    Decimal bookedNotPaid = Decimal.valueOf(j.ZISM_BAPI_CR_ACC_GETDETAIL.exports.EV_CREDIT_OVERVIEW.BOOKED_NOT_PAID);
                    response.sumOfBookedNotInvoiced = totalBookedNotInvoiced;
                    response.sumOfInvoicedNotPaid = totalInvoicedNotPaid;
                    response.BookedNotPaidList = bookedNotPaidList;
                    response.wrapper = j;
                    primaryLiabilitiesAndBookedNotPaid = primaryLiabilities + bookedNotPaid;
                }
            }
            
            List<Opportunity> opps = [Select Id,Name,Opportunity_Number__c,Expected_Bookings_Real__c,Credit_Approval_Date__c,Credit_Approval_Date1__c,AccountId,Account.Name,Credit_Approved_For__c,Credit_Approved_For__r.Name,PrimaryQuote__c,PrimaryQuote__r.Name,PrimaryQuote__r.Net_Value__c,PrimaryQuote__r.SAP_Quote_Number_Truncated__c
                                      From Opportunity
                                      Where Credit_Approved_For__c = :AccId and AccountId != :AccId and OppStatus__c != 'Lost' and OppStatus__c != 'Fully Booked' and PrimaryQuote__c != null];
            
            Decimal approvedNotBookedVal = 0;
            Decimal totalOppExpectedBooking = 0, totalQuoteNetValue = 0;
            List<AccountCreditControllerWrapper.ApprovedNotBooked> approvedNotBookedList = new List<AccountCreditControllerWrapper.ApprovedNotBooked>();
            for(Opportunity opp:opps)
            {
                AccountCreditControllerWrapper.ApprovedNotBooked ApprovedNotBooked= new AccountCreditControllerWrapper.ApprovedNotBooked();
                ApprovedNotBooked.oppNumber = opp.Opportunity_Number__c;
                ApprovedNotBooked.oppId =opp.Id;
                ApprovedNotBooked.oppName =opp.Name;
                ApprovedNotBooked.quoteName =opp.PrimaryQuote__r.Name;
                ApprovedNotBooked.quoteNumber =opp.PrimaryQuote__r.SAP_Quote_Number_Truncated__c;
                ApprovedNotBooked.quoteId =opp.PrimaryQuote__c;
                ApprovedNotBooked.customerName = opp.Account.Name;
                ApprovedNotBooked.accountId = opp.AccountId;
                ApprovedNotBooked.oppExpectedBookings = opp.Expected_Bookings_Real__c;
                ApprovedNotBooked.creditApprovedDate = opp.Credit_Approval_Date__c;
                ApprovedNotBooked.quoteNetValue = opp.PrimaryQuote__r.Net_Value__c;
                if(opp.PrimaryQuote__r.Net_Value__c != null)
                    approvedNotBookedVal = approvedNotBookedVal + opp.PrimaryQuote__r.Net_Value__c;
                approvedNotBookedList.add(ApprovedNotBooked);
                
                totalOppExpectedBooking += opp.Expected_Bookings_Real__c == null ? 0 : opp.Expected_Bookings_Real__c;
                totalQuoteNetValue += opp.PrimaryQuote__r.Net_Value__c == null ? 0 : opp.PrimaryQuote__r.Net_Value__c;
            }
            
            response.sumOfOppExpectedBooking = totalOppExpectedBooking;
            response.sumOfQuoteNetValue = totalQuoteNetValue;
            response.ApprovedNotBookedList = approvedNotBookedList;
            response.ApprovedNotBooked = approvedNotBookedVal;
            response.TotalLiabilities = primaryLiabilitiesAndBookedNotPaid + approvedNotBookedVal;
            return response;
            
        }
        catch (Exception ex)
        {
            System.debug('Error Occurred : ' + ex.getMessage());
            return response;
        } 
    }
}