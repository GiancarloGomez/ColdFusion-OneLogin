<cfscript>
    if (cgi.request_method == "POST"){
        request.company.setCompanyName(form.companyName);
        request.company.setConsumeUrl(form.consumeUrl);
        request.company.setIssuerUrl(form.issuerUrl);
        request.company.setIssuerID(form.issuerID);
        request.company.setCertificate(form.certificate);
        transaction { entitySave(request.company); }
        session.saved = true;
        sleep(250);
        location(cgi.http_referer,false);
    }
</cfscript>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SAML Login - One Login</title>
    <link rel="shortcut icon" type="image/png" href="/favicon.png">
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="//fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700">
    <link rel="stylesheet" href="/includes/css/theme.css">
</head>
<body>
    <div class="container">
        <cfoutput>
        <cfif structKeyExists(session,"saved")>
            <div class="alert alert-success">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                Changes saved!
            </div>
            <cfset structDelete(session,"saved") />
        </cfif>
        <cfif request.company.isReady()>
            <div class="well well-small text-center text-success">
                <span class="glyphicon glyphicon-ok"></span> Application is ready to use, <a href="/">click here</a> to go to test request.
            </div>
        </cfif>
        <form role="form" method="post" class="simple-validation">
            <div class="form-group">
                <label for="companyName">Company Name</label>
                <input type="text" class="form-control" id="companyName" name="companyName" placeholder="Enter Company Name" value="#encodeForHTML(request.company.getCompanyName())#">
                <p class="help-block">
                    This is not required for SAML, only here for example if you were to add to multi-tenant app, possibly tie into Company table.
                </p>
            </div>
            <div class="form-group required">
                <label for="consumeUrl">Consume URL</label>
                <input type="text" class="form-control" id="consumeUrl" name="consumeUrl" placeholder="Enter Consume URL (ie: #request.siteURL#consume/)" value="#encodeForHTML(request.company.getConsumeUrl())#">
                <p class="help-block">
                    The URL of the consume file for this app. The SAML Response will be posted to this URL
                </p>
            </div>
            <div class="form-group required">
                <label for="issuerUrl">Issuer</label>
                <input type="text" class="form-control" id="issuerUrl" name="issuerUrl" placeholder="Enter Issuer (ie: #request.siteURL#)" value="#encodeForHTML(request.company.getIssuerUrl())#">
                <p class="help-block">
                    The issuer of the authentication request. This would usually be the URL of the issuing web application.
                </p>
            </div>
            <div class="form-group required">
                <label for="issuerID">Issuer ID</label>
                <input type="text" class="form-control" id="issuerID" name="issuerID" placeholder="Enter Issuer ID" value="#encodeForHTML(request.company.getIssuerID())#">
                <p class="help-block">
                    The ID for this company at the Identity Provider, this value is used to post to the proper URL. You can find
                    this value after creating the App in OneLogin and clicking on <strong class="text-info">"Single Sign-On"</strong> tab. There will be 3 URLs in that page and
                    each ends with a numeric value which is your ID. (ie:https://app.onelogin.com/saml/metadata/<strong class="text-success">382730</strong>)
                </p>
            </div>
            <div class="form-group required">
                <label for="certificate">X.509 Certificate</label>
                <textarea class="form-control" id="certificate" name="certificate" rows="10" placeholder="Enter Certificate Text">#encodeForHTML(request.company.getCertificate())#</textarea>
                <p class="help-block">
                    Enter the Certificate Content used for this App on OneLogin. This can be found under the <strong class="text-info">"Single Sign-On"</strong> tab. Look for the
                    <strong class="text-info">"X.509 Certificate"</strong> and click on <strong class="text-info">"View Details"</strong>. On the following page you will see
                    a text box with the value to enter here.
                </p>
            </div>
            <span class="frmPrc" style="display:none;">
                <button class="btn btn-default" type="button" disabled="disabled">
                    <i class="fa fa-spin fa-spinner"></i> Saving ...
                </button>
            </span>
            <span class="frmBtn">
                <button type="submit" class="btn btn-primary">Save Settings</button>
            </span>
        </form>
        </cfoutput>
    </div>
    <script src="//code.jquery.com/jquery-1.11.1.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
    <script src="/includes/js/scripts.js"></script>
    <script src="/includes/js/validation.min.js"></script>
</body>
</html>