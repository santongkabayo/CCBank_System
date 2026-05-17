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
        // Gets the connection string from web.config to connect to the database
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If not logged in, send back to Login page
            if (Session["AccountNo"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }
            // On first load only, show the current account number on the label
            if (!IsPostBack)
                lblAccountNo.Text = Session["AccountNo"].ToString();
        }

        // Converts plain password into a scrambled string for security
        private string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                // Convert password to bytes then hash it
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                // Convert each byte to a 2-character hex string
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        // Runs when Change Password button is clicked
        protected void btnChange_Click(object sender, EventArgs e)
        {
            // Check if all required fields are filled
            Page.Validate();
            // Stop if validation fails
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            // Get account number from Session
            string accountNo = Session["AccountNo"].ToString();
            // Hash both current and new passwords for comparison and storage
            string hashedCurrent = HashPassword(txtCurrentPassword.Text);
            string hashedNew = HashPassword(txtNewPassword.Text);

            // Open database connection
            using (var db = new SqlConnection(connDB))
            {
                db.Open();

                // Step 1: Verify if the current password is correct
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    // Count rows where account number AND current password match
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE ACCOUNT_NO = @accountNo AND PASSWORD_HASH = @currentPw";
                    cmd.Parameters.AddWithValue("@accountNo", accountNo);
                    cmd.Parameters.AddWithValue("@currentPw", hashedCurrent);

                    // If count is 0, current password is wrong — stop
                    if ((int)cmd.ExecuteScalar() == 0)
                    {
                        lblResult.Text = "<span style='color:red;'>Current password is incorrect.</span>";
                        return;
                    }
                }

                // Step 2: Update the password with the new one
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    // UPDATE query replaces old password hash with new password hash
                    cmd.CommandText = "UPDATE USER_TBL SET PASSWORD_HASH = @newPw WHERE ACCOUNT_NO = @accountNo";
                    cmd.Parameters.AddWithValue("@newPw", hashedNew);
                    cmd.Parameters.AddWithValue("@accountNo", accountNo);

                    // ExecuteNonQuery runs the UPDATE and returns number of rows affected
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