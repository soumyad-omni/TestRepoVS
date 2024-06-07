global class UpdateOppDivController {
   
    @AuraEnabled
    global static Boolean updateDiv(){
        Boolean retVal = true;
        updateOppAccDivision b = new updateOppAccDivision();
        Database.executeBatch(b);

        return retVal;
    }
}