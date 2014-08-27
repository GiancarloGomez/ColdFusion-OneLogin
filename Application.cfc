/**
*   @output     false
*/
component{

    this.name               = "OneLogin_SAML_1.0";
    this.sessionmanagement  = true;
    this.sessiontimeout     = createTimeSpan(0,7,0,0);
    this.datasource         = "onelogin_saml_example";

    // java settings
    this.javaSettings       = {
        LoadPaths       : ["/bin"],
        reloadOnChange  : true,
        watchInterval   : 60
    };

    // this is only here for this POC and should not be used in production
    this.enableOrm = true;
    try{ CreateObject("java","coldfusion.server.ServiceFactory").DatasourceService.verifyDataSource(this.datasource); }
    catch(Any e){ this.enableOrm = false; }

    // orm settings
    this.ormEnabled     = this.enableOrm;
    this.ormSettings    = {
        automanageSession       : false,
        cfclocation             : "/model/orm/",
        dbcreate                : "update",
        flushatrequestend       : false,
        logSQL                  : false,
        useDBForMapping         : false
    };

    public boolean function onRequestStart(){
        // pass ormEnabled state to request
        request.appIsReady  = this.ormEnabled;
        request.siteURL     = "http" & (cgi.server_port_secure ? "s" : "") & "://" & cgi.server_name & "/";

        if (structKeyExists(url,"reload")){
            ormReload();
            location("./",false);
        }

        // check if company is setup and configured
        if (request.appIsReady){
            // get company
            request.company = entityLoadByPK("Company",1);
            // create company if nto already created
            if (isNull(request.company)){
                request.company = entityNew("Company");
                transaction { entitySave(request.company); }
            }
            // relocate to admin if not completely setup
            if (!findNoCase("admin",cgi.script_name) && !request.company.isReady())
                location("/admin/",false);
        }

        return true;
    }

}