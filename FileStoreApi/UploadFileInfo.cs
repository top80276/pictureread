namespace FileStoreApi
{
    /// <summary>
    /// 管理檔案上傳參數
    /// 
    /// Mahler 2022/12/27
    /// </summary>
    public class UploadFileInfo
    {
        public IFormFile File { get; set; }
        public string ContentType { get; set; }
        public string RefNo { get; set; }
    }
}
