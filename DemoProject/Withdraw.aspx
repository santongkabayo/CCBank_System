<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Withdraw.aspx.cs" Inherits="DemoProject.Withdraw" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CC Bank - Withdraw</title>
    <style>
        :root { 
            --bg: #f5f0e8; 
            --card: #fff; 
            --text: #2c3e50; 
            --subtext: #666; 
            --border: #e0d0c0; 
            --accent: #e74c3c; 
            --input-bg: #fff; 
            --input-border: #ddd; 
            --label: #555; 
            --muted: #999; 
            --hover: #fff8f0; 
            --shadow: rgba(0,0,0,0.08);
        }
        body.dark { 
            --bg: #0f0f1a; 
            --card: #1e1e30; 
            --text: #f0f0f0; 
            --subtext: #aaa; 
            --border: #333; 
            --accent: #e74c3c; 
            --input-bg: #2a2a3e; 
            --input-border: #444; 
            --label: #ccc; 
            --result-bg: #2a2a3e; 
            --hover: #2a2a3e; 
            --shadow: rgba(0,0,0,0.3);
        }
        
        * { box-sizing:border-box; margin:0; padding:0; transition:background 0.3s,color 0.3s; }
        body { font-family:Arial,sans-serif; background:var(--bg); color:var(--text); min-height:100vh; }
        
        .navbar { background:linear-gradient(135deg,#f0a070,#f5b942); padding:0 30px; display:flex; align-items:center; justify-content:space-between; height:64px; box-shadow:0 2px 12px rgba(0,0,0,0.15); position:sticky; top:0; z-index:100; }
        body.dark .navbar { background:linear-gradient(135deg,#1a1a2e,#16213e); }
        .navbar-brand { display:flex; align-items:center; gap:10px; }
        .navbar-brand img { width:80px; height:80px; object-fit:contain; transition: transform 0.3s; }
        .navbar-brand img:hover { transform: rotate(-5deg) scale(1.05); }
        .navbar-brand span { color:white; font-size:18px; font-weight:bold; }
        .navbar-links { display:flex; align-items:center; gap:6px; }
        .navbar-links a { color:rgba(255,255,255,0.9); text-decoration:none; font-size:13px; padding:8px 12px; border-radius:6px; transition: background 0.2s, transform 0.2s; }
        .navbar-links a:hover { background:rgba(255,255,255,0.2); transform: translateY(-1px); }
        .navbar-links .btn-logout { background:rgba(231,76,60,0.8); color:white; padding:7px 14px; border-radius:6px; font-size:13px; text-decoration:none; font-weight:bold; margin-left:6px; }
        .navbar-links .btn-logout:hover { background:rgba(231,76,60,1); }
        
        .theme-btn { background:rgba(255,255,255,0.2); border:none; border-radius:20px; padding:6px 12px; cursor:pointer; font-size:16px; color:white; margin-left:8px; transition: background 0.2s, transform 0.3s; }
        .theme-btn:hover { background: rgba(255,255,255,0.3); transform: rotate(20deg); }
        
        .main { max-width:560px; margin:40px auto; padding:0 20px; }
        .page-card { background:var(--card); border-radius:16px; padding:32px; box-shadow:0 4px 20px rgba(0,0,0,0.1); border:1px solid var(--border); animation: fadeInUp 0.5s ease 0.1s both; }
        
        .page-title { display:flex; align-items:center; gap:10px; margin-bottom:24px; }
        .page-title .icon { font-size:30px; }
        .page-title h2 { color:var(--text); font-size:20px; }
        
        .info-row { display:flex; justify-content:space-between; background:var(--hover); border-radius:8px; padding:12px 16px; margin-bottom:12px; font-size:14px; border:1px solid var(--border); transition: transform 0.2s; }
        .info-row:hover { transform: translateX(2px); }
        .info-row span:first-child { color:var(--subtext); }
        .info-row span:last-child { font-weight:bold; color:#e74c3c; }
        
        .divider { border:none; border-top:1px solid var(--border); margin:16px 0; }
        .row { margin-bottom:14px; position:relative; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        
        input[type="text"] { 
            width:100%; padding:10px 14px; border:1.5px solid var(--input-border); border-radius:8px; font-size:14px; background:var(--input-bg); color:var(--text); 
            transition: border-color 0.2s, box-shadow 0.2s, transform 0.2s;
        }
        input[type="text"]:focus { border-color:#e74c3c; outline:none; transform: scale(1.01); box-shadow:0 0 0 3px rgba(231,76,60,0.15); }
        
        .hint { font-size:11px; color:var(--muted); margin-top:4px; margin-bottom:4px; }
        
        .pin-section { background:var(--hover); border:1px solid var(--border); border-radius:10px; padding:16px; margin-bottom:14px; text-align:center; transition: transform 0.2s; }
        .pin-section:hover { transform: translateY(-1px); }
        .pin-section .pin-label { font-weight:bold; color:var(--label); font-size:13px; margin-bottom:10px; display:block; }
        
        .pin-inputs { display:flex; gap:10px; justify-content:center; margin-top:6px; }
        .pin-inputs input { 
            width:60px; height:60px; text-align:center; font-size:22px; font-weight:bold; border:1.5px solid var(--input-border); border-radius:10px; background:var(--input-bg); color:var(--text); 
            transition: border-color 0.2s, box-shadow 0.2s, transform 0.2s;
        }
        .pin-inputs input:focus { border-color:#e74c3c; outline:none; transform: scale(1.05); box-shadow:0 0 0 3px rgba(231,76,60,0.15); }
        
        .btn-row { display:flex; gap:10px; margin-top:16px; }
        .btn-primary { 
            flex:2; background:linear-gradient(135deg,#e74c3c,#c0392b); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; 
            transition: opacity 0.2s, transform 0.2s, box-shadow 0.2s;
        }
        .btn-primary:hover { opacity:0.88; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(231,76,60,0.3); }
        .btn-primary:active { transform: scale(0.98); }
        
        .btn-secondary { 
            flex:1; background:var(--input-bg); color:var(--label); padding:12px; border:1.5px solid var(--input-border); border-radius:8px; cursor:pointer; font-size:14px; 
            transition: border-color 0.2s, background-color 0.2s, color 0.2s, transform 0.2s;
        }
        .btn-secondary:hover { border-color: #e74c3c; color: #e74c3c; background-color: var(--hover); transform: translateY(-1px); }
        .btn-secondary:active { transform: scale(0.97); }
        
        .result { margin-top:14px; padding:12px 14px; background:var(--result-bg); border-left:4px solid #e74c3c; border-radius:6px; font-size:13px; min-height:20px; color:var(--text); transition: all 0.3s ease; }
        .back-link { margin-top:14px; text-align:center; font-size:13px; }
        .back-link a { color:#e67e22; text-decoration:none; font-weight:bold; transition: opacity 0.2s, transform 0.2s; display: inline-block; }
        .back-link a:hover { transform: translateY(-1px); opacity: 0.8; }
        .error { color:#e74c3c; font-size:13px; display:block; margin-top:4px; }
        .hidden-validator-input { opacity:0 !important; position:absolute !important; z-index:-1 !important; height:0 !important; width:0 !important; padding:0 !important; margin:0 !important; border:none !important; }

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
            border: 4px solid var(--border);
            border-top-color: #e74c3c;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }
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
        <div class="navbar-links">
            <a href="Dashboard.aspx">🏠 Home</a>
            <a href="StatementOfAccount.aspx">📄 Statement</a>
            <a href="MyDepositsWithdrawals.aspx">📊 Reports</a>
            <a href="Logout.aspx" class="btn-logout">🚪 Logout</a>
            <button type="button" class="theme-btn" onclick="toggleTheme()">🌑</button>
        </div>
    </nav>

    <form id="form1" runat="server">
    <div class="main">
        <div class="page-card">
            <div class="page-title">
                <span class="icon">🏧</span>
                <h2>Withdraw</h2>
            </div>

            <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:" />

            <div class="info-row">
                <span>Account No</span>
                <span><asp:Label ID="lblAccountNo" runat="server"></asp:Label></span>
            </div>
            <div class="info-row">
                <span>Current Balance</span>
                <span>₱<asp:Label ID="lblBalance" runat="server"></asp:Label></span>
            </div>

            <hr class="divider" />

            <div class="row">
                <span class="label">Amount to Withdraw</span>
                <input type="text" id="txtAmountDisplay" placeholder="0.00" autocomplete="off" />
                <asp:TextBox ID="txtAmount" runat="server" CssClass="hidden-validator-input"></asp:TextBox>
                <div class="hint">Min: ₱100.00 | Max: ₱50,000.00 per transaction</div>
                <asp:RequiredFieldValidator ID="rfvAmount" runat="server" ControlToValidate="txtAmount" ErrorMessage="Amount is required." ForeColor="Red" Display="Dynamic" CssClass="error" />
                <asp:RangeValidator ID="rngAmount" runat="server" ControlToValidate="txtAmount" MinimumValue="100" MaximumValue="50000" Type="Double" ErrorMessage="Amount must be between ₱100.00 and ₱50,000.00." ForeColor="Red" Display="Dynamic" CssClass="error" />
            </div>

            <div class="pin-section">
                <span class="pin-label">🔐 Enter Transaction PIN to Confirm</span>
                <div class="pin-inputs">
                    <asp:TextBox ID="pin1" runat="server" MaxLength="1" CssClass="wd-pin" autocomplete="off" TextMode="Password"></asp:TextBox>
                    <asp:TextBox ID="pin2" runat="server" MaxLength="1" CssClass="wd-pin" autocomplete="off" TextMode="Password"></asp:TextBox>
                    <asp:TextBox ID="pin3" runat="server" MaxLength="1" CssClass="wd-pin" autocomplete="off" TextMode="Password"></asp:TextBox>
                    <asp:TextBox ID="pin4" runat="server" MaxLength="1" CssClass="wd-pin" autocomplete="off" TextMode="Password"></asp:TextBox>
                </div>
            </div>

            <div class="btn-row">
                <asp:Button ID="btnWithdraw" runat="server" Text="🏧 Withdraw" OnClick="btnWithdraw_Click" CssClass="btn-primary" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" CausesValidation="false" CssClass="btn-secondary" />
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
        const realInput = document.getElementById('<%= txtAmount.ClientID %>');
        const displayInput = document.getElementById('txtAmountDisplay');

        if (displayInput && realInput) {
            if (realInput.value) displayInput.value = realInput.value;
            displayInput.addEventListener('input', function () { realInput.value = this.value; });
        }

        document.querySelectorAll('input.wd-pin').forEach(function (el, i, arr) {
            el.addEventListener('input', function () {
                this.value = this.value.replace(/\D/g, ''); // Numeric only
                if (this.value && i < arr.length - 1) arr[i + 1].focus();
            });
            el.addEventListener('keydown', function (e) {
                if (e.key === 'Backspace' && !this.value && i > 0) arr[i - 1].focus();
            });
        });

        function toggleTheme() {
            document.body.classList.toggle('dark');
            var btn = document.querySelector('.theme-btn');
            if (btn) btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            var btn = document.querySelector('.theme-btn');
            if (btn) btn.textContent = '☀️';
        }

        // Handle structural initialization loader removal
        window.addEventListener('load', function () {
            var loader = document.getElementById('pageLoader');
            if (loader) {
                loader.classList.add('hidden');
                setTimeout(function () { loader.style.display = 'none'; }, 400);
            }
        });

        // Track local out-routing hyperlinks for clean page lifecycle transition animations
        document.querySelectorAll('a[href], .navbar-links a').forEach(function (link) {
            if (link.href && !link.href.includes('#') && link.target !== '_blank') {
                link.addEventListener('click', function (e) {
                    e.preventDefault();
                    var href = this.href;
                    var card = document.querySelector('.page-card');
                    if (card) {
                        card.style.opacity = '0';
                        card.style.transform = 'translateY(-12px)';
                        card.style.transition = 'opacity 0.3s, transform 0.3s';
                    }
                    setTimeout(function () { window.location.href = href; }, 280);
                });
            }
        });
    </script>
</body>
</html>
