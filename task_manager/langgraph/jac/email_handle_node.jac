import from states { AppState }
import from prompts { EMAIL_DECIDER_PROMPT, EMAIL_DRAFT_PROMPT, llm }
import from email.mime.text { MIMEText }
import smtplib;
import json;
import os;

def email_decider_node(state: AppState) -> AppState {
    history = state.get("history", [])[-10:];
    hist_txt = "\n".join(history);
    
    raw = (EMAIL_DECIDER_PROMPT | llm).invoke({
        "history": hist_txt,
        "utterance": state.get("utterance", "")
    }).content;
    try {
        data = json.loads(raw);
        action = data.get("action", "DRAFT");
        if action not in {"DRAFT", "SEND"} {
            action = "DRAFT";
        }
    } except Exception {
        action = "DRAFT";
    }
    state["email_action"] = action;
    return state;
}

def email_draft_node(state: AppState) -> AppState {
    history = state.get("history", [])[-10:];
    hist_txt = "\n".join(history);

    raw = (EMAIL_DRAFT_PROMPT | llm).invoke({"history": hist_txt, "utterance": state.get("utterance","")}).content;
    try {
        data = json.loads(raw);
        draft = f"To: {data.get('to','')}\nSubject: {data.get('subject','')}\n\n{data.get('body','')}";
        state["response"] = "Here is your email draft (sending is not enabled in this step):\n\n" + draft + "\n\n(To send this email, please confirm it.)";
        state["email_to"] = data.get("to","");
        state["email_subject"] = data.get("subject","");
        state["email_content"] = data.get("body","");
    } except Exception as e {
        state["response"] = f"Couldn't prepare the email draft. ({e})";
    }
    return state;
}

def send_email(state: AppState) -> AppState {
    email_to = (state.get("email_to") or "").strip();
    email_subject = (state.get("email_subject") or "").strip();
    email_content = state.get("email_content") or "";

    if not email_to or email_to == "someone@example.com" {
        state["response"] = "No valid recipient found. Please include a real 'to' address.";
        return state;
    }
    if not email_subject {
        state["response"] = "Subject is empty. Please add a subject before sending.";
        return state;
    }
    if not email_content.strip() {
        state["response"] = "Body is empty. Please add content before sending.";
        return state;
    }

    msg = MIMEText(email_content, _charset="utf-8");
    msg["Subject"] = email_subject;
    msg["From"] = os.getenv("SENDER_EMAIL");
    msg["To"] = email_to;

    try {
        server = smtplib.SMTP("smtp.gmail.com", 587, timeout=30);
        server.ehlo();
        server.starttls();
        server.ehlo();
        server.login(os.getenv("SENDER_EMAIL"), os.getenv("SENDER_PASSWORD"));
        server.sendmail(os.getenv("SENDER_EMAIL"), [email_to], msg.as_string());  # list!
        server.quit();
        state["response"] = f"Email sent to {email_to} with subject '{email_subject}'.";
    } except Exception as e {
        state["response"] = f"Failed to send email. ({e})";
    }
    return state;
}
