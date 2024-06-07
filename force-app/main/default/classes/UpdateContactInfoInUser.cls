public class UpdateContactInfoInUser implements Queueable{//IBA-4525
    Map<Id,Contact> userConMap;
    public UpdateContactInfoInUser(Map<Id,Contact> userConMap){
        this.userConMap = userConMap;
    }
	public void execute(QueueableContext context) {
        List<User> userList = [Select Id,FirstName,MiddleName,LastName From User Where Id IN :userConMap.keySet() AND Profile.Name = 'Omnicell B2B Storefront Profile'];
        for(User usr:userList){
            Contact con = userConMap.get(usr.Id);
            usr.FirstName = con.FirstName;
            usr.MiddleName = con.MiddleName;
            usr.LastName = con.LastName;
        }
        try{
            update userList;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
}