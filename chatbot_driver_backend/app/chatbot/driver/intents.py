import re

from app.ai.intent.schema import IntentResult
from app.ai.language.detector import language_detector
from app.chatbot.common.intents import (
    ACTIVE_SAFETY_PATTERN,
    COMMON_ACCOUNT_PATTERN,
    COMMON_FAQ_PATTERN,
    COMMON_HUMAN_AGENT_PATTERN,
    IMMEDIATE_EMERGENCY_OVERRIDE,
    SAFETY_POLICY_PATTERN,
    is_policy_faq_text,
)
from app.common.enums.chat import Intent, Priority, RiskLevel

DRIVER_INTENT_KEYWORD_MAP: list[tuple[Intent, re.Pattern]] = [
    # 1. Customer cancellation (Passenger cancelled)
    (Intent.CUSTOMER_CANCELLED, re.compile(
        r"(customer|rider|passenger).*(cancel|cancelled|रद्द|कैंसिल)"
        r"|cancellation fee.*(milegi|driver|milna)"
        r"|passenger ne.*(cancel|रद्द)"
        r"|rider ne.*(cancel|रद्द)"
        r"|customer ne.*(cancel|रद्द)"
        r"|ride cancel kar di|trip cancel kar di|cancel kardi",
        re.I,
    )),
    # 2. Customer not found
    (Intent.CUSTOMER_NOT_FOUND, re.compile(
        r"(customer|rider|passenger) (is )?not (at|found|here)|rider missing|customer nahi mila|customer nahi hai|rider location pe nahi"
        r"|customer unreachable|customer not picking|passenger missing|passenger nahi mil|nahi mil raha|cannot find.*passenger"
        r"|not at the pickup|pickup location par nahi|pickup spot par nahi|pickup par nahi",
        re.I,
    )),
    # 3. Ride offer / acceptance
    (Intent.ACCEPTANCE, re.compile(r"accept.*(ride|booking|duty|rule|rules|policy)|ride accept|booking accept|duty accept|cannot accept|accept issue|duty accept nahi", re.I)),
    (Intent.RIDE_OFFER, re.compile(
        r"ride offer|booking offer|offer nahi aa|ride offer nahi|booking nahi mil"
        r"|the ride request disappeared|ride request.*(disappear|expire|timeout|timed out|miss|chali gayi|gayab)"
        r"|request.*(disappear|expire|timeout|timed out|gayab)|offer.*(disappear|expire|timeout|timed out|gayab)|request disappear"
        r"|राइड.*(विनंती|ऑफर).*(गायब|गेली|नाही|संपली)|विनंती.*(गायब|गेली)",
        re.I,
    )),
    # 3b. Active ride / trip status
    (Intent.RIDE_STATUS, re.compile(
        r"where is my (active )?ride|ride status|active ride|current trip|active trip|current ride"
        r"|मेरी एक्टिव राइड|एक्टिव राइड|સક્રિય રાઇડ|સર્ગરમ રાઇડ|সক্রিয় রাইড|ਸਰਗਰਮ ਰਾਈਡ"
        r"|મારી એક્ટિવ રાઇડ|আমার সক্রিয় রাইড|ਤੁਹਾਡੀ ਸਰਗਰਮ ਰਾਈਡ"
        r"|meri active ride|active ride kahan|active ride status",
        re.I,
    )),
    # 4. Payout status (Must precede cash payment / general queries)
    (Intent.PAYOUT, re.compile(
        r"payout|withdraw|bank transfer|payout delay|paise kab aayenge|payout issue|bank payout"
        r"|payment.*(arrive|aayeg|aayi|delay|status)|payment kab aayegi|payment abhi tak nahi"
        r"|when will my payout|when will.*payout arrive|when will i get paid|payout kab receive"
        r"|when will my payment arrive|my payout is delayed|payment abhi tak nahi aayi|payment nahi aayi hai",
        re.I,
    )),
    # 5. Incentives / Bonus
    (Intent.INCENTIVE, re.compile(r"incentive|bonus|target bonus|trip bonus|peak hour bonus|incentive status|bonus kab milega|incentive nahi mila|incentive abhi tak nahi", re.I)),
    # 6. Document status / verification
    (Intent.DOCUMENT_STATUS, re.compile(
        r"document.*(status|approve|reject|expir|require|needed|list|rule|verification|verify|verified)|(license|rc|insurance).*(expir|status|approve|require|needed)"
        r"|driver verification|verification pending|verification status|my documents are pending|driving documents"
        r"|kagaz|document verification|what documents|driver document|onboarding document|दस्तावेज़|દસ્તાવેજ|নথি",
        re.I,
    )),
    # 7. Vehicle / document support
    (Intent.VEHICLE_DOCUMENT, re.compile(r"vehicle (document|support|change)|add vehicle|change vehicle|update rc|gadi badalna|new vehicle", re.I)),
    # 8. Navigation & App troubleshooting
    (Intent.NAVIGATION, re.compile(r"navigation|gps|map issue|map wrong|galat route|map nahi chal|navigation kaam nahi", re.I)),
    (Intent.APP_TROUBLESHOOTING, re.compile(r"app (crash|freeze|freezing|hang|issue|kharab|update|not working|work|problem|error)|not working|slow app|driver app", re.I)),
    # 9. Cash payment dispute
    (Intent.CASH_PAYMENT, re.compile(
        r"cash payment|cash ride|customer didn'?t pay|customer did not|customer has not paid|cash nahi diya|cash collection|cash amount"
        r"|payment nahi|ne payment|payment nahi kiya|payment nahi mila|payment nahi hua|pay nahi kiya|payment नहीं"
        r"|भुगतान नहीं|पैसे नहीं दिए|कैश नहीं दिया|रुपये नहीं दिए|पैसे नहीं मिले|कैश नहीं मिला"
        r"|भुगतान कोनी|कोनी कर्यो|पिया कोनी|पैसे कोनी|कोनी दिया|koni karyo|koni"
        r"|ਭੁਗਤਾਨ ਨਹੀਂ ਕੀਤਾ|ਕੀਤਾ|kiti|kitta|ਪੈਸੇ ਨਹੀਂ ਦਿੱਤੇ"
        r"|ચુકવણી કરી નથી|nathi kari|nathi|પૈસા નથી આપ્યા|payment કર્યું નથી"
        r"|পেমেন্ট করেনি|টাকা দেয়নি|ক্যাশ|payment করেনি"
        r"|पेमेंट केले नाही|पैसे दिले नाहीत|कॅश दिली नाही"
        r"|பணம் செலுத்தவில்லை|பணம் தரவில்லை"
        r"|చెల్లింపు చేయలేదు|డబ్బులు ఇవ్వలేదు"
        r"|ಪಾವತಿ ಮಾಡಲಿಲ್ಲ|ಹಣ ನೀಡಲಿಲ್ಲ"
        r"|പണമടച്ചില്ല|പണം നൽകിയില്ല"
        r"|ଦେୟ ଦେଇନାହାଁନ୍ତି|ଟଙ୍କା ଦେଇନାହାଁନ୍ତି"
        r"|পৰিশোধ কৰা নাই|টকা দিয়া নাই"
        r"|ادائیگی نہیں کی|رقم نہیں دی",
        re.I,
    )),
    # 10. Earnings (daily, weekly, monthly)
    (Intent.EARNINGS, re.compile(
        r"\bearnings?\b|kamai|daily earning|weekly earning|monthly earning|kitna kamaya|today'?s earning|haftewari kamai|aaj ki kamai|how much did i earn"
        r"|total earning|earning kitni|kitni earning",
        re.I,
    )),
    # 10b. Trip fare inquiries
    (Intent.FARE, re.compile(
        r"fare|price|kitna paisa|charge|how much.*fare|fare breakdown|calculated|why.*fare|fare calculation|fare policy"
        r"|किराया|ज्यादा पैसे|अधिक पैसे|extra paise|paise cut|paise kyu cut|jyada paise|zyada paise",
        re.I,
    )),
    # 11. Account, FAQ, Human Agent
    (Intent.ACCOUNT, COMMON_ACCOUNT_PATTERN),
    (Intent.HUMAN_AGENT, COMMON_HUMAN_AGENT_PATTERN),
    (Intent.FAQ, COMMON_FAQ_PATTERN),
]


