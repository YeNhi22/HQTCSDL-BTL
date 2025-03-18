
---------------------------------------------------------------TRIGGER-------------------------------------------------------------------------------

--										|1. Kiểm tra giá thuốc không âm khi thêm vào |
CREATE TRIGGER trg_Check_DonGia_Thuoc
ON THUOC
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE DonGia < 0)
    BEGIN
        PRINT N'Lỗi: giá thuốc không được âm.'
        ROLLBACK TRANSACTION
    END
END
GO
--Kiểm tra:
INSERT INTO THUOC (MaThuoc, TenThuoc, DonGia, DVT, MaLoai)  
VALUES ('T002', 'Thuốc B', -10000, 'Vỉ', 'ML02'); 

--									|2. Tự đọng cập nhật tổng tiền trong hóa đơn khi có thay đổi trong chi tiết hóa đơn|
CREATE TRIGGER trg_Update_TongTien_HoaDon
ON CHITIETHOADON
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE HOADON
    SET TongTien = (
        SELECT SUM(ct.SoLuong * t.DonGia) 
        FROM CHITIETHOADON ct 
        JOIN THUOC t ON ct.MaThuoc = t.MaThuoc
        WHERE ct.SoHD = HOADON.SoHD
    )
    WHERE SoHD IN (SELECT SoHD FROM inserted UNION SELECT SoHD FROM deleted)
END
GO
--Kết quả:
SELECT * FROM HOADON WHERE SoHD = '01';



--									|3. Kiểm tra số lượng thuốc trong chi tiết hóa đơn không được nhỏ hơn 1|
CREATE TRIGGER Check_SoLuong_Thuoc
ON CHITIETHOADON
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE SoLuong < 1)
    BEGIN
        PRINT N'Lỗi: Số lượng thuốc phải lớn hơn 0!';
        ROLLBACK TRANSACTION;
    END
END;
GO
--Kiểm tra:
INSERT INTO CHITIETHOADON (SoHD, MaThuoc, SoLuong) VALUES ('01', 'MT01', 0);


--										|4. Không cho phép xóa nhân viên nếu có hóa đơn liên quan|
CREATE TRIGGER trg_Prevent_Delete_NhanVien
ON NHANVIEN
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted d JOIN HOADON h ON d.MaNV = h.MaNV)
    BEGIN
        PRINT N'Lỗi: Không thể xóa nhân viên đã lập hóa đơn.'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        DELETE FROM NHANVIEN WHERE MaNV IN (SELECT MaNV FROM deleted)
    END
END
GO
--Kết quả:
DELETE FROM NHANVIEN WHERE MaNV = 'NV10'; 

--													| 5. Kiểm tra số lượng tồn kho|
CREATE PROCEDURE sp_TraCuuThongTinThuoc 
@MaThuoc NVARCHAR(10)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM THUOC WHERE MaThuoc = @MaThuoc)
    BEGIN
        SELECT MaThuoc, TenThuoc, DonGia
        FROM THUOC
        WHERE MaThuoc = @MaThuoc;
    END
    ELSE
    BEGIN
        PRINT N'Thuốc có mã ' + @MaThuoc + N' không tồn tại trong hệ thống.';
    END
END
GO
--Kiểm tra:
EXEC sp_TraCuuThongTinThuoc @MaThuoc = 'MT17';

--												| 6. Không cho phép thêm hóa đơn với tổng tiền là NULL|
CREATE TRIGGER trg_Check_TongTien_HoaDon
ON HOADON
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE TongTien IS NULL)
    BEGIN
        PRINT N'Lỗi: Tổng tiền không thể để trống.'
        ROLLBACK TRANSACTION
    END
END
GO
--Kết quả:
INSERT INTO HOADON (SoHD, NgayMua, MaKH, MaNV, TongTien)
VALUES ('HD01', '2025-03-03', 'KH01', 'NV01', NULL);


--												|7. Kiểm tra số điện thoại hợp lí khi thêm khách hàng|
CREATE TRIGGER trg_Check_SDT_KhachHang
ON KHACHHANG
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE DienThoai NOT LIKE '[0-9]%' OR LEN(DienThoai) < 10 OR LEN(DienThoai) > 11)
    BEGIN
        PRINT N'Lỗi: Số điện thoại không hợp lệ. Phải chứa 10-11 chữ số và bắt đầu bằng số.'
        ROLLBACK TRANSACTION
    END
END
GO
--Kiểm tra:
INSERT INTO KHACHHANG (MaKH, TenKH, DienThoai, DiaChi)
VALUES ('KH19', N'Nguyễn Văn A', 'A787654342', N'Hà Nội');

SELECT*FROM KHACHHANG;


--													| 8. Không cho phép sửa mã hóa đơn |
CREATE TRIGGER trg_Prevent_Update_MaHD
ON HOADON
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted i JOIN deleted d ON i.SoHD <> d.SoHD)
    BEGIN
        PRINT N'Lỗi: Không thể thay đổi mã hóa đơn.'
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        UPDATE HOADON
        SET NgayMua = i.NgayMua, TongTien = i.TongTien, MaKH = i.MaKH, MaNV = i.MaNV
        FROM HOADON h
        INNER JOIN inserted i ON h.SoHD = i.SoHD
    END
END
GO
--Kiểm tra:
UPDATE HOADON 
SET SoHD = '999' 
WHERE SoHD = '01';


--												|9. Tự động xóa chi tiết hóa đơn khi xóa hóa đơn |
CREATE TRIGGER trg_Delete_CTHD_When_Delete_HD
ON HOADON
AFTER DELETE
AS
BEGIN
    DELETE FROM CHITIETHOADON WHERE SoHD IN (SELECT SoHD FROM deleted)
END
GO
--Thêm ràng buộc ON DELETE CASCADE
ALTER TABLE CHITIETHOADON 
ADD CONSTRAINT FK_CHITIETHOADON_HOADON 
FOREIGN KEY (SoHD) REFERENCES HOADON(SoHD) ON DELETE CASCADE;s
--Kiểm tra:
DELETE FROM HOADON WHERE SoHD = '17';
--Kết quả:
SELECT * FROM CHITIETHOADON WHERE SoHD = '17';


--										|10. Không cho phép xóa loại thuốc nếu còn thuốc thuộc loại đó|
CREATE TRIGGER trg_Prevent_Delete_LoaiThuoc
ON LOAITHUOC
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted d JOIN THUOC t ON d.MaLoai = t.MaLoai)
    BEGIN
		PRINT (N'Lỗi: Không thể xóa loại thuốc nếu còn thuốc thuộc loại đó')
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        DELETE FROM LOAITHUOC WHERE MaLoai IN (SELECT MaLoai FROM deleted)
    END
END
GO
--Kiểm tra:
DELETE FROM LOAITHUOC WHERE MaLoai = 'ML01';
