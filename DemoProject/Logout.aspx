<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="DemoProject.Logout" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CCBank - Logout</title>
    <style>
        :root { --bg:#f5f0e8; --card:#fff; --text:#2c3e50; --subtext:#666; --border:#e0d0c0; --hover: #fff8f0;  --shadow: rgba(0,0,0,0.08); }
        body.dark { --bg:#0f0f1a; --card:#1e1e30; --text:#f0f0f0; --subtext:#aaa; --border:#333; --hover: #2a2a3e; --shadow: rgba(0,0,0,0.3); }
        * { box-sizing:border-box; margin:0; padding:0; }
        body { font-family:Arial,sans-serif; background:var(--bg); color:var(--text); min-height:100vh; display:flex; flex-direction:column; }
        .navbar { background:linear-gradient(135deg,#f0a070,#f5b942); padding:0 30px; display:flex; align-items:center; height:64px; box-shadow:0 2px 12px rgba(0,0,0,0.15); }
        body.dark .navbar { background:linear-gradient(135deg,#1a1a2e,#16213e); }
        .navbar-brand { display:flex; align-items:center; gap:10px; }
        .navbar-brand img { width:80px; height:80px; object-fit:contain; }
        .navbar-brand span { color:white; font-size:18px; font-weight:bold; }
        .center { flex:1; display:flex; justify-content:center; align-items:center; }
        .page-card { background:var(--card); border-radius:16px; padding:40px; box-shadow:0 4px 20px rgba(0,0,0,0.1); border:1px solid var(--border); text-align:center; width:380px; }
        .icon { font-size:50px; margin-bottom:16px; }
        h2 { color:var(--text); font-size:22px; margin-bottom:10px; }
        .message { color:var(--subtext); font-size:14px; margin-bottom:28px; }
        .btn-row { display:flex; gap:12px; justify-content:center; }
        .btn-danger { flex:1; background:linear-gradient(135deg,#e74c3c,#c0392b); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:14px; font-weight:bold; }
        .btn-danger:hover { opacity:0.88; }
        .btn-secondary { flex:1; background:var(--border); color:var(--text); padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:14px; }
        .btn-secondary:hover { opacity:0.8; }
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
    <nav class="navbar">
        <div class="navbar-brand">
            <img src="CC bank.png" alt="CCBank" />
            <span>CC Bank</span>
        </div>
    </nav>

    <div class="center">
        <form id="form1" runat="server">
            <div class="page-card">
                <div class="icon">🚪</div>
                <h2>Logout</h2>
                <div class="message">
                    <asp:Label ID="lblMessage" runat="server">Are you sure you want to logout from CCBank?</asp:Label>
                </div>
                <div class="btn-row">
                    <asp:Button ID="btnConfirmLogout" runat="server" Text="Yes, Logout"
                        OnClick="btnConfirmLogout_Click" CssClass="btn-danger" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                        OnClick="btnCancel_Click" CausesValidation="false" CssClass="btn-secondary" />
                </div>
            </div>
        </form>
    </div>

    <script>
        // Hide page loader
        window.addEventListener('load', function () {
            var loader = document.getElementById('pageLoader');
            loader.classList.add('hidden');
            setTimeout(function () { loader.style.display = 'none'; }, 400);
        });

        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
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
