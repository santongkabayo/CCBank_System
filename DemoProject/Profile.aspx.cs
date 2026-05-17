using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

namespace DemoProject
{
    public partial class Profile : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }
            if (!IsPostBack) LoadProfile();
        }

        private void LoadProfile()
        {
            string accountNo = Session["AccountNo"].ToString();

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT * FROM USER_TBL WHERE ACCOUNT_NO = @acct";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        string lastname = dr["LASTNAME"].ToString();
                        string firstname = dr["FIRSTNAME"].ToString();
                        string fullname = lastname + ", " + firstname;
                        DateTime dateReg = Convert.ToDateTime(dr["DATE_REGISTERED"]);

                        lblFullName.Text = firstname + " " + lastname;
                        lblAccountNo.Text = accountNo;
                        lblAcctNo.Text = accountNo;
                        lblUsername.Text = dr["USERNAME"].ToString();
                        lblName.Text = fullname;
                        lblDateRegistered.Text = dateReg.ToString("MMMM dd, yyyy hh:mm tt");
                        lblEmail.Text = dr["EMAIL"].ToString();
                        txtNewEmail.Text = dr["EMAIL"].ToString();
                    }
                    dr.Close();
                }
            }
        }

        protected void btnUpdateEmail_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string accountNo = Session["AccountNo"].ToString();
            string newEmail = txtNewEmail.Text.Trim().ToLower();

            // Check if email is already used by another account
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE EMAIL = @email AND ACCOUNT_NO != @acct";
                    cmd.Parameters.AddWithValue("@email", newEmail);
                    cmd.Parameters.AddWithValue("@acct", accountNo);

                    if ((int)cmd.ExecuteScalar() > 0)
                    {
                        lblResult.Text = "<span style='color:red;'>This email is already used by another account.</span>";
                        return;
                    }
                }

                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "UPDATE USER_TBL SET EMAIL = @email WHERE ACCOUNT_NO = @acct";
                    cmd.Parameters.AddWithValue("@email", newEmail);
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    int ctr = cmd.ExecuteNonQuery();

                    if (ctr > 0)
                    {
                        lblEmail.Text = newEmail;
                        lblResult.Text = "<span style='color:green;'>✅ Email updated successfully!</span>";
                    }
                    else
                        lblResult.Text = "<span style='color:red;'>Update failed. Please try again.</span>";
                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            lblResult.Text = "";
            LoadProfile();
        }
    }
}