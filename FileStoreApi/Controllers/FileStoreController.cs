using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace FileStoreApi.Controllers
{
    [Route("api/fs")]
    [ApiController]
    public class FileStoreController : ControllerBase
    {
        private readonly IConfiguration Configuration;

        public FileStoreController(IConfiguration configuration) : base()
        {
            Configuration = configuration;

            if (!string.IsNullOrEmpty(Configuration["CONN_STR"]))
            {
                DB.DataProvider.ConnectionString = Configuration["CONN_STR"];
            }
        }

        private bool ValidateApiKey()
        {
            string? api_key = null;

            if (!string.IsNullOrEmpty(Configuration["API_KEY"]))
            {
                api_key = Configuration["API_KEY"];
            }

            if (api_key == null)
            {
                return true;
            }
            else
            {
                if (!Request.Headers.ContainsKey("API-KEY") || !(Request.Headers["API-KEY"].Equals("@@@API-KEY@@@")))
                {
                    Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                    return false;
                }
                return true;
            }
        }

        [HttpPost]
        [DisableRequestSizeLimit]
        [Route("upload")]
        public IActionResult Upload([FromForm] UploadFileInfo info)
        {
            if (!ValidateApiKey()) return Unauthorized();

            if (info.File.Length <= 0)
            {
                return BadRequest("Can not upload zero-sized file.");
            }

            try
            {
                //: Create new internal filename
                Guid fs_id = Guid.NewGuid();

                string filetable_name = "datastore";
                DB.sp_fs_root_path.Param p1 = new DB.sp_fs_root_path.Param();
                p1.ftable_name = filetable_name;
                string sqlRootPath = DB.sp_fs_root_path.Execute(p1);

                FileInfo targetFile = new FileInfo(Path.Combine(sqlRootPath, fs_id.ToString()));

                if (string.IsNullOrEmpty(sqlRootPath))
                {
                    throw new InvalidProgramException("Error - Can not find filetable " + filetable_name);
                }

                //: Upload to FileTable 'datastore'
                try
                {
                    FileStream fsWrite = System.IO.File.OpenWrite(targetFile.FullName);
                    info.File.CopyTo(fsWrite);
                    fsWrite.Close();
                }
                catch (Exception x)
                {
                    return BadRequest(x.Message);
                }

                //: Find file in FileTable 'datastore' and retrieve stream_id
                DB.sp_fs_store_get_by_name.Param p2 = new DB.sp_fs_store_get_by_name.Param();
                p2.filename = targetFile.Name;
                var rows1 = DB.sp_fs_store_get_by_name.ExecuteArr(p2);
                if (rows1.Length == 0)
                {
                    throw new InvalidProgramException("???");
                }

                string stream_id = rows1[0].stream_id;
                int file_size = int.Parse(rows1[0].cached_file_size);

                //: Add new entry to FileInfo
                DB.sp_fs_fileinfo_add.Param p3 = new DB.sp_fs_fileinfo_add.Param();
                p3.fs_id = fs_id;
                p3.stream_id = Guid.Parse(rows1[0].stream_id);
                p3.origin_path = (info.File.FileName == null ? string.Empty : info.File.FileName);
                p3.origin_name = info.File.FileName;
                p3.content_type = info.ContentType;
                p3.file_size = file_size;
                p3.ref_no = info.RefNo;
                DB.sp_fs_fileinfo_add.Execute(p3);

                return Ok(fs_id);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet]
        [Route("download")]
        public IActionResult Download(string fs_id)
        {
            if (!ValidateApiKey()) return Unauthorized();

            Guid guid = Guid.NewGuid();
            if (!Guid.TryParse(fs_id, out guid))
            {
                return BadRequest("Incorrect form of fs_id !!!");
            }

            DB.sp_fs_fileinfo_get.Param p1 = new DB.sp_fs_fileinfo_get.Param();
            p1.fs_id = guid;
            var rows1 = DB.sp_fs_fileinfo_get.ExecuteArr(p1);

            if (rows1.Length == 0)
            {
                return BadRequest("Can not find fs_id !!!");
            }

            DB.sp_fs_store_get_unc_path.Param p2 = new DB.sp_fs_store_get_unc_path.Param();
            p2.stream_id = Guid.Parse(rows1[0].stream_id);
            string unc_path = DB.sp_fs_store_get_unc_path.Execute(p2);

            FileInfo fileInfo = new FileInfo(unc_path);
            if (!fileInfo.Exists)
            {
                return BadRequest("Unable to locate file path in database.");
            }

            return PhysicalFile(fileInfo.FullName, rows1[0].content_type);
        }

        [HttpGet]
        [Route("delete")]
        public IActionResult Delete(string fs_id)
        {
            if (!ValidateApiKey()) return Unauthorized();

            Guid guid = Guid.NewGuid();
            if (!Guid.TryParse(fs_id, out guid))
            {
                return BadRequest("Incorrect form of fs_id !!!");
            }

            DB.sp_fs_fileinfo_get.Param p1 = new DB.sp_fs_fileinfo_get.Param();
            p1.fs_id = guid;
            var rows1 = DB.sp_fs_fileinfo_get.ExecuteArr(p1);

            if (rows1.Length == 0)
            {
                return BadRequest("Can not find fs_id !!!");
            }

            DB.sp_fs_store_get_unc_path.Param p2 = new DB.sp_fs_store_get_unc_path.Param();
            p2.stream_id = Guid.Parse(rows1[0].stream_id);
            string unc_path = DB.sp_fs_store_get_unc_path.Execute(p2);

            FileInfo fileInfo = new FileInfo(unc_path);
            if (!fileInfo.Exists)
            {
                return BadRequest("Unable to locate file path in database.");
            }

            try
            {
                fileInfo.Delete();
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
            finally
            {
                var p3 = new DB.sp_fs_fileinfo_del.Param();
                p3.fs_id = guid;
                DB.sp_fs_fileinfo_del.Execute(p3);
            }
            return Ok();
        }
    }
}
