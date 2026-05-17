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
                        // Clear recovery sessions
                        Session.Remove("RecoveryEmail");
                        Session.Remove("RecoveryAccount");
                        Session.Remove("RecoveryQuestion");
                        Session.Remove("RecoveryVerified");

                        lblResult.Text = "<span style='color:green;'>✅ Password reset successfully! " +
                                         "<a href='Login.aspx'>Click here to Login</a></span>";
                    }
                    else
                        lblResult.Text = "<span style='color:red;'>Reset failed. Please try again.</span>";
                }
            }
        }
    }
}