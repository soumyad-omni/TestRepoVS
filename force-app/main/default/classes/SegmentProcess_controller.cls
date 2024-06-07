global class SegmentProcess_controller {
    
    @AuraEnabled
    global static Boolean updateSegment(){
        Boolean retVal = true;
        ProcessSegment b = new ProcessSegment();
        Database.executeBatch(b);
        retVal = false;
        return retVal;
    }

}