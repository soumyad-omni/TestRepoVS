public with sharing class SaveResultforOppCustomForm {
    @AuraEnabled
    public Boolean success { get; set; }
    @AuraEnabled
    public String message { get; set; }
    @AuraEnabled
    public Opportunity oppDetails { get; set; }    
    @AuraEnabled
    public Boolean proceedToQuote { get; set; }   
}