public class LookUpPageUserController {
    public String searchvalue { get; set;}
    List<User> listUsers = new List<User>();
    String norecords;

	public LookUpPageUserController() {
        norecords = System.Label.LookUp_Page_No_Records_Found_Error;
        searchvalue=ApexPages.currentPage().getParameters().get('parentname');
        String searchText = '%'+ searchvalue + '%';
        system.debug('searchText: '+ searchText);
        id b2bProfileId = [select Id, Name from Profile where name = 'Omnicell B2B Storefront Profile'].id;
		listUsers = [select Name,Id from user where IsActive = True AND Name Like :searchText AND ProfileId != :b2bProfileId Order by Name];
	}
    public List<User> getlistUsers() {
        if(listUsers.size()!=0)
        {
            return listUsers;
        }else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,norecords));
            return null;
        }
    }
}