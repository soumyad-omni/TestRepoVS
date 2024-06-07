public class AccountCreditControllerWrapper {
	@AuraEnabled Public AccountCreditExposureWrapperClass wrapper;
    @AuraEnabled Public Decimal TotalLiabilities;
    @AuraEnabled Public Decimal ApprovedNotBooked;
    @AuraEnabled Public Decimal sumOfBookedNotInvoiced;
    @AuraEnabled Public Decimal sumOfInvoicedNotPaid;
    @AuraEnabled Public Decimal sumOfOppExpectedBooking;
    @AuraEnabled Public Decimal sumOfQuoteNetValue;
    @AuraEnabled Public List<BookedNotPaid> PrimaryLiablities;
    @AuraEnabled Public List<BookedNotPaid> BookedNotPaidList;
    @AuraEnabled Public List<ApprovedNotBooked> ApprovedNotBookedList;
    
    Public class BookedNotPaid{
        @AuraEnabled Public String oppNumber;
        @AuraEnabled Public Id oppId;
        @AuraEnabled Public String oppName;
        @AuraEnabled Public String quoteName;
        @AuraEnabled Public String quoteNumber;
        @AuraEnabled Public Id quoteId;
        @AuraEnabled Public String customerName;
        @AuraEnabled Public Id accountId;
        @AuraEnabled Public Decimal oppExpectedBookings;
        @AuraEnabled Public Date creditApprovedDate;
        @AuraEnabled Public String SoNumber;
        @AuraEnabled Public Decimal amoutOutsandingAsLiability;
        @AuraEnabled Public Decimal amountBooked;
        @AuraEnabled Public Decimal amountPaid;
        @AuraEnabled Public Decimal amountInvoiced;
        @AuraEnabled Public Decimal invoicedNotPaid;
    }
    Public class ApprovedNotBooked{
        @AuraEnabled Public String oppName;
        @AuraEnabled Public String oppNumber;
        @AuraEnabled Public Id oppId;
        @AuraEnabled Public String quoteName;
        @AuraEnabled Public String quoteNumber;
        @AuraEnabled Public Id quoteId;
        @AuraEnabled Public String customerName;
        @AuraEnabled Public Id accountId;
        @AuraEnabled Public Decimal oppExpectedBookings;
        @AuraEnabled Public Date creditApprovedDate;
        @AuraEnabled Public Decimal quoteNetValue;
    }
}