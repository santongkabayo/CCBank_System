<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Registration.aspx.cs" Inherits="DemoProject.Registration" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CC Bank - Register</title>
    <style>
        :root { --bg:linear-gradient(135deg,#f4a58a 0%,#f0a070 25%,#f5b942 60%,#f9c85a 100%); --card:rgba(255,255,255,0.95); --text:#2c3e50; --subtext:#666; --input-bg:#fff; --input-border:#ddd; --label:#555; --result-bg:#fff8f0; --link:#e67e22; }
        body.dark { --bg:linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%); --card:rgba(30,30,50,0.97); --text:#f0f0f0; --subtext:#aaa; --input-bg:#2a2a3e; --input-border:#444; --label:#ccc; --result-bg:#2a2a3e; --link:#f5b942; }
        * { box-sizing:border-box; margin:0; padding:0; transition:background 0.3s,color 0.3s; }
        body { font-family:Arial,sans-serif; min-height:100vh; display:flex; justify-content:center; align-items:center; background:var(--bg); padding:30px 0; }
        .theme-toggle { position:fixed; top:16px; right:16px; background:rgba(255,255,255,0.2); border:none; border-radius:20px; padding:8px 14px; cursor:pointer; font-size:18px; z-index:999; }
        .container { width:500px; background:var(--card); border-radius:20px; padding:40px; box-shadow:0 20px 60px rgba(0,0,0,0.2); }
        .logo-area { text-align:center; margin-bottom:20px; }
        .logo-area img { width:80px; height:80px; object-fit:contain; }
        .logo-area h1 { color:var(--text); font-size:20px; margin-top:8px; }
        .logo-area p { color:var(--subtext); font-size:12px; }
        .divider { border:none; border-top:1px solid var(--input-border); margin:14px 0; }
        .section-title { font-size:12px; font-weight:bold; color:#f0a070; text-transform:uppercase; letter-spacing:1px; margin:16px 0 10px 0; }
        .row { margin-bottom:14px; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        .input-wrap { position:relative; }
        .input-wrap input, .input-wrap select { width:100%; padding:10px 40px 10px 14px; border:1.5px solid var(--input-border); border-radius:8px; font-size:14px; background:var(--input-bg); color:var(--text); }
        .input-wrap input:focus, .input-wrap select:focus { border-color:#f0a070; outline:none; box-shadow:0 0 0 3px rgba(240,160,112,0.15); }
        select { padding:10px 14px !important; }
        .toggle-pw { position:absolute; right:12px; top:50%; transform:translateY(-50%); cursor:pointer; font-size:16px; background:none; border:none; color:#aaa; }
        .pin-inputs { display:flex; gap:10px; justify-content:center; margin-top:4px; }
        .pin-inputs input { width:55px; height:55px; text-align:center; font-size:22px; font-weight:bold; border:1.5px solid var(--input-border); border-radius:10px; background:var(--input-bg); color:var(--text); padding:0; }
        .pin-inputs input:focus { border-color:#f0a070; outline:none; }
        .btn-row { display:flex; gap:10px; margin-top:8px; }
        .btn-primary { flex:2; background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; }
        .btn-primary:hover { opacity:0.88; }
        .btn-secondary { flex:1; background:var(--input-bg); color:var(--label); padding:12px; border:1.5px solid var(--input-border); border-radius:8px; cursor:pointer; font-size:14px; }
        .result { margin-top:14px; padding:10px 14px; background:var(--result-bg); border-left:4px solid #f0a070; border-radius:6px; font-size:13px; min-height:20px; color:var(--text); }
        .link-row { margin-top:14px; font-size:13px; color:var(--subtext); text-align:center; }
        .link-row a { color:var(--link); text-decoration:none; font-weight:bold; }
        .error { color:#e74c3c; font-size:13px; }
        .hint { font-size:11px; color:#aaa; margin-top:3px; }
    </style>
</head>
<body>
    <button class="theme-toggle" onclick="toggleTheme()">🌑</button>
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

        <!-- PERSONAL INFO -->
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

        <!-- PASSWORD -->
        <div class="section-title">🔒 Security</div>

        <div class="row">
            <span class="label">Password</span>
            <div class="input-wrap">
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50"></asp:TextBox>
                <button type="button" class="toggle-pw" onclick="togglePw('<%= txtPassword.ClientID %>', this)">👁️</button>
            </div>
            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required." ForeColor="Red" />
            <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,50}$" 
                ErrorMessage="Password must be at least 6 characters long and contain at least one uppercase letter, one lowercase letter, and one number." 
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

        <!-- 4-DIGIT PIN -->
        <div class="row">
            <span class="label">Transaction PIN (4 digits)</span>
            <div class="hint">Used for sending money — keep this private!</div>
            <div class="pin-inputs">
                <input type="password" id="pin1" maxlength="1" oninput="moveFocus(this,'pin2')" />
                <input type="password" id="pin2" maxlength="1" oninput="moveFocus(this,'pin3')" />
                <input type="password" id="pin3" maxlength="1" oninput="moveFocus(this,'pin4')" />
                <input type="password" id="pin4" maxlength="1" oninput="combinePIN()" />
            </div>
            <!-- Replace hdnPIN with this hidden TextBox -->
<asp:TextBox ID="txtPIN" runat="server" style="display:none;"></asp:TextBox>

<!-- Point the validator to the new TextBox ID -->
<asp:RequiredFieldValidator ID="rfvPIN" runat="server" 
    ControlToValidate="txtPIN" 
    ErrorMessage="Transaction PIN (4 digits) is required." 
    ForeColor="Red" />
        </div>

        <!-- SECRET QUESTION -->
        <div class="section-title">❓ Account Recovery</div>

        <div class="row">
            <span class="label">Secret Question</span>
            <div class="input-wrap">
                <asp:DropDownList ID="ddlSecretQuestion" runat="server" style="width:100%;padding:10px 14px;border:1.5px solid #ddd;border-radius:8px;font-size:14px;">
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
        function toggleTheme() {
            document.body.classList.toggle('dark');
            document.querySelector('.theme-toggle').textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        if (localStorage.getItem('theme') === 'dark') { document.body.classList.add('dark'); document.querySelector('.theme-toggle').textContent = '☀️'; }

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
    </script>
</body>
</html>
