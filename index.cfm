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
        <!--- APP IS READY - SHOW FORM --->
        <cfif request.appIsReady>
            <form action="/post/" class="form-signin text-center simple-validation" role="form" method="post">
                <h2 class="form-signin-heading text-info">SAML Login Sample</h2>
                <p>
                    Click below to login using OneLogin.
                </p>
                <span class="frmPrc" style="display:none;">
                    <button class="btn btn-lg btn-default btn-block" type="button" disabled="disabled" style="line-height:35px;">
                        <i class="fa fa-spin fa-spinner"></i> PROCESSING
                    </button>
                </span>
                <span class="frmBtn">
                    <button class="btn btn-lg btn-default btn-block" type="submit">
                        <img src="/includes/img/logo-onelogin.png" />
                    </button>
                </span>
                <p>
                    <a href="/admin/">Click here to edit the company settings</a>
                    <br /><br />
                    <a href="http://youtu.be/VxS86G4hD-k" class="text-danger" target="_blank">Click here to view demo video</a>
                </p>
            </form>
        <cfelse>
        <!--- SHOW SET UP INFO --->
            <div class="well lead setup-instructions">
                <h1>SAML Login Sample Setup Required</h1>
                <p>
                    Welcome to the OneLogin SAML Sample Application. To begin you must create a datasource in your ColdFusion Administrator
                    labeled <strong>"onelogin_saml_example"</strong>. Once complete, reload this page and the required table will be generated and you
                    will be directed to the configuration page.
                </p>
            </div>
        </cfif>
    </div>
    <script src="//code.jquery.com/jquery-1.11.1.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
    <script src="/includes/js/scripts.js"></script>
    <script src="/includes/js/validation.min.js"></script>
</body>
</html>