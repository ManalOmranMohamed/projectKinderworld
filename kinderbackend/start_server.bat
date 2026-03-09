@echo off
set SECRET_KEY=test-secret-key-for-demo-testing-only
set ENABLE_ADMIN_SEED_ENDPOINT=true
set ADMIN_SEED_SECRET=demo-seed-secret
cd /d "c:\Graduation Project\kinderbackend"
.venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000

