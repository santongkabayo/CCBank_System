<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="DemoProject.ForgotPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     <title>CC Bank - Forgot Password</title>
    <style>
        :root { --bg:linear-gradient(135deg,#f4a58a 0%,#f0a070 25%,#f5b942 60%,#f9c85a 100%); --card:rgba(255,255,255,0.95); --text:#2c3e50; --subtext:#666; --input-bg:#fff; --input-border:#ddd; --label:#555; --result-bg:#fff8f0; --link:#e67e22; }
        body.dark { --bg:linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%); --card:rgba(30,30,50,0.97); --text:#f0f0f0; --subtext:#aaa; --input-bg:#2a2a3e; --input-border:#444; --label:#ccc; --result-bg:#2a2a3e; --link:#f5b942; }
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
        .step.done { background:#27ae60; color:white; }
        .row { margin-bottom:14px; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        input[type="text"], input[type="email"] { width:100%; padding:11px 14px; border:1.5px solid var(--input-border); border-radius:8px; font-size:14px; background:var(--input-bg); color:var(--text); }
        input[type="text"]:focus, input[type="email"]:focus { border-color:#f0a070; outline:none; box-shadow:0 0 0 3px rgba(240,160,112,0.15); }
        .btn-primary { width:100%; background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; margin-top:8px; }
        .btn-primary:hover { opacity:0.88; }
        .result { margin-top:14px; padding:10px 14px; background:var(--result-bg); border-left:4px solid #f0a070; border-radius:6px; font-size:13px; min-height:20px; color:var(--text); }
        .link-row { margin-top:14px; font-size:13px; color:var(--subtext); text-align:center; }
        .link-row a { color:var(--link); text-decoration:none; font-weight:bold; }
        .error { color:#e74c3c; font-size:13px; }
    </style>
</head>
<body>
    <button class="theme-toggle" onclick="toggleTheme()">🌑</button>
    <form id="form1" runat="server">
    <div class="container">
        <div class="logo-area">
            <img src="CC bank.png" alt="CCBank" />
            <h1>Forgot Password</h1>
            <p>Enter your registered email to recover your account</p>
        </div>
        <hr class="divider" />

        <!-- Step indicators -->
        <div class="steps">
            <div class="step active">1</div>
            <div class="step">2</div>
            <div class="step">3</div>
        </div>

        <asp:ValidationSummary ID="ValidationSummary1" runat="server"
            ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

        <div class="row">
            <span class="label">📧 Registered Email Address</span>
            <asp:TextBox ID="txtEmail" runat="server" MaxLength="100"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                ControlToValidate="txtEmail" ErrorMessage="Email is required." ForeColor="Red" />
            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                ControlToValidate="txtEmail"
                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                ErrorMessage="Please enter a valid email." ForeColor="Red" />
        </div>

        <asp:Button ID="btnNext" runat="server" Text="Next →"
            OnClick="btnNext_Click" CssClass="btn-primary" />

        <div class="result">
            <asp:Label ID="lblResult" runat="server"></asp:Label>
        </div>

        <div class="link-row">
            <a href="Login.aspx">← Back to Login</a>
        </div>
    </div>
    </form>
    <script>
        function toggleTheme() {
            document.body.classList.toggle('dark');
            document.querySelector('.theme-toggle').textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        if (localStorage.getItem('theme') === 'dark') { document.body.classList.add('dark'); document.querySelector('.theme-toggle').textContent = '☀️'; }
    </script>
</body>
</html>
