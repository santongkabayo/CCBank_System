using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Net;
using System.Web.Configuration;
using SendGrid;
using SendGrid.Helpers.Mail;

namespace DemoProject
{
    public partial class ForgotPIN : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string email = txtEmail.Text.Trim().ToLower();

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT ACCOUNT_NO, USERNAME FROM USER_TBL WHERE EMAIL = @email";
                    cmd.Parameters.AddWithValue("@email", email);
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        string accountNo = dr["ACCOUNT_NO"].ToString();
                        string username = dr["USERNAME"].ToString();
                        dr.Close();

                        string token = Guid.NewGuid().ToString("N");

                        using (var cmd2 = db.CreateCommand())
                        {
                            cmd2.CommandText = "UPDATE USER_TBL SET PIN_RESET_TOKEN = @token, PIN_RESET_TOKEN_EXPIRY = @expiry WHERE ACCOUNT_NO = @acct";
                            cmd2.Parameters.AddWithValue("@token", token);
                            cmd2.Parameters.AddWithValue("@expiry", DateTime.Now.AddMinutes(30));
                            cmd2.Parameters.AddWithValue("@acct", accountNo);
                            cmd2.ExecuteNonQuery();
                        }

                        string resetLink = $"http://ramos-finalproject.runasp.net/ResetPIN.aspx?token={token}";
                        string emailError = SendPINResetEmail(email, username, resetLink);

                        if (string.IsNullOrEmpty(emailError))
                            lblResult.Text = "<span style='color:green;'>✅ A PIN reset link has been sent to your email. It expires in 30 minutes.</span>";
                        else
                            lblResult.Text = "<span style='color:red;'>❌ Email Error: " + emailError + "</span>";
                    }
                    else
                    {
                        dr.Close();
                        lblResult.Text = "<span style='color:red;'>❌ Email not found. Please check and try again.</span>";
                    }
                }
            }
        }

        // Updated Implementation: SendGrid API Delivery Pipeline
        private string SendPINResetEmail(string toEmail, string username, string resetLink)
        {
            try
            {
                var client = new SendGrid.SendGridClient("API KEY HERE");
                var from = new SendGrid.Helpers.Mail.EmailAddress("ccbanksystem@gmail.com", "CC Bank");
                var to = new SendGrid.Helpers.Mail.EmailAddress(toEmail);
                var subject = "CC Bank - Transaction PIN Reset Request";
                var htmlContent = $@"
                    <div style='font-family:Arial,sans-serif;max-width:500px;margin:auto;padding:30px;border:1px solid #ddd;border-radius:12px;'>
                        <h2 style='color:#f0a070;text-align:center;'>CC Bank</h2>
                        <h3 style='color:#2c3e50;'>Transaction PIN Reset Request</h3>
                        <p style='color:#555;'>Hi <strong>{username}</strong>,</p>
                        <p style='color:#555;'>We received a request to reset your Transaction PIN. Click the button below. This link expires in <strong>30 minutes</strong>.</p>
                        <div style='text-align:center;margin:30px 0;'>
                            <a href='{resetLink}' style='background:linear-gradient(135deg,#f0a070,#f5b942);color:white;padding:14px 30px;border-radius:8px;text-decoration:none;font-weight:bold;font-size:15px;'>Reset My PIN</a>
                        </div>
                        <p style='color:#888;font-size:12px;'>If you did not request this, ignore this email.</p>
                    </div>";

                var msg = SendGrid.Helpers.Mail.MailHelper.CreateSingleEmail(from, to, subject, "", htmlContent);
                var response = client.SendEmailAsync(msg).Result;

                if ((int)response.StatusCode >= 400)
                    return "SendGrid Error: " + response.StatusCode;

                return "";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
    }
}