<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="DemoProject.Dashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <title>CCBank - Dashboard</title>
    <style>
        :root {
            --bg: #f5f0e8;
            --navbar: linear-gradient(135deg, #f0a070, #f5b942);
            --card: #ffffff;
            --text: #2c3e50;
            --subtext: #666;
            --border: #e0d0c0;
            --accent: #e67e22;
            --green: #27ae60;
            --red: #e74c3c;
            --blue: #2980b9;
            --muted: #999;
            --hover: #fff8f0;
        }
        body.dark {
            --bg: #0f0f1a;
            --navbar: linear-gradient(135deg, #1a1a2e, #16213e);
            --card: #1e1e30;
            --text: #f0f0f0;
            --subtext: #aaa;
            --border: #333;
            --accent: #f5b942;
            --hover: #2a2a3e;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; transition: background 0.3s, color 0.3s; }
        body { font-family: Arial, sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; }

        /* NAVBAR */
        .navbar {
            background: var(--navbar);
            padding: 0 30px;
            display: flex; align-items: center;
            justify-content: space-between;
            height: 64px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.15);
            position: sticky; top: 0; z-index: 100;
        }
        .navbar-brand {
            display: flex; align-items: center; gap: 10px;
        }
        .navbar-brand img { width: 80px; height: 80px; object-fit: contain; }
        .navbar-brand span { color: white; font-size: 18px; font-weight: bold; letter-spacing: 1px; }
        .navbar-links {
            display: flex; align-items: center; gap: 6px;
        }
        .navbar-links a {
            color: rgba(255,255,255,0.9);
            text-decoration: none; font-size: 13px;
            padding: 8px 12px; border-radius: 6px;
            transition: background 0.2s;
        }
        .navbar-links a:hover { background: rgba(255,255,255,0.2); }
        .navbar-links a.active { background: rgba(255,255,255,0.25); font-weight: bold; }
        .navbar-links .btn-logout {
            background: rgba(231,76,60,0.8);
            color: white; padding: 7px 14px;
            border-radius: 6px; font-size: 13px;
            text-decoration: none; font-weight: bold;
            margin-left: 6px;
        }
        .navbar-links .btn-logout:hover { background: rgba(192,57,43,0.9); }
        .theme-btn {
            background: rgba(255,255,255,0.2);
            border: none; border-radius: 20px;
            padding: 6px 12px; cursor: pointer;
            font-size: 16px; color: white; margin-left: 8px;
        }

        /* SCREEN-FILLING RESPONSIVE GRID LAYOUT */
        .main { 
            max-width: 1420px; 
            margin: 0 auto; 
            padding: 30px 24px; 
        }
        .welcome-text { font-size: 24px; font-weight: bold; color: var(--text); margin-bottom: 24px; }
        .welcome-text span { color: var(--accent); }

        /* Two-Column Matrix Framework split for modern wide monitors */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 420px 1fr;
            gap: 24px;
            align-items: start;
        }

        .dashboard-sidebar {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .dashboard-content {
            display: flex;
            flex-direction: column;
            gap: 20px;
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 24px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
            min-height: 500px;
        }

        /* CARDS VIEWPORT REFACTORING */
        .cards-stack { display: flex; flex-direction: column; gap: 16px; }
        .card {
            background: var(--card);
            border-radius: 14px; padding: 20px 22px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
            border: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .card-details { flex: 1; }
        .card-label { font-size: 11px; color: var(--muted); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
        .card-value { font-size: 22px; font-weight: bold; color: var(--text); }
        .card-value.green { color: var(--green); }
        .card-value.red { color: var(--red); }
        .card-icon { font-size: 32px; display: flex; align-items: center; justify-content: center; width: 50px; height: 50px; background: var(--bg); border-radius: 10px; }
        
        .card.accent-card {
            background: linear-gradient(135deg, #f0a070, #f5b942);
            border: none;
        }
        .card.accent-card .card-icon { background: rgba(255,255,255,0.2); }
        .card.accent-card .card-label,
        .card.accent-card .card-value { color: white; }

        /* ACCOUNT INFO BOXES */
        .info-box {
            background: var(--card); border-radius: 14px;
            padding: 22px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
            border: 1px solid var(--border);
        }
        .info-box h3 { font-size: 14px; color: var(--accent); margin-bottom: 14px; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-table { width: 100%; border-collapse: collapse; }
        .info-table td { padding: 10px 6px; font-size: 14px; color: var(--text); border-bottom: 1px solid var(--border); }
        .info-table td:first-child { font-weight: bold; color: var(--subtext); width: 130px; font-size: 13px; }
        .info-table tr:last-child td { border-bottom: none; }

        /* ALERTS AND MESSAGES */
        .notif-box {
            background: var(--card); border-radius: 14px;
            padding: 18px 22px;
            border-left: 4px solid #f5b942;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
        }
        .notif-box h4 { color: var(--accent); margin-bottom: 10px; font-size: 14px; }

        /* NAVIGATION ACTION GRID ITEMS */
        .section-title { font-size: 12px; font-weight: bold; color: var(--muted); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
        .actions-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
        .action-btn {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            background: var(--card); border: 1px solid var(--border);
            border-radius: 12px; padding: 14px 8px;
            text-decoration: none; color: var(--text);
            font-size: 12px; font-weight: bold;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04);
            transition: transform 0.2s, box-shadow 0.2s;
            text-align: center;
        }
        .action-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.1); background: var(--hover); }
        .action-btn .icon { font-size: 22px; margin-bottom: 4px; }
        .action-btn.deposit .icon { color: var(--green); }
        .action-btn.withdraw .icon { color: var(--red); }
        .action-btn.send .icon { color: var(--blue); }
        .action-btn.statement .icon { color: var(--accent); }

        /* LOG TABLES AND GRIDVIEWS */
        .grid-wrap { overflow-x: auto; border-radius: 8px; border: 1px solid var(--border); }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        table th { background: linear-gradient(135deg, #f0a070, #f5b942); color: white; padding: 12px; text-align: left; font-weight: bold; }
        body.dark table th { background: linear-gradient(135deg, #16213e, #1a1a2e); }
        table td { padding: 12px; border-bottom: 1px solid var(--border); color: var(--text); }
        table tr:last-child td { border-bottom: none; }
        table tr:hover td { background: var(--hover); }

        /* RESPONSIVE BREAKPOINT RULES FOR LAPTOPS/TABLETS */
        @media (max-width: 1024px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
            .actions-grid {
                grid-template-columns: repeat(4, 1fr);
            }
        }
        @media (max-width: 480px) {
            .actions-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">
            <img src="CC bank.png" alt="CCBank" />
            <span>CC Bank</span>
        </div>
        <div class="navbar-links">
            <a href="Dashboard.aspx" class="active">🏠 Home</a>
            <a href="StatementOfAccount.aspx">📄 Statement</a>
            <a href="MyDepositsWithdrawals.aspx">📊 Reports</a>
            <a href="ChangePassword.aspx">🔑 Change Password</a>
            <a href="ResetPassword.aspx">🔐 Reset Password</a>
            <a href="Profile.aspx">👤 Profile</a>
            <a href="Logout.aspx" class="btn-logout">🚪 Logout</a>   
            <button class="theme-btn" onclick="toggleTheme()">🌑</button>
        </div>
    </nav>

    <form id="form1" runat="server">
    <div class="main">
        <div class="welcome-text">
            Welcome back, <span><asp:Label ID="lblWelcome" runat="server"></asp:Label></span>! 👋
        </div>

        <div class="dashboard-grid">
            
            <div class="dashboard-sidebar">
                
                <div class="cards-stack">
                    <div class="card accent-card">
                        <div class="card-icon">💳</div>
                        <div class="card-details">
                            <div class="card-label">Current Balance</div>
                            <div class="card-value">₱<asp:Label ID="lblBalance" runat="server"></asp:Label></div>
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-icon">📤</div>
                        <div class="card-details">
                            <div class="card-label">Total Sent</div>
                            <div class="card-value red">₱<asp:Label ID="lblTotalSent" runat="server"></asp:Label></div>
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-icon">🏦</div>
                        <div class="card-details">
                            <div class="card-label">Account No</div>
                            <div class="card-value" style="font-size:18px; letter-spacing:0.5px;"><asp:Label ID="lblAccountNo" runat="server"></asp:Label></div>
                            <asp:Label ID="lblAccountNo2" runat="server" Visible="false"></asp:Label>
                        </div>
                    </div>
                </div>

                <div class="info-box">
                    <h3>👤 Account Information</h3>
                    <table class="info-table">
                        <tr><td>Full Name</td><td><asp:Label ID="lblName" runat="server"></asp:Label></td></tr>
                        <tr><td>Date Registered</td><td><asp:Label ID="lblDateRegistered" runat="server"></asp:Label></td></tr>
                    </table>
                </div>

                <div class="info-box">
                    <div class="section-title">Quick Actions</div>
                    <div class="actions-grid">
                        <a href="Deposit.aspx" class="action-btn deposit">
                            <span class="icon">💰</span>Deposit
                        </a>
                        <a href="Withdraw.aspx" class="action-btn withdraw">
                            <span class="icon">🏧</span>Withdraw
                        </a>
                        <a href="SendMoney.aspx" class="action-btn send">
                            <span class="icon">📤</span>Send Money
                        </a>
                        <a href="MySentReceived.aspx" class="action-btn statement">
                            <span class="icon">🔁</span>Sent/Rcvd
                        </a>
                    </div>
                </div>

                <asp:Panel ID="pnlNotif" runat="server" Visible="false">
                    <div class="notif-box">
                        <h4>🔔 Recently Received CCBank Money</h4>
                        <div class="grid-wrap">
                            <asp:GridView ID="grdNotif" runat="server" AutoGenerateColumns="false"
                                BorderWidth="0" CellPadding="4" Font-Size="13px" Width="100%">
                                <Columns>
                                    <asp:BoundField DataField="TRANS_DATE" HeaderText="Date" DataFormatString="{0:MM/dd/yyyy hh:mm tt}" />
                                    <asp:BoundField DataField="AMOUNT" HeaderText="Amount" DataFormatString="{0:N2}" />
                                    <asp:BoundField DataField="RECEIVED_FROM" HeaderText="Received From" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </asp:Panel>
            </div>

            <div class="dashboard-content">
                <div class="section-title" style="margin-bottom: 10px; font-size: 14px; color: var(--text);">📑 Recent Transactions History Log</div>
                <div class="grid-wrap">
                    <asp:GridView ID="grdRecentTrans" runat="server" AutoGenerateColumns="false"
                        BorderWidth="0" CellPadding="6" Font-Size="13px" Width="100%"
                        ShowHeaderWhenEmpty="false">
                        <Columns>
                            <asp:BoundField DataField="TRANS_DATE"    HeaderText="Transaction Date"    DataFormatString="{0:MM/dd/yyyy hh:mm tt}" />
                            <asp:BoundField DataField="TRANS_TYPE"    HeaderText="Operation Type" />
                            <asp:BoundField DataField="AMOUNT"        HeaderText="Amount Transacted"  DataFormatString="{0:N2}" />
                            <asp:BoundField DataField="BALANCE_AFTER" HeaderText="Running Balance Available" DataFormatString="{0:N2}" />
                        </Columns>
                    </asp:GridView>
                </div>
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
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            document.querySelector('.theme-btn').textContent = '☀️';
        }
    </script>
</body>
</html>
