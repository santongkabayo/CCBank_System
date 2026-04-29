using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoProject
{
    public partial class ChangePassword : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }
            if (!IsPostBack)
                lblAccountNo.Text = Session["AccountNo"].ToString();
        }
        private string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }
        protected void btnChange_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string accountNo = Session["AccountNo"].ToString();
            string hashedCurrent = HashPassword(txtCurrentPassword.Text);
            string hashedNew = HashPassword(txtNewPassword.Text);

            using (var db = new SqlConnection(connDB))
            {
                db.Open();

                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE ACCOUNT_NO = @accountNo AND PASSWORD_HASH = @currentPw";
                    cmd.Parameters.AddWithValue("@accountNo", accountNo);
                    cmd.Parameters.AddWithValue("@currentPw", hashedCurrent);

                    if ((int)cmd.ExecuteScalar() == 0)
                    {
                        lblResult.Text = "<span style='color:red;'>Current password is incorrect.</span>";
                        return;
                    }
                }

                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = "UPDATE USER_TBL SET PASSWORD_HASH = @newPw WHERE ACCOUNT_NO = @accountNo";
                    cmd.Parameters.AddWithValue("@newPw", hashedNew);
                    cmd.Parameters.AddWithValue("@accountNo", accountNo);

                    int ctr = cmd.ExecuteNonQuery();
                    if (ctr > 0)
                        lblResult.Text = "<span style='color:green;'>Password changed successfully!</span>";
                    else
                        lblResult.Text = "<span style='color:red;'>Password change failed. Please try again.</span>";
                }
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            lblResult.Text = "";
        }

    }

}