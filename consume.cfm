<cfscript>
    // user account specific settings. Import the certificate here
    accountSettings = createObject("java","com.onelogin.AccountSettings");
    accountSettings.setCertificate(reReplace(request.company.getCertificate(),"-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----","","all"));

    // Generate an AuthRequest and send it to the identity provider
    samlResponse = createObject("java","com.onelogin.saml.Response").init(accountSettings);

    // samlResponse.loadXmlFromBase64(trim(form.SAMLResponse));

    // instead of using the loadXmlFromBase64 as it throws an error, use the coded
    // directly to decode the  SAMLResponse and then pass to loadXml
    b64Coded    = createObject("java","org.apache.commons.codec.binary.Base64");
    xmlString   = toString(b64Coded.decode(trim(form.SAMLResponse)));

    // now load the XML
    samlResponse.loadXml(xmlString);

    validResponse = samlResponse.isValid();

    // once packet is good we need to verify that is within the allowed time as the library only validates the
    // request came from a valid IdP
    if (validResponse){
        saml            = new services.saml();
        verify          = saml.buildPacket(xmlString);
        validResponse   = verify.verified.NotBefore && verify.verified.notOnOrAfter;
    }
</cfscript>

<!--- DEBUG PURPOSES --->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SAML Login - One Login</title>
    <link rel="shortcut icon" type="image/png" href="/favicon.png">
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="//fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700">
    <link rel="stylesheet" href="//fonts.googleapis.com/css?family=Source+Code+Pro">
    <link rel="stylesheet" href="/includes/css/theme.css">
</head>
<body>
    <cfoutput>
    <div class="container">
        <div class="row">
            <div class="col-xs-10">
                <cfif validResponse>
                    <div class="alert alert-success alert-block">
                        This is a good response, at this point you would simply validate the email we receive back as a user in the
                        database. If the user is not in the database you can opt to crawl the values returned in teh XML and create
                        a user on the fly.
                        <br /><br />
                        This request is valid until <strong>#dateTimeFormat(verify.conditions.notOnOrAfter,"mm/dd/yyyy hh:nn aa")# EST</strong>, since we are
                        still in a <strong>POST</strong> state, you can just hit the refresh button to retry after the time specified to see
                        the request invalidate.
                    </div>
                <cfelse>
                    <div class="alert alert-danger alert-block">
                        This is not a valid response, review below to see why it failed.
                    </div>
                </cfif>
            </div>
            <div class="col-xs-2">
                <a href="/" class="btn btn-default">Return to Initiator Page</a>
            </div>
        </div>
        <table class="table">
            <colgroup>
                <col width="280">
            </colgroup>
            <tr>
                <th>Is response valid (certificate check)</th>
                <td>
                    <cfif samlResponse.isValid()>
                        <strong class="text-success"><span class="glyphicon glyphicon-ok"></span> Passed</strong>
                    <cfelse>
                        <strong class="text-danger"><span class="glyphicon glyphicon-remove"></span> Failed</strong>
                    </cfif>
                </td>
            </tr>
            <cfif samlResponse.isValid()>
                <tr>
                    <th>The user to check on our end is</th>
                    <td>#samlResponse.getNameId()#</td>
                </tr>
                <tr>
                    <th>The conditions of this request are</th>
                    <td>
                        <dl>
                            <dt>Not Before</dt>
                            <dd>
                                #dateTimeFormat(verify.conditions.notBefore,"mm/dd/yyyy hh:nn aa")# EST
                                <cfif verify.verified.NotBefore>
                                    <strong class="text-success"><span class="glyphicon glyphicon-ok"></span> Passed</strong>
                                <cfelse>
                                    <strong class="text-danger"><span class="glyphicon glyphicon-remove"></span> Failed</strong>
                                </cfif>
                            </dd>
                            <dt>Not On Or After</dt>
                            <dd>
                                #dateTimeFormat(verify.conditions.notOnOrAfter,"mm/dd/yyyy hh:nn aa")# EST
                                <cfif verify.verified.notOnOrAfter>
                                    <strong class="text-success"><span class="glyphicon glyphicon-ok"></span> Passed</strong>
                                <cfelse>
                                    <strong class="text-danger"><span class="glyphicon glyphicon-remove"></span> Failed</strong>
                                </cfif>
                            </dd>
                        </dl>
                    </td>
                </tr>
                <tr>
                    <th>The attributes of this user returned are</th>
                    <td><cfdump var="#saml.getAttributes()#" /></td>
                </tr>
            </cfif>
        </table>
        <div class="well">
            <pre>#encodeForHTML(reReplace(xmlString,"(<saml|<ds)","\n\1","ALL"))#</pre>
        </div>
    </div>
    </cfoutput>
</body>
</html>