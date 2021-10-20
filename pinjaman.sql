-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 20 Okt 2021 pada 18.17
-- Versi server: 10.4.20-MariaDB
-- Versi PHP: 7.4.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pinjaman`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ulangBulan` (`dateFrom` DATETIME, `platfon` INT, `bunga` REAL, `lamapinjaman` INT)  BEGIN
    
   		DECLARE df DATETIME;
        DECLARE lama INT;
        DECLARE intTotalAngsuran REAL;
        DECLARE intAngsuranBunga REAL;
        DECLARE intSisaPinjaman REAL;
        DECLARE intAngsuranPokok REAL;
       
  
    SET lama = 0;
    
    IF ( DATE_FORMAT(dateFrom ,'%d-%m-%Y') = '00-00-0000') THEN
               SET df = CURRENT_DATE();
           ELSE
               SET df = dateFrom;
           END IF;
    
    DROP TEMPORARY TABLE IF EXISTS dummy;
    
    CREATE TEMPORARY TABLE dummy(
       angsuranke int,
       tanggal VARCHAR(100),
       totalAngsuran REAL,
       angsuranPokok REAL,
       angsuranBunga REAL,
       sisaPinjaman REAL
       
    );

    WHILE  lama < lamapinjaman DO
           
           
 
 			SET intTotalAngsuran  = hitungAngsuran(platfon,bunga,lamapinjaman);
           IF ( lama <1) THEN
             
            
              SET intAngsuranBunga = angsuranBunga(30 , bunga , platfon);
              SET intAngsuranPokok = intTotalAngsuran - intAngsuranBunga;
              SET intSisaPinjaman =  platfon-intAngsuranPokok;
              
           ELSE
           
             SET intAngsuranBunga = angsuranBunga(30 , bunga , intSisaPinjaman);
             SET intAngsuranPokok = intTotalAngsuran - intAngsuranBunga;
             SET intSisaPinjaman =  intSisaPinjaman-intAngsuranPokok;
             
           END IF;
        
           
             
            SET intAngsuranPokok = intTotalAngsuran - intAngsuranBunga;
            
           
  
            insert into dummy  values (lama +1 , DATE_FORMAT(df ,'%d-%m-%Y'),intTotalAngsuran,intAngsuranPokok,intAngsuranBunga,intSisaPinjaman);
            
            SET df = DATE_ADD(df, INTERVAL 1 MONTH);
            SET lama = lama +1;
               
    END WHILE;
    
    select * from dummy ;
    
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `angsuranBunga` (`hari` INT, `bunga` REAL, `sisapinjaman` REAL) RETURNS DOUBLE BEGIN
          
           DECLARE hasil REAL;
          
           SET hasil =  bunga/360*30*sisapinjaman;
           RETURN hasil ;
           

 END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `hitungAngsuran` (`platfon` INT, `bunga` REAL, `lamapinjaman` INT) RETURNS DOUBLE BEGIN
           DECLARE bungaperbulan REAL;
           DECLARE hasil REAL;
           SET bungaperbulan = bunga/12;
           RETURN bungaperbulan*platfon*(POWER(((1+bungaperbulan)),lamapinjaman))/(POWER(((1+bungaperbulan)),lamapinjaman)-1);
           

 END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pinjaman`
--

CREATE TABLE `pinjaman` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `pinjaman`
--
ALTER TABLE `pinjaman`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `pinjaman`
--
ALTER TABLE `pinjaman`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
