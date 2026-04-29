using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoProject
{
    public partial class Registration : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] != null)
                Response.Redirect("Dashboard.aspx");
        }

        // Hash password using SHA256
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

        // Generate Account No: last 3 of password + last 3 of lastname
        private string GenerateAccountNo(string password, string lastname)
        {
            string cleanLastname = lastname.Trim().ToUpper();
            string cleanPassword = password.Trim();

            // Get last 3 of password
            string last3Password = cleanPassword.Length >= 3
                ? cleanPassword.Substring(cleanPassword.Length - 3).ToUpper()
                : cleanPassword.ToUpper().PadLeft(3, '0');

            // Get last 3 of lastname
            string last3Lastname = cleanLastname.Length >= 3
                ? cleanLastname.Substring(cleanLastname.Length - 3)
                : cleanLastname.PadRight(3, 'X');

            return last3Password + last3Lastname;
        }

        private bool IsUsernameDuplicate(string username)
        {
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE USERNAME = @username";
                    cmd.Parameters.AddWithValue("@username", username);
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        private bool IsEmailDuplicate(string email)
        {
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE EMAIL = @email";
                    cmd.Parameters.AddWithValue("@email", email);
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        private bool IsAccountNoDuplicate(string accountNo)
        {
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE ACCOUNT_NO = @accountNo";
                    cmd.Parameters.AddWithValue("@accountNo", accountNo);
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string username = txtUsername.Text.Trim().ToLower();
            string lastname = txtLastname.Text.Trim().ToUpper();
            string firstname = txtFirstname.Text.Trim().ToUpper();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;
            string hashedPw = HashPassword(password);
            string accountNo = GenerateAccountNo(password, lastname);

            if (IsUsernameDuplicate(username))
            {
                lblResult.Text = "<span style='color:red;'>Username already taken. Please choose another.</span>";
                return;
            }
            if (IsEmailDuplicate(email))
            {
                lblResult.Text = "<span style='color:red;'>Email is already registered.</span>";
                return;
            }
            if (IsAccountNoDuplicate(accountNo))
            {
                lblResult.Text = "<span style='color:red;'>Account No conflict. Please try a different password.</span>";
                return;
            }

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = "INSERT INTO USER_TBL (ACCOUNT_NO, USERNAME, LASTNAME, FIRSTNAME, EMAIL, PASSWORD_HASH, DATE_REGISTERED) "
                                    + "VALUES (@accountNo, @username, @lastname, @firstname, @email, @password, GETDATE())";
                    cmd.Parameters.AddWithValue("@accountNo", accountNo);
                    cmd.Parameters.AddWithValue("@username", username);
                    cmd.Parameters.AddWithValue("@lastname", lastname);
                    cmd.Parameters.AddWithValue("@firstname", firstname);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@password", hashedPw);

                    int ctr = cmd.ExecuteNonQuery();
                    if (ctr > 0)
                    {
                        lblResult.Text = "<span style='color:green;'>Registration successful!<br/>" +
                                         "Your Account No is: <strong>" + accountNo + "</strong><br/>" +
                                         "<a href='Login.aspx'>Click here to Login</a></span>";
                        txtUsername.Text = txtLastname.Text = txtFirstname.Text = txtEmail.Text = "";
                    }
                    else
                        lblResult.Text = "<span style='color:red;'>Registration failed. Please try again.</span>";
                }
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtUsername.Text = txtLastname.Text = txtFirstname.Text = txtEmail.Text = "";
            lblResult.Text = "";
        }
    }
}   