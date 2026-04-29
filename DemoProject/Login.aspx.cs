using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoProject
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AccountNo"] != null)
                Response.Redirect("Dashboard.aspx");
        }

        private string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string username = txtUsername.Text.Trim().ToLower();
            string hashedPw = HashPassword(txtPassword.Text);

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = "SELECT ACCOUNT_NO, USERNAME, LASTNAME, FIRSTNAME, DATE_REGISTERED "
                                    + "FROM USER_TBL "
                                    + "WHERE USERNAME = @username AND PASSWORD_HASH = @password";
                    cmd.Parameters.AddWithValue("@username", username);
                    cmd.Parameters.AddWithValue("@password", hashedPw);

                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        Session["AccountNo"] = dr["ACCOUNT_NO"].ToString();
                        Session["Username"] = dr["USERNAME"].ToString();
                        Session["Lastname"] = dr["LASTNAME"].ToString();
                        Session["Firstname"] = dr["FIRSTNAME"].ToString();
                        Session["DateRegistered"] = dr["DATE_REGISTERED"].ToString();
                        dr.Close();
                        Response.Redirect("Dashboard.aspx");
                    }
                    else
                    {
                        dr.Close();
                        lblResult.Text = "<span style='color:red;'>Invalid Username or Password.</span>";
                    }
                }
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtUsername.Text = "";
            lblResult.Text = "";
        }

    }
}