DROP TABLE IF EXISTS shipments_product_categories CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS partners CASCADE;
DROP TABLE IF EXISTS dhl_storages CASCADE;
DROP TABLE IF EXISTS countries CASCADE;
DROP TABLE IF EXISTS incoterms CASCADE;
DROP TABLE IF EXISTS partner_roles CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;

CREATE TABLE partners (
	partner_id SERIAL PRIMARY KEY,
	first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
	phone_number VARCHAR(30) NOT NULL
);

CREATE TABLE countries (
	country_code VARCHAR(2) PRIMARY KEY,
	country_name TEXT NOT NULL
);

CREATE TABLE partner_roles (
	partner_role_id VARCHAR(1) PRIMARY KEY,
	partner_role_name VARCHAR(12) NOT NULL
);

CREATE TABLE incoterms (
	basis VARCHAR(3) PRIMARY KEY,
	responsibility_insurance VARCHAR(1) NOT NULL REFERENCES partner_roles(partner_role_id),
	responsibility_customs_export VARCHAR(1) NOT NULL REFERENCES partner_roles(partner_role_id),
	responsibility_customs_import VARCHAR(1) NOT NULL REFERENCES partner_roles(partner_role_id),
	responsibility_delivery_to_transport VARCHAR(1) NOT NULL REFERENCES partner_roles(partner_role_id),
	responsibility_delivery_to_destination VARCHAR(1) NOT NULL REFERENCES partner_roles(partner_role_id)
);

CREATE TABLE product_categories (
	product_category_id SERIAL PRIMARY KEY,
	product_category_name TEXT NOT NULL
);

CREATE TABLE dhl_storages (
	dhl_storage_id SERIAL PRIMARY KEY,
	country_code VARCHAR(2) NOT NULL REFERENCES countries(country_code),
	address TEXT NOT NULL
);

CREATE TABLE shipments (
	invoice_number SERIAL PRIMARY KEY,
	shipper_id INT NOT NULL REFERENCES partners(partner_id),
	receiver_id INT NOT NULL REFERENCES partners(partner_id),
	shipper_storage_id INT NOT NULL REFERENCES dhl_storages(dhl_storage_id),
	receiver_storage_id INT NOT NULL REFERENCES dhl_storages(dhl_storage_id),
	incoterms_basis VARCHAR(3) NOT NULL REFERENCES incoterms(basis),
	weight_kg REAL CHECK (weight_kg > 0) NOT NULL,
	departure_date DATE NOT NULL,
	receipt_date DATE NOT NULL
);

CREATE TABLE shipments_product_categories (
	invoice_number INT NOT NULL REFERENCES shipments(invoice_number),
	invoice_position INT CHECK (invoice_position > 0) NOT NULL,
	product_category_id INT NOT NULL REFERENCES product_categories(product_category_id)
);


