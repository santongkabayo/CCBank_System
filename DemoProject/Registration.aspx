<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Registration.aspx.cs" Inherits="DemoProject.Registration" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Registration</title>
    <style>
        body { font-family: Arial; margin: 30px; background-color: #f0f4f8; }
        .container { width: 520px; padding: 30px; border: 1px solid #999; border-radius: 8px; background-color: #ffffff; }
        h2 { color: #2c3e50; margin-bottom: 20px; }
        .row { margin-bottom: 14px; }
        .label { display: inline-block; width: 170px; font-weight: bold; }
        .result { margin-top: 20px; padding: 12px; background-color: #f4f8ff; border: 1px solid #aac; }
        .error { color: red; }
        .link-row { margin-top: 16px; font-size: 13px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2>User Registration</h2>

            <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                ForeColor="Red" CssClass="error"
                HeaderText="Please correct the following errors:" />

            <div class="row">
                <span class="label">Username:</span>
                <asp:TextBox ID="txtUsername" runat="server" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                    ControlToValidate="txtUsername" ErrorMessage="Username is required." ForeColor="Red" />
                <asp:RegularExpressionValidator ID="revUsername" runat="server"
                    ControlToValidate="txtUsername"
                    ValidationExpression="^[a-zA-Z0-9_]{4,20}$"
                    ErrorMessage="Username must be 4-20 letters, numbers, or underscore." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">Lastname:</span>
                <asp:TextBox ID="txtLastname" runat="server" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvLastname" runat="server"
                    ControlToValidate="txtLastname" ErrorMessage="Lastname is required." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">Firstname:</span>
                <asp:TextBox ID="txtFirstname" runat="server" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvFirstname" runat="server"
                    ControlToValidate="txtFirstname" ErrorMessage="Firstname is required." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">Email:</span>
                <asp:TextBox ID="txtEmail" runat="server" MaxLength="100"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                    ControlToValidate="txtEmail" ErrorMessage="Email is required." ForeColor="Red" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Please enter a valid email address." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">Password:</span>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword" ErrorMessage="Password is required." ForeColor="Red" />
                <asp:RegularExpressionValidator ID="revPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ValidationExpression="^.{6,}$"
                    ErrorMessage="Password must be at least 6 characters." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">Confirm Password:</span>
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                    ControlToValidate="txtConfirmPassword" ErrorMessage="Please confirm your password." ForeColor="Red" />
                <asp:CompareValidator ID="cvPassword" runat="server"
                    ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword"
                    ErrorMessage="Passwords do not match." ForeColor="Red" />
            </div>

            <div class="row">
                <asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" CausesValidation="false" />
            </div>

            <div class="result">
                <asp:Label ID="lblResult" runat="server"></asp:Label>
            </div>

            <div class="link-row">
                Already have an account? <a href="Login.aspx">Login here</a>
            </div>
        </div>
    </form>
</body>
</html>
