/*
 End Point: https://omnicell--fulldev.sandbox.my.salesforce.com/services/apexrest/QLBacklogValidDate
Method: POST
Request Body: 
{
      "valid_to":"2022-09-28",
      "valid_from":"2022-08-12"
}
*/
@RestResource(urlMapping='/QLBacklogValidDate/*')
global with sharing class QLBacklogValidDateIntegration {
    @HttpPost
    global Static void updateQLBacklogRestMethod(){
        RestRequest request= RestContext.request;
        RestResponse response= RestContext.response;
        
        String requestBody= request.requestBody.toString();
        System.debug('Printing the request body'+requestBody);
        try
        {
            if(requestBody <> '' && requestBody <> NULL)
            {
                cls_wrapper cls = (cls_wrapper)JSON.deserialize(requestBody, cls_wrapper.class);
                
                if(cls.valid_to == NULL || cls.valid_from == NULL)
                {
                    response.statusCode = 400;
                    response.responseBody=blob.valueOf('Invalid Date');
                }
                else
                {
                    Database.executeBatch(new BatchQLBacklogValidDateIntegration(cls.valid_from, cls.valid_to), 10000);
                }
            }
            else
            {
                response.statusCode = 400;
                response.responseBody=blob.valueOf('Invalid Request Body');
            }
        }
        catch(Exception ex)
        {
            response.statusCode = 400;
            response.responseBody=blob.valueOf(ex.getMessage());
        }
    }
    
    global class cls_wrapper
    {
        Date valid_to;
        Date valid_from;
    }
}