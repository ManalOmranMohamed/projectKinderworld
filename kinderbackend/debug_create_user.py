from database import SessionLocal
from models import User
from auth import hash_password
from datetime import datetime

if __name__ == '__main__':
    db = SessionLocal()
    try:
        now = datetime.utcnow()
        user = User(email='debug@example.com', password_hash=hash_password('secret'), role='parent', name='Debug', is_active=True, created_at=now, updated_at=now)
        db.add(user)
        db.commit()
        db.refresh(user)
        print('OK', user.id)
    except Exception as e:
        import traceback
        traceback.print_exc()
    finally:
        db.close()
