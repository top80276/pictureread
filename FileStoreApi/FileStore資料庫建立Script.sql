USE [master]
GO
/****** Object:  Database [FileStore]    Script Date: 2022/12/27 下午 04:05:38 ******/
CREATE DATABASE [FileStore]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FileStore', FILENAME = N'C:\DBFiles\FileStore.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [FS] CONTAINS FILESTREAM  DEFAULT
( NAME = N'FileStore_fs', FILENAME = N'C:\DBFiles\FileStore_fs' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'FileStore_log', FILENAME = N'C:\DBFiles\FileStore_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [FileStore].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [FileStore] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [FileStore] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [FileStore] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [FileStore] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [FileStore] SET ARITHABORT OFF 
GO
ALTER DATABASE [FileStore] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [FileStore] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [FileStore] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [FileStore] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [FileStore] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [FileStore] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [FileStore] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [FileStore] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [FileStore] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [FileStore] SET  DISABLE_BROKER 
GO
ALTER DATABASE [FileStore] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [FileStore] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [FileStore] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [FileStore] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [FileStore] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [FileStore] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [FileStore] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [FileStore] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [FileStore] SET  MULTI_USER 
GO
ALTER DATABASE [FileStore] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [FileStore] SET DB_CHAINING OFF 
GO
ALTER DATABASE [FileStore] SET FILESTREAM( NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = N'DataFileStore' ) 
GO
ALTER DATABASE [FileStore] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [FileStore] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'FileStore', N'ON'
GO
ALTER DATABASE [FileStore] SET QUERY_STORE = OFF
GO
USE [FileStore]
GO
/****** Object:  Table [dbo].[datastore]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [dbo].[datastore] AS FILETABLE ON [PRIMARY] FILESTREAM_ON [FS]
WITH
(
FILETABLE_DIRECTORY = N'datastore1', FILETABLE_COLLATE_FILENAME = Chinese_Taiwan_Stroke_CI_AS
)
GO
/****** Object:  Table [dbo].[FileInfo]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileInfo](
	[fs_id] [uniqueidentifier] NOT NULL,
	[stream_id] [uniqueidentifier] NOT NULL,
	[origin_path] [nvarchar](255) NULL,
	[origin_name] [nvarchar](255) NULL,
	[content_type] [nvarchar](100) NULL,
	[file_size] [int] NULL,
	[ref_no] [nvarchar](100) NULL,
	[update_dt] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileInfo] ADD  CONSTRAINT [DF_FileInfo_update_dt]  DEFAULT (getdate()) FOR [update_dt]
GO
/****** Object:  StoredProcedure [dbo].[sp_fs_fileinfo_add]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	OODA_REMARK: Add new file information.
	OODA_RESULT: VOID
*/
CREATE PROCEDURE [dbo].[sp_fs_fileinfo_add]
	@fs_id				UNIQUEIDENTIFIER,
	@stream_id			UNIQUEIDENTIFIER,
	@origin_path		NVARCHAR(255),
	@origin_name		NVARCHAR(255),
	@content_type		NVARCHAR(100),
	@file_size			INT,
	@ref_no				NVARCHAR(100)
AS
	DELETE dbo.FileInfo WHERE fs_id = @fs_id	

	INSERT INTO dbo.FileInfo 
		(fs_id, stream_id, origin_path, origin_name, content_type, file_size, ref_no, update_dt)
	VALUES
		(@fs_id, @stream_id, @origin_path, @origin_name, @content_type, @file_size, @ref_no, GETDATE())
GO
/****** Object:  StoredProcedure [dbo].[sp_fs_fileinfo_del]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	OODA_REMARK: Delete file info
	OODA_RESULT: VOID
*/
CREATE PROCEDURE [dbo].[sp_fs_fileinfo_del]
	@fs_id			UNIQUEIDENTIFIER
AS
	DELETE dbo.FileInfo WHERE fs_id = @fs_id
GO
/****** Object:  StoredProcedure [dbo].[sp_fs_fileinfo_get]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	OODA_REMARK: Get file info
	OODA_RESULT: RECORDSET
*/
CREATE PROCEDURE [dbo].[sp_fs_fileinfo_get]
	@fs_id			UNIQUEIDENTIFIER
AS
	SELECT   fs_id, stream_id, origin_path, origin_name, content_type, file_size, ref_no, update_dt
	FROM     dbo.FileInfo
	WHERE	 fs_id = @fs_id
GO
/****** Object:  StoredProcedure [dbo].[sp_fs_root_path]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	OODA_REMARK: Get the root path of FileStore
	OODA_RESULT: SCALAR
*/
CREATE PROCEDURE [dbo].[sp_fs_root_path]
	@ftable_name	nvarchar(128)
AS
	IF (SELECT FILETABLEROOTPATH(@ftable_name)) IS NULL
		SELECT '' 
	ELSE
		SELECT FILETABLEROOTPATH(@ftable_name)
GO
/****** Object:  StoredProcedure [dbo].[sp_fs_store_get_by_name]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	OODA_REMARK: Get information from file table
	OODA_RESULT: RECORDSET
*/
CREATE PROCEDURE [dbo].[sp_fs_store_get_by_name]
	@filename	NVARCHAR(255)
AS
	SELECT stream_id, [name], cached_file_size, creation_time FROM dbo.datastore WHERE [name] = @filename
GO
/****** Object:  StoredProcedure [dbo].[sp_fs_store_get_unc_path]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	OODA_REMARK: Get UNC path by stream_id
	OODA_RESULT: SCALAR
*/
CREATE PROCEDURE [dbo].[sp_fs_store_get_unc_path]
	@stream_id		UNIQUEIDENTIFIER
AS
	SELECT file_stream.GetFileNamespacePath(1) AS 'unc_path' FROM dbo.datastore WHERE stream_id = @stream_id
GO
/****** Object:  StoredProcedure [dbo].[spOODA_SPDescription_get]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


/*
	OODA_Remark: get the decriptions from sp, used for OODA (2003/07/30)
	OODA_Result: SCALAR 
*/
CREATE PROCEDURE [dbo].[spOODA_SPDescription_get] 
--=====> ouput param. <=====
@MSG1 nvarchar(100) OUTPUT,
@MSG2 nvarchar(100) OUTPUT,
--=====> input param. <=====
@objName nvarchar(50) 
AS
--=====> declare the inner parameters <=====
DECLARE @SPStr nvarchar(4000) 
DECLARE @tmpSPStr   nvarchar(500)
DECLARE @FindStr nvarchar(30) 
DECLARE @flag_start smallint 
DECLARE @flag_end   smallint 
DECLARE @flag_len   smallint  
DECLARE @flag_esultType_start   smallint 
DECLARE @flag_default_end     smallint 
DECLARE @flag_default_len     smallint 
DECLARE @flag_description_start   smallint 
DECLARE @flag_description_end     smallint 
DECLARE @flag_description_len     smallint 
DECLARE @OODA_Remark    nvarchar(2000) 
DECLARE @OODA_Result    nvarchar(10)

--=====> setting the inner parameters <=====
SET @tmpSPStr = ''

--=====> get the text of sp <=====
SELECT @SPStr=text FROM syscomments WHERE id = object_id(@objName)  AND colid =1

--=====> cut the region of sp's parameters <=====
SET @flag_start	= 1
SET @flag_end	=CHARINDEX(UPPER('CREATE PROCEDURE'),UPPER(@SPStr))
SET @flag_len	=@flag_end-@flag_start
IF @flag_len<=0
BEGIN
	SET @MSG1='FAILURE'
	SET @MSG2='<spOODA_SPDescription_get>-''CREATE PROCEDURE'' should have only one space separator. ' 
	RETURN
END

SET @SPStr=SUBSTRING(@SPStr,@flag_start,@flag_len) 


--=====> get OODA_Remark <=====
SET @FindStr = 'OODA_Remark:'
SET @OODA_Remark=''
SET @flag_start	=CHARINDEX(UPPER(@FindStr),UPPER(@SPStr))+LEN(@FindStr)+1
SET @flag_end	=CHARINDEX(CHAR(10),@SPStr,@flag_start)
SET @flag_len	=@flag_end-@flag_start 
IF @flag_start <>0	
BEGIN
	SET @OODA_Remark=SUBSTRING(@SPStr,@flag_start,@flag_len)
END
IF @@ERROR >0
BEGIN
	SET @MSG1='FAILURE'
	SET @MSG2='<spOODA_SPDescription_get>-error occurs when get OODA_Remark' 
	RETURN
END
--=====> get OODA_Result <=====
SET @FindStr = 'OODA_Result:'
SET @OODA_Result=''
SET @flag_start	=CHARINDEX(UPPER(@FindStr),UPPER(@SPStr))+LEN(@FindStr)+1
SET @flag_end	=CHARINDEX(CHAR(10),@SPStr,@flag_start)
SET @flag_len	=@flag_end-@flag_start 
IF @flag_start <>0	
BEGIN
	SET @OODA_Result=SUBSTRING(@SPStr,@flag_start,@flag_len)
	SET @OODA_Result = REPLACE(@OODA_Result,CHAR(9),'')
	SET @OODA_Result = REPLACE(@OODA_Result,' ','')
END
IF @@ERROR >0
BEGIN
	SET @MSG1='FAILURE'
	SET @MSG2='<spOODA_SPDescription_get>-error occurs when get OODA_Result' 
	RETURN
END
ELSE
BEGIN
	SELECT  @OODA_Remark AS OODA_Remark,  
		  @OODA_Result AS OODA_Result 
	SET @MSG1='SUCCESS'
	SET @MSG2='' 
	RETURN
END


GO
/****** Object:  StoredProcedure [dbo].[spOODA_SPParameter_list]    Script Date: 2022/12/27 下午 04:05:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


/*
	OODA_Remark: get the information from sp's parameters, used for OODA (2003/008/13 by Jamy)
	OODA_Result: RECORDSET 
*/
CREATE PROCEDURE [dbo].[spOODA_SPParameter_list]
--=====> ouput param. <=====
@MSG1 nvarchar(50) OUTPUT,
@MSG2 nvarchar(50) OUTPUT,
--=====> input param. <=====
@objName nvarchar(50) 
AS
/*
	Revision 7.0, emmit @MSG1, @MSG2 checking
*/
--=====> create temp table to keep the informations of sp's parameters <=====
CREATE TABLE #tmpSPParam(
	SP_name    	nvarchar(50),
	SP_type    	nvarchar(20),
	SP_length  	smallint,
	SP_default 	nvarchar(50),
	SP_description	nvarchar(300),
	SP_enum	nvarchar(300),
	SP_mixed	nvarchar(300),
	SP_outparam 	bit,
	SP_nullable	bit
)
--=====> declare the inner parameters <=====
DECLARE @SPStr nvarchar(4000) 
DECLARE @tmpSPStr   nvarchar(2000) 
DECLARE @tmpSPStr2   nvarchar(2000)
DECLARE @flag_start smallint 
DECLARE @flag_end   smallint 
DECLARE @flag_len   smallint  
DECLARE @flag_default_start   smallint 
DECLARE @flag_default_end     smallint 
DECLARE @flag_default_len     smallint 
DECLARE @flag_description_start1   smallint 
DECLARE @flag_description_end1     smallint 
DECLARE @flag_description_len1     smallint 
DECLARE @flag_description_start2   smallint 
DECLARE @flag_description_end2     smallint 
DECLARE @flag_description_len2     smallint 
DECLARE @flag_enum_start   smallint 
DECLARE @flag_enum_end     smallint 
DECLARE @flag_enum_len     smallint 
DECLARE @SP_name    nvarchar(50) 
DECLARE @flag_mixed_start   smallint 
DECLARE @flag_mixed_end     smallint 
DECLARE @flag_mixed_len     smallint 
DECLARE @SP_type    nvarchar(20)
DECLARE @SP_length  smallint
DECLARE @SP_default nvarchar(50)
DECLARE @SP_description nvarchar(300)
DECLARE @SP_nullable bit 
DECLARE @SP_enum nvarchar(300) 
DECLARE @SP_mixed nvarchar(300)
DECLARE @ValNum	smallint
DECLARE @counter	smallint 
DECLARE @flag  	smallint
--=====> setting the inner parameters <=====
SET @tmpSPStr = ''

