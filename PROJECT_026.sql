CREATE DATABASE Lesco_DB;
USE Lesco_DB;
CREATE TABLE CUSTOMERS (
customer_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
address TEXT NOT NULL,
phone VARCHAR(20) UNIQUE,
email VARCHAR(100),
registration_date DATE NOT NULL,
status ENUM('Active', 'Inactive') DEFAULT 'Active'
);
CREATE TABLE TARIFFS (
tariff_id INT AUTO_INCREMENT PRIMARY KEY,
tariff_name VARCHAR(100) NOT NULL,
effective_date DATE NOT NULL,
end_date DATE
);
CREATE TABLE TRANSFORMERS (
transformer_id INT AUTO_INCREMENT PRIMARY KEY,
location VARCHAR(255),
capacity DECIMAL(10,2),
status ENUM('Operational', 'Maintenance', 'Out of Service') DEFAULT 'Operational'
);
CREATE TABLE CONNECTIONS (
connection_id INT AUTO_INCREMENT PRIMARY KEY,
customer_id INT NOT NULL,
meter_number VARCHAR(50) UNIQUE NOT NULL,
connection_type ENUM('Residential', 'Commercial', 'Industrial') DEFAULT 'Residential',
installation_date DATE NOT NULL,
status ENUM('Active', 'Disconnected', 'Suspended') DEFAULT 'Active',
tariff_id INT NOT NULL,
transformer_id INT NOT NULL,
FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (tariff_id) REFERENCES TARIFFS(tariff_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
FOREIGN KEY (transformer_id) REFERENCES TRANSFORMERS(transformer_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE TARIFF_SLABS (
slab_id INT AUTO_INCREMENT PRIMARY KEY,
tariff_id INT NOT NULL,
min_units INT NOT NULL,
max_units INT NOT NULL,
rate DECIMAL(10,2) NOT NULL,
FOREIGN KEY (tariff_id) REFERENCES TARIFFS(tariff_id)
ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE EMPLOYEES (
employee_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
role VARCHAR(50),
department VARCHAR(50),
contact_info VARCHAR(100),
hire_date DATE
);
CREATE TABLE METER_READINGS (
reading_id INT AUTO_INCREMENT PRIMARY KEY,
connection_id INT NOT NULL,
reading_date DATETIME NOT NULL,
reading_value DECIMAL(10,2) NOT NULL,
previous_reading_id INT,
current_reading_id INT,
reader_employee_id INT NOT NULL,
type ENUM('Initial', 'Final', 'Monthly') DEFAULT 'Monthly',
FOREIGN KEY (connection_id) REFERENCES CONNECTIONS(connection_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (reader_employee_id) REFERENCES EMPLOYEES(employee_id)
ON DELETE RESTRICT ON UPDATE CASCADE,
FOREIGN KEY (previous_reading_id) REFERENCES METER_READINGS(reading_id)
ON DELETE SET NULL ON UPDATE CASCADE,
FOREIGN KEY (current_reading_id) REFERENCES METER_READINGS(reading_id)
ON DELETE SET NULL ON UPDATE CASCADE
);
DROP TABLE IF EXISTS BILLS;

CREATE TABLE IF NOT EXISTS BILLS (
bill_id INT AUTO_INCREMENT PRIMARY KEY,
connection_id INT NOT NULL,
issue_date DATE NOT NULL,
due_date DATE NOT NULL,
consumption_units DECIMAL(10,2) NOT NULL,
amount_due DECIMAL(12,2) NOT NULL,
status ENUM('Unpaid', 'Paid', 'Overdue') DEFAULT 'Unpaid',
previous_reading_id INT,
current_reading_id INT,
FOREIGN KEY (connection_id) REFERENCES CONNECTIONS(connection_id) ON DELETE
CASCADE ON UPDATE CASCADE,
FOREIGN KEY (previous_reading_id) REFERENCES METER_READINGS(reading_id) ON DELETE
SET NULL ON UPDATE CASCADE,
FOREIGN KEY (current_reading_id) REFERENCES METER_READINGS(reading_id) ON DELETE
SET NULL ON UPDATE CASCADE
);
CREATE TABLE PAYMENT_METHODS (
method_id INT AUTO_INCREMENT PRIMARY KEY,
method_name VARCHAR(50) NOT NULL,
description TEXT
);
CREATE TABLE PAYMENTS (
payment_id INT AUTO_INCREMENT PRIMARY KEY,
bill_id INT NOT NULL,
payment_date DATETIME NOT NULL,
amount DECIMAL(12,2) NOT NULL,
payment_method_id INT NOT NULL,
transaction_id VARCHAR(100),
FOREIGN KEY (bill_id) REFERENCES BILLS(bill_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (payment_method_id) REFERENCES PAYMENT_METHODS(method_id)
ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE COMPLAINTS (
complaint_id INT AUTO_INCREMENT PRIMARY KEY,
customer_id INT NOT NULL,
connection_id INT NOT NULL,
description TEXT NOT NULL,
timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
status ENUM('Open', 'In Progress', 'Resolved', 'Closed') DEFAULT 'Open',
resolution_date DATETIME,
FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
ON DELETE CASCADE ON UPDATE CASCADE,

FOREIGN KEY (connection_id) REFERENCES CONNECTIONS(connection_id)
ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE WORK_ORDERS (
workorder_id INT AUTO_INCREMENT PRIMARY KEY,
complaint_id INT NOT NULL,
type VARCHAR(100),
description TEXT,
assigned_to INT,
scheduled_date DATE,
status ENUM('Pending', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Pending',
completion_date DATE,
FOREIGN KEY (complaint_id) REFERENCES COMPLAINTS(complaint_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (assigned_to) REFERENCES EMPLOYEES(employee_id)
ON DELETE SET NULL ON UPDATE CASCADE
);


INSERT INTO CUSTOMERS (name, address, phone, email, registration_date, status) VALUES
('Imran Ali', 'House 206, G Block, Khayaban-e-Amin, Lahore', '03001234567', 'imran.ali@example.com', '2023-01-10', 'Active'),
('Faiza Noor', 'Flat 12-B, Usman Heights, Johar Town Phase 2, Lahore', '03011234567', 'faiza.noor@example.com', '2023-02-14', 'Active'),
('Usman Tariq', 'House 88, Street 3, DHA Phase 6, Lahore', '03121234567', 'usman.tariq@example.com', '2023-03-21', 'Inactive'),
('Sana Raza', 'Plot 14, Sector C, Bahria Town, Lahore', '03231234567', 'sana.raza@example.com', '2023-04-05', 'Active'),
('Bilal Hussain', 'House 331, Block E2, Wapda Town, Lahore', '03341234567', 'bilal.hussain@example.com', '2023-05-30', 'Inactive');


INSERT INTO TARIFFS (tariff_name, effective_date, end_date) VALUES
('Residential Basic', '2022-01-01', NULL),
('Commercial Standard', '2022-01-01', NULL),
('Industrial Peak', '2022-01-01', NULL),
('Seasonal Special', '2023-06-01', '2023-09-30'),
('Legacy Tariff', '2020-01-01', '2022-12-31');


INSERT INTO CONNECTIONS (customer_id, meter_number, connection_type, installation_date, status, tariff_id, transformer_id) VALUES
(1, 'MTR10001', 'Residential', '2023-01-15', 'Active', 1, 1),
(2, 'MTR10002', 'Commercial', '2023-02-20', 'Active', 2, 2),
(3, 'MTR10003', 'Industrial', '2023-03-10', 'Disconnected', 3, 3),
(4, 'MTR10004', 'Residential', '2023-04-05', 'Suspended', 1, 4),
(5, 'MTR10005', 'Commercial', '2023-05-25', 'Active', 2, 5)


INSERT INTO TARIFF_SLABS (tariff_id, min_units, max_units, rate) VALUES
(1, 0, 100, 5.50),
(1, 101, 300, 7.75),
(2, 0, 200, 10.00),
(3, 0, 500, 12.50),
(3, 501, 1000, 15.00);

INSERT INTO EMPLOYEES (name, role, department, contact_info, hire_date) VALUES
('Usman Riaz', 'Technician', 'Field Ops', 'usman.r@example.com', '2020-05-10'),
('Hina Shah', 'Meter Reader', 'Metering', 'hina.shah@example.com', '2021-07-15'),
('Faisal Qureshi', 'Billing Officer', 'Accounts', 'faisal.q@example.com', '2019-08-01'),
('Ayesha Noor', 'CSR', 'Support', 'ayesha.noor@example.com', '2022-01-20'),
('Bilal Iqbal', 'Engineer', 'Maintenance', 'bilal.i@example.com', '2018-11-30');


INSERT INTO METER_READINGS (connection_id, reading_date, reading_value, previous_reading_id, reader_employee_id, type) VALUES
(1, '2023-06-01 10:00:00', 120.5, NULL, 2, 'Initial'),
(1, '2023-07-01 10:00:00', 250.0, 1, 2, 'Monthly'),
(2, '2023-06-05 11:00:00', 300.0, NULL, 2, 'Initial'),
(2, '2023-07-05 11:00:00', 475.0, 3, 2, 'Monthly'),
(3, '2023-06-10 09:00:00', 1000.0, NULL, 2, 'Initial');


INSERT INTO PAYMENT_METHODS (method_name, description) VALUES
('Cash', 'Cash payment at service center'),
('Credit Card', 'Visa or Mastercard accepted'),
('Bank Transfer', 'Online bank transfer'),
('Mobile Wallet', 'Easypaisa/JazzCash'),
('Cheque', 'Cheque deposit to LESCO account');

INSERT INTO PAYMENTS (bill_id, payment_date, amount, payment_method_id, transaction_id) VALUES
(2, '2023-07-10 15:00:00', 1500.00, 2, 'TXN10001'),
(3, '2023-07-01 12:00:00', 12000.00, 3, 'TXN10002'),
(5, '2023-07-20 10:00:00', 2500.00, 1, 'TXN10003'),
(1, '2023-07-05 09:30:00', 1000.00, 4, 'TXN10004'),
(4, '2023-07-15 16:45:00', 2000.00, 2, 'TXN10005');



INSERT INTO WORK_ORDERS (complaint_id, type, description, assigned_to, scheduled_date, status, completion_date) VALUES
(1, 'Inspection', 'Inspect transformer', 5, '2023-07-10', 'Pending', NULL),
(2, 'Billing Review', 'Check high bill reading', 3, '2023-07-12', 'In Progress', NULL),
(3, 'Meter Replacement', 'Replace faulty meter', 1, '2023-07-05', 'Completed', '2023-07-05'),
(4, 'Voltage Fix', 'Stabilize voltage issue', 5, '2023-06-18', 'Completed', '2023-06-20'),
(5, 'Emergency Repair', 'Restore power to Sector A', 1, '2023-06-24', 'Completed', '2023-06-25');


(5, 'MTR10005', 'Commercial', '2023-05-25', 'Active', 2, 5)  -- Add 


SELECT c.customer_id, c.name, c.phone, cn.meter_number, cn.connection_type, t.tariff_name
FROM CUSTOMERS c
JOIN CONNECTIONS cn ON c.customer_id = cn.customer_id
JOIN TARIFFS t ON cn.tariff_id = t.tariff_id
WHERE c.status = 'Active' AND cn.status = 'Active';


SELECT reading_id, reading_date, reading_value, type
FROM METER_READINGS
WHERE connection_id = 1
ORDER BY reading_date DESC
LIMIT 5;

SELECT b.bill_id, b.issue_date, b.due_date, b.amount_due,
       IFNULL(SUM(p.amount), 0) AS total_paid,
       b.amount_due - IFNULL(SUM(p.amount), 0) AS balance_due
FROM BILLS b 
LEFT JOIN PAYMENTS p ON b.bill_id = p.bill_id
JOIN CONNECTIONS c ON b.connection_id = c.connection_id
WHERE c.customer_id = 1
GROUP BY b.bill_id;

UPDATE CUSTOMERS
SET status = 'Inactive'
WHERE customer_id = 3;

UPDATE METER_READINGS
SET reading_value = 275.0, reading_date = '2023-07-02 10:00:00'
WHERE reading_id = 2;

DELETE FROM METER_READINGS
WHERE reading_id = 5;

DELETE FROM CUSTOMERS
WHERE customer_id = 5;

GRANT ALL PRIVILEGES ON Lesco_DB.* TO 'f2023376014'@'%.umt.edu.pk';


GRANT ALL PRIVILEGES ON Lesco_DB.* TO 'f2023376026'@'%.umt.edu.pk';

REVOKE INSERT, UPDATE, DELETE ON Lesco_DB.* FROM 'f2023376026'@'%.umt.edu.pk';

FLUSH PRIVILEGES;

START TRANSACTION;

-- Example inserts or updates
UPDATE CUSTOMERS SET status = 'Inactive' WHERE customer_id = 4;
INSERT INTO PAYMENTS (bill_id, payment_date, amount, payment_method_id, transaction_id)
VALUES (1, NOW(), 100.00, 1, 'TXN10006');

-- Commit the changes if all successful
COMMIT;

-- Or rollback on error
-- ROLLBACK;
SHOW TABLES;

DESCRIBE CUSTOMERS;
CREATE USER IF NOT EXISTS 'f2023376014'@'%.umt.edu.pk' IDENTIFIED BY 'StrongPassword1!';
CREATE USER IF NOT EXISTS 'f2023376026'@'%.umt.edu.pk' IDENTIFIED BY 'StrongPassword2!';