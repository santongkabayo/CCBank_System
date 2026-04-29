using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoProject
{
    public partial class Withdraw : System.Web.UI.Page
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
        protected void btnWithdraw_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string accountNo = Session["AccountNo"].ToString();
            decimal amount;
            if (!decimal.TryParse(txtAmount.Text, out amount))
            {
                lblResult.Text = "<span style='color:red;'>Invalid amount.</span>"; return;
            }

            if (amount % 100 != 0)
            {
                lblResult.Text = "<span style='color:red;'>Amount must be divisible by ₱100.00.</span>"; return;
            }

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                decimal currentBalance = GetCurrentBalance(accountNo, db);

                if (amount > currentBalance)
                {
                    lblResult.Text = "<span style='color:red;'>Insufficient funds. " +
                        "Your current balance is ₱" + currentBalance.ToString("N2") + ".</span>";
                    return;
                }

                decimal balanceAfter = currentBalance - amount;

                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText =
                        "INSERT INTO TRANSACTION_TBL (ACCOUNT_NO, TRANS_TYPE, AMOUNT, BALANCE_AFTER) " +
                        "VALUES (@acct, 'W', @amount, @balAfter)";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    cmd.Parameters.AddWithValue("@amount", amount);
                    cmd.Parameters.AddWithValue("@balAfter", balanceAfter);
                    cmd.ExecuteNonQuery();
                }

                lblBalance.Text = balanceAfter.ToString("N2");
                lblResult.Text = "<span style='color:green;'>Withdrawal of ₱" + amount.ToString("N2") +
                                  " successful! New Balance: ₱" + balanceAfter.ToString("N2") + "</span>";
                txtAmount.Text = "";
            }
        }
        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtAmount.Text = "";
            lblResult.Text = "";
        }
    }
}