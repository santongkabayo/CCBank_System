using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;

namespace DemoProject
{
    public partial class ResetPasswordEmail : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;
        string token = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            token = Request.QueryString["token"];

            if (string.IsNullOrEmpty(token))
            {
                lblResult.Text = "<span style='color:red;'>❌ Invalid or missing reset link.</span>";
                btnReset.Enabled = false;
                return;
            }

            // Validate token exists and not expired
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE RESET_TOKEN = @token AND RESET_TOKEN_EXPIRY > GETDATE()";
                    cmd.Parameters.AddWithValue("@token", token);
                    int count = (int)cmd.ExecuteScalar();
                    if (count == 0)
                    {
                        lblResult.Text = "<span style='color:red;'>❌ This reset link has expired or already been used. Please request a new one.</span>";
                        btnReset.Enabled = false;
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
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            token = Request.QueryString["token"];
            string hashedNew = HashPassword(txtNewPassword.Text);

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = @"UPDATE USER_TBL 
                                        SET PASSWORD_HASH = @pw, RESET_TOKEN = NULL, RESET_TOKEN_EXPIRY = NULL 
                                        WHERE RESET_TOKEN = @token AND RESET_TOKEN_EXPIRY > GETDATE()";
                    cmd.Parameters.AddWithValue("@pw", hashedNew);
                    cmd.Parameters.AddWithValue("@token", token);
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        btnReset.Enabled = false;
                        string script = @"
                            var seconds = 3;
                            var container = document.getElementById('" + lblResult.ClientID + @"');
                            container.style.borderLeft = '4px solid #27ae60';
                            var interval = setInterval(function() {
                                container.innerHTML = ""<span style='color:#27ae60;font-weight:bold;'>✅ Password reset successfully! Redirecting in "" + seconds + "" seconds...</span>"";
                                seconds--;
                                if (seconds < 0) { clearInterval(interval); window.location.href = 'Login.aspx'; }
                            }, 1000);";
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "redirect", script, true);
                    }
                    else
                    {
                        lblResult.Text = "<span style='color:red;'>❌ Link expired. Please request a new reset link.</span>";
                    }
                }
            }
        }
    }
}