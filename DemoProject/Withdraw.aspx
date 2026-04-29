<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Withdraw.aspx.cs" Inherits="DemoProject.Withdraw" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Withdraw</title>
    <style>
        body { font-family: Arial; margin: 30px; background-color: #f0f4f8; }
        .container { width: 480px; padding: 30px; border: 1px solid #999; border-radius: 8px; background-color: #fff; }
        h2 { color: #2c3e50; }
        .row { margin-bottom: 14px; }
        .label { display: inline-block; width: 160px; font-weight: bold; }
        .result { margin-top: 16px; padding: 12px; background-color: #f4f8ff; border: 1px solid #aac; }
        .error { color: red; }
        .link-row { margin-top: 14px; font-size: 13px; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="container">
    <h2>🏧 Withdraw</h2>

    <asp:ValidationSummary ID="ValidationSummary1" runat="server"
        ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

    <div class="row">
        <span class="label">Account No:</span>
        <asp:Label ID="lblAccountNo" runat="server" Font-Bold="true"></asp:Label>
    </div>
    <div class="row">
        <span class="label">Current Balance:</span>
        ₱<asp:Label ID="lblBalance" runat="server" Font-Bold="true"></asp:Label>
    </div>
    <div class="row">
        <span class="label">Amount to Withdraw:</span>
        <asp:TextBox ID="txtAmount" runat="server"></asp:TextBox>
        <asp:RequiredFieldValidator ID="rfvAmount" runat="server"
            ControlToValidate="txtAmount" ErrorMessage="Amount is required." ForeColor="Red" />
        <asp:RangeValidator ID="rngAmount" runat="server"
            ControlToValidate="txtAmount" MinimumValue="100" MaximumValue="2000" Type="Double"
            ErrorMessage="Amount must be between ₱100.00 and ₱2,000.00." ForeColor="Red" />
    </div>
    <div class="row">
        <asp:Button ID="btnWithdraw" runat="server" Text="Withdraw" OnClick="btnWithdraw_Click" />
        <asp:Button ID="btnClear"    runat="server" Text="Clear"    OnClick="btnClear_Click" CausesValidation="false" />
    </div>
    <div class="result">
        <asp:Label ID="lblResult" runat="server"></asp:Label>
    </div>
    <div class="link-row"><a href="Dashboard.aspx">← Back to Dashboard</a></div>
</div>
    </form>
</body>
</html>
