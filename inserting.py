import psycopg2
from psycopg2 import sql
from faker import Faker
import random
from datetime import datetime as d, timedelta

fake = Faker()

def connect():
    return psycopg2.connect(
        dbname="DHL",
        user="postgres",
        password="1579",
        host="localhost"
    )



def insert_partners(cur, count):
    for _ in range(count):
        first_name = fake.first_name()
        last_name = fake.last_name()
        phone_number = fake.phone_number()

        cur.execute("""
            INSERT INTO "partners" (first_name, last_name, phone_number)
            VALUES (%s, %s, %s)
        """, (first_name, last_name, phone_number))



def insert_countries(cur, count):
    i = 0
    unique_country_names = set()
    unique_country_codes = set()

    while (i < count):
        country_name = fake.country()
        country_code = fake.country_code()

        if (country_name not in unique_country_names) and (country_code not in unique_country_codes):
            unique_country_names.add(country_name)
            unique_country_codes.add(country_code)
            i += 1

            cur.execute("""
                INSERT INTO "countries" (country_code, country_name)
                VALUES (%s, %s)
            """, (country_code, country_name))

    return unique_country_codes



def insert_partner_roles(cur):
    cur.execute(f"""
        INSERT INTO "partner_roles" (partner_role_id, partner_role_name)
        VALUES ('о', 'отправитель');
        INSERT INTO "partner_roles" (partner_role_id, partner_role_name)
        VALUES ('п', 'получатель');
        INSERT INTO "partner_roles" (partner_role_id, partner_role_name)
        VALUES ('н', 'не определен')
    """)



def insert_incoterms(cur):
    cur.execute(f"""
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('EXW', 'н', 'п', 'п', 'п', 'п');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('FCA', 'н', 'о', 'п', 'п', 'п');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('FAS', 'н', 'о', 'п', 'о', 'п');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('FOB', 'н', 'о', 'п', 'о', 'п');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('CFR', 'н', 'о', 'п', 'о', 'п');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('CIF', 'о', 'о', 'п', 'о', 'п');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('CIP', 'о', 'о', 'п', 'о', 'о');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('CPT', 'н', 'о', 'п', 'о', 'о');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('DAP', 'н', 'о', 'п', 'о', 'о');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('DPU', 'н', 'о', 'п', 'о', 'о');
        INSERT INTO "incoterms" (basis, responsibility_insurance, responsibility_customs_export, responsibility_customs_import, responsibility_delivery_to_transport, responsibility_delivery_to_destination)
        VALUES ('DDP', 'н', 'о', 'о', 'о', 'о')
    """)



def insert_product_categories(cur, count):
    for _ in range(count):
        product_category_name = fake.word()

        cur.execute(f"""
            INSERT INTO "product_categories" (product_category_name)
            VALUES ('{product_category_name}')
        """)



def insert_dhl_storages(cur, count, country_codes):
    for _ in range(count):
        country_code = random.choice(list(country_codes))
        address = fake.address()

        cur.execute(f"""
            INSERT INTO "dhl_storages" (country_code, address)
            VALUES ('{country_code}', '{address}')
        """)



def insert_shipments(cur, count, num_partners, num_dhl_storages):
    incoterms_basises = ["EXW", "FCA", "FAS", "FOB", "CFR", "CIF", "CIP", "CPT", "DAP", "DPU", "DDP"]

    for _ in range(count):
        shipper_id = random.randint(1, num_partners)
        receiver_id = random.randint(1, num_partners)
        shipper_storage_id = random.randint(1, num_dhl_storages)
        receiver_storage_id = random.randint(1, num_dhl_storages)
        incoterms_basis = random.choice(incoterms_basises)
        weight_kg = random.uniform(0.01, 500.0)
        departure_date = fake.date_between(d(1990, 1, 1), d(2026, 1, 1))
        receipt_date = fake.date_between(d(1990, 1, 1), d(2026, 1, 1))

        cur.execute(f"""
            INSERT INTO "shipments" (shipper_id, receiver_id, shipper_storage_id, receiver_storage_id, incoterms_basis, weight_kg, departure_date, receipt_date)
            VALUES ({shipper_id}, {receiver_id}, {shipper_storage_id}, {receiver_storage_id}, '{incoterms_basis}', {weight_kg}, '{departure_date}', '{receipt_date}')
        """)



def insert_shipments_product_categories(cur, num_shipments_product_categories, num_positions, num_shipments, num_product_categories):
    for _ in range(num_shipments_product_categories):
        invoice_number = random.randint(1, num_shipments)
        invoice_position = random.randint(1, num_positions)
        product_category_id = random.randint(1, num_product_categories)

        cur.execute(f"""
            INSERT INTO "shipments_product_categories" (invoice_number, invoice_position, product_category_id)
            VALUES ({invoice_number}, {invoice_position}, {product_category_id})
        """)



def main():
    try:
        conn = connect()
        conn.autocommit = False
        cur = conn.cursor()

        num_partners = 100000
        num_countries = 175
        num_product_categories = 10000
        num_dhl_storages = 10000
        num_shipments = 1000000
        num_shipments_product_categories = 10000000
        num_positions = 10

        #print("Inserting partners...")
        #insert_partners(cur, num_partners)

        #print("Inserting countries...")
        #country_codes = insert_countries(cur, num_countries)

        #print("Inserting partner_roles...")
        #insert_partner_roles(cur)

        #print("Inserting incoterms...")
        #insert_incoterms(cur)

        #print("Inserting product_categories...")
        #insert_product_categories(cur, num_product_categories)

        #print("Inserting dhl_storages...")
        #insert_dhl_storages(cur, num_dhl_storages, country_codes)

        #print("Inserting shipments...")
        #insert_shipments(cur, num_shipments, num_partners, num_dhl_storages)
        
        #print("Inserting shipments_product_categories...")
        #insert_shipments_product_categories(cur, num_shipments_product_categories, num_positions, num_shipments, num_product_categories)

        conn.commit()
        print("Data inserted successfully!")

    except Exception as e:
        print(f"An error occurred: {e}")
        conn.rollback()
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    main()