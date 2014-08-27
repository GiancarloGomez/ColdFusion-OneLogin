<cfscript>
  try{

    // used to encode string - chose to use Java version just in case CF did not encode correctly
    // encodeForURL appears to work but to keep the same as the samples from OneLogin I will use the Java reference
    urlEncoder = createObject("java","java.net.URLEncoder");

    // the appSettings object contain application specific settings used by the SAML library
    appSettings = createObject("java","com.onelogin.AppSettings");

    // set the URL of the consume file for this app. The SAML Response will be posted to this URL
    appSettings.setAssertionConsumerServiceUrl(request.company.getConsumeUrl());

    // set the issuer of the authentication request. This would usually be the URL of the issuing web application
    appSettings.setIssuer(request.company.getIssuerUrl());

    // the accSettings object contains settings specific to the users account.
    accSettings = createObject("java","com.onelogin.AccountSettings");

    // The URL at the Identity Provider where to the authentication request should be sent
    accSettings.setIdpSsoTargetUrl("https://app.onelogin.com/saml/signon/" & request.company.getIssuerID());

    // Generate an AuthRequest and send it to the identity provider
    authReq = createObject("java","com.onelogin.saml.AuthRequest").init(appSettings, accSettings);

    // now send to one login
    location ( accSettings.getIdp_sso_target_url() & "?SAMLRequest=" & authReq.getRidOfCRLF(urlEncoder.encode(authReq.getRequest(authReq.base64),"UTF-8")), false);
  }
catch(Any e){
    writeDump(e);
}
</cfscript>