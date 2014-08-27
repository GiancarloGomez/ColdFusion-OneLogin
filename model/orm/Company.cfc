/**
*   @output         false
*   @persistent     true
*/
component
{
    property name="id"                  fieldtype="id"      generator="native";
    property name="companyName"         ormtype="string"    length="150";
    property name="consumeUrl"          ormtype="string"    length="255";
    property name="issuerUrl"           ormtype="string"    length="150";
    property name="issuerID"            ormtype="string"    length="50";
    property name="certificate"         ormtype="string"    length="2000";
    property name="createdOn"           ormtype="timestamp";
    property name="updatedOn"           ormtype="timestamp";

    public void function init(){
        setCreatedOn(getHttpTimeString());
    }

    public void function preUpdate(struct oldData ){
        setUpdatedOn(getHttpTimeString());
    }

    public boolean function isReady(){
        // return tru if all fields are set
        return  len(getConsumeUrl()) &&
                len(getIssuerUrl()) &&
                len(getIssuerID()) &&
                len(getCertificate());
    }
}