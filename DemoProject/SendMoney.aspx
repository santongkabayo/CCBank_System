<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendMoney.aspx.cs" Inherits="DemoProject.SendMoney" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
      <title>CCBank - Send Money</title>
    <style>
        :root { --bg:#f5f0e8; --card:#fff; --text:#2c3e50; --subtext:#666; --border:#e0d0c0; --accent:#2980b9; --input-bg:#fff; --input-border:#ddd; --label:#555; --result-bg:#fff8f0; --muted:#999; --hover:#fff8f0; --green: #27ae60; }
        body.dark { --bg:#0f0f1a; --card:#1e1e30; --text:#f0f0f0; --subtext:#aaa; --border:#333; --accent:#3498db; --input-bg:#2a2a3e; --input-border:#444; --label:#ccc; --result-bg:#2a2a3e; --hover:#2a2a3e; --green: #2ecc71; }
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
        .main { max-width:580px; margin:40px auto; padding:0 20px; }
        .page-card { background:var(--card); border-radius:16px; padding:32px; box-shadow:0 4px 20px rgba(0,0,0,0.1); border:1px solid var(--border); }
        .page-title { display:flex; align-items:center; gap:10px; margin-bottom:24px; }
        .page-title .icon { font-size:30px; }
        .page-title h2 { color:var(--text); font-size:20px; }
        .info-row { display:flex; justify-content:space-between; background:var(--hover); border-radius:8px; padding:12px 16px; margin-bottom:10px; font-size:14px; border:1px solid var(--border); }
        .info-row span:first-child { color:var(--subtext); }
        .info-row span:last-child { font-weight:bold; color:var(--accent); }
        .divider { border:none; border-top:1px solid var(--border); margin:16px 0; }
        .row { margin-bottom:14px; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        
        /* PIN input field grid layout styling */
        .pin-container { display:flex; gap:12px; justify-content:center; margin:15px 0; }
        .pin-box { width:55px; height:55px; text-align:center; font-size:24px; font-weight:bold; border:2px solid var(--input-border); border-radius:10px; background:var(--input-bg); color:var(--text); }
        .pin-box:focus { border-color:#2980b9; outline:none; box-shadow:0 0 0 3px rgba(41,128,185,0.15); }
        
        input[type="text"] { width:100%; padding:10px 14px; border:1.5px solid var(--input-border); border-radius:8px; font-size:14px; background:var(--input-bg); color:var(--text); }
        input[type="text"]:focus { border-color:#2980b9; outline:none; box-shadow:0 0 0 3px rgba(41,128,185,0.15); }
        .hint { font-size:11px; color:var(--muted); margin-top:4px; margin-bottom: 8px; }
        .recipient-box { background:rgba(39,174,96,0.1); border-left:4px solid var(--green); border-radius:8px; padding:14px; margin-bottom:16px; font-size:14px; color:var(--text); }
        .recipient-box strong { color:var(--green); }
        .btn-search { background:linear-gradient(135deg,#7f8c8d,#95a5a6); color:white; padding:12px 20px; border:none; border-radius:8px; cursor:pointer; font-size:14px; font-weight:bold; width:100%; }
        .btn-search:hover { opacity:0.88; }
        .btn-row { display:flex; gap:10px; margin-top:16px; }
        .btn-primary { flex:1; background:linear-gradient(135deg,#2980b9,#3498db); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; }
        .btn-primary:hover { opacity:0.88; }
        .result { margin-top:14px; padding:12px 14px; background:var(--result-bg); border-left:4px solid #2980b9; border-radius:6px; font-size:13px; min-height:20px; color:var(--text); word-break:break-word; }
        .back-link { margin-top:14px; text-align:center; font-size:13px; }
        .back-link a { color:#e67e22; text-decoration:none; font-weight:bold; }
        .error { color:#e74c3c; font-size:13px; margin-bottom:15px; }
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
            <a href="Logout.aspx" class="btn-logout">🚪 Logout</a>
            <button type="button" class="theme-btn" onclick="toggleTheme()">🌑</button>
        </div>
    </nav>

    <form id="form1" runat="server">
    <div class="main">
        <div class="page-card">
            <div class="page-title">
                <span class="icon">📤</span>
                <h2>Send CCBank Money</h2>
            </div>

            <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                ForeColor="Red" CssClass="error" HeaderText="Please correct the following errors:"
                ValidationGroup="vgSend" DisplayMode="BulletList" />

            <div class="info-row">
                <span>Your Account No</span>
                <span><asp:Label ID="lblMyAccount" runat="server"></asp:Label></span>
            </div>
            <div class="info-row">
                <span>Your Balance</span>
                <span>₱<asp:Label ID="lblBalance" runat="server"></asp:Label></span>
            </div>

            <hr class="divider" />

            <div class="row">
                <span class="label">Recipient Account No</span>
                <asp:TextBox ID="txtRecipientAcct" runat="server" MaxLength="20"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvRecipient" runat="server"
                    ControlToValidate="txtRecipientAcct"
                    ErrorMessage="Recipient Account No is required."
                    ForeColor="Red" ValidationGroup="vgLookup" Display="Dynamic" />
            </div>
            <div class="row">
                <asp:Button ID="btnLookup" runat="server" Text="🔍 Search Recipient"
                    OnClick="btnLookup_Click" CausesValidation="true"
                    ValidationGroup="vgLookup" CssClass="btn-search" />
            </div>

            <asp:Panel ID="pnlSendForm" runat="server" Visible="false">
                <div class="recipient-box">
                    <strong>✅ Recipient Found</strong><br />
                    Account No: <asp:Label ID="lblRecipientAcct" runat="server"></asp:Label><br />
                    Name: <asp:Label ID="lblRecipientName" runat="server"></asp:Label>
                </div>

                <div class="row">
                    <span class="label">Amount to Send</span>
                    <input type="text" id="txtAmountDisplay" placeholder="0.00" />
                    <asp:TextBox ID="txtAmount" runat="server" style="display:none;"></asp:TextBox>
                    
                    <div class="hint">Min: ₱100.00 | Max: ₱50,000.00 | Precise decimals allowed</div>
                    
                    <asp:RequiredFieldValidator ID="rfvAmount" runat="server"
                        ControlToValidate="txtAmount" ErrorMessage="Amount is required."
                        ForeColor="Red" ValidationGroup="vgSend" Display="Dynamic" />
                    <asp:RangeValidator ID="rngAmount" runat="server"
                        ControlToValidate="txtAmount" MinimumValue="100" MaximumValue="50000" Type="Double"
                        ErrorMessage="Amount must be between ₱100.00 and ₱50,000.00."
                        ForeColor="Red" ValidationGroup="vgSend" Display="Dynamic" />
                </div>

                <div class="row">
                    <span class="label">Your 4-Digit Transaction PIN</span>
                    <div class="pin-container">
                        <input type="password" class="pin-box" maxlength="1" id="p1" autocomplete="off" />
                        <input type="password" class="pin-box" maxlength="1" id="p2" autocomplete="off" />
                        <input type="password" class="pin-box" maxlength="1" id="p3" autocomplete="off" />
                        <input type="password" class="pin-box" maxlength="1" id="p4" autocomplete="off" />
                    </div>
                    
                    <input type="hidden" id="txtHiddenPIN" runat="server" value="" />
                    <span id="clientPinError" style="color:Red; display:none; font-size:13px; margin-top:5px;">4-Digit Secure PIN is required.</span>
                </div>

                <div class="btn-row">
                    <asp:Button ID="btnSend" runat="server" Text="📤 Send Money"
                        OnClick="btnSend_Click" OnClientClick="return preparePinSubmit();" 
                        ValidationGroup="vgSend" CssClass="btn-primary" />
                </div>
            </asp:Panel>

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
        // Sync display input box directly to hidden server control variables
        var displayBox = document.getElementById('txtAmountDisplay');
        var hiddenBox = document.getElementById('<%= txtAmount.ClientID %>');
        if(displayBox && hiddenBox) {
            displayBox.addEventListener('input', function() {
                hiddenBox.value = this.value;
            });
        }

        // Handles field auto-tabbing navigation across custom PIN inputs
        document.querySelectorAll('.pin-box').forEach((box, index, boxes) => {
            box.addEventListener('input', function() {
                if (this.value.length === 1 && index < boxes.length - 1) {
                    boxes[index + 1].focus();
                }
            });

            box.addEventListener('keydown', function(e) {
                if (e.key === "Backspace" && this.value.length === 0 && index > 0) {
                    boxes[index - 1].focus();
                }
            });
        });

        // Stitches independent visual squares into text values before processing lifecycle begins
        function preparePinSubmit() {
            var digit1 = document.getElementById('p1').value;
            var digit2 = document.getElementById('p2').value;
            var digit3 = document.getElementById('p3').value;
            var digit4 = document.getElementById('p4').value;
            
            var fullPin = digit1 + digit2 + digit3 + digit4;
            
            var hiddenInput = document.getElementById('<%= txtHiddenPIN.ClientID %>');
            var errorLabel = document.getElementById('clientPinError');

            // Check validation on the client side first
            if (fullPin.length !== 4) {
                if (errorLabel) errorLabel.style.display = 'block';
                return false; // Interrupt and block the lifecycle execution process
            }

            if (errorLabel) errorLabel.style.display = 'none';
            if (hiddenInput) hiddenInput.value = fullPin;

            return true;
        }

        function toggleTheme() {
            document.body.classList.toggle('dark');
            var btn = document.querySelector('.theme-btn');
            btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            var btn = document.querySelector('.theme-btn');
            if (btn) btn.textContent = '☀️';
        }
    </script>
</body>
</html>
