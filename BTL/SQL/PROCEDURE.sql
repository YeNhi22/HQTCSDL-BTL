
------------------------------------------------------PROCEDURE--------------------------------------------------------------------------------------

--									| 1.hiển thị những hóa đơn có tổng giá trị lớn hơn 500,000. |	
CREATE PROCEDURE GetHighValueOrders 
    @MinValue FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        hd.SoHD,
        hd.NgayMua,
        SUM(cthd.SoLuong * t.DonGia) AS TotalValue
    FROM CHITIETHOADON cthd
    JOIN THUOC t ON cthd.MaThuoc = t.MaThuoc
    JOIN HOADON hd ON cthd.SoHD = hd.SoHD
    GROUP BY hd.SoHD, hd.NgayMua
    HAVING SUM(cthd.SoLuong * t.DonGia) > @MinValue;
END;
--Kết quả:
EXEC GetHighValueOrders @MinValue = 500000;


--												|2. Thêm một loại thuốc mới|
CREATE PROCEDURE AddNewMedicine
    @MaThuoc NVARCHAR(10),
    @TenThuoc NVARCHAR(100),
    @DonGia DECIMAL(10,2),
    @DVT NVARCHAR(10),
    @MaLoai NVARCHAR(10)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM THUOC WHERE MaThuoc = @MaThuoc)
    BEGIN
        RAISERROR('Mã thuốc đã tồn tại!', 16, 1);
        RETURN;
    END

    INSERT INTO THUOC (MaThuoc, TenThuoc, DonGia, DVT, MaLoai)
    VALUES (@MaThuoc, @TenThuoc, @DonGia, @DVT, @MaLoai);
END;
--Kết quả:
EXEC AddNewMedicine 'MT20', 'Paracetamol', 20000, 'Viên', 'ML02';
--Kiểm tra:
SELECT * FROM THUOC;


--												|3. Cập nhật giá thuốc|	
CREATE PROCEDURE UpdateMedicinePrice
    @MaThuoc NVARCHAR(10),
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    UPDATE THUOC
    SET DonGia = @NewPrice
    WHERE MaThuoc = @MaThuoc;
END;
--Kết quả:
EXEC UpdateMedicinePrice 'MT01', 18000;
--Kiểm tra 
SELECT * FROM THUOC;


--												|4. Xóa một thuốc khỏi danh sách|
CREATE PROCEDURE DeleteMedicine
    @MaThuoc NVARCHAR(10)
AS
BEGIN
    DELETE FROM THUOC
    WHERE MaThuoc = @MaThuoc;
END;
--Kết quả:
EXEC DeleteMedicine 'MT20';
--Kiểm tra:
SELECT * FROM THUOC; 


--										|5.Tính tổng doanh thu của một nhân viên|
CREATE PROCEDURE GetTotalRevenueByEmployee
    @MaNV NVARCHAR(10)
AS
BEGIN
    SELECT NV.MaNV, NV.TenNV, SUM(CTHD.SoLuong * T.DonGia) AS TotalRevenue
    FROM NHANVIEN NV
    JOIN HOADON HD ON NV.MaNV = HD.MaNV
    JOIN CHITIETHOADON CTHD ON HD.SoHD = CTHD.SoHD
    JOIN THUOC T ON CTHD.MaThuoc = T.MaThuoc
    WHERE NV.MaNV = @MaNV
    GROUP BY NV.MaNV, NV.TenNV;
END;
--Kết quả:
EXEC GetTotalRevenueByEmployee 'NV01';


--									|6. Tìm khách hàng có số đơn hàng nhiều nhất|
CREATE PROCEDURE GetTopCustomers
AS
BEGIN
    SELECT TOP 1 KH.MaKH, KH.TenKH, COUNT(HD.SoHD) AS OrderCount
    FROM KHACHHANG KH
    JOIN HOADON HD ON KH.MaKH = HD.MaKH
    GROUP BY KH.MaKH, KH.TenKH
    ORDER BY OrderCount DESC;