IF object_id(@objName)  is NULL 
BEGIN
	SET @MSG1='FAILURE'
	SET @MSG2='error occurs , because there is no such object in the database !!' 
	RETURN	
END
--=====> get the basic informations of sp's parameters <=====
INSERT INTO #tmpSPParam
    SELECT c.name, t.name, c.prec, '','','', c.isoutparam , 0, 0
    FROM syscolumns c,systypes t WHERE c.xtype=t.xusertype AND c.id = object_id(@objName) order by colid  

--=====> get the text of sp <=====
SELECT @SPStr=text FROM syscomments WHERE id = object_id(@objName)  AND colid =1 

/*
--=====> cut the region of sp's parameters <=====
SET @flag_start=CHARINDEX(UPPER(@objName),UPPER(@SPStr))+LEN(@objName)
SET @flag_end  =CHARINDEX(UPPER('AS'),UPPER(@SPStr))   
SET @flag_len  =@flag_end-@flag_start
SET @SPStr=SUBSTRING(@SPStr,@flag_start,@flag_len) 
*/
--=====> use cursor to get more information from sp's parameters by each parameter <=====
SELECT @ValNum=COUNT(*) FROM #tmpSPParam 
SET @counter = 0

DECLARE Cursor_param CURSOR FOR
    SELECT SP_name,SP_type,SP_length FROM #tmpSPParam
