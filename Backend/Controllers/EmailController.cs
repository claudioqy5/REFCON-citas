using System.Text.RegularExpressions;
using MailKit.Net.Imap;
using MailKit.Search;
using MailKit;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmailController : ControllerBase
    {
        [HttpGet("get-2fa-code")]
        public async Task<IActionResult> Get2FACode()
        {
            try
            {
                using var client = new ImapClient();
                // Connect to Gmail IMAP
                await client.ConnectAsync("imap.gmail.com", 993, true);

                // Authenticate using the App Password
                await client.AuthenticateAsync("hernanminsa@gmail.com", "ctyvgzorrpilndzk");

                // Open the Inbox folder in read-write mode
                var inbox = client.Inbox;
                await inbox.OpenAsync(FolderAccess.ReadWrite);

                // Search for unread emails
                var query = SearchQuery.NotSeen;
                var uids = await inbox.SearchAsync(query);

                if (uids.Count == 0)
                {
                    await client.DisconnectAsync(true);
                    return NotFound(new { success = false, message = "No se encontraron correos nuevos." });
                }

                // Get the latest unread email
                var uid = uids[uids.Count - 1];
                var message = await inbox.GetMessageAsync(uid);
                
                string body = message.TextBody ?? message.HtmlBody ?? "";

                // Extract 4 to 8 digit code (MINSA uses 6 usually)
                var match = Regex.Match(body, @"\b(\d{4,8})\b");
                
                if (match.Success)
                {
                    string code = match.Groups[1].Value;
                    
                    // Mark as read so we don't read it again next time
                    await inbox.AddFlagsAsync(uid, MessageFlags.Seen, true);
                    
                    await client.DisconnectAsync(true);
                    return Ok(new { success = true, code = code });
                }

                await client.DisconnectAsync(true);
                return NotFound(new { success = false, message = "Correo encontrado pero no contiene un código numérico." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }
}
