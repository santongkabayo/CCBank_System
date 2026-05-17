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
    public partial class Dashboard : System.Web.UI.Page
    {
        // Gets the connection string from web.config to connect to the database
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // DEFENSE IN DEPTH: Guard against null session states before accessing OS memory variables
            if (Session["AccountNo"] == null || Session["Firstname"] == null || Session["Lastname"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Load dashboard data only on first load, not on every postback event
            if (!IsPostBack)
            {
                LoadDashboard();
            }
        }

        /// <summary>
        /// Reads secure isolated user data blocks and pulls transactional updates from disk storage.
        /// </summary>
        private void LoadDashboard()
        {
            // Extract immutable state safe-guards from the OS Session memory pool
            string accountNo = Session["AccountNo"].ToString();
            string lastname = Session["Lastname"].ToString();
            string firstname = Session["Firstname"].ToString();
            string dateRegistered = Session["DateRegistered"] != null ? Session["DateRegistered"].ToString() : "";

            // Display descriptive data bindings on frontend text layers
            lblWelcome.Text = Server.HtmlEncode(firstname + " " + lastname); // Guard against stored XSS scripting bugs
            lblAccountNo.Text = Server.HtmlEncode(accountNo);
            lblName.Text = Server.HtmlEncode(lastname + ", " + firstname);

            if (lblAccountNo2 != null) lblAccountNo2.Text = Server.HtmlEncode(accountNo);

            // Structure system registration datetime parsing smoothly
            DateTime dt;
            lblDateRegistered.Text = DateTime.TryParse(dateRegistered, out dt)
                ? dt.ToString("MMMM dd, yyyy hh:mm tt") : "Not Available";

            // -------------------------------------------------------------------------
            // SYSTEMS DESIGN APPROACH: Multi-Query Batch Execution
            // Instead of opening 3 slow sequential query rounds, we batch them into a single I/O stream.
            // This drops context-switching overhead on the OS processor down drastically!
            // -------------------------------------------------------------------------
            string batchedSqlScript =
                // Query [0]: Compute Current Net Balance
                "SELECT ISNULL(SUM(CASE WHEN TRANS_TYPE IN ('D','R') THEN AMOUNT ELSE 0 END),0) - " +
                "       ISNULL(SUM(CASE WHEN TRANS_TYPE IN ('W','S') THEN AMOUNT ELSE 0 END),0) " +
                "FROM TRANSACTION_TBL WHERE ACCOUNT_NO = @acct; " +

                // Query [1]: Compute Total Aggregated Sent Money
                "SELECT ISNULL(SUM(AMOUNT),0) FROM TRANSACTION_TBL " +
                "WHERE ACCOUNT_NO = @acct AND TRANS_TYPE = 'S'; " +

                // Query [2]: FIXED BUG - Pull actual top 5 generic recent activities for transaction log
                "SELECT TOP 5 TRANS_DATE, " +
                "       CASE TRANS_TYPE WHEN 'D' THEN 'Deposit' WHEN 'W' THEN 'Withdrawal' WHEN 'S' THEN 'Sent' WHEN 'R' THEN 'Received' END AS TRANS_TYPE, " +
                "       AMOUNT, BALANCE_AFTER " +
                "FROM TRANSACTION_TBL WHERE ACCOUNT_NO = @acct " +
                "ORDER BY TRANS_DATE DESC; " +

                // Query [3]: Pull top 5 alerts matching received activities in the last week
                "SELECT TOP 5 TRANS_DATE, AMOUNT, RECEIVED_FROM FROM TRANSACTION_TBL " +
                "WHERE ACCOUNT_NO = @acct AND TRANS_TYPE = 'R' " +
                "AND TRANS_DATE >= DATEADD(DAY, -7, GETDATE()) " +
                "ORDER BY TRANS_DATE DESC;";

            // Wrap handles tightly in "using" statements to prevent physical unmanaged memory leaks
            using (SqlConnection db = new SqlConnection(connDB))
            {
                using (SqlCommand cmd = new SqlCommand(batchedSqlScript, db))
                {
                    cmd.Parameters.AddWithValue("@acct", accountNo);

                    // Introduce an active DataSet container mapping to populate via a single file system sweep
                    DataSet dashboardDataSet = new DataSet();

                    using (SqlDataAdapter systemAdapter = new SqlDataAdapter(cmd))
                    {
                        db.Open(); // Open operating system pipeline connection
                        systemAdapter.Fill(dashboardDataSet); // Stream data down into processing registers
                    } // SystemAdapter closed atomically here

                    // Extract computed data indexes safely out of the dataset tables
                    decimal currentBalance = (decimal)dashboardDataSet.Tables[0].Rows[0][0];
                    decimal totalSent = (decimal)dashboardDataSet.Tables[1].Rows[0][0];

                    lblBalance.Text = currentBalance.ToString("N2");
                    lblTotalSent.Text = totalSent.ToString("N2");

                    // Bind [Table 2] -> The generalized Recent Transactions Grid
                    grdRecentTrans.DataSource = dashboardDataSet.Tables[2];
                    grdRecentTrans.DataBind();

                    // Bind [Table 3] -> The isolated Security Received-Notification alert grid
                    DataTable receivedNotificationTable = dashboardDataSet.Tables[3];
                    if (receivedNotificationTable.Rows.Count > 0)
                    {
                        grdNotif.DataSource = receivedNotificationTable;
                        grdNotif.DataBind();
                        pnlNotif.Visible = true; // Make panel block displayable
                    }
                    else
                    {
                        pnlNotif.Visible = false; // Hide if empty
                    }
                } // SqlCommand transaction variables de-allocated here
            } // Hard network socket resource cleanly released back to OS core kernel pooling
        }
    }
}
