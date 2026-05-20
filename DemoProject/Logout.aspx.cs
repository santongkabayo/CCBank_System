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
    public partial class Logout : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If not logged in, send to Login page
            if (Session["AccountNo"] == null)
                Response.Redirect("Login.aspx");
        }

        protected void btnConfirmLogout_Click(object sender, EventArgs e)
        {
            // NEW FEATURE: Switch connection flag state to offline in database before clearing session
            if (Session["AccountNo"] != null)
            {
                string userAccount = Session["AccountNo"].ToString();

                using (SqlConnection db = new SqlConnection(connDB))
                {
                    db.Open();
                    using (SqlCommand logoutCmd = db.CreateCommand())
                    {
                        logoutCmd.CommandType = CommandType.Text;
                        logoutCmd.CommandText = "UPDATE USER_TBL SET IS_LOGGED_IN = 0 WHERE ACCOUNT_NO = @acct";
                        logoutCmd.Parameters.AddWithValue("@acct", userAccount);
                        logoutCmd.ExecuteNonQuery();
                    }
                }
            }

            // Clear all session data (removes all stored login info)
            Session.Clear();
            // Completely destroy the session
            Session.Abandon();
            // Send user back to Login page
            Response.Redirect("Login.aspx");
        }

        // Runs when Cancel button is clicked
        // User changed their mind — send them back to Dashboard
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            // Safety measure: routing fallback check for administrators who cancel out
            if (Session["UserRole"]?.ToString() == "Admin")
            {
                Response.Redirect("Admin.aspx");
            }
            else
            {
                Response.Redirect("Dashboard.aspx");
            }
        }
    }
}