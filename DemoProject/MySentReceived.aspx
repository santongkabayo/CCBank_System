<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MySentReceived.aspx.cs" Inherits="DemoProject.MySentReceived" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Sent or Received Transactions</title>
    <style>
        body { font-family: Arial; margin: 30px; background-color: #f9f6f0; }
        .container { width: 750px; padding: 30px; border: 1px solid #999; border-radius: 8px; background-color: #fff; }
        h2 { color: #2980b9; text-align: center; }
        .row { margin-bottom: 12px; }
        .label { display: inline-block; width: 60px; font-weight: bold; }
        .error { color: red; }
        .link-row { margin-top: 14px; font-size: 13px; }
        table.grid { width: 100%; border-collapse: collapse; margin-top: 16px; }
        table.grid th { background-color: #2980b9; color: white; padding: 8px; font-size: 13px; text-align: left; }
        table.grid td { padding: 7px 8px; font-size: 13px; border-bottom: 1px solid #eee; }
        table.grid tr:nth-child(even) { background-color: #f4f8ff; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="container">
    <h2>My Sent or Received Transactions</h2>

    <asp:ValidationSummary ID="ValidationSummary1" runat="server"
        ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

    <div class="row">
        <span class="label">From</span>
        <asp:TextBox ID="txtFrom" runat="server" TextMode="Date"></asp:TextBox>
        <asp:RequiredFieldValidator ID="rfvFrom" runat="server"
            ControlToValidate="txtFrom" ErrorMessage="From date is required." ForeColor="Red" />
    </div>
    <div class="row">
        <span class="label">To</span>
        <asp:TextBox ID="txtTo" runat="server" TextMode="Date"></asp:TextBox>
        <asp:RequiredFieldValidator ID="rfvTo" runat="server"
            ControlToValidate="txtTo" ErrorMessage="To date is required." ForeColor="Red" />
    </div>
    <div class="row">
        <span class="label">Type</span>
        <asp:DropDownList ID="ddlType" runat="server">
            <asp:ListItem Value="ALL">All</asp:ListItem>
            <asp:ListItem Value="S">Sent</asp:ListItem>
            <asp:ListItem Value="R">Received</asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="row">
        <asp:Button ID="btnList" runat="server" Text="List" OnClick="btnList_Click"
            style="background-color:#27ae60;color:white;padding:6px 20px;border:none;border-radius:4px;cursor:pointer;" />
        &nbsp;<a href="Dashboard.aspx">View Dashboard</a>
    </div>

    <asp:Label ID="lblError" runat="server" ForeColor="Red"></asp:Label>

    <asp:GridView ID="grdData" runat="server" AutoGenerateColumns="false"
        CssClass="grid" ShowHeaderWhenEmpty="false">
        <Columns>
            <asp:BoundField DataField="SEQ"           HeaderText="Seq. #" />
            <asp:BoundField DataField="TRANS_DATE"    HeaderText="Date Sent/Received" DataFormatString="{0:MM/dd/yyyy hh:mm tt}" />
            <asp:BoundField DataField="AMOUNT"        HeaderText="Amount"        DataFormatString="{0:N2}" ItemStyle-HorizontalAlign="Right" />
            <asp:BoundField DataField="SENT_TO"       HeaderText="Sent To"       NullDisplayText="" />
            <asp:BoundField DataField="RECEIVED_FROM" HeaderText="Received From" NullDisplayText="" />
        </Columns>
    </asp:GridView>

    <div class="link-row"><a href="Dashboard.aspx">← Back to Dashboard</a></div>
</div>
    </form>
</body>
</html>
