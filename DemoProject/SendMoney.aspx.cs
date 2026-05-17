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
using System.Data;

namespace DemoProject
{
    public partial class SendMoney : System.Web.UI.Page
    {
        // Gets the connection string from web.config to connect to the database
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }
            if (!IsPostBack) LoadInfo();
        }

        private decimal GetCurrentBalance(string accountNo, SqlConnection db, SqlTransaction transaction = null)
        {
            using (var cmd = db.CreateCommand())
            {
                if (transaction != null) cmd.Transaction = transaction;

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
                lblBalance.Text = GetCurrentBalance(accountNo, db, null).ToString("N2");
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
                lblResult.Text = "<span style='color:red;'>You cannot send money to your own account.</span>";
                return;
            }

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT ACCOUNT_NO, LASTNAME, FIRSTNAME FROM USER_TBL WHERE ACCOUNT_NO = @acct";
                    cmd.Parameters.AddWithValue("@acct", recipAcct);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblRecipientAcct.Text = dr["ACCOUNT_NO"].ToString();
                            lblRecipientName.Text = dr["LASTNAME"].ToString() + ", " + dr["FIRSTNAME"].ToString();
                            pnlSendForm.Visible = true;
                        }
                        else
                        {
                            lblResult.Text = "<span style='color:red;'>Recipient account not found.</span>";
                        }
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
                lblResult.Text = "<span style='color:red;'>Invalid numerical amount format.</span>";
                return;
            }

            if (amount < 100.00m)
            {
                lblResult.Text = "<span style='color:red;'>Minimum transfer amount allowed is ₱100.00.</span>";
                return;
            }

            // SAFETY CHECK: Read the combined value from our new HTML hidden control component safely
            if (txtHiddenPIN == null || string.IsNullOrEmpty(txtHiddenPIN.Value))
            {
                lblResult.Text = "<span style='color:red;'>4-Digit Secure PIN is required.</span>";
                return;
            }

            string pinValue = txtHiddenPIN.Value.Trim();

            if (pinValue.Length != 4)
            {
                lblResult.Text = "<span style='color:red;'>PIN must be exactly 4 digits.</span>";
                return;
            }

            // Hash the verified 4-digit PIN value safely
            string hashedPIN = HashPassword(pinValue);
            bool isPinValid = false;

            // STEP 1: Verify the PIN with a dedicated, isolated database connection wrapper
            using (SqlConnection dbCheck = new SqlConnection(connDB))
            {
                dbCheck.Open();
                using (SqlCommand cmdCheck = new SqlCommand("SELECT COUNT(*) FROM USER_TBL WHERE ACCOUNT_NO=@acct AND PIN_HASH=@pin", dbCheck))
                {
                    cmdCheck.Parameters.AddWithValue("@acct", myAcct);
                    cmdCheck.Parameters.AddWithValue("@pin", hashedPIN);

                    object scalarResult = cmdCheck.ExecuteScalar();
                    if (scalarResult != null)
                    {
                        isPinValid = ((int)scalarResult > 0);
                    }
                }
            }

            // If the PIN is wrong, stop execution early safely BEFORE any transaction blocks open
            if (!isPinValid)
            {
                lblResult.Text = "<span style='color:red;'>Incorrect Transaction PIN. Transfer denied.</span>";
                return;
            }

            // STEP 2: Proceed with the money transfer transaction on a pristine connection resource pool
            using (SqlConnection db = new SqlConnection(connDB))
            {
                db.Open();
                using (SqlTransaction transaction = db.BeginTransaction(System.Data.IsolationLevel.Serializable))
                {
                    try
                    {
                        decimal senderBalance = GetCurrentBalance(myAcct, db, transaction);
                        if (amount > senderBalance)
                        {
                            lblResult.Text = "<span style='color:red;'>Insufficient funds. Balance available: ₱" +
                                senderBalance.ToString("N2") + ".</span>";
                            transaction.Rollback();
                            return;
                        }

                        decimal recipientBalance = GetCurrentBalance(recipAcct, db, transaction);

                        decimal senderBalAfter = senderBalance - amount;
                        decimal recipBalAfter = recipientBalance + amount;

                        // Write record row to TRANSACTION_TBL for Sender ('S')
                        using (SqlCommand cmdSender = new SqlCommand(
                            "INSERT INTO TRANSACTION_TBL (ACCOUNT_NO, TRANS_TYPE, AMOUNT, BALANCE_AFTER, SENT_TO) " +
                            "VALUES (@acct, 'S', @amount, @balAfter, @sentTo)", db, transaction))
                        {
                            cmdSender.Parameters.AddWithValue("@acct", myAcct);
                            cmdSender.Parameters.AddWithValue("@amount", amount);
                            cmdSender.Parameters.AddWithValue("@balAfter", senderBalAfter);
                            cmdSender.Parameters.AddWithValue("@sentTo", recipAcct);
                            cmdSender.ExecuteNonQuery();
                        }

                        // Write record row to TRANSACTION_TBL for Recipient ('R')
                        using (SqlCommand cmdRecip = new SqlCommand(
                            "INSERT INTO TRANSACTION_TBL (ACCOUNT_NO, TRANS_TYPE, AMOUNT, BALANCE_AFTER, RECEIVED_FROM) " +
                            "VALUES (@acct, 'R', @amount, @balAfter, @recvFrom)", db, transaction))
                        {
                            cmdRecip.Parameters.AddWithValue("@acct", recipAcct);
                            cmdRecip.Parameters.AddWithValue("@amount", amount);
                            cmdRecip.Parameters.AddWithValue("@balAfter", recipBalAfter);
                            cmdRecip.Parameters.AddWithValue("@recvFrom", myAcct);
                            cmdRecip.ExecuteNonQuery();
                        }

                        transaction.Commit();

                        lblBalance.Text = senderBalAfter.ToString("N2");
                        lblResult.Text = "<span style='color:green;'>Successfully transferred ₱" + amount.ToString("N2") +
                                          " to " + lblRecipientName.Text + ". New Balance: ₱" + senderBalAfter.ToString("N2") + "</span>";

                        // Clear inputs safely on a successful transaction
                        pnlSendForm.Visible = false;
                        txtRecipientAcct.Text = "";
                        txtAmount.Text = "";
                        txtHiddenPIN.Value = "";
                    }
                    catch (Exception ex)
                    {
                        if (transaction != null && transaction.Connection != null)
                        {
                            transaction.Rollback();
                        }
                        lblResult.Text = "<span style='color:red;'>Transaction aborted: " + ex.Message + "</span>";
                    }
                }
            }
        }
    }
}