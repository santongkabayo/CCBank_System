using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

namespace DemoProject
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Must have completed steps 1 and 2
            if (Session["RecoveryVerified"] == null || Session["RecoveryAccount"] == null)
            {
                Response.Redirect("ForgotPassword.aspx"); return;
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

            string accountNo = Session["RecoveryAccount"].ToString();
            string hashedNew = HashPassword(txtNewPassword.Text);

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "UPDATE USER_TBL SET PASSWORD_HASH = @pw WHERE ACCOUNT_NO = @acct";
                    cmd.Parameters.AddWithValue("@pw", hashedNew);
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    int ctr = cmd.ExecuteNonQuery();

                    if (ctr > 0)
                    {
                        // 1. Clear recovery wizard parameters
                        Session.Remove("RecoveryEmail");
                        Session.Remove("RecoveryAccount");
                        Session.Remove("RecoveryQuestion");
                        Session.Remove("RecoveryVerified");

                        // 2. Clear out login auto-bypass states to keep the login page locked
                        Session.Clear();
                        Session.Abandon();

                        // 3. Inject an active, animated UI countdown directly into the results label
                        string countdownScript = @"
                            var seconds = 3;
                            var container = document.getElementById('" + lblResult.ClientID + @"');
                            container.style.borderLeft = '4px solid #27ae60';
                            
                            var interval = setInterval(function() {
                                container.innerHTML = ""<span style='color:#27ae60; font-weight:bold;'>✅ Password reset successfully! Redirecting to login in "" + seconds + "" seconds...</span>"";
                                seconds--;
                                if (seconds < 0) {
                                    clearInterval(interval);
                                    window.location.href = 'Login.aspx';
                                }
                            }, 1000);
                        ";

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "RedirectCountdown", countdownScript, true);
                    }
                    else
                    {
                        lblResult.Text = "<span style='color:red;'>Reset failed. Please try again.</span>";
                    }
                }
            }
        }
    }
}