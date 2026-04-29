<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DemoProject.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Login</title>
    <style>
        body { font-family: Arial; margin: 30px; background-color: #f0f4f8; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .container { width: 460px; padding: 30px; border: 1px solid #999; border-radius: 8px; background-color: #ffffff; }
        h2 { color: #2c3e50; margin-bottom: 20px; }
        .row { margin-bottom: 14px; }
        .label { display: inline-block; width: 150px; font-weight: bold; }
        .result { margin-top: 20px; padding: 12px; background-color: #f4f8ff; border: 1px solid #aac; }
        .error { color: red; }
        .link-row { margin-top: 16px; font-size: 13px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2>User Login</h2>

            <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                ForeColor="Red" CssClass="error"
                HeaderText="Please correct the following errors:" />

            <div class="row">
                <span class="label">Username:</span>
                <asp:TextBox ID="txtUsername" runat="server" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                    ControlToValidate="txtUsername" ErrorMessage="Username is required." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">Password:</span>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword" ErrorMessage="Password is required." ForeColor="Red" />
            </div>

            <div class="row">
                <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" CausesValidation="false" />
            </div>

            <div class="result">
                <asp:Label ID="lblResult" runat="server"></asp:Label>
            </div>

            <div class="link-row">
                No account yet? <a href="Registration.aspx">Register here</a>
            </div>
        </div>
    </form>
</body>
</html>
