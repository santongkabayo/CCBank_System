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
    public partial class MySentReceived : System.Web.UI.Page
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

            string type = ddlType.SelectedValue;
            string accountNo = Session["AccountNo"].ToString();

            string typeFilter = (type == "ALL") ? "TRANS_TYPE IN ('S','R')" :
                                                   "TRANS_TYPE = '" + type + "'";

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText =
                        "SELECT ROW_NUMBER() OVER (ORDER BY TRANS_DATE DESC) AS SEQ, " +
                        "       TRANS_DATE, AMOUNT, SENT_TO, RECEIVED_FROM " +
                        "FROM TRANSACTION_TBL " +
                        "WHERE ACCOUNT_NO = @acct " +
                        "  AND " + typeFilter +
                        "  AND CAST(TRANS_DATE AS DATE) >= @fromDate " +
                        "  AND CAST(TRANS_DATE AS DATE) <= @toDate " +
                        "ORDER BY TRANS_DATE DESC";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    cmd.Parameters.AddWithValue("@fromDate", fromDate);
                    cmd.Parameters.AddWithValue("@toDate", toDate);

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);
                    grdData.DataSource = dt;
                    grdData.DataBind();

                    if (dt.Rows.Count == 0)
                        lblError.Text = "No records found for the selected filter.";
                }
            }
        }
    }
}