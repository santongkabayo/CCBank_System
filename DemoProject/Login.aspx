<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DemoProject.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title>CCBank - Login</title>
    <style>
        :root {
            --bg: linear-gradient(135deg, #f4a58a 0%, #f0a070 25%, #f5b942 60%, #f9c85a 100%);
            --card: rgba(255,255,255,0.95);
            --text: #2c3e50;
            --subtext: #666;
            --input-bg: #fff;
            --input-border: #ddd;
            --label: #555;
            --result-bg: #fff8f0;
            --link: #e67e22;
            --hint: #aaa;
        }
        body.dark {
            --bg: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            --card: rgba(30,30,50,0.97);
            --text: #f0f0f0;
            --subtext: #aaa;
            --input-bg: #2a2a3e;
            --input-border: #444;
            --label: #ccc;
            --result-bg: #2a2a3e;
            --link: #f5b942;
            --hint: #777;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; transition: background 0.3s, color 0.3s; }
        body {
            font-family: Arial, sans-serif;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: var(--bg);
        }
        .theme-toggle {
            position: fixed; top: 16px; right: 16px;
            background: rgba(255,255,255,0.2);
            border: none; border-radius: 20px;
            padding: 8px 14px; cursor: pointer;
            font-size: 18px; backdrop-filter: blur(4px);
            z-index: 999;
        }
        .container {
            width: 440px;
            background: var(--card);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        }
        .logo-area {
            text-align: center; margin-bottom: 10px;
        }
        .logo-area img {
            width: 120px; height: 120px; object-fit: contain;
        }
        .logo-area h1 {
            color: var(--text); font-size: 22px; margin-top: 8px;
        }
        .logo-area p {
            color: var(--subtext); font-size: 12px; margin-top: 2px;
        }
        .divider {
            border: none; border-top: 1px solid var(--input-border);
            margin: 16px 0;
        }
        .row { margin-bottom: 16px; }
        .label {
            display: block; font-weight: bold;
            color: var(--label); margin-bottom: 6px; font-size: 13px;
        }
        .input-wrap { position: relative; }
        .input-wrap input {
            width: 100%; padding: 10px 40px 5px 5px;
            border: 1.5px solid var(--input-border);
            border-radius: 8px; font-size: 14px;
            background: var(--input-bg); color: var(--text);
        }
        .input-wrap input:focus {
            border-color: #f0a070; outline: none;
            box-shadow: 0 0 0 3px rgba(240,160,112,0.15);
        }
        .toggle-pw {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            cursor: pointer; font-size: 16px;
            background: none; border: none;
            color: var(--hint);
        }
        .btn-row { display: flex; gap: 10px; margin-top: 8px; }
        .btn-primary {
            flex: 2;
            background: linear-gradient(135deg, #f0a070, #f5b942);
            color: white; padding: 12px; border: none;
            border-radius: 8px; cursor: pointer;
            font-size: 15px; font-weight: bold;
            box-shadow: 0 4px 15px rgba(240,160,112,0.4);
        }
        .btn-primary:hover { opacity: 0.88; transform: translateY(-1px); }
        .btn-secondary {
            flex: 1; background: var(--input-bg);
            color: var(--label); padding: 12px;
            border: 1.5px solid var(--input-border);
            border-radius: 8px; cursor: pointer; font-size: 14px;
        }
        .btn-secondary:hover { opacity: 0.8; }
        .result {
            margin-top: 14px; padding: 10px 14px;
            background: var(--result-bg);
            border-left: 4px solid #f0a070;
            border-radius: 6px; font-size: 13px; min-height: 20px;
            color: var(--text);
        }
        .link-row {
            margin-top: 16px; font-size: 13px;
            color: var(--subtext); text-align: center;
        }
        .link-row a {
            color: var(--link); text-decoration: none; font-weight: bold;
        }
        .link-row a:hover { text-decoration: underline; }
        .error { color: #e74c3c; font-size: 13px; }
    </style>
</head>
<body>
    <button class="theme-toggle" onclick="toggleTheme()">🌑</button>
    <form id="form1" runat="server">
        <div class="container">
            <div class="logo-area">
                <img src="CC bank.png" alt="CCBank Logo" />
                <h1>CCBank Login</h1>
                <p>Secure Online Banking</p>
            </div>
            <hr class="divider" />

            <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                ForeColor="Red" CssClass="error"
                HeaderText="Please correct the following errors:" />

            <div class="row">
                <span class="label">Username</span>
                <div class="input-wrap">
                    <asp:TextBox ID="txtUsername" runat="server" MaxLength="50"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                        ControlToValidate="txtUsername"
                        ErrorMessage="Username is required." ForeColor="Red" />
                </div>
            </div>

            <div class="row">
                <span class="label">Password</span>
                <div class="input-wrap">
                    <div class="input-wrap">
    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
    <button type="button" class="toggle-pw" onclick="togglePw(null, this)">🙈</button>
</div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                        ControlToValidate="txtPassword"
                        ErrorMessage="Password is required." ForeColor="Red" />
                </div>
            </div>

            <div class="btn-row">
                <asp:Button ID="btnLogin" runat="server" Text="Login"
                    OnClick="btnLogin_Click" CssClass="btn-primary" />
                <asp:Button ID="btnClear" runat="server" Text="Clear"
                    OnClick="btnClear_Click" CausesValidation="false" CssClass="btn-secondary" />
            </div>

            <div class="result">
                <asp:Label ID="lblResult" runat="server"></asp:Label>
            </div>

            <div class="link-row">
                No account yet? <a href="Registration.aspx">Register here</a> 
                </br></br>
                <a href="ForgotPassword.aspx" style="color:#aaa;font-size:12px;">Forgot Password?</a>
            </div>
        </div>
    </form>

    <script>
        // Dark/Light mode
        function toggleTheme() {
            document.body.classList.toggle('dark');
            var btn = document.querySelector('.theme-toggle');
            btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        // Load saved theme
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            document.querySelector('.theme-toggle').textContent = '☀️';
        }

        // Show/Hide password
        function togglePw(inputId, btn) {
            var input = document.getElementById('<%= txtPassword.ClientID %>');
            if (input.type === 'password') {
                input.type = 'text';
                btn.textContent = '🙈';
            } else {
                input.type = 'password';
                btn.textContent = '👁️';
            }
        }
    </script>
</body>
</html>
