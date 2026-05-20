<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StatementOfAccount.aspx.cs" Inherits="DemoProject.StatementOfAccount" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
   <title>CCBank - Statement of Account</title>
    <style>
        :root { 
            --bg: #f5f0e8; 
            --card: #fff; 
            --text: #2c3e50; 
            --subtext: #666; 
            --border: #e0d0c0; 
            --accent: #e67e22; 
            --input-bg: #fff; 
            --input-border: #ddd; 
            --label: #555; 
            --muted: #999; 
            --hover: #fff8f0; 
            --shadow: rgba(0,0,0,0.08);
        }
        body.dark { 
            --bg: #0f0f1a; 
            --card: #1e1e30; 
            --text: #f0f0f0; 
            --subtext: #aaa; 
            --border: #333; 
            --accent: #f5b942; 
            --input-bg: #2a2a3e; 
            --input-border: #444; 
            --label: #ccc; 
            --hover: #2a2a3e; 
            --shadow: rgba(0,0,0,0.3);
        }
        
        * { box-sizing:border-box; margin:0; padding:0; transition:background 0.3s,color 0.3s; }
        body { font-family:Arial,sans-serif; background:var(--bg); color:var(--text); min-height:100vh; }
        
        .navbar { background:linear-gradient(135deg,#f0a070,#f5b942); padding:0 30px; display:flex; align-items:center; justify-content:space-between; height:64px; box-shadow:0 2px 12px rgba(0,0,0,0.15); position:sticky; top:0; z-index:100; }
        body.dark .navbar { background:linear-gradient(135deg,#1a1a2e,#16213e); }
        .navbar-brand { display:flex; align-items:center; gap:10px; }
        .navbar-brand img { width:80px; height:80px; object-fit:contain; transition: transform 0.3s; }
        .navbar-brand img:hover { transform: rotate(-5deg) scale(1.05); }
        .navbar-brand span { color:white; font-size:18px; font-weight:bold; }
        .navbar-links { display:flex; align-items:center; gap:6px; }
        .navbar-links a { color:rgba(255,255,255,0.9); text-decoration:none; font-size:13px; padding:8px 12px; border-radius:6px; transition: background 0.2s, transform 0.2s; }
        .navbar-links a:hover { background:rgba(255,255,255,0.2); transform: translateY(-1px); }
        .navbar-links .btn-logout { background:rgba(231,76,60,0.8); color:white; padding:7px 14px; border-radius:6px; font-size:13px; text-decoration:none; font-weight:bold; margin-left:6px; }
        .navbar-links .btn-logout:hover { background:rgba(231,76,60,1); }
        
        .theme-btn { background:rgba(255,255,255,0.2); border:none; border-radius:20px; padding:6px 12px; cursor:pointer; font-size:16px; color:white; margin-left:8px; transition: background 0.2s, transform 0.3s; }
        .theme-btn:hover { background: rgba(255,255,255,0.3); transform: rotate(20deg); }
        
        .main { max-width:960px; margin:30px auto; padding:0 20px; }
        .page-card { background:var(--card); border-radius:16px; padding:32px; box-shadow:0 4px 20px rgba(0,0,0,0.1); border:1px solid var(--border); animation: fadeInUp 0.5s ease 0.1s both; }
        
        .page-title { display:flex; align-items:center; gap:10px; margin-bottom:24px; }
        .page-title .icon { font-size:26px; }
        .page-title h2 { color:var(--text); font-size:20px; }
        
        /* --- Aligned Filter Layout Structure --- */
        .filter-row { 
            display: flex; 
            gap: 16px; 
            align-items: flex-start; 
            margin-bottom: 24px; 
            flex-wrap: wrap; 
        }
        .filter-group { 
            display: flex; 
            flex-direction: column; 
            gap: 4px; 
            position: relative;
            vertical-align: top;
        }
        .label { font-weight:bold; color:var(--label); font-size:13px; }
        
        input[type="date"], .btn-list, .btn-dash {
            height: 40px;
            box-sizing: border-box;
        }
        
        input[type="date"] { 
            padding: 0 12px; 
            border: 1.5px solid var(--input-border); 
            border-radius: 8px; 
            font-size: 14px; 
            background: var(--input-bg); 
            color: var(--text); 
            transition: border-color 0.2s, transform 0.2s;
        }
        input[type="date"]:focus { border-color:#f0a070; outline:none; transform: scale(1.02); }
        
        .btn-list { 
            background: linear-gradient(135deg,#f0a070,#f5b942); 
            color: white; 
            padding: 0 22px; 
            border: none; 
            border-radius: 8px; 
            cursor: pointer; 
            font-size: 14px; 
            font-weight: bold; 
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-top: 23px;
            transition: opacity 0.2s, transform 0.2s, box-shadow 0.2s;
        }
        .btn-list:hover { opacity:0.88; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(240,160,112,0.3); }
        .btn-list:active { transform: scale(0.98); }
        
        .btn-dash { 
            background: var(--input-bg); 
            color: var(--label); 
            padding: 0 16px; 
            border: 1.5px solid var(--input-border); 
            border-radius: 8px; 
            font-size: 13px; 
            text-decoration: none; 
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-top: 23px;
            transition: border-color 0.2s, color 0.2s, background-color 0.2s, transform 0.2s;
        }
        .btn-dash:hover { border-color: #f0a070; color: var(--text); background-color: var(--hover); transform: translateY(-1px); }

        /* Absolutely positions empty fields so they don't break flex-wrap rules */
        .filter-group .error, 
        .filter-group span[id*="rfv"] {
            font-size: 11px;
            margin-top: 2px;
            position: absolute;
            top: 65px;
            left: 0;
            white-space: nowrap;
        }
        
        .error-msg { color:#e74c3c; font-size:13px; margin:10px 0; display: block; }
        .grid-wrap { overflow-x:auto; margin-top:20px; border-radius: 8px; box-shadow: 0 2px 8px var(--shadow); }
        table { width:100%; border-collapse:collapse; font-size:13px; }
        table th { background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:12px 14px; text-align:left; font-weight: bold; }
        body.dark table th { background:linear-gradient(135deg,#1a1a2e,#16213e); border-bottom: 2px solid var(--border); }
        table td { padding:10px 14px; border-bottom:1px solid var(--border); color:var(--text); }
        table tr:hover td { background:var(--hover); }
        
        .back-link { margin-top:24px; text-align:center; font-size:13px; }
        .back-link a { color:var(--accent); text-decoration:none; font-weight:bold; transition: opacity 0.2s, transform 0.2s; display: inline-block; }
        .back-link a:hover { transform: translateY(-1px); opacity: 0.8; }
        .error { color:#e74c3c; font-size:13px; }

        /* ── ANIMATIONS ── */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(24px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* ── PAGE LOADER ── */
        .page-loader {
            position: fixed; inset: 0;
            background: var(--bg);
            display: flex; align-items: center; justify-content: center;
            z-index: 9999;
            transition: opacity 0.4s;
        }
        .page-loader.hidden { opacity: 0; pointer-events: none; }
        .loader-spinner {
            width: 48px; height: 48px;
            border: 4px solid var(--border);
            border-top-color: #f0a070;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }
    </style>
</head>
<body>
    <div class="page-loader" id="pageLoader">
        <div class="loader-spinner"></div>
    </div>

    <nav class="navbar">
        <div class="navbar-brand">
            <img src="CC bank.png" alt="CCBank" />
            <span>CC Bank</span>
        </div>
        <div class="navbar-links">
            <a href="Dashboard.aspx">🏠 Home</a>
            <a href="StatementOfAccount.aspx">📄 Statement</a>
            <a href="MyDepositsWithdrawals.aspx">📊 Reports</a>
            <a href="ChangePassword.aspx">🔑 Change Password</a><a href="ChangePIN.aspx">🔐 Change PIN</a>
            <a href="Logout.aspx" class="btn-logout">🚪 Logout</a>
            <button type="button" class="theme-btn" onclick="toggleTheme()">🌑</button>
        </div>
    </nav>

    <form id="form1" runat="server">
    <div class="main">
        <div class="page-card">
            <div class="page-title">
                <span class="icon">📄</span>
                <h2>My Statement of Account</h2>
            </div>

            <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

            <div class="filter-row">
                <div class="filter-group">
                    <span class="label">From</span>
                    <asp:TextBox ID="txtFrom" runat="server" TextMode="Date"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvFrom" runat="server"
                        ControlToValidate="txtFrom" ErrorMessage="From date is required." ForeColor="Red" Display="Dynamic" />
                </div>
                <div class="filter-group">
                    <span class="label">To</span>
                    <asp:TextBox ID="txtTo" runat="server" TextMode="Date"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvTo" runat="server"
                        ControlToValidate="txtTo" ErrorMessage="To date is required." ForeColor="Red" Display="Dynamic" />
                </div>
                <asp:Button ID="btnList" runat="server" Text="List" OnClick="btnList_Click" CssClass="btn-list" />
                <a href="Dashboard.aspx" class="btn-dash">View Dashboard</a>
            </div>

            <asp:Label ID="lblError" runat="server" CssClass="error-msg"></asp:Label>

            <div class="grid-wrap">
                <asp:GridView ID="grdStatement" runat="server" AutoGenerateColumns="false"
                    ShowHeaderWhenEmpty="false">
                    <Columns>
                        <asp:BoundField DataField="SEQ"           HeaderText="Seq. #" />
                        <asp:BoundField DataField="TRANS_TYPE"    HeaderText="Type" />
                        <asp:BoundField DataField="TRANS_DATE"    HeaderText="Date" DataFormatString="{0:MM/dd/yyyy hh:mm tt}" />
                        <asp:BoundField DataField="DEBIT"         HeaderText="Debit"         DataFormatString="{0:N2}" NullDisplayText="" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField DataField="CREDIT"        HeaderText="Credit"        DataFormatString="{0:N2}" NullDisplayText="" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField DataField="BALANCE_AFTER" HeaderText="Balance"       DataFormatString="{0:N2}" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField DataField="SENT_TO"       HeaderText="Sent To"       NullDisplayText="" />
                        <asp:BoundField DataField="RECEIVED_FROM" HeaderText="Received From" NullDisplayText="" />
                    </Columns>
                </asp:GridView>
            </div>

            <div class="back-link">
                <a href="Dashboard.aspx">← Back to Dashboard</a>
            </div>
        </div>
    </div>
    </form>

    <script>
        function toggleTheme() {
            document.body.classList.toggle('dark');
            var btn = document.querySelector('.theme-btn');
            if (btn) btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            var btn = document.querySelector('.theme-btn');
            if (btn) btn.textContent = '☀️';
        }

        // Handle page loader animation release
        window.addEventListener('load', function () {
            var loader = document.getElementById('pageLoader');
            if (loader) {
                loader.classList.add('hidden');
                setTimeout(function () { loader.style.display = 'none'; }, 400);
            }
        });

        // Handle structural exit transitions for clean routing animations
        document.querySelectorAll('a[href], .navbar-links a').forEach(function (link) {
            if (link.href && !link.href.includes('#') && link.target !== '_blank') {
                link.addEventListener('click', function (e) {
                    e.preventDefault();
                    var href = this.href;
                    var card = document.querySelector('.page-card');
                    if (card) {
                        card.style.opacity = '0';
                        card.style.transform = 'translateY(-12px)';
                        card.style.transition = 'opacity 0.3s, transform 0.3s';
                    }
                    setTimeout(function () { window.location.href = href; }, 280);
                });
            }
        });
    </script>
</body>
</html>
