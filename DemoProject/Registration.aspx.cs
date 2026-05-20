using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;

namespace DemoProject
{
    public partial class Registration : System.Web.UI.Page
    {
        string connDB = WebConfigurationManager.ConnectionStrings["connDB"].ConnectionString;
        private static readonly object _fileLock = new object();
        private static readonly Random _rng = new Random();

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
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        private string GenerateNumericAccountNo()
        {
            lock (_rng)
            {
                StringBuilder numericBuilder = new StringBuilder();
                for (int i = 0; i < 11; i++)
                    numericBuilder.Append(_rng.Next(0, 10));
                return numericBuilder.ToString();
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) { lblResult.Text = ""; return; }

            string username = txtUsername.Text.Trim().ToLower();
            string lastname = txtLastname.Text.Trim().ToUpper();
            string firstname = txtFirstname.Text.Trim().ToUpper();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;
            string secretQuestion = ddlSecretQuestion.SelectedValue;
            string secretAnswer = txtSecretAnswer.Text.Trim().ToLower();
            string pin = txtPIN.Text.Trim();

            if (pin.Length != 4 || !System.Text.RegularExpressions.Regex.IsMatch(pin, @"^\d{4}$"))
            {
                lblResult.Text = "<span style='color:red;'>PIN must be exactly 4 digits (0-9).</span>";
                return;
            }

            string passwordPattern = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,50}$";
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, passwordPattern))
            {
                lblResult.Text = "<span style='color:red;'>Password must be at least 6 characters and contain an uppercase letter, a lowercase letter, and a number.</span>";
                LogSystemEvent("REGISTRATION REJECTED: Client attempted password policy submission bypass.");
                return;
            }

            string hashedPw = HashPassword(password);
            string hashedAnswer = HashPassword(secretAnswer);
            string hashedPIN = HashPassword(pin);

            using (var db = new SqlConnection(connDB))
            {
                db.Open();

                // FIXED: Changed IsolationLevel from Serializable to ReadCommitted to stop concurrency collisions
                using (SqlTransaction transaction = db.BeginTransaction(IsolationLevel.ReadCommitted))
                {
                    try
                    {
                        if (CheckDuplicateInTransaction("USERNAME", username, db, transaction))
                        {
                            transaction.Rollback();
                            lblResult.Text = "<span style='color:red;'>Username already taken.</span>";
                            LogSystemEvent($"REGISTRATION ATTEMPT DENIED: Username '{username}' already exists.");
                            return;
                        }

                        if (CheckDuplicateInTransaction("EMAIL", email, db, transaction))
                        {
                            transaction.Rollback();
                            lblResult.Text = "<span style='color:red;'>Email already registered.</span>";
                            LogSystemEvent($"REGISTRATION ATTEMPT DENIED: Email '{email}' already exists.");
                            return;
                        }

                        string accountNo = GenerateNumericAccountNo();
                        int safetyCounter = 0;
                        while (CheckDuplicateInTransaction("ACCOUNT_NO", accountNo, db, transaction) && safetyCounter < 10)
                        {
                            accountNo = GenerateNumericAccountNo();
                            safetyCounter++;
                        }

                        using (var cmd = db.CreateCommand())
                        {
                            cmd.Transaction = transaction;
                            cmd.CommandText =
                                "INSERT INTO USER_TBL (ACCOUNT_NO, USERNAME, LASTNAME, FIRSTNAME, EMAIL, PASSWORD_HASH, PIN_HASH, SECRET_QUESTION, SECRET_ANSWER, DATE_REGISTERED) " +
                                "VALUES (@acct, @username, @lastname, @firstname, @email, @pw, @pin, @sq, @sa, GETDATE())";

                            cmd.Parameters.AddWithValue("@acct", accountNo);
                            cmd.Parameters.AddWithValue("@username", username);
                            cmd.Parameters.AddWithValue("@lastname", lastname);
                            cmd.Parameters.AddWithValue("@firstname", firstname);
                            cmd.Parameters.AddWithValue("@email", email);
                            cmd.Parameters.AddWithValue("@pw", hashedPw);
                            cmd.Parameters.AddWithValue("@pin", hashedPIN);
                            cmd.Parameters.AddWithValue("@sq", secretQuestion);
                            cmd.Parameters.AddWithValue("@sa", hashedAnswer);

                            int rowsAffected = cmd.ExecuteNonQuery();

                            if (rowsAffected > 0)
                            {
                                transaction.Commit();
                                lblResult.Text = "<span style='color:green;'>✅ Registration successful!<br/>" +
                                                 "Your Account No: <strong>" + accountNo + "</strong><br/>" +
                                                 "<a href='Login.aspx'>Click here to Login</a></span>";
                                LogSystemEvent($"REGISTRATION SUCCESSFUL: Account '{accountNo}' assigned to User '{username}'.");
                                ClearFormFields();
                            }
                            else
                            {
                                transaction.Rollback();
                                lblResult.Text = "<span style='color:red;'>Registration failed. Please try again.</span>";
                                LogSystemEvent($"REGISTRATION FAILED: INSERT returned 0 rows for Username '{username}'.");
                            }
                        }
                    }
                    catch (SqlException ex)
                    {
                        try { transaction.Rollback(); } catch { }
                        lblResult.Text = "<span style='color:red;'>❌ Database Error: " + ex.Message + "</span>";
                        LogSystemEvent($"SQL EXCEPTION: {ex.Number} - {ex.Message}");
                    }
                    catch (Exception ex)
                    {
                        try { transaction.Rollback(); } catch { }
                        lblResult.Text = "<span style='color:red;'>❌ Unexpected Error: " + ex.Message + "</span>";
                        LogSystemEvent($"UNEXPECTED EXCEPTION: {ex.Message}");
                    }
                }
            }
        }

        private bool CheckDuplicateInTransaction(string field, string value, SqlConnection connection, SqlTransaction transaction)
        {
            using (var cmd = connection.CreateCommand())
            {
                cmd.Transaction = transaction;
                cmd.CommandText = $"SELECT COUNT(*) FROM USER_TBL WHERE {field} = @val";
                cmd.Parameters.AddWithValue("@val", value);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private void LogSystemEvent(string logMessage)
        {
            string physicalLogPath = Server.MapPath("~/App_Data/security_audit.log");
            lock (_fileLock)
            {
                try
                {
                    string baseDir = Path.GetDirectoryName(physicalLogPath);
                    if (!Directory.Exists(baseDir))
                        Directory.CreateDirectory(baseDir);

                    using (StreamWriter fileLogWriter = File.AppendText(physicalLogPath))
                        fileLogWriter.WriteLine($"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {logMessage}");
                }
                catch (Exception fileSysEx)
                {
                    System.Diagnostics.Debug.WriteLine("File Logging Error: " + fileSysEx.Message);
                }
            }
        }

        private void ClearFormFields()
        {
            txtUsername.Text = txtLastname.Text = txtFirstname.Text =
            txtEmail.Text = txtSecretAnswer.Text = txtPIN.Text = "";
            ddlSecretQuestion.SelectedIndex = 0;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearFormFields();
            lblResult.Text = "";
        }
    }
}