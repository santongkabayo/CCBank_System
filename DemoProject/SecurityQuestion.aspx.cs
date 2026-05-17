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
    public partial class SecurityQuestion : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // If no recovery session, send back to forgot password
            if (Session["RecoveryEmail"] == null)
            {
                Response.Redirect("ForgotPassword.aspx"); return;
            }
            if (!IsPostBack)
                lblQuestion.Text = Session["RecoveryQuestion"].ToString();
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

        protected void btnVerify_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string accountNo = Session["RecoveryAccount"].ToString();
            string answer = txtAnswer.Text.Trim().ToLower();
            string hashedAnswer = HashPassword(answer);

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE ACCOUNT_NO = @acct AND SECRET_ANSWER = @ans";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    cmd.Parameters.AddWithValue("@ans", hashedAnswer);

                    int count = (int)cmd.ExecuteScalar();
                    if (count > 0)
                    {
                        // Answer correct — allow password reset
                        Session["RecoveryVerified"] = "YES";
                        Response.Redirect("ResetPassword.aspx");
                    }
                    else
                    {
                        lblResult.Text = "<span style='color:red;'>❌ Incorrect answer. Please try again.</span>";
                    }
                }
            }
        }
    }
}