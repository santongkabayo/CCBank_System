<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="DemoProject.Admin" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CC Bank Admin - Control Center</title>
    <style>
        /* Shared Core Design System Variables */
        :root { --bg:#f5f0e8; --card:#fff; --text:#2c3e50; --subtext:#666; --border:#e0d0c0; --accent:#e67e22; --input-bg:#fff; --input-border:#ddd; --label:#555; --result-bg:#fff8f0; --muted:#999; --hover:#fff8f0; --green:#27ae60; --red:#e74c3c; }
        body.dark { --bg:#0f0f1a; --card:#1e1e30; --text:#f0f0f0; --subtext:#aaa; --border:#333; --accent:#f5b942; --input-bg:#2a2a3e; --input-border:#444; --label:#ccc; --result-bg:#2a2a3e; --hover:#2a2a3e; }
        
        * { box-sizing:border-box; margin:0; padding:0; transition:background 0.3s,color 0.3s; }
        body { font-family:Arial,sans-serif; background:var(--bg); color:var(--text); min-height:100vh; }
        
        /* Navbar */
        .navbar { background:linear-gradient(135deg,#f0a070,#f5b942); padding:0 30px; display:flex; align-items:center; justify-content:space-between; height:64px; box-shadow:0 2px 12px rgba(0,0,0,0.15); position:sticky; top:0; z-index:100; }
        body.dark .navbar { background:linear-gradient(135deg,#1a1a2e,#16213e); }
        .navbar-brand { display:flex; align-items:center; gap:10px; }
        .navbar-brand img { width:80px; height:80px; object-fit:contain; }
        .navbar-brand span { color:white; font-size:18px; font-weight:bold; }
        .navbar-links { display:flex; align-items:center; gap:6px; }
        .navbar-links a { color:rgba(255,255,255,0.9); text-decoration:none; font-size:13px; padding:8px 12px; border-radius:6px; }
        .navbar-links a:hover { background:rgba(255,255,255,0.2); }
        .navbar-links .btn-logout { background:rgba(231,76,60,0.8); color:white; padding:7px 14px; border-radius:6px; font-size:13px; text-decoration:none; font-weight:bold; margin-left:6px; }
        .theme-btn { background:rgba(255,255,255,0.2); border:none; border-radius:20px; padding:6px 12px; cursor:pointer; font-size:16px; color:white; margin-left:8px; }
        
        /* Admin Content Workspace */
        .container { max-width: 1200px; margin: 40px auto; padding: 0 20px; }
        
        /* Metric Cards Grid */
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .metric-card { background: var(--card); padding: 24px; border-radius: 16px; border: 1px solid var(--border); box-shadow: 0 4px 20px rgba(0,0,0,0.06); }
        .metric-card h3 { font-size: 12px; color: var(--subtext); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; font-weight: bold; }
        .metric-card .value { font-size: 26px; font-weight: bold; color: var(--accent); }
        
        /* Admin Interactive Tables Sections */
        .admin-section { background: var(--card); border-radius: 16px; padding: 32px; border: 1px solid var(--border); margin-bottom: 30px; box-shadow: 0 4px 20px rgba(0,0,0,0.06); }
        .section-header { margin-bottom: 20px; border-bottom: 1px solid var(--border); padding-bottom: 12px; }
        .section-header h2 { font-size: 18px; color: var(--text); display: flex; align-items: center; gap: 8px; }
        
        /* Form Clean DataGrid Layout System */
        .grid-wrap { overflow-x: auto; border-radius: 8px; border: 1px solid var(--border); background: var(--card); }
        
        /* GridView CSS Custom Overrides */
        .admin-table { width: 100%; border-collapse: collapse; font-size: 13px; text-align: left; }
        .admin-table th { background: var(--hover); padding: 14px 16px; color: var(--text); font-weight: bold; border-bottom: 2px solid var(--border); }
        .admin-table td { padding: 12px 16px; border-bottom: 1px solid var(--border); color: var(--text); vertical-align: middle; }
        .admin-table tr:last-child td { border-bottom: none; }
        .admin-table tr:hover td { background: var(--hover); }
        
        /* Transaction State Badges */
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; color: white; display: inline-block; }
        .badge-deposit { background: var(--green); }
        .badge-withdraw { background: var(--red); }
        .badge-transfer { background: var(--accent); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <nav class="navbar">
            <div class="navbar-brand">
                <img src="CC bank.png" alt="CCBank" />
                <span>CC Bank 👤 Admin Control Panel</span>
            </div>
            <div class="navbar-links">
                <a href="Logout.aspx" class="btn-logout">🚪 Logout</a>
                <button type="button" class="theme-btn" onclick="toggleTheme()">O</button>
            </div>
        </nav>

        <div class="container">
            <div class="metrics-grid">
                <div class="metric-card">
                    <h3>Total Registered Users</h3>
                    <div class="value"><asp:Label ID="lblTotalUsers" runat="server" Text="0"></asp:Label></div>
                </div>
                <div class="metric-card">
                    <h3>Bank Liquidity (Total Deposits)</h3>
                    <div class="value">₱<asp:Label ID="lblTotalBalance" runat="server" Text="0.00"></asp:Label></div>
                </div>
                <div class="metric-card">
                    <h3>Transactions Processed Today</h3>
                    <div class="value"><asp:Label ID="lblTodayTrans" runat="server" Text="0"></asp:Label></div>
                </div>
            </div>

            <div class="admin-section">
                <div class="section-header">
                    <h2>⚡ Administrative Account Actions</h2>
                </div>
                
                <div style="display: flex; gap: 15px; align-items: flex-start; flex-wrap: wrap; background: var(--hover); padding: 20px; border-radius: 8px; border: 1px solid var(--border);">
                    <div style="flex: 1; min-width: 200px;">
                        <span class="label" style="display:block; font-weight:bold; margin-bottom:5px; font-size:13px;">Target Client Account Number</span>
                        <asp:TextBox ID="txtTargetAccount" runat="server" placeholder="e.g. 100001" style="width:100%; padding:10px; border:1.5px solid var(--input-border); border-radius:8px; background:var(--input-bg); color:var(--text);"></asp:TextBox>
                    </div>
                    
                    <div style="flex: 2; min-width: 280px; display: flex; gap: 10px; margin-top: 22px;">
                        <asp:Button ID="btnToggleLock" runat="server" Text="🔒 Toggle Lock / Unlock" 
                            OnClick="btnToggleLock_Click" CssClass="btn-secondary" style="margin-top:0; padding:11px;" />
                            
                        <asp:Button ID="btnResetPassword" runat="server" Text="🔑 Reset to Temp123!" 
                            OnClick="btnResetPassword_Click" CssClass="btn-primary" style="margin-top:0; padding:11px; background:linear-gradient(135deg, #e67e22, #d35400);" />
                    </div>
                </div>
                
                <div style="margin-top: 10px;">
                    <asp:Label ID="lblAdminResult" runat="server" Font-Size="13px" Font-Bold="true"></asp:Label>
                </div>
            </div>

            <div class="admin-section">
                <div class="section-header">
                    <h2>👥 Registered User Directory</h2>
                </div>
                <div class="grid-wrap">
                    <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" GridLines="None" CssClass="admin-table">
                        <Columns>
                            <asp:BoundField DataField="ACCOUNT_NO" HeaderText="Account No" />
                            <asp:BoundField DataField="Fullname" HeaderText="Client Profile Name" />
                            <asp:BoundField DataField="USER_ROLE" HeaderText="System Role Level" />
                            
                            <%-- Synchronized Dynamic Status Badge System --%>
                            <asp:TemplateField HeaderText="Account Status">
                                <ItemTemplate>
                                    <span class='<%# Eval("ACCOUNT_STATUS").ToString() == "Locked" ? "badge badge-withdraw" : "badge badge-deposit" %>'>
                                        <%# Eval("ACCOUNT_STATUS") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="CurrentBalance" HeaderText="Net Available Balance" DataFormatString="₱{0:N2}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="admin-section">
                <div class="section-header">
                    <h2>📜 Global Operations Audit Trail</h2>
                </div>
                <div class="grid-wrap">
                    <asp:GridView ID="gvAllTransactions" runat="server" AutoGenerateColumns="False" GridLines="None" CssClass="admin-table">
                        <Columns>
                            <asp:BoundField DataField="TRANS_DATE" HeaderText="Timestamp" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />
                            <asp:BoundField DataField="ACCOUNT_NO" HeaderText="Account Owner" />
                            <asp:BoundField DataField="TRANS_TYPE" HeaderText="Action Type" />
                            <asp:BoundField DataField="AMOUNT" HeaderText="Transaction Value" DataFormatString="₱{0:N2}" />
                            <asp:BoundField DataField="SENT_TO" HeaderText="Target Destination Account" NullDisplayText="-" />
                            <asp:BoundField DataField="RECEIVED_FROM" HeaderText="Origin Source Account" NullDisplayText="-" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>

    <script>
        function toggleTheme() {
            document.body.classList.toggle('dark');
            var btn = document.querySelector('.theme-btn');
            btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }

        // Initialize display configuration state using the core system keys
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            document.querySelector('.theme-btn').textContent = '☀️';
        } else {
            document.querySelector('.theme-btn').textContent = '🌑';
        }
    </script>
</body>
</html>
