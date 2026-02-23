from fastapi import APIRouter

router = APIRouter(tags=["content"])

HELP_FAQ = [
    {
        "question": "How do I add a child profile?",
        "answer": "Use the plus button on the child login screen or go through the parent dashboard and tap 'Create Child'.",
    },
    {
        "question": "What should I do if I forget the picture password?",
        "answer": "Parents can reset the profile from the dashboard by removing and re-adding the child profile.",
    },
]

ABOUT_INFO = {
    "title": "About Kinder",
    "body": "Kinder helps parents monitor learning goals and manage screen time in a safe, child-friendly environment.",
}

LEGAL_TERMS = "These are the Terms of Service for Kinder."
LEGAL_PRIVACY = "This is the Privacy Policy for Kinder."
LEGAL_COPPA = "COPPA compliance details go here."


@router.get("/content/help-faq")
def help_faq():
    return {"items": HELP_FAQ}


@router.get("/content/about")
def about():
    return ABOUT_INFO


@router.get("/legal/terms")
def terms():
    return {"content": LEGAL_TERMS}


@router.get("/legal/privacy")
def privacy():
    return {"content": LEGAL_PRIVACY}


@router.get("/legal/coppa")
def coppa():
    return {"content": LEGAL_COPPA}
