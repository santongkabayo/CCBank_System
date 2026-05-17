using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;


namespace DemoProject
{
    public partial class Withdraw : System.Web.UI.Page
    {
        // Gets the connection string from web.config to connect to the database
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If not logged in, send back to Login page
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }

            // Load account info only on first load
            if (!IsPostBack) LoadInfo();
        }

        // Computes and returns the current balance of the user within an isolation transaction thread boundary
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

        // Loads the account number and current balance on the page
        private void LoadInfo()
        {
            string accountNo = Session["AccountNo"].ToString();
            lblAccountNo.Text = accountNo;

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                lblBalance.Text = GetCurrentBalance(accountNo, db, null).ToString("N2");
            }
        }

        // Runs when Withdraw button is clicked
        protected void btnWithdraw_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string accountNo = Session["AccountNo"].ToString();
            decimal amount;

            if (!decimal.TryParse(txtAmount.Text, out amount))
            {
                lblResult.Text = "<span style='color:#e74c3c;'>Invalid amount format entered.</span>";
                return;
            }

            if (amount < 100.00m)
            {
                lblResult.Text = "<span style='color:#e74c3c;'>Minimum required withdrawal amount is ₱100.00.</span>";
                return;
            }

            using (var db = new SqlConnection(connDB))
            {
                db.Open();

                // Concurrency Guard: Prevents double-click race conditions from overdrafting the account balance
                using (SqlTransaction transaction = db.BeginTransaction(IsolationLevel.Serializable))
                {
                    try
                    {
                        decimal currentBalance = GetCurrentBalance(accountNo, db, transaction);

                        if (amount > currentBalance)
                        {
                            lblResult.Text = "<span style='color:#e74c3c;'>Insufficient funds. " +
                                "Your current balance is ₱" + currentBalance.ToString("N2") + ".</span>";
                            transaction.Rollback();
                            return;
                        }

                        decimal balanceAfter = currentBalance - amount;

                        // Insert withdrawal row transaction ledger entry
                        using (var cmd = db.CreateCommand())
                        {
                            cmd.Transaction = transaction;
                            cmd.CommandText =
                                "INSERT INTO TRANSACTION_TBL (ACCOUNT_NO, TRANS_TYPE, AMOUNT, BALANCE_AFTER, TRANS_DATE) " +
                                "VALUES (@acct, 'W', @amount, @balAfter, GETDATE())";
                            cmd.Parameters.AddWithValue("@acct", accountNo);
                            cmd.Parameters.AddWithValue("@amount", amount);
                            cmd.Parameters.AddWithValue("@balAfter", balanceAfter);

                            cmd.ExecuteNonQuery();
                        }

                        // Retrieve the assigned primary key sequence identifier for transaction receipt handling
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
                    catch (Exception)
                    {
                        transaction.Rollback();
                        lblResult.Text = "<span style='color:#e74c3c;'>A temporary processing engine collision occurred. Please retry your withdrawal.</span>";
                    }
                }
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtAmount.Text = "";
            lblResult.Text = "";
            ClientScript.RegisterStartupScript(this.GetType(), "ClearDisplay", "document.getElementById('txtAmountDisplay').value = '';", true);
        }
    }
}