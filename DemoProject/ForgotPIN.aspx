<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPIN.aspx.cs" Inherits="DemoProject.ForgotPIN" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CC Bank - Forgot PIN</title>
    <style>
                :root { --bg:linear-gradient(135deg,#f4a58a 0%,#f0a070 25%,#f5b942 60%,#f9c85a 100%); --card:rgba(255,255,255,0.95); --text:#2c3e50; --subtext:#666; --input-bg:#fff; --input-border:#ddd; --label:#555; --result-bg:#fff8f0; --link:#e67e22; --shadow: rgba(0,0,0,0.08);}
        body.dark { --bg:linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%); --card:rgba(30,30,50,0.97); --text:#f0f0f0; --subtext:#aaa; --input-bg:#2a2a3e; --input-border:#444; --label:#ccc; --result-bg:#2a2a3e; --link:#f5b942; --shadow: rgba(0,0,0,0.3);  }
        * { box-sizing:border-box; margin:0; padding:0; transition:background 0.3s,color 0.3s; }
        body { font-family:Arial,sans-serif; min-height:100vh; display:flex; justify-content:center; align-items:center; background:var(--bg); }
        .theme-toggle { position:fixed; top:16px; right:16px; background:rgba(255,255,255,0.2); border:none; border-radius:20px; padding:8px 14px; cursor:pointer; font-size:18px; z-index:999; }
        .container { width:440px; background:var(--card); border-radius:20px; padding:40px; box-shadow:0 20px 60px rgba(0,0,0,0.2); }
        .logo-area { text-align:center; margin-bottom:20px; }
        .logo-area img { width:80px; height:80px; object-fit:contain; }
        .logo-area h1 { color:var(--text); font-size:20px; margin-top:8px; }
        .logo-area p { color:var(--subtext); font-size:12px; }
        .divider { border:none; border-top:1px solid var(--input-border); margin:14px 0; }
        .steps { display:flex; justify-content:center; gap:8px; margin-bottom:20px; }
        .step { width:28px; height:28px; border-radius:50%; background:#ddd; color:#999; font-size:12px; font-weight:bold; display:flex; align-items:center; justify-content:center; }
        .step.active { background:linear-gradient(135deg,#f0a070,#f5b942); color:white; }
        .row { margin-bottom:14px; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        input[type="text"], input[type="email"] { width:100%; padding:11px 14px; border:1.5px solid var(--input-border); border-radius:8px; font-size:14px; background:var(--input-bg); color:var(--text); }
        input[type="text"]:focus, input[type="email"]:focus { border-color:#f0a070; outline:none; box-shadow:0 0 0 3px rgba(240,160,112,0.15); }
        .btn-primary { width:100%; background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; margin-top:8px; }
        .btn-primary:hover { opacity:0.88; }
        .btn-secondary { width:100%; background:transparent; color:var(--link); padding:12px; border:2px solid var(--link); border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; margin-top:8px; }
        .btn-secondary:hover { background:var(--link); color:white; }
        .or-divider { text-align:center; color:var(--subtext); font-size:13px; margin:10px 0; }
        .result { margin-top:14px; padding:10px 14px; background:var(--result-bg); border-left:4px solid #f0a070; border-radius:6px; font-size:13px; min-height:20px; color:var(--text); }
        .link-row { margin-top:14px; font-size:13px; color:var(--subtext); text-align:center; }
        .link-row a { color:var(--link); text-decoration:none; font-weight:bold; }
        .error { color:#e74c3c; font-size:13px; }
                        /* ── ANIMATIONS ── */
@keyframes slideDown {
    from { transform: translateY(-100%); opacity: 0; }
    to   { transform: translateY(0);     opacity: 1; }
}
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

/* ── NAVBAR ANIMATION ── */
.navbar { animation: slideDown 0.5s ease; }
.navbar-brand img { transition: transform 0.3s; }
.navbar-brand img:hover { transform: rotate(-5deg) scale(1.1); }
.navbar-links a {
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
.navbar-links a:hover { transform: translateY(-1px); }
.navbar-links .btn-logout {
    transition: background 0.2s, transform 0.2s, box-shadow 0.2s;
    box-shadow: 0 2px 8px rgba(231,76,60,0.3);
}
.navbar-links .btn-logout:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(231,76,60,0.4);
}
.theme-btn { transition: background 0.2s, transform 0.3s; }
.theme-btn:hover { background: rgba(255,255,255,0.3); transform: rotate(20deg); }

/* ── MAIN CONTENT ANIMATION ── */
.main { animation: fadeInUp 0.6s ease; }
.page-card { animation: fadeInUp 0.5s ease 0.1s both; }

/* ── CARD HOVER ── */
.card {
    transition: transform 0.25s, box-shadow 0.25s;
}
.card:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 30px var(--shadow);
}
.card-icon { transition: transform 0.3s; }
.card:hover .card-icon { transform: scale(1.15) rotate(-5deg); }

/* ── BUTTON HOVER ── */
.btn-primary {
    transition: opacity 0.2s, transform 0.2s, box-shadow 0.2s;
}
.btn-primary:hover {
    opacity: 0.88;
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(240,160,112,0.4);
}
.btn-primary:active { transform: scale(0.97); }
.btn-secondary { transition: opacity 0.2s, transform 0.2s; }
.btn-secondary:hover { opacity: 0.8; transform: translateY(-1px); }

/* ── TABLE ROW HOVER ── */
table tr { transition: background 0.15s; }
table td { transition: background 0.15s; }

/* ── INFO BOX HOVER ── */
.info-box { transition: transform 0.25s, box-shadow 0.25s; }
.info-box:hover { transform: translateY(-2px); box-shadow: 0 8px 24px var(--shadow); }
.info-table tr { transition: background 0.2s; }
.info-table tr:hover td { background: var(--hover); }

/* ── INPUT FOCUS ── */
input[type="text"], input[type="password"], input[type="email"] {
    transition: border-color 0.2s, box-shadow 0.2s, transform 0.2s;
}
input[type="text"]:focus, input[type="password"]:focus, input[type="email"]:focus {
    transform: scale(1.01);
}

/* ── RESULT LABEL ANIMATION ── */
.result { transition: all 0.3s ease; }

/* ── ACTION BUTTONS ── */
.action-btn {
    transition: transform 0.25s, box-shadow 0.25s;
    position: relative; overflow: hidden;
}
.action-btn::before {
    content: '';
    position: absolute; inset: 0;
    background: var(--hover);
    opacity: 0;
    transition: opacity 0.2s;
}
.action-btn:hover::before { opacity: 1; }
.action-btn:hover { transform: translateY(-4px) scale(1.03); }
.action-btn:active { transform: scale(0.97); }
.action-btn .icon { transition: transform 0.3s; position: relative; }
.action-btn:hover .icon { transform: scale(1.2) rotate(-8deg); }
    </style>
</head>
<body>
    <div class="page-loader" id="pageLoader">
    <div class="loader-spinner"></div>
</div>

    <button class="theme-toggle" onclick="toggleTheme()">🌑</button>
    <form id="form1" runat="server">
    <div class="container">
        <div class="logo-area">
            <img src="CC bank.png" alt="CCBank" />
            <h1>Forgot PIN</h1>
            <p>Enter your registered email to reset your Transaction PIN</p>
        </div>
        <hr class="divider" />

        <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

        <div class="row">
            <span class="label">📧 Registered Email Address</span>
            <asp:TextBox ID="txtEmail" runat="server" MaxLength="100"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." ForeColor="Red" />
            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Please enter a valid email." ForeColor="Red" />
        </div>

        <asp:Button ID="btnSend" runat="server" Text="📧 Send PIN Reset Link" OnClick="btnSend_Click" CssClass="btn-primary" />

        <div class="result">
            <asp:Label ID="lblResult" runat="server"></asp:Label>
        </div>

        <div class="link-row">
            <a href="Login.aspx">← Back to Login</a>
        </div>
    </div>
    </form>
        <script>
            // Hide page loader
            window.addEventListener('load', function () {
                var loader = document.getElementById('pageLoader');
                loader.classList.add('hidden');
                setTimeout(function () { loader.style.display = 'none'; }, 400);
            });

            // Theme toggle
            function toggleTheme() {
                document.body.classList.toggle('dark');
                var btn = document.querySelector('.theme-toggle');  // ← change this
                btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
                localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
            }
            if (localStorage.getItem('theme') === 'dark') {
                document.body.classList.add('dark');
                document.querySelector('.theme-toggle').textContent = '☀️';  // ← and this
            }

            // Smooth page navigation with fade-out
            document.querySelectorAll('a[href]').forEach(function (link) {
                if (link.href && !link.href.includes('#') && link.target !== '_blank') {
                    link.addEventListener('click', function (e) {
                        e.preventDefault();
                        var href = this.href;
                        var main = document.querySelector('.main') || document.querySelector('.page-card') || document.querySelector('.container');
                        if (main) {
                            main.style.opacity = '0';
                            main.style.transform = 'translateY(-10px)';
                            main.style.transition = 'opacity 0.3s, transform 0.3s';
                        }
                        setTimeout(function () { window.location.href = href; }, 280);
                    });
                }
            });
</script>
</body>
</html>