END;
--Kết quả:
EXEC GetTopCustomers;


--								|7. Kiểm tra số lượng tồn kho của một loại thuốc|
CREATE PROCEDURE GetStockQuantity
    @MaThuoc NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Tính tổng số lượng thuốc đã bán
    DECLARE @SoLuongBan INT;

    SELECT @SoLuongBan = COALESCE(SUM(SoLuong), 0)
    FROM CHITIETHOADON
    WHERE MaThuoc = @MaThuoc;

    -- Hiển thị kết quả
    SELECT 
        t.MaThuoc, 
        t.TenThuoc, 
        (100 - @SoLuongBan) AS SoLuongTon -- Giả sử nhập kho ban đầu là 100 đơn vị
    FROM THUOC t
    WHERE t.MaThuoc = @MaThuoc;
END;
--Kết quả:
EXEC GetStockQuantity @MaThuoc = 'MT01';

--											|8. Tính tổng giá trị đơn hàng theo ngày|
CREATE PROCEDURE GetTotalSalesByDate
    @Date DATE
AS
BEGIN
    SELECT SUM(CTHD.SoLuong * T.DonGia) AS TotalSales
    FROM HOADON HD
    JOIN CHITIETHOADON CTHD ON HD.SoHD = CTHD.SoHD
    JOIN THUOC T ON CTHD.MaThuoc = T.MaThuoc
    WHERE HD.NgayMua = @Date;
END;
--Kết quả:
EXEC GetTotalSalesByDate '2024-11-22';

--										|9. Hiển thị danh sách đơn hàng của một khách hàng|
CREATE PROCEDURE GetOrdersByCustomer
    @MaKH NVARCHAR(10)
AS
BEGIN
    SELECT HD.SoHD, HD.NgayMua, SUM(CTHD.SoLuong * T.DonGia) AS TotalValue
    FROM HOADON HD
    JOIN CHITIETHOADON CTHD ON HD.SoHD = CTHD.SoHD
    JOIN THUOC T ON CTHD.MaThuoc = T.MaThuoc
    WHERE HD.MaKH = @MaKH
    GROUP BY HD.SoHD, HD.NgayMua;
END;
--Kết quả:
EXEC GetOrdersByCustomer 'KH01';

--										|10. Thêm một hóa đơn mới|
CREATE PROCEDURE AddNewInvoice
    @SoHD NVARCHAR(10),
    @MaKH NVARCHAR(10),
    @NgayMua DATE,
    @MaThuoc NVARCHAR(10),
    @SoLuong INT,
	@TongTien INT,
	@MaNV VARCHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem mã hóa đơn đã tồn tại chưa
    IF EXISTS (SELECT 1 FROM HOADON WHERE SoHD = @SoHD)
    BEGIN
        PRINT N'Hóa đơn đã tồn tại!';
        RETURN;
    END

    -- Thêm hóa đơn mới
    INSERT INTO HOADON (SoHD, MaKH, NgayMua)
    VALUES (@SoHD, @MaKH, @NgayMua);

    -- Kiểm tra xem thuốc có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM THUOC WHERE MaThuoc = @MaThuoc)
    BEGIN
        PRINT N'Mã thuốc không tồn tại!';
        RETURN;
    END

    -- Thêm chi tiết hóa đơn
    INSERT INTO CHITIETHOADON (SoHD, MaThuoc, SoLuong)
    VALUES (@SoHD, @MaThuoc, @SoLuong);

    PRINT N'Hóa đơn đã được thêm thành công!';
END;
--Kết quả:
EXEC AddNewInvoice 
    @SoHD = '17', 
    @MaKH = 'KH12', 
    @NgayMua = '2024-03-02',
    @MaThuoc = 'MT12',
    @SoLuong = 7,
	@TongTien = 156000,
	@MaNV = 'NV12';

	SELECT * FROM HOADON;
SELECT * FROM CHITIETHOADON;

DROP PROCEDURE AddNewInvoice;

