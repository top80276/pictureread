# pictureread
QL Server 安裝注意

1.資料庫必須要啟用FileStream功能(安裝頁面全要勾)。

![FileStore1](https://github.com/user-attachments/assets/a9793b0b-3b27-4647-9ca3-3b7d3f1de789)


2.還原FileStore資料庫 (FileStore.bak)


IIS 設定
1.完成 NETCORE Bundle Install on IIS

2.建立站台，注意APP Pool要選未管理，且 Process Model 屬性中要給予本機帳號的 Identity，否則會出現Access Denied的問題。

![FileStore2](https://github.com/user-attachments/assets/a279d4ee-8320-4bc5-875c-ef20b96a6e32)


3.發布(publish)專案，並複製專案到IIS當中。



API 測試機使用說明


API 與測試方式

檔案上傳 /api/fs/upload

檔案下載 /api/fs/download

檔案刪除 /api/fs/delete


API 與測試方式

DB: FileStore @ localhost sa / XXXXX

Server URL: http://localhost/api/fs 

KEY: 請在 Header 中加入 API_KEY: @@@API-KEY@@@

檔案上傳 <server_url>/api/fs/upload

Action: POST

Body: Mutipart

File	檔案路徑

ContentType	檔案的MIME-TYPE

RefNo	給應用程式利用的參考

Return: File ID (fs_id) 檔案存取索引ID

實際呼叫的範例：

![FileStore3](https://github.com/user-attachments/assets/5a5dc829-2b40-4122-891c-22be6896ea23)


檔案下載 <server_url>/api/fs/download

Action: GET

URL Parameter: "fs_id?" + "XXXX-XXXX-XXXX....."

實際呼叫範例：

![FileStore4](https://github.com/user-attachments/assets/cc8ec366-8d44-4e85-94e4-5c046553ccf0)


檔案刪除 <server_url>/api/fs/delete

Action: GET

URL Parameter: "fs_id?" + "XXXX-XXXX-XXXX....."
