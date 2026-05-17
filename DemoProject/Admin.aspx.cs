using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoProject
{
    public partial class Admin : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // --- SECURITY CHECK ---
            if (Session["AccountNo"] == null || Session["UserRole"]?.ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStats();
                LoadUsers();
                LoadGlobalTransactions();
            }
        }

        private void LoadStats()
        {
            using (SqlConnection db = new SqlConnection(connDB))
            {
                db.Open();

                // 1. Count Total Users
                SqlCommand cmd1 = new SqlCommand("SELECT COUNT(*) FROM USER_TBL", db);
                lblTotalUsers.Text = cmd1.ExecuteScalar().ToString();

                // 2. Count Today's Transactions
                SqlCommand cmd2 = new SqlCommand("SELECT COUNT(*) FROM TRANSACTION_TBL WHERE CAST(TRANS_DATE AS DATE) = CAST(GETDATE() AS DATE)", db);
                lblTodayTrans.Text = cmd2.ExecuteScalar().ToString();

                // 3. Calculate Global Liquidity
                SqlCommand cmd3 = new SqlCommand(@"
                    SELECT SUM(Credit) - SUM(Debit) 
                    FROM (
                        SELECT AMOUNT AS Credit, 0 AS Debit FROM TRANSACTION_TBL WHERE TRANS_TYPE IN ('D','R')
                        UNION ALL
                        SELECT 0, AMOUNT FROM TRANSACTION_TBL WHERE TRANS_TYPE IN ('W','S')
                    ) AS Liquidity", db);

                object total = cmd3.ExecuteScalar();
                lblTotalBalance.Text = (total != DBNull.Value) ? Convert.ToDecimal(total).ToString("N2") : "0.00";
            }
        }

        private void LoadUsers()
        {
            using (SqlConnection db = new SqlConnection(connDB))
            {
                // Pulls user list, retrieves account status, and calculates their balance on the fly
                string query = @"
                    SELECT u.ACCOUNT_NO, 
                           (u.LASTNAME + ', ' + u.FIRSTNAME) as Fullname, 
                           u.USER_ROLE, 
                           ISNULL(u.ACCOUNT_STATUS, 'Active') as ACCOUNT_STATUS,
                           (ISNULL((SELECT SUM(AMOUNT) FROM TRANSACTION_TBL WHERE ACCOUNT_NO = u.ACCOUNT_NO AND TRANS_TYPE IN ('D','R')),0) - 
                            ISNULL((SELECT SUM(AMOUNT) FROM TRANSACTION_TBL WHERE ACCOUNT_NO = u.ACCOUNT_NO AND TRANS_TYPE IN ('W','S')),0)) as CurrentBalance
                    FROM USER_TBL u";

                SqlDataAdapter da = new SqlDataAdapter(query, db);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvUsers.DataSource = dt;
                gvUsers.DataBind();
            }
        }

        protected void btnToggleLock_Click(object sender, EventArgs e)
        {
            string targetAcct = txtTargetAccount.Text.Trim();
            if (string.IsNullOrEmpty(targetAcct))
            {
                lblAdminResult.Text = "<span style='color:#e74c3c;'>Please provide a valid account number.</span>";
                return;
            }

            using (SqlConnection db = new SqlConnection(connDB))
            {
                db.Open();

                // 1. Check current account status
                SqlCommand checkCmd = new SqlCommand("SELECT ISNULL(ACCOUNT_STATUS, 'Active') AS ACCOUNT_STATUS, USER_ROLE FROM USER_TBL WHERE ACCOUNT_NO = @acct", db);
                checkCmd.Parameters.AddWithValue("@acct", targetAcct);

                using (SqlDataReader dr = checkCmd.ExecuteReader())
                {
                    if (!dr.Read())
                    {
                        lblAdminResult.Text = "<span style='color:#e74c3c;'>Account number not found.</span>";
                        return;
                    }

                    string currentStatus = dr["ACCOUNT_STATUS"].ToString();
                    string role = dr["USER_ROLE"].ToString();

                    if (role == "Admin")
                    {
                        lblAdminResult.Text = "<span style='color:#e74c3c;'>Security Rule: You cannot lock another administrator account.</span>";
                        return;
                    }

                    dr.Close(); // Close reader before running update command

                    // 2. Toggle the status string values
                    string newStatus = (currentStatus == "Locked") ? "Active" : "Locked";

                    SqlCommand updateCmd = new SqlCommand("UPDATE USER_TBL SET ACCOUNT_STATUS = @status WHERE ACCOUNT_NO = @acct", db);
                    updateCmd.Parameters.AddWithValue("@status", newStatus);
                    updateCmd.Parameters.AddWithValue("@acct", targetAcct);
                    updateCmd.ExecuteNonQuery();

                    lblAdminResult.Text = $"<span style='color:#27ae60;'>Account {targetAcct} status updated successfully to [{newStatus}].</span>";
                }
            }

            // Refresh your data tables instantly
            LoadStats();
            LoadUsers();
            LoadGlobalTransactions();
            txtTargetAccount.Text = "";
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            string targetAcct = txtTargetAccount.Text.Trim();
            if (string.IsNullOrEmpty(targetAcct))
            {
                lblAdminResult.Text = "<span style='color:#e74c3c;'>Please provide a valid account number.</span>";
                return;
            }

            // Hash the default "Temp123!" string using SHA256 to align with your login logic
            string temporaryPassword = "Temp123!";
            string hashedPw;
            using (System.Security.Cryptography.SHA256 sha = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(System.Text.Encoding.UTF8.GetBytes(temporaryPassword));
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                hashedPw = sb.ToString();
            }

            using (SqlConnection db = new SqlConnection(connDB))
            {
                db.Open();

                SqlCommand cmd = new SqlCommand("UPDATE USER_TBL SET PASSWORD_HASH = @pw WHERE ACCOUNT_NO = @acct", db);
                cmd.Parameters.AddWithValue("@pw", hashedPw);
                cmd.Parameters.AddWithValue("@acct", targetAcct);

                int rowsAffected = cmd.ExecuteNonQuery();
                if (rowsAffected > 0)
                {
                    lblAdminResult.Text = $"<span style='color:#27ae60;'>Password for Account {targetAcct} reset to default 'Temp123!' successfully.</span>";
                }
                else
                {
                    lblAdminResult.Text = "<span style='color:#e74c3c;'>Account number not found. Failed to reset password.</span>";
                }
            }
            txtTargetAccount.Text = "";
        }

        private void LoadGlobalTransactions()
        {
            using (SqlConnection db = new SqlConnection(connDB))
            {
                // Pulls EVERY transaction from EVERY user, newest first
                string query = "SELECT TOP 50 TRANS_DATE, ACCOUNT_NO, TRANS_TYPE, AMOUNT, SENT_TO, RECEIVED_FROM FROM TRANSACTION_TBL ORDER BY TRANS_DATE DESC";
                SqlDataAdapter da = new SqlDataAdapter(query, db);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvAllTransactions.DataSource = dt;
                gvAllTransactions.DataBind();
            }
        }
    }
}