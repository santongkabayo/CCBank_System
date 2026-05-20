using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using SendGrid;
using SendGrid.Helpers.Mail;

namespace DemoProject
{
    public partial class ChangePIN : System.Web.UI.Page
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

        protected void btnChange_Click(object sender, EventArgs e)
        {
            string accountNo = Session["AccountNo"].ToString();

            string currentPIN = curPin1.Text.Trim() + curPin2.Text.Trim() + curPin3.Text.Trim() + curPin4.Text.Trim();
            string newPIN = newPin1.Text.Trim() + newPin2.Text.Trim() + newPin3.Text.Trim() + newPin4.Text.Trim();
            string confirmPIN = conPin1.Text.Trim() + conPin2.Text.Trim() + conPin3.Text.Trim() + conPin4.Text.Trim();

            if (currentPIN.Length != 4 || !System.Text.RegularExpressions.Regex.IsMatch(currentPIN, @"^\d{4}$"))
            {
                lblResult.Text = "<span style='color:red;'>❌ Current PIN must be exactly 4 digits.</span>";
                return;
            }
            if (newPIN.Length != 4 || !System.Text.RegularExpressions.Regex.IsMatch(newPIN, @"^\d{4}$"))
            {
                lblResult.Text = "<span style='color:red;'>❌ New PIN must be exactly 4 digits.</span>";
                return;
            }
            if (newPIN != confirmPIN)
            {
                lblResult.Text = "<span style='color:red;'>❌ New PIN and Confirm PIN do not match.</span>";
                return;
            }

            string hashedCurrent = HashPassword(currentPIN);
            string hashedNew = HashPassword(newPIN);

            using (var db = new SqlConnection(connDB))
            {
                db.Open();

                // Verify current PIN
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE ACCOUNT_NO = @acct AND PIN_HASH = @pin";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    cmd.Parameters.AddWithValue("@pin", hashedCurrent);
                    if ((int)cmd.ExecuteScalar() == 0)
                    {
                        lblResult.Text = "<span style='color:red;'>❌ Current PIN is incorrect.</span>";
                        return;
                    }
                }

                // Update to new PIN
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "UPDATE USER_TBL SET PIN_HASH = @newPin WHERE ACCOUNT_NO = @acct";
                    cmd.Parameters.AddWithValue("@newPin", hashedNew);
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        // Get email and username to send confirmation
                        string email = "";
                        string username = "";
                        using (var cmd2 = db.CreateCommand())
                        {
                            cmd2.CommandText = "SELECT EMAIL, USERNAME FROM USER_TBL WHERE ACCOUNT_NO = @acct";
                            cmd2.Parameters.AddWithValue("@acct", accountNo);
                            var dr = cmd2.ExecuteReader();
                            if (dr.Read())
                            {
                                email = dr["EMAIL"].ToString();
                                username = dr["USERNAME"].ToString();
                            }
                            dr.Close();
                        }

                        // Send confirmation email
                        SendPINChangedEmail(email, username);

                        lblResult.Text = "<span style='color:green;'>✅ PIN changed successfully! A confirmation email has been sent.</span>";
                    }
                    else
                    {
                        lblResult.Text = "<span style='color:red;'>❌ PIN change failed. Please try again.</span>";
                    }
                }
            }
        }

        private void SendPINChangedEmail(string toEmail, string username)
        {
            try
            {
                var client = new SendGridClient("API KEY HERE");
                var from = new EmailAddress("ccbanksystem@gmail.com", "CC Bank");
                var to = new EmailAddress(toEmail);
                var subject = "CC Bank - Transaction PIN Changed";
                var htmlContent = $@"
                    <div style='font-family:Arial,sans-serif;max-width:500px;margin:auto;padding:30px;border:1px solid #ddd;border-radius:12px;'>
                        <h2 style='color:#f0a070;text-align:center;'>CC Bank</h2>
                        <h3 style='color:#2c3e50;'>Transaction PIN Changed</h3>
                        <p style='color:#555;'>Hi <strong>{username}</strong>,</p>
                        <p style='color:#555;'>Your Transaction PIN has been successfully changed on <strong>{DateTime.Now:MMMM dd, yyyy} at {DateTime.Now:hh:mm tt}</strong>.</p>
                        <p style='color:#555;'>If you did not make this change, please contact support immediately or reset your PIN.</p>
                        <div style='margin-top:20px;padding:14px;background:#fff8f0;border-left:4px solid #f0a070;border-radius:6px;'>
                            <p style='margin:0;color:#888;font-size:12px;'>This is an automated message from CC Bank. Please do not reply.</p>
                        </div>
                    </div>";

                var msg = MailHelper.CreateSingleEmail(from, to, subject, "", htmlContent);
                var response = System.Threading.Tasks.Task.Run(async () => await client.SendEmailAsync(msg)).Result;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Email Error: " + ex.Message);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            curPin1.Text = curPin2.Text = curPin3.Text = curPin4.Text = "";
            newPin1.Text = newPin2.Text = newPin3.Text = newPin4.Text = "";
            conPin1.Text = conPin2.Text = conPin3.Text = conPin4.Text = "";
            lblResult.Text = "";
        }
    }
}