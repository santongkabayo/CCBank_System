<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="DemoProject.ChangePassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Change Password</title>
    <style>
        body { font-family: Arial; margin: 0px; padding: 0; min-height: 100vh; background: linear-gradient(135deg, ) }
        .container { width: 520px; padding: 30px; border: 1px solid #999; border-radius: 8px; background-color: #ffffff; }
        h2 { color: #2c3e50; margin-bottom: 20px; }
        .row { margin-bottom: 14px; }
        .label { display: inline-block; width: 180px; font-weight: bold; }
        .result { margin-top: 20px; padding: 12px; background-color: #f4f8ff; border: 1px solid #aac; }
        .error { color: red; }
        .link-row { margin-top: 16px; font-size: 13px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2>Change Password</h2>

            <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                ForeColor="Red" CssClass="error"
                HeaderText="Please correct the following errors:" />

            <div class="row">
                <span class="label">Account No:</span>
                <asp:Label ID="lblAccountNo" runat="server" Font-Bold="true"></asp:Label>
            </div>

            <div class="row">
                <span class="label">Current Password:</span>
                <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server"
                    ControlToValidate="txtCurrentPassword" ErrorMessage="Current Password is required." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">New Password:</span>
                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server"
                    ControlToValidate="txtNewPassword" ErrorMessage="New Password is required." ForeColor="Red" />
                <asp:RegularExpressionValidator ID="revNewPassword" runat="server"
                    ControlToValidate="txtNewPassword"
                    ValidationExpression="^.{6,}$"
                    ErrorMessage="New Password must be at least 6 characters." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">Confirm New Password:</span>
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                    ControlToValidate="txtConfirmPassword" ErrorMessage="Please confirm your new password." ForeColor="Red" />
                <asp:CompareValidator ID="cvPassword" runat="server"
                    ControlToValidate="txtConfirmPassword" ControlToCompare="txtNewPassword"
                    ErrorMessage="New passwords do not match." ForeColor="Red" />
            </div>

            <div class="row">
                <asp:Button ID="btnChange" runat="server" Text="Change Password" OnClick="btnChange_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" CausesValidation="false" />
            </div>

            <div class="result">
                <asp:Label ID="lblResult" runat="server"></asp:Label>
            </div>

            <div class="link-row">
                <a href="Dashboard.aspx">&larr; Back to Dashboard</a>
            </div>
        </div>
    </form>
</body>
</html>
