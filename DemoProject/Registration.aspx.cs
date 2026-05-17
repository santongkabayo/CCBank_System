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
        // OS SYNCHRONIZATION MUTEX: Protects concurrent writing to the shared file log system
        // OS SYNCHRONIZATION MUTEX: Protects concurrent writing to the shared file log system
        private static readonly object _fileLock = new object();

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

        /// <summary>
        /// NEW NUMERIC FUNCTION: Generates a standardized 11-digit bank identifier.
        /// Does not rely on passwords or text strings, keeping user state completely unlinked.
        /// </summary>
        private string GenerateNumericAccountNo()
        {
            Random randomizer = new Random();
            StringBuilder numericBuilder = new StringBuilder();

            // Generate 11 individual digits to avoid overflow limits of a standard 32-bit Integer
            for (int i = 0; i < 11; i++)
            {
                numericBuilder.Append(randomizer.Next(0, 10));
            }

            return numericBuilder.ToString();
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

            string hashedPw = HashPassword(password);
            string hashedAnswer = HashPassword(secretAnswer);
            string hashedPIN = HashPassword(pin);

            // Validate PIN layout before consuming OS memory processing cycles
            if (pin.Length != 4 || !System.Text.RegularExpressions.Regex.IsMatch(pin, @"^\d{4}$"))
            {
                lblResult.Text = "<span style='color:red;'>PIN must be exactly 4 digits (0-9).</span>";
                return;
            }

            // NEW OS INPUT SECURITY GUARD: Validate complex password rules on the backend thread
            string passwordPattern = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,50}$";
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, passwordPattern))
            {
                lblResult.Text = "<span style='color:red;'>Password must be at least 6 characters long and contain an uppercase letter, a lowercase letter, and a number.</span>";
                LogSystemEvent("REGISTRATION REJECTED: Client attempted password policy submission bypass.");
                return; // Stop thread execution before hitting database transactions
            }

            // -------------------------------------------------------------------------
            // OS CONCEPT: PROCESS SYNCHRONIZATION via TRANSACTION ISOLATION LEVELS
            // Defends against Time-of-Check to Time-of-Use (TOCTOU) race condition errors.
            // -------------------------------------------------------------------------
            using (var db = new SqlConnection(connDB))
            {
                db.Open();

                // Establish a strict multi-user concurrency barrier.
                // Serializable isolation level blocks any competing threads from touching 
                // the checked data until our process completely validates and inserts.
                using (SqlTransaction transaction = db.BeginTransaction(IsolationLevel.Serializable))
                {
                    try
                    {
                        // 1. Perform atomic duplicate checks inside the synchronized transaction scope
                        if (CheckDuplicateInTransaction("USERNAME", username, db, transaction))
                        {
                            lblResult.Text = "<span style='color:red;'>Username already taken.</span>";
                            LogSystemEvent($"REGISTRATION ATTEMPT DENIED: Username '{username}' already exists (Race Condition Prevented).");
                            return;
                        }
                        if (CheckDuplicateInTransaction("EMAIL", email, db, transaction))
                        {
                            lblResult.Text = "<span style='color:red;'>Email already registered.</span>";
                            LogSystemEvent($"REGISTRATION ATTEMPT DENIED: Email '{email}' already exists.");
                            return;
                        }

                        // GENERATE AND VERIFY UNIQUE ACCOUNT NUMBER
                        string accountNo = GenerateNumericAccountNo();
                        int safetyCounter = 0;

                        // OS Safety Check Loop: If the random number hits an existing number in the DB,
                        // recalculate a new number immediately inside our isolated transaction lock!
                        while (CheckDuplicateInTransaction("ACCOUNT_NO", accountNo, db, transaction) && safetyCounter < 10)
                        {
                            accountNo = GenerateNumericAccountNo();
                            safetyCounter++;
                        }

                        // 2. Safe Execution: No other background thread could have slipped in during this validation window.
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

                            int ctr = cmd.ExecuteNonQuery();
                            if (ctr > 0)
                            {
                                // Commit lock and push mutations permanently down to disk storage
                                transaction.Commit();

                                lblResult.Text = "<span style='color:green;'>✅ Registration successful!<br/>" +
                                                 "Your Account No: <strong>" + accountNo + "</strong><br/>" +
                                                 "<a href='Login.aspx'>Click here to Login</a></span>";

                                LogSystemEvent($"REGISTRATION SUCCESSFUL: Account '{accountNo}' assigned to User '{username}'.");
                                ClearFormFields();
                            }
                            else
                            {
                                lblResult.Text = "<span style='color:red;'>Registration failed. Please try again.</span>";
                            }
                        }
                    }
                    catch (SqlException ex)
                    {
                        // Handle potential structural deadlock situations safely without system instability
                        lblResult.Text = "<span style='color:red;'>A concurrency lock collision occurred. Please retry your request.</span>";
                        LogSystemEvent($"OS EXCEPTION DETECTED - DB State Deadlock: {ex.Message}");
                    }
                }
            }
        }

        private bool CheckDuplicateInTransaction(string field, string value, SqlConnection connection, SqlTransaction transaction)
        {
            using (var cmd = connection.CreateCommand())
            {
                cmd.Transaction = transaction;
                cmd.CommandText = $"SELECT COUNT(*) FROM USER_TBL WITH (XLOCK, ROWLOCK) WHERE {field} = @val";
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
                    {
                        Directory.CreateDirectory(baseDir);
                    }

                    using (StreamWriter fileLogWriter = File.AppendText(physicalLogPath))
                    {
                        fileLogWriter.WriteLine($"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {logMessage}");
                    }
                }
                catch (Exception fileSysEx)
                {
                    System.Diagnostics.Debug.WriteLine("OS Hardware File Handling Error: " + fileSysEx.Message);
                }
            }
        }

        private void ClearFormFields()
        {
            txtUsername.Text = txtLastname.Text = txtFirstname.Text = txtEmail.Text = txtSecretAnswer.Text = txtPIN.Text = "";
            ddlSecretQuestion.SelectedIndex = 0;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearFormFields();
            lblResult.Text = "";
        }
    }
}