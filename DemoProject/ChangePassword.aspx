<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="DemoProject.ChangePassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CCBank - Change Password</title>
    <style>
        :root { --bg:#f5f0e8; --card:#fff; --text:#2c3e50; --subtext:#666; --border:#e0d0c0; --accent:#e67e22; --input-bg:#fff; --input-border:#ddd; --label:#555; --result-bg:#fff8f0; --muted:#999; --hover:#fff8f0; }
        body.dark { --bg:#0f0f1a; --card:#1e1e30; --text:#f0f0f0; --subtext:#aaa; --border:#333; --accent:#f5b942; --input-bg:#2a2a3e; --input-border:#444; --label:#ccc; --result-bg:#2a2a3e; --hover:#2a2a3e; }
        * { box-sizing:border-box; margin:0; padding:0; transition:background 0.3s,color 0.3s; }
        body { font-family:Arial,sans-serif; background:var(--bg); color:var(--text); min-height:100vh; }
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
        .main { max-width:520px; margin:40px auto; padding:0 20px; }
        .page-card { background:var(--card); border-radius:16px; padding:32px; box-shadow:0 4px 20px rgba(0,0,0,0.1); border:1px solid var(--border); }
        .page-title { display:flex; align-items:center; gap:10px; margin-bottom:24px; }
        .page-title .icon { font-size:30px; }
        .page-title h2 { color:var(--text); font-size:20px; }
        .acct-row { background:var(--hover); border-radius:8px; padding:12px 16px; margin-bottom:16px; font-size:14px; border:1px solid var(--border); color:var(--subtext); }
        .acct-row strong { color:var(--accent); }
        .divider { border:none; border-top:1px solid var(--border); margin:16px 0; }
        .row { margin-bottom:14px; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        .input-wrap { position:relative; }
        input[type="password"], input[type="text"] { width:100%; padding:10px 40px 10px 14px; border:1.5px solid var(--input-border); border-radius:8px; font-size:14px; background:var(--input-bg); color:var(--text); }
        input[type="password"]:focus, input[type="text"]:focus { border-color:#f0a070; outline:none; box-shadow:0 0 0 3px rgba(240,160,112,0.15); }
        .toggle-pw { position:absolute; right:12px; top:50%; transform:translateY(-50%); cursor:pointer; font-size:16px; background:none; border:none; color:#aaa; }
        .btn-row { display:flex; gap:10px; margin-top:8px; }
        .btn-primary { flex:2; background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; }
        .btn-primary:hover { opacity:0.88; }
        .btn-secondary { flex:1; background:var(--input-bg); color:var(--label); padding:12px; border:1.5px solid var(--input-border); border-radius:8px; cursor:pointer; font-size:14px; }
        .result { margin-top:14px; padding:12px 14px; background:var(--result-bg); border-left:4px solid #f0a070; border-radius:6px; font-size:13px; min-height:20px; color:var(--text); }
        .back-link { margin-top:14px; text-align:center; font-size:13px; }
        .back-link a { color:var(--accent); text-decoration:none; font-weight:bold; }
        .error { color:#e74c3c; font-size:13px; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">
            <img src="CC bank.png" alt="CCBank" />
            <span>CC Bank</span>
        </div>
        <div class="navbar-links">
            <a href="Dashboard.aspx">🏠 Home</a>
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
        <div class="page-card">
            <div class="page-title">
                <span class="icon">🔑</span>
                <h2>Change Password</h2>
            </div>

            <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

            <div class="acct-row">
                Account No: <strong><asp:Label ID="lblAccountNo" runat="server"></asp:Label></strong>
            </div>

            <div class="row">
                <span class="label">Current Password</span>
                <div class="input-wrap">
                    <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                    <button type="button" class="toggle-pw" onclick="togglePw('<%= txtCurrentPassword.ClientID %>', this)">👁️</button>
                </div>
                <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server"
                    ControlToValidate="txtCurrentPassword" ErrorMessage="Current Password is required." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">New Password</span>
                <div class="input-wrap">
                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                    <button type="button" class="toggle-pw" onclick="togglePw('<%= txtNewPassword.ClientID %>', this)">👁️</button>
                </div>
                <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server"
                    ControlToValidate="txtNewPassword" ErrorMessage="New Password is required." ForeColor="Red" />
                <asp:RegularExpressionValidator ID="revNewPassword" runat="server"
                    ControlToValidate="txtNewPassword" ValidationExpression="^.{6,}$"
                    ErrorMessage="New Password must be at least 6 characters." ForeColor="Red" />
            </div>

            <div class="row">
                <span class="label">Confirm New Password</span>
                <div class="input-wrap">
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                    <button type="button" class="toggle-pw" onclick="togglePw('<%= txtConfirmPassword.ClientID %>', this)">👁️</button>
                </div>
                <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                    ControlToValidate="txtConfirmPassword" ErrorMessage="Please confirm your new password." ForeColor="Red" />
                <asp:CompareValidator ID="cvPassword" runat="server"
                    ControlToValidate="txtConfirmPassword" ControlToCompare="txtNewPassword"
                    ErrorMessage="New passwords do not match." ForeColor="Red" />
            </div>

            <div class="btn-row">
                <asp:Button ID="btnChange" runat="server" Text="🔑 Change Password"
                    OnClick="btnChange_Click" CssClass="btn-primary" />
                <asp:Button ID="btnClear" runat="server" Text="Clear"
                    OnClick="btnClear_Click" CausesValidation="false" CssClass="btn-secondary" />
            </div>

            <div class="result">
                <asp:Label ID="lblResult" runat="server"></asp:Label>
            </div>

            <div class="back-link">
                <a href="Dashboard.aspx">← Back to Dashboard</a>
            </div>
        </div>
    </div>
    </form>

    <script>
        function togglePw(id, btn) {
            var input = document.getElementById(id);
            if (input.type === 'password') { input.type = 'text'; btn.textContent = '🙈'; }
            else { input.type = 'password'; btn.textContent = '👁️'; }
        }
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
