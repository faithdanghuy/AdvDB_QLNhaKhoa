﻿/* 21HTTT1 - 21CLC1.CSDLNC.03
 * 21127004 - Trần Nguyễn An Phong
 * 21127135 - Diệp Hữu Phúc
 * 21127296 - Đặng Hà Huy
 * 21127315 - Nguyễn Gia Khánh
 * 21127712 - Lê Quang Trường
 */
USE [NC03_QLNhaKhoa]
GO

CREATE OR ALTER PROC USP_LICHHEN_INS
    @IDHOSO VARCHAR(5),
    @NGAY DATE,
    @GIO INT,
    @TINHTRANG INT,
    @GHICHU NVARCHAR(100),
    @IDPHONGKHAM VARCHAR(5),
    @IDNHASI VARCHAR(5),
    @IDTROKHAM VARCHAR(5) = NULL,
    @IDNHANVIENDAT VARCHAR(5) = NULL,
    @IDLICHHEN VARCHAR(5) = NULL OUTPUT
AS BEGIN TRAN
    IF NOT EXISTS (SELECT * FROM HOSOBENHNHAN
        WHERE IDHOSO = @IDHOSO) BEGIN
        RAISERROR('INVALID IDHOSO', 16, 1)
        ROLLBACK TRAN
        RETURN -1
    END

    IF NOT EXISTS (SELECT * FROM PHONGKHAM WHERE IDPHONGKHAM = @IDPHONGKHAM
        AND GIOMOCUA <= @GIO AND GIO <= GIODONGCUA) BEGIN
        RAISERROR('INVALID GIO FOR INPUTTED PHONGKHAM, OR INVALID PHONGKHAM', 16, 1)
        ROLLBACK TRAN
        RETURN -2
    END

    IF @TINHTRANG != 0 AND @TINHTRANG != 1 BEGIN
        RAISERROR('INVALID TINHTRANG', 16, 1)
        ROLLBACK TRAN
        RETURN -3
    END

    IF NOT EXISTS (SELECT * FROM TAIKHOAN WHERE IDTAIKHOAN = @IDNHASI) BEGIN
        RAISERROR('INVALID IDNHASI', 16, 1)
        ROLLBACK TRAN
        RETURN -4
    END

    IF dbo.F_CHK_NHASI_FREE(@IDNHASI, @NGAY, @GIO) = 0 BEGIN
        RAISERROR('NHASI IS NOT AVAILABLE AS SAID NGAY AND GIO', 16, 1)
        ROLLBACK TRAN
        RETURN -5
    END
    
    IF @IDTROKHAM IS NOT NULL AND NOT EXISTS
        (SELECT * FROM TAIKHOAN WHERE IDTAIKHOAN = @IDTROKHAM) BEGIN
        RAISERROR('INVALID IDTROKHAM', 16, 1)
        ROLLBACK TRAN
        RETURN -6
    END

    IF @IDNHANVIENDAT IS NOT NULL AND NOT EXISTS
        (SELECT * FROM TAIKHOAN WHERE IDTAIKHOAN = @IDNHANVIENDAT) BEGIN
        RAISERROR('INVALID IDNHANVIENDAT', 16, 1)
        ROLLBACK TRAN
        RETURN -7
    END

    SELECT @IDLICHHEN = IDLICHHEN FROM LICHHEN
    WHERE IDLICHHEN = (SELECT MAX(IDLICHHEN) FROM LICHHEN
        WHERE IDHOSO = @IDHOSO)

    SET @IDLICHHEN = dbo.F_MAKE_ID('LH', @IDLICHHEN)

    INSERT INTO LICHHEN
    VALUES (@IDHOSO, @IDLICHHEN, @NGAY, @GIO, @TINHTRANG, @GHICHU,
        @IDPHONGKHAM, @IDNHASI, @IDTROKHAM, @IDNHANVIENDAT)
COMMIT TRAN
GO