<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPIN.aspx.cs" Inherits="DemoProject.ResetPIN" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>CC Bank - Reset PIN</title>
    <style>
        :root { 
            --bg: linear-gradient(135deg,#f4a58a 0%,#f0a070 25%,#f5b942 60%,#f9c85a 100%); 
            --card: rgba(255,255,255,0.95); 
            --text: #2c3e50; 
            --subtext: #666; 
            --border: #e0d0c0;
            --accent: #e67e22;
            --input-bg: #fff; 
            --input-border: #ddd; 
            --label: #555; 
            --muted: #999;
            --hover: #fff8f0;
            --result-bg: #fff8f0; 
            --link: #e67e22; 
            --shadow: rgba(0,0,0,0.08);
        }
        body.dark { 
            --bg: linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%); 
            --card: rgba(30,30,50,0.97); 
            --text: #f0f0f0; 
            --subtext: #aaa; 
            --border: #333;
            --accent: #f5b942;
            --input-bg: #2a2a3e; 
            --input-border: #444; 
            --label: #ccc; 
            --hover: #2a2a3e;
            --result-bg: #2a2a3e; 
            --link: #f5b942; 
            --shadow: rgba(0,0,0,0.3);
        }
        
        * { box-sizing:border-box; margin:0; padding:0; transition:background 0.3s,color 0.3s; }
        body { font-family:Arial,sans-serif; min-height:100vh; display:flex; justify-content:center; align-items:center; background:var(--bg); color:var(--text); }
        
        .theme-toggle { position:fixed; top:16px; right:16px; background:rgba(255,255,255,0.2); border:none; border-radius:20px; padding:8px 14px; cursor:pointer; font-size:18px; z-index:999; transition: background 0.2s, transform 0.3s; }
        .theme-toggle:hover { background: rgba(255,255,255,0.3); transform: rotate(20deg); }
        
        .container { width:440px; background:var(--card); border-radius:20px; padding:40px; box-shadow:0 20px 60px rgba(0,0,0,0.2); animation: fadeInUp 0.5s ease 0.1s both; }
        
        .logo-area { text-align:center; margin-bottom:20px; }
        .logo-area img { width:80px; height:80px; object-fit:contain; transition: transform 0.3s; }
        .logo-area img:hover { transform: rotate(-5deg) scale(1.1); }
        .logo-area h1 { color:var(--text); font-size:20px; margin-top:8px; }
        
        .divider { border:none; border-top:1px solid var(--input-border); margin:14px 0; }
        
        .row { margin-bottom:14px; }
        .label { display:block; font-weight:bold; color:var(--label); margin-bottom:5px; font-size:13px; }
        
        .pin-inputs { display:flex; gap:10px; justify-content:center; margin-top:12px; }
        .pin-inputs .pin-box { 
            width:60px; height:60px; text-align:center; font-size:22px; font-weight:bold; border:1.5px solid var(--input-border); border-radius:10px; background:var(--input-bg); color:var(--text); 
            transition: border-color 0.2s, box-shadow 0.2s, transform 0.2s;
        }
        .pin-inputs .pin-box:focus { border-color:#f0a070; outline:none; transform: scale(1.05); box-shadow:0 0 0 3px rgba(240,160,112,0.15); }
        
        .btn-primary { 
            width:100%; background:linear-gradient(135deg,#f0a070,#f5b942); color:white; padding:12px; border:none; border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; margin-top:18px; 
            transition: opacity 0.2s, transform 0.2s, box-shadow 0.2s;
        }
        .btn-primary:hover { opacity:0.88; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(240,160,112,0.4); }
        .btn-primary:active { transform: scale(0.97); }
        
        .result { margin-top:14px; padding:10px 14px; background:var(--result-bg); border-left:4px solid #f0a070; border-radius:6px; font-size:13px; min-height:20px; color:var(--text); transition: all 0.3s ease; }
        .error { color:#e74c3c; font-size:13px; }

        /* ── ANIMATIONS ── */
        @keyframes slideDown {
            from { transform: translateY(-100%); opacity: 0; }
            to   { transform: translateY(0);     opacity: 1; }
        }
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

    <button class="theme-toggle" onclick="toggleTheme()">🌑</button>

    <form id="form1" runat="server">
    <div class="container">
        <div class="logo-area">
            <img src="CC bank.png" alt="CC Bank" />
            <h1>Reset Transaction PIN</h1>
        </div>
        <hr class="divider" />

        <div class="row">
            <span class="label" style="text-align:center;display:block;">Enter New 4-Digit PIN</span>
            <div class="pin-inputs">
                <asp:TextBox ID="pin1" runat="server" MaxLength="1" CssClass="pin-box" TextMode="Password"></asp:TextBox>
                <asp:TextBox ID="pin2" runat="server" MaxLength="1" CssClass="pin-box" TextMode="Password"></asp:TextBox>
                <asp:TextBox ID="pin3" runat="server" MaxLength="1" CssClass="pin-box" TextMode="Password"></asp:TextBox>
                <asp:TextBox ID="pin4" runat="server" MaxLength="1" CssClass="pin-box" TextMode="Password"></asp:TextBox>
            </div>
        </div>

        <asp:Button ID="btnReset" runat="server" Text="🔒 Reset PIN" OnClick="btnReset_Click" CssClass="btn-primary" />

        <div class="result">
            <asp:Label ID="lblResult" runat="server"></asp:Label>
        </div>
    </div>
    </form>

    <script>
        function toggleTheme() {
            document.body.classList.toggle('dark');
            var btn = document.querySelector('.theme-toggle');
            btn.textContent = document.body.classList.contains('dark') ? '☀️' : '🌑';
            localStorage.setItem('theme', document.body.classList.contains('dark') ? 'dark' : 'light');
        }
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark');
            document.querySelector('.theme-toggle').textContent = '☀️';
        }

        window.addEventListener('load', function () {
            var loader = document.getElementById('pageLoader');
            loader.classList.add('hidden');
            setTimeout(function () { loader.style.display = 'none'; }, 400);

            // Focus on the first entry box when the page opens up
            var firstBox = document.getElementById('<%= pin1.ClientID %>');
            if (firstBox) firstBox.focus();
        });

        // Safe client side DOM lookup for ASP components
        var elements = [
            document.getElementById('<%= pin1.ClientID %>'),
            document.getElementById('<%= pin2.ClientID %>'),
            document.getElementById('<%= pin3.ClientID %>'),
            document.getElementById('<%= pin4.ClientID %>')
        ];

        elements.forEach(function (el, i, arr) {
            if (!el) return;

            el.addEventListener('input', function () {
                this.value = this.value.replace(/\D/g, ''); // Clear out non numeric values
                if (this.value && i < arr.length - 1) {
                    if (arr[i + 1]) arr[i + 1].focus();
                }
            });

            el.addEventListener('keydown', function (e) {
                if (e.key === 'Backspace' && !this.value && i > 0) {
                    if (arr[i - 1]) arr[i - 1].focus();
                }
            });
        });

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
