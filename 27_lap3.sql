use QLDA;
/* 1. Với mỗi đề án, liệt kê tên đề án và tổng số giờ làm việc một tuần của tất cả các nhân viên 
tham dự đề án đó. 
o Xuất định dạng “tổng số giờ làm việc” kiểu decimal với 2 số thập phân.
o Xuất định dạng “tổng số giờ làm việc” kiểu varchar
➢ Với mỗi phòng ban, liệt kê tên phòng ban và lương trung bình của những nhân viên làm 
việc cho phòng ban đó.
o Xuất định dạng “luong trung bình” kiểu decimal với 2 số thập phân, sử dụng dấu 
phẩy để phân biệt phần nguyên và phần thập phân.
o Xuất định dạng “luong trung bình” kiểu varchar. Sử dụng dấu phẩy tách cứ mỗi 3 
chữ số trong chuỗi ra, gợi ý dùng thêm các hàm Left, Replace*/

SELECT PHANCONG.MADA, TENDEAN , cast(SUM(THOIGIAN) as decimal(18,2)) as 'Tong so gio',
								convert(varchar, SUM(THOIGIAN)) as 'Tong so gio'
from PHANCONG
join DEAN on DEAN.MADA = PHANCONG.MADA
join CONGVIEC ON CONGVIEC.MADA = DEAN.MADA
group by PHANCONG.MADA, TENDEAN;

SELECT TENPHG, replace(CAST(AVG(LUONG) AS DECIMAL(18,2)), '.', ',') AS 'Luong TB'
FROM NHANVIEN
JOIN PHONGBAN ON PHONGBAN.MAPHG = NHANVIEN.PHG
GROUP BY TENPHG;

SELECT TENPHG, REPLACE(LEFT(CAST(AVG(LUONG) AS VARCHAR), LEN(CAST(AVG(LUONG) AS VARCHAR))), '.', ',' ) AS 'Luong TB'
FROM NHANVIEN
JOIN PHONGBAN ON PHONGBAN.MAPHG = NHANVIEN.PHG
GROUP BY TENPHG;

/* 2. Với mỗi đề án, liệt kê tên đề án và tổng số giờ làm việc một tuần của tất cả các nhân viên 
tham dự đề án đó.
o Xuất định dạng “tổng số giờ làm việc” với hàm CEILING
o Xuất định dạng “tổng số giờ làm việc” với hàm FLOOR
o Xuất định dạng “tổng số giờ làm việc” làm tròn tới 2 chữ số thập phân
➢ Cho biết họ tên nhân viên (HONV, TENLOT, TENNV) có mức lương trên mức lương 
trung bình (làm tròn đến 2 số thập phân) của phòng "Nghiên cứu"*/
select TENDEAN, ceiling(sum(THOIGIAN)) as 'Tong so gio lam viec',
				floor(sum(THOIGIAN)) as 'Tong so gio lam viec',
				round(sum(THOIGIAN),2) as 'Tong so gio lam viec'
from DEAN
join PHANCONG on PHANCONG.MADA = DEAN.MADA
join CONGVIEC ON CONGVIEC.MADA = DEAN.MADA
group by TENDEAN;

select HONV+' '+TENLOT+' '+TENNV AS 'HO VÀ TÊN'
FROM NHANVIEN
JOIN PHONGBAN ON PHONGBAN.MAPHG = NHANVIEN.PHG
WHERE Luong > (SELECT round(AVG(Luong),2) FROM NHANVIEN ) AND TENPHG LIKE N'Nghiên Cứu';

/* 3. Danh sách những nhân viên (HONV, TENLOT, TENNV, DCHI) có trên 2 thân nhân, 
thỏa các yêu cầu
o Dữ liệu cột HONV được viết in hoa toàn bộ
o Dữ liệu cột TENLOT được viết chữ thường toàn bộ
o Dữ liệu chột TENNV có ký tự thứ 2 được viết in hoa, các ký tự còn lại viết 
thường( ví dụ: kHanh)
o Dữ liệu cột DCHI chỉ hiển thị phần tên đường, không hiển thị các thông tin khác 
như số nhà hay thành phố.
➢ Cho biết tên phòng ban và họ tên trưởng phòng của phòng ban có đông nhân viên nhất, 
hiển thị thêm một cột thay thế tên trưởng phòng bằng tên “Fpoly”*/

SELECT UPPER(NHANVIEN.HONV) ,
       LOWER(NHANVIEN.TENLOT) ,
       LOWER(LEFT(NHANVIEN.TENNV, 1)) + UPPER(SUBSTRING(NHANVIEN.TENNV, 2, 1)) + LOWER(SUBSTRING(NHANVIEN.TENNV, 3, LEN(NHANVIEN.TENNV) - 2)) ,
       SUBSTRING(NHANVIEN.DCHI, CHARINDEX(' ', NHANVIEN.DCHI) + 1, CHARINDEX(',', NHANVIEN.DCHI) - CHARINDEX(' ', NHANVIEN.DCHI) - 1) AS TenDuong
FROM NHANVIEN
JOIN THANNHAN ON NHANVIEN.MANV = THANNHAN.MA_NVIEN
GROUP BY NHANVIEN.HONV, NHANVIEN.TENLOT, NHANVIEN.DCHI, NHANVIEN.TENNV
HAVING COUNT(THANNHAN.MA_NVIEN) >= 2;

select Top 1 with ties NHANVIEN.PHG, PHONGBAN.TENPHG, PHONGBAN.TRPHG, NV.TENNV,
						REPLACE(NV.TENNV, NV.TENNV, 'FPOLY') AS 'TEN THAY THE',
						COUNT(NHANVIEN.MANV) as 'SO LUONG NV'
						FROM NHANVIEN
						JOIN PHONGBAN ON PHONGBAN.MAPHG = NHANVIEN.PHG
						JOIN NHANVIEN NV ON NV.MANV = PHONGBAN.TRPHG
						GROUP BY NHANVIEN.PHG, PHONGBAN.TENPHG, PHONGBAN.TRPHG, NV.TENNV
						ORDER BY COUNT(NHANVIEN.MANV) DESC;

/* 4. Sử dụng các hàm ngày tháng năm
➢ Cho biết các nhân viên có năm sinh trong khoảng 1960 đến 1965.
➢ Cho biết tuổi của các nhân viên tính đến thời điểm hiện tại.
➢ Dựa vào dữ liệu NGSINH, cho biết nhân viên sinh vào thứ mấy.
➢ Cho biết số lượng nhân viên, tên trưởng phòng, ngày nhận chức trưởng phòng và ngày 
nhận chức trưởng phòng hiển thi theo định dạng dd-mm-yy (ví dụ 25-04-2019)*/

SELECT *
FROM NhanVien
WHERE YEAR(NGSINH) BETWEEN 1960 AND 1965;

select *, YEAR(GETDATE()) - YEAR(NGSINH) AS 'Tuoi NV'
from NHANVIEN

SELECT NGSINH, DATENAME(WEEKDAY, NGSINH) AS 'Thu'
FROM NHANVIEN

SELECT PHONGBAN.TRPHG, NV.TENNV, 
    COUNT(NHANVIEN.MANV) AS 'SO LUONG NV',
    CONVERT(varchar, PHONGBAN.NG_NHANCHUC, 105) AS 'NGAY NHAN CHUC'
FROM NHANVIEN
JOIN PHONGBAN ON NHANVIEN.PHG = PHONGBAN.MAPHG
JOIN NHANVIEN NV ON NV.MANV = PHONGBAN.TRPHG
GROUP BY PHONGBAN.TRPHG, NV.TENNV, PHONGBAN.NG_NHANCHUC;

