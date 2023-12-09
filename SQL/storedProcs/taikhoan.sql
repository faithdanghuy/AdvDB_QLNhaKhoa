﻿/* 21HTTT1 - 21CLC1.CSDLNC.03
 * 21127004 - Trần Nguyễn An Phong
 * 21127135 - Diệp Hữu Phúc
 * 21127296 - Đặng Hà Huy
 * 21127315 - Nguyễn Gia Khánh
 * 21127712 - Lê Quang Trường
 */
USE [NC03_QLNhaKhoa]
GO

CREATE OR ALTER PROC USP_TAIKHOAN_INS
    @TENDANGNHAP NVARCHAR(25),
    @MATKHAU VARCHAR(20),
    @LOAITAIKHOAN INT, -- 0: NHANVIEN, 1: NHASI, 2: QUANTRIVIEN
    @HOTEN NVARCHAR(100),
    @NGAYSINH DATE,
    @GIOITINH INT, -- 0: NAM, 1: NỮ
    @EMAIL VARCHAR(30),
    @SDT VARCHAR(11),
    @DIACHI NVARCHAR(200),
    @IDTAIKHOAN CHAR(7) = NULL OUTPUT
AS BEGIN TRAN
    IF EXISTS (SELECT TENDANGNHAP FROM TAIKHOAN
        WHERE LOAITAIKHOAN = @LOAITAIKHOAN
            AND TENDANGNHAP = @TENDANGNHAP) BEGIN
        RAISERROR('INVALID TENDANGNHAP', 16, 1)
        ROLLBACK TRAN
        RETURN -1
    END

    DECLARE @TYPE CHAR(2)
    IF (@LOAITAIKHOAN = 0) SET @TYPE = 'NV'
    ELSE IF (@LOAITAIKHOAN = 1) SET @TYPE = 'NS'
    ELSE IF (@LOAITAIKHOAN = 2) SET @TYPE = 'AD'
    ELSE BEGIN
        RAISERROR('INVALID LOAITAIKHOAN', 16, 1)
        ROLLBACK TRAN
        RETURN -1
    END

    SELECT @IDTAIKHOAN = IDTAIKHOAN FROM TAIKHOAN
    WHERE IDTAIKHOAN = (SELECT MAX(IDTAIKHOAN) FROM TAIKHOAN
        WHERE IDTAIKHOAN LIKE @TYPE + '%')

    SET @IDTAIKHOAN = dbo.F_MAKE_ID(@TYPE, @IDTAIKHOAN)

    INSERT INTO TAIKHOAN
    VALUES (@IDTAIKHOAN, @TENDANGNHAP, @MATKHAU, @LOAITAIKHOAN,
        @HOTEN, @NGAYSINH, @GIOITINH, @EMAIL, @SDT, @DIACHI)
COMMIT TRAN
RETURN 0
GO

CREATE OR ALTER PROC USP_TAIKHOAN_UPD
    @IDTAIKHOAN CHAR(7),
    @TENDANGNHAP NVARCHAR(25),
    @MATKHAU VARCHAR(20),
    @LOAITAIKHOAN INT, -- 0: NHANVIEN, 1: NHASI, 2: QUANTRIVIEN
    @HOTEN NVARCHAR(100),
    @NGAYSINH DATE,
    @GIOITINH INT, -- 0: NAM, 1: NỮ
    @EMAIL VARCHAR(30),
    @SDT VARCHAR(11),
    @DIACHI NVARCHAR(200)
AS BEGIN TRAN
    IF NOT EXISTS (SELECT IDTAIKHOAN FROM TAIKHOAN
        WHERE IDTAIKHOAN = @IDTAIKHOAN) BEGIN
        RAISERROR('INVALID IDTAIKHOAN', 16, 1)
        ROLLBACK TRAN
        RETURN -1
    END

    IF @LOAITAIKHOAN != 0 AND @LOAITAIKHOAN != 1 AND @LOAITAIKHOAN != 2 BEGIN
        RAISERROR('INVALID LOAITAIKHOAN', 16, 1)
        ROLLBACK TRAN
        RETURN -2
    END

    IF @GIOITINH != 0 AND @GIOITINH != 1 BEGIN
        RAISERROR('INVALID GIOITINH', 16, 1)
        ROLLBACK TRAN
        RETURN -3
    END

    IF @TENDANGNHAP IS NULL OR @MATKHAU IS NULL OR @HOTEN IS NULL
        OR @NGAYSINH IS NULL OR @EMAIL IS NULL OR @SDT IS NULL
        OR @DIACHI IS NULL BEGIN
        RAISERROR('INVALID DATA', 16, 1)
        ROLLBACK TRAN
        RETURN -4
    END

    UPDATE TAIKHOAN SET TENDANGNHAP = @TENDANGNHAP, MATKHAU = @MATKHAU,
        LOAITAIKHOAN = @LOAITAIKHOAN, HOTEN = @HOTEN, NGAYSINH = @NGAYSINH,
        GIOITINH = @GIOITINH, EMAIL = @EMAIL, SDT = @SDT, DIACHI = @DIACHI
    WHERE IDTAIKHOAN = @IDTAIKHOAN
COMMIT TRAN
RETURN 0
GO