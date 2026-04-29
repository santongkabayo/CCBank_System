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
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }
        }
        protected void btnList_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) return;

            lblError.Text = "";
            DateTime fromDate, toDate, today = DateTime.Today;

            if (!DateTime.TryParse(txtFrom.Text, out fromDate) || !DateTime.TryParse(txtTo.Text, out toDate))
            {
                lblError.Text = "Invalid date format."; return;
            }
            if (fromDate > today || toDate > today)
            {
                lblError.Text = "Dates must not be future dates."; return;
            }
            if (fromDate > toDate)
            {
                lblError.Text = "From date must be earlier than To date."; return;
            }

            string accountNo = Session["AccountNo"].ToString();
            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText =
                        "SELECT ROW_NUMBER() OVER (ORDER BY TRANS_DATE) AS SEQ, " +
                        "       TRANS_TYPE, TRANS_DATE, " +
                        "       CASE WHEN TRANS_TYPE IN ('W','S') THEN AMOUNT ELSE NULL END AS DEBIT, " +
                        "       CASE WHEN TRANS_TYPE IN ('D','R') THEN AMOUNT ELSE NULL END AS CREDIT, " +
                        "       BALANCE_AFTER, SENT_TO, RECEIVED_FROM " +
                        "FROM TRANSACTION_TBL " +
                        "WHERE ACCOUNT_NO = @acct " +
                        "  AND CAST(TRANS_DATE AS DATE) >= @fromDate " +
                        "  AND CAST(TRANS_DATE AS DATE) <= @toDate " +
                        "ORDER BY TRANS_DATE";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    cmd.Parameters.AddWithValue("@fromDate", fromDate);
                    cmd.Parameters.AddWithValue("@toDate", toDate);

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);
                    grdStatement.DataSource = dt;
                    grdStatement.DataBind();

                    if (dt.Rows.Count == 0)
                        lblError.Text = "No transactions found for the selected date range.";
                }
            }
        }
    }
}