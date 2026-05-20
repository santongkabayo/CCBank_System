using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SendGrid;
using SendGrid.Helpers.Mail;

namespace DemoProject
{
    public partial class AboutContact : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblStatus.Visible = false;
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid)
            {
                lblStatus.Visible = false;
                return;
            }

            string clientName = txtName.Text.Trim();
            string clientEmail = txtEmail.Text.Trim().ToLower();
            string clientMessage = txtMessage.Text.Trim();

            // Run delivery pipeline targeting your system address
            string emailError = SendInquiryEmail(clientName, clientEmail, clientMessage);

            lblStatus.Visible = true;
            if (string.IsNullOrEmpty(emailError))
            {
                lblStatus.Text = "✅ Thank you! Your suggestion/inquiry has been successfully emailed to our system support team.";
                lblStatus.Style["color"] = "#27ae60";
                lblStatus.Style["background-color"] = "rgba(39, 174, 96, 0.1)";
                lblStatus.Style["border"] = "1px solid #27ae60";

                // Clear fields out after successful processing
                txtName.Text = string.Empty;
                txtEmail.Text = string.Empty;
                txtMessage.Text = string.Empty;
            }
            else
            {
                lblStatus.Text = "❌ Failed to route transmission via SendGrid: " + emailError;
                lblStatus.Style["color"] = "#e74c3c";
                lblStatus.Style["background-color"] = "rgba(231, 76, 60, 0.1)";
                lblStatus.Style["border"] = "1px solid #e74c3c";
            }
        }

        private string SendInquiryEmail(string name, string fromEmail, string messageBody)
        {
            try
            {
                // Inject your secure SendGrid API Key token here
                var client = new SendGrid.SendGridClient("API KEY HERE");

                // Mail envelope definitions
                var from = new SendGrid.Helpers.Mail.EmailAddress("ccbanksystem@gmail.com", "CCBank Contact Portal");
                var to = new SendGrid.Helpers.Mail.EmailAddress("ccbanksystem@gmail.com", "CCBank System Admin");

                string subject = $"CCBank System Inquiry/Suggestion from {name}";

                var htmlContent = $@"
                    <div style='font-family:Arial,sans-serif;max-width:600px;margin:auto;padding:30px;border:1px solid #e0d0c0;border-radius:12px;background-color:#fff;'>
                        <h2 style='color:#e67e22;border-bottom:2px solid #f5b942;padding-bottom:10px;margin-top:0;'>New System Inquiry / Suggestion</h2>
                        <p style='font-size:14px;color:#2c3e50;'>You have received a new contact submission regarding the CCBank platform.</p>
                        
                        <table style='width:100%;border-collapse:collapse;margin:20px 0;font-size:14px;'>
                            <tr>
                                <td style='padding:8px;font-weight:bold;color:#666;width:30%;border-bottom:1px solid #eee;'>Sender Name:</td>
                                <td style='padding:8px;color:#2c3e50;border-bottom:1px solid #eee;'>{name}</td>
                            </tr>
                            <tr>
                                <td style='padding:8px;font-weight:bold;color:#666;border-bottom:1px solid #eee;'>Sender Email:</td>
                                <td style='padding:8px;color:#2c3e50;border-bottom:1px solid #eee;'><a href='mailto:{fromEmail}'>{fromEmail}</a></td>
                            </tr>
                            <tr>
                                <td style='padding:8px;font-weight:bold;color:#666;vertical-align:top;padding-top:12px;'>Message Content:</td>
                                <td style='padding:8px;color:#2c3e50;line-height:1.5;background-color:#fff8f0;border-radius:6px;white-space:pre-wrap;'>{messageBody}</td>
                            </tr>
                        </table>
                        
                        <p style='color:#888;font-size:11px;margin-top:30px;border-top:1px solid #ddd;padding-top:10px;text-align:center;'>
                            This email was generated automatically by the CCBank Contact Desk component portal.
                        </p>
                    </div>";

                // Generate and dispatch single transactional email message pipeline
                var msg = SendGrid.Helpers.Mail.MailHelper.CreateSingleEmail(from, to, subject, "", htmlContent);

                // Optional line addition to allow clicking 'Reply' in your inbox to email the user back directly
                msg.SetReplyTo(new SendGrid.Helpers.Mail.EmailAddress(fromEmail, name));

                var response = client.SendEmailAsync(msg).Result;

                if ((int)response.StatusCode >= 400)
                    return "SendGrid Code Status: " + response.StatusCode;

                return "";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
    }
}