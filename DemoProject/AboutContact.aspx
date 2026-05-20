<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AboutContact.aspx.cs" Inherits="DemoProject.AboutContact" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CCBank - About & Contact Us</title>
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
        
        .grid-container { display: flex; gap: 40px; margin-top: 20px; flex-wrap: wrap; }
        .col-about { flex: 1.2; min-width: 300px; }
        .col-contact { flex: 1; min-width: 300px; border-left: 1px solid var(--border); padding-left: 40px; }
        
        @media (max-width: 768px) {
            .col-contact { border-left: none; padding-left: 0; border-top: 1px solid var(--border); padding-top: 30px; }
        }

        .section-title { font-size: 20px; color: var(--text); margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
        .about-p { font-size: 14px; color: var(--subtext); line-height: 1.6; margin-bottom: 16px; }
        
        .info-pill-box { display: flex; flex-direction: column; gap: 12px; margin-top: 24px; }
        .info-pill { display: flex; align-items: center; gap: 12px; background: var(--hover); border: 1px solid var(--border); padding: 12px 16px; border-radius: 8px; font-size: 13.5px; }
        .info-pill .pill-icon { font-size: 20px; }
        .info-pill div strong { display: block; color: var(--text); font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 2px; }
        .info-pill div span { color: var(--subtext); }

        .row { margin-bottom: 16px; position: relative; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:6px; font-size:13px; }
        
        input[type="text"], textarea { 
            width:100%; padding:10px 14px; border:1.5px solid var(--input-border); border-radius:8px; font-size:14px; background:var(--input-bg); color:var(--text); font-family: Arial, sans-serif;
            transition: border-color 0.2s, box-shadow 0.2s, transform 0.2s;
        }
        input[type="text"]:focus, textarea:focus { border-color:#f0a070; outline:none; transform: scale(1.01); box-shadow:0 0 0 3px rgba(240,160,112,0.15); }
        textarea { resize: vertical; min-height: 110px; }
        
        .btn-send { 
            width: 100%; background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:14px; font-weight:bold; 
            transition: opacity 0.2s, transform 0.2s, box-shadow 0.2s; margin-top: 8px;
        }
        body.dark .btn-send { background: linear-gradient(135deg,#1a1a2e,#16213e); border: 1px solid var(--border); }
        .btn-send:hover { opacity:0.9; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(240,160,112,0.3); }
        .btn-send:active { transform: scale(0.98); }
        
        .result-msg { margin-top:14px; padding:10px 12px; border-radius:6px; font-size:13px; display: block; min-height: 20px; line-height: 1.5; }
        .error { color:#e74c3c; font-size:13px; display:block; margin-top:4px; }
        .back-link { margin-top:32px; text-align:center; font-size:13px; border-top: 1px solid var(--border); padding-top: 20px; }
        .back-link a { color:var(--accent); text-decoration:none; font-weight:bold; transition: opacity 0.2s, transform 0.2s; display: inline-block; }
        .back-link a:hover { transform: translateY(-1px); opacity: 0.8; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(24px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        .page-loader { position: fixed; inset: 0; background: var(--bg); display: flex; align-items: center; justify-content: center; z-index: 9999; transition: opacity 0.4s; }
        .page-loader.hidden { opacity: 0; pointer-events: none; }
        .loader-spinner { width: 48px; height: 48px; border: 4px solid var(--border); border-top-color: #f0a070; border-radius: 50%; animation: spin 0.8s linear infinite; }
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
            <a href="Logout.aspx" class="btn-logout">🚪 Logout</a>
            <button type="button" class="theme-btn" onclick="toggleTheme()">🌑</button>
        </div>
    </nav>

    <form id="form1" runat="server">
    <div class="main">
        <div class="page-card">
            
            <div class="grid-container">
                <div class="col-about">
                    <h2 class="section-title">🏛️ About CC Bank</h2>
                    <p class="about-p">
                        Welcome to CC Bank, where your money and security are our top priorities. We are committed to providing simple, safe, and reliable banking services for everyone. As technology grows, we continue to improve our services to give our customers a smooth and convenient banking experience.
                    </p>
                    <p class="about-p">
                        Whether you are checking your account, managing your balance, or sending money securely in real time, our system is designed to keep your information safe and our services available anytime you need them.
                    </p>

                    <div class="info-pill-box">
                        <div class="info-pill">
                            <span class="pill-icon">📍</span>
                            <div>
                                <strong>Corporate Headquarters</strong>
                                <span>Colon St., Cebu City, Cebu </span>
                            </div>
                        </div>
                        <div class="info-pill">
                            <span class="pill-icon">📞</span>
                            <div>
                                <strong>Customer Support Center</strong>
                                <span>+63 969 070 5660</span>
                            </div>
                        </div>
                        <div class="info-pill">
                            <span class="pill-icon">✉️</span>
                            <div>
                                <strong>Official Correspondence</strong>
                                <span>ccbanksystem@gmail.com</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-contact">
                    <h2 class="section-title">📩 Contact Support & Suggestions</h2>
                    
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" CssClass="error" HeaderText="Fix the following items:" />

                    <div class="row">
                        <span class="label">Full Name</span>
                        <asp:TextBox ID="txtName" runat="server" placeholder="Enter your complete name" MaxLength="100"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Full Name is required." ForeColor="Red" Display="Dynamic" CssClass="error" />
                    </div>

                    <div class="row">
                        <span class="label">Email Address</span>
                        <asp:TextBox ID="txtEmail" runat="server" placeholder="example@gmail.com" MaxLength="100"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email address is required." ForeColor="Red" Display="Dynamic" CssClass="error" />
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Invalid email address format." ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ForeColor="Red" Display="Dynamic" CssClass="error" />
                    </div>

                    <div class="row">
                        <span class="label">Your Inquiry / Suggestions</span>
                        <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" placeholder="How can we improve the system or help you today?"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="txtMessage" ErrorMessage="Message details are required." ForeColor="Red" Display="Dynamic" CssClass="error" />
                    </div>

                    <asp:Button ID="btnSubmit" runat="server" Text="✉️ Send Message" OnClick="btnSubmit_Click" CssClass="btn-send" />
                    
                    <asp:Label ID="lblStatus" runat="server" CssClass="result-msg" Visible="false"></asp:Label>
                </div>
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

        window.addEventListener('load', function () {
            var loader = document.getElementById('pageLoader');
            if (loader) {
                loader.classList.add('hidden');
                setTimeout(function () { loader.style.display = 'none'; }, 400);
            }
        });

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
