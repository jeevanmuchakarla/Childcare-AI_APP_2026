CREATE DATABASE IF NOT EXISTS childcare;
USE childcare;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Parent', 'Preschool', 'Daycare', 'Admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS parents (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS children (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    age VARCHAR(50),
    FOREIGN KEY (parent_id) REFERENCES parents(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS centers (
    user_id INT PRIMARY KEY,
    center_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(150),
    phone VARCHAR(20),
    license_number VARCHAR(100),
    capacity VARCHAR(50),
    address TEXT,
    opening_time VARCHAR(20),
    closing_time VARCHAR(20),
    safety_certifications TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parent_id INT NOT NULL,
    provider_id INT NOT NULL,
    child_id INT,
    status ENUM('Pending', 'Confirmed', 'Completed', 'Cancelled') DEFAULT 'Pending',
    booking_date DATE NOT NULL,
    start_time VARCHAR(20),
    end_time VARCHAR(20),
    total_amount FLOAT,
    FOREIGN KEY (parent_id) REFERENCES parents(user_id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    amount FLOAT NOT NULL,
    status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Pending',
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);
