using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoProject
{
    public partial class Logout : System.Web.UI.Page
    {
        // Runs automatically when the page loads
        protected void Page_Load(object sender, EventArgs e)
        {
            // If not logged in, send to Login page
            if (Session["AccountNo"] == null)
                Response.Redirect("Login.aspx");
        }

        protected void btnConfirmLogout_Click(object sender, EventArgs e)
        {
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
            Response.Redirect("Dashboard.aspx");
        }
    }
}