public class fromJSON{
    public cls_SAPResponse SAPResponse;
    public class cls_SAPResponse {
        public cls_item[] item;
    }
    public class cls_item {
        public String MessageType;  //E
        public String MessageId;    //CRM_ORGMAN
        //public String Number;   //038
        public String Message;  //Enter an organizational unit (Sales)
        public String LogMessageNo; //000000
        public String ROW;  //0
    }
    public static fromJSON parse(String json){
        return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
    }

  
}