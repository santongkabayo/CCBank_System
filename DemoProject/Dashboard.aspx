<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="DemoProject.Dashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard</title>
    <style>
        body { font-family: Arial; margin: 30px; background-color: #f0f4f8; }
        .container { width: 620px; padding: 30px; border: 1px solid #999; border-radius: 8px; background-color: #fff; }
        h2 { color: #2c3e50; }
        .info-box { background-color: #eaf3fb; border: 1px solid #90caf9; border-radius: 6px; padding: 20px; margin-bottom: 16px; }
        .info-box table { width: 100%; border-collapse: collapse; }
        .info-box td { padding: 8px 6px; font-size: 15px; }
        .info-box td:first-child { font-weight: bold; width: 200px; color: #1a5276; }
        .notif-box { background-color: #fff8e1; border: 1px solid #f9a825; border-radius: 6px; padding: 14px; margin-bottom: 16px; }
        .notif-box h4 { margin: 0 0 8px 0; color: #e65100; }
        .nav-section h4 { color: #555; margin-bottom: 8px; }
        .nav-links a { display: inline-block; margin: 4px 6px 4px 0; padding: 8px 14px; background-color: #2980b9; color: white; text-decoration: none; border-radius: 4px; font-size: 13px; }
        .nav-links a:hover { background-color: #1a5276; }
        .nav-links a.danger { background-color: #c0392b; }
        .nav-links a.danger:hover { background-color: #922b21; }
        .nav-links a.report { background-color: #27ae60; }
        .nav-links a.report:hover { background-color: #1e8449; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="container">
    <h2>Dashboard</h2>
    <p>Welcome, <strong><asp:Label ID="lblWelcome" runat="server"></asp:Label></strong>!</p>

    <div class="info-box">
        <h3 style="margin-top:0;color:#1a5276;">My Account Summary</h3>
        <table>
            <tr><td>Account No:</td><td><asp:Label ID="lblAccountNo" runat="server"></asp:Label></td></tr>
            <tr><td>Name:</td><td><asp:Label ID="lblName" runat="server"></asp:Label></td></tr>
            <tr><td>Date Registered:</td><td><asp:Label ID="lblDateRegistered" runat="server"></asp:Label></td></tr>
            <tr><td>Total Current Balance:</td><td><strong>₱<asp:Label ID="lblBalance" runat="server"></asp:Label></strong></td></tr>
            <tr><td>Total Sent Amount:</td><td>₱<asp:Label ID="lblTotalSent" runat="server"></asp:Label></td></tr>
        </table>
    </div>

    <asp:Panel ID="pnlNotif" runat="server" Visible="false">
        <div class="notif-box">
            <h4>🔔 Recently Received CloudMoney</h4>
            <asp:GridView ID="grdNotif" runat="server" AutoGenerateColumns="false"
                BorderWidth="0" CellPadding="4" Font-Size="13px">
                <Columns>
                    <asp:BoundField DataField="TRANS_DATE"    HeaderText="Date"          DataFormatString="{0:MM/dd/yyyy hh:mm tt}" />
                    <asp:BoundField DataField="AMOUNT"        HeaderText="Amount"        DataFormatString="{0:N2}" />
                    <asp:BoundField DataField="RECEIVED_FROM" HeaderText="Received From" />
                </Columns>
            </asp:GridView>
        </div>
    </asp:Panel>

    <div class="nav-section">
        <h4>Transactions</h4>
        <div class="nav-links">
            <a href="Deposit.aspx">💰 Deposit</a>
            <a href="Withdraw.aspx">🏧 Withdraw</a>
            <a href="SendMoney.aspx">📤 Send CloudMoney</a>
        </div>
    </div>

    <div class="nav-section" style="margin-top:12px;">
        <h4>Reports</h4>
        <div class="nav-links">
            <a href="StatementOfAccount.aspx" class="report">📄 Statement of Account</a>
            <a href="MyDepositsWithdrawals.aspx" class="report">📊 My Deposits/Withdrawals</a>
            <a href="MySentReceived.aspx" class="report">🔁 My Sent/Received</a>
        </div>
    </div>

    <div class="nav-section" style="margin-top:12px;">
        <h4>Account</h4>
        <div class="nav-links">
            <a href="ChangePassword.aspx">🔑 Change Password</a>
            <a href="Logout.aspx" class="danger">🚪 Logout</a>
        </div>
    </div>
</div>
    </form>
</body>
</html>
