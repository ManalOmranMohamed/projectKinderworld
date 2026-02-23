from sqlalchemy import Column, Integer, String, DateTime, Boolean, Date, func, ForeignKey, JSON, text
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    name = Column(String, nullable=True)
    role = Column(String, nullable=False, default="parent")
    is_active = Column(Boolean, default=True, nullable=False)
    is_premium = Column(Boolean, default=False, nullable=False, server_default=text("0"))
    plan = Column(String, nullable=False, default="FREE", server_default=text("'FREE'"))

    token_version = Column(Integer, default=0, nullable=False, server_default=text("0"))
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    # One-to-many: a parent can have multiple child profiles
    children = relationship("ChildProfile", back_populates="parent", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
    privacy_setting = relationship("PrivacySetting", back_populates="user", uselist=False, cascade="all, delete-orphan")
    support_tickets = relationship("SupportTicket", back_populates="user", cascade="all, delete-orphan")


class ChildProfile(Base):
    __tablename__ = "child_profiles"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    parent_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    name = Column(String, nullable=False)
    picture_password = Column(JSON, nullable=False)  # Stored as JSON array of strings
    date_of_birth = Column(Date, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
    age = Column(Integer, nullable=True)
    avatar = Column(String, nullable=True)

    parent = relationship("User", back_populates="children")


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    child_id = Column(Integer, ForeignKey("child_profiles.id"), nullable=True, index=True)
    type = Column(String, nullable=False, default="SYSTEM")
    title = Column(String, nullable=False)
    body = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    is_read = Column(Boolean, default=False, nullable=False)

    user = relationship("User", back_populates="notifications")


class PrivacySetting(Base):
    __tablename__ = "privacy_settings"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, unique=True, index=True)
    data_collection_opt_out = Column(Boolean, default=False, nullable=False)
    personalized_recommendations = Column(Boolean, default=True, nullable=False)
    analytics_enabled = Column(Boolean, default=True, nullable=False)

    user = relationship("User", back_populates="privacy_setting")


class SupportTicket(Base):
    __tablename__ = "support_tickets"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    subject = Column(String, nullable=False)
    message = Column(String, nullable=False)
    email = Column(String, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)

    user = relationship("User", back_populates="support_tickets")


class ParentalControl(Base):
    __tablename__ = "parental_controls"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, unique=True, index=True)
    daily_limit_enabled = Column(Boolean, default=True, nullable=False)
    hours_per_day = Column(Integer, default=2, nullable=False)
    break_reminders_enabled = Column(Boolean, default=True, nullable=False)
    age_appropriate_only = Column(Boolean, default=True, nullable=False)
    block_educational = Column(Boolean, default=False, nullable=False)
    require_approval = Column(Boolean, default=False, nullable=False)
    sleep_mode = Column(Boolean, default=True, nullable=False)
    bedtime = Column(String, nullable=True)
    wake_time = Column(String, nullable=True)
    emergency_lock = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)


class PaymentMethod(Base):
    __tablename__ = "payment_methods"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    label = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)

