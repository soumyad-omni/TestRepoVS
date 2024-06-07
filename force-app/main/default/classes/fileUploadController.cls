public with sharing class fileUploadController {
    

    @AuraEnabled
    public static String uploadFile(String tagType, String base64, String filename, String recordId) {
        system.debug('tagType'+tagType);
        ContentVersion cv = createContentVersion(base64, filename, tagType);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }

    private static ContentVersion createContentVersion(String base64, String filename, String tagType) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.Tag__c = tagType;
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
    }

    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
          //ContentDocLinkTriggerHandler.TriggerDisabled = true;
          insert cdl;
          return cdl;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
    }

    @AuraEnabled
    public static list<Attachment> fileTagCheckFromQAP(String recordId) {
      system.debug('recordId ' +recordId);
      map<id,echosign_dev1__SIGN_Agreement__c> aggMap = new map<id,echosign_dev1__SIGN_Agreement__c>([select id FROM echosign_dev1__SIGN_Agreement__c WHERE Quote_Approval__c =:recordId]);
      list<Attachment> attList = new list<Attachment>();
      if(aggMap.size()>0){
        map<id,Attachment> att = new map<id,Attachment>([SELECT id, name, ParentId, CreatedById  FROM Attachment WHERE ParentId =:aggMap.keyset()]);
        if(att.size()>0){
          list<Agreement_Tag__c> aggTagList = [select id, tag__c, Parent_Id__c from Agreement_Tag__c where Parent_Id__c =:att.keyset()];
          list<string> hasTag = new list<string>();
          if(aggTagList.size()>0){
            for(Agreement_Tag__c ata:aggTagList){
              hasTag.add(ata.Parent_Id__c);
            }            
          }
          
          for(Attachment atta:att.values()){
            if(!hasTag.contains(atta.id)){
              if(UserInfo.getUserId() == atta.CreatedById){
                attList.add(atta);
              }              
            }              
          }
          
        }
        
      }
      return attList;
    }

    @AuraEnabled
    public static boolean tagInsert(list<Agreement_Tag__c> atgList){
      boolean flag = false;
      system.debug(atgList.size());
      if(atgList.size()>0){
        insert atgList;
        flag = true;
      }
      return flag;
    }

    @AuraEnabled(cacheable=true)
    public static List<fileWrapper> getFiles(Id recordId) {

      List<fileWrapper> fileList = new List<fileWrapper>();

      list<ContentDocumentLink> cdList = [SELECT Id, ContentDocumentId, ContentDocument.Title, SystemModstamp
      FROM ContentDocumentLink WHERE LinkedEntityId = :recordId order by SystemModstamp desc];

      map<id,ContentDocumentLink> cdMap = new map<id,ContentDocumentLink>();

      for(ContentDocumentLink cd:cdList){
        cdMap.put(cd.ContentDocumentId,cd);
      }

      list<ContentVersion> cvList = [SELECT ContentSize , ContentDocumentId, FileType, Tag__c, CreatedDate  
      FROM ContentVersion WHERE ContentDocumentId =:cdMap.keyset() order by CreatedDate desc];

      for(ContentVersion cv:cvList){
        ContentDocumentLink cd = cdMap.get(cv.ContentDocumentId);
        datetime createdate = cd.SystemModstamp;
        String formattedDateTime = createdate.format('MMMM dd, yyyy');

        Integer fileSizeInBytes = cv.ContentSize; 
        string fileSize = '0B';
        if(fileSizeInBytes >= 1024 && fileSizeInBytes < (1024*1024)){
            fileSize = string.valueOf(fileSizeInBytes/1024) + 'KB';
        }else if(fileSizeInBytes >= (1024*1024)){
            fileSize = string.valueOf(fileSizeInBytes/(1024*1024)) + 'MB';
        }else{
            fileSize = string.valueOf(fileSizeInBytes) + 'B';
        }
        fileList.add( new fileWrapper(cd.ContentDocument.Title,cd.ContentDocumentId,cv.Tag__c,fileSize,formattedDateTime,cv.FileType.toLowerCase()));
      }

      map<id,attachment> attList = new map<id,attachment>([SELECT Id,Name, CreatedDate FROM attachment 
      where ParentId =:recordId order by CreatedDate desc]);

      list<Agreement_Tag__c> relatedTag = [select Parent_Id__c, Tag__c from Agreement_Tag__c where Parent_Id__c =:attList.keySet()];
      map<id,Agreement_Tag__c> tamMap = new map<id,Agreement_Tag__c>();
      for(Agreement_Tag__c tg:relatedTag){
        tamMap.put(tg.Parent_Id__c,tg);
      }

      for(attachment att:attList.values()){
        datetime createdate = att.CreatedDate;
        String formattedDateTime = createdate.format('MMMM dd, yyyy');
        
        if(tamMap.containskey(att.Id)){
          Agreement_Tag__c tg = tamMap.get(att.Id);
          fileList.add( new fileWrapper(att.Name,att.Id,tg.Tag__c,'Attachment',formattedDateTime,' '));
        }else{
          fileList.add( new fileWrapper(att.Name,att.Id,' ','Attachment',formattedDateTime,' '));
        }
        
      }


      return fileList;
    }

    public class fileWrapper {
      @AuraEnabled
      public string fname { get; set; }
      @AuraEnabled
      public id fid { get; set; }
      @AuraEnabled
      public string tag { get; set; }
      @AuraEnabled
      public string size { get; set; }
      @AuraEnabled
      public string cdate { get; set; }
      @AuraEnabled
      public string ctype { get; set; }
      
      public fileWrapper(string fname, id fid, string tag, string size, string cdate, string ctype) {
          this.fname = fname;
          this.fid = fid;
          this.tag = tag;
          this.size = size;
          this.cdate = cdate;
          this.ctype = ctype;
      }
  }
}