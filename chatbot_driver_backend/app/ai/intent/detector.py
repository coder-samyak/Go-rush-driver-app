"""
Driver Chatbot Intent Detector.
Routes queries strictly using the DriverIntentRouter.
Customer-specific intents are not recognized and return UNKNOWN.
"""
from app.ai.intent.schema import IntentResult
from app.chatbot.driver.intents import driver_intent_router, DriverIntentRouter
from app.common.enums.chat import Intent, Priority, RiskLevel

class IntentDetector(DriverIntentRouter):
    """Driver Chatbot Intent Detector for all driver-partner queries."""
    pass

intent_detector = driver_intent_router
