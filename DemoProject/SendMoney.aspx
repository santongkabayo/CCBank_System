<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendMoney.aspx.cs" Inherits="DemoProject.SendMoney" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Send CloudMoney</title>
    <style>
        body { font-family: Arial; margin: 30px; background-color: #f0f4f8; }
        .container { width: 520px; padding: 30px; border: 1px solid #999; border-radius: 8px; background-color: #fff; }
        h2 { color: #2c3e50; }
        .row { margin-bottom: 14px; }
        .label { display: inline-block; width: 180px; font-weight: bold; }
        .result { margin-top: 16px; padding: 12px; background-color: #f4f8ff; border: 1px solid #aac; }
        .recipient-box { background-color: #e8f5e9; border: 1px solid #a5d6a7; border-radius: 6px; padding: 12px; margin-bottom: 14px; }
        .error { color: red; }
        .link-row { margin-top: 14px; font-size: 13px; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="container">
    <h2>📤 Send CloudMoney</h2>

    <asp:ValidationSummary ID="ValidationSummary1" runat="server"
        ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:"
        ValidationGroup="vgSend" />

    <div class="row">
        <span class="label">Your Account No:</span>
        <asp:Label ID="lblMyAccount" runat="server" Font-Bold="true"></asp:Label>
    </div>
    <div class="row">
        <span class="label">Your Balance:</span>
        ₱<asp:Label ID="lblBalance" runat="server" Font-Bold="true"></asp:Label>
    </div>

    <hr />

    <!-- STEP 1: Look up recipient -->
    <div class="row">
        <span class="label">Recipient Account No:</span>
        <asp:TextBox ID="txtRecipientAcct" runat="server" MaxLength="20"></asp:TextBox>
        <asp:RequiredFieldValidator ID="rfvRecipient" runat="server"
            ControlToValidate="txtRecipientAcct" ErrorMessage="Recipient Account No is required."
            ForeColor="Red" ValidationGroup="vgLookup" />
    </div>
    <div class="row">
        <asp:Button ID="btnLookup" runat="server" Text="Search Recipient"
            OnClick="btnLookup_Click" CausesValidation="true" ValidationGroup="vgLookup" />
    </div>

    <!-- STEP 2: Show recipient info and send form -->
    <asp:Panel ID="pnlSendForm" runat="server" Visible="false">
        <div class="recipient-box">
            <strong>Recipient Found:</strong><br />
            Account No: <asp:Label ID="lblRecipientAcct" runat="server"></asp:Label><br />
            Name: <asp:Label ID="lblRecipientName" runat="server"></asp:Label>
        </div>

        <div class="row">
            <span class="label">Amount to Send:</span>
            <asp:TextBox ID="txtAmount" runat="server"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvAmount" runat="server"
                ControlToValidate="txtAmount" ErrorMessage="Amount is required."
                ForeColor="Red" ValidationGroup="vgSend" />
            <asp:RangeValidator ID="rngAmount" runat="server"
                ControlToValidate="txtAmount" MinimumValue="100" MaximumValue="2000" Type="Double"
                ErrorMessage="Amount must be between ₱100.00 and ₱2,000.00."
                ForeColor="Red" ValidationGroup="vgSend" />
        </div>

        <div class="row">
            <span class="label">Your Password:</span>
            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                ControlToValidate="txtPassword" ErrorMessage="Password is required for verification."
                ForeColor="Red" ValidationGroup="vgSend" />
        </div>

        <div class="row">
            <asp:Button ID="btnSend" runat="server" Text="Send CloudMoney"
                OnClick="btnSend_Click" ValidationGroup="vgSend" />
        </div>
    </asp:Panel>

    <div class="result">
        <asp:Label ID="lblResult" runat="server"></asp:Label>
    </div>
    <div class="link-row"><a href="Dashboard.aspx">← Back to Dashboard</a></div>
</div>
    </form>
</body>
</html>