OPEN  Cursor_param
FETCH NEXT FROM Cursor_param
INTO @SP_name, @SP_type, @SP_length 
--=====> start the cursor <=====
WHILE @@FETCH_STATUS = 0
BEGIN
	--=====> restore the value <=====
	SET @SP_default	=''
	SET @SP_description	=''
	SET @SP_enum	=''
	SET @SP_mixed	=''
	SET @SP_nullable	=0
	SET @counter = @counter +1
	--=====> get the DEFAULT value of the sp's parameter <===== 
	SET @flag_start=1
	WHILE 1=1
	BEGIN 
		SET @flag_start=CHARINDEX(@SP_name+CHAR(9),@SPStr,1) 
		IF @flag_start =0
			SET @flag_start=CHARINDEX(@SP_name+'',@SPStr,1)	
		IF @flag_start<>0
			BREAK
	END
	SET @flag_start = @flag_start+LEN(@SP_name) 
	SET @flag_end  =CHARINDEX(CHAR(10),@SPStr,@flag_start)  
	SET @flag_len  =@flag_end-@flag_start                     
	SET @tmpSPStr = SUBSTRING(@SPStr,@flag_start,@flag_len) 
	SET @tmpSPStr2 = SUBSTRING(@SPStr,@flag_start,@flag_len) 
	SET @tmpSPStr2 = REPLACE(@tmpSPStr2,CHAR(9),'')
	SET @tmpSPStr2 = REPLACE(@tmpSPStr2,' ','')
	SET @flag_default_start =CHARINDEX('=',@tmpSPStr2) 
	IF @flag_default_start <> 0
	BEGIN

		SET @flag_default_end =CHARINDEX('--',@tmpSPStr2)-1 
		IF @flag_default_end=-1 AND @counter=@ValNum



			SET @flag_default_end =CHARINDEX(CHAR(10),@tmpSPStr2)-1 
		IF @flag_default_end=-1
			SET @flag_default_end =CHARINDEX(',',@tmpSPStr2)-1
		IF  @flag_default_end=-1
			SET @flag_default_end =LEN(@tmpSPStr2)
		SET @flag_default_len=@flag_default_end-@flag_default_start 
		SET @SP_default= SUBSTRING(@tmpSPStr2,@flag_default_start+1,@flag_default_len)
		IF UPPER(@SP_default)='NULL'
		BEGIN
			SET @SP_default = 'NULL'
			SET @SP_nullable=1
		END
	END
	ELSE
	BEGIN
		SELECT @SP_default=CASE @SP_type 
			WHEN 'bigint'	 	THEN '0'
			WHEN 'binary'	 	THEN '0'
			WHEN 'bit'	 	THEN '0'
			WHEN 'char' 		THEN ''
			WHEN 'datetime'	THEN '2050/01/01'
			WHEN 'decimal'		THEN '0'
			WHEN 'float'		THEN '0'
			WHEN 'image'		THEN '0'
			WHEN 'int'		THEN '0'
			WHEN 'money'		THEN '0'
			WHEN 'nchar' 		THEN ''	
			WHEN 'ntext'		THEN ''
			WHEN 'numeric' 	THEN '0'
			WHEN 'nvarchar' 	THEN ''
			WHEN 'real'	 	THEN '0'
			WHEN 'smalldatetime'	THEN '2050/01/01'
			WHEN 'smallint'		THEN '0'
			WHEN 'smallmoney'	THEN '0'
			WHEN 'sql_variant'	THEN NULL
			WHEN 'sysname'	THEN NULL
			WHEN 'text'		THEN ''
			WHEN 'timestamp'	THEN NULL
			WHEN 'tinyint'		THEN '0'
			WHEN 'uniqueidentifier'	THEN NULL
			WHEN 'varbinary'	THEN '0'
			WHEN 'varchar'		THEN '' 
			ELSE	''
		END
	END
	SET @SP_default = REPLACE(@SP_default,',','') 
	SET @SP_default = REPLACE(@SP_default,'''','') 


	IF @@ERROR >0
	BEGIN
		SET @MSG1='FAILURE'
		SET @MSG2='error occurs when getting DEFAULT value' 
		RETURN
	END
	--=====> get the DESCRIPTION value of the sp's parameter <=====
	SET @flag_description_start1=CHARINDEX('--',@tmpSPStr) +2
	IF @flag_description_start1 <> 2  
	BEGIN 
		SET @flag_enum_start = CHARINDEX('<ENUM>',UPPER(@tmpSPStr))+6  
		SET @flag_mixed_start = CHARINDEX('<MIXED>',UPPER(@tmpSPStr))+7 
		IF @flag_enum_start <> 6  
			BEGIN 		
			IF @flag_mixed_start <>7
			BEGIN
				SET @MSG1='FAILURE'
				SET @MSG2='<ENUM> and <MIXED> tag can''t declare at same time !!' 
				RETURN
			END
			SET @flag_enum_end = CHARINDEX('</ENUM>',UPPER(@tmpSPStr)) 
			IF @flag_enum_end =0
			BEGIN
				SET @MSG1='FAILURE'
				SET @MSG2='no end tag </ENUM>' 
				RETURN
			END
			SET @flag_enum_len = @flag_enum_end - @flag_enum_start 	
			SET @SP_enum = SUBSTRING(@tmpSPStr,@flag_enum_start,@flag_enum_len)		
			SET @flag_description_end1 =@flag_enum_start-7	
			IF @flag_description_end1>@flag_description_start1
 				SET @flag_description_len1  =@flag_description_end1 - @flag_description_start1
			ELSE
				SET @flag_description_len1 =0
			SET @flag_description_start2=@flag_enum_end+7
 			SET @flag_description_len2  =LEN(@tmpSPStr) - @flag_description_start2 
			SET @SP_description = SUBSTRING(@tmpSPStr,@flag_description_start1,@flag_description_len1)	+ ' ' +
						SUBSTRING(@tmpSPStr,@flag_description_start2,@flag_description_len2)	
			END
		ELSE
			BEGIN
			IF @flag_mixed_start <> 7
				BEGIN 		
				SET @flag_mixed_end = CHARINDEX('</MIXED>',UPPER(@tmpSPStr)) 
				IF @flag_mixed_end =0
				BEGIN
					SET @MSG1='FAILURE'
					SET @MSG2='no end tag </MIXED>' 
					RETURN
				END
				SET @flag_mixed_len = @flag_mixed_end - @flag_mixed_start 	
				SET @SP_mixed = SUBSTRING(@tmpSPStr,@flag_mixed_start,@flag_mixed_len)		
				SET @flag_description_end1 =@flag_mixed_start-8	
				IF @flag_description_end1>@flag_description_start1
	 				SET @flag_description_len1  =@flag_description_end1 - @flag_description_start1
				ELSE
					SET @flag_description_len1 =0
				SET @flag_description_start2=@flag_enum_end+8
	 			SET @flag_description_len2  =LEN(@tmpSPStr) - @flag_description_start2 
				SET @SP_description = SUBSTRING(@tmpSPStr,@flag_description_start1,@flag_description_len1)	+ ' ' +
							SUBSTRING(@tmpSPStr,@flag_description_start2,@flag_description_len2)	
				END
			ELSE
				BEGIN
				SET @flag_description_end1 = LEN(@tmpSPStr) 
				SET @flag_description_len1  =@flag_description_end1 - @flag_description_start1 
				SET @SP_description = SUBSTRING(@tmpSPStr,@flag_description_start1,@flag_description_len1)	
				END
		END
	END	
	IF @@ERROR >0
	BEGIN
		SET @MSG1='FAILURE'
		SET @MSG2='error occurs when getting DESCRIPTION value' 
		RETURN
	END

	UPDATE #tmpSPParam SET SP_default=@SP_default, SP_description=@SP_description, SP_enum=@SP_enum , SP_mixed=@SP_mixed , SP_nullable=@SP_nullable
	WHERE SP_name=@SP_name 
	IF @@ERROR >0
	BEGIN
		SET @MSG1='FAILURE'
		SET @MSG2='error occurs when update #tmpSPParam table' 
		RETURN
	END

	FETCH NEXT FROM Cursor_param
	INTO @SP_name, @SP_type, @SP_length 
END
--=====> kill cursor <=====
CLOSE Cursor_param
DEALLOCATE Cursor_param 

IF @@ERROR >0
BEGIN
	SET @MSG1='FAILURE'
	SET @MSG2='other unknown errors' 
	RETURN
END
ELSE
BEGIN
	-- 7.0 emmit @MSG1, @MSG2 checking.
	
	-- IF NOT EXISTS(select SP_name from #tmpSPParam where SP_name='@MSG1' ) AND
                 -- NOT EXISTS(select SP_name from #tmpSPParam where SP_name='@MSG2' )
	-- BEGIN
		-- SET @MSG1='FAILURE'
		-- SET @MSG2='there is no @MSG1 or @MSG2 !!' 
		-- RETURN	
	-- END
	-- ELSE
	BEGIN
		SET @MSG1='SUCCESS'
		SET @MSG2=''
		--=====> return the data list which are collected from sp's parameter <=====
		SELECT * FROM #tmpSPParam
		RETURN
	END
END
GO
USE [master]
GO
ALTER DATABASE [FileStore] SET  READ_WRITE 
GO
