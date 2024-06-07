global class SceduleApexjobOnCurrentQuoteLineResult implements Schedulable {
    private Integer numberOfDays;
    public SceduleApexjobOnCurrentQuoteLineResult(Integer numberOfDays){
        this.numberOfDays = numberOfDays;
    }
    global void execute(SchedulableContext sc) {
        CleanCurrentQuoteLineResult firstJob = new CleanCurrentQuoteLineResult(numberOfDays);
        Database.executeBatch(firstJob,5000);
    }
}