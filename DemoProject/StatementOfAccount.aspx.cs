using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

namespace DemoProject
{
    public partial class StatementOfAccount : System.Web.UI.Page
    {
        // Gets the connection string from web.config to connect to the database
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If not logged in, send back to Login page
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }

            // Automatically suggest and pre-fill dates on the initial page load
            if (!IsPostBack)
            {
                DateTime today = DateTime.Today;
                DateTime firstDayOfMonth = new DateTime(today.Year, today.Month, 1);

                // Pre-fills date field selectors cleanly across browser engines
                txtFrom.Text = firstDayOfMonth.ToString("yyyy-MM-dd");
                txtTo.Text = today.ToString("yyyy-MM-dd");
            }
        }

        // Runs when List button is clicked
        protected void btnList_Click(object sender, EventArgs e)
        {
            // Check if all required fields are filled
            Page.Validate();
            if (!Page.IsValid) return;

            lblError.Text = "";
            grdStatement.DataSource = null;
            grdStatement.DataBind();

            DateTime fromDate, toDate;
            DateTime today = DateTime.Today;

            // Try to convert the textbox values to DateTime
            if (!DateTime.TryParse(txtFrom.Text, out fromDate) || !DateTime.TryParse(txtTo.Text, out toDate))
            {
                lblError.Text = "Invalid date format.";
                return;
            }

            // Dates must not be future dates
            if (fromDate > today || toDate > today)
            {
                lblError.Text = "Dates must not be future dates.";
                return;
            }

            // From date must be earlier than or equal to To date
            if (fromDate > toDate)
            {
                lblError.Text = "From date must be earlier than To date.";
                return;
            }

            // Adjust end constraint to 23:59:59 to prevent time truncation errors
            DateTime endOfToDate = toDate.Date.AddDays(1).AddTicks(-1);

            string accountNo = Session["AccountNo"].ToString();

            // Open database connection
            using (SqlConnection db = new SqlConnection(connDB))
            {
                db.Open();
                using (SqlCommand cmd = db.CreateCommand())
                {
                    // Full parameterized statement query mapping readable strings to operation modes
                    cmd.CommandText =
                        "SELECT ROW_NUMBER() OVER (ORDER BY TRANS_DATE) AS SEQ, " +
                        "       CASE TRANS_TYPE " +
                        "            WHEN 'D' THEN 'Deposit' " +
                        "            WHEN 'W' THEN 'Withdrawal' " +
                        "            WHEN 'S' THEN 'Transfer Sent' " +
                        "            WHEN 'R' THEN 'Transfer Received' " +
                        "            ELSE TRANS_TYPE END AS TRANS_TYPE, " +
                        "       TRANS_DATE, " +
                        "       CASE WHEN TRANS_TYPE IN ('W','S') THEN AMOUNT ELSE NULL END AS DEBIT, " +
                        "       CASE WHEN TRANS_TYPE IN ('D','R') THEN AMOUNT ELSE NULL END AS CREDIT, " +
                        "       BALANCE_AFTER, SENT_TO, RECEIVED_FROM " +
                        "FROM TRANSACTION_TBL " +
                        "WHERE ACCOUNT_NO = @acct " +
                        "  AND TRANS_DATE >= @fromDate " +
                        "  AND TRANS_DATE <= @endDate " +
                        "ORDER BY TRANS_DATE"; // Statements display sequential order oldest to newest

                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    cmd.Parameters.AddWithValue("@fromDate", fromDate.Date);
                    cmd.Parameters.AddWithValue("@endDate", endOfToDate);

                    // Fill a DataTable with the query results
                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }

                    // Connect DataTable to GridView and display it
                    grdStatement.DataSource = dt;
                    grdStatement.DataBind();

                    // Show message if no transactions found
                    if (dt.Rows.Count == 0)
                    {
                        lblError.Text = "No transactions found for the selected date range.";
                    }
                }
            }
        }
    }
}