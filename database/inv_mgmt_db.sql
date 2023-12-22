-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 22, 2023 at 07:29 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `inv_mgmt_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addCustomer` (IN `p_cust_fname` VARCHAR(150), IN `p_cust_lname` VARCHAR(150), IN `p_cust_email` VARCHAR(255), IN `p_cust_phone` VARCHAR(50), IN `p_cust_address` TEXT, IN `p_cust_city` VARCHAR(150))   BEGIN
    INSERT INTO customer (
        cust_fname,
        cust_lname,
        cust_email,
        cust_phone,
        cust_address,
        cust_city
    ) VALUES (
        p_cust_fname,
        p_cust_lname,
        p_cust_email,
        p_cust_phone,
        p_cust_address,
        p_cust_city
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addEmployee` (IN `p_emp_fname` VARCHAR(150), IN `p_emp_lname` VARCHAR(150), IN `p_emp_email` VARCHAR(255), IN `p_emp_phone` VARCHAR(50), IN `p_emp_address` TEXT, IN `p_emp_city` VARCHAR(150))   BEGIN
    INSERT INTO employee (
        emp_fname,
        emp_lname,
        emp_email,
        emp_phone,
        emp_address,
        emp_city
    ) VALUES (
        p_emp_fname,
        p_emp_lname,
        p_emp_email,
        p_emp_phone,
        p_emp_address,
        p_emp_city
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addsupplier` (IN `p_supp_name` VARCHAR(150), IN `p_supp_contact_person` VARCHAR(150), IN `p_supp_email` VARCHAR(255), IN `p_supp_phone` VARCHAR(50), IN `p_supp_address` TEXT, IN `p_supp_city` VARCHAR(150))   BEGIN
    INSERT INTO supplier (
        supp_name,
        supp_contact_person,
        supp_email,
        supp_phone,
        supp_address,
        supp_city
    ) VALUES (
        p_supp_name,
        p_supp_contact_person,
        p_supp_email,
        p_supp_phone,
        p_supp_address,
        p_supp_city
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_inventory` (IN `p_inv_id` INT, IN `p_reorder_point` INT, IN `p_description` VARCHAR(255))   BEGIN
    
    IF EXISTS (SELECT 1 FROM inventory WHERE inv_id = p_inv_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Inventory with the given inv_id already exists';
    ELSE
       
        INSERT INTO inventory (inv_id, reorder_point, description)
        VALUES (p_inv_id, p_reorder_point, p_description);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTransaction` (IN `p_transaction_type` INT, IN `p_cust_order_id` INT, IN `p_cust_id` INT, IN `p_restock_item_id` INT, IN `p_supp_id` INT, IN `p_emp_id` INT, IN `p_discount` INT)   BEGIN
    INSERT INTO transaction (
        transaction_type,
        cust_order_id,
        cust_id,
        restock_item_id,
        supp_id,
        emp_id,
        discount,
        transaction_date
    ) VALUES (
        p_transaction_type,
        CASE WHEN p_transaction_type = 2 THEN NULL ELSE p_cust_order_id END,
        CASE WHEN p_transaction_type = 2 THEN NULL ELSE p_cust_id END,
        CASE WHEN p_transaction_type = 1 THEN NULL ELSE p_restock_item_id END,
        CASE WHEN p_transaction_type = 1 THEN NULL ELSE p_supp_id END,
        p_emp_id,
        p_discount,
        CURRENT_DATE()
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `restockItem` (IN `p_inv_id` INT, IN `p_order_qty` INT, IN `p_order_unit_price` DECIMAL(10,2), IN `p_order_date` DATE, IN `p_delivery_date` DATE)   BEGIN
    DECLARE invExists INT;

    
    SELECT COUNT(*) INTO invExists FROM inventory WHERE inv_id = p_inv_id;

    
    IF invExists = 1 THEN
       
        INSERT INTO restock_item (inv_id, order_qty, order_unit_price)
        VALUES (p_inv_id, p_order_qty, p_order_unit_price);

        
        SET @restock_item_id = LAST_INSERT_ID();

        
        INSERT INTO restock_detail (restock_item_id, order_date, delivery_date, status)
        VALUES (@restock_item_id,p_order_date, p_delivery_date, 1);

    ELSE
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid inv_id';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateCustomer` (IN `p_cust_id` INT, IN `p_cust_fname` VARCHAR(150), IN `p_cust_lname` VARCHAR(150), IN `p_cust_email` VARCHAR(255), IN `p_cust_phone` VARCHAR(50), IN `p_cust_address` TEXT, IN `p_cust_city` VARCHAR(150))   BEGIN
    UPDATE customer
    SET
        cust_fname = p_cust_fname,
        cust_lname = p_cust_lname,
        cust_email = p_cust_email,
        cust_phone = p_cust_phone,
        cust_address = p_cust_address,
        cust_city = p_cust_city
    WHERE
        cust_id = p_cust_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateEmployee` (IN `p_emp_id` INT, IN `p_emp_role_id` INT, IN `p_hire_date` DATE, IN `p_status` INT)   BEGIN
    UPDATE employee
    SET
        emp_role_id = p_emp_role_id,
        hire_date = p_hire_date,
        status = p_status
    WHERE emp_id = p_emp_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateRestockStatus` (IN `p_restock_detail_id` INT, IN `p_rstk_id` INT)   BEGIN
    DECLARE rstkExists INT;
    
    
    SELECT COUNT(*) INTO rstkExists
    FROM restock_detail
    WHERE restock_dtl_id = p_restock_detail_id;


    IF rstkExists = 1 THEN
        
        IF p_rstk_id = 2 THEN
            UPDATE restock_detail
            SET status = p_rstk_id, received_date = CURDATE()
            WHERE restock_dtl_id = p_restock_detail_id;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid status or received_date for update';
        END IF;
    ELSE
       
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid inv_id or rstk_id';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateSupplier` (IN `p_supplier_id` INT, IN `p_supplier_name` VARCHAR(150), IN `p_supplier_email` VARCHAR(255), IN `p_supplier_phone` VARCHAR(50), IN `p_supplier_address` TEXT, IN `p_supplier_city` VARCHAR(150))   BEGIN
    UPDATE supplier
    SET
        supplier_name = p_supplier_name,
        supplier_email = p_supplier_email,
        supplier_phone = p_supplier_phone,
        supplier_address = p_supplier_address,
        supplier_city = p_supplier_city
    WHERE
        supplier_id = p_supplier_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_inventory` (IN `p_inv_id` INT, IN `p_reorder_point` INT, IN `p_description` VARCHAR(255), IN `p_unit_price` DECIMAL(10,2))   BEGIN
    DECLARE inv_exists INT;

   
    SELECT COUNT(*) INTO inv_exists FROM inventory WHERE inv_id = p_inv_id;

    IF inv_exists > 0 THEN
        
        UPDATE inventory
        SET
            reorder_point = p_reorder_point,
            last_stock_update = CURRENT_DATE,
            description = p_description,
            unit_price = p_unit_price
        WHERE inv_id = p_inv_id;

        SELECT 'Inventory updated successfully.' AS result;

    ELSE
        SELECT 'Inventory with inv_id ' || p_inv_id || ' does not exist.' AS result;

    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_product` (IN `p_inv_id` INT, IN `p_cat_id` INT, IN `p_prod_name` VARCHAR(255), IN `p_prod_srp` DECIMAL(10,2))   BEGIN
    DECLARE inv_exists INT;

    
    SELECT COUNT(*) INTO inv_exists FROM inventory WHERE inv_id = p_inv_id;

    IF inv_exists > 0 THEN
        
        UPDATE product
        SET
            cat_id = p_cat_id,
            prod_name = p_prod_name,
            prod_srp = p_prod_srp
        WHERE inv_id = p_inv_id;

        SELECT 'Product updated successfully.' AS result;

    ELSE
        SELECT 'Inventory with inv_id ' || p_inv_id || ' does not exist.' AS result;

    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `available_product_in_inventory`
-- (See below for the actual view)
--
CREATE TABLE `available_product_in_inventory` (
`cat_id` int(11)
,`cat_name` varchar(255)
,`cat_description` text
,`prod_id` int(11)
,`prod_name` varchar(150)
,`prod_srp` decimal(10,2)
,`inv_id` int(11)
,`available_qty` int(11)
,`reorder_point` int(11)
,`last_stock_update` date
,`inventory_description` text
,`unit_price` decimal(10,2)
,`total_amount_inv` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `cat_id` int(11) NOT NULL,
  `cat_name` varchar(255) NOT NULL,
  `cat_description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`cat_id`, `cat_name`, `cat_description`) VALUES
(1, 'upper', 'shirt'),
(2, 'lower', 'pantalon'),
(3, 'underware', 'levis nga brief');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `cust_id` int(11) NOT NULL,
  `cust_fname` varchar(150) NOT NULL,
  `cust_lname` varchar(150) NOT NULL,
  `cust_email` varchar(255) DEFAULT NULL,
  `cust_phone` varchar(30) DEFAULT NULL,
  `cust_address` text DEFAULT NULL,
  `cust_city` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`cust_id`, `cust_fname`, `cust_lname`, `cust_email`, `cust_phone`, `cust_address`, `cust_city`) VALUES
(11, 'Clarc', 'Gumapon', 'clarcG@gmail.com', '1348246579', 'poblacion', 'pagadian city'),
(12, 'Joane', 'Ondin', 'OndinJ@gmail.com', '9764589123', 'prk idk', 'Tukuran City'),
(13, 'Stela', 'Catian', 'CatianS@gmail.com', '1452364591', 'Masagana', 'Aurora City'),
(14, 'jeremae', 'lumusad', 'jlum@gmail.com', '44444444444', 'poblacion', 'aurora');

-- --------------------------------------------------------

--
-- Table structure for table `customer_order`
--

CREATE TABLE `customer_order` (
  `cust_order_id` int(11) NOT NULL,
  `prod_id` int(11) NOT NULL,
  `cust_order_qty` int(11) NOT NULL,
  `cust_order_subtotal` decimal(10,2) NOT NULL,
  `cust_order_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer_order`
--

INSERT INTO `customer_order` (`cust_order_id`, `prod_id`, `cust_order_qty`, `cust_order_subtotal`, `cust_order_date`) VALUES
(16, 1, 40, 500.00, '2023-12-22'),
(17, 2, 23, 1000.00, '2023-12-23'),
(18, 3, 53, 5000.00, '2023-12-23');

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `emp_id` int(11) NOT NULL,
  `emp_role_id` int(11) DEFAULT NULL,
  `emp_fname` varchar(150) NOT NULL,
  `emp_lname` varchar(150) NOT NULL,
  `emp_email` varchar(255) DEFAULT NULL,
  `emp_phone` varchar(50) DEFAULT NULL,
  `emp_address` text DEFAULT NULL,
  `emp_city` varchar(150) DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  `status` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`emp_id`, `emp_role_id`, `emp_fname`, `emp_lname`, `emp_email`, `emp_phone`, `emp_address`, `emp_city`, `hire_date`, `status`) VALUES
(20, 2, 'CM', 'Baslan', 'CmBaslant@yahoo.com', '1245731649', 'sapa anding', 'Ramon Magsaysay', '2023-11-12', 2),
(21, NULL, 'liezel Joy', 'Espiga', 'LJEspiga@gmail.com', '94613578912', 'bagong lipunan', 'aurora zds', NULL, 1),
(22, 1, 'rexenie', 'quilicot', 'rex@gmail.com', '53419576216', 'Poblacion', 'Aurora', '2023-11-12', 2);

-- --------------------------------------------------------

--
-- Table structure for table `employee_role`
--

CREATE TABLE `employee_role` (
  `emp_role_id` int(11) NOT NULL,
  `emp_role` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee_role`
--

INSERT INTO `employee_role` (`emp_role_id`, `emp_role`) VALUES
(1, 'manager'),
(2, 'sales clerk');

-- --------------------------------------------------------

--
-- Table structure for table `employee_status`
--

CREATE TABLE `employee_status` (
  `emp_stat_id` int(11) NOT NULL,
  `status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee_status`
--

INSERT INTO `employee_status` (`emp_stat_id`, `status`) VALUES
(1, 'inactive/not hired'),
(2, 'active/hired');

-- --------------------------------------------------------

--
-- Stand-in structure for view `employee_view`
-- (See below for the actual view)
--
CREATE TABLE `employee_view` (
`emp_id` int(11)
,`emp_role` varchar(50)
,`emp_fullname` varchar(301)
,`emp_email` varchar(255)
,`emp_phone` varchar(50)
,`emp_address` text
,`emp_hire_date` date
,`emp_status` varchar(20)
,`total_transaction` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `inv_id` int(11) NOT NULL,
  `available_qty` int(11) DEFAULT NULL,
  `reorder_point` int(11) DEFAULT NULL,
  `last_stock_update` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `supp_id` int(11) DEFAULT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `total_inv_amount` decimal(20,2) GENERATED ALWAYS AS (`available_qty` * `unit_price`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`inv_id`, `available_qty`, `reorder_point`, `last_stock_update`, `description`, `supp_id`, `unit_price`) VALUES
(1, 100, 20, '2023-12-22', 'ambot lang', 11, 30.00),
(2, NULL, 4, NULL, 'short', 12, 0.00),
(3, NULL, 5, NULL, 'ngano ne', 13, 0.00);

-- --------------------------------------------------------

--
-- Stand-in structure for view `inventory_products_view`
-- (See below for the actual view)
--
CREATE TABLE `inventory_products_view` (
`cat_id` int(11)
,`cat_name` varchar(255)
,`cat_description` text
,`prod_id` int(11)
,`prod_name` varchar(150)
,`prod_srp` decimal(10,2)
,`inv_id` int(11)
,`available_qty` int(11)
,`reorder_point` int(11)
,`last_stock_update` date
,`inv_description` text
,`supp_id` int(11)
,`unit_price` decimal(10,2)
,`total_inv_amount` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `low_stock_products`
-- (See below for the actual view)
--
CREATE TABLE `low_stock_products` (
`cat_id` int(11)
,`cat_name` varchar(255)
,`cat_description` text
,`prod_id` int(11)
,`prod_name` varchar(150)
,`prod_srp` decimal(10,2)
,`inv_id` int(11)
,`available_qty` int(11)
,`reorder_point` int(11)
,`last_stock_update` date
,`inventory_description` text
,`unit_price` decimal(10,2)
,`total_inv_amount` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `prod_id` int(11) NOT NULL,
  `cat_id` int(11) NOT NULL,
  `prod_name` varchar(150) DEFAULT NULL,
  `inv_id` int(11) DEFAULT NULL,
  `prod_srp` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`prod_id`, `cat_id`, `prod_name`, `inv_id`, `prod_srp`) VALUES
(1, 1, 'v-neck', 1, 30.00),
(2, 2, 'polo', 2, 10.00),
(3, 3, 'calvin klein', 3, 5.00);

-- --------------------------------------------------------

--
-- Table structure for table `restock_detail`
--

CREATE TABLE `restock_detail` (
  `restock_dtl_id` int(11) NOT NULL,
  `restock_item_id` int(11) NOT NULL,
  `order_date` date NOT NULL,
  `delivery_date` date NOT NULL,
  `status` int(11) DEFAULT 1,
  `received_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `restock_detail`
--

INSERT INTO `restock_detail` (`restock_dtl_id`, `restock_item_id`, `order_date`, `delivery_date`, `status`, `received_date`) VALUES
(14, 10, '2023-12-22', '2024-01-01', 2, '2023-12-22'),
(15, 11, '2023-12-22', '2024-01-01', 1, NULL),
(16, 12, '2023-12-22', '2024-01-01', 1, NULL);

--
-- Triggers `restock_detail`
--
DELIMITER $$
CREATE TRIGGER `restock_trigger` AFTER UPDATE ON `restock_detail` FOR EACH ROW BEGIN
    IF NEW.status = 2 THEN
        
        UPDATE inventory
        SET available_qty = COALESCE(available_qty, 0) + (
            SELECT order_qty
            FROM restock_item
            WHERE restock_item_id = NEW.restock_item_id
        )
        WHERE inv_id = (
            SELECT inv_id
            FROM restock_item
            WHERE restock_item_id = NEW.restock_item_id
        );


        UPDATE inventory
        SET last_stock_update = NEW.received_date
        WHERE inv_id = (
            SELECT inv_id
            FROM restock_item
            WHERE restock_item_id = NEW.restock_item_id
        );

        UPDATE inventory
        SET unit_price = (
            SELECT order_unit_price
            FROM restock_item
            WHERE restock_item_id = NEW.restock_item_id
        )
        WHERE inv_id = (
            SELECT inv_id
            FROM restock_item
            WHERE restock_item_id = NEW.restock_item_id
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `restock_item`
--

CREATE TABLE `restock_item` (
  `restock_item_id` int(11) NOT NULL,
  `inv_id` int(11) NOT NULL,
  `order_qty` int(11) NOT NULL,
  `order_unit_price` decimal(10,2) DEFAULT NULL,
  `restock_item_subtotal` decimal(10,2) GENERATED ALWAYS AS (`order_qty` * `order_unit_price`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `restock_item`
--

INSERT INTO `restock_item` (`restock_item_id`, `inv_id`, `order_qty`, `order_unit_price`) VALUES
(10, 1, 100, 30.00),
(11, 2, 300, 10.00),
(12, 3, 60, 130.00);

--
-- Triggers `restock_item`
--
DELIMITER $$
CREATE TRIGGER `update_restock_item_subtotal` BEFORE INSERT ON `restock_item` FOR EACH ROW BEGIN
    
    SET NEW.restock_item_subtotal = NEW.order_qty * NEW.order_unit_price;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `restock_item_info`
-- (See below for the actual view)
--
CREATE TABLE `restock_item_info` (
`restock_item_id` int(11)
,`inv_id` int(11)
,`order_qty` int(11)
,`order_unit_price` decimal(10,2)
,`restock_item_subtotal` decimal(10,2)
,`restock_dtl_id` int(11)
,`order_date` date
,`delivery_date` date
,`restock_status` varchar(50)
,`supplier_name` varchar(250)
);

-- --------------------------------------------------------

--
-- Table structure for table `restock_status`
--

CREATE TABLE `restock_status` (
  `rstk_id` int(11) NOT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `restock_status`
--

INSERT INTO `restock_status` (`rstk_id`, `status`) VALUES
(1, 'en route'),
(2, 'received');

-- --------------------------------------------------------

--
-- Stand-in structure for view `restock_transaction_history`
-- (See below for the actual view)
--
CREATE TABLE `restock_transaction_history` (
`type` varchar(50)
,`tran_id` int(11)
,`supp_id` int(11)
,`supp_name` varchar(250)
,`inv_id` int(11)
,`prod_name` varchar(150)
,`restock_item_id` int(11)
,`order_qty` int(11)
,`order_unit_price` decimal(10,2)
,`restock_item_subtotal` decimal(10,2)
,`restock_dtl_id` int(11)
,`order_date` date
,`delivery_date` date
,`received_date` date
,`emp_id` int(11)
,`emp_fname` varchar(150)
,`emp_lname` varchar(150)
,`discount` int(11)
,`total_amount` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `sale_transaction_history`
-- (See below for the actual view)
--
CREATE TABLE `sale_transaction_history` (
`type` varchar(50)
,`tran_id` int(11)
,`prod_name` varchar(150)
,`prod_srp` decimal(10,2)
,`cust_order_qty` int(11)
,`cust_order_subtotal` decimal(10,2)
,`cust_order_id` int(11)
,`cust_order_date` date
,`discount` int(11)
,`total_amount` decimal(10,2)
,`transaction_date` date
,`cust_id` int(11)
,`cust_fname` varchar(150)
,`cust_lname` varchar(150)
,`emp_id` int(11)
,`emp_fname` varchar(150)
,`emp_lname` varchar(150)
);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `supp_id` int(11) NOT NULL,
  `supp_name` varchar(250) NOT NULL,
  `supp_contact_person` varchar(250) NOT NULL,
  `supp_email` varchar(255) DEFAULT NULL,
  `supp_phone` varchar(30) DEFAULT NULL,
  `supp_address` text DEFAULT NULL,
  `supp_city` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`supp_id`, `supp_name`, `supp_contact_person`, `supp_email`, `supp_phone`, `supp_address`, `supp_city`) VALUES
(11, 'jeans Co.', 'James Acal', 'AcalJ@gmail.com', '45789134561', 'pobalacion', 'ozamis'),
(12, 'ShirtLess', 'cenen pintor', 'cenp@gmail.com', '47524678916', 'pobalacion', 'Aurora'),
(13, 'ShoeLess', 'Justhin Narvasa', 'Just10@gmail.com', '47514691324', 'pobalacion', 'pagadian');

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

CREATE TABLE `transaction` (
  `tran_id` int(11) NOT NULL,
  `transaction_type` int(11) NOT NULL,
  `cust_order_id` int(11) DEFAULT NULL,
  `cust_id` int(11) DEFAULT NULL,
  `restock_item_id` int(11) DEFAULT NULL,
  `supp_id` int(11) DEFAULT NULL,
  `emp_id` int(11) NOT NULL,
  `discount` int(11) DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `transaction_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`tran_id`, `transaction_type`, `cust_order_id`, `cust_id`, `restock_item_id`, `supp_id`, `emp_id`, `discount`, `total_amount`, `transaction_date`) VALUES
(10, 1, 16, 11, NULL, NULL, 20, 0, 0.00, '2023-12-22'),
(11, 2, NULL, NULL, 10, 11, 22, 0, 0.00, '2023-12-22'),
(12, 2, NULL, NULL, 12, 12, 20, 0, 0.00, '2023-12-22');

--
-- Triggers `transaction`
--
DELIMITER $$
CREATE TRIGGER `check_transaction_conditions` BEFORE INSERT ON `transaction` FOR EACH ROW BEGIN
    IF NEW.transaction_type = 1 THEN
        SET NEW.supp_id = NULL;
        SET NEW.restock_item_id = NULL;
    ELSEIF NEW.transaction_type = 2 THEN
        SET NEW.cust_order_id = NULL;
        SET NEW.cust_id = NULL;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `convert_discount_to_decimal` BEFORE INSERT ON `transaction` FOR EACH ROW BEGIN
   
    SET NEW.discount = NEW.discount / 100;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_total_amount` BEFORE UPDATE ON `transaction` FOR EACH ROW BEGIN
    DECLARE transaction_type INT;

   

    IF transaction_type = 1 THEN
        SET NEW.total_amount = (SELECT cust_order_subtotal FROM customer_order WHERE customer_order.cust_order_id = NEW.cust_order_id) * NEW.discount;
    ELSEIF transaction_type = 2 THEN
        SET NEW.total_amount = (SELECT restock_item_subtotal FROM restock_item WHERE restock_item.restock_item_id = NEW.restock_item_id) * NEW.discount;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `transact_type`
--

CREATE TABLE `transact_type` (
  `t_type_id` int(11) NOT NULL,
  `type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transact_type`
--

INSERT INTO `transact_type` (`t_type_id`, `type`) VALUES
(1, 'sale'),
(2, 'reorder/restock');

-- --------------------------------------------------------

--
-- Structure for view `available_product_in_inventory`
--
DROP TABLE IF EXISTS `available_product_in_inventory`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `available_product_in_inventory`  AS SELECT `c`.`cat_id` AS `cat_id`, `c`.`cat_name` AS `cat_name`, `c`.`cat_description` AS `cat_description`, `p`.`prod_id` AS `prod_id`, `p`.`prod_name` AS `prod_name`, `p`.`prod_srp` AS `prod_srp`, `i`.`inv_id` AS `inv_id`, `i`.`available_qty` AS `available_qty`, `i`.`reorder_point` AS `reorder_point`, `i`.`last_stock_update` AS `last_stock_update`, `i`.`description` AS `inventory_description`, `i`.`unit_price` AS `unit_price`, `i`.`total_inv_amount` AS `total_amount_inv` FROM ((`category` `c` join `product` `p` on(`c`.`cat_id` = `p`.`cat_id`)) join `inventory` `i` on(`p`.`inv_id` = `i`.`inv_id`)) WHERE `i`.`available_qty` >= `i`.`reorder_point` ;

-- --------------------------------------------------------

--
-- Structure for view `employee_view`
--
DROP TABLE IF EXISTS `employee_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `employee_view`  AS SELECT `e`.`emp_id` AS `emp_id`, `er`.`emp_role` AS `emp_role`, concat(`e`.`emp_fname`,' ',`e`.`emp_lname`) AS `emp_fullname`, `e`.`emp_email` AS `emp_email`, `e`.`emp_phone` AS `emp_phone`, `e`.`emp_address` AS `emp_address`, `e`.`hire_date` AS `emp_hire_date`, `es`.`status` AS `emp_status`, count(`t`.`tran_id`) AS `total_transaction` FROM (((`employee` `e` join `employee_role` `er` on(`e`.`emp_role_id` = `er`.`emp_role_id`)) join `employee_status` `es` on(`e`.`status` = `es`.`emp_stat_id`)) left join `transaction` `t` on(`e`.`emp_id` = `t`.`emp_id`)) GROUP BY `e`.`emp_id`, `er`.`emp_role`, concat(`e`.`emp_fname`,' ',`e`.`emp_lname`), `e`.`emp_email`, `e`.`emp_phone`, `e`.`emp_address`, `e`.`hire_date`, `es`.`status` ;

-- --------------------------------------------------------

--
-- Structure for view `inventory_products_view`
--
DROP TABLE IF EXISTS `inventory_products_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `inventory_products_view`  AS SELECT `c`.`cat_id` AS `cat_id`, `c`.`cat_name` AS `cat_name`, `c`.`cat_description` AS `cat_description`, `p`.`prod_id` AS `prod_id`, `p`.`prod_name` AS `prod_name`, `p`.`prod_srp` AS `prod_srp`, `i`.`inv_id` AS `inv_id`, `i`.`available_qty` AS `available_qty`, `i`.`reorder_point` AS `reorder_point`, `i`.`last_stock_update` AS `last_stock_update`, `i`.`description` AS `inv_description`, `i`.`supp_id` AS `supp_id`, `i`.`unit_price` AS `unit_price`, `i`.`total_inv_amount` AS `total_inv_amount` FROM ((`category` `c` join `product` `p` on(`c`.`cat_id` = `p`.`cat_id`)) join `inventory` `i` on(`p`.`inv_id` = `i`.`inv_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `low_stock_products`
--
DROP TABLE IF EXISTS `low_stock_products`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `low_stock_products`  AS SELECT `c`.`cat_id` AS `cat_id`, `c`.`cat_name` AS `cat_name`, `c`.`cat_description` AS `cat_description`, `p`.`prod_id` AS `prod_id`, `p`.`prod_name` AS `prod_name`, `p`.`prod_srp` AS `prod_srp`, `i`.`inv_id` AS `inv_id`, `i`.`available_qty` AS `available_qty`, `i`.`reorder_point` AS `reorder_point`, `i`.`last_stock_update` AS `last_stock_update`, `i`.`description` AS `inventory_description`, `i`.`unit_price` AS `unit_price`, `i`.`total_inv_amount` AS `total_inv_amount` FROM ((`category` `c` join `product` `p` on(`c`.`cat_id` = `p`.`cat_id`)) join `inventory` `i` on(`p`.`inv_id` = `i`.`inv_id`)) WHERE `i`.`available_qty` < `i`.`reorder_point` ;

-- --------------------------------------------------------

--
-- Structure for view `restock_item_info`
--
DROP TABLE IF EXISTS `restock_item_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `restock_item_info`  AS SELECT `ri`.`restock_item_id` AS `restock_item_id`, `ri`.`inv_id` AS `inv_id`, `ri`.`order_qty` AS `order_qty`, `ri`.`order_unit_price` AS `order_unit_price`, `ri`.`restock_item_subtotal` AS `restock_item_subtotal`, `rd`.`restock_dtl_id` AS `restock_dtl_id`, `rd`.`order_date` AS `order_date`, `rd`.`delivery_date` AS `delivery_date`, `rs`.`status` AS `restock_status`, `s`.`supp_name` AS `supplier_name` FROM (((`restock_item` `ri` join `restock_detail` `rd` on(`ri`.`restock_item_id` = `rd`.`restock_item_id`)) join `restock_status` `rs` on(`rd`.`status` = `rs`.`rstk_id`)) join `supplier` `s` on(`ri`.`inv_id` = `s`.`supp_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `restock_transaction_history`
--
DROP TABLE IF EXISTS `restock_transaction_history`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `restock_transaction_history`  AS SELECT `tt`.`type` AS `type`, `t`.`tran_id` AS `tran_id`, `s`.`supp_id` AS `supp_id`, `s`.`supp_name` AS `supp_name`, `i`.`inv_id` AS `inv_id`, `p`.`prod_name` AS `prod_name`, `ri`.`restock_item_id` AS `restock_item_id`, `ri`.`order_qty` AS `order_qty`, `ri`.`order_unit_price` AS `order_unit_price`, `ri`.`restock_item_subtotal` AS `restock_item_subtotal`, `rd`.`restock_dtl_id` AS `restock_dtl_id`, `rd`.`order_date` AS `order_date`, `rd`.`delivery_date` AS `delivery_date`, `rd`.`received_date` AS `received_date`, `e`.`emp_id` AS `emp_id`, `e`.`emp_fname` AS `emp_fname`, `e`.`emp_lname` AS `emp_lname`, `t`.`discount` AS `discount`, `t`.`total_amount` AS `total_amount` FROM (((((((`transact_type` `tt` join `transaction` `t` on(`tt`.`t_type_id` = `t`.`transaction_type`)) join `restock_item` `ri` on(`t`.`restock_item_id` = `ri`.`restock_item_id`)) join `restock_detail` `rd` on(`ri`.`restock_item_id` = `rd`.`restock_item_id`)) join `supplier` `s` on(`ri`.`inv_id` = `s`.`supp_id`)) join `inventory` `i` on(`ri`.`inv_id` = `i`.`inv_id`)) join `product` `p` on(`i`.`inv_id` = `p`.`inv_id`)) join `employee` `e` on(`t`.`emp_id` = `e`.`emp_id`)) WHERE `tt`.`type` = 'restock' ;

-- --------------------------------------------------------

--
-- Structure for view `sale_transaction_history`
--
DROP TABLE IF EXISTS `sale_transaction_history`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sale_transaction_history`  AS SELECT `tt`.`type` AS `type`, `t`.`tran_id` AS `tran_id`, `p`.`prod_name` AS `prod_name`, `p`.`prod_srp` AS `prod_srp`, `co`.`cust_order_qty` AS `cust_order_qty`, `co`.`cust_order_subtotal` AS `cust_order_subtotal`, `co`.`cust_order_id` AS `cust_order_id`, `co`.`cust_order_date` AS `cust_order_date`, `t`.`discount` AS `discount`, `t`.`total_amount` AS `total_amount`, `t`.`transaction_date` AS `transaction_date`, `c`.`cust_id` AS `cust_id`, `c`.`cust_fname` AS `cust_fname`, `c`.`cust_lname` AS `cust_lname`, `e`.`emp_id` AS `emp_id`, `e`.`emp_fname` AS `emp_fname`, `e`.`emp_lname` AS `emp_lname` FROM (((((`transact_type` `tt` join `transaction` `t` on(`tt`.`t_type_id` = `t`.`transaction_type`)) join `customer_order` `co` on(`t`.`cust_order_id` = `co`.`cust_order_id`)) join `product` `p` on(`co`.`prod_id` = `p`.`prod_id`)) join `customer` `c` on(`t`.`cust_id` = `c`.`cust_id`)) join `employee` `e` on(`t`.`emp_id` = `e`.`emp_id`)) WHERE `tt`.`type` = 'sale' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`cat_id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`cust_id`);

--
-- Indexes for table `customer_order`
--
ALTER TABLE `customer_order`
  ADD PRIMARY KEY (`cust_order_id`),
  ADD KEY `prod_id` (`prod_id`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`emp_id`),
  ADD KEY `emp_role_id` (`emp_role_id`),
  ADD KEY `fk_employee_status` (`status`);

--
-- Indexes for table `employee_role`
--
ALTER TABLE `employee_role`
  ADD PRIMARY KEY (`emp_role_id`);

--
-- Indexes for table `employee_status`
--
ALTER TABLE `employee_status`
  ADD PRIMARY KEY (`emp_stat_id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`inv_id`),
  ADD KEY `your_fk_constraint_name` (`supp_id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`prod_id`),
  ADD KEY `inv_id` (`inv_id`),
  ADD KEY `fk_cat_id` (`cat_id`);

--
-- Indexes for table `restock_detail`
--
ALTER TABLE `restock_detail`
  ADD PRIMARY KEY (`restock_dtl_id`),
  ADD KEY `restock_item_id` (`restock_item_id`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `restock_item`
--
ALTER TABLE `restock_item`
  ADD PRIMARY KEY (`restock_item_id`),
  ADD KEY `inv_id` (`inv_id`);

--
-- Indexes for table `restock_status`
--
ALTER TABLE `restock_status`
  ADD PRIMARY KEY (`rstk_id`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`supp_id`);

--
-- Indexes for table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`tran_id`),
  ADD KEY `transaction_type` (`transaction_type`),
  ADD KEY `cust_order_id` (`cust_order_id`),
  ADD KEY `cust_id` (`cust_id`),
  ADD KEY `restock_item_id` (`restock_item_id`),
  ADD KEY `supp_id` (`supp_id`),
  ADD KEY `emp_id` (`emp_id`);

--
-- Indexes for table `transact_type`
--
ALTER TABLE `transact_type`
  ADD PRIMARY KEY (`t_type_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `cat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `cust_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `customer_order`
--
ALTER TABLE `customer_order`
  MODIFY `cust_order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `emp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `employee_role`
--
ALTER TABLE `employee_role`
  MODIFY `emp_role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `inv_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `prod_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `restock_detail`
--
ALTER TABLE `restock_detail`
  MODIFY `restock_dtl_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `restock_item`
--
ALTER TABLE `restock_item`
  MODIFY `restock_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `supp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `transaction`
--
ALTER TABLE `transaction`
  MODIFY `tran_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customer_order`
--
ALTER TABLE `customer_order`
  ADD CONSTRAINT `customer_order_ibfk_1` FOREIGN KEY (`prod_id`) REFERENCES `product` (`prod_id`);

--
-- Constraints for table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`emp_role_id`) REFERENCES `employee_role` (`emp_role_id`),
  ADD CONSTRAINT `fk_employee_status` FOREIGN KEY (`status`) REFERENCES `employee_status` (`emp_stat_id`);

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `your_fk_constraint_name` FOREIGN KEY (`supp_id`) REFERENCES `supplier` (`supp_id`);

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `fk_cat_id` FOREIGN KEY (`cat_id`) REFERENCES `category` (`cat_id`),
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`inv_id`) REFERENCES `inventory` (`inv_id`);

--
-- Constraints for table `restock_detail`
--
ALTER TABLE `restock_detail`
  ADD CONSTRAINT `restock_detail_ibfk_1` FOREIGN KEY (`restock_item_id`) REFERENCES `restock_item` (`restock_item_id`),
  ADD CONSTRAINT `restock_detail_ibfk_2` FOREIGN KEY (`status`) REFERENCES `restock_status` (`rstk_id`);

--
-- Constraints for table `restock_item`
--
ALTER TABLE `restock_item`
  ADD CONSTRAINT `restock_item_ibfk_1` FOREIGN KEY (`inv_id`) REFERENCES `inventory` (`inv_id`);

--
-- Constraints for table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`transaction_type`) REFERENCES `transact_type` (`t_type_id`),
  ADD CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`cust_order_id`) REFERENCES `customer_order` (`cust_order_id`),
  ADD CONSTRAINT `transaction_ibfk_3` FOREIGN KEY (`cust_id`) REFERENCES `customer` (`cust_id`),
  ADD CONSTRAINT `transaction_ibfk_4` FOREIGN KEY (`restock_item_id`) REFERENCES `restock_item` (`restock_item_id`),
  ADD CONSTRAINT `transaction_ibfk_5` FOREIGN KEY (`supp_id`) REFERENCES `supplier` (`supp_id`),
  ADD CONSTRAINT `transaction_ibfk_6` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
