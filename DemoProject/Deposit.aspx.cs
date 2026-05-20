using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;

namespace DemoProject
{
    public partial class Deposit : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }
            if (!IsPostBack) LoadInfo();
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
                return Convert.ToDecimal(cmd.ExecuteScalar());
            }
        }

        private void LoadInfo()
        {
            string accountNo = Session["AccountNo"].ToString();
            lblAccountNo.Text = accountNo;
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                lblBalance.Text = GetCurrentBalance(accountNo, db).ToString("N2");
            }
        }

        protected void btnDeposit_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string accountNo = Session["AccountNo"].ToString();

            // Validate PIN
            string pin = pin1.Text.Trim() + pin2.Text.Trim() + pin3.Text.Trim() + pin4.Text.Trim();
            if (pin.Length != 4 || !System.Text.RegularExpressions.Regex.IsMatch(pin, @"^\d{4}$"))
            {
                lblResult.Text = "<span style='color:#e74c3c;'>❌ Please enter your 4-digit Transaction PIN.</span>";
                return;
            }

            string hashedPIN = HashPassword(pin);

            decimal amount;
            if (!decimal.TryParse(txtAmount.Text, out amount))
            {
                lblResult.Text = "<span style='color:#e74c3c;'>Invalid amount format entered.</span>";
                return;
            }

            using (var db = new SqlConnection(connDB))
            {
                db.Open();

                // Verify PIN
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM USER_TBL WHERE ACCOUNT_NO = @acct AND PIN_HASH = @pin";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    cmd.Parameters.AddWithValue("@pin", hashedPIN);
                    if ((int)cmd.ExecuteScalar() == 0)
                    {
                        lblResult.Text = "<span style='color:#e74c3c;'>❌ Incorrect PIN. Transaction cancelled.</span>";
                        return;
                    }
                }

                using (SqlTransaction transaction = db.BeginTransaction(IsolationLevel.Serializable))
                {
                    try
                    {
                        decimal currentBalance = GetCurrentBalance(accountNo, db, transaction);
                        decimal maxWalletCapacity = 500000.00m;

                        if (currentBalance + amount > maxWalletCapacity)
                        {
                            transaction.Rollback();
                            lblResult.Text = "<span style='color:#e74c3c;'>Total balance cannot exceed ₱" + maxWalletCapacity.ToString("N2") + ".</span>";
                            return;
                        }

                        decimal balanceAfter = currentBalance + amount;

                        using (var cmd = db.CreateCommand())
                        {
                            cmd.Transaction = transaction;
                            cmd.CommandText =
                                "INSERT INTO TRANSACTION_TBL (ACCOUNT_NO, TRANS_TYPE, AMOUNT, BALANCE_AFTER, TRANS_DATE) " +
                                "VALUES (@acct, 'D', @amount, @balAfter, GETDATE())";
                            cmd.Parameters.AddWithValue("@acct", accountNo);
                            cmd.Parameters.AddWithValue("@amount", amount);
                            cmd.Parameters.AddWithValue("@balAfter", balanceAfter);
                            cmd.ExecuteNonQuery();
                        }

                        using (var cmd2 = db.CreateCommand())
                        {
                            cmd2.Transaction = transaction;
                            cmd2.CommandText = "SELECT TOP 1 TRANS_ID FROM TRANSACTION_TBL WHERE ACCOUNT_NO = @acct ORDER BY TRANS_ID DESC";
                            cmd2.Parameters.AddWithValue("@acct", accountNo);
                            Session["LastTransID"] = cmd2.ExecuteScalar().ToString();
                        }

                        transaction.Commit();
                        Response.Redirect("Receipt.aspx");
                    }
                    catch
                    {
                        transaction.Rollback();
                        lblResult.Text = "<span style='color:#e74c3c;'>A processing error occurred. Please retry.</span>";
                    }
                }
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtAmount.Text = "";
            pin1.Text = pin2.Text = pin3.Text = pin4.Text = "";
            lblResult.Text = "";
            ClientScript.RegisterStartupScript(this.GetType(), "ClearDisplay", "document.getElementById('txtAmountDisplay').value = '';", true);
        }
    }
}