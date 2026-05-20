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
            --shadow: rgba(0,0,0,0.08);
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
            --shadow: rgba(0,0,0,0.3);
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
            transition: background 0.2s, transform 0.3s;
        }
        .theme-toggle:hover { background: rgba(255,255,255,0.3); transform: rotate(20deg); }
        
        .container {
            width: 440px;
            background: var(--card);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            animation: fadeInUp 0.5s ease 0.1s both;
        }
        .logo-area { text-align: center; margin-bottom: 10px; }
        .logo-area img { width: 120px; height: 120px; object-fit: contain; transition: transform 0.3s; }
        .logo-area img:hover { transform: rotate(-5deg) scale(1.05); }
        .logo-area h1 { color: var(--text); font-size: 22px; margin-top: 8px; }
        .logo-area p { color: var(--subtext); font-size: 12px; margin-top: 2px; }
        
        .divider { border: none; border-top: 1px solid var(--input-border); margin: 16px 0; }
        .row { margin-bottom: 16px; }
        .label { display: block; font-weight: bold; color: var(--label); margin-bottom: 6px; font-size: 13px; }
        
        .input-wrap { position: relative; width: 100%; }
        .input-wrap input {
            width: 100%; padding: 12px 42px 12px 12px;
            border: 1.5px solid var(--input-border);
            border-radius: 8px; font-size: 14px;
            background: var(--input-bg); color: var(--text);
            transition: border-color 0.2s, box-shadow 0.2s, transform 0.2s;
        }
        .input-wrap input:focus {
            border-color: #f0a070; outline: none;
            transform: scale(1.01);
            box-shadow: 0 0 0 3px rgba(240,160,112,0.15);
        }
        
        .toggle-pw {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            cursor: pointer; font-size: 16px;
            background: none; border: none;
            color: var(--hint); z-index: 5;
            padding: 4px; outline: none;
        }
        
        .btn-row { display: flex; gap: 10px; margin-top: 8px; }
        .btn-primary {
            flex: 2;
            background: linear-gradient(135deg, #f0a070, #f5b942);
            color: white; padding: 12px; border: none;
            border-radius: 8px; cursor: pointer;
            font-size: 15px; font-weight: bold;
            box-shadow: 0 4px 15px rgba(240,160,112,0.4);
            transition: opacity 0.2s, transform 0.2s, box-shadow 0.2s;
        }
        .btn-primary:hover { opacity: 0.88; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(240,160,112,0.5); }
        .btn-primary:active { transform: scale(0.97); }
        
        .btn-secondary {
            flex: 1; background: var(--input-bg);
            color: var(--label); padding: 12px;
            border: 1.5px solid var(--input-border);
            border-radius: 8px; cursor: pointer; font-size: 14px;
            transition: opacity 0.2s, transform 0.2s;
        }
        .btn-secondary:hover { opacity: 0.8; transform: translateY(-1px); }
        
        .result {
            margin-top: 14px; padding: 10px 14px;
            background: var(--result-bg);
            border-left: 4px solid #f0a070;
            border-radius: 6px; font-size: 13px; min-height: 20px;
            color: var(--text); transition: all 0.3s ease;
        }
        .link-row { margin-top: 16px; font-size: 13px; color: var(--subtext); text-align: center; }
        .link-row a { color: var(--link); text-decoration: none; font-weight: bold; transition: opacity 0.2s; }
        .link-row a:hover { text-decoration: underline; opacity: 0.8; }
        .error { color: #e74c3c; font-size: 13px; display: block; margin-bottom: 10px; }
        
        /* ── ANIMATIONS ── */
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
            border: 4px solid var(--input-border);
            border-top-color: #f0a070;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }
    </style>
</head>
<body>
    <div class="page-loader" id="pageLoader">
        <div class="loader-spinner"></div>
    </div>
    
    <button type="button" class="theme-toggle" onclick="toggleTheme()">🌑</button>
    
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
                    <asp:TextBox ID="txtUsername" runat="server" MaxLength="50" autocomplete="off"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                        ControlToValidate="txtUsername" Display="Dynamic" CssClass="error"
                        ErrorMessage="Username is required." ForeColor="Red" />
                </div>
            </div>

            <div class="row">
                <span class="label">Password</span>
                <div class="input-wrap">
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                    <button type="button" class="toggle-pw" onclick="togglePw()">👁️</button>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                        ControlToValidate="txtPassword" Display="Dynamic" CssClass="error"
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
    <br /><br />
    <a href="ForgotPassword.aspx" style="color:#aaa;font-size:12px;">Forgot Password?</a>
    &nbsp;|&nbsp;
    <a href="ForgotPIN.aspx" style="color:#aaa;font-size:12px;">Forgot PIN?</a>
</div>
        </div>
    </form>

    <script>
        // Smoothly hide page loader on window load
        window.addEventListener('load', function () {
            var loader = document.getElementById('pageLoader');
            if (loader) {
                loader.classList.add('hidden');
                setTimeout(function () { loader.style.display = 'none'; }, 400);
            }
        });

        // Fixed Dynamic Password Visibility Toggle
        function togglePw() {
            const pwInput = document.getElementById('<%= txtPassword.ClientID %>');
            const toggleBtn = document.querySelector('.toggle-pw');

            if (pwInput && toggleBtn) {
                if (pwInput.type === "password") {
                    pwInput.type = "text";
                    toggleBtn.textContent = "🙈";
                } else {
                    pwInput.type = "password";
                    toggleBtn.textContent = "👁️";
                }
            }
        }

        // Theme preference management switcher
        function toggleTheme() {
            document.body.classList.toggle('dark');
            var btn = document.querySelector('.theme-toggle');
            if (btn) btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            var btn = document.querySelector('.theme-toggle');
            if (btn) btn.textContent = '☀️';
        }

        // Outbound transitions handler
        document.querySelectorAll('a[href]').forEach(function (link) {
            if (link.href && !link.href.includes('#') && link.target !== '_blank') {
                link.addEventListener('click', function (e) {
                    e.preventDefault();
                    var href = this.href;
                    var container = document.querySelector('.container');
                    if (container) {
                        container.style.opacity = '0';
                        container.style.transform = 'translateY(-10px)';
                        container.style.transition = 'opacity 0.3s, transform 0.3s';
                    }
                    setTimeout(function () { window.location.href = href; }, 280);
                });
            }
        });
    </script>
</body>
</html>
