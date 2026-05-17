<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="DemoProject.Logout" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CCBank - Logout</title>
    <style>
        :root { --bg:#f5f0e8; --card:#fff; --text:#2c3e50; --subtext:#666; --border:#e0d0c0; }
        body.dark { --bg:#0f0f1a; --card:#1e1e30; --text:#f0f0f0; --subtext:#aaa; --border:#333; }
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
    </style>
</head>
<body>
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
        if (localStorage.getItem('theme') === 'dark')
            document.body.classList.add('dark');
    </script>
</body>
</html>
