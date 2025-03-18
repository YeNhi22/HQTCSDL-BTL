


---------------------------------------------------------XÂY DỰNG CÁC VIEW-------------------------------------------------------------------

--										| 1. Tạo view hiển thị doanh thu theo từng khách hàng |
CREATE VIEW DoanhThuKhachHang AS 
SELECT 
    kh.MaKH,
    kh.TenKH,
    SUM(cthd.SoLuong * cthd.SoHD) AS DoanhThu
FROM KHACHHANG kh
JOIN HOADON hd ON kh.MaKH = hd.MaKH
JOIN CHITIETHOADON cthd ON hd.SoHD = cthd.SoHD
GROUP BY kh.MaKH, kh.TenKH;
--Kiểm tra kết quả:
SELECT * FROM DoanhThuKhachHang;

--										| 2. Tạo view hiển thị sản phẩm bán chạy nhất |
CREATE VIEW BestSellingProduct AS
SELECT TOP 1
    t.MaThuoc,
    t.TenThuoc,
    SUM(cthd.SoLuong) AS TotalSold
FROM CHITIETHOADON cthd
JOIN THUOC t ON cthd.MaThuoc = t.MaThuoc
GROUP BY t.MaThuoc, t.TenThuoc
ORDER BY TotalSold DESC;
--Kết quả:
SELECT * FROM BestSellingProduct;





--										|3. Tạo view hiển thị hiệu suất của nhân viên |
CREATE VIEW EmployeePerformance AS
SELECT 
    nv.MaNV,
    nv.TenNV,
    COUNT(hd.SoHD) AS SoHoaDon,
    SUM(hd.TongTien) AS TongDoanhThu
FROM NHANVIEN nv
LEFT JOIN HOADON hd ON nv.MaNV = hd.MaNV
GROUP BY nv.MaNV, nv.TenNV;
--Kết quả:
SELECT * FROM EmployeePerformance ORDER BY TongDoanhThu DESC;

--										|4. Tạo view hiển thị hóa đơn có tổng giá trị cao nhất |
CREATE VIEW HighestValueOrder AS
SELECT TOP 1
    hd.SoHD, 
    hd.NgayMua, 
    SUM(cthd.SoLuong * t.DonGia) AS TotalValue
FROM CHITIETHOADON cthd
JOIN THUOC t ON cthd.MaThuoc = t.MaThuoc
JOIN HOADON hd ON cthd.SoHD = hd.SoHD
GROUP BY hd.SoHD, hd.NgayMua
ORDER BY TotalValue DESC;
--Kết quả:
SELECT * FROM HighestValueOrder;



--									|5. Tạo view hiển thị số lượng sản phẩm trung bình được bán trong mỗi đơn hàng. |
CREATE VIEW AverageOrderQuantity AS
SELECT SoHD, AVG(SoLuong) AS AvgQuantityPerOrder
FROM CHITIETHOADON
GROUP BY SoHD;
--Kết quả:
SELECT * FROM AverageOrderQuantity;

--									|6. Tạo view hiển thị số lượng sản phẩm bán được theo từng loại |
CREATE VIEW CategorySales AS
SELECT l.MaLoai, l.TenLoai, SUM(cthd.SoLuong) AS TotalQuantitySold
FROM LOAITHUOC l
JOIN THUOC t ON l.MaLoai = t.MaLoai
JOIN CHITIETHOADON cthd ON t.MaThuoc = cthd.MaThuoc
GROUP BY l.MaLoai, l.TenLoai;
--Kết quả:
SELECT * FROM CategorySales;

--									|7. Tạo view hiển thị tổng số lượng sản phẩm bán được của từng nhân viên |
CREATE VIEW EmployeeProductSales AS
SELECT nv.MaNV, nv.TenNV, SUM(cthd.SoLuong) AS TotalProductsSold
FROM NHANVIEN nv
JOIN HOADON hd ON nv.MaNV = hd.MaNV
JOIN CHITIETHOADON cthd ON hd.SoHD = cthd.SoHD
GROUP BY nv.MaNV, nv.TenNV;
--Kết quả:
SELECT * FROM EmployeeProductSales;

--									|8. Tạo view hiển thị số lần mua hàng của từng khách hàng |
CREATE VIEW CustomerPurchaseFrequency AS
SELECT kh.MaKH, kh.TenKH, COUNT(hd.SoHD) AS PurchaseCount
FROM KHACHHANG kh
JOIN HOADON hd ON kh.MaKH = hd.MaKH
GROUP BY kh.MaKH, kh.TenKH;
--Kết quả: 
SELECT * FROM CustomerPurchaseFrequency;

--									|9. Tạo view hiển thị khách hàng chi tiêu nhiều nhất |
CREATE VIEW TopSpendingCustomers AS
SELECT kh.MaKH, kh.TenKH, SUM(cthd.SoLuong * t.DonGia) AS TotalSpent
FROM KHACHHANG kh
JOIN HOADON hd ON kh.MaKH = hd.MaKH
JOIN CHITIETHOADON cthd ON hd.SoHD = cthd.SoHD
JOIN THUOC t ON cthd.MaThuoc = t.MaThuoc
GROUP BY kh.MaKH, kh.TenKH;
--Kết quả:
SELECT * FROM TopSpendingCustomers ORDER BY TotalSpent DESC;

--									|10. Tạo view hiển thị danh sách nhân viên và số đơn hàng họ đã xử lý|
CREATE VIEW EmployeeOrderCount AS
SELECT NV.MaNV, NV.TenNV, COUNT(HD.SoHD) AS TotalOrdersHandled
FROM NHANVIEN NV
LEFT JOIN HOADON HD ON NV.MaNV = HD.MaNV
GROUP BY NV.MaNV, NV.TenNV;
--Kết quả:
SELECT * FROM EmployeeOrderCount;