class DriverIntentRouter:
    """Driver Chatbot Intent Router: Strictly scopes classification to driver use cases."""

    def detect(self, text: str) -> IntentResult:
        language = language_detector.detect(text)

        # 1. P0 Safety Emergency vs P3 Safety Policy Inquiry
        is_policy_past = bool(SAFETY_POLICY_PATTERN.search(text)) and not bool(IMMEDIATE_EMERGENCY_OVERRIDE.search(text))
        if is_policy_past and ACTIVE_SAFETY_PATTERN.search(text):
            return IntentResult(
                intent=Intent.SAFETY,
                confidence=0.90,
                urgency=Priority.P3_FAQ,
                language=language,
                requires_tool=False,
                requires_human=False,
                risk_level=RiskLevel.LOW,
            )

        if ACTIVE_SAFETY_PATTERN.search(text):
            return IntentResult(
                intent=Intent.SAFETY,
                confidence=0.95,
                urgency=Priority.P0_EMERGENCY,
                language=language,
                requires_tool=True,
                requires_human=True,
                risk_level=RiskLevel.CRITICAL,
            )

        # 2. Driver intent keyword routing
        for intent, pattern in DRIVER_INTENT_KEYWORD_MAP:
            if pattern.search(text):
                is_policy = is_policy_faq_text(text)
                return IntentResult(
                    intent=intent,
                    confidence=0.75,
                    urgency=self._determine_urgency(text, intent),
                    language=language,
                    requires_tool=False if is_policy else self._requires_tool(intent, text),
                    risk_level=self._risk_level(intent),
                )

        return IntentResult(
            intent=Intent.UNKNOWN,
            confidence=0.2,
            urgency=Priority.P3_FAQ,
            language=language,
        )

    @staticmethod
    def _determine_urgency(text: str, intent: Intent) -> Priority:
        text_lower = text.lower()
        if ACTIVE_SAFETY_PATTERN.search(text):
            is_policy_past = bool(SAFETY_POLICY_PATTERN.search(text)) and not bool(IMMEDIATE_EMERGENCY_OVERRIDE.search(text))
            if is_policy_past:
                return Priority.P3_FAQ
            return Priority.P0_EMERGENCY

        if any(w in text_lower for w in ["hack", "hacked", "compromise", "compromised", "account hacked"]) or \
           (any(w in text_lower for w in ["critical", "blocked", "cannot access", "severely blocked"]) and any(w in text_lower for w in ["payment", "earning", "earnings", "payout"])):
            return Priority.P1_CRITICAL

        if intent in {Intent.CASH_PAYMENT, Intent.CUSTOMER_NOT_FOUND, Intent.PAYOUT}:
            return Priority.P1_CRITICAL

        if is_policy_faq_text(text):
            return Priority.P3_FAQ

        return Priority.P2_STANDARD

    @classmethod
    def _requires_tool(cls, intent: Intent, text: str = "") -> bool:
        if text and is_policy_faq_text(text):
            return False
        return intent in {
            Intent.RIDE_STATUS,
            Intent.EARNINGS,
            Intent.PAYOUT,
            Intent.INCENTIVE,
            Intent.DOCUMENT_STATUS,
            Intent.VEHICLE_DOCUMENT,
            Intent.CASH_PAYMENT,
            Intent.RIDE_OFFER,
            Intent.ACCEPTANCE,
            Intent.CUSTOMER_NOT_FOUND,
            Intent.CUSTOMER_CANCELLED,
            Intent.HUMAN_AGENT,
        }

    @staticmethod
    def _risk_level(intent: Intent) -> RiskLevel:
        if intent in {Intent.PAYOUT, Intent.VEHICLE_DOCUMENT, Intent.CASH_PAYMENT}:
            return RiskLevel.MEDIUM
        if intent == Intent.ACCOUNT:
            return RiskLevel.HIGH
        return RiskLevel.LOW


driver_intent_router = DriverIntentRouter()
