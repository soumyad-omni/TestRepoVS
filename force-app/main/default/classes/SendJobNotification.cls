public class SendJobNotification {
    private String job_Name = '';
    private Integer interval_minutes = 0; 
    private Boolean sendMailNow = false;
    private Map<String, String> msgTypeMap = null;
       
    public SendJobNotification(String jobName, Integer minutes) {
        job_Name = jobName;
        interval_minutes = minutes;
        msgTypeMap = setMsgTypeMap();
    }
    
    public void checkTimeAndSendMail(Boolean se){
        sendMailNow = se;
        checkTimeAndSendMail();
    }
    
    public void checkTimeAndSendMail(){
      //  System.debug('checkTimeAndSendMail ::: 1 ');
        try{
            String mailBody = '';
            Boolean scheduleErr = false;
            Boolean jobErr = false;
            Boolean recordErr = false;
            
            // Check the value of interval_minutes variable.
            DateTime dt = System.now();
            DateTime earlier = dt.addMinutes(-interval_minutes);
            System.debug('Now : ' + dt + '\t Earlier : ' + earlier);
            
            // Find teh job id
            Job_list__c jl = [SELECT id, Name FROM Job_list__c 
                WHERE Name = :job_Name LIMIT 1];
            
            // Check all job execution for this job for the time period 
            // of "interval_minutes" munites.
            List<Job_execution__c> jeList =[SELECT id, Name, endTime__c, Job_id__c, 
                notificationStatus__c, startTime__c, NextRunTime__c, status__c  
                FROM Job_execution__c 
                WHERE endTime__c >= :earlier AND Job_id__c = :jl.Id AND notificationStatus__c = 'NotSent'];
            
            if(jeList != null && jeList.size() > 0){
              //  System.debug('checkTimeAndSendMail ::: 2 ');
                
                // Find startDate__c and endDate__c from Job_log_distribution__c
                List<Job_log_distribution__c> jldList = [SELECT Email_alias_id__c, emailList__c, 
                                               startDate__c, endDate__c, Job_id__c, 
                                               msgTypes__c, ReportEmail__c
                                               FROM Job_log_distribution__c 
                                               WHERE Job_id__c = :jl.Id ];
                if(jldList != null && jldList.size() > 0){
                //    System.debug('checkTimeAndSendMail ::: 3 ');
                    for (Job_log_distribution__c jld : jldList){
                        
                        // Notification will be sent only in following condition
                        if((sendMailNow && jld.ReportEmail__c.equalsIgnoreCase('WhenFinish'))
                           || (!sendMailNow && jld.ReportEmail__c.equalsIgnoreCase('AsScheduled'))){
                               
                               String Email_alias_id = ''; 
                               if(jld.Email_alias_id__c != null){
                                   Email_alias_id = jld.Email_alias_id__c;
                               }
                               
                               String emailList = jld.emailList__c;
                           //    String errEmailList = jld.Error_emailList__c;
                               Date startDate = jld.startDate__c;
                               Date endDate = jld.endDate__c;
                               
                               // if current date is same of after start date and end date (if any) 
                               // is later than today 
                               // Find emailList__c and Email_alias_id__c (if any)for email to send.
                               // send email
                               Boolean sendmail = false;
                               if(startDate <= Date.today()){
                                   if(endDate == null){
                                       sendmail = true;    
                                   } else if(endDate >= Date.today()){
                                       sendmail = true;
                                   } 
                               }	// End if(startDate <= Date.today())
                               
                               if(sendmail){
                                   
                                   List<Job_execution__c> jeListSent = new List<Job_execution__c>();
                                   
                                    jobErr = false;
                                    recordErr = false;
                                   
                                   for (Job_execution__c je : jeList){
                                       
                                       // -- Check the notification status (notificationStatus__c)
                                       if(je.notificationStatus__c.equalsIgnoreCase('NotSent')){
                                           // ---- if the value is "Not sent"
                                           
                                           // ------ get the log message for sending email.
                                           // Query Log_message with jobExec
                                           String msgLog = '';
                                           String summaryLog = '';
                                           for (Job_log__c jlog : [SELECT Job_execution_id__c, msgLog__c, 
												msgTypeName__c , timeStamp__c 
												from Job_log__c where Job_execution_id__c =:je.Id
												ORDER BY timeStamp__c]) {
                                                                       
												if(jlog != null){
                                                                    
                                                    // check if the message type exists in distribution record
                                                    if( jld.msgTypes__c.containsIgnoreCase(jLog.msgTypeName__c.trim())){
                                                        String msgTypeNameFull = msgTypeMap.get(jLog.msgTypeName__c.trim().toLowerCase());
                                                        
                                                        if (msgTypeNameFull.equalsIgnoreCase('Summary')){
                                                            summaryLog = summaryLog + jLog.timeStamp__c 
                                                                + ' : ' + jLog.msgLog__c + '\n';    
                                                        } else{
                                                            if(msgTypeNameFull.equalsIgnoreCase('Error')){
                                                                recordErr = true;    
                                                            }
                                                            if(msgTypeNameFull.equalsIgnoreCase('Next run error')){
                                                                scheduleErr = true;    
                                                            }
                                                            msgLog = msgLog + msgTypeNameFull + ' : ' + jLog.timeStamp__c 
                                                                + ' : ' + jLog.msgLog__c + '\n';
                                                        }
                                                        
                                                    }	// if( jld.msgTypes__c.containsIgnoreCase(jLog.msgTypeName__c.trim()))                            
                                                    
                                                }	// End  if(jlog != null)   
                                                }	// End for
                                           
                                           if(!je.status__c.equalsIgnoreCase('Successful')){
                                               jobErr = true;    
                                           }
                                           
                                           String errInfo = '';
                                           if (scheduleErr){
                                               errInfo = errInfo + 'ERROR in Next Run. ';    
                                           }
                                           if (jobErr){
                                               errInfo = errInfo + 'ERROR in Job Run. ';    
                                           }
                                           if (recordErr){
                                               errInfo = errInfo + 'ERROR in one or more Records. ';    
                                           }
                                           
                                           //   System.debug('checkTimeAndSendMail ::: 6 ');
                                           System.debug('msgLog.length() :::  ' + msgLog.length());
                                           
                                           if(msgLog.length() > 0){  
                                               System.debug('Send EMAIL');
                                               String msg_info = 'Job : ' + jl.Name + '\n'
                                                   + 'Start time : ' + je.startTime__c + '\n'
                                                   + 'End time : ' + je.endTime__c + '\n'
                                                   + 'Job run status : ' + je.status__c + '\n\n'
                                                   + 'Next Scheduled Run : ' + je.NextRunTime__c + '\n\n'
                                                   + 'Error information : ' + errInfo + '\n\n'
                                                   ;
                                               
                                               if (summaryLog.length() > 0){
                                                   summaryLog = 'Job Summary: \n' + summaryLog; 
                                               }
                                               mailBody = mailBody + msg_info + summaryLog + '\n Log detail: \n' + msgLog + '\n\n';
                                               
                                               // ------ make the notificationStatus__c value to "Sent"
                                               if(!scheduleErr){
                                                   System.debug('Set execution to SENT');
                                                   je.notificationStatus__c = 'Sent';
                                                   jeListSent.add(je);
                                                   
                                               }
                                               
                                           }	// End if(msgLog.length() > 0)	
                                       }	// End if(je.notificationStatus__c.equalsIgnoreCase('NotSent'))
                                       
                                   }	// End for (Job_execution__c je : jeList)
                                   
                                   // ------ send the email with all these messages.
                                   if(mailBody.length() > 0){
                                       Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                       
                                       List<String> lstEmail = emailList.split(',');
                                       
                                       message.setToAddresses(lstEmail);
                                       
                                       message.optOutPolicy = 'FILTER';
                                       
                                       String mailSub = 'Job run result of job ' + jl.Name 
                                           + ' for last ' + noOfMinutesToDuration(interval_minutes) + ' minutes';
                                       if(scheduleErr){
                                           mailSub = ' [ERROR in Next Run] ' + mailSub ;	
                                       }
                                       mailSub = mailSub + '.';
                                       message.subject = mailSub;
                                       message.plainTextBody = mailBody;
                                       Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                                       Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                                       
                                       if (results[0].success) {
                                           System.debug('The email was sent successfully.');
                                       } else {
                                           System.debug('The email failed to send: ' + results[0].errors[0].message);
                                       }
                                       
                                   }	// End if(mailBody.length() > 0)
                                   
                                   // ------ Update the notificationStatus__c value to "Sent"
                                   if(jeListSent.size() > 0){
                                       update jeListSent;
                                   }
                                   
                               }	// End  if(sendmail)	
                               
                        }	// if((sendMailNow && jld.ReportEmail__c.equalsIgnoreCase('WhenFinish'))
                            // || (!sendMailNow && jld.ReportEmail__c.equalsIgnoreCase('AsScheduled')))
   
                    }	//  for (Job_log_distribution__c jld : jldList)
                }
                
            }	// End if(jeList != null && jeList.size() > 0)
            
        } catch(Exception e){
        	System.debug('The email notification error: ' + e.getMessage() + ' at line : ' + e.getLineNumber());    
        }

    }	// End checkTimeAndSendMail()
    
    public String noOfMinutesToDuration(Integer total_mnts){
    	String duration = '';        
        Integer totalSec = total_mnts * 60;
        Double h = (totalSec/3600); 
        Double m = (totalSec -(3600*h))/60;
        Double s = (totalSec -(3600*h)-(m*60));
        
        duration = h > 1 ? duration + h + ' hours ' : duration + h + ' hour ';
        duration = m > 1 ? duration + m + ' minutes ' : duration + m + ' minute ';
        duration = s > 1 ? duration + s + ' seconds ' : duration + s + ' second ';
        
        System.debug('h::' + h + ' m :: ' + m + 's :: ' + s + ' DURATION :: ' + duration);
        return duration;
    }
    
    public Map<String, String> setMsgTypeMap(){
        Map<String, String> m = new Map<String, String>(); // Define a new map

        List<Message_type__c> mtList = [SELECT Name, msgType__c FROM Message_type__c];
        if(mtList != null && mtList.size() > 0){
            for (Message_type__c mt : mtList){
                m.put(mt.msgType__c, mt.Name); 
            }
        }
        
		return(m);  
    }
    
}