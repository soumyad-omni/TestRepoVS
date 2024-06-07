trigger BookingPackApprvalTrigger on Booking_Pack_Approval__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerDispatcher.run(new BookingPackApprovalTriggerHandler());
}