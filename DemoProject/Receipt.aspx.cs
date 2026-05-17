using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

namespace DemoProject
{
    public partial class Receipt : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] == null) { Response.Redirect("Login.aspx"); return; }
            if (Session["LastTransID"] == null) { Response.Redirect("Dashboard.aspx"); return; }

            if (!IsPostBack) LoadReceipt();
        }

        private void LoadReceipt()
        {
            int transID = Convert.ToInt32(Session["LastTransID"].ToString());

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandText = "SELECT * FROM TRANSACTION_TBL WHERE TRANS_ID = @id";
                    cmd.Parameters.AddWithValue("@id", transID);
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        string transType = dr["TRANS_TYPE"].ToString();
                        string typeName = transType == "D" ? "Deposit" :
                                           transType == "W" ? "Withdrawal" :
                                           transType == "S" ? "Send CCBank Money" : "Received Money";

                        lblTransID.Text = dr["TRANS_ID"].ToString();
                        lblTransDate.Text = Convert.ToDateTime(dr["TRANS_DATE"]).ToString("MMMM dd, yyyy hh:mm tt");
                        lblTransType.Text = typeName;
                        lblAccountNo.Text = dr["ACCOUNT_NO"].ToString();
                        lblAmount.Text = Convert.ToDecimal(dr["AMOUNT"]).ToString("N2");
                        lblBalanceAfter.Text = Convert.ToDecimal(dr["BALANCE_AFTER"]).ToString("N2");

                        if (transType == "S" && dr["SENT_TO"] != DBNull.Value)
                        {
                            lblSentTo.Text = dr["SENT_TO"].ToString();
                            pnlSentTo.Visible = true;
                        }
                        if (transType == "R" && dr["RECEIVED_FROM"] != DBNull.Value)
                        {
                            lblReceivedFrom.Text = dr["RECEIVED_FROM"].ToString();
                            pnlReceivedFrom.Visible = true;
                        }
                    }
                    dr.Close();
                }
            }
        }
    }
}