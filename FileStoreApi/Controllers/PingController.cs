using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace FileStoreApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PingController : ControllerBase
    {
        [HttpGet]
        public IActionResult Ping()
        {
            return Ok("ver. FY230106 " + DateTime.Now);
        }
    }
}
