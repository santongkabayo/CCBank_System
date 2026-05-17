<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Receipt.aspx.cs" Inherits="DemoProject.Receipt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CCBank - Transaction Receipt</title>
    <style>
        :root { --bg:#f5f0e8; --card:#fff; --text:#2c3e50; --subtext:#666; --border:#e0d0c0; --accent:#e67e22; --hover:#fff8f0; }
        body.dark { --bg:#0f0f1a; --card:#1e1e30; --text:#f0f0f0; --subtext:#aaa; --border:#333; --accent:#f5b942; --hover:#2a2a3e; }
        * { box-sizing:border-box; margin:0; padding:0; }
        body { font-family:Arial,sans-serif; background:var(--bg); color:var(--text); min-height:100vh; display:flex; flex-direction:column; }
        .navbar { background:linear-gradient(135deg,#f0a070,#f5b942); padding:0 30px; display:flex; align-items:center; height:64px; }
        body.dark .navbar { background:linear-gradient(135deg,#1a1a2e,#16213e); }
        .navbar-brand { display:flex; align-items:center; gap:10px; }
        .navbar-brand img { width:80px; height:80px; object-fit:contain; }
        .navbar-brand span { color:white; font-size:18px; font-weight:bold; }
        .main { max-width:500px; margin:40px auto; padding:0 20px; width:100%; }
        .receipt-card {
            background:var(--card); border-radius:16px;
            box-shadow:0 4px 20px rgba(0,0,0,0.1);
            overflow:hidden; border:1px solid var(--border);
        }
        .receipt-header {
            background:linear-gradient(135deg,#f0a070,#f5b942);
            padding:24px; text-align:center; color:white;
        }
        .receipt-header .check { font-size:48px; margin-bottom:8px; }
        .receipt-header h2 { font-size:20px; margin-bottom:4px; }
        .receipt-header p { font-size:13px; opacity:0.9; }
        .receipt-body { padding:24px; }
        .receipt-row {
            display:flex; justify-content:space-between;
            padding:12px 0; border-bottom:1px solid var(--border);
            font-size:14px;
        }
        .receipt-row:last-child { border-bottom:none; }
        .receipt-row span:first-child { color:var(--subtext); }
        .receipt-row span:last-child { font-weight:bold; color:var(--text); }
        .receipt-row.amount span:last-child { color:#27ae60; font-size:18px; }
        .receipt-footer { padding:0 24px 24px; }
        .btn-row { display:flex; gap:10px; margin-top:4px; }
        .btn-print { flex:1; background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:14px; font-weight:bold; }
        .btn-dashboard { flex:1; background:var(--border); color:var(--text); padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:14px; text-decoration:none; text-align:center; display:block; }
        .btn-dashboard:hover { opacity:0.8; }
        .trans-type-badge { display:inline-block; padding:4px 12px; border-radius:20px; font-size:12px; font-weight:bold; color:white; }
        .type-D { background:#27ae60; }
        .type-W { background:#e74c3c; }
        .type-S { background:#2980b9; }
        .type-R { background:#8e44ad; }
        @media print {
            .navbar, .btn-row { display:none !important; }
            body { background:white; }
            .main { margin:0; }
            .receipt-card { box-shadow:none; border:1px solid #ddd; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">
            <img src="CC bank.png" alt="CC Bank" />
            <span>CCBank</span>
        </div>
    </nav>

    <form id="form1" runat="server">
    <div class="main">
        <div class="receipt-card">
            <div class="receipt-header">
                <div class="check">✅</div>
                <h2>Transaction Successful!</h2>
                <p><asp:Label ID="lblTransDate" runat="server"></asp:Label></p>
            </div>

            <div class="receipt-body">
                <div class="receipt-row">
                    <span>Transaction ID</span>
                    <span>#<asp:Label ID="lblTransID" runat="server"></asp:Label></span>
                </div>
                <div class="receipt-row">
                    <span>Type</span>
                    <span><asp:Label ID="lblTransType" runat="server"></asp:Label></span>
                </div>
                <div class="receipt-row">
                    <span>Account No</span>
                    <span><asp:Label ID="lblAccountNo" runat="server"></asp:Label></span>
                </div>
                <div class="receipt-row amount">
                    <span>Amount</span>
                    <span>₱<asp:Label ID="lblAmount" runat="server"></asp:Label></span>
                </div>
                <div class="receipt-row">
                    <span>Balance After</span>
                    <span>₱<asp:Label ID="lblBalanceAfter" runat="server"></asp:Label></span>
                </div>
                <asp:Panel ID="pnlSentTo" runat="server" Visible="false">
                    <div class="receipt-row">
                        <span>Sent To</span>
                        <span><asp:Label ID="lblSentTo" runat="server"></asp:Label></span>
                    </div>
                </asp:Panel>
                <asp:Panel ID="pnlReceivedFrom" runat="server" Visible="false">
                    <div class="receipt-row">
                        <span>Received From</span>
                        <span><asp:Label ID="lblReceivedFrom" runat="server"></asp:Label></span>
                    </div>
                </asp:Panel>
            </div>

            <div class="receipt-footer">
                <div class="btn-row">
                    <button type="button" class="btn-print" onclick="window.print()">🖨️ Print Receipt</button>
                    <a href="Dashboard.aspx" class="btn-dashboard">🏠 Dashboard</a>
                </div>
            </div>
        </div>
    </div>
    </form>

    <script>
        if (localStorage.getItem('theme') === 'dark') document.body.classList.add('dark');
    </script>
</body>
</html>
