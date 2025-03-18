--------------------------------------------- TẠO TÀI KHOẢN ĐĂNG NHẬP----------------------------------------------------------------------------

-- Tạo LOGIN và USER cho QuanLy
CREATE LOGIN QuanLy WITH PASSWORD = 'QuanLy@123';
CREATE USER QuanLy FOR LOGIN QuanLy;

-- Tạo LOGIN và USER cho NhanVien
CREATE LOGIN NhanVien WITH PASSWORD = 'NhanVien@123';
CREATE USER NhanVien FOR LOGIN NhanVien;

-- Tạo LOGIN và USER cho KhachHang
CREATE LOGIN KhachHang WITH PASSWORD = 'KhachHang@123';
CREATE USER KhachHang FOR LOGIN KhachHang;

----------------------------------------------TẠO CÁC ROLE VÀ GÁN QUYỀN-----------------------------------------------------------------------------------------
-- Tạo role quản lý
--Kiểm tra và xóa ROLE QuanLy nếu đã tồn tại
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'QuanLyRole')
    DROP ROLE QuanLyRole;

CREATE ROLE QuanLyRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.[HOADON] TO QuanLyRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.[CHITIETHOADON] TO QuanLyRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.[THUOC] TO QuanLyRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.[LOAITHUOC] TO QuanLyRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.[KHACHHANG] TO QuanLyRole;

ALTER ROLE QuanLyRole ADD MEMBER QuanLy;

-- Tạo role nhân viên
--Kiểm tra và xóa ROLE NhanVien nếu đã tồn tại
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'NhanVienRole')
    DROP ROLE NhanVienRole;

CREATE ROLE NhanVienRole;
GRANT SELECT, INSERT, UPDATE ON dbo.[HOADON] TO NhanVienRole;
GRANT SELECT, INSERT, UPDATE ON dbo.[CHITIETHOADON] TO NhanVienRole;
GRANT SELECT ON dbo.[THUOC] TO NhanVienRole;
GRANT SELECT ON dbo.[KHACHHANG] TO NhanVienRole;

ALTER ROLE NhanVienRole ADD MEMBER NhanVien;

-- Tạo role khách hàng
--Kiểm tra và xóa ROLE KhachHang nếu đã tồn tại
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'KhachHangRole')
    DROP ROLE KhachHangRole;

CREATE ROLE KhachHangRole;
GRANT SELECT ON dbo.[THUOC] TO KhachHangRole;
GRANT SELECT ON dbo.[LOAITHUOC] TO KhachHangRole;
GRANT SELECT ON dbo.[KHACHHANG] TO KhachHangRole;

ALTER ROLE KhachHangRole ADD MEMBER KhachHang;

---------------------------------------------------------KIỂM TRA QUYỀN-------------------------------------------------------------------------------------------------

---------------------------------------ĐĂNG NHẬP BẰNG TÀI KHOẢN QUẢN LÝ VÀ KIỂM TRA QUYỀN---------------------------------------------------------------------------
EXECUTE AS USER = 'QuanLy';
--Tthêm một loại thuốc mới (thành công)
INSERT INTO LOAITHUOC (MaLoai, TenLoai) VALUES ('ML20', N'Thuốc Tiêu Hóa');

SELECT*FROM LOAITHUOC;
--Xóa một loại thuốc (thành công)
BEGIN TRY
    DELETE FROM LOAITHUOC WHERE MaLoai = 'ML20';
    PRINT N'Xóa thành công!';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
-- Trả lại quyền người dùng ban đầu
REVERT;

-----------------------------------------ĐĂNG NHẬP BẰNG TÀI KHOẢN NHÂN VIÊN VÀ KIỂM TRA QUYỀN-----------------------------------------------------------------
EXECUTE AS USER = 'NhanVien';
--Thêm một hóa đơn mới (thành công)
INSERT INTO HOADON (SoHD, NgayMua, TongTien, MaKH, MaNV) 
VALUES ('18', GETDATE(), 100000, 'KH01', 'NV01');

SELECT*FROM HOADON;
--Xóa một hóa đơn (sẽ bị từ chối)
BEGIN TRY
    DELETE FROM HOADON WHERE SoHD = '18';
    PRINT N'Xóa thành công!';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
-- Trả lại quyền người dùng ban đầu
REVERT;

--------------------------------------ĐĂNG NHẬP BẰNG TÀI KHOẢN KHÁCH HÀNG VÀ KIỂM TRA QUYỀN-----------------------------------------------------
EXECUTE AS USER = 'KhachHang';
--Xem thông tin thuốc (thành công)
SELECT * FROM THUOC;
--Thêm thông tin khách hàng (sẽ bị từ chối)
BEGIN TRY
    INSERT INTO KHACHHANG (MaKH, TenKH, DiaChi, DienThoai) 
    VALUES ('KH19', N'Nguyễn Văn A', N'Hà Nội', '0901234567');
    PRINT N'Thêm thành công!';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
--Xóa thông tin khách hàng (sẽ bị từ chối)
BEGIN TRY
    DELETE FROM KHACHHANG WHERE MaKH = 'KH11';
    PRINT N'Xóa thành công!';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
-- Trả lại quyền người dùng ban đầu
REVERT;

-----------------------------------------------------XÓA TÀI KHOẢN VÀ ROLE NẾU CẦN-----------------------------------------------------------------------
-- Xóa người dùng khỏi role
ALTER ROLE QuanLy DROP MEMBER QuanLy;
ALTER ROLE NhanVien DROP MEMBER NhanVien;
ALTER ROLE KhachHang DROP MEMBER KhachHang;

-- Xóa role
DROP ROLE QuanLy;
DROP ROLE NhanVien;
DROP ROLE KhachHang;

-- Xóa user trong database
DROP USER QuanLy;
DROP USER NhanVien;
DROP USER KhachHang;

-- Xóa login trên SQL Server
DROP LOGIN QuanLy;
DROP LOGIN NhanVien;
DROP LOGIN KhachHang;

SELECT name FROM sys.server_principals WHERE type IN ('S', 'U', 'G');
