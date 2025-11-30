-- ================================================================
-- LegalConnect Database Schema
-- AI-Powered Legal Services Platform
-- Created: November 2025
-- ================================================================

-- Drop database if exists and create fresh
DROP DATABASE IF EXISTS legalconnect_db;
CREATE DATABASE legalconnect_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE legalconnect_db;

-- ================================================================
-- USERS TABLE (Main user account table)
-- ================================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    user_type ENUM('client', 'lawyer', 'admin') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_user_type (user_type)
) ENGINE=InnoDB;

-- ================================================================
-- CLIENTS TABLE (Extended client information)
-- ================================================================
CREATE TABLE clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ================================================================
-- LAWYERS TABLE (Extended lawyer professional information)
-- ================================================================
CREATE TABLE lawyers (
    lawyer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    bar_number VARCHAR(50) NOT NULL UNIQUE,
    state_licensed VARCHAR(100) NOT NULL,
    years_experience VARCHAR(50) NOT NULL,
    primary_specialization VARCHAR(100) NOT NULL,
    city_practice VARCHAR(100) NOT NULL,
    hourly_rate VARCHAR(50) NOT NULL,
    bio TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    profile_views INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_specialization (primary_specialization),
    INDEX idx_state (state_licensed)
) ENGINE=InnoDB;

-- ================================================================
-- CASES TABLE (Legal cases submitted by clients)
-- ================================================================
CREATE TABLE cases (
    case_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    lawyer_id INT NULL,
    case_title VARCHAR(255) NOT NULL,
    case_type VARCHAR(100) NOT NULL,
    case_description TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    urgency VARCHAR(50) DEFAULT 'Normal',
    budget VARCHAR(100),
    document_path VARCHAR(500),
    case_status ENUM('pending', 'active', 'completed', 'closed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    FOREIGN KEY (lawyer_id) REFERENCES lawyers(lawyer_id) ON DELETE SET NULL,
    INDEX idx_status (case_status),
    INDEX idx_client (client_id),
    INDEX idx_lawyer (lawyer_id)
) ENGINE=InnoDB;

-- ================================================================
-- SAMPLE DATA (For testing purposes)
-- ================================================================

-- Insert sample client user
INSERT INTO users (first_name, last_name, email, password_hash, phone_number, city, user_type) 
VALUES 
('Pranjal', 'Pal', 'pranjalpal05@gmail.com', 
 'e99a18c428cb38d5f260853678922e03abc06e3e0b6f0a9b0e84c10e0f8c0c3f', -- Password: password123
 '9876543210', 'New Delhi', 'client');

-- Insert client record
INSERT INTO clients (user_id) 
VALUES (LAST_INSERT_ID());

-- Insert sample lawyer user
INSERT INTO users (first_name, last_name, email, password_hash, phone_number, city, user_type) 
VALUES 
('Dhruv', 'Pal', 'dfjnbd@gmail.com',
 'e99a18c428cb38d5f260853678922e03abc06e3e0b6f0a9b0e84c10e0f8c0c3f', -- Password: password123
 '9123456789', 'Mumbai', 'lawyer');

-- Insert lawyer record
INSERT INTO lawyers (user_id, bar_number, state_licensed, years_experience, primary_specialization, city_practice, hourly_rate, bio, is_verified) 
VALUES 
(LAST_INSERT_ID(), 'BAR123456', 'Maharashtra', '6-10 years', 'Criminal Law', 'Mumbai', 'Rs.2000-5000/hour', 
 'Experienced criminal lawyer with successful track record in high-profile cases.', TRUE);

-- Insert sample case
INSERT INTO cases (client_id, case_title, case_type, case_description, city, urgency, budget, case_status)
VALUES 
(1, 'Property Dispute Case', 'Property Law', 
 'Need legal assistance for property ownership dispute with neighbor regarding boundary issues.', 
 'New Delhi', 'Urgent', 'Rs.50,000 - Rs.1,00,000', 'pending');

-- ================================================================
-- ADDITIONAL USEFUL QUERIES
-- ================================================================

-- View all users with their roles
-- SELECT u.user_id, u.first_name, u.last_name, u.email, u.user_type, u.created_at 
-- FROM users u ORDER BY u.created_at DESC;

-- View all lawyers with their details
-- SELECT u.first_name, u.last_name, u.email, l.bar_number, l.primary_specialization, l.years_experience, l.hourly_rate
-- FROM users u 
-- INNER JOIN lawyers l ON u.user_id = l.user_id 
-- WHERE u.user_type = 'lawyer';

-- View all cases with client and lawyer information
-- SELECT c.case_id, c.case_title, c.case_type, c.case_status,
--        u1.first_name AS client_first_name, u1.last_name AS client_last_name,
--        u2.first_name AS lawyer_first_name, u2.last_name AS lawyer_last_name
-- FROM cases c
-- INNER JOIN clients cl ON c.client_id = cl.client_id
-- INNER JOIN users u1 ON cl.user_id = u1.user_id
-- LEFT JOIN lawyers l ON c.lawyer_id = l.lawyer_id
-- LEFT JOIN users u2 ON l.user_id = u2.user_id;

-- Count cases by status
-- SELECT case_status, COUNT(*) as count 
-- FROM cases 
-- GROUP BY case_status;

-- Count users by type
-- SELECT user_type, COUNT(*) as count 
-- FROM users 
-- GROUP BY user_type;

-- ================================================================
-- DATABASE SETUP COMPLETE
-- ================================================================

SELECT 'Database legalconnect_db created successfully!' AS message;
SELECT 'Total tables created: 4 (users, clients, lawyers, cases)' AS info;
