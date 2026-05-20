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
                LoadUserAccessLogs(); // Real database track directory load
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

                // 2. Count Today's Transactions (Using C# local date fallback to bypass restricted SQL functions)
                TimeZoneInfo localZone = TimeZoneInfo.FindSystemTimeZoneById("Taipei Standard Time");
                DateTime localToday = TimeZoneInfo.ConvertTime(DateTime.UtcNow, localZone).Date;

                SqlCommand cmd2 = new SqlCommand("SELECT TRANS_DATE FROM TRANSACTION_TBL", db);
                int transactionsTodayCount = 0;
                using (SqlDataReader dr = cmd2.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        if (dr["TRANS_DATE"] != DBNull.Value)
                        {
                            DateTime transTimeLocal = TimeZoneInfo.ConvertTime(Convert.ToDateTime(dr["TRANS_DATE"]), localZone);
                            if (transTimeLocal.Date == localToday)
                            {
                                transactionsTodayCount++;
                            }
                        }
                    }
                }
                lblTodayTrans.Text = transactionsTodayCount.ToString();

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

                // 4. REAL LIVE COUNTER: Pulls directly from our brand-new column tracking status
                SqlCommand cmd4 = new SqlCommand("SELECT COUNT(*) FROM USER_TBL WHERE ISNULL(IS_LOGGED_IN, 0) = 1", db);
                lblLiveUsers.Text = cmd4.ExecuteScalar().ToString();
            }
        }

        private void LoadUserAccessLogs()
        {
            using (SqlConnection db = new SqlConnection(connDB))
            {
                string query = @"
                    SELECT ACCOUNT_NO, 
                           (LASTNAME + ', ' + FIRSTNAME) as Fullname, 
                           USER_ROLE, 
                           DATE_REGISTERED, 
                           LAST_LOGIN_TIME, 
                           ISNULL(IS_LOGGED_IN, 0) as IS_LOGGED_IN 
                    FROM USER_TBL 
                    ORDER BY ISNULL(IS_LOGGED_IN, 0) DESC, LAST_LOGIN_TIME DESC";

                SqlDataAdapter da = new SqlDataAdapter(query, db);
                DataTable dt = new DataTable();
                da.Fill(dt);

                // --- C# TIMEZONE TRANSLATION WORKER ---
                TimeZoneInfo localZone = TimeZoneInfo.FindSystemTimeZoneById("Taipei Standard Time");

                DataTable clonedDt = dt.Clone();
                clonedDt.Columns["DATE_REGISTERED"].DataType = typeof(DateTime);
                clonedDt.Columns["LAST_LOGIN_TIME"].DataType = typeof(DateTime);
                foreach (DataRow row in dt.Rows) clonedDt.ImportRow(row);

                foreach (DataRow row in clonedDt.Rows)
                {
                    if (row["DATE_REGISTERED"] != DBNull.Value)
                    {
                        DateTime serverTime = Convert.ToDateTime(row["DATE_REGISTERED"]);
                        row["DATE_REGISTERED"] = TimeZoneInfo.ConvertTime(serverTime, localZone);
                    }
                    if (row["LAST_LOGIN_TIME"] != DBNull.Value)
                    {
                        DateTime serverTime = Convert.ToDateTime(row["LAST_LOGIN_TIME"]);
                        row["LAST_LOGIN_TIME"] = TimeZoneInfo.ConvertTime(serverTime, localZone);
                    }
                }

                gvUserAccessLogs.DataSource = clonedDt;
                gvUserAccessLogs.DataBind();
            }
        }

        private void LoadUsers()
        {
            using (SqlConnection db = new SqlConnection(connDB))
            {
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

                    dr.Close();

                    string newStatus = (currentStatus == "Locked") ? "Active" : "Locked";

                    SqlCommand updateCmd = new SqlCommand("UPDATE USER_TBL SET ACCOUNT_STATUS = @status WHERE ACCOUNT_NO = @acct", db);
                    updateCmd.Parameters.AddWithValue("@status", newStatus);
                    updateCmd.Parameters.AddWithValue("@acct", targetAcct);
                    updateCmd.ExecuteNonQuery();

                    lblAdminResult.Text = $"<span style='color:#27ae60;'>Account {targetAcct} status updated successfully to [{newStatus}].</span>";
                }
            }

            LoadStats();
            LoadUsers();
            LoadGlobalTransactions();
            LoadUserAccessLogs();
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

            LoadUserAccessLogs();
            txtTargetAccount.Text = "";
        }

        private void LoadGlobalTransactions()
        {
            using (SqlConnection db = new SqlConnection(connDB))
            {
                string query = "SELECT TOP 50 TRANS_DATE, ACCOUNT_NO, TRANS_TYPE, AMOUNT, SENT_TO, RECEIVED_FROM FROM TRANSACTION_TBL ORDER BY TRANS_DATE DESC";
                SqlDataAdapter da = new SqlDataAdapter(query, db);
                DataTable dt = new DataTable();
                da.Fill(dt);

                // --- C# TIMEZONE TRANSLATION WORKER ---
                TimeZoneInfo localZone = TimeZoneInfo.FindSystemTimeZoneById("Taipei Standard Time");

                DataTable clonedDt = dt.Clone();
                clonedDt.Columns["TRANS_DATE"].DataType = typeof(DateTime);
                foreach (DataRow row in dt.Rows) clonedDt.ImportRow(row);

                foreach (DataRow row in clonedDt.Rows)
                {
                    if (row["TRANS_DATE"] != DBNull.Value)
                    {
                        DateTime serverTime = Convert.ToDateTime(row["TRANS_DATE"]);
                        row["TRANS_DATE"] = TimeZoneInfo.ConvertTime(serverTime, localZone);
                    }
                }

                gvAllTransactions.DataSource = clonedDt;
                gvAllTransactions.DataBind();
            }
        }
    }
}