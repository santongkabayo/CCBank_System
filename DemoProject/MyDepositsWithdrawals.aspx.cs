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
    public partial class MyDepositsWithdrawals : System.Web.UI.Page
    {
        // Gets the connection string from web.config to connect to the database
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }

            // Automatically suggest and pre-fill dates on the initial page load
            if (!IsPostBack)
            {
                DateTime today = DateTime.Today;
                DateTime firstDayOfMonth = new DateTime(today.Year, today.Month, 1);

                // Format as yyyy-MM-dd so the browser HTML5 date control recognizes it
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
            grdData.DataSource = null;
            grdData.DataBind();

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

            // Set toDate to end of that day (23:59:59) so afternoon transactions aren't cut off
            DateTime endOfToDate = toDate.Date.AddDays(1).AddTicks(-1);

            string type = ddlType.SelectedValue;
            string accountNo = Session["AccountNo"].ToString();

            // Open database connection
            using (SqlConnection db = new SqlConnection(connDB))
            {
                db.Open();
                using (SqlCommand cmd = db.CreateCommand())
                {
                    // Parameterized base query mapping a CASE statement to display clean text labels
                    string baseQuery = "SELECT ROW_NUMBER() OVER (ORDER BY TRANS_DATE) AS SEQ, " +
                                       "       CASE TRANS_TYPE WHEN 'D' THEN 'Deposit' WHEN 'W' THEN 'Withdrawal' ELSE TRANS_TYPE END AS TRANS_TYPE, " +
                                       "       TRANS_DATE, AMOUNT " +
                                       "FROM TRANSACTION_TBL " +
                                       "WHERE ACCOUNT_NO = @acct " +
                                       "  AND TRANS_DATE >= @fromDate " +
                                       "  AND TRANS_DATE <= @endDate ";

                    // Safely apply filtering parameters without concatenating raw strings
                    if (type == "ALL")
                    {
                        baseQuery += " AND TRANS_TYPE IN ('D', 'W') ";
                    }
                    else
                    {
                        baseQuery += " AND TRANS_TYPE = @type ";
                        cmd.Parameters.AddWithValue("@type", type);
                    }

                    baseQuery += " ORDER BY TRANS_DATE"; // Displays oldest transaction records first

                    cmd.CommandText = baseQuery;
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
                    grdData.DataSource = dt;
                    grdData.DataBind();

                    // Show message if no records found
                    if (dt.Rows.Count == 0)
                    {
                        lblError.Text = "No records found for the selected filter.";
                    }
                }
            }
        }
    }
}