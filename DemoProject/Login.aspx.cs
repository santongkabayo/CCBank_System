using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DemoProject
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;

        // OS SYNCHRONIZATION OBJECT (Critical Section Lock)
        // Prevents multiple threads from crashing into the same log file simultaneously.
        private static readonly object _fileLock = new object();

        protected void Page_Load(object sender, EventArgs e)
        {
            // If already authenticated, bypass login gate immediately based on role layout
            if (Session["AccountNo"] != null)
            {
                if (Session["UserRole"]?.ToString() == "Admin")
                    Response.Redirect("Admin.aspx"); // Standardized redirection target name
                else
                    Response.Redirect("Dashboard.aspx");
            }
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

            // -------------------------------------------------------------
            // OS CONCEPT: PROCESS/THREAD LOAD SIMULATION
            // Mimics a heavy cryptography/network task. Perfect for demonstrating
            // concurrent user behaviors or request queues to your professor.
            // -------------------------------------------------------------
            Thread.Sleep(100); // Suspends the current thread for 100ms

            bool isSuccess = false;
            string userRole = "Customer"; // Default fallback role state
            string logMessage = "";

            using (var db = new SqlConnection(connDB))
            {
                db.Open();
                using (var cmd = db.CreateCommand())
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = "SELECT ACCOUNT_NO, USERNAME, LASTNAME, FIRSTNAME, DATE_REGISTERED, USER_ROLE, ACCOUNT_STATUS "
                                    + "FROM USER_TBL "
                                    + "WHERE USERNAME = @username AND PASSWORD_HASH = @password";
                    cmd.Parameters.AddWithValue("@username", username);
                    cmd.Parameters.AddWithValue("@password", hashedPw);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            // --- ADMINISTRATIVE LOCK GATE SYSTEM ---
                            // Check the account status immediately before processing sessions or routing paths
                            string status = dr["ACCOUNT_STATUS"] != DBNull.Value ? dr["ACCOUNT_STATUS"].ToString() : "Active";

                            if (status == "Locked")
                            {
                                lblResult.Text = "<span style='color:red;'>Your account has been administratively suspended. Please contact support.</span>";

                                // Explicitly record the security breach attempt into the file system log before returning
                                LogSecurityEventToOS($"BLOCKED ACCESS - Suspended account '{username}' attempted login.");
                                return; // Hard structural breakpoint to kill processing immediately
                            }

                            // If account state is safe (Active), populate system session data arrays normally
                            isSuccess = true;
                            Session["AccountNo"] = dr["ACCOUNT_NO"].ToString();
                            Session["Username"] = dr["USERNAME"].ToString();
                            Session["Lastname"] = dr["LASTNAME"].ToString();
                            Session["Firstname"] = dr["FIRSTNAME"].ToString();
                            Session["DateRegistered"] = dr["DATE_REGISTERED"].ToString();

                            // Synchronize the retrieved role out to the system environment session
                            userRole = dr["USER_ROLE"] != DBNull.Value ? dr["USER_ROLE"].ToString() : "Customer";
                            Session["UserRole"] = userRole;

                            logMessage = $"SUCCESS - User '{username}' logged in successfully as [{userRole}].";
                        }
                        else
                        {
                            logMessage = $"FAILURE - Failed login attempt for user '{username}'. Invalid credentials.";
                        }
                    }
                }
            }

            // -------------------------------------------------------------
            // OS CONCEPT: FILE I/O MANAGEMENT & SYNCHRONIZATION
            // Safely interacts with the OS file system using mutual exclusion.
            // -------------------------------------------------------------
            LogSecurityEventToOS(logMessage);

            if (isSuccess)
            {
                // Core Routing Architecture Guard: Branch processing lines depending entirely on clearance rules
                if (userRole == "Admin")
                {
                    Response.Redirect("Admin.aspx");
                }
                else
                {
                    Response.Redirect("Dashboard.aspx");
                }
            }
            else
            {
                // Display error only if it wasn't intercepted by the Lock validation return above
                if (string.IsNullOrEmpty(lblResult.Text))
                {
                    lblResult.Text = "<span style='color:red;'>Invalid Username or Password.</span>";
                }
            }
        }

        /// <summary>
        /// Handles writing to the file system while utilizing thread lock mechanisms.
        /// </summary>
        private void LogSecurityEventToOS(string message)
        {
            string logFilePath = Server.MapPath("~/App_Data/security_audit.log");

            // CRITICAL SECTION: The 'lock' ensures Mutual Exclusion. 
            lock (_fileLock)
            {
                try
                {
                    string dir = Path.GetDirectoryName(logFilePath);
                    if (!Directory.Exists(dir))
                    {
                        Directory.CreateDirectory(dir);
                    }

                    using (StreamWriter writer = File.AppendText(logFilePath))
                    {
                        writer.WriteLine($"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {message}");
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("OS File Write Error: " + ex.Message);
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