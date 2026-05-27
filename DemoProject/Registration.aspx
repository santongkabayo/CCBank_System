<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Registration.aspx.cs" Inherits="DemoProject.Registration" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CCBank - Registration</title>
    <style>
        :root {
            --bg: linear-gradient(135deg, #f4a58a 0%, #f0a070 25%, #f5b942 60%, #f9c85a 100%);
            --card: rgba(255,255,255,0.95);
            --text: #2c3e50; --subtext: #666; --border: #e0d0c0;
            --accent: #e67e22; --input-bg: #fff; --input-border: #ddd;
            --label: #555; --muted: #999; --hover: #fff8f0;
            --shadow: rgba(0,0,0,0.08); --link: #e67e22;
        }
        body.dark {
            --bg: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            --card: rgba(30,30,50,0.97);
            --text: #f0f0f0; --subtext: #aaa; --border: #333;
            --accent: #f5b942; --input-bg: #2a2a3e; --input-border: #444;
            --label: #ccc; --hover: #2a2a3e; --shadow: rgba(0,0,0,0.3); --link: #f5b942;
        }
        * { box-sizing:border-box; margin:0; padding:0; transition:background 0.3s,color 0.3s; }
        body {
            font-family:Arial,sans-serif;
            background:var(--bg);
            color:var(--text);
            min-height:100vh;
            display:flex;
            justify-content:center;
            align-items:flex-start;
            padding:40px 20px;
        }
        .theme-toggle {
            position:fixed; top:16px; right:16px;
            background:rgba(255,255,255,0.2);
            border:none; border-radius:20px;
            padding:8px 14px; cursor:pointer;
            font-size:18px; z-index:999;
            transition:background 0.2s, transform 0.3s;
        }
        .theme-toggle:hover { background:rgba(255,255,255,0.3); transform:rotate(20deg); }
        .container {
            width:520px;
            background:var(--card);
            border-radius:20px;
            padding:40px;
            box-shadow:0 20px 60px rgba(0,0,0,0.2);
            margin:0 auto;
            animation:fadeInUp 0.5s ease 0.1s both;
        }
        .logo-area { text-align:center; margin-bottom:20px; }
        .logo-area img { width:80px; height:80px; object-fit:contain; transition:transform 0.3s; }
        .logo-area img:hover { transform:rotate(-5deg) scale(1.05); }
        .logo-area h1 { color:var(--text); font-size:20px; margin-top:8px; }
        .logo-area p { color:var(--subtext); font-size:12px; }
        .divider { border:none; border-top:1px solid var(--input-border); margin:14px 0; }
        .section-title { font-size:12px; font-weight:bold; color:var(--accent); text-transform:uppercase; letter-spacing:1px; margin:16px 0 10px; }
        .row { margin-bottom:14px; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        .input-wrap { position:relative; }
        input[type="text"], input[type="password"] {
            width:100%; padding:12px 42px 12px 12px;
            border:1.5px solid var(--input-border);
            border-radius:8px; font-size:14px;
            background:var(--input-bg); color:var(--text);
            transition:border-color 0.2s, box-shadow 0.2s, transform 0.2s;
        }
        input[type="text"]:focus, input[type="password"]:focus {
            border-color:#f0a070; outline:none;
            transform:scale(1.01);
            box-shadow:0 0 0 3px rgba(240,160,112,0.15);
        }
        .toggle-pw {
            position:absolute; right:12px; top:50%;
            transform:translateY(-50%);
            cursor:pointer; font-size:16px;
            background:none; border:none; color:#aaa;
        }
        .hint { font-size:11px; color:var(--muted); margin-top:4px; }
        .pin-inputs { display:flex; gap:10px; margin-top:8px; justify-content:center; }
        .pin-inputs input {
            width:60px; height:60px; text-align:center;
            font-size:22px; font-weight:bold;
            border:1.5px solid var(--input-border);
            border-radius:10px; background:var(--input-bg); color:var(--text);
            transition:border-color 0.2s, box-shadow 0.2s;
        }
        .pin-inputs input:focus { border-color:#f0a070; outline:none; box-shadow:0 0 0 3px rgba(240,160,112,0.15); }
        .btn-row { display:flex; gap:10px; margin-top:8px; }
        .btn-primary {
            flex:2; background:linear-gradient(135deg,#f0a070,#f5b942);
            color:white; padding:12px; border:none;
            border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold;
            box-shadow:0 4px 15px rgba(240,160,112,0.4);
            transition:opacity 0.2s, transform 0.2s, box-shadow 0.2s;
        }
        .btn-primary:hover { opacity:0.88; transform:translateY(-2px); box-shadow:0 6px 20px rgba(240,160,112,0.5); }
        .btn-primary:active { transform:scale(0.97); }
        .btn-secondary {
            flex:1; background:var(--input-bg); color:var(--label);
            padding:12px; border:1.5px solid var(--input-border);
            border-radius:8px; cursor:pointer; font-size:14px;
            transition:opacity 0.2s, transform 0.2s;
        }
        .btn-secondary:hover { opacity:0.8; transform:translateY(-1px); }
        .result {
            margin-top:14px; padding:10px 14px;
            background:var(--hover); border-left:4px solid #f0a070;
            border-radius:6px; font-size:13px; min-height:20px;
            color:var(--text); transition:all 0.3s ease;
        }
        .link-row { margin-top:14px; font-size:13px; color:var(--subtext); text-align:center; }
        .link-row a { color:var(--link); text-decoration:none; font-weight:bold; }
        .link-row a:hover { text-decoration:underline; opacity:0.8; }
        .error { color:#e74c3c; font-size:13px; }

        /* ── ANIMATIONS ── */
        @keyframes fadeInUp {
            from { opacity:0; transform:translateY(24px); }
            to   { opacity:1; transform:translateY(0); }
        }
        @keyframes spin { to { transform:rotate(360deg); } }

        /* ── PAGE LOADER ── */
        .page-loader {
            position:fixed; inset:0;
            background:var(--bg);
            display:flex; align-items:center; justify-content:center;
            z-index:9999; transition:opacity 0.4s;
        }
        .page-loader.hidden { opacity:0; pointer-events:none; }
        .loader-spinner {
            width:48px; height:48px;
            border:4px solid var(--input-border);
            border-top-color:#f0a070;
            border-radius:50%;
            animation:spin 0.8s linear infinite;
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
            <img src="CC bank.png" alt="CC Bank Logo" />
            <h1>Create Account</h1>
            <p>Join CCBank today</p>
        </div>
        <hr class="divider" />

        <asp:ValidationSummary ID="ValidationSummary1" runat="server"
            ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

        <div class="section-title">👤 Personal Information</div>

        <div class="row">
            <span class="label">Username</span>
            <div class="input-wrap">
                <asp:TextBox ID="txtUsername" runat="server" MaxLength="50"></asp:TextBox>
            </div>
            <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername" ErrorMessage="Username is required." ForeColor="Red" />
            <asp:RegularExpressionValidator ID="revUsername" runat="server" ControlToValidate="txtUsername" ValidationExpression="^[a-zA-Z0-9_]{4,20}$" ErrorMessage="Username: 4-20 letters, numbers or underscore." ForeColor="Red" />
        </div>

        <div class="row">
            <span class="label">Lastname</span>
            <div class="input-wrap">
                <asp:TextBox ID="txtLastname" runat="server" MaxLength="50"></asp:TextBox>
            </div>
            <asp:RequiredFieldValidator ID="rfvLastname" runat="server" ControlToValidate="txtLastname" ErrorMessage="Lastname is required." ForeColor="Red" />
        </div>

        <div class="row">
            <span class="label">Firstname</span>
            <div class="input-wrap">
                <asp:TextBox ID="txtFirstname" runat="server" MaxLength="50"></asp:TextBox>
            </div>
            <asp:RequiredFieldValidator ID="rfvFirstname" runat="server" ControlToValidate="txtFirstname" ErrorMessage="Firstname is required." ForeColor="Red" />
        </div>

        <div class="row">
            <span class="label">Email</span>
            <div class="input-wrap">
                <asp:TextBox ID="txtEmail" runat="server" MaxLength="100"></asp:TextBox>
            </div>
            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." ForeColor="Red" />
            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Please enter a valid email." ForeColor="Red" />
        </div>

        <div class="section-title">🔒 Security</div>

        <div class="row">
            <span class="label">Password</span>
            <div class="input-wrap">
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <button type="button" class="toggle-pw" onclick="togglePw('<%= txtPassword.ClientID %>', this)">👁️</button>
            </div>
            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required." ForeColor="Red" />
            <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,50}$"
                ErrorMessage="Password must be at least 6 characters with uppercase, lowercase, and number."
                ForeColor="Red" Display="Dynamic" />
        </div>

        <div class="row">
            <span class="label">Confirm Password</span>
            <div class="input-wrap">
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <button type="button" class="toggle-pw" onclick="togglePw('<%= txtConfirmPassword.ClientID %>', this)">👁️</button>
            </div>
            <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" ErrorMessage="Please confirm your password." ForeColor="Red" />
            <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword" ErrorMessage="Passwords do not match." ForeColor="Red" />
        </div>

        <div class="row">
            <span class="label">Transaction PIN (4 digits)</span>
            <div class="hint">Used for sending money — keep this private!</div>
            <div class="pin-inputs">
                <input type="password" id="pin1" maxlength="1" oninput="moveFocus(this,'pin2')" />
                <input type="password" id="pin2" maxlength="1" oninput="moveFocus(this,'pin3')" />
                <input type="password" id="pin3" maxlength="1" oninput="moveFocus(this,'pin4')" />
                <input type="password" id="pin4" maxlength="1" oninput="combinePIN()" />
            </div>
            <asp:TextBox ID="txtPIN" runat="server" style="display:none;"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvPIN" runat="server"
                ControlToValidate="txtPIN"
                ErrorMessage="Transaction PIN (4 digits) is required."
                ForeColor="Red" />
        </div>

        <div class="section-title">❓ Account Recovery</div>

        <div class="row">
            <span class="label">Secret Question</span>
            <div class="input-wrap">
                <asp:DropDownList ID="ddlSecretQuestion" runat="server" style="width:100%;padding:10px 14px;border:1.5px solid var(--input-border);border-radius:8px;font-size:14px;background:var(--input-bg);color:var(--text);">
                    <asp:ListItem Value="">-- Select a secret question --</asp:ListItem>
                    <asp:ListItem>What is your mother's maiden name?</asp:ListItem>
                    <asp:ListItem>What was the name of your first pet?</asp:ListItem>
                    <asp:ListItem>What is the name of your elementary school?</asp:ListItem>
                    <asp:ListItem>What was your childhood nickname?</asp:ListItem>
                    <asp:ListItem>What is your favorite food?</asp:ListItem>
                    <asp:ListItem>What city were you born in?</asp:ListItem>
                </asp:DropDownList>
            </div>
            <asp:RequiredFieldValidator ID="rfvSecretQ" runat="server" ControlToValidate="ddlSecretQuestion" InitialValue="" ErrorMessage="Please select a secret question." ForeColor="Red" />
        </div>

        <div class="row">
            <span class="label">Secret Answer</span>
            <div class="input-wrap">
                <asp:TextBox ID="txtSecretAnswer" runat="server" MaxLength="100"></asp:TextBox>
            </div>
            <asp:RequiredFieldValidator ID="rfvSecretA" runat="server" ControlToValidate="txtSecretAnswer" ErrorMessage="Secret answer is required." ForeColor="Red" />
            <div class="hint">Answer is not case sensitive</div>
        </div>

        <div class="btn-row">
            <asp:Button ID="btnRegister" runat="server" Text="Create Account" OnClick="btnRegister_Click" CssClass="btn-primary" />
            <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" CausesValidation="false" CssClass="btn-secondary" />
        </div>

        <div class="result">
            <asp:Label ID="lblResult" runat="server"></asp:Label>
        </div>

        <div class="link-row">
            Already have an account? <a href="Login.aspx">Login here</a>
        </div>
    </div>
    </form>

    <script>
        window.addEventListener('load', function () {
            var loader = document.getElementById('pageLoader');
            if (loader) {
                loader.classList.add('hidden');
                setTimeout(function () { loader.style.display = 'none'; }, 400);
            }
        });

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

        function togglePw(id, btn) {
            var input = document.getElementById(id);
            input.type = input.type === 'password' ? 'text' : 'password';
            btn.textContent = input.type === 'password' ? '👁️' : '🙈';
        }

        function moveFocus(current, nextId) {
            if (current.value.length === 1) {
                var next = document.getElementById(nextId);
                if (next) next.focus();
            }
            combinePIN();
        }

        function combinePIN() {
            var pin = document.getElementById('pin1').value +
                      document.getElementById('pin2').value +
                      document.getElementById('pin3').value +
                      document.getElementById('pin4').value;
            document.getElementById('<%= txtPIN.ClientID %>').value = pin;
        }

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
