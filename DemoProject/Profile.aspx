<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="DemoProject.Profile" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CCBank - My Profile</title>
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
        .main { max-width:620px; margin:40px auto; padding:0 20px; }
        .profile-header { background:linear-gradient(135deg,#f0a070,#f5b942); border-radius:16px; padding:30px; text-align:center; margin-bottom:20px; box-shadow:0 4px 20px rgba(0,0,0,0.1); }
        .avatar { width:80px; height:80px; border-radius:50%; background:rgba(255,255,255,0.3); display:flex; align-items:center; justify-content:center; font-size:36px; margin:0 auto 12px; }
        .profile-header h2 { color:white; font-size:22px; }
        .profile-header p { color:rgba(255,255,255,0.85); font-size:13px; margin-top:4px; }
        .page-card { background:var(--card); border-radius:16px; padding:28px; box-shadow:0 4px 20px rgba(0,0,0,0.08); border:1px solid var(--border); margin-bottom:16px; }
        .card-title { font-size:14px; font-weight:bold; color:var(--accent); margin-bottom:16px; text-transform:uppercase; letter-spacing:1px; }
        .info-table { width:100%; border-collapse:collapse; }
        .info-table td { padding:10px 6px; font-size:14px; color:var(--text); border-bottom:1px solid var(--border); }
        .info-table td:first-child { font-weight:bold; color:var(--subtext); width:180px; font-size:13px; }
        .info-table tr:last-child td { border-bottom:none; }
        .divider { border:none; border-top:1px solid var(--border); margin:16px 0; }
        .row { margin-bottom:14px; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        input[type="text"], input[type="email"] { width:100%; padding:10px 14px; border:1.5px solid var(--input-border); border-radius:8px; font-size:14px; background:var(--input-bg); color:var(--text); }
        input[type="text"]:focus, input[type="email"]:focus { border-color:#f0a070; outline:none; }
        .btn-row { display:flex; gap:10px; }
        .btn-primary { flex:2; background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:11px; border:none; border-radius:8px; cursor:pointer; font-size:14px; font-weight:bold; }
        .btn-primary:hover { opacity:0.88; }
        .btn-secondary { flex:1; background:var(--input-bg); color:var(--label); padding:11px; border:1.5px solid var(--input-border); border-radius:8px; cursor:pointer; font-size:14px; }
        .result { margin-top:14px; padding:10px 14px; background:var(--result-bg); border-left:4px solid #f0a070; border-radius:6px; font-size:13px; min-height:20px; color:var(--text); }
        .back-link { margin-top:14px; text-align:center; font-size:13px; }
        .back-link a { color:var(--accent); text-decoration:none; font-weight:bold; }
        .error { color:#e74c3c; font-size:13px; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="navbar-brand">
            <img src="CC bank.png" alt="CCBank" />
            <span>CCBank</span>
        </div>
        <div class="navbar-links">
            <a href="Dashboard.aspx">🏠 Home</a>
            <a href="StatementOfAccount.aspx">📄 Statement</a>
            <a href="MyDepositsWithdrawals.aspx">📊 Reports</a>
            <a href="ChangePassword.aspx">🔑 Change Password</a>
            <a href="ResetPassword.aspx">🔐 Reset Password</a>
            <a href="Logout.aspx" class="btn-logout">🚪 Logout</a>
            <button class="theme-btn" onclick="toggleTheme()">🌙</button>
        </div>
    </nav>

    <form id="form1" runat="server">
    <div class="main">

        <!-- Profile Header -->
        <div class="profile-header">
            <div class="avatar">👤</div>
            <h2><asp:Label ID="lblFullName" runat="server"></asp:Label></h2>
            <p><asp:Label ID="lblAccountNo" runat="server"></asp:Label></p>
        </div>

        <!-- Account Info -->
        <div class="page-card">
            <div class="card-title">📋 Account Information</div>
            <table class="info-table">
                <tr><td>Account No</td><td><asp:Label ID="lblAcctNo" runat="server"></asp:Label></td></tr>
                <tr><td>Username</td><td><asp:Label ID="lblUsername" runat="server"></asp:Label></td></tr>
                <tr><td>Full Name</td><td><asp:Label ID="lblName" runat="server"></asp:Label></td></tr>
                <tr><td>Date Registered</td><td><asp:Label ID="lblDateRegistered" runat="server"></asp:Label></td></tr>
                <tr><td>Email</td><td><asp:Label ID="lblEmail" runat="server"></asp:Label></td></tr>
            </table>
        </div>

        <!-- Edit Email -->
        <div class="page-card">
            <div class="card-title">✏️ Update Email Address</div>

            <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

            <div class="row">
                <span class="label">New Email Address</span>
                <asp:TextBox ID="txtNewEmail" runat="server" MaxLength="100"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                    ControlToValidate="txtNewEmail" ErrorMessage="Email is required." ForeColor="Red" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtNewEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Please enter a valid email address." ForeColor="Red" />
            </div>

            <div class="btn-row">
                <asp:Button ID="btnUpdateEmail" runat="server" Text="💾 Update Email"
                    OnClick="btnUpdateEmail_Click" CssClass="btn-primary" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                    OnClick="btnCancel_Click" CausesValidation="false" CssClass="btn-secondary" />
            </div>

            <div class="result">
                <asp:Label ID="lblResult" runat="server"></asp:Label>
            </div>
        </div>

        <div class="back-link">
            <a href="Dashboard.aspx">← Back to Dashboard</a>
        </div>
    </div>
    </form>

    <script>
        function toggleTheme() {
            document.body.classList.toggle('dark');
            document.querySelector('.theme-btn').textContent = document.body.classList.contains('dark') ? '☀️' : '🌙';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        if (localStorage.getItem('theme') === 'dark') { document.body.classList.add('dark'); document.querySelector('.theme-btn').textContent = '☀️'; }
    </script>
</body>
</html>
