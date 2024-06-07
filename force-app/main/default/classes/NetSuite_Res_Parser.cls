public class NetSuite_Res_Parser {
    public class LineItems_NetsuiteIds {
        public String sap_item_number;
        public String NetsuiteId;
    }
    public String SalesOrder_NetsuiteId;
    public List<LineItems_NetsuiteIds> LineItems_NetsuiteIds;
    public static NetSuite_Res_Parser parse(String json) {
        return (NetSuite_Res_Parser) System.JSON.deserialize(json, NetSuite_Res_Parser.class);
    }
}