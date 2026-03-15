@echo off
if "%KINDER_JWT_SECRET%"=="" if "%JWT_SECRET_KEY%"=="" if "%SECRET_KEY%"=="" (
  echo ERROR: JWT secret is not set.
  echo Set KINDER_JWT_SECRET in your environment or .env file before starting.
  exit /b 1
)
if "%ENABLE_ADMIN_SEED_ENDPOINT%"=="" set ENABLE_ADMIN_SEED_ENDPOINT=false
rem ENABLE_ADMIN_SEED_ENDPOINT is for local/dev use only. Do not enable in production.
cd /d "c:\Graduation Project\kinderbackend"
.venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000

