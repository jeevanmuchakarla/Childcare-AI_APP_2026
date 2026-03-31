-- Childcare AI Backend SQL Schema
-- Auto-generated from models.py

CREATE DATABASE IF NOT EXISTS Childcare_db;
USE Childcare_db;

CREATE TABLE users (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	email VARCHAR(120) NOT NULL, 
	password_hash VARCHAR(255) NOT NULL, 
	`role` ENUM('Parent','Preschool','Daycare','Admin') NOT NULL, 
	is_approved BOOL, 
	created_at DATETIME, 
	PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ix_users_email ON users (email);

CREATE INDEX ix_users_id ON users (id);

CREATE TABLE otp_codes (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	email VARCHAR(120) NOT NULL, 
	code VARCHAR(6) NOT NULL, 
	expires_at DATETIME NOT NULL, 
	is_verified BOOL, 
	PRIMARY KEY (id)
);

CREATE INDEX ix_otp_codes_id ON otp_codes (id);

CREATE INDEX ix_otp_codes_email ON otp_codes (email);

CREATE TABLE parents (
	user_id INTEGER NOT NULL, 
	full_name VARCHAR(150) NOT NULL, 
	phone VARCHAR(20), 
	bio TEXT, 
	profile_image VARCHAR(255), 
	date_of_birth VARCHAR(50), 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);

CREATE TABLE admins (
	user_id INTEGER NOT NULL, 
	full_name VARCHAR(150) NOT NULL, 
	employee_id VARCHAR(50), 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);

CREATE TABLE centers (
	user_id INTEGER NOT NULL, 
	center_name VARCHAR(200) NOT NULL, 
	contact_person VARCHAR(150), 
	phone VARCHAR(20), 
	license_number VARCHAR(100), 
	capacity VARCHAR(50), 
	address TEXT, 
	opening_time VARCHAR(20), 
	closing_time VARCHAR(20), 
	certifications TEXT, 
	years_experience INTEGER, 
	bio TEXT, 
	website VARCHAR(255), 
	profile_image VARCHAR(255), 
	date_of_birth VARCHAR(50), 
	rating FLOAT, 
	classes_count INTEGER, 
	staff_ratio VARCHAR(50), 
	review_count INTEGER, 
	status VARCHAR(20), 
	latitude FLOAT, 
	longitude FLOAT, 
	current_status ENUM('Open','Closed','Holiday','Special Event'), 
	status_message VARCHAR(255), 
	PRIMARY KEY (user_id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);

CREATE TABLE messages (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	sender_id INTEGER NOT NULL, 
	sender_role VARCHAR(50), 
	receiver_id INTEGER NOT NULL, 
	receiver_role VARCHAR(50), 
	content TEXT NOT NULL, 
	image_url VARCHAR(255), 
	is_read BOOL, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(sender_id) REFERENCES users (id), 
	FOREIGN KEY(receiver_id) REFERENCES users (id)
);

CREATE INDEX ix_messages_id ON messages (id);

CREATE TABLE certifications (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	user_id INTEGER NOT NULL, 
	name VARCHAR(200) NOT NULL, 
	file_url VARCHAR(255) NOT NULL, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);

CREATE INDEX ix_certifications_id ON certifications (id);

CREATE TABLE staff_members (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	provider_id INTEGER NOT NULL, 
	name VARCHAR(150) NOT NULL, 
	`role` VARCHAR(100) NOT NULL, 
	status ENUM('Present','Away','On Leave'), 
	last_seen DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(provider_id) REFERENCES users (id)
);

CREATE INDEX ix_staff_members_id ON staff_members (id);

CREATE TABLE schedule_items (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	provider_id INTEGER NOT NULL, 
	time VARCHAR(20) NOT NULL, 
	activity VARCHAR(255) NOT NULL, 
	is_completed BOOL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(provider_id) REFERENCES users (id)
);

CREATE INDEX ix_schedule_items_id ON schedule_items (id);

CREATE TABLE ai_insights (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	provider_id INTEGER NOT NULL, 
	title VARCHAR(200) NOT NULL, 
	content TEXT NOT NULL, 
	type VARCHAR(50), 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(provider_id) REFERENCES users (id)
);

CREATE INDEX ix_ai_insights_id ON ai_insights (id);

CREATE TABLE daily_notes (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	provider_id INTEGER NOT NULL, 
	author_name VARCHAR(150), 
	content TEXT NOT NULL, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(provider_id) REFERENCES users (id)
);

CREATE INDEX ix_daily_notes_id ON daily_notes (id);

CREATE TABLE children (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	parent_id INTEGER NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	age VARCHAR(50), 
	allergies TEXT, 
	medical_notes TEXT, 
	emergency_contact VARCHAR(100), 
	PRIMARY KEY (id), 
	FOREIGN KEY(parent_id) REFERENCES parents (user_id)
);

CREATE INDEX ix_children_id ON children (id);

CREATE TABLE reviews (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	parent_id INTEGER NOT NULL, 
	provider_id INTEGER NOT NULL, 
	rating INTEGER NOT NULL, 
	comment TEXT, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(parent_id) REFERENCES parents (user_id), 
	FOREIGN KEY(provider_id) REFERENCES users (id)
);

CREATE INDEX ix_reviews_id ON reviews (id);

CREATE TABLE bookings (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	parent_id INTEGER NOT NULL, 
	provider_id INTEGER NOT NULL, 
	child_id INTEGER, 
	booking_type VARCHAR(50), 
	schedule_type VARCHAR(50), 
	status ENUM('Pending','Confirmed','Completed','Cancelled'), 
	booking_date DATE NOT NULL, 
	start_time VARCHAR(100), 
	end_time VARCHAR(100), 
	total_amount FLOAT, 
	parent_name VARCHAR(150), 
	parent_phone VARCHAR(50), 
	child_age_or_name VARCHAR(100), 
	notes TEXT, 
	PRIMARY KEY (id), 
	FOREIGN KEY(parent_id) REFERENCES parents (user_id), 
	FOREIGN KEY(provider_id) REFERENCES users (id), 
	FOREIGN KEY(child_id) REFERENCES children (id)
);

CREATE INDEX ix_bookings_id ON bookings (id);

CREATE TABLE photos (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	center_id INTEGER, 
	child_id INTEGER, 
	url VARCHAR(255) NOT NULL, 
	caption VARCHAR(200), 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(center_id) REFERENCES centers (user_id), 
	FOREIGN KEY(child_id) REFERENCES children (id)
);

CREATE INDEX ix_photos_id ON photos (id);

CREATE TABLE notifications (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	user_id INTEGER NOT NULL, 
	title VARCHAR(150) NOT NULL, 
	message TEXT NOT NULL, 
	type VARCHAR(50), 
	is_read BOOL, 
	child_id INTEGER, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id), 
	FOREIGN KEY(child_id) REFERENCES children (id)
);

CREATE INDEX ix_notifications_id ON notifications (id);

CREATE TABLE meal_records (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	child_id INTEGER NOT NULL, 
	provider_id INTEGER NOT NULL, 
	meal_type VARCHAR(50) NOT NULL, 
	food_item VARCHAR(255) NOT NULL, 
	amount_eaten VARCHAR(50) NOT NULL, 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(child_id) REFERENCES children (id), 
	FOREIGN KEY(provider_id) REFERENCES users (id)
);

CREATE INDEX ix_meal_records_id ON meal_records (id);

CREATE TABLE activity_records (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	child_id INTEGER NOT NULL, 
	provider_id INTEGER NOT NULL, 
	activity_type VARCHAR(50) NOT NULL, 
	notes TEXT, 
	start_time VARCHAR(100), 
	end_time VARCHAR(100), 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(child_id) REFERENCES children (id), 
	FOREIGN KEY(provider_id) REFERENCES users (id)
);

CREATE INDEX ix_activity_records_id ON activity_records (id);

CREATE TABLE payments (
	id INTEGER NOT NULL AUTO_INCREMENT, 
	booking_id INTEGER NOT NULL, 
	amount FLOAT NOT NULL, 
	status ENUM('Pending','Paid','Failed','Refunded'), 
	payment_method VARCHAR(50), 
	created_at DATETIME, 
	PRIMARY KEY (id), 
	FOREIGN KEY(booking_id) REFERENCES bookings (id)
);

CREATE INDEX ix_payments_id ON payments (id);

