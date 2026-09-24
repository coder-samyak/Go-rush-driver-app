import re
from app.common.enums.chat import Intent, Priority, RiskLevel

# Multilingual safety patterns for active emergencies (P0) vs safety policy/procedure inquiries (P3)
SAFETY_POLICY_PATTERN = re.compile(
    r"(procedure|policy|rules|guidelines|what (to|should i) do after|yesterday|last week|few days ago|past accident"
    r"|नियम|नीति|प्रक्रिया|दिशा-निर्देश|कल हुआ|कल का|पिछले हफ्ते|क्या करना चाहिए|kya karein|kya karna"
    r"|પોલિસી|પ્રક્રિયા|ਨਿਯਮ|ਪ੍ਰਕਿਰਿਆ)",
    re.IGNORECASE,
)

IMMEDIATE_EMERGENCY_OVERRIDE = re.compile(
    r"(turant|abhi|right now|immediately|call police|in danger|help me right now|save me|तुरंत|अभी|तत्काल)",
    re.IGNORECASE,
)

ACTIVE_SAFETY_PATTERN = re.compile(
    r"(accident|i crashed|car crash|vehicle crash|crashed into|crashed my|crashed the|had a crash|collision|hit|durghatna|hadsa|akastmat|apghat"
    r"|एक्सीडेंट|दुर्घटना|हादसा|अपघात|અકસ્માત|দুর্ঘটনা|حادثہ|விபத்து|అపాయం|ಅಪಘಾತ|അപകടം"
    r"|emergency|sos|danger|dangerous|unsafe|khatra|khatre|in danger|feel unsafe|don'?t feel safe|safe feel|safe feel nahi|सुरक्षित महसूस नहीं"
    r"|damaged my vehicle|damage.*vehicle|damage.*car|car damage|gaadi damage|gadi damage|gaadi.*damage|gadi.*damage|damage.*gaadi|damage.*gadi"
    r"|आपातकाल|आपत्कालीन|खतरा|खतरे|जोखम|धोका|বিপদ|അപകടം|అత్యవసరం|ತುರ್ತು"
    r"|threat|threatened|threaten|dhamki|attack|attacked|assault|assaulted|harass|harassed|hamla|behaving badly|badly behave|bad behavior|misbehave"
    r"|धमकी|हमला|हल्ला|হুমকি|হামলা|బెదిరింపు|ದಾಳಿ|ഭീഷണി|बुरा व्यवहार"
    r"|police|ambulance|help emergency|help accident|immediate help|turant madad|turant sahayata|abhi help|save me|bachao"
    r"|मदद|सहायता|पुलिस|एंबुलेंस|बचाओ|ਮਦਦ|ਸਹਾਇਤਾ|ਮਦਦ|પોલીસ|మదత్|உதவி|ಸಹಾಯ|സഹായം"
    r"|सहायता चाहिए|मदद चाहिए|help chahiye)",
    re.IGNORECASE,
)

COMMON_HUMAN_AGENT_PATTERN = re.compile(
    r"human agent|talk to (a )?person|real agent|connect.*agent|agent connect|agent.*connect|connect.*support|support agent|customer care|speak to agent|driver support|support se baat|agent se baat|human support|customer support|need.*support|need human support|सपोर्ट से बात|सपोर्ट एजेंट|बात करनी है",
    re.IGNORECASE,
)

COMMON_FAQ_PATTERN = re.compile(
    r"faq|help center|support sla|support time|how long.*support|response time|general query|help info|\bsla\b",
    re.IGNORECASE,
)

COMMON_ACCOUNT_PATTERN = re.compile(
    r"account|profile|login|password|delete.*(account|data)|change.*(email|phone|setting|settings)|name change|privacy|onboard|onboarding|join as driver|sign up driver|register driver|चालक पंजीकरण",
    re.IGNORECASE,
)


def is_policy_faq_text(text: str) -> bool:
    text_lower = text.lower()
    policy_phrases = [
        "policy", "rule", "rules", "how does", "what is the", "what are the",
        "terms", "faq", "procedure", "how long does", "what documents do", "how to", "what documents are",
        "why was", "how is", "explain", "onboarding", "sla", "process", "tell me about", "can you explain",
        "when can", "what happens if", "what should i do", "how can i",
        "पॉलिसी", "नियम", "क्या नियम", "नियम क्या", "प्रक्रिया", "दिशा-निर्देश", "kya hai", "kya hain",
        "પોલિસી", "નિયમો", "શું છે", "নীতি", "নিয়ম", "কী"
    ]
    exclude_personal = [
        "my document", "my documents", "my ride", "my refund", "my payment", "my earnings", "check my", "cancel my", "my account"
    ]
    return any(p in text_lower for p in policy_phrases) and not any(p in text_lower for p in exclude_personal)
