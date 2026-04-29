using System;
using System.Collections.Generic;
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
    public partial class SendMoney : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }
            if (!IsPostBack) LoadInfo();
        }
        private decimal GetCurrentBalance(string accountNo, SqlConnection db)
        {
            using (var cmd = db.CreateCommand())
            {
                cmd.CommandText =
                    "SELECT ISNULL(SUM(CASE WHEN TRANS_TYPE IN ('D','R') THEN AMOUNT ELSE 0 END),0)" +
                    "     - ISNULL(SUM(CASE WHEN TRANS_TYPE IN ('W','S') THEN AMOUNT ELSE 0 END),0)" +
                    " FROM TRANSACTION_TBL WHERE ACCOUNT_NO = @acct";
                cmd.Parameters.AddWithValue("@acct", accountNo);
                return (decimal)cmd.ExecuteScalar();
            }
        }

        private string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        private void LoadInfo()
        {
            string accountNo = Session["AccountNo"].ToString();
            lblMyAccount.Text = accountNo;
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                lblBalance.Text = GetCurrentBalance(accountNo, db).ToString("N2");
            }
        }

        protected void btnLookup_Click(object sender, EventArgs e)
        {
            string myAcct = Session["AccountNo"].ToString();
            string recipAcct = txtRecipientAcct.Text.Trim().ToUpper();
            lblResult.Text = "";
            pnlSendForm.Visible = false;

            if (recipAcct == myAcct)
            {
                lblResult.Text = "<span style='color:red;'>You cannot send to your own account.</span>";
                return;
            }

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT ACCOUNT_NO, LASTNAME, FIRSTNAME FROM USER_TBL WHERE ACCOUNT_NO = @acct";
                    cmd.Parameters.AddWithValue("@acct", recipAcct);
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        lblRecipientAcct.Text = dr["ACCOUNT_NO"].ToString();
                        lblRecipientName.Text = dr["LASTNAME"] + ", " + dr["FIRSTNAME"];
                        dr.Close();
                        pnlSendForm.Visible = true;
                    }
                    else
                    {
                        dr.Close();
                        lblResult.Text = "<span style='color:red;'>Recipient account not found.</span>";
                    }
                }
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            Page.Validate("vgSend");
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string myAcct = Session["AccountNo"].ToString();
            string recipAcct = lblRecipientAcct.Text;
            decimal amount;
            if (!decimal.TryParse(txtAmount.Text, out amount))
            {
                lblResult.Text = "<span style='color:red;'>Invalid amount.</span>"; return;
            }
            if (amount % 100 != 0)
            {
                lblResult.Text = "<span style='color:red;'>Amount must be divisible by ₱100.00.</span>"; return;
            }

            // Verify password
            string hashedPw = HashPassword(txtPassword.Text);
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE ACCOUNT_NO=@acct AND PASSWORD_HASH=@pw";
                    cmd.Parameters.AddWithValue("@acct", myAcct);
                    cmd.Parameters.AddWithValue("@pw", hashedPw);
                    if ((int)cmd.ExecuteScalar() == 0)
                    {
                        lblResult.Text = "<span style='color:red;'>Incorrect password.</span>"; return;
                    }
                }

                decimal senderBalance = GetCurrentBalance(myAcct, db);
                if (amount > senderBalance)
                {
                    lblResult.Text = "<span style='color:red;'>Insufficient funds. Balance: ₱" +
                        senderBalance.ToString("N2") + ".</span>"; return;
                }

                decimal senderBalAfter = senderBalance - amount;
                decimal recipientBalance = GetCurrentBalance(recipAcct, db);
                decimal recipBalAfter = recipientBalance + amount;

                // Insert SEND record for sender
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText =
                        "INSERT INTO TRANSACTION_TBL (ACCOUNT_NO, TRANS_TYPE, AMOUNT, BALANCE_AFTER, SENT_TO) " +
                        "VALUES (@acct, 'S', @amount, @balAfter, @sentTo)";
                    cmd.Parameters.AddWithValue("@acct", myAcct);
                    cmd.Parameters.AddWithValue("@amount", amount);
                    cmd.Parameters.AddWithValue("@balAfter", senderBalAfter);
                    cmd.Parameters.AddWithValue("@sentTo", recipAcct);
                    cmd.ExecuteNonQuery();
                }

                // Insert RECEIVE record for recipient
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText =
                        "INSERT INTO TRANSACTION_TBL (ACCOUNT_NO, TRANS_TYPE, AMOUNT, BALANCE_AFTER, RECEIVED_FROM) " +
                        "VALUES (@acct, 'R', @amount, @balAfter, @recvFrom)";
                    cmd.Parameters.AddWithValue("@acct", recipAcct);
                    cmd.Parameters.AddWithValue("@amount", amount);
                    cmd.Parameters.AddWithValue("@balAfter", recipBalAfter);
                    cmd.Parameters.AddWithValue("@recvFrom", myAcct);
                    cmd.ExecuteNonQuery();
                }

                lblBalance.Text = senderBalAfter.ToString("N2");
                lblResult.Text = "<span style='color:green;'>Successfully sent ₱" + amount.ToString("N2") +
                                  " to " + lblRecipientName.Text + ". New Balance: ₱" + senderBalAfter.ToString("N2") + "</span>";
                pnlSendForm.Visible = false;
                txtRecipientAcct.Text = "";
                txtAmount.Text = "";
            }
        }
    }
}