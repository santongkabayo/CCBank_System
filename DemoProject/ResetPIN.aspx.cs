using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;

namespace DemoProject
{
    public partial class ResetPIN : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            string token = Request.QueryString["token"];

            if (string.IsNullOrEmpty(token))
            {
                lblResult.Text = "<span style='color:red;'>❌ Invalid or missing reset link.</span>";
                btnReset.Enabled = false;
                return;
            }

            if (!IsPostBack)
            {
                using (var db = new SqlConnection(connDB))
                {
                    db.Open();
                    using (var cmd = db.CreateCommand())
                    {
                        cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE PIN_RESET_TOKEN = @token AND PIN_RESET_TOKEN_EXPIRY > GETDATE()";
                        cmd.Parameters.AddWithValue("@token", token);
                        int count = (int)cmd.ExecuteScalar();
                        if (count == 0)
                        {
                            lblResult.Text = "<span style='color:red;'>❌ This reset link has expired or already been used.</span>";
                            btnReset.Enabled = false;
                        }
                    }
                }
            }
        }

        private string HashPassword(string text)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(text));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            string token = Request.QueryString["token"];

            string pin = pin1.Text.Trim() + pin2.Text.Trim() + pin3.Text.Trim() + pin4.Text.Trim();

            if (pin.Length != 4 || !System.Text.RegularExpressions.Regex.IsMatch(pin, @"^\d{4}$"))
            {
                lblResult.Text = "<span style='color:red;'>❌ Please enter a valid 4-digit PIN.</span>";
                return;
            }

            string hashedPIN = HashPassword(pin);

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = @"UPDATE USER_TBL 
                                        SET PIN_HASH = @pin, PIN_RESET_TOKEN = NULL, PIN_RESET_TOKEN_EXPIRY = NULL 
                                        WHERE PIN_RESET_TOKEN = @token AND PIN_RESET_TOKEN_EXPIRY > GETDATE()";
                    cmd.Parameters.AddWithValue("@pin", hashedPIN);
                    cmd.Parameters.AddWithValue("@token", token);
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        btnReset.Enabled = false;
                        // Use ClientScript instead of ScriptManager (no ScriptManager needed)
                        string script = @"
                            var seconds = 3;
                            var container = document.getElementById('" + lblResult.ClientID + @"');
                            container.style.borderLeft = '4px solid #27ae60';
                            var interval = setInterval(function() {
                                container.innerHTML = ""<span style='color:#27ae60;font-weight:bold;'>✅ PIN reset successfully! Redirecting in "" + seconds + "" seconds...</span>"";
                                seconds--;
                                if (seconds < 0) { clearInterval(interval); window.location.href = 'Login.aspx'; }
                            }, 1000);";
                        ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
                    }
                    else
                    {
                        lblResult.Text = "<span style='color:red;'>❌ Link expired. Please request a new PIN reset link.</span>";
                    }
                }
            }
        }
    }
}