<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="DemoProject.Dashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <title>CCBank - Dashboard</title>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
            --shadow: rgba(0,0,0,0.08);
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
            --shadow: rgba(0,0,0,0.3);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            transition: background 0.4s, color 0.4s;
        }

        /* ── NAVBAR ── */
        .navbar {
            background: var(--navbar);
            padding: 0 30px;
            display: flex; align-items: center;
            justify-content: space-between;
            height: 64px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
            position: sticky; top: 0; z-index: 100;
            animation: slideDown 0.5s ease;
        }
        @keyframes slideDown {
            from { transform: translateY(-100%); opacity: 0; }
            to   { transform: translateY(0);     opacity: 1; }
        }
        .navbar-brand { display: flex; align-items: center; gap: 10px; }
        .navbar-brand img {
            width: 80px; height: 80px; object-fit: contain;
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.2));
            transition: transform 0.3s;
        }
        .navbar-brand img:hover { transform: rotate(-5deg) scale(1.1); }
        .navbar-brand span { color: white; font-size: 18px; font-weight: bold; letter-spacing: 1px; }
        .navbar-links { display: flex; align-items: center; gap: 4px; }
        .navbar-links a {
            color: rgba(255,255,255,0.9);
            text-decoration: none; font-size: 13px;
            padding: 8px 12px; border-radius: 8px;
            transition: background 0.2s, transform 0.2s;
            position: relative;
        }
        .navbar-links a::after {
            content: '';
            position: absolute; bottom: 4px; left: 50%; right: 50%;
            height: 2px; background: white; border-radius: 2px;
            transition: left 0.2s, right 0.2s;
        }
        .navbar-links a:hover::after { left: 12px; right: 12px; }
        .navbar-links a:hover { background: rgba(255,255,255,0.15); transform: translateY(-1px); }
        .navbar-links a.active { background: rgba(255,255,255,0.25); font-weight: bold; }
        .navbar-links .btn-logout {
            background: rgba(231,76,60,0.85);
            color: white; padding: 7px 14px;
            border-radius: 8px; font-size: 13px;
            text-decoration: none; font-weight: bold;
            margin-left: 6px;
            transition: background 0.2s, transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 2px 8px rgba(231,76,60,0.3);
        }
        .navbar-links .btn-logout:hover {
            background: rgba(192,57,43,0.95);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(231,76,60,0.4);
        }
        .theme-btn {
            background: rgba(255,255,255,0.2);
            border: none; border-radius: 20px;
            padding: 6px 12px; cursor: pointer;
            font-size: 16px; color: white; margin-left: 8px;
            transition: background 0.2s, transform 0.3s;
        }
        .theme-btn:hover { background: rgba(255,255,255,0.3); transform: rotate(20deg); }

        /* ── MAIN LAYOUT ── */
        .main {
            max-width: 1420px;
            margin: 0 auto;
            padding: 30px 24px;
            animation: fadeInUp 0.6s ease;
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(24px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .welcome-text {
            font-size: 24px; font-weight: bold;
            color: var(--text); margin-bottom: 24px;
            animation: fadeInUp 0.5s ease 0.1s both;
        }
        .welcome-text span { color: var(--accent); }

        .dashboard-grid {
            display: grid;
            grid-template-columns: 420px 1fr;
            gap: 24px;
            align-items: start;
        }
        .dashboard-sidebar { display: flex; flex-direction: column; gap: 20px; }

        /* ── CARDS ── */
        .cards-stack { display: flex; flex-direction: column; gap: 16px; }
        .card {
            background: var(--card);
            border-radius: 16px; padding: 20px 22px;
            box-shadow: 0 4px 20px var(--shadow);
            border: 1px solid var(--border);
            display: flex; align-items: center; gap: 16px;
            transition: transform 0.25s, box-shadow 0.25s;
            animation: fadeInUp 0.5s ease both;
        }
        .card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px var(--shadow);
        }
        .card:nth-child(1) { animation-delay: 0.1s; }
        .card:nth-child(2) { animation-delay: 0.2s; }
        .card:nth-child(3) { animation-delay: 0.3s; }

        .card-details { flex: 1; }
        .card-label { font-size: 11px; color: var(--muted); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
        .card-value { font-size: 22px; font-weight: bold; color: var(--text); }
        .card-value.green { color: var(--green); }
        .card-value.red { color: var(--red); }
        .card-icon {
            font-size: 28px;
            display: flex; align-items: center; justify-content: center;
            width: 52px; height: 52px;
            background: var(--bg); border-radius: 12px;
            transition: transform 0.3s;
        }
        .card:hover .card-icon { transform: scale(1.15) rotate(-5deg); }

        .card.accent-card {
            background: linear-gradient(135deg, #f0a070, #f5b942);
            border: none;
            box-shadow: 0 6px 24px rgba(245,185,66,0.35);
        }
        .card.accent-card:hover { box-shadow: 0 12px 32px rgba(245,185,66,0.5); }
        .card.accent-card .card-icon { background: rgba(255,255,255,0.25); }
        .card.accent-card .card-label,
        .card.accent-card .card-value { color: white; }

        /* ── INFO BOX ── */
        .info-box {
            background: var(--card); border-radius: 16px; padding: 22px;
            box-shadow: 0 4px 20px var(--shadow);
            border: 1px solid var(--border);
            transition: transform 0.25s, box-shadow 0.25s;
            animation: fadeInUp 0.5s ease 0.3s both;
        }
        .info-box:hover { transform: translateY(-2px); box-shadow: 0 8px 24px var(--shadow); }
        .info-box h3 { font-size: 13px; color: var(--accent); margin-bottom: 14px; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-box h4 { font-size: 13px; color: var(--accent); margin-bottom: 14px; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-table { width: 100%; border-collapse: collapse; }
        .info-table td { padding: 10px 6px; font-size: 14px; color: var(--text); border-bottom: 1px solid var(--border); transition: background 0.2s; }
        .info-table tr:hover td { background: var(--hover); }
        .info-table td:first-child { font-weight: bold; color: var(--subtext); width: 130px; font-size: 13px; }
        .info-table tr:last-child td { border-bottom: none; }

        /* ── QUICK ACTIONS ── */
        .section-title { font-size: 12px; font-weight: bold; color: var(--muted); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 10px; }
        .actions-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
        .action-btn {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            background: var(--card); border: 1px solid var(--border);
            border-radius: 14px; padding: 16px 8px;
            text-decoration: none; color: var(--text);
            font-size: 12px; font-weight: bold;
            box-shadow: 0 2px 8px var(--shadow);
            transition: transform 0.25s, box-shadow 0.25s, background 0.2s;
            text-align: center; position: relative; overflow: hidden;
        }
        .action-btn::before {
            content: '';
            position: absolute; inset: 0;
            background: var(--hover);
            opacity: 0;
            transition: opacity 0.2s;
        }
        .action-btn:hover::before { opacity: 1; }
        .action-btn:hover {
            transform: translateY(-4px) scale(1.03);
            box-shadow: 0 10px 24px var(--shadow);
        }
        .action-btn:active { transform: scale(0.97); }
        .action-btn .icon {
            font-size: 24px; margin-bottom: 6px;
            transition: transform 0.3s;
            position: relative;
        }
        .action-btn:hover .icon { transform: scale(1.2) rotate(-8deg); }
        .action-btn.deposit .icon { color: var(--green); }
        .action-btn.withdraw .icon { color: var(--red); }
        .action-btn.send .icon { color: var(--blue); }
        .action-btn.statement .icon { color: var(--accent); }

        /* ── DASHBOARD CONTENT ── */
        .dashboard-content {
            display: flex; flex-direction: column; gap: 24px;
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px; padding: 24px;
            box-shadow: 0 4px 20px var(--shadow);
            min-height: 500px;
            animation: fadeInUp 0.5s ease 0.2s both;
            transition: box-shadow 0.25s;
        }
        .dashboard-content:hover { box-shadow: 0 8px 32px var(--shadow); }

        /* ── CHART CONTAINER ── */
        .chart-container {
            width: 100%;
            height: 240px;
            position: relative;
            background: rgba(255,255,255,0.02);
            border-radius: 12px;
            padding: 10px;
            border: 1px dashed var(--border);
        }

        /* ── NOTIF BOX ── */
        .notif-box {
            background: var(--card); border-radius: 14px;
            padding: 18px 22px;
            border-left: 4px solid #f5b942;
            box-shadow: 0 4px 16px var(--shadow);
            animation: pulse-border 2s ease infinite;
        }
        @keyframes pulse-border {
            0%, 100% { border-left-color: #f5b942; }
            50%       { border-left-color: #f0a070; }
        }

        /* ── TABLE ── */
        .grid-wrap { overflow-x: auto; border-radius: 10px; border: 1px solid var(--border); }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        table th {
            background: linear-gradient(135deg, #f0a070, #f5b942);
            color: white; padding: 12px; text-align: left; font-weight: bold;
        }
        body.dark table th { background: linear-gradient(135deg, #16213e, #1a1a2e); }
        table td {
            padding: 12px; border-bottom: 1px solid var(--border);
            color: var(--text);
            transition: background 0.15s;
        }
        table tr:last-child td { border-bottom: none; }
        table tr { transition: background 0.15s; }
        table tbody tr:hover td { background: var(--hover); }

        /* ── RESPONSIVE ── */
        @media (max-width: 1024px) {
            .dashboard-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 480px) {
            .actions-grid { grid-template-columns: repeat(2, 1fr); }
        }

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
        @keyframes spin { to { transform: rotate(360deg); } }
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
            <a href="Dashboard.aspx" class="active">🏠 Home</a>
            <a href="AboutContact.aspx">🏢 About & Contact</a>
            <a href="StatementOfAccount.aspx">📄 Statement</a>
            <a href="MyDepositsWithdrawals.aspx">📊 Reports</a>
            <a href="ChangePassword.aspx">🔑 Change Password</a>
            <a href="ChangePIN.aspx">🔐 Change PIN</a>
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
                            <div class="card-value" style="font-size:18px;letter-spacing:0.5px;"><asp:Label ID="lblAccountNo" runat="server"></asp:Label></div>
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
                <div class="section-title" style="font-size:14px;color:var(--text);margin-bottom:2px;">📈 Balance Tracking Analytics</div>
                <div class="chart-container">
                    <canvas id="balanceChart"></canvas>
                </div>

                <div class="section-title" style="font-size:14px;color:var(--text);margin-bottom:2px; margin-top:10px;">📑 Recent Transactions History Log</div>
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
        // Global variables for Chart instance management
        var transactionChart = null;

        // Hide page loader
        window.addEventListener('load', function () {
            var loader = document.getElementById('pageLoader');
            loader.classList.add('hidden');
            setTimeout(function () { loader.style.display = 'none'; }, 400);

            // Generate chart metrics from dynamic table rows
            initChartTrackingSystem();
        });

        // Theme toggle with dynamic chart refreshing
        function toggleTheme() {
            document.body.classList.toggle('dark');
            var btn = document.querySelector('.theme-btn');
            btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');

            // Re-render chart to pick up dark/light text color changes
            initChartTrackingSystem();
        }
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            // Theme button label handling handled below during document parsing if executed early
        }

        // Smooth page navigation with fade-out
        document.querySelectorAll('a[href]').forEach(function (link) {
            if (link.href && !link.href.includes('#') && link.target !== '_blank') {
                link.addEventListener('click', function (e) {
                    e.preventDefault();
                    var href = this.href;
                    document.querySelector('.main').style.opacity = '0';
                    document.querySelector('.main').style.transform = 'translateY(-10px)';
                    document.querySelector('.main').style.transition = 'opacity 0.3s, transform 0.3s';
                    setTimeout(function () { window.location.href = href; }, 280);
                });
            }
        });

        // Count-up animation for balance display
        function animateValue(el, start, end, duration) {
            var startTime = null;
            function step(timestamp) {
                if (!startTime) startTime = timestamp;
                var progress = Math.min((timestamp - startTime) / duration, 1);
                var current = (start + (end - start) * easeOut(progress)).toFixed(2);
                el.textContent = parseFloat(current).toLocaleString('en-PH', { minimumFractionDigits: 2 });
                if (progress < 1) requestAnimationFrame(step);
            }
            requestAnimationFrame(step);
        }
        function easeOut(t) { return 1 - Math.pow(1 - t, 3); }

        window.addEventListener('load', function () {
            if (localStorage.getItem('theme') === 'dark') {
                var btn = document.querySelector('.theme-btn');
                if (btn) btn.textContent = '☀️';
            }
            var balanceEl = document.querySelector('.accent-card .card-value');
            if (balanceEl) {
                var raw = balanceEl.textContent.replace(/[₱,]/g, '').trim();
                var val = parseFloat(raw);
                if (!isNaN(val)) {
                    balanceEl.textContent = '0.00';
                    setTimeout(function () { animateValue(balanceEl, 0, val, 1200); }, 300);
                }
            }
        });

        // ── TRACKING SYSTEM CHART CONFIGURATION ──
        function initChartTrackingSystem() {
            var tableRows = document.querySelectorAll("#grdRecentTrans tr:not(:first-child)");
            var labels = [];
            var balanceData = [];

            // Loop backwards to show tracking chronically (oldest to newest left-to-right)
            for (var i = tableRows.length - 1; i >= 0; i--) {
                var cells = tableRows[i].getElementsByTagName("td");
                if (cells.length >= 4) {
                    // Extract Date and sanitize Balance value
                    var dateText = cells[0].textContent.split(' ')[0]; // Gets short MM/dd format
                    var balValue = parseFloat(cells[3].textContent.replace(/,/g, ''));

                    if (!isNaN(balValue)) {
                        labels.push(dateText);
                        balanceData.push(balValue);
                    }
                }
            }

            // Fallback placeholder data if user has no transactions yet
            if (balanceData.length === 0) {
                labels = ["No Data"];
                balanceData = [0];
            }

            // Detect current theme to match color accents cleanly
            var isDark = document.body.classList.contains('dark');
            var textColor = isDark ? '#f0f0f0' : '#2c3e50';
            var gridColor = isDark ? 'rgba(255,255,255,0.07)' : 'rgba(0,0,0,0.05)';
            var lineAccent = isDark ? '#f5b942' : '#e67e22';

            var ctx = document.getElementById('balanceChart').getContext('2d');

            // Clean up existing instances if resetting layouts or toggling themes
            if (transactionChart) {
                transactionChart.destroy();
            }

            transactionChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Running Balance Available (₱)',
                        data: balanceData,
                        borderColor: lineAccent,
                        borderWidth: 3,
                        backgroundColor: isDark ? 'rgba(245, 185, 66, 0.1)' : 'rgba(230, 126, 34, 0.06)',
                        fill: true,
                        tension: 0.35,
                        pointBackgroundColor: lineAccent,
                        pointHoverRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            labels: { color: textColor, font: { family: 'Segoe UI', size: 11 } }
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    return ' Balance: ₱' + context.parsed.y.toLocaleString('en-PH', { minimumFractionDigits: 2 });
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: { color: gridColor },
                            ticks: { color: textColor, font: { size: 10 } }
                        },
                        y: {
                            grid: { color: gridColor },
                            ticks: {
                                color: textColor,
                                font: { size: 10 },
                                callback: function (value) { return '₱' + value.toLocaleString(); }
                            }
                        }
                    }
                }
            });
        }
    </script>
</body>
</html>
