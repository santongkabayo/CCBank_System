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
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }
            if (!IsPostBack) LoadDashboard();
        }
        private void LoadDashboard()
        {
            string accountNo = Session["AccountNo"].ToString();
            string lastname = Session["Lastname"].ToString();
            string firstname = Session["Firstname"].ToString();
            string dateRegistered = Session["DateRegistered"].ToString();

            lblWelcome.Text = firstname + " " + lastname;
            lblAccountNo.Text = accountNo;
            lblName.Text = lastname + ", " + firstname;

            DateTime dt;
            lblDateRegistered.Text = DateTime.TryParse(dateRegistered, out dt)
                ? dt.ToString("MMMM dd, yyyy hh:mm tt") : dateRegistered;

            using (var db = new SqlConnection(connDB))
            {
                db.Open();

                // Compute ang current balance
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText =
                        "SELECT " +
                        "  ISNULL(SUM(CASE WHEN TRANS_TYPE IN ('D','R') THEN AMOUNT ELSE 0 END),0) " +
                        "- ISNULL(SUM(CASE WHEN TRANS_TYPE IN ('W','S') THEN AMOUNT ELSE 0 END),0) " +
                        "FROM TRANSACTION_TBL WHERE ACCOUNT_NO = @acct";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    lblBalance.Text = ((decimal)cmd.ExecuteScalar()).ToString("N2");
                }

                // Overall nga na sent
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText =
                        "SELECT ISNULL(SUM(AMOUNT),0) FROM TRANSACTION_TBL " +
                        "WHERE ACCOUNT_NO = @acct AND TRANS_TYPE = 'S'";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    lblTotalSent.Text = ((decimal)cmd.ExecuteScalar()).ToString("N2");
                }

                // Recent na received (last 5, within last 7 days)
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText =
                        "SELECT TOP 5 TRANS_DATE, AMOUNT, RECEIVED_FROM FROM TRANSACTION_TBL " +
                        "WHERE ACCOUNT_NO = @acct AND TRANS_TYPE = 'R' " +
                        "AND TRANS_DATE >= DATEADD(DAY,-7,GETDATE()) " +
                        "ORDER BY TRANS_DATE DESC";
                    cmd.Parameters.AddWithValue("@acct", accountNo);
                    DataTable dt2 = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt2);
                    if (dt2.Rows.Count > 0)
                    {
                        grdNotif.DataSource = dt2;
                        grdNotif.DataBind();
                        pnlNotif.Visible = true;
                    }
                }
            }
        }
    }

}