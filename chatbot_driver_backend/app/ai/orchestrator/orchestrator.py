"""
Driver Chatbot Orchestrator.
Exclusively serves Driver Flutter App queries (trips, earnings, documents, driver safety, support).
Customer workflows are not handled here.
"""
from app.chatbot.driver.orchestrator import DriverChatbot

class ChatOrchestrator(DriverChatbot):
    """ChatOrchestrator for GoRush Driver AI Chatbot."""
    pass