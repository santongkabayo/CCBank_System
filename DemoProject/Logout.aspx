<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="DemoProject.Logout" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Logout</title>
    <style>
        body { font-family: Arial; margin: 30px; background-color: #f0f4f8; }
        .container { width: 420px; padding: 30px; border: 1px solid #999; border-radius: 8px; background-color: #ffffff; text-align: center; }
        h2 { color: #2c3e50; margin-bottom: 20px; }
        .message { font-size: 15px; color: #555; margin-bottom: 24px; }
        .row { margin-bottom: 14px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2>Logout</h2>
            <div class="message">
                <asp:Label ID="lblMessage" runat="server">Are you sure you want to logout?</asp:Label>
            </div>
            <div class="row">
                <asp:Button ID="btnConfirmLogout" runat="server" Text="Yes" OnClick="btnConfirmLogout_Click" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false" />
            </div>
        </div>
    </form>
</body>
</html>
