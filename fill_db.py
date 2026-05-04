import sqlite3
import random

db_path = r'c:\Users\DELL\Desktop\Mobile team Project\app.db'
conn = sqlite3.connect(db_path)
conn.row_factory = sqlite3.Row
cur = conn.cursor()

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 Pools for generating realistic placeholder data
# ─────────────────────────────────────────────────────────────────────────────

phone_prefixes = ['0550', '0555', '0770', '0771', '0660', '0697', '0676', '0551', '0773']
email_domains  = ['gmail.com', 'yahoo.fr', 'hotmail.fr', 'outlook.com']

gps_coords = [
    'https://maps.app.goo.gl/Nsxq2gyNG5PatWpF6',
    'https://maps.app.goo.gl/8kZc3YmVwXpQtR9e7',
    'https://maps.app.goo.gl/3rJtBkNLhFqW5sYu8',
    'https://maps.app.goo.gl/7vCpXdMnQeAZ2wKj9',
    'https://maps.app.goo.gl/LmRqTsYxVbNpKzWc6',
]

social_links = [
    'https://web.facebook.com/docteur.mila',
    'https://web.facebook.com/cabinet.medical.mila',
    'https://web.facebook.com/clinique.mila',
    'https://www.instagram.com/dr_mila_sante',
    'https://web.facebook.com/sante.mila.dz',
]

# Schedule JSON — Mon–Thu + Sat (standard Algerian office hours, skip Friday)
schedule_templates = [
    '[{"day":"Saturday","from":"08:00","to":"12:00"},{"day":"Sunday","from":"08:00","to":"17:00"},{"day":"Monday","from":"09:00","to":"17:00"},{"day":"Tuesday","from":"09:00","to":"17:00"},{"day":"Wednesday","from":"09:00","to":"17:00"},{"day":"Thursday","from":"09:00","to":"17:00"}]',
    '[{"day":"Sunday","from":"09:00","to":"13:00"},{"day":"Monday","from":"08:00","to":"16:00"},{"day":"Tuesday","from":"08:00","to":"16:00"},{"day":"Wednesday","from":"08:00","to":"16:00"},{"day":"Thursday","from":"08:00","to":"16:00"}]',
    '[{"day":"Saturday","from":"09:00","to":"14:00"},{"day":"Monday","from":"09:00","to":"18:00"},{"day":"Tuesday","from":"09:00","to":"18:00"},{"day":"Wednesday","from":"09:00","to":"18:00"},{"day":"Thursday","from":"09:00","to":"18:00"}]',
]

def rand_phone():
    prefix = random.choice(phone_prefixes)
    number = ''.join([str(random.randint(0, 9)) for _ in range(7)])
    return f'{prefix} {number[:2]} {number[2:4]} {number[4:]}'

def rand_email(name):
    parts = name.lower().replace(' ', '.').replace('é','e').replace('è','e') \
                .replace('ê','e').replace('â','a').replace('ô','o')
    parts = ''.join(c for c in parts if c.isalnum() or c == '.')[:20]
    return f'{parts}@{random.choice(email_domains)}'

def rand_gps():
    return random.choice(gps_coords)

def rand_social():
    return random.choice(social_links)

def rand_schedule():
    return random.choice(schedule_templates)

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 Step 1 — Fill NULL fields in doctors
# ─────────────────────────────────────────────────────────────────────────────
cur.execute('SELECT id, name, phone, email, gps, social_network, schedule FROM doctors')
doctors = cur.fetchall()

updated = 0
for doc in doctors:
    doc_id   = doc['id']
    name     = doc['name']
    updates  = {}

    if not doc['phone']:
        updates['phone'] = rand_phone()
    if not doc['email']:
        updates['email'] = rand_email(name)
    if not doc['gps']:
        updates['gps'] = rand_gps()
    if not doc['social_network']:
        updates['social_network'] = rand_social()
    if not doc['schedule']:
        updates['schedule'] = rand_schedule()

    if updates:
        set_clause = ', '.join(f'{k} = ?' for k in updates)
        values     = list(updates.values()) + [doc_id]
        cur.execute(f'UPDATE doctors SET {set_clause} WHERE id = ?', values)
        updated += 1

print(f'Updated {updated} doctors with generated data.')

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 Step 2 — Add a sample user
# ─────────────────────────────────────────────────────────────────────────────
cur.execute('''
    INSERT OR IGNORE INTO users (username, email, password, role)
    VALUES (?, ?, ?, ?)
''', ('Ahmed Benali', 'ahmed.benali@gmail.com', 'hashed_password_123', 'patient'))

user_id = cur.lastrowid
if user_id == 0:
    cur.execute("SELECT id FROM users WHERE email = 'ahmed.benali@gmail.com'")
    user_id = cur.fetchone()[0]

print(f'Sample user inserted/found with ID: {user_id}')

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 Step 3 — Add a sample feedback (user → first doctor)
# ─────────────────────────────────────────────────────────────────────────────
cur.execute('SELECT id, name FROM doctors LIMIT 1')
first_doctor = cur.fetchone()
doctor_id    = first_doctor['id']
doctor_name  = first_doctor['name']

cur.execute('''
    INSERT INTO feedback (user_id, doctor_id, message, rating)
    VALUES (?, ?, ?, ?)
''', (
    user_id,
    doctor_id,
    f'Dr {doctor_name} was very professional and helpful. Highly recommended!',
    5
))

print(f'Sample feedback inserted: user {user_id} → doctor {doctor_id} ({doctor_name}), rating: 5⭐')

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 Verify final state
# ─────────────────────────────────────────────────────────────────────────────
conn.commit()

cur.execute('SELECT COUNT(*) FROM doctors WHERE phone IS NOT NULL') 
print(f'\nDoctors with phone:         {cur.fetchone()[0]}/100')
cur.execute('SELECT COUNT(*) FROM doctors WHERE email IS NOT NULL')
print(f'Doctors with email:         {cur.fetchone()[0]}/100')
cur.execute('SELECT COUNT(*) FROM doctors WHERE gps IS NOT NULL')
print(f'Doctors with GPS:           {cur.fetchone()[0]}/100')
cur.execute('SELECT COUNT(*) FROM doctors WHERE social_network IS NOT NULL')
print(f'Doctors with social_network:{cur.fetchone()[0]}/100')
cur.execute('SELECT COUNT(*) FROM doctors WHERE schedule IS NOT NULL')
print(f'Doctors with schedule:      {cur.fetchone()[0]}/100')
cur.execute('SELECT COUNT(*) FROM users')
print(f'Users:                      {cur.fetchone()[0]}')
cur.execute('SELECT COUNT(*) FROM feedback')
print(f'Feedback rows:              {cur.fetchone()[0]}')

conn.close()
print('\nDone! app.db is fully populated.')
