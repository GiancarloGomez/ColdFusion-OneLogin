/**
* @output       false
* @accessors    true
*/
component{

    /**
    * @type struct
    * @hint Contains the attributes returned in a valid response
    */
    property name="attributes";

    function init(){
        return this;
    }

    /**
    * @hint         Handles building and validating a SAML response into a ColdFusion Struct
    * @xmlResponse  xml
    * @return       Struct
    */
    public function buildPacket(required xml xmlResponse){

        // Build the Packet we use to validate against
        var packet = {
            "issuer"        : getSingleValue(arguments.xmlResponse,"//*[local-name()='Issuer']").XMLText,
            "conditions"    : getSingleValue(arguments.xmlResponse,"//*[local-name()='Conditions']").XMLAttributes
        };
        // Eastern Standard Time Offset
        var ESTtargetZoneOffset = -5;
        // Get Server Timezon Info
        var TimeZoneInfo        = GetTimeZoneInfo();
        // If Daylight Savings Time
        if ( TimeZoneInfo.isDSTOn ) {
            ESTtargetZoneOffset = ESTtargetZoneOffset  + 1;
        }
        // Translate times
        packet.conditions["now"]            = DateAdd("s",40,now()); // 250 server seems to be 40 seconds behind
        packet.conditions["NotBefore"]      = DateConvertISO8601(packet.conditions.NotBefore, ESTtargetZoneOffset);
        packet.conditions["NotOnOrAfter"]   = DateConvertISO8601(packet.conditions.NotOnOrAfter, ESTtargetZoneOffset);
        // set the packets attributes into struct of instance
        setAttributes(buildAttributes(arguments.xmlResponse));
        // validate the packet
        return verifyPacket(packet);
    }

    /**
    * @hint         Validates the Date Values passed in the SAML Response to Local Time
    * @xmlResponse  xml
    * @return       Struct
    */
    private function verifyPacket(required struct samlPacket){

        arguments.samlPacket["verified"] = {
            "NotBefore"     : DateCompare(arguments.samlPacket.conditions.now, arguments.samlPacket.conditions.NotBefore,"s") == 1 ? true : false,
            "NotOnOrAfter"  : DateCompare(arguments.samlPacket.conditions.now, arguments.samlPacket.conditions.NotOnOrAfter,"s") >= 0 ? false : true
        };

        return arguments.samlPacket;
    }

    /**
    * @hint         Gets the AttributeStatement from the XML Response and translates to a ColdFusion Struct
    * @xmlResponse  xml
    * @return       Struct
    */
    private struct function buildAttributes(required xml xmlResponse){
        // setup return struct
        local.attr = {};
        try{
            // read the attributes
            local.attributes = getSingleValue(arguments.xmlResponse,"//*[local-name()='AttributeStatement']").xmlChildren;
            // loop thru results and build a struct with our values
            for (attribute in attributes){
                // if period in attribute name break into own child struct
                if (find(".",attribute.xmlAttributes.name)){
                    attr[getToken(attribute.xmlAttributes.name,1,".")][getToken(attribute.xmlAttributes.name,2,".")] = attribute.xmlChildren[1].xmlText;
                } else {
                    attr[attribute.xmlAttributes.name] = attribute.xmlChildren[1].xmlText;
                }
            }
        }
        catch (Any e) {/* Put any logic here if you want to capture*/}
        // return struct
        return local.attr;
    }

    /**
    * @hint                 Convert a date in ISO 8601 format to an ODBC datetime.
    * @ISO8601dateString    string  The ISO8601 date string. (Required)
    * @targetZoneOffset     numeric The timezone offset. (Required)
    * @return               Datetime
    * @author               David Satz (david_satz@hyperion.com)
    */
    private function DateConvertISO8601(required string ISO8601dateString, numeric targetZoneOffset = 0) {
        var rawDatetime = left(ISO8601dateString,10) & " " & mid(ISO8601dateString,12,8);
        // adjust offset based on offset given in date string
        if (uCase(mid(ISO8601dateString,20,1)) neq "Z")
            targetZoneOffset = targetZoneOffset -  val(mid(ISO8601dateString,20,3)) ;
        return DateAdd("h", targetZoneOffset, CreateODBCDateTime(rawDatetime));
    }

    /**
    * @hint         Handles retrieving a value from an XML response - XML search Wrapper
    * @xmlResponse  xml
    * @xpath        string
    * @reqAttrib    boolean
    * @return       string
    * @author       http://blog.tagworldwide.com/?p=19
    */
    private function getSingleValue(required xml xmlResponse, required string xpath, boolean reqAttrib = true){
        var values= XmlSearch(arguments.xmlResponse,arguments.xpath);
        if (arguments.reqAttrib){
            if (!ArrayLen(values))
                throw(type:"saml" message:"Error: No value for: #xpath#");
        }
        if (isArray(values))
            return values[1];
        else
            return values;
    }
}