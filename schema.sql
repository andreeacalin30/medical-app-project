-- Basic schema for medical system
-- CREATE TABLE IF NOT EXISTS roles (
--     role_id INT PRIMARY KEY,
--     role_name VARCHAR(50) NOT NULL UNIQUE,
--     description TEXT
-- );

-- CREATE TABLE IF NOT EXISTS users (
--     user_id INT PRIMARY KEY,
--     username VARCHAR(50) NOT NULL UNIQUE,
--     password_hash VARCHAR(255) NOT NULL,
--     email VARCHAR(100) NOT NULL UNIQUE,
--     role_id INT,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     last_login TIMESTAMP,
--     is_active BOOLEAN DEFAULT true,
--     FOREIGN KEY (role_id) REFERENCES roles(role_id)
-- );

-- Additional tables as needed

-- Roles table - Enhanced with hierarchical role support and more details
CREATE TABLE IF NOT EXISTS roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_system_role BOOLEAN DEFAULT false,
    parent_role_id INT NULL,
    role_level INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_role_id) REFERENCES roles(role_id) ON DELETE SET NULL
);

-- Permissions table - Defines specific permissions
CREATE TABLE IF NOT EXISTS permissions (
    permission_id SERIAL PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    permission_key VARCHAR(100) NOT NULL UNIQUE,
    resource_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role-Permission relationships - Many-to-many relationship
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    granted_by INT,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE,
    FOREIGN KEY (granted_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Enhanced Users table
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    primary_role_id INT,
    is_active BOOLEAN DEFAULT true,
    is_email_verified BOOLEAN DEFAULT false,
    must_change_password BOOLEAN DEFAULT false,
    password_changed_at TIMESTAMP,
    failed_login_attempts INT DEFAULT 0,
    last_failed_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    created_by INT,
    FOREIGN KEY (primary_role_id) REFERENCES roles(role_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- User-Role relationships - To support multiple roles per user
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT,
    is_primary BOOLEAN DEFAULT false,
    expiry_date TIMESTAMP NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Resources table - For managing various system resources (tables, modules, etc.)
CREATE TABLE IF NOT EXISTS resources (
    resource_id SERIAL PRIMARY KEY,
    resource_name VARCHAR(100) NOT NULL UNIQUE,
    resource_type VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Access Control Rules - Defines fine-grained CRUD permissions for roles on resources
CREATE TABLE IF NOT EXISTS access_control_rules (
    rule_id SERIAL PRIMARY KEY,
    role_id INT NOT NULL,
    resource_id INT NOT NULL,
    can_create BOOLEAN DEFAULT false,
    can_read BOOLEAN DEFAULT false,
    can_update BOOLEAN DEFAULT false,
    can_delete BOOLEAN DEFAULT false,
    condition_expression TEXT, -- JSON or SQL condition for row-level security
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(user_id) ON DELETE SET NULL,
    UNIQUE (role_id, resource_id)
);

-- Audit Log table - For tracking access and changes
CREATE TABLE IF NOT EXISTS audit_log (
    log_id SERIAL PRIMARY KEY,
    user_id INT,
    role_id INT,
    action_type VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id VARCHAR(100) NOT NULL,
    action_details JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL
);

-- Initialize system roles
INSERT INTO roles (role_name, description, is_system_role, role_level) 
VALUES 
('Administrator', 'Full system access', true, 100),
('Doctor', 'Medical staff with patient management access', true, 50),
('Nurse', 'Medical support staff', true, 40),
('Receptionist', 'Front desk staff', true, 30),
('Patient', 'Medical system patient', true, 10),
('Auditor', 'Read-only access for auditing purposes', true, 60)
ON CONFLICT (role_name) DO NOTHING;