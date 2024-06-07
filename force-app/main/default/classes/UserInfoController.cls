public class UserInfoController{
public user cuser{get;set;}
public string HideCuserAccess{get;set;}
public string ShowCuserAccess{get;set;}

public UserInfoController(){
 HideCuserAccess = 'none';
        ShowCuserAccess = 'none';
    cuser=new User();
    cuser=[Select Id,Name,Email,Read_Only_User__c from User where Id=:userinfo.getuserId()];
    system.debug('++++++'+cuser.Read_Only_User__c);
    if(cuser.Read_Only_User__c){
        HideCuserAccess = 'block';
        ShowCuserAccess = 'none';
    }else{
     HideCuserAccess = 'none';
        ShowCuserAccess = 'block';
    }
    }
}